# encoding: utf-8

require_relative 'monkeypatches'
require_relative '../utils/logging'

# @author Alexei Matyushkin
module Qipowl::Bowlers

  # Base class for all the parsers.
  #
  # Technically it may be instantiated, but that’s meaningless.
  # Main operation method for it and all the descendants is
  # {#parse}. It sequentially executes following
  # private methods:
  #
  # - {#defreeze}
  # - {#roast}
  # - {#serveup}
  #
  # Normally the developer does not need to interfere the {#roast}
  # method which proceeds the input string. To prepare the input
  # for +evaluation+ one overwrites {#defreeze}, for some afterwork
  # the {#serveup} method is here.
  #
  # Descendants are supposed to overwrite {#method_missing} for some
  # custom processing and introduce DSL methods, which will be executed
  # by `eval` inside the {#roast} method.
  #
  # Instance variables `:in` and `:out` are here to gain an access to
  # the last interpreted input string and the result of evaluation
  # respectively.
  #
  class Bowler
    include TypoLogging
    
    # Internal constant for joining/splitting the strings during processing.
    # Override on your own risk. I can′t imagine why you would need to do so.
    SEPARATOR = $, || ' '

    %w(block alone magnet grip regular).each { |section|
      define_method "∀_#{section}".to_sym, ->(*args) {
        raise "Default method for #{section} MUST be defined (name: “∀_#{section}”)"
      }
    }

    # Prepares blocks in the input for the execution
    def block! str
      self.class::BLOCK_TAGS.each { |tag, value|
        str.gsub!(/(#{tag})(.*?)$(.*?)(#{tag}|\Z)/m) {
          "\n\n#{$1}('#{$2}', '#{$3}')\n\n"
        }
      }
      str
    end

    # Prepares customs in the input for the execution
    def custom! str
      self.class::CUSTOM_TAGS.each { |tag, value|
        str.gsub!(/#{tag}/, value)
      }
      str
    end

    # Prepares grips in the input for the execution
    def grip! str
      self.class::GRIP_TAGS.each { |tag, value|
        str.gsub!(/(#{tag})(.*?)(?:#{tag}|\Z)/m) {
          tag, args = [$1, $2]
          "#{tag} #{args.split(' ').count.to_s.bowl} #{args}"
        }
      }
      str
    end

    def defreeze! str
      str.bowl!
      block! str
      custom! str
      grip! str
    end
    
  end
end
