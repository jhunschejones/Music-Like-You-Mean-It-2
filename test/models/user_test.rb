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
end
