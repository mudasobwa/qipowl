require_relative 'spec_helper'

describe String do
  before(:each) do
    @string = 'Hello, world!'
    @bowled = 'Ｈｅｌｌｏ， ｗｏｒｌｄ！'
  end

  describe "#bowl" do
    context 'string is bowled' do
      it 'contains no ruby symbols' do
        expect(@string.bowl).to eql @bowled 
      end
    end
      
    context 'bowled and unbowled string' do
      it "is the same string" do
        expect(@string.bowl.unbowl).to eql @string
      end
    end
  end
  
  describe "#carriage" do
    context 'uncarriaged and carriaged string' do
      it "is the same string" do
        expect(@string.uncarriage.carriage).to eql @string
      end
    end
  end
    
end

