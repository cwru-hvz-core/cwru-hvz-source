require 'spec_helper'

describe Achievement::DoubleKill do
  let(:player) { FactoryGirl.create(:registration, :zombie) }
  let(:first_tag) { FactoryGirl.create(:tag, tagger: player, game: player.game, datetime: first_time) } 
  let(:second_tag) { FactoryGirl.create(:tag, tagger: player, game: player.game, datetime: second_time) }

  before do
    player.tagged << first_tag
  end

  subject { player.tagged << second_tag }

  context 'when a player has two tags more than 30 minutes apart' do
    let(:first_time) { player.game.game_begins }
    let(:second_time) { first_time + 31.minutes }

    it 'she is not awarded the achievement' do
      expect { subject }.to_not change { Achievement.count }
    end
  end

  context 'when a player has two tags less than 30 minutes apart' do
    let(:first_time) { player.game.game_begins }
    let(:second_time) { first_time + 29.minutes }

    it 'she is awarded the achievement' do
      pending('fix this later')
      expect { subject }.to change { Achievement.count }.by(1)
    end
  end
end
