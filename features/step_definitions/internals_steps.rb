# encoding: utf-8

Given(/^the input strings are "(.*?)" and "(.*?)"$/) do |tg1, tg2|
  @tg1 = tg1
  @tg2 = tg2
end

When(/^we check it against Map::inline\?$/) do
  @result = Typogrowl::Map::inline? @input
end

When(/^we call tg_styling method on it$/) do
  @result = @input.tg_styling '≡', 2
end

When(/^we check it against Map::same_tag\?$/) do
  @result = Typogrowl::Map::same_tag? @tg1, @tg2
end

Then(/^the result is expected: "(.*?)"$/) do |res|
  @result.to_s.should == res
end