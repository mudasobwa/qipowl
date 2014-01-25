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

  # A wrapper for the configuration block
  def configure &block
    instance_eval(&block)
  end

  def [](key)
    config[key.to_sym]
  end

private

  def set(key, value)
    config[key.to_sym] = value
  end

  def add(key, value)
    config[key.to_sym] = [*config[key.to_sym]] << value
  end

  def config
    @config ||= Hash.new
  end

  def method_missing(sym, *args)
    if sym.to_s =~ /(.+)=$/
      config[$1.to_sym] = args.first
    else
      config[sym.to_sym]
    end
  end
end

Qipowl::configure do
  set :bowlers, File.expand_path(File.join(__dir__, '..', 'config', 'bowlers'))
end

class Qipowl::Html
  attr_reader :bowler
  def self.parse s
    (@bowler ||= Qipowl::Ruler.new_bowler "html").execute s
  end
end
