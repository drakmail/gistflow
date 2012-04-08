require 'spec_helper'

PUNCTUATION = ['.', ',', ':', ';', '?', '!', '(', ')']

describe Replaceable do
  describe '#replace_gists' do
    let(:replaceable) { Replaceable.new('gist:1, gist:2') }
    before { replaceable.replace_gists! }
    subject { replaceable.to_s }
    
    it 'should replace gists to links' do
      should == '[gist:1](https://gist.github.com/1), [gist:2](https://gist.github.com/2)'
    end
    
    PUNCTUATION.each do |char|
      context "end with #{char}" do
        let(:replaceable) { Replaceable.new("gist:1#{char}") }
        it { should == "[gist:1](https://gist.github.com/1)#{char}" }
      end
    end
  end
  
  describe '#replace_tags!' do
    let(:replaceable) { Replaceable.new('#tag1, #tag2') }
    before { replaceable.replace_tags! }
    subject { replaceable.to_s }
    
    it 'should replace tags to links' do
      should == '[#tag1](/tags/tag1), [#tag2](/tags/tag2)'
    end
    
    PUNCTUATION.each do |char|
      context "end with #{char}" do
        let(:replaceable) { Replaceable.new("#tag#{char}") }
        it { should == "[#tag](/tags/tag)#{char}" }
      end
    end
  end
  
  describe '#replace_usernames' do
    before { replaceable.replace_usernames! }
    subject { replaceable.to_s }
    
    context 'unexisted user' do
      let(:replaceable) { Replaceable.new(' @username ') }
      
      it 'should not replace it' do
        should == ' @username '
      end
    end
    
    context 'existed user' do
      before do
        FactoryGirl.create(:user, :username => 'username')
        replaceable.replace_usernames!
      end
      
      context 'wrapped @usename' do
        let(:replaceable) { Replaceable.new(' @username ') }
        it { should == ' [@username](/users/username) ' }
      end
      
      context 'two usernames' do
        let(:replaceable) { Replaceable.new('@username @username') }
        it { should == '[@username](/users/username) [@username](/users/username)' }
      end
      
      context 'started with @username' do
        let(:replaceable) { Replaceable.new('@username ') }
        it { should == '[@username](/users/username) ' }
      end
      
      context 'at the end of the line' do
        let(:replaceable) { Replaceable.new(' @username') }
        it { should == ' [@username](/users/username)' }
      end
      
      context 'a part of email' do
        let(:replaceable) { Replaceable.new('foo@username') }
        it { should == 'foo@username' }
      end
      
      context 'a double @username@username' do
        let(:replaceable) { Replaceable.new('@username@username') }
        it { should == '@username@username' }
      end
      
      PUNCTUATION.each do |char|
        context "end with #{char}" do
          let(:replaceable) { Replaceable.new("@username#{char}") }
          it { should == "[@username](/users/username)#{char}" }
        end
      end
    end
  end
  
  describe '#tag_names' do
    let(:replaceable) { Replaceable.new('#tag1, #tag2, #tag3') }
    subject { replaceable.tag_names }
    it { should == %w(tag1 tag2 tag3) }
  end
end
