# encoding: utf-8

require 'cgi'
require 'json'
require 'sinatra'

require_relative '../qipowl'

use Rack::Session::Pool, :expire_after => 2592000

before do
  session[:typo] ||= Qipowl.tg_md__html
end

get '/html/mapping' do
  content_type :json
  session[:typo].mapping.hash.to_json
end

delete '/html/mapping/:key' do |key|
  content_type :json
  session[:typo].mapping.remove_spice(key.to_sym).to_json
end

put '/html/mapping/:section/:key/:value/?:enclosure?' do |section, key, value, enclosure|
  content_type :json
  session[:typo].mapping.add_spice(section.to_sym, key.to_sym, value.to_sym, enclosure ? enclosure.to_sym : nil).to_json
end

get '/html/parse' do
  str = CGI::parse(request.query_string)['text'].first
  content_type :html
  session[:typo].parse_and_roll str
end
