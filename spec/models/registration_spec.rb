require 'spec_helper'

describe Registration do
  describe '#most_recent_feed' do
    subject { registration.most_recent_feed }

    let(:registration) { FactoryGirl.create(:registration, :zombie) }

    it 'should return a time' do
      registration.most_recent_feed.should_not == nil
    end
  end

  describe '#killing_tag' do
    subject { registration.killing_tag }

    context 'when the player is human' do
      let(:registration) { FactoryGirl.create(:registration, :human) }
      it { should be_nil }
    end

    context 'when the player is a zombie' do
      let(:registration) { FactoryGirl.create(:registration, :zombie) }
      it { should == registration.taggedby.first }
    end

    context 'when the player is deceased' do
      let(:registration) { FactoryGirl.create(:registration, :deceased) }
      it { should == registration.taggedby.first }
    end

    context 'when the player is an OZ' do
      let(:registration) { FactoryGirl.create(:registration, :oz) }
      it { should be_nil }
    end
  end
end
