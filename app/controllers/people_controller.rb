class PeopleController < ApplicationController
  before_filter :check_login, :except => ["login", "logout"]
  before_filter CASClient::Frameworks::Rails::Filter, :only => "login"

  def update
    @person = Person.find(params[:id], :include => :registrations) or Person.new

    if !@logged_in_person.can_edit?(@person)
      flash[:error] = "You do not have permissions to edit this person's details."
      return redirect_to root_url
    end

    # Protect against name changes
    if params[:person][:name] != @person.name
      if @is_admin || @person.can_change_name?
        @person.update_attribute(:name, params[:person][:name])
      else
        return redirect_to edit_person_url(@person), :flash => {
          :error => "You cannot edit your name now!"
        }
      end
    end
    params[:person].delete(:name)

    @person.update_attributes(params[:person])

    if @is_admin and not params[:person][:is_admin].nil?
      # This has to be done separately because we need to ensure that the person granting
      # admin access is an admin themselves.
      @person.is_admin = params[:person][:is_admin]
      @person.save()
    end

    case params[:next]
    when 'registration'
      redirect_to new_registration_path
    else
      redirect_to edit_person_path(@person)
    end
  end

  def edit
    @toedit = Person.find(params[:id])

    if !@logged_in_person.can_edit?(@toedit)
      flash[:error] = "You do not have permissions to edit this person's details."
      return redirect_to root_url
    end
  end

  def show
    @person = Person.find(params[:id])

    if not @is_admin and @person != @logged_in_person
      flash[:error] = "You do not have permissions to view this person's profile."
      redirect_to root_url
      return
    end
  end

  def list
    # TODO: Limit people to only the people who have registered on a certain site.
    @people = Person.all
  end

  def login
    redirect_to (session[:was_at] or root_url())
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
    #redirect_to (session[:was_at] or root_url())
  end

  def new
    redirect_to root_url()
  end
end
