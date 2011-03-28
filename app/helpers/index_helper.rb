module IndexHelper
	def tag_text(tag)
		tagger = tag.tagger
		unless tagger.nil?
			tagger_str = tagger.person.name + " tagged "
			if tag.tagger.is_oz and not  @current_game.ozs_revealed?
				tagger_str = "An original zombie tagged "
			end
		end
		tagger_str ||= "An administrator converted "
		tagee = tag.tagee.person

		tagger_str + tagee.name + " " + distance_of_time_in_words(tag.datetime - @current_game.utc_offset, Time.now) + " ago."
	end
end
