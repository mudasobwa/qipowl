# encoding: utf-8

# КТО ЧТО_ДЕЛАЕТ КОМУ   ЧТО
#  ☺       ⚙     ♿     ☕

# КАКОЙ   КАК   КАКОЙ  КАКОЙ
#  ☼      ☂     ☼      ☼

# ПОКА НЕ ОПРЕДЕЛЕНА ЧАСТЬ РЕЧИ (найти термин для)
#                 ∈

# МАРКЕРЫ ДЛЯ ПАДЕЖЕЙ, ВРЕМЕН, [ДЕЕ]ПРИЧАСТИЙ ИТД.
# например: глагол_наст.вр_деепричастие — «сетуя»

require 'typogrowth'

require_relative '../core/bowler'

module Qipowl
  module Mappers
    class IspruBowlerMapper < BowlerMapper

    end
  end

  module Bowlers
    class Ispru < Bowler

      attr_reader :dict

      LANG_FROM = 'es' # FIXME UGLY
      LANG_TO   = 'ru' # FIXME UGLY

##############################################################################
###              Default handlers for all the types of markup              ###
##############################################################################

      # `:regular` default handler
      # @param [Array] args the words, gained since last call to {#harvest}
      def ∀_regular *args
        ["#{__callee__}", [*args].flatten]
      end

      # Drum-roll!! The main handler for words
      def ∀_word method, *args, &block
        [(@dict[method.to_s.unbowl] || method).bowl, args]
      end

=begin
      def ． *args
      end
      def ， *args
      end
      def ； *args
      end
      def ！ *args
      end
      def ？ *args
      end
      def ！ *args
        [__callee__, args]
      end
      def ： *args
        [__callee__, args]
      end
=end
    protected
      def defreeze str
        @dict = {'Mamá' => 'Мама', 'lavados' => 'моет', 'marco' => 'раму'}
        (super str) # .typo(LANG_FROM)
      end

      # @see {Qipowl::Bowler#serveup}
      #
      # Additionally it beatifies the output HTML
      #
      # @param [String] str to be roasted
      def serveup str
        (super str).typo(lang: LANG_TO).strip
      end

    private
      # Hence we cannot simply declare the DSL for it, we need to handle
      # calls to all the _methods_, starting with those symbols.
      #
      # @param [Symbol] method as specified by caller (`method_missing`.)
      # @param [Array] args as specified by caller (`method_missing`.)
      # @param [Proc] block as specified by caller (`method_missing`.)
      #
      # @return [Array] the array of words
      def special_handler method, *args, &block
        ∀_word method, args, block
      end
    end
  end
end
