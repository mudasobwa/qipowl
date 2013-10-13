# encoding: utf-8

Given(/^the input string is "(.*?)"$/) do |str|
  @content = str
end

Given(/^the input string is taken from file "(.*?)"$/) do |f|
  @content = File.read(f)
end

################################################################################

When(/^input string is processed with Typogrowl::Html parser$/) do
  @result = Typogrowl::Html.new.parse_and_roll @content
end

################################################################################

Then(/^the result should equal to "(.*?)"$/) do |result|
  expect(@result).to eq(result)
end

Then(/^the result should be multiline and almost equal to "(.*?)"$/) do |result|
  expect(@result.gsub /\R/, '').to eq(result)
end

Then(/^the result should equal to content of file "(.*?)"$/) do |file|
  expect(@result).to eq(File.read(file))
end