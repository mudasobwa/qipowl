# encoding: utf-8

require_relative 'spec_helper'

describe Typogrowl::Html do
  before(:each) do
    @parser = Typogrowl.tg_md__html
    @string = File.read("#{File.dirname(__FILE__)}/input.tgm")
  end

  describe "#parse_and_roll" do
    context 'when text is provided' do
      it 'is modified in whitespace only' do
        @result = @parser.parse_and_roll @string
        expect(@result).to eql File.read("#{File.dirname(__FILE__)}/output.html")
      end
    end
  end
end
