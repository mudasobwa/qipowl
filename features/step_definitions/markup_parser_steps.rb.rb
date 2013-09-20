# encoding: utf-8

Given(/^the input string is "(.*?)"$/) do |str|
  @content = str
end

When(/^input string is processed with Typogrowl’s preliminary parser$/) do
  @preliminary = Typogrowl::Parser::Preliminary.new @content
end

Then(/^the result should equal to "(.*?)"$/) do |str|
  @preliminary.out.should == str
end
