# encoding: utf-8

require 'cgi'
require 'json'
require 'sinatra'

require_relative '../typogrowl'

use Rack::Session::Pool, :expire_after => 2592000

before do
  session[:typo] ||= Typogrowl.tg_md__html
end

get '/bowler/mapping' do
  content_type :json
  session[:typo].mapping.to_json
end

get '/bowler/:type' do |type|
  raise Exception.new "Type #{type} is not supported. Aborting." \
    unless type == 'html'
  str = CGI::parse(request.query_string)['text'].first
  content_type :html
  session[:typo].parse_and_roll str
end
