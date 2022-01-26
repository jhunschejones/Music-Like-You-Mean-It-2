class UsersController < ApplicationController
  class InsecureRequest < StandardError; end

  skip_before_action :authenticate_admin_user, only: [:create_workshop_users, :unsubscribe, :destroy]

  def index
    @users = User.where(site_role: User::SITE_USER).order({ created_at: :desc })
  end

  def new
    @user = User.new
  end

  def create
    user = User.find_or_create_workshop_user(name: user_params[:name], email: user_params[:email])
    user.just_created? ? flash[:success] = "User added" : flash[:notice] = "User already exists"
    redirect_to new_user_path
  end

  def unsubscribe
    @user = User.from_unsubscribe_key(params[:id])
    session[:user_id] = @user.id
  rescue
    flash[:alert] = "Something went wrong! Please follow the unsubscribe link from your email again."
    redirect_to workshop_path
  end

  def create_workshop_users
    user = User.find_or_create_workshop_user(name: user_params[:name], email: user_params[:email])
    if user.is_admin?
      reset_session
      redirect_to login_url
    else
      session[:user_id] = user.id
      UserMailer.workshop_email(user.id).deliver_later
      redirect_to workshop_path
    end
  end

  def destroy
    @user_to_delete = User.find(params[:id])
    @authenticated_user = User.find(session[:user_id])
    secure_request!
    @user_to_delete.destroy!

    respond_to do |format|
      format.js
      format.html {
        reset_session
        flash[:notice] = "You have successfully unsubscribed."
        redirect_to workshop_path
      }
    end
  rescue
    if @authenticated_user
      flash[:alert] = "Something went wrong! Please try again."
      redirect_to unsubscribe_path(id: @authenticated_user.unsubscribe_key)
    else
      flash[:alert] = "Something went wrong! Please follow the unsubscribe link from your email again."
      redirect_to workshop_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def secure_request!
    unless @authenticated_user.is_admin? || (@user_to_delete == @authenticated_user)
      raise InsecureRequest
    end
  end
end
