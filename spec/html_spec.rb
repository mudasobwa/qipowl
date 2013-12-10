# encoding: utf-8

require_relative 'spec_helper'

describe Qipowl::Html do
  before(:each) do
    @parser = Qipowl.tg_md__html
    @string = "Hello, world!"
  end

  describe "#parse_and_roll" do
    context 'when text is provided' do
      it 'is surrounded with para' do
        @result = @parser.parse_and_roll @string
        expect(@result).to eql "<p class='owl'>Hello, world!</p>"
      end
    end
  end
end
