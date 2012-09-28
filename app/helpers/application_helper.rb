module ApplicationHelper
	def date_humanize(date)
		return date.strftime("%A, %B %e, %Y @ %I:%M %p")
	end

	def date_humanize_dayofweek_and_time(date)
		return date.strftime("%A, %I:%M %p")
	end

  def profile_photo_url(person, size=32, default=image_path('http://casehvz.com/images/gravatar_default.png'))
    ["http://www.gravatar.com/avatar/",
      Digest::MD5.hexdigest(person.caseid + '@case.edu'),
      "?s=#{size}&d=#{u default}"
    ].join
  end

  def gravatar_profile_url(person)
    ["http://www.gravatar.com/",
      Digest::MD5.hexdigest(person.caseid + '@case.edu'),
    ].join
  end
end
