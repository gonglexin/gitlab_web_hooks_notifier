require 'sinatra'
require 'sinatra/reloader' if development?
require 'terminal-notifier'
require_relative 'helpers'

post '/' do
  event = JSON.parse env['rack.input'].gets
  handle_event(event)
end
