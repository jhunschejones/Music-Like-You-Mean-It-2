require "test_helper"

# bundle exec ruby -Itest test/models/email_test.rb
class EmailTest < ActiveSupport::TestCase
  describe ".to_send_today" do
    it "returns emails ready to send today" do
      assert_equal [emails(:ready_to_send)], Email.to_send_today
    end

    it "does not return past emails" do
      refute Email.to_send_today.include?(emails(:already_sent))
    end

    it "does not return future emails" do
      refute Email.to_send_today.include?(emails(:future))
    end

    it "does not return draft emails" do
      refute Email.to_send_today.include?(emails(:draft))
    end
  end
end
