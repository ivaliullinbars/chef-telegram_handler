#
# Author:: Dell Cloud Manager OSS
# Copyright:: Dell, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Disable Slack handler in why-run mode
# See also: https://github.com/rackspace-cookbooks/chef-slack_handler/issues/48
# Inspired by https://github.com/DataDog/chef-datadog/pull/231/files
if Chef::Config[:why_run]
  Chef::Log.warn('Running in why-run mode, skipping telegram_handler')
  return
end

# if webhook attribute set, use webhook handler, otherwise use slackr gem handler
# if node['chef_client']['handler']['telegram']['chats'].empty?
#   Chef::Log.fatal('Chat ids array empty!')
# end

directory node['chef_handler']['handler_path']

cookbook_file "#{node['chef_handler']['handler_path']}/telegram_handler_util.rb" do
  source 'telegram_handler_util.rb'
  mode "0600"
  # action :nothing
  action :create
  # end
# end.run_action(:create)
end

cookbook_file "#{node['chef_handler']['handler_path']}/telegram_handler_webhook.rb" do
  source 'telegram_handler_webhook.rb'
  mode "0600"
  # action :nothing
  action :create
  # end
# end.run_action(:create)
end

chef_handler "Chef::Handler::Telegram" do
  source "#{node['chef_handler']['handler_path']}/telegram_handler_webhook.rb"
  arguments [
    node['chef_client']['handler']['telegram']
  ]
  supports start: true, report: true, exception: true
  # action :nothing
  action :enable
# end.run_action(:enable)
end

# Based on https://github.com/onddo/chef-handler-zookeeper
ruby_block 'trigger_start_handlers' do
  block do
    require 'chef/run_status'
    require 'chef/handler'
    Chef::Handler.run_start_handlers(self)
  end
  # action :nothing
  action :create
# end.run_action(:create)
end
