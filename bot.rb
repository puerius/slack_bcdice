# frozen_string_literal: true

require 'slack-ruby-bot'
require 'rubygems'
require 'net/http'
require './settings'
require './commander'

ENV['SLACK_API_TOKEN'] = SLACK_API_TOKEN

# コマンドを読み取ってSlackに投稿するクラス
class BCDiceBot < SlackRubyBot::Bot
  def self.error?(message)
    message.start_with?('Error')
  end

  def self.resolve_shorthand(key)
    SHORTHANDS[key.upcase] || key
  end

  def self.post_file(title, content, channel, client)
    if error?(content)
      client.say(channel: channel, text: result)
    else
      @slack_file_api.post do |req|
        req.body = {
          title: title,
          filetype: 'text',
          channels: channel,
          content: content,
          token: SLACK_API_TOKEN
        }
      end
    end
  end

  def self.regex_of_systems
    shorthands_regex = SHORTHANDS.keys.join('|')
    systems_regex = @commander.systems(:regex)
    if error?(systems_regex)
      ''
    elsif shorthands_regex.empty?
      systems_regex
    else
      "#{systems_regex}|#{shorthands_regex}"
    end
  end

  # 初期化処理
  @commander = Commander.new(BCDICE_API_URL)
  @slack_file_api = Faraday.new(url: SLACK_FILE_API_URL) do |faraday|
    faraday.request :url_encoded
    faraday.adapter :net_http
  end
  @systems_regex = regex_of_systems

  match /\Ahelp\slist/i do |client, data, _|
    post_file('System List',
              @commander.names,
              data.channel,
              client)
  end

  match /\Ahelp\s(?<system>#{@systems_regex})/i do |client, data, match|
    system = resolve_shorthand(match[:system])
    post_file("Usage #{system}",
              @commander.systeminfo(system),
              data.channel,
              client)
  end

  match /help\sshorthands/i do |client, data, _|
    post_file("Shorthand List",
              SHORTHANDS.map{|k, v| "#{k}: #{v}"}.join("\n"),
              data.channel,
              client)
  end

  match /(?<system>#{@systems_regex})\s(?<command>.+)/i do |client, data, match|
    system = resolve_shorthand(match[:system])
    client.say(channel: data.channel, text: @commander.diceroll(system, match[:command]))
  end

end

SlackRubyBot::Client.logger.level = Logger::WARN

BCDiceBot.run
