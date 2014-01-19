# encoding: utf-8

require 'cgi'
require 'json'
require 'sinatra'

require_relative '../../lib/qipowl'

use Rack::Session::Pool, :expire_after => 2592000

before do
  session[:typo] ||= Qipowl::Ruler.new_bowler "html"
  session[:mapping] ||= session[:typo].class::ENTITIES.rmerge({:custom => session[:typo].class::CUSTOM_TAGS}).to_json
end

get '/html/mapping' do
  content_type :json
  session[:mapping]
end

delete '/html/mapping/:key' do |key|
  content_type :json
  session[:typo].remove_entity(key.to_sym).to_json
end

put '/html/mapping/:section/:key/:value/?:enclosure?' do |section, key, value, enclosure|
  content_type :json
  session[:typo].add_entity(section.to_sym, key.to_sym, value.to_sym, enclosure ? enclosure.to_sym : nil).to_json
end

get '/html/parse' do
  str = CGI::parse(request.query_string)['text'].first
  content_type :html
  session[:typo].execute str
end
