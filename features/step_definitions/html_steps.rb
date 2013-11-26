# encoding: utf-8

Given(/^parser is "(.*?)"$/) do |clazz|
  @parser = eval("Qipowl::#{clazz.capitalize}.new")
end

Given(/^the input string is "(.*?)"$/) do |str|
  @content = str
end

Given(/^the input string is taken from file "(.*?)"$/) do |f|
  @content = File.read(f)
end

Given(/^rule "(.*?)" is added to mapping as "(.*?)" in "(.*?)" section with "(.*?)" enclosure$/) do |key, value, section, enclosure|
  @parser.mapping.add_spice section.to_sym, key.to_sym, value.to_sym, enclosure.to_sym
end

Given(/^rule "(.*?)" is removed from mapping$/) do |key|
  @parser.mapping.remove_spice key.to_sym
end

Given(/^rules from "(.*?)" are merged in$/) do |f|
  @parser.merge_rules f
end

Given(/^parser class is "(.*?)"$/) do |name|
  @parser_class = name
end

################################################################################

When(/^input string is processed with parser$/) do
  @result = @parser.parse_and_roll @content
end

When(/^input string is reversed with unparse_and_roll$/) do
  @result = @parser.unparse_and_roll @content
end

When(/^the result is printed out to file "(.*?)"$/) do |file|
  File.write(file, @result)
end

When(/^input string is processed with parser’s class function$/) do
  @result = eval("Qipowl::#{@parser_class.capitalize}.parse '#{@content}'")
end

################################################################################

Then(/^the result should be printed to stdout as is$/) do
  puts '='*40
  puts @result
  puts '='*40
end

Then(/^the result should equal to "(.*?)"$/) do |result|
  expect(@result.gsub(/\s*/, '')).to eq(result.gsub(/\s*/, ''))
end

Then(/^the result should equal to$/) do |result|
  expect(@result.gsub(/\s*/, '')).to eq(result.gsub(/\s*/, ''))
end

Then(/^the result should start with to "(.*?)"$/) do |result|
  expect(@result.gsub(/\s*/, '')).to match(/^#{result.gsub(/\s*/, '')}/)
end

Then(/^the result should be multiline and almost equal to "(.*?)"$/) do |result|
  expect(@result.gsub(/\s*/, '')).to eq(result.gsub(/\s*/, ''))
end

Then(/^the result should equal to content of file "(.*?)"$/) do |file|
  expect(@result).to eq(File.read(file))
end