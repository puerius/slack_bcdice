# frozen_string_literal: true

require './bc_dice_api_caller'
require './settings'

class Commander
  def initialize(bcdice_url)
    @bcdice_api = BCDiceApiCaller.new(bcdice_url)
    @systems = @bcdice_api.systems
    @names = @bcdice_api.names
  end

  def version
    handle_response(@bcdice_api.version){|res| "API:#{res[:api]}\nBCDice#{res[:bcdice]}" }
  end

  def systems(mode = :post)
    handle_response(@systems) do |res|
      case mode
      when :post
        res[:systems].join("\n")
      when :regex
        res[:systems].join('|')
      else
        res[:systems].join(',')
      end
    end
  end

  def names
    handle_response(@names) do |res|
      res[:names]
        .map{|h| "#{h[:system]} => #{h[:name]}" }
        .join("\n")
    end
  end

  def systeminfo(system)
    handle_response(@bcdice_api.systeminfo(system)) do |res|
      systeminfo = res[:systeminfo]
      <<~INFO
        name: #{systeminfo[:name]}
        gameType: #{systeminfo[:gameType]}
        info:
        #{systeminfo[:info]}
      INFO
    end
  end

  def onset(sys, text)
    handle_response(@bcdice_api.onset(sys, text)){|res| res[:result]}
  end

  def diceroll(system, command)
    handle_response(@bcdice_api.diceroll(system, command)){|res| "#{system}#{res[:result]}"}
  end

  def handle_response(res)
    if res[:ok]
      yield res
    else
      res[:reason]
    end
  end

end
