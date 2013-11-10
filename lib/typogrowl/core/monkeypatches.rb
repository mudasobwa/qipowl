# encoding: utf-8

require_relative '../utils/hash_recursive_merge'

module Typogrowl
  class ::Array
    # Checks whether an array contains non-nil elements
    # @return +true+ if an array does not contain non-nils and +false+ otherwise
    def vacant?
      (self.flatten - [nil]).empty?
    end
  end

  # Bowling string means producing interpreter-safe text basing on ascii input.
  # 
  class ::String
    NBSP = "\u{00A0}"
    CARRIAGE_RETURN = '␍'
    NULL = '␀'
    ASCII_SYMBOLS, ASCII_DIGITS, ASCII_LETTERS_SMALL, ASCII_LETTERS_CAP = [
        [(0x21..0x2F), (0x3A..0x40), (0x5B..0x60), (0x7B..0x7E)],
        [(0x30..0x39)],
        [(0x61..0x7A)],
        [(0x41..0x5A)]
    ].map { |current| current.map(&:to_a).flatten.map { |i| [i].pack('U') } }
    ASCII_ALL = [ASCII_SYMBOLS, ASCII_DIGITS, ASCII_LETTERS_SMALL, ASCII_LETTERS_CAP]

    CODEPOINT_ORIGIN = 0xFF00 - 0x0020 # For FULLWIDTH characters

    UTF_SYMBOLS, UTF_DIGITS, UTF_LETTERS_SMALL, UTF_LETTERS_CAP = ASCII_ALL.map { |current|
      Hash[* current.join.each_codepoint.map { |char|
        [[char].pack("U"), [char + CODEPOINT_ORIGIN].pack("U")]
      }.flatten]
    }
    UTF_ALL = [UTF_SYMBOLS.values, UTF_DIGITS.values, UTF_LETTERS_SMALL.values, UTF_LETTERS_CAP.values]
    
    UTF_ASCII = UTF_SYMBOLS.merge(UTF_DIGITS).merge(UTF_LETTERS_SMALL).merge(UTF_LETTERS_CAP)
    ASCII_UTF = UTF_ASCII.invert
    
    def hsub! hash
      self if self.gsub!(hash.keys.join('|'), hash)
    end
    def hsub hash
      (out = self.dup).hsub! hash
      out
    end
    def bowl!
      self if self.gsub!(/[#{Regexp.quote(ASCII_ALL.join)}]/, UTF_ASCII)
    end
    def bowl
      (out = self.dup).bowl!
      out
    end
    def unbowl!
      self if self.gsub!(/[#{Regexp.quote(UTF_ALL.join)}]/, ASCII_UTF)
    end
    def unbowl
      (out = self.dup).unbowl!
      out
    end

    HTML_ENTITIES = Hash[[['<', 'lt'], ['>', 'gt'], ['&', 'amp']].map { |ent| [ent.first.bowl, "&#{ent.last};"] }]

    def carriage
      self.gsub(/\R/, " #{CARRIAGE_RETURN} ")
    end
    def carriage!
      self.gsub!(/\R/, " #{CARRIAGE_RETURN} ")
    end
    def uncarriage
      self.gsub(/\s*#{CARRIAGE_RETURN}\s*/, $/)
    end
    def uncarriage!
      self.gsub!(/\s*#{CARRIAGE_RETURN}\s*/, $/)
    end

    def un␚ify
      self.gsub(/␚(.*?)␚/, '')
    end
    
    def to_filename
      self.bowl.gsub(/\s/, "#{NBSP}")
    end
  end
  
  class ::Symbol
    def bowl
      self.to_s.bowl.to_sym
    end
    def unbowl
      self.to_s.unbowl.to_sym
    end
  end
  
  class ::Fixnum
    def ␚ify
      "␚#{self}␚"
    end
  end
end
