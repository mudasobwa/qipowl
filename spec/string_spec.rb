require_relative 'spec_helper'

describe String do
  before(:each) do
    @string = '\' " - ( ) { } \[ \] . , : ; ! ? ~ + * / % < > @ & | ^ = `'
    @entitified = '\' " - ( ) { } \[ \] . , : ; ! ? ~ + * / % &lt; &gt; @ &amp; | ^ = `'
  end

  describe "#bowl" do
    context 'bowled string' do
      it 'contains no ruby symbols' do
        expect(/[#{Regexp.quote String::ASCII_ALL.join}]/ =~ @string.bowl).to eql nil 
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

