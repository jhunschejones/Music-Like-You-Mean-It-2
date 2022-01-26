class ApplicationController < ActionController::Base
  before_action :authenticate_user
  before_action :authenticate_admin_user

  private

  def authenticate_user
    @current_user ||= session[:user_id] ? User.find_by(id: session[:user_id]) : nil
  end

  def authenticate_admin_user
    @current_user ||= session[:user_id] ? User.find_by(id: session[:user_id]) : nil
    unless @current_user&.is_admin?
      session[:return_to] ||= request.url
      redirect_to login_url, notice: "You do not have permission to access that page"
    end
  end
end
