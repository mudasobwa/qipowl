# encoding: utf-8

module Typogrowl  
  module Helpers
    module_function :wellform
    module_function :inlines 
    module_function :split
    module_function :block
  end
end

Given(/^the input is taken from file "(.*?)"$/) do |file|
  @content = File.open(File.join(Dir.pwd, 'data', "#{file}")) { |f| f.read }
end

# ==============================================================================

When(/^we split the input$/) do
  @splitted = Typogrowl::Helpers.split @content
  @output = @splitted
end

When(/^we parse last item with “block” function$/) do
  @output = Typogrowl::Helpers.block @splitted.last
end

When(/^we parse "(\d+)" item with “block” function$/) do |num|
  @output = Typogrowl::Helpers.block @splitted[num.to_i - 1]
end

When(/^we process the input$/) do
  @output = Typogrowl::Helpers.process @content
end

# ==============================================================================

Then(/^the result is printed out$/) do
  p @output
end

Then(/^the result is array of size "(\d+)"$/) do |sz|
  @splitted.size.should == sz.to_i
end

Then(/^the first item equals to "(.*?)"$/) do |line|
  @splitted[0].should == line
end

Then(/^the result starts with "(.*?)"$/) do |output|
  @output.start_with?(output).should == true
end

Then(/^the result ends with "(.*?)"$/) do |output|
  @output.end_with?(output).should == true
end
