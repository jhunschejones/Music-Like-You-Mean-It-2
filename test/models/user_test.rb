require "test_helper"

# bundle exec ruby -Itest test/models/user_test.rb
class UserTest < ActiveSupport::TestCase
  test "prevents user from being saved with invalid site_role" do
    user = User.new(
      name: "Riley Jones",
      email: "riley@dafox.com",
      password: "secret",
      password_confirmation: "secret",
      site_role: "wizzard"
    )
    user.validate
    expected_errors = { site_role: ["not included in '[\"user\", \"admin\"]'"] }
    assert_equal(expected_errors, user.errors.messages)
  end

  describe ".find_by_unsubscribe_key" do
    test "returns a user with old key format" do
      key = Rails.application.message_verifier(:unsubscribe).generate(users(:site_user).id)
      user_from_unsubscribe_key = User.find_by_unsubscribe_key(key)
      assert user_from_unsubscribe_key.is_a?(User)
      assert_equal users(:site_user).id, user_from_unsubscribe_key.id
    end

    test "returns a user with new key format" do
      key = Rails.application.message_verifier(:unsubscribe).generate({
        id: users(:site_user).id,
        created_at: Time.now.utc.to_s
      })
      user_from_unsubscribe_key = User.find_by_unsubscribe_key(key)
      assert user_from_unsubscribe_key.is_a?(User)
      assert_equal users(:site_user).id, user_from_unsubscribe_key.id
    end

    test "returns nil when no user is found" do
      key = Rails.application.message_verifier(:unsubscribe).generate({
        id: User.last.id + 100,
        created_at: Time.now.utc.to_s
      })
      assert_nil User.find_by_unsubscribe_key(key)
    end

    test "returns nil for invalid signature" do
      key = Rails.application.message_verifier(:unsubscribe).generate("I_Hacks_Your_Keyz")
      assert_nil User.find_by_unsubscribe_key(key)
    end
  end

  describe ".find_by_workshop_key" do
    test "returns a user with old key format" do
      key = Rails.application.message_verifier(:workshop).generate(users(:site_user).id)
      user_from_workshop_key = User.find_by_workshop_key(key)
      assert user_from_workshop_key.is_a?(User)
      assert_equal users(:site_user).id, user_from_workshop_key.id
    end

    test "returns a user with new key format" do
      key = Rails.application.message_verifier(:workshop).generate({
        id: users(:site_user).id,
        created_at: Time.now.utc.to_s
      })
      user_from_workshop_key = User.find_by_workshop_key(key)
      assert user_from_workshop_key.is_a?(User)
      assert_equal users(:site_user).id, user_from_workshop_key.id
    end

    test "returns nil when no user is found" do
      key = Rails.application.message_verifier(:workshop).generate({
        id: User.last.id + 100,
        created_at: Time.now.utc.to_s
      })
      assert_nil User.find_by_workshop_key(key)
    end

    test "returns nil for invalid signature" do
      key = Rails.application.message_verifier(:workshop).generate("I_Hacks_Your_Keyz")
      assert_nil User.find_by_workshop_key(key)
    end
  end
end
