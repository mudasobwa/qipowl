# encoding: utf-8

require 'logger'

module TypoLogging
  def logger
    TypoLogging.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
