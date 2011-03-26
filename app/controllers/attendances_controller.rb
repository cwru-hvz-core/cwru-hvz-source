class AttendancesController < ApplicationController
	before_filter :check_admin

	def create
	 	@attendance = Attendance.new(params[:attendance])
		if @attendance.person_id.nil?
			@attendance.person_id = Person.where("lower(name) LIKE ?", params[:attendance][:person_name].downcase + "%")
		end
		@attendance.save()
		@attendances = Attendance.find_all_by_mission_id(params[:attendance][:mission_id], :order=>"created_at DESC")
		@humans = @attendances.map {|x| x if x.registration.is_human?}.compact
		@zombies = @attendances.map {|x| x if x.registration.is_zombie?}.compact
	end

	def destroy
		@attendance = Attendance.find(params[:id])
		if @attendance.delete()
			redirect_to mission_attendance_url(@attendance.mission.id)
		else
			flash[:error] = "Could not delete attendance!"
			redirect_to mission_attendance_url(@attendance.mission.id)
		end
	end
end
