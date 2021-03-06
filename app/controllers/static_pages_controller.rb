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
    if params[:id].present?
      user_from_workshop_key = User.find_by_workshop_key(params[:id])
      if user_from_workshop_key.nil?
        reset_session
        flash.now[:notice] = "Sorry, but we couldn't find your workshop! Please follow the link from your email or enter your information on the signup form."
        return render "users/new_workshop_user"
      end
      logger.debug "Setting user id in session to '#{user_from_workshop_key.id}'"
      session[:user_id] = user_from_workshop_key.id
      logger.debug "User id set in session to '#{session[:user_id]}'"
      # TODO: Still losing the session on redirect somehow, so I don't think this will work 🤔
      # return redirect_to workshop_url, status: :see_other
      @current_user = user_from_workshop_key
    end

    if @current_user.nil?
      logger.debug "Couldn't find current user with id '#{session[:user_id]}'"
      return render "users/new_workshop_user"
    end

    @current_user.increment!(:workshop_page_views)
  end
end
