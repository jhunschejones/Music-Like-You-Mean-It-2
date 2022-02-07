require "csv"

class UsersController < ApplicationController
  include DateParsing

  class InsecureRequest < StandardError; end
  class NoUnsubscribeUserFound < StandardError; end

  skip_before_action :authenticate_admin_user, only: [:create_workshop_users, :unsubscribe, :destroy]

  ORDERED_CSV_FIELDS = [
    :name,
    :email,
    :site_role,
    :workshop_page_views,
    :created_at,
    :updated_at
  ]

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
    # Handle unsubscribe key provided via URL params first
    if params[:id]
      @user = User.find_by_unsubscribe_key(params[:id])
      raise NoUnsubscribeUserFound unless @user
      session[:user_id] = @user.id
      # return redirect_to unsubscribe_path
    end

    @user = User.find(session[:user_id])
  rescue ActiveRecord::RecordNotFound, NoUnsubscribeUserFound
    reset_session
    flash[:notice] = "We couldn't find you! You are either already unsubscribed, or you'll need to follow the unsubscribe link from your email again."
    return redirect_to workshop_path
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
    # user is authenticated automatically when they go to the unsubscribe page
    @authenticated_user = User.find(session[:user_id])
    @user_to_delete = User.find(params[:id])
    secure_request!
    @user_to_delete.destroy!

    return respond_to(&:turbo_stream) if @authenticated_user.is_admin?

    reset_session
    flash[:notice] = "You have successfully unsubscribed."
    # https://github.com/hotwired/turbo-rails/issues/122#issuecomment-782766453
    redirect_to workshop_path, status: :see_other
  rescue
    if @authenticated_user
      flash[:alert] = "Something went wrong! Please try again."
      redirect_to unsubscribe_path(id: @authenticated_user.unsubscribe_key)
    else
      flash[:alert] = "Something went wrong! Please follow the unsubscribe link from your email again."
      redirect_to workshop_path
    end
  end

  def export
  end


  def import
  end

  def download
    csv = CSV.generate(headers: true) do |csv|
      csv << ORDERED_CSV_FIELDS # add headers

      User.find_each do |user|
        csv << ORDERED_CSV_FIELDS.map { |attr| user.send(attr) }
      end
    end

    respond_to do |format|
      format.csv { send_data(csv, filename: "users_export_#{Time.now.utc.to_i}.csv") }
    end
  end

  def upload
    unless params[:csv_file]&.content_type == "text/csv"
      return redirect_to import_users_path, alert: "Missing CSV file or unsupported file format"
    end

    users_added = 0
    users_updated = 0
    users_already_exist = 0
    admins_skipped = 0
    CSV.read(params[:csv_file].path).each_with_index do |row, index|
      if index.zero?
        return redirect_to import_users_path, alert: "Incorrectly formatted CSV" if row.size != ORDERED_CSV_FIELDS.size
        next if params[:csv_includes_headers]
      end

      name = row[0]
      email = row[1]
      site_role = User::SITE_USER # don't allow users to be made admins with user import
      workshop_page_views = row[3].presence || 0
      created_at = row[4].presence && date_or_time_from(row[4])
      updated_at = row[5].presence && date_or_time_from(row[5])

      if (user = User.find_by(email: email))
        if user.is_admin?
          # don't accidentally overwrite admin users
          admins_skipped +=1
        elsif params[:overwrite_matching_users]
          users_updated += 1 if user.update(
            name: name,
            site_role: site_role,
            workshop_page_views: workshop_page_views,
            created_at: created_at,
            updated_at: updated_at
          )
        end

        next users_already_exist += 1
      end

      temp_password = SecureRandom.hex
      users_added += 1 if User.create(
        name: name,
        email: email,
        site_role: site_role,
        workshop_page_views: workshop_page_views,
        created_at: created_at,
        updated_at: updated_at,
        password: temp_password,
        password_confirmation: temp_password
      )
    end

    flash[:success] =
      if params[:overwrite_matching_users]
        "#{users_updated} existing #{"user".pluralize(users_updated)} updated, #{users_added} new #{"user".pluralize(users_added)} imported, #{admins_skipped} #{"admin".pluralize(admins_skipped)} skipped."
      else
        "#{users_added} new #{"user".pluralize(users_added)} imported, #{users_already_exist} #{"user".pluralize(users_already_exist)} already #{"exist".pluralize(users_added)}."
      end
    redirect_to users_path
  rescue InvalidDateOrTime => error
    redirect_to import_users_path, alert: "Some users were unable to be imported: invalid date format: '#{error.message}'. Please use 'mm/dd/yyyy' formatted dates."
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
