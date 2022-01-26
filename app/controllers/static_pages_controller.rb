class StaticPagesController < ApplicationController
  skip_before_action :authenticate_admin_user

  def about
  end

  def privacy
  end

  def terms
  end

  def workshop
    @current_user = User.find(session[:user_id])
    @current_user.increment!(:workshop_page_views)
  rescue ActiveRecord::RecordNotFound
    render "users/new_workshop_user"
  end

  def error
    if params[:code] == "404"
      render "404", status: 404
    else
      render "500", status: 500
    end
  end
end
