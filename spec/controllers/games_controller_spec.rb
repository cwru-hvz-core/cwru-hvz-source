require 'spec_helper'

describe GamesController do
  render_views

  let(:game) { FactoryGirl.create(:current_game) }

  describe '#show' do
    it 'renders' do
      get :show, id: game.id
      response.should be_success
    end

    context 'with players' do
      let!(:player) { FactoryGirl.create(:registration, game: game) }

      it 'shows the player name' do
        get :show, id: game.id
        response.body.should include(player.person.name)
      end
    end

    context 'with squads' do
      let!(:squad) { FactoryGirl.create(:squad, game: game) }

      it 'shows the squad name' do
        get :show, id: game.id
        response.body.should include(squad.name)
      end
    end
  end

  describe '#edit' do
    subject { get :edit, id: game.id }

    it 'redirects you home' do
      subject.should redirect_to(root_path)
    end

    context 'when logged in as a non-admin user' do
      let(:user) { FactoryGirl.create(:person) }
      
      before do
        log_in_as(user)
      end

      it 'redirects you home' do
        subject.should redirect_to(root_path)
      end
    end

    context 'as an admin' do
      let(:user) { FactoryGirl.create(:admin) }

      before do
        log_in_as(user)
      end

      it 'redirects you home' do
        subject.should be_success
      end
    end
  end
end
