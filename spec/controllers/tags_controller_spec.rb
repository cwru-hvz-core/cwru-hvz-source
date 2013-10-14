require 'spec_helper'

describe TagsController do
  let!(:game) { FactoryGirl.create(:current_game) }

  describe 'GET #new' do
    subject { get :new }

    context 'when logged out' do
      it 'redirects home' do
        subject.should redirect_to root_path
      end
    end

    context 'when logged in as an unregistered user' do
      let(:person) { FactoryGirl.create(:person) }

      before do
        log_in_as(person)
      end

      it 'redirects home' do
        subject.should redirect_to root_path
      end
    end

    context 'when logged in as a registered user' do
      context 'as a human' do
        let(:registration) { FactoryGirl.create(:registration, :human, game: game) }

        before do
          log_in_as(registration.person)
        end

        it 'redirects home' do
          subject
          response.should redirect_to root_path
        end
      end

      context 'as a zombie' do
        let(:registration) { FactoryGirl.create(:registration, :zombie, game: game) }

        before do
          log_in_as(registration.person)
        end

        it 'renders successfully' do
          subject
          response.should be_success
        end
      end
    end
  end
end
