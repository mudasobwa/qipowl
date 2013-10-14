# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Hash do
  before(:each) do
    @hash = {:'*'=>{'*'=>1, 'b'=>2},:w=>{:'*'=>:*, :b=>'b'}}
    bwld = String::BOWLED_SYMBOLS['*'].to_sym
    @res = {bwld=>{'*'=>1, 'b'=>2},:w=>{bwld=>:*, :b=>'b'}}
  end

  describe "#bowl" do
    context 'when bowled' do
      it 'replaces occurences recursively' do
        expect(@hash.bowl).to eql @res
      end
    end
    context 'when bowled and unbowled' do
      it 'remains the same string' do
        expect(@hash.bowl.unbowl).to eql @hash
      end
    end
  end
  describe "#bowl!" do
    context 'when bowled inplace' do
      it 'replaces occurences recursively within current instance' do
        @hash.bowl!
        expect(@hash).to eql @res
      end
    end
  end
end

