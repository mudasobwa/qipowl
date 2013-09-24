When(/^preliminary parsed string is processed with Typogrowl’s HTML composer$/) do
  @result = Typogrowl::ComposeHandler.new('html').compose @preliminary.out
end

Then(/^the result should be printed out$/) do
  puts @result
end
