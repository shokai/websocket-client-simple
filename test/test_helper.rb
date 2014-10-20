require 'rubygems'
require 'bundler'
require 'minitest/autorun'
require 'websocket-client-simple'
require 'eventmachine'
require 'websocket-eventmachine-server'

$:.unshift File.expand_path '../lib', File.dirname(__FILE__)
