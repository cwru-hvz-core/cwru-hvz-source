module IndexHelper
	def tag_text(tag)
		tagger = tag.tagger.person
		tagger_str = "An unknown zombie"
		unless tagger.nil?
			tagger_str = tagger.name
		end
		if tag.tagger.is_oz and not @current_game.ozs_revealed?
			tagger_str = "An original zombie"
		end
		tagee = tag.tagee.person

		tagger_str + " tagged " + tagee.name + " " + distance_of_time_in_words(tag.datetime - @current_game.utc_offset, Time.now) + " ago."
	end
end
