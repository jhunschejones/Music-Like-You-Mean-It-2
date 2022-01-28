class UserMailer < ApplicationMailer
  include Roadie::Rails::Automatic

  def daily_email(email_id:, user_id:, is_test: false)
    @user = User.find(user_id)
    @email = Email.find(email_id)
    mail(
      to: @user.email,
      subject: is_test ? "TEST #{@email.subject}" : @email.subject
    )
  end

  def workshop_email(user_id)
    @user = User.find(user_id)
    mail(
      to: @user.email,
      subject: "Music Like You Mean It Workshop (Link Inside)"
    )
  end

  def welcome_email(user_id)
    @user = User.find(user_id)
    mail(
      to: @user.email,
      subject: "Welcome to Music Like You Mean It!"
    )
  end
end
