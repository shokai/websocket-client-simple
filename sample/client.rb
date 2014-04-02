#!/usr/bin/env ruby
$:.unshift File.expand_path '../lib', File.dirname(__FILE__)
require 'rubygems'
require 'websocket-client-simple'

puts "websocket-client-simple v#{WebSocket::Client::Simple::VERSION}"

url = ARGV.shift || 'ws://localhost:8080'

ws = WebSocket::Client::Simple.connect url

ws.on :message do |msg|
  puts ">> #{msg.data}"
end

ws.on :open do
  puts "-- websocket open (#{ws.url})"
end

ws.on :close do |e|
  puts "-- websocket close (#{e.inspect})"
  exit 1
end

ws.on :error do |e|
  puts "-- error (#{e.inspect})"
end

loop do
  ws.send STDIN.gets.strip
end
