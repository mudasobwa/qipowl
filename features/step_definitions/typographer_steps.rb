When(/^input string is processed with Typogrowl’s typography parser$/) do
  @content.gsub! /\\+"/, '"'
  @typo = Typograph::Parser.parse @content
end

When(/^input string is processed with Typogrowl’s typography parser with lang "(.*?)"$/) do |lang|
  @content.gsub! /\\+"/, '"'
  @typo = Typograph::Parser.parse @content, lang
end

Then(/^neither single nor double quotes are left in the string$/) do
  @typo.scan(/"|'/).count.should == 0
end

Then(/^the typoed result should equal to "(.*?)"$/) do |str|
  @typo.should == str
end
