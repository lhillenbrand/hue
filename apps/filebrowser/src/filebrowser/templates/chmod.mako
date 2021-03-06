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
<%namespace name="edit" file="editor_components.mako" />
<style>
.table-margin {
	padding-left:20px;
	padding-right:20px;
}
</style>

<form action="/filebrowser/chmod?next=${next|u}" method="POST" enctype="multipart/form-data"
      class="form-inline form-padding-fix">
    <div class="modal-header">
        <a href="#" class="close" data-dismiss="modal">&times;</a>
        <h3>Change Permissions: ${path}</h3>
    </div>
    <div class="table-margin">
        ${edit.render_field(form["path"], hidden=True)}
        <table class="table table-striped">
            <thead>
            <tr>
                <th>&nbsp;</th>
                <th class="center">User</th>
                <th class="center">Group</th>
                <th class="center">Other</th>
				<th width="120">&nbsp</th>
            </tr>
            </thead>
            <tbody>
            <tr>
                <td><strong>Read</strong></td>
                <td class="center">${edit.render_field(form["user_read"], tag="checkbox", button_text=" ", nolabel=True)}</td>
                <td class="center">${edit.render_field(form["group_read"], tag="checkbox", button_text=" ", nolabel=True)}</td>
                <td class="center">${edit.render_field(form["other_read"], tag="checkbox", button_text=" ", nolabel=True)}</td>
				<td>&nbsp;</td>
            </tr>
            <tr>
                <td><strong>Write</strong></td>
                <td class="center">${edit.render_field(form["user_write"], tag="checkbox", button_text=" ", nolabel=True)}</td>
                <td class="center">${edit.render_field(form["group_write"], tag="checkbox", button_text=" ", nolabel=True)}</td>
                <td class="center">${edit.render_field(form["other_write"], tag="checkbox", button_text=" ", nolabel=True)}</td>
				<td>&nbsp;</td>
            </tr>
            <tr>
                <td><strong>Execute</strong></td>
                <td class="center">${edit.render_field(form["user_execute"], tag="checkbox", button_text=" ", nolabel=True)}</td>
                <td class="center">${edit.render_field(form["group_execute"], tag="checkbox", button_text=" ", nolabel=True)}</td>
                <td class="center">${edit.render_field(form["other_execute"], tag="checkbox", button_text=" ", nolabel=True)}</td>
				<td>&nbsp;</td>
            </tr>
            </tbody>
        </table>
    </div>
    <div class="modal-footer" style="padding-top: 10px;">
        <input class="btn primary" type="submit" value="Submit"/>
        <a class="btn" onclick="$('#changePermissionModal').modal('hide');">Cancel</a>
    </div>
</form>
