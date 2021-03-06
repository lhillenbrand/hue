## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
  from desktop.views import commonheader, commonfooter
%>
<%namespace name="comps" file="jobbrowser_components.mako" />

${commonheader("Job Task: " + task.taskId + "- Job Browser", "jobbrowser")}

<div class="container-fluid">
	<h1>Job Task: ${task.taskId} - Job Browser</h1>
	<div class="row-fluid">
		<div class="span2">
			<div class="well sidebar-nav">
				<h6>Task ID</h6>
				${task.taskId_short}

				<h6>Job</h6>
				<a href="${url('jobbrowser.views.single_job', jobid=joblnk.jobId)}" class="frame_tip jt_view" title="View this job">${joblnk.jobId_short}</a>

				<h6>Status</h6>
				% if task.state.lower() == 'running' or task.state.lower() == 'pending':
					<span class="label label-warning">${task.state.lower()}</span>
				% elif task.state.lower() == 'succeeded':
					<span class="label label-success">${task.state.lower()}</span>
				% else:
					<span class="label">${task.state.lower()}</span>
				% endif
			</div>
		</div>
		<div class="span10">
			<ul class="nav nav-tabs">
				<li class="active"><a href="#attempts" data-toggle="tab">Attempts</a></li>
				<li><a href="#metadata" data-toggle="tab">Metadata</a></li>
				<li><a href="#counters" data-toggle="tab">Counters</a></li>
			</ul>

			<div class="tab-content">
				<div class="tab-pane active" id="attempts">
					<table id="attemptsTable" class="table table-striped table-condensed">
		              <thead>
		                <tr>
		                 <th>Attempt ID</th>
		                 <th>Progress</th>
		                 <th>State</th>
		                 <th>Task Tracker</th>
		                 <th>Start Time</th>
		                 <th>End Time</th>
		                 <th>Output Size</th>
		                 <th>Phase</th>
		                 <th>Shuffle Finish</th>
		                 <th>Sort Finish</th>
		                 <th>Map Finish</th>
		                 <th>View</th>
		                </tr>
		              </thead>
		              <tbody>
		                % for attempt in task.attempts:
		                 <tr data-dblclick-delegate="{'dblclick_loads':'.view_attempt'}">
		                   <td>${attempt.attemptId_short}</td>
		                   <td>${"%d" % (attempt.progress * 100)}%</td>
		                   <td><span class="status_link ${attempt.state}">${attempt.state}</span></td>
		                   <td><a href="/jobbrowser/trackers/${attempt.taskTrackerId}" class="task_tracker_link">${attempt.taskTrackerId}</a></td>
		                   <td>${attempt.startTimeFormatted}</td>
		                   <td>${attempt.finishTimeFormatted}</td>
		                   <td>${attempt.outputSize}</td>
		                   <td>${attempt.phase}</td>
		                   <td>${attempt.shuffleFinishTimeFormatted}</td>
		                   <td>${attempt.sortFinishTimeFormatted}</td>
		                   <td>${attempt.mapFinishTimeFormatted}</td>
		                   <td><a class="frame_tip jtask_view jt_slide_right view_attempt" title="View this attempt"
		                          href="${ url('jobbrowser.views.single_task_attempt', jobid=joblnk.jobId, taskid=task.taskId, attemptid=attempt.attemptId) }">View</a></td>
		                 </tr>
		                % endfor
		              </tbody>
		            </table>
				</div>
				<div id="metadata" class="tab-pane">
					<table id="metadataTable" class="table table-striped table-condensed">
		              <thead>
		                <th>Name</th>
		                <th>Value</th>
		              </thead>
		              <tbody>
		                <tr>
		                  <td>Task id</td>
		                  <td>${task.taskId}</td>
		                </tr>
		                <tr>
		                  <td>Type</td>
		                  <td>${task.taskType}</td>
		                </tr>
		                <tr>
		                  <td>JobId</td>
		                  <td><a href="${url('jobbrowser.views.single_job', jobid=joblnk.jobId)}" class="frame_tip jt_view" title="View this job">${joblnk.jobId}</a></td>
		                </tr>
		                <tr>
		                  <td>State</td>
		                  <td>${task.state}</td>
		                </tr>
		                <tr>
		                  <td>Status</td>
		                  <td>${task.mostRecentState}</td>
		                </tr>
		                <tr>
		                  <td>Start Time</td>
		                  <td>${task.startTimeFormatted}</td>
		                </tr>
		                <tr>
		                  <td>Execution Start Time</td>
		                  <td>${task.execStartTimeFormatted}</td>
		                </tr>
		                <tr>
		                  <td>Execution Finish Time</td>
		                  <td>${task.execFinishTimeFormatted}</td>
		                </tr>
		                <tr>
		                  <td>Progress</td>
		                  <td>${"%d" % (task.progress * 100)}%</td>
		                </tr>
		              </tbody>
		            </table>
				</div>
				<div id="counters" class="tab-pane">
					${comps.task_counters(task.counters)}
				</div>
			</div>
		</div>
	</div>
</div>



		<script type="text/javascript" charset="utf-8">
			$(document).ready(function(){
				$("#attemptsTable").dataTable({
					"bPaginate": false,
				    "bLengthChange": false,
					"bInfo": false,
					"bFilter": false
				});
				$("#metadataTable").dataTable({
					"bPaginate": false,
				    "bLengthChange": false,
					"bInfo": false,
					"bAutoWidth": false,
					"bFilter": false,
					"aoColumns": [
						{ "sWidth": "30%" },
						{ "sWidth": "70%" }
					]
				});

				$(".taskCountersTable").dataTable({
					"bPaginate": false,
				    "bLengthChange": false,
					"bInfo": false,
					"bAutoWidth": false,
					"aoColumns": [
						{ "sWidth": "30%" },
						{ "sWidth": "70%" }
					]
				});

				$(".dataTables_wrapper").css("min-height","0");
				$(".dataTables_filter").hide();

			});
		</script>


    ${commonfooter()}
