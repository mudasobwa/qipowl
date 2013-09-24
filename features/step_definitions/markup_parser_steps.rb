# encoding: utf-8

Given(/^the input string is "(.*?)"$/) do |str|
  @content = str
end

Given(/^the input string is taken from file "(.*?)"$/) do |f|
  @content = File.read(f)
end

################################################################################

When(/^input string is processed with Typogrowl’s preliminary parser$/) do
  @preliminary = Typogrowl::Parser::Preliminary.new(@content)
  @result = @preliminary.out
end

################################################################################

Then(/^the result should equal to "(.*?)"$/) do |str|
  @result.should == str
end

Then(/^the result should equal to content of file "(.*?)"$/) do |f|
  @result.should == File.read(f)
end

################################################################################
# Not reusable

Then(/^no parenthesis are left in the input$/) do
  @preliminary.out.should_not =~ /\(|\)/
end
