#!/usr/bin/env python
# Licensed to Cloudera, Inc. under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  Cloudera, Inc. licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""
Views for JobSubmission.

The typical workflow has a user creating a "job design".
Existing job designs can also be edited and listed.
To "run" the job design, it must be parameterized, and submitted
to the cluster.  A parameterized, submitted job design
is a "job submission".  Submissions can be "watched".
"""

try:
  import json
except ImportError:
  import simplejson as json
import logging


from django.core import urlresolvers
from django.shortcuts import redirect

from desktop.lib.django_util import render, PopupException, extract_field_data
from desktop.lib.rest.http_client import RestException
from desktop.log.access import access_warn

from hadoop.fs.exceptions import WebHdfsException

from jobsub import models, submit
from jobsub.management.commands import jobsub_setup
from jobsub.oozie_lib.oozie_api import get_oozie
import jobsub.forms


LOG = logging.getLogger(__name__)


def oozie_job(request, jobid):
  """View the details about this job."""
  try:
    workflow = get_oozie().get_job(jobid)
    _check_permission(request, workflow.user,
                      "Access denied: view job %s" % (jobid,),
                      allow_root=True)
    # Accessing log and definition will trigger Oozie API calls
    log = workflow.log
    definition = workflow.definition
  except RestException, ex:
    raise PopupException("Error accessing Oozie job %s" % (jobid,),
                         detail=ex.message)

  # Cross reference the submission history (if any)
  design_link = None
  try:
    history_record = models.JobHistory.objects.get(job_id=jobid)
    design = history_record.design
    if design.owner == request.user:
      design_link = urlresolvers.reverse(jobsub.views.edit_design,
                                         kwargs={'design_id': design.id})
  except models.JobHistory.DoesNotExist, ex:
    pass

  return render('workflow.mako', request, {
    'workflow': workflow,
    'design_link': design_link,
    'definition': definition,
    'log': log,
  })


def list_history(request):
  """
  List the job submission history. Normal users can only look at their
  own submissions.
  """
  history = models.JobHistory.objects

  if not request.user.is_superuser:
    history = history.filter(owner=request.user)
  history = history.order_by('-submission_date')

  return render('list_history.mako', request, {
    'history': history,
  })


def new_design(request, action_type):
  form = jobsub.forms.design_form_by_type(action_type)

  if request.method == 'POST':
    form.bind(request.POST)

    if form.is_valid():
      action = form.action.save(commit=False)
      action.action_type = action_type
      action.save()

      design = form.wf.save(commit=False)
      design.root_action = action
      design.owner = request.user
      design.save()

      return redirect(urlresolvers.reverse(list_designs))
  else:
    form.bind()

  return _render_design_edit(request, form, action_type, _STD_PROPERTIES_JSON)


def _render_design_edit(request, form, action_type, properties_hint):
  return render('edit_design.mako', request, {
    'form': form,
    'action': request.path,
    'action_type': action_type,
    'properties': extract_field_data(form.action['job_properties']),
    'files': extract_field_data(form.action['files']),
    'archives': extract_field_data(form.action['archives']),
    'properties_hint': properties_hint,
  })


def list_designs(request):
  '''
  List all workflow designs. Result sorted by last modification time.
  Query params:
    owner       - Substring filter by owner field
    name        - Substring filter by design name field
  '''
  data = models.OozieDesign.objects
  owner = request.GET.get("owner", '')
  name = request.GET.get('name', '')
  if owner:
    data = data.filter(owner__username__icontains=owner)
  if name:
    data = data.filter(name__icontains=name)
  data = data.order_by('-last_modified')
  show_install_examples = \
      request.user.is_superuser and not jobsub_setup.Command().has_been_setup()

  return render("list_designs.mako", request, {
    'designs': list(data),
    'currentuser':request.user,
    'owner': owner,
    'name': name,
    'show_install_examples': show_install_examples,
  })


def _get_design(design_id):
  """Raise PopupException if design doesn't exist"""
  try:
    return models.OozieDesign.objects.get(pk=design_id)
  except models.OozieDesign.DoesNotExist:
    raise PopupException("Job design not found")

def _check_permission(request, owner_name, error_msg, allow_root=False):
  """Raise PopupException if user doesn't have permission to modify the design"""
  if request.user.username != owner_name:
    if allow_root and request.user.is_superuser:
      return
    access_warn(request, error_msg)
    raise PopupException("Permission denied. You are not the owner.")


