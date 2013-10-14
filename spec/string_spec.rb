require_relative 'spec_helper'

describe String do
  before(:each) do
    @string = '\' " - ( ) { } \[ \] . , : ; ! ? ~ + * / % < > @ & | ^ = `'
    @entitified = '\' " - ( ) { } \[ \] . , : ; ! ? ~ + * / % &lt; &gt; @ &amp; | ^ = `'
  end

  describe "#bowl" do
    context 'bowled string' do
      it 'contains no ruby symbols' do
        expect(/[#{String::RUBY_SYMBOLS}]/ =~ @string.bowl).to eql nil 
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
  
  describe "#entitify" do
    context 'entitified string' do
      it "is contains no restricted symbols even if applied to bowled string" do
        expect(@string.bowl.entitify.unbowl).to eql @entitified
      end
    end
  end
  
  
end

