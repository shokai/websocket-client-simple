#!/usr/bin/env ruby
require 'eventmachine'
require 'websocket-eventmachine-server'

PORT = (ARGV.shift || 8080).to_i

EM::run do
  @channel = EM::Channel.new

  puts "start websocket server - port:#{PORT}"

  WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => PORT) do |ws|
    ws.onopen do
      sid = @channel.subscribe do |mes|
        ws.send mes
      end
      puts "<#{sid}> connect"

      @channel.push "hello new client <#{sid}>"

      ws.onmessage do |msg|
        puts "<#{sid}> #{msg}"
        @channel.push "<#{sid}> #{msg}"
      end

      ws.onclose do
        puts "<#{sid}> disconnected"
        @channel.unsubscribe sid
        @channel.push "<#{sid}> disconnected"
      end
    end
  end

end
