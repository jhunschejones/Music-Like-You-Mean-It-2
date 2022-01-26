class Email < ApplicationRecord
  has_rich_text :body

  scope :to_send_today, -> { where(sent_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day, is_draft: false) }
end
