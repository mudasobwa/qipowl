# encoding: utf-8

require_relative '../core/bowler'

module Qipowl
  
  # Markup processor for Html output.
  # 
  # This class produces HTML from markup as Markdown does.
  class Cmd < Bowler
    def initialize file = nil
      super
      merge_rules file if file
    end
    
    def список_файлов *args
      puts `#{@mapping.linewide(__callee__)} #{args.join(SEPARATOR).unbowl}`
    end
    
    def self.execute str
      Cmd.new.parse_and_roll str
    end
    
  end

end
