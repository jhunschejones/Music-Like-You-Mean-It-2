require "test_helper"

# bundle exec ruby -Itest test/mailers/user_mailer_test.rb
class UserMailerTest < ActionMailer::TestCase
  describe "#daily_email" do
    test "uses correct format for test email" do
      email = UserMailer.daily_email(email_id: emails(:draft).id, user_id: users(:site_admin).id, is_test: true).deliver_now

      assert_not ActionMailer::Base.deliveries.empty?
      assert_equal "Josh [Music Like You Mean It] <contact@musiclikeyoumeanit.com>", email.from
      assert_equal [users(:site_admin).email], email.to
      assert_equal "TEST #{emails(:draft).subject}", email.subject
    end

    test "uses correct format for real email" do
      email = UserMailer.daily_email(email_id: emails(:draft).id, user_id: users(:site_admin).id).deliver_now

      assert_not ActionMailer::Base.deliveries.empty?
      assert_equal "Josh [Music Like You Mean It] <contact@musiclikeyoumeanit.com>", email.from
      assert_equal [users(:site_admin).email], email.to
      assert_equal emails(:draft).subject, email.subject
    end
  end

  describe "#workshop_email" do
    test "sends the workshop email" do
      email = UserMailer.workshop_email(users(:site_user).id).deliver_now

      assert_not ActionMailer::Base.deliveries.empty?
      assert_equal "Josh [Music Like You Mean It] <contact@musiclikeyoumeanit.com>", email.from
      assert_equal [users(:site_user).email], email.to
      assert_equal "Music Like You Mean It Workshop (Link Inside)", email.subject
    end
  end

  describe "#welcome_email" do
    test "sends the welcome email" do
      email = UserMailer.welcome_email(users(:site_user).id).deliver_now

      assert_not ActionMailer::Base.deliveries.empty?
      assert_equal "Josh [Music Like You Mean It] <contact@musiclikeyoumeanit.com>", email.from
      assert_equal [users(:site_user).email], email.to
      assert_equal "Welcome to Music Like You Mean It!", email.subject
    end
  end
end
