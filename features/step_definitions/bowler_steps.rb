Given(/^the input file is "(.*?)"$/) do |f|
  @f = f
end

When(/^bowler is created$/) do
  @bowler = Qipowl::Ruler.new_bowler 'html'
end

Then(/^bowler has all the method aliases$/) do
  puts @bowler.class.instance_methods(false)
  puts '='*60
  @bowler.class.constants(false).each { |c|
    puts "Constant: #{c}"
    puts @bowler.class.const_get(c)
    puts '-'*60
  }
end
