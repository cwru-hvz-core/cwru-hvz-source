require 'spec_helper'

describe WaiverController do
  render_views

  let(:game) { FactoryGirl.create(:current_game) }
  let(:person) { FactoryGirl.create(:person) }

  before do
    Game.stub(current: game)
    log_in_as(person)
  end

  describe '#new' do
    subject { get :new, id: person.id }

    it 'redirects home when the game is not open for registration' do
      subject
      response.should redirect_to root_url
    end

    context 'when the game is open for registration' do
      before { game.stub(now: game.registration_begins + 1.minute) }

      it 'renders' do
        subject
        response.should be_success
      end
    end
  end

  describe '#create' do
    let(:valid_params) do
      { id: person.id,
        waiver: {
          studentid: '1234567',
          chk1: '1',
          chk2: '1',
          chk3: '1',
          chk4: '1',
          emergencyname: 'John Doe',
          emergencyrelationship: 'Brother',
          emergencyphone: '123-456-7890',
          signature: person.name,
      } }
    end

    it 'redirects home when the game is not open for registration' do
      post :create, valid_params
      response.should redirect_to root_path
    end

    context 'when the game is open for registration' do
      before { game.stub(now: game.registration_begins + 1.minute) }

      it 'creates a waiver instance' do
        expect { post :create, valid_params }.
          to change { Waiver.count }.by(1)
      end

      context 'when a next registration step is passed in' do
        let(:redirection_params) { valid_params.merge(next: 'registration') }

        it 'redirects to the registration step' do
          post :create, redirection_params
          response.should redirect_to new_registration_path
        end
      end
    end
  end
end