def delete_design(request, design_id):
  if request.method == 'POST':
    try:
      design_obj = _get_design(design_id)
      _check_permission(request, design_obj.owner.username,
                        "Access denied: delete design %s" % (design_id,),
                        allow_root=True)
      design_obj.root_action.delete()
      design_obj.delete()

      submit.Submission(design_obj, request.fs).remove_deployment_dir()
    except models.OozieDesign.DoesNotExist:
      LOG.error("Trying to delete non-existent design (id %s)" % (design_id,))
      raise PopupException("Workflow not found")

  return redirect(urlresolvers.reverse(list_designs))


def edit_design(request, design_id):
  design_obj = _get_design(design_id)
  _check_permission(request, design_obj.owner.username,
                    "Access denied: edit design %s" % (design_id,))

  if request.method == 'POST':
    form = jobsub.forms.design_form_by_instance(design_obj, request.POST)
    if form.is_valid():
      form.action.save()
      form.wf.save()
      return redirect(urlresolvers.reverse(list_designs))
  else:
    form = jobsub.forms.design_form_by_instance(design_obj)

  return _render_design_edit(request,
                               form,
                               design_obj.root_action.action_type,
                               _STD_PROPERTIES_JSON)


def clone_design(request, design_id):
  design_obj = _get_design(design_id)
  clone = design_obj.clone(request.user)
  return redirect(urlresolvers.reverse(edit_design, kwargs={'design_id': clone.id}))


def get_design_params(request, design_id):
  """
  Return the parameters found in the design as a json dictionary of
    { param_key : label }
  This expects an ajax call.
  """
  design_obj = _get_design(design_id)
  _check_permission(request, design_obj.owner.username,
                    "Access denied: design parameters %s" % (design_id,))
  params = design_obj.find_parameters()
  params_with_labels = dict((p, p.upper()) for p in params)
  return render('dont_care_for_ajax', request, { 'params': params_with_labels })


def submit_design(request, design_id):
  """
  Submit a workflow to Oozie.
  The POST data should contain parameter values.
  """
  if request.method != 'POST':
    raise PopupException('Please use a POST request to submit a design.')

  design_obj = _get_design(design_id)
  _check_permission(request, design_obj.owner.username,
                    "Access denied: submit design %s" % (design_id,))

  # Expect the parameter mapping in the POST data
  param_mapping = request.POST
  design_obj.bind_parameters(request.POST)

  try:
    submission = submit.Submission(design_obj, request.fs)
    jobid = submission.run()
  except RestException, ex:
    raise PopupException("Error submitting design %s" % (design_id,),
                         detail=ex.message)
  # Save the submission record
  job_record = models.JobHistory(owner=request.user,
                                 job_id=jobid,
                                 design=design_obj)
  job_record.save()

  # Show oozie job info
  return redirect(urlresolvers.reverse(oozie_job, kwargs={'jobid': jobid}))


def setup(request):
  """Installs jobsub examples."""
  if request.method != "POST":
    raise PopupException('Please use a POST request to install the examples.')
  try:
    # Warning: below will modify fs.user
    jobsub_setup.Command().handle_noargs()
  except WebHdfsException, e:
    raise PopupException('The examples could not be installed.', detail=e)
  return redirect(urlresolvers.reverse(list_designs))



# See http://wiki.apache.org/hadoop/JobConfFile
_STD_PROPERTIES = [
  'mapred.input.dir',
  'mapred.output.dir',
  'mapred.job.name',
  'mapred.job.queue.name',
  'mapred.mapper.class',
  'mapred.reducer.class',
  'mapred.combiner.class',
  'mapred.partitioner.class',
  'mapred.map.tasks',
  'mapred.reduce.tasks',
  'mapred.input.format.class',
  'mapred.output.format.class',
  'mapred.input.key.class',
  'mapred.input.value.class',
  'mapred.output.key.class',
  'mapred.output.value.class',
  'mapred.mapoutput.key.class',
  'mapred.mapoutput.value.class',
  'mapred.combine.buffer.size',
  'mapred.min.split.size',
  'mapred.speculative.execution',
  'mapred.map.tasks.speculative.execution',
  'mapred.reduce.tasks.speculative.execution',
  'mapred.queue.default.acl-administer-jobs',
]

_STD_PROPERTIES_JSON = json.dumps(_STD_PROPERTIES)
