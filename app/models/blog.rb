class Blog < ApplicationRecord
  has_many :tags, dependent: :destroy, inverse_of: :blog
  has_rich_text :content
  # used to query the attached ActionText directly
  has_one :action_text_rich_text, class_name: "ActionText::RichText", as: :record

  validates :title, presence: true

  scope :published, -> { where("published_at < ? AND is_draft = ?", Time.now, false) }

  before_save :format_named_url

  def id_for_url
    named_url.nil? ? id : named_url
  end

  private

  def format_named_url
    unless named_url.nil?
      formatted_named_url = named_url.strip.downcase.split.join("-")
      self.named_url = formatted_named_url.empty? ? nil : formatted_named_url
    end
  end
end
