# encoding: utf-8

require_relative 'spec_helper'

describe Typogrowl::Bowler do
  before(:each) do
    @parser = Typogrowl::Bowler.new
    @string = File.read("#{File.dirname(__FILE__)}/input.tgm")
  end

  describe "#parse_and_roll" do
    context 'text is provided' do
      it 'is modified in whitespace only' do
        @result = @parser.parse_and_roll @string
        expect(@result.gsub(/[\n\s]/, '')).to eql @result.gsub(/[\n\s]/, '')
      end
    end
  end
end
