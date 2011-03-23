module InfractionsHelper
	def calc_total_severity(registration)
		return registration.infractions.find_all{|x| !x.nullified}.sum{|i| i.severity}
	end
	
	def severity_description(severity)
		descriptions = ["Low (Rule Violation)", "Medium (Intentional DBAD)",  "High (Grounds for Removal)"]
		if(severity > 0 && severity <= 3)
			return descriptions[severity - 1]
		else
			return ""
		end
	end
end
