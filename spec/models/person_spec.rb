require 'spec_helper'

describe Person do
  describe '#phone=' do
    subject { person.phone }
    
    let(:person) do
      FactoryGirl.build(:person)
    end
    
    context 'when there are non digits in the phone number' do
      before do
        person.phone = '111-222-3333'
      end

      it { should == '1112223333' }
    end
  end

  describe '#==' do
    subject { person1 == person2 }

    let(:person1) do
      FactoryGirl.build(:person, caseid: 'jxd123')
    end

    context 'if they have the same caseid' do
      let(:person2) do
        FactoryGirl.build(:person, caseid: 'jxd123')
      end

      it { should be_true }
    end

    context 'if they have different caseids' do
      let(:person2) do
        FactoryGirl.build(:person, caseid: 'jxd125')
      end

      it { should be_false }
    end
  end

  describe '#signed_waiver?' do
    subject { person.signed_waiver?(game) }

    let(:game) do
      FactoryGirl.build(:game)
    end

    let(:person) do
      FactoryGirl.build(:person)
    end

    context 'there is no waiver' do
      it { should be_false }
    end

    context 'there is a waiver' do
      before do
        FactoryGirl.create(:waiver, game: game, person: person)
      end

      it { should be_true }
    end
  end

  describe '#can_change_name?' do
    subject { person.can_change_name? }
    
    context 'if the person is an admin' do
      let(:person) do
        FactoryGirl.build(:admin)
      end

      it { should be_true }
    end

    context 'if there is a current registration' do
      let(:person) do
        FactoryGirl.create(:person)
      end

      before do
        FactoryGirl.create(:registration, game: game, person: person)
      end

      context 'if the game has begun' do
        let(:game) do
          FactoryGirl.create(:current_game, :begun)
        end

        it { should be_false }
      end

      context 'if the game has not begun' do
        let(:game) do
          FactoryGirl.create(:current_game)
        end

        it { should be_true }
      end
    end
  end

  describe '#can_edit' do
    subject { other.can_edit?(person) }
    
    let(:person) do
      FactoryGirl.build(:person)
    end

    context 'if the person is the same' do
      let(:other) do
        person
      end

      it { should be_true }
    end

    context 'if the person is an admin' do
      let(:other) do
        FactoryGirl.build(:admin)
      end

      it { should be_true }
    end

    context 'if the person is someone else' do
      let(:other) do
        FactoryGirl.build(:person)
      end

      it { should be_false }
    end
  end

  describe '#legal_to_sign_waiver?' do
    subject { person.legal_to_sign_waiver? }

    context 'if the person is under 18' do
      let(:person) do
        FactoryGirl.build(:person, :underage)
      end

      it { should be_false }
    end
    
    context 'if the person is 18' do
      let(:person) do
        FactoryGirl.build(:person)
      end

      it { should be_true }
    end
  end
end
