class UserMailerPreview < ActionMailer::Preview
  def daily_email
    UserMailer.daily_email(user_id: User.last.id, email_id: Email.last.id)
  end

  def workshop_email
    UserMailer.workshop_email(User.last.id)
  end

  def welcome_email
    UserMailer.welcome_email(User.last.id)
  end
end
