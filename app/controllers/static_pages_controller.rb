class StaticPagesController < ApplicationController
  skip_before_action :authenticate_admin_user

  def about
  end

  def privacy
  end

  def terms
  end

  def workshop
    # Handle workshop key provided via URL params first
    if params[:id]
      user_from_workshop_key = User.find_by_workshop_key(params[:id])
      if user_from_workshop_key
        session[:user_id] = user_from_workshop_key.id
        # redirect_to workshop_path
      else
        reset_session
        flash.now[:notice] = "Sorry, but we couldn't find your workshop! Please follow the link from your email or enter your information on the signup form."
        return render "users/new_workshop_user"
      end
    end

    @current_user = User.find(session[:user_id])
    @current_user.increment!(:workshop_page_views)
  rescue ActiveRecord::RecordNotFound
    render "users/new_workshop_user"
  end
end
