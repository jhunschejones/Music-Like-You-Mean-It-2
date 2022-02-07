class SessionsController < ApplicationController
  skip_before_action :authenticate_admin_user

  def new
    if @current_user
      redirect_to session.delete(:return_to) || blogs_path
    end
  end

  def create
    user = User.find_by(email: params[:email])

    if user.try(:authenticate, params[:password])
      session[:user_id] = user.id
      flash.discard
      redirect_to session.delete(:return_to) || blogs_path
    else
      redirect_to login_url, alert: "Invalid email/password combination"
    end
  end

  def destroy
    reset_session
    # https://github.com/hotwired/turbo-rails/issues/122#issuecomment-782766453
    redirect_to login_url, notice: "Succesfully logged out", status: :see_other
  end
end
