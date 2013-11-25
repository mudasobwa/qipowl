# encoding: utf-8

require_relative 'spec_helper'

describe Qipowl::Bowler do
  before(:each) do
    @parser = Qipowl::Bowler.new
    @string = File.read("#{File.dirname(__FILE__)}/input.tgm")
  end

  describe "#parse_and_roll" do
    context 'text is provided' do
      it 'is modified in whitespace only' do
        @result = @parser.parse_and_roll @string
        expect(@result.gsub(/[\n\s]/, '')).to eql @string.gsub(/[\n\s]/, '')
      end
    end
  end
end
