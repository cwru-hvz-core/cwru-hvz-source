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

        it 'redirects to edit_person_path with ?next=registration' do
          get :new
          response.should redirect_to edit_person_path(user, next: 'registration')
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

        it 'redirects to sign_waiver_url with ?next=registration' do
          get :new
          response.should redirect_to sign_waiver_url(user, next: 'registration')
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

  describe '#create' do
    let!(:game) { FactoryGirl.create(:current_game) }
    let!(:user) { FactoryGirl.create(:person) }

    context 'under all the valid circumstances' do
      before do
        Game.stub(current: game)
        log_in_as(user)
        FactoryGirl.create(:waiver, person: user, game: game)
        game.stub(now: game.registration_begins + 1.minute)
      end

      let(:valid_params) do
        { registration: {
          wants_oz: '0',
          is_off_campus: '0'
        } }
      end

      it 'works' do
        expect { post :create, valid_params }.
          to change { Registration.count }.by(1)
      end
    end
  end
end
