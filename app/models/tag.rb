class Tag < ApplicationRecord
  belongs_to :blog, touch: true

  validates :text, presence: true

  before_save :format_text

  private

  def format_text
    self.text = text.strip.capitalize
  end
end
