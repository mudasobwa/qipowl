# encoding: utf-8

module Typogrowl
  class ::Array
    # Checks whether an array contains non-nil elements
    # @return +true+ if an array does not contain non-nils and +false+ otherwise
    def vacant?
      (self.flatten - [nil]).empty?
    end
  end
  class ::Hash
    %w{bowl unbowl}.each { |m|
      Hash.class_eval %Q{
        def #{m}
          Hash[self.map { |k, v|
            [ 
              Symbol === k ? k.to_s.#{m}.to_sym : k, 
              Hash === v ? v.#{m} : v 
            ]
          }]
        end
        def #{m}!
          self.replace self.#{m}
        end
      }
    }
  end
  class ::String
    NBSP = "\u{00A0}"
    CARRIAGE_RETURN = '␍'
    NULL = '␀'
    RUBY_SYMBOLS = '\'"\-(){}\[\].,:;!?~+*/%<>@&|^=`'
    CODEPOINT_ORIGIN = 0x1000
    BOWLED_SYMBOLS = Hash[* RUBY_SYMBOLS.split(//).map { |s|
      [s, [(RUBY_SYMBOLS.index(s) + CODEPOINT_ORIGIN)].pack("U")]
    }.flatten]
    UNBOWLED_SYMBOLS = BOWLED_SYMBOLS.invert
    BOWL_SYMBOLS = BOWLED_SYMBOLS.values.join
    RUBY_KEYWORDS = %w{__FILE__ __LINE__ alias and begin BEGIN break case 
      class def defined? do else elsif end END ensure false for if in module 
      next nil not or redo rescue retry return self super then true undef 
      unless until when while yield}.map &:to_sym
    DIGITS_ORIGIN = 0x0D66
    DIGITS_WITH_POINT = (0..8).inject({}) { |m, i|
      m[i] = [i + DIGITS_ORIGIN].pack("U")
      m
    }
      
    def bowl!
      r = []
      r << self.gsub!(/[#{RUBY_SYMBOLS}]/, BOWLED_SYMBOLS)
      r << self.gsub!(/(\s)(\d)/, "\\1#{NULL}\\2")
      (
        RUBY_KEYWORDS + Kernel.public_methods +
        Bowler.public_instance_methods
      ).uniq.each { |m|
        # FIXME Do something with methods ending with “?”
        r << self.gsub!(/(?<=\p{^L})#{m.to_s.gsub '?', '\?'}(?=\p{^L})/, "#{NULL}#{m}")
      }
      r.vacant? ? nil : self
    end
    def bowl
      (out = self.dup).bowl!
      out
    end
    def unbowl!
      r = []
      r << self.gsub!(/[#{BOWL_SYMBOLS}]/, UNBOWLED_SYMBOLS)
      r << self.gsub!(/#{NULL}/, '')
      r.vacant? ? nil : self
    end
    def unbowl
      (out = self.dup).unbowl!
      out
    end
    def uncarriage empty=true
      self.gsub /\R/, empty ? ' ' : "#{CARRIAGE_RETURN}"
    end
    def uncarriage! empty=true
      self.gsub! /\R/, empty ? ' ' : "#{CARRIAGE_RETURN}"
    end
    def carriage
      self.gsub /#{CARRIAGE_RETURN}/, "\n"
    end
    def carriage!
      self.gsub! /#{CARRIAGE_RETURN}/, "\n"
    end
    def entitify!
      self.gsub! /[<>&#{BOWLED_SYMBOLS['&']}#{BOWLED_SYMBOLS['>']}#{BOWLED_SYMBOLS['<']}]/, 
                          '&'=>'&amp;', '<'=>'&lt;', '>'=>'&gt;',
                          "#{BOWLED_SYMBOLS['&']}"=>"#{BOWLED_SYMBOLS['&']}amp;", 
                          "#{BOWLED_SYMBOLS['<']}"=>"#{BOWLED_SYMBOLS['&']}lt;", 
                          "#{BOWLED_SYMBOLS['>']}"=>"#{BOWLED_SYMBOLS['&']}gt;"
    end
    def entitify
      (out = self.dup).entitify!
      out
    end
    def self.bracketify i
      raise Exception.new "Bracketifying is working for integers in range #{(0..8)} only." \
        unless Fixnum === i && i >= 0 && i <= 8 
      "❲#{DIGITS_WITH_POINT[i]}❳"
    end
  end
  
  class ::Fixnum
    def bracketify
      String.bracketify self
    end
  end
end
