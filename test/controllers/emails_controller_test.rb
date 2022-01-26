require 'test_helper'

# bundle exec ruby -Itest test/controllers/emails_controller_test.rb
class EmailsControllerTest < ActionDispatch::IntegrationTest
  describe "admin authentication" do
    describe "when no user is logged in" do
      test "user is blocked from the emails page" do
        get emails_path
        assert_redirected_to login_path
      end

      test "user is blocked from the email page" do
        get email_path(emails(:draft))
        assert_redirected_to login_path
      end

      test "user is blocked from the new email page" do
        get new_email_path
        assert_redirected_to login_path
      end

      test "user is blocked from the edit email page" do
        get edit_email_path(emails(:draft))
        assert_redirected_to login_path
      end

      test "user is blocked from the test email action" do
        UserMailer.expects(:daily_email).never
        get test_email_path(emails(:draft))
        assert_redirected_to login_path
      end

      test "user is blocked from the send daily emails action" do
        SendDailyEmailJob.expects(:perform_later).never
        post send_daily_email_emails_path
        assert_redirected_to login_path
      end

      test "user is blocked from creating emails" do
        assert_no_difference 'Email.count' do
          post emails_path, params: { email: { subject: "My New Email" } }
        end
        assert_redirected_to login_path
      end

      test "user is blocked from updating emails" do
        assert_no_changes -> { Email.find(emails(:draft).id).subject } do
          patch email_path(emails(:draft)), params: { email: { subject: "Change The Email Subject" } }
        end
        assert_redirected_to login_path
      end

      test "user is blocked from deleting emails" do
        assert_no_difference 'Email.count' do
          delete email_path(emails(:draft), format: :js)
        end
        assert_redirected_to login_path
      end
    end

    describe "when site user is logged in" do
      before do
        login_as(users(:site_user))
      end

      test "user is blocked from the emails page" do
        get emails_path
        assert_redirected_to login_path
      end

      test "user is blocked from the email page" do
        get email_path(emails(:draft))
        assert_redirected_to login_path
      end

      test "user is blocked from the new email page" do
        get new_email_path
        assert_redirected_to login_path
      end

      test "user is blocked from the edit email page" do
        get edit_email_path(emails(:draft))
        assert_redirected_to login_path
      end

      test "user is blocked from the test email action" do
        UserMailer.expects(:daily_email).never
        get test_email_path(emails(:draft))
        assert_redirected_to login_path
      end

      test "user is blocked from the send daily emails action" do
        SendDailyEmailJob.expects(:perform_later).never
        post send_daily_email_emails_path
        assert_redirected_to login_path
      end

      test "user is blocked from creating emails" do
        assert_no_difference 'Email.count' do
          post emails_path, params: { email: { subject: "My New Email" } }
        end
        assert_redirected_to login_path
      end

      test "user is blocked from updating emails" do
        assert_no_changes -> { Email.find(emails(:draft).id).subject } do
          patch email_path(emails(:draft)), params: { email: { subject: "Change The Email Subject" } }
        end
        assert_redirected_to login_path
      end

      test "user is blocked from deleting emails" do
        assert_no_difference 'Email.count' do
          delete email_path(emails(:draft), format: :js)
        end
        assert_redirected_to login_path
      end
    end

    describe "when site admin is logged in" do
      before do
        login_as(users(:site_admin))
      end

      test "user can access the emails page" do
        get emails_path
        assert_response :success
        assert_select "h2.title", /All emails/
      end

      test "user can access the email page" do
        get email_path(emails(:draft))
        assert_response :success
        assert_select "span", emails(:draft).subject
      end

      test "user can access new email page" do
        get new_email_path
        assert_response :success
        assert_select "h2.title", "New email"
      end

      test "user can access edit email page" do
        get edit_email_path(emails(:draft))
        assert_response :success
        assert_select 'form input[name="email[subject]"][value=?]', emails(:draft).subject
      end

      test "user can send test email" do
        test_job = mock()
        test_job.stubs(:deliver_later)
        UserMailer.expects(:daily_email)
                  .with(email_id: emails(:draft).id, user_id: users(:site_admin).id, is_test: true)
                  .returns(test_job)

        get test_email_path(emails(:draft))
        assert_redirected_to email_path(emails(:draft))
      end

      test "user can send daily emails" do
        SendDailyEmailJob.expects(:perform_later).once
        post send_daily_email_emails_path
        assert_redirected_to emails_path
        assert_equal "Daily emails enqueued", flash[:success]
      end

      test "user can create emails" do
        assert_difference 'Email.count', 1 do
          post emails_path, params: { email: { subject: "My New Email" } }
        end
      end

      test "user can update emails" do
        assert_changes -> { Email.find(emails(:draft).id).subject } do
          patch email_path(emails(:draft)), params: { email: { subject: "Change The Subject" } }
        end
        assert_equal "Change The Subject", Email.find(emails(:draft).id).subject
      end

      test "user is can delete deleting emails" do
        assert_difference 'Email.count', -1 do
          delete email_path(emails(:draft), format: :js)
        end
      end
    end
  end

  private

  def login_as(user)
    post login_path, params: { email: user.email, password: "secret" }
  end
end
