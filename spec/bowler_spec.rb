# encoding: utf-8

require_relative 'spec_helper'

describe Qipowl::Bowler do
  before(:each) do
    @parser = Qipowl::Bowler.new
    @string = "Hello, world!"
  end

  describe "#parse_and_roll" do
    context 'text is provided' do
      it 'returns as is' do
        @result = @parser.parse_and_roll @string
        expect(@result).to eql @string
      end
    end
  end
end
