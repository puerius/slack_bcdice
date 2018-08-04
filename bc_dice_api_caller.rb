# frozen_string_literal: true

require 'json'
require 'faraday'
require 'uri'

class BCDiceApiCaller
  ACCEPT_STATUS = [200, 400].freeze

  def initialize(url)
    @url = url + '/v1/'
  end

  def version
    fetch(:version)
  end

  def systems
    fetch(:systems)
  end

  def names
    fetch(:names)
  end

  def diceroll(system, command)
    fetch(:diceroll, system: system, command: command)
  end

  def systeminfo(system)
    fetch(:systeminfo, system: system)
  end

  def onset(sys, text)
    fetch(:onset, sys: sys, text: text)
  end

  private

  def fetch(method, query = nil)
    begin
      http_res = Faraday.get(request_url(method, query))
    rescue StandardError
      return create_server_error
    end
    if !ACCEPT_STATUS.include?(http_res.status)
      create_server_error
    elsif method == :onset
      handle_onset_response(http_res.body)
    else
      handle_json_response(http_res.body)
    end
  end

  def request_url(method, query)
    @url + method.to_s + (query ? '?' + URI.encode_www_form(query).gsub('%26gt%3B', '%3E') : '')
  end

  def handle_onset_response(res_body)
    if res_body.match?(/error/)
      create_error(:unknown, 'Error: Unknown command or system.')
    else
      { ok: true, result: res_body }.freeze
    end
  end

  def handle_json_response(res_body)
    response = JSON.parse(res_body, symbolize_names: true)
    response[:ok] = true if response[:ok].nil?
    response.freeze
  end

  def create_server_error
    create_error(:server, 'Error: API-Server error. Invalid URL or API-Server may be down.')
  end

  def create_error(type, reason)
    { ok: false, error: type, reason: "Error: #{reason}" }.freeze
  end
end
