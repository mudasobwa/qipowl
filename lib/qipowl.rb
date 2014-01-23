# encoding: utf-8

require_relative "qipowl/version"
require_relative "qipowl/constants"

require_relative "qipowl/core/mapper"
require_relative "qipowl/core/ruler"
require_relative "qipowl/core/bowler"

require_relative "qipowl/bowlers/html"
require_relative "qipowl/bowlers/i_sp_ru"
#require_relative "qipowl/bowlers/cmd"
#require_relative "qipowl/bowlers/yaml"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

module Qipowl
  extend self

  # Basic single-method DSL with .parameter method
  # being used to define a set of available settings.
  # This method takes one or more symbols, with each one being
  # a name of the configuration option.
  def params *names
    names.each do |name|
      attr_accessor name
      define_method name do |*values|
        value = values.first
        value ? self.send("#{name}=", value) : instance_variable_get("@#{name}")
      end
    end
  end

  # A wrapper for the configuration block
  def config &block
    instance_eval(&block)
  end

end

Qipowl::config do
  params :bowlers_dir
  bowlers_dir File.expand_path(File.join(__dir__, '..', 'config', 'bowlers'))
end

class Qipowl::Html
  attr_reader :bowler
  def self.parse s
    (@bowler ||= Qipowl::Ruler.new_bowler "html").execute s
  end
end