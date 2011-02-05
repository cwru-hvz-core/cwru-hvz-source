require 'test_helper'

class GameTest < ActiveSupport::TestCase
	# Replace this with your real tests.
	def setup
		@a = games(:valid)
	end

	test "is invalid without a name" do
		@a.short_name = nil
		assert !@a.valid?
	end
	test "ensures sequential dates" do
		@a.registration_ends = @a.registration_begins - 100
		assert !@a.valid?
		@a = games(:valid)
		@a.game_ends = @a.game_begins - 100
		assert !@a.valid?
	end
end
