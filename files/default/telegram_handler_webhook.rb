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

require "chef"
require "chef/handler"
require 'net/http'
require "timeout"
require_relative 'telegram_handler_util'

class Chef::Handler::Telegram < Chef::Handler
  attr_reader :api_url, :api_domain, :api_token, :chats, :config, :timeout, :fail_only, :message_detail_level, :cookbook_detail_level

  def initialize(config = {})
    Chef::Log.debug('Initializing Chef::Handler::Telegram')
    @config = config
    @timeout = @config[:timeout]
    if @config[:api_url] and @config[:api_domain]
      @api_url = @config[:api_url]
      @api_domain = @config[:api_domain]
    else
      @api_url = 'https://api.telegram.org'
    end
    @api_token = @config[:api_token]
    @chats = @config[:chats]
    @fail_only = @config[:fail_only]
    @message_detail_level = @config[:message_detail_level]
    @cookbook_detail_level = @config[:cookbook_detail_level]
  end

  def setup_run_status(run_status)
    @run_status = run_status
    @util = TelegramHandlerUtil.new(@config, @run_status)
  end

  def report
    setup_run_status(run_status)

    @chats.each do |chat|
      Chef::Log.debug("Sending handler report to Telegram chat #{chat}")
      Timeout.timeout(@timeout) do
        sending_to_telegram = if @run_status.is_a?(Chef::RunStatus)
                             report_chef_run_end(chat)
                           else
                             report_chef_run_start(chat)
                           end
        Chef::Log.info("Sending report to Telegram chat #{chat[:id]}") if sending_to_telegram
      end
    end
  rescue Exception => e
    Chef::Log.warn("Failed to send message to Telegram: #{e.message}")
  end

  private

  def report_chef_run_start(chat)
    return false unless @util.send_on_start(chat)
    # telegram_message(" :gear: #{@util.start_message(chat)}", chat[:id])
    telegram_message(" \xE2\x9A\x99 #{@util.start_message(chat)}", chat[:id])
  end

  def report_chef_run_end(chat)
    if @run_status.success?
      return false if @util.fail_only(chat)
      # telegram_message(" :white_check_mark: #{@util.end_message(chat)}", chat[:id])
      telegram_message(" \xE2\x9C\x85 #{@util.end_message(chat)}", chat[:id])
    else
      telegram_message(" \xF0\x9F\x92\x80 #{@util.end_message(chat)}", chat[:id], run_status.exception)
    end
  end

  def telegram_message(message, chat_id, text_attachment = nil)
    Chef::Log.debug("Sending telegram message #{message} to chat #{chat_id} #{text_attachment ? 'with' : 'without'} a text attachment")
    # telegram api request uri
    uri = URI.parse("#{@api_url}/bot#{@api_token}/sendMessage")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    if defined? @api_domain
      req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json', 'Host' => "#{@api_domain}")
    else
      req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    end
    req.body = request_body(chat_id, message, text_attachment)
    Chef::Log.debug Chef::JSONCompat.to_json_pretty(req.body)
    res = http.request(req)
    # responses can be:
    # "Bad token"
    # "invalid_payload"
    # "ok"
    raise res.body unless JSON.parse(res.body)['ok']
  end

  def request_body(chat_id, message, text_attachment)
    body = {}
    body[:chat_id] = chat_id
    body[:text] = message
    # body[:parse_mode] = 'Markdown'
    # body[:attachments] = [{ text: text_attachment.to_s }] unless text_attachment.nil?
    body.to_json
  end
end
