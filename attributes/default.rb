#
# Copyright ???
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Attributes for Slack intergration Using slackr gem. Requires API key
## required attributes
default['chef_client']['handler']['telegram']['api_url'] = 'https://api.telegram.org'
default['chef_client']['handler']['telegram']['api_domain'] = 'api.telegram.org'
default['chef_client']['handler']['telegram']['api_token'] = nil
default['chef_client']['handler']['telegram']['chats'] = []
# shared attributes
default['chef_client']['handler']['telegram']['timeout']    = 15
# Valid options here are basic, elapsed, resources
default['chef_client']['handler']['telegram']['message_detail_level'] = 'basic'
# Valid options here are off, all
default['chef_client']['handler']['telegram']['cookbook_detail_level'] = 'off'
# Only report failures
default['chef_client']['handler']['telegram']['fail_only'] = false
# Whether to send a message to when the Chef run starts
default['chef_client']['handler']['telegram']['send_start_message'] = false
# Whether to send a message the node.chef_environment as well as the node.name
default['chef_client']['handler']['telegram']['send_environment'] = false
#
default['chef_handler']['handler_path'] = "#{File.expand_path(File.join(Chef::Config[:file_cache_path], '..'))}/handlers"
