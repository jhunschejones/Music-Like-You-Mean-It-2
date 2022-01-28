class SendDailyEmailJob < ApplicationJob
  queue_as :default

  def perform
    Email.to_send_today.each do |email|
      User.find_each do |user|
        UserMailer.daily_email(email_id: email.id, user_id: user.id).deliver_later
      end
    end
  end
end
