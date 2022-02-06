class StaticPagesController < ApplicationController
  skip_before_action :authenticate_admin_user

  def about
  end

  def privacy
  end

  def terms
  end

  def workshop
    @current_user =
      if session[:user_id]
        User.find(session[:user_id])
      elsif params[:id]
        User.from_workshop_key(params[:id])
      end

    return render "users/new_workshop_user" unless @current_user

    session[:user_id] = @current_user.id
    @current_user.increment!(:workshop_page_views)
  rescue ActiveRecord::RecordNotFound
    render "users/new_workshop_user"
  end
end
