class ConvertDbTimesToUtc < ActiveRecord::Migration
  def up
    Game.all.map do |g|
      g.update_attributes(
        :game_begins => g.game_begins + 4.hours,
        :game_ends => g.game_ends + 4.hours,
        :registration_begins => g.registration_begins + 4.hours,
        :registration_ends => g.registration_ends + 4.hours,
        :oz_reveal => g.oz_reveal + 4.hours,
      )
    end

    Tag.all.map do |t|
      t.update_attributes(
        :datetime => t.datetime + 4.hours,
      )
    end

    Feed.all.map do |f|
      f.update_attributes(
        :datetime => f.datetime + 4.hours,
      )
    end

    Mission.all.map do |m|
      m.update_attributes(
        :start => m.start + 4.hours,
        :end => m.end + 4.hours,
      )
    end

    CheckIn.all.map do |c|
      c.update_attributes(
        :created_at => c.created_at + 4.hours,
      )
    end

    ContactMessage.all.map do |c|
      c.update_attributes(
        :created_at => c.created_at + 4.hours,
        :occurred => c.occurred + 4.hours,
      )
    end

    Infraction.all.map do |i|
      i.update_attributes(
        :created_at => i.created_at + 4.hours,
      )
    end

    Waiver.all.map do |w|
      w.update_attributes(
        :created_at => w.created_at + 4.hours,
      )
    end
  end

  def down
    Game.all.map do |g|
      g.update_attributes(
        :game_begins => g.game_begins - 4.hours,
        :game_ends => g.game_ends - 4.hours,
        :registration_begins => g.registration_begins - 4.hours,
        :registration_ends => g.registration_ends - 4.hours,
        :oz_reveal => g.oz_reveal - 4.hours,
      )
    end

    Tag.all.map do |t|
      t.update_attributes(
        :datetime => t.datetime - 4.hours,
      )
    end

    Feed.all.map do |f|
      f.update_attributes(
        :datetime => f.datetime - 4.hours,
      )
    end

    Mission.all.map do |m|
      m.update_attributes(
        :start => m.start - 4.hours,
        :end => m.end - 4.hours,
      )
    end

    CheckIn.all.map do |c|
      c.update_attributes(
        :created_at => c.created_at - 4.hours,
      )
    end

    ContactMessage.all.map do |c|
      c.update_attributes(
        :created_at => c.created_at - 4.hours,
        :occurred => c.occurred - 4.hours,
      )
    end

    Infraction.all.map do |i|
      i.update_attributes(
        :created_at => i.created_at - 4.hours,
      )
    end

    Waiver.all.map do |w|
      w.update_attributes(
        :created_at => w.created_at - 4.hours,
      )
    end
  end
end
