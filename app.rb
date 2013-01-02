require 'sinatra'
set :environment, :development
set :views, settings.root
require "sinatra/reloader" if development?

get '/' do
  haml :index
end

get '/css/*.css' do
  content_type 'text/css', :charset => 'utf-8'
  filename = params[:splat].first
  scss filename.to_sym, :views => "#{settings.root}/public/css"
end

get '/js/*.js' do
  content_type 'text/javascript', :charset => 'utf-8'
  filename = params[:splat].first
  coffee filename.to_sym, :views => "#{settings.root}/public/js"
end
