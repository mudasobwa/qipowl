Then(/^the result should equal to "(.*?)"$/) do |result|
  expect(@result.carriage).to eq(result)
end

Then(/^the result should equal to$/) do |result|
  expect(@result).to eq(result)
end

Then(/^the result should match "(.*?)"$/) do |result|
  expect(@result).to match(result)
end
