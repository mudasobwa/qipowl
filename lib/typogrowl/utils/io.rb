# encoding: utf-8

module Typogrowl
  module IO
    FILENAME_SYMBOLS = {
      '#'  => ['＃', '﹟', '♯'],
      '?'  => ['？', '﹖'],
      '&'  => ['＆', '﹠'],
      '@'  => ['＠', '﹫'],
      '\\' => ['＼'],
      '/'  => ['／'],
      ' '  => ["\u{00A0}"]
    }.inject({}) { |h,(k,v)| h[k]=v.first; h }
  end
end
