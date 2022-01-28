class User < ApplicationRecord
  has_secure_password

  encrypts :name
  encrypts :email, deterministic: true, downcase: true

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :password, presence: true, confirmation: true, if: :password
  validate :site_role_valid

  SITE_USER = "user".freeze
  SITE_ADMIN = "admin".freeze
  USER_SITE_ROLES = [SITE_USER, SITE_ADMIN].freeze

  def is_admin?
    site_role == SITE_ADMIN
  end

  def can_manage_users?
    is_admin?
  end

  def can_manage_emails?
    is_admin?
  end

  def can_manage_blogs?
    is_admin?
  end

  def just_created?
    saved_change_to_attribute?(:id)
  end

  def unsubscribe_key
    Rails.application.message_verifier(:unsubscribe).generate(id)
  end

  def self.find_or_create_workshop_user(name:, email:)
    temp_password = SecureRandom.hex
    create_with(
      name: name,
      password: temp_password,
      password_confirmation: temp_password
    ).find_or_create_by(email: email)
  end

  def self.from_unsubscribe_key(unsubscribe_key)
    find(
      Rails.application.message_verifier(:unsubscribe).verify(unsubscribe_key)
    )
  end

  private

  def site_role_valid
    unless USER_SITE_ROLES.include?(site_role)
      errors.add(:site_role, "not included in '#{USER_SITE_ROLES}'")
    end
  end
end
