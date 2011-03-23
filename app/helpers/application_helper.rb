module ApplicationHelper
	def date_humanize(date)
		return date.strftime("%A, %B %e, %Y @ %I:%M %p")
	end

	def date_humanize_dayofweek_and_time(date)
		return date.strftime("%A, %I:%M %p")
	end
end
