# encoding: utf-8

Given(/^parser is "(.*?)"$/) do |clazz|
  @parser = eval("Typogrowl::#{clazz.capitalize}.new")
end

Given(/^the input string is "(.*?)"$/) do |str|
  @content = str
end

Given(/^the input string is taken from file "(.*?)"$/) do |f|
  @content = File.read(f)
end

Given(/^rules from "(.*?)" are merged in$/) do |f|
  @parser.merge_rules f
end

################################################################################

When(/^input string is processed with parser$/) do
  @result = @parser.parse_and_roll @content
end

When(/^input string is reversed with unparse_and_roll$/) do
  @result = @parser.unparse_and_roll @content
end

################################################################################

Then(/^the result should equal to "(.*?)"$/) do |result|
  expect(@result).to eq(result)
end

Then(/^the result should start with to "(.*?)"$/) do |result|
  expect(@result).to match(/^#{result}/)
end

Then(/^the result should be multiline and almost equal to "(.*?)"$/) do |result|
  expect(@result.gsub /\R/, '').to eq(result)
end

Then(/^the result should equal to content of file "(.*?)"$/) do |file|
  expect(@result).to eq(File.read(file))
end