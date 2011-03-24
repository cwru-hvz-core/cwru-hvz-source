class AttendancesController < ApplicationController
	before_filter :check_admin

	def create
	 	@attendance = Attendance.new(params[:attendance])
		@attendance.save()
		@attendances = Attendance.find_all_by_mission_id(params[:attendance][:mission_id], :order=>"created_at DESC")
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
