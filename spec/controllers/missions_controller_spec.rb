require 'spec_helper'

describe MissionsController do
  describe '#index' do
    render_views

    before do
      @game = FactoryGirl.create(:current_game)
      @missions = FactoryGirl.create_list(:mission, 5, :game => @game)
    end

    it 'lists all the missions that exist for the current game' do
      get :index
      @missions.all? { |m| response.body.include? m.title }.should be_true
    end

    context 'when another game exists' do
      before do
        @other_game = FactoryGirl.create(:game)
        @other_missions = FactoryGirl.create_list(:mission, 5, :game => @other_game)
      end

      it "doesn't show missions for a different game" do
        @other_missions.any? { |m| response.body.include? m.title}.should be_false
      end
    end
  end
end
