class ContactMessagesController < ApplicationController

	def new
		# TODO: This probably deserves its own place somewhere else, as it is not really
		# a "people" thing.
		@admins = Person.find_all_by_is_admin(true)
	end

	def create
		@new = ContactMessage.new(params[:contact_message])
		@new.game = @current_game

		if @new.save
			flash[:notice] = "Thank you for your feedback. An administrator will read your message shortly and we will take appropriate action."
			redirect_to :contact_messages
		else
			flash[:error] = @new.errors.full_messages.first
			redirect_to :contact_messages
		end

	end
	
	def list
		if params[:all].nil?
			@messages = ContactMessage.find_all_by_game_id_and_visible(@current_game, true)
		else
			@messages = ContactMessage.find_all_by_game_id(@current_game)
		end
	end
	
	def destroy
		@message = ContactMessage.find(params[:id])
		@message.visible = false
		@message.save()
		redirect_to list_contact_messages_url()
	end
end
