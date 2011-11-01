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
<%namespace name="wrappers" file="header_footer.mako" />
${wrappers.head('Upload Files', 'upload', show_new_directory=False)}

<div class="prompt_popup">
<form action="/filebrowser/upload?next=${next|u}" method="POST" enctype="multipart/form-data">
  <h4 class="jframe-hidden">Upload Files</h4>
  <div class="well">
    <input type="hidden" name="dest" value="/tmp" id="id_dest" />

    <h4 style="display: inline;">File to Upload</h4>
    <input class="input-file" style="display:inline; background-color: transparent;" type="file" name="hdfs_file" id="id_hdfs_file" />
    <input class="btn" type="submit" value="Submit" />
  </div>

</form>
</div>

<span class="alert-message block-message info">Go back to where you were: <a href="/filebrowser/view${next}">${next}</a>.</span>


${wrappers.foot()}
