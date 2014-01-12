Then(/^the result should equal to "(.*?)"$/) do |result|
  expect(@result).to eq(result)
end

Then(/^the result should equal to$/) do |result|
  expect(@result).to eq(result)
end
