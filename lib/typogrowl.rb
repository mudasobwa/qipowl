# encoding: utf-8

require_relative "typogrowl/version"

#require "typogrowl/utils/io"
require_relative "typogrowl/core/bowler"
require_relative "typogrowl/bowlers/html"

module Typogrowl
  def self.tg__html
    Html.new
  end
  
  def self.tg_md__html
    result = tg__html
    result.merge_rules "#{File.dirname(__FILE__)}/tagmaps/markdown2html.yaml"
    result
  end
end
