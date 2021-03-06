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
<%namespace name="layout" file="layout.mako" />
<%namespace name="comps" file="beeswax_components.mako" />
<%namespace name="util" file="util.mako" />
${commonheader("Beeswax: Create table from file", "beeswax", "100px")}
${layout.menubar(section='history')}
<div class="container-fluid">
% if error_msg:
<h4>${error_msg}</h4>
% endif
<h1>Save Query Results</h1>
<form id="saveForm" action="${action}" method="POST" class="form form-inline">
	<label class="radio">
		<input id="id_save_target_0" type="radio" name="save_target" value="to a new table" checked="checked"/>
		&nbsp;In a new table
	</label>
	${comps.field(form['target_table'], notitle=True, placeholder="Table Name")}
	<br/>
	<label class="radio">
		<input id="id_save_target_1" type="radio" name="save_target" value="to HDFS directory">
		&nbsp;In an HDFS directory
	</label>
	${comps.field(form['target_dir'], notitle=True, hidden=True, placeholder="Results location")}
  <br/><br/>
  <input type="submit" name="save" value="Save" class="btn primary"/>
  <input type="submit" name="cancel" value="Cancel" class="btn"/>
</form>
</div>


<script type="text/javascript" charset="utf-8">
	$(document).ready(function(){
		$("input[name='save_target']").change(function(){
			$("#fieldRequired").addClass("hidden");
			$("input[name='target_dir']").removeClass("fieldError");
			$("input[name='target_table']").removeClass("fieldError");
			if ($(this).val().indexOf("HDFS")>-1){
				$("input[name='target_table']").addClass("hidden");
				$("input[name='target_dir']").removeClass("hidden");
			}
			else {
				$("input[name='target_table']").removeClass("hidden");
				$("input[name='target_dir']").addClass("hidden");
			}
		});

		$("#saveForm").submit(function(e){
			if ($(e.originalEvent.explicitOriginalTarget).attr("name") == "cancel"){
				return true;
			}
			if ($("input[name='save_target']:checked").val().indexOf("HDFS")>-1){
				if ($.trim($("input[name='target_dir']").val()) == ""){
					$("#fieldRequired").removeClass("hidden");
					$("input[name='target_dir']").addClass("fieldError");
					return false;
				}
			}
			else {
				if ($.trim($("input[name='target_table']").val()) == ""){
					$("#fieldRequired").removeClass("hidden");
					$("input[name='target_table']").addClass("fieldError");
					return false;
				}
			}
			return true;
		});
	});
</script>
${commonfooter()}
