require 'spec_helper'

describe RegistrationsController do
  render_views

  describe '#new' do
    let!(:game) { FactoryGirl.create(:current_game) }
    let!(:user) { FactoryGirl.create(:person) }

    before do
      Game.stub(current: game)
      log_in_as(user)
    end

    context 'when the game has not yet opened for registration' do
      before do
        game.stub(now: game.registration_begins - 1.minute)
      end

      it 'redirects home' do
        get :new
        response.should redirect_to root_url
      end
    end

    context 'when the game is open for registration' do
      before do
        game.stub(now: game.registration_begins + 1.minute)
      end

      context 'when the user has not inputted a name' do
        let!(:user) { FactoryGirl.create(:person, name: '') }

        it 'redirects to edit_person_path' do
          get :new
          response.should redirect_to edit_person_path(user)
        end
      end

      context 'when the user has not signed a waiver' do
        context 'when the user is under 18' do
          let!(:user) { FactoryGirl.create(:person, :underage) }

          it 'renders' do
            get :new
            response.should be_success
          end
        end

        it 'requires a waiver to be signed' do
          get :new
          response.should redirect_to sign_waiver_url(user)
        end
      end

      context 'when the user has signed a waiver' do
        before do
          FactoryGirl.create(:waiver, person: user, game: game)
        end

        it 'renders' do
          get :new
          response.should be_success
        end
      end
    end

    context 'when the game is closed for registration' do
      before do
        game.stub(now: game.registration_ends + 1.minute)
      end

      it 'redirects home' do
        get :new
        response.should redirect_to root_url
      end
    end
  end
end
