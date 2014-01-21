# encoding: utf-8

Given(/^input string is "(.*?)"$/) do |s|
  @input = s
end

When(/^I call upcase on it$/) do
  @result = @input.upcase
end
