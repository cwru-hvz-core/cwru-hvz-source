class ContactMessagesController < ApplicationController
	def new
		# TODO: This probably deserves its own place somewhere else, as it is not really
		# a "people" thing.
		@admins = Person.find_all_by_is_admin(true)
	end

	def create
		@new = ContactMessage.new(params[:contact_message])
		if @new.save
			flash[:notice] = "Thank you for your feedback. An administrator will read your message shortly and we will take appropriate action."
			redirect_to :contact_messages
		else
			flash[:error] = @new.errors.full_messages.first
			redirect_to :contact_messages
		end

	end


end
