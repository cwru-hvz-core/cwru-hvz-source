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
end
