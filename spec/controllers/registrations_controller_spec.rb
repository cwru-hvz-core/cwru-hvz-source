require 'spec_helper'

describe RegistrationsController do
  describe '#new' do
    let!(:game) { FactoryGirl.create(:current_game) }
    let!(:user) { FactoryGirl.create(:person) }

    before do
      Game.stub(current: game)
      FactoryGirl.create(:waiver, person: user, game: game)
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

      it 'renders' do
        get :new
        response.should be_success
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
