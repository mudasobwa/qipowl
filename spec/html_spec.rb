# encoding: utf-8

require_relative 'spec_helper'

describe Typogrowl::Html do
  before(:each) do
    @parser = Typogrowl::Html.new
    @string = File.read("#{File.dirname(__FILE__)}/input.tgm")
  end

  describe "#parse_and_roll" do
    context 'when italic markup applied' do
      it 'em tags came in output' do
        expect(@parser.parse_and_roll('here ≈italic≈ goes')).to eql 'here <em>italic</em> goes'
      end
    end
    
    context 'when text is provided' do
      it 'is modified in whitespace only' do
        @result = @parser.parse_and_roll @string
        expect(@result.gsub(/[\n\s]/, '')).to eql @string.gsub(/[\n\s]/, '')
      end
    end
  end
end
