require 'spec_helper'

describe Person do
  describe '#legal_to_sign_waiver?' do
    subject { person.legal_to_sign_waiver? }

    context 'if the person is under 18' do
      let(:person) do
        FactoryGirl.build(:person, date_of_birth: Date.today - 18.years + 1.day)
      end

      it { should be_false }
    end
    
    context 'if the person is 18' do
      let(:person) do
        FactoryGirl.build(:person, date_of_birth: Date.today - 18.years)
      end

      it { should be_true }
    end
  end
end
