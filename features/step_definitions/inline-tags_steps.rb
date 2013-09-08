# encoding: utf-8

Given(/^bullet is one of given$/) do
  # no init 
end

When(/^bullets are "(.*?)"$/) do |b|
  @bullets = b.split ''
end

Then(/^tags produced by tag function are (.*)$/) do |res|
  @bullets.map { |b|
    Typogrowl::Map.tag(b)
  }.should == eval(res)
end

Given(/^the input string is "(.*?)"$/) do |input|
  @input = input
end

When(/^we normalize the string$/) do
  @output = Typogrowl::Helpers.wellform @input
end

When(/^we process the string$/) do
  @output = Typogrowl::Helpers.inlines @input
end

Then(/^the result is "(.*?)"$/) do |output|
  @output.should == output
end
