# encoding: utf-8

require_relative 'monkeypatches'

module Typogrowl  
  module Helpers
    def pre_wellform input
      input.gsub(/(#{Map::TAGS_BLOCKQUOTES_RE}#{String::␢}*|^)—#{String::␢}*(.*?)(,|¹|†|‡)#{String::␢}*(\S+)(?:\Z|$)/) { |m|
        bq, master, delim, slave = $~.captures
        delim = '¹' if delim == ','
        slave.uri? ? "#{bq}↓#{master.gsub(/\s/, String::␣)}¹#{slave}↓" : 
                     "#{bq}↓#{master.gsub(/\s/, String::␣)}†#{slave}†↓"
      }
    end
    # FIXME Wellform will fail after two consequent execs on lines for anchor etc
    # FIXME this method after all the tests passed should be made private!!
    def wellform input
      input = pre_wellform input
      input
              .tg_void('⏎')
              .tg_void('——')
           .tg_styling('≡', 2)
           .tg_styling('≈', 2)
           .tg_styling('↓', 1)
           .tg_styling('λ', 1)
              .tg_link('✇', 'http://www.youtube.com/watch\?v=|http://youtu.be/')
              .tg_link('⚐', 'http', 'jpeg|jpg|gif|png')
              .tg_link('⚓')
              .tg_abbr('†')
            .tg_simple('☎')
            .tg_simple('✉')
              .tg_line('∙', :ul)
              .tg_line('▶', :dl, '—')
              .tg_line('▷', :dl_horizontal, '—')
             .tg_block('“')
    end

    def inlines input
      input = wellform input
      loop do
        input.gsub!(/(?<func>[#{Map::TAGS_STR}]+)#{String::␢}+〈(?<arg>[^〈〉]+)〉/m) {
          eval "DSL.#{$~[:func]} \"#{$~[:arg].gsub /"/, '\"'}\""
        } 
        break unless $~
      end
      input
    end

    def split input
      current = nil
      input.split(/\n/).inject([]) { |memo, c|
        c.strip!
        if !memo.last
          memo << (Map::block?(c) ? c : "#{Map::TAGS[:p].first} #{c}")
        elsif /\A\Z/ =~ c
          memo << ''
        elsif (Map::block?(c) && 
              !Map::same_tag?(memo.last.split(/#{String::␢‖␢}/).first, c.split(/#{String::␢‖␢}/).first))
          memo << c
        else
          c.gsub!(/\A[#{Map::TAGS_STR}]+#{String::␢}+/, '') if memo.last.start_with? c.split(/#{String::␢‖␢}/).first
          memo.last << (memo.last.empty? ? "#{Map::TAGS[:p].first} #{c}" : "\n#{c}")
        end
        memo
      }.delete_if &:empty?
    end

    def block input
      raise ArgumentError.new("Block should begin with one of #{Map::TAGS_RE}") \
        unless Map::block? input[0]

      unless /(?<func>\S+)#{String::␢}*(?<arg>.*)/m =~ input
        raise ArgumentError.new("Block should be well-formed: [\n#{input}\n]") \
      end
      func, arg = $~.captures
      arg = inlines arg
      
      raise ArgumentError.new("Block should not contain controls (#{Map::TAGS_RE}) inside [\n#{arg}\n]") \
        if Map::inline? arg

      inlines("#{func}" + (arg.empty? ? '' : " 〈#{arg}〉")).gsub /\n/, ' '
    end
    
    def process input
      split(input).map { |l|
        block l
      }
    end
    module_function :process
  end
  
  # Monkeypatches
  class ::String
    def tg_inlines
      Helpers.inlines self
    end

    def tg_split
      Helpers.split self
    end
  end
end