# encoding: utf-8

require_relative "qipowl/version"
require_relative "qipowl/bowlers/html"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

module Qipowl
  def self.tg__html
    Html.new
  end
  
  def self.tg_md__html
    result = tg__html
    result.merge_rules "#{File.dirname(__FILE__)}/tagmaps/markdown2html.yaml"
    result
  end
end
