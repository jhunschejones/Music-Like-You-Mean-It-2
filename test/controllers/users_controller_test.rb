require "test_helper"

# bundle exec ruby -Itest test/controllers/users_controller_test.rb
class UsersControllerTest < ActionDispatch::IntegrationTest
  describe "admin authentication" do
    describe "when no user is logged in" do
      test "user is blocked from the users page" do
        get users_path
        assert_redirected_to login_path
      end

      test "user is blocked from new users page" do
        get new_user_path
        assert_redirected_to login_path
      end

      test "user cannot access user export page" do
        get export_users_path
        assert_redirected_to login_path
      end

      test "user cannot access user download" do
        get download_users_path(format: :csv)
        assert_redirected_to login_path
      end

      test "user cannot access user import page" do
        get import_users_path
        assert_redirected_to login_path
      end

      test "user is blocked from user upload" do
        csv_file = fixture_file_upload("test/fixtures/files/users_export_1643392033.csv", "text/csv")
        assert_no_difference "User.count" do
          post upload_users_path, params: { csv_file: csv_file, csv_includes_headers: true }
        end
        assert_redirected_to login_path
      end
    end

    describe "when site user is logged in" do
      before do
        login_as(users(:site_user))
      end

      test "user is blocked from the users page" do
        get users_path
        assert_redirected_to login_path
      end

      test "user is blocked from new users page" do
        get new_user_path
        assert_redirected_to login_path
      end

      test "user cannot access user export page" do
        get export_users_path
        assert_redirected_to login_path
      end

      test "user cannot access user download" do
        get download_users_path(format: :csv)
        assert_redirected_to login_path
      end

      test "user cannot access user import page" do
        get import_users_path
        assert_redirected_to login_path
      end

      test "user is blocked from user upload" do
        csv_file = fixture_file_upload("test/fixtures/files/users_export_1643392033.csv", "text/csv")
        assert_no_difference "User.count" do
          post upload_users_path, params: { csv_file: csv_file, csv_includes_headers: true }
        end
        assert_redirected_to login_path
      end
    end

    describe "when site admin is logged in" do
      before do
        login_as(users(:site_admin))
      end

      test "user can access the users page" do
        get users_path
        assert_response :success
        assert_select "h2", /All site users/
      end

      test "user can access new users page" do
        get new_user_path
        assert_response :success
        assert_select "h2", "Manually add a site user"
      end

      test "user can access user export page" do
        get export_users_path
        assert_response :success
      end

      test "user can access user download" do
        get download_users_path(format: :csv)
        assert_response :success
      end

      test "user can access user import page" do
        get import_users_path
        assert_response :success
      end

      test "user can upload a valid user CSV" do
        csv_file = fixture_file_upload("test/fixtures/files/users_export_1643392033.csv", "text/csv")
        assert_difference "User.count", 2 do
          post upload_users_path, params: { csv_file: csv_file, csv_includes_headers: true }
        end
        assert_redirected_to users_path
        assert_equal "2 new users imported, 1 user already exists.", flash[:success]

        new_user = User.find_by(email: "linguini.paws@dafox.com")
        assert_equal "Linguini Paws", new_user.name
        assert_equal User::SITE_USER, new_user.site_role
        assert_equal 2, new_user.workshop_page_views
        assert_equal Time.parse("Fri, 28 Jan 2022 11:47:01.000000000 CST -06:00"), new_user.created_at
        assert_equal Time.parse("Fri, 29 Jan 2022 11:47:01.000000000 CST -06:00"), new_user.updated_at
      end
    end
  end

  describe "POST new" do
    describe "when user is a site_user" do
      before do
        login_as(users(:site_user))
      end

      test "does not create a new user" do
        assert_no_difference "User.count" do
          post users_path, params: { user: { name: "Riley", email: "riley@dafox.com" } }
        end
      end

      test "redirects to admin login page" do
        post users_path, params: { user: { name: "Riley", email: "riley@dafox.com" } }
        assert_redirected_to login_path
      end
    end

    describe "when user is a site_admin" do
      before do
        login_as(users(:site_admin))
      end

      describe "when a user with matching email already exists" do
        test "does not create a new user record" do
          assert_no_difference "User.count" do
            post users_path, params: { user: { name: users(:site_user).name, email: users(:site_user).email } }
          end
        end
      end

      describe "when a user does not exist with matching email" do
        test "creates a new user record" do
          assert_difference "User.count", 1 do
            post users_path, params: { user: { name: "Riley", email: "riley@dafox.com" } }
          end
        end
      end
    end
  end

  describe "POST create_workshop_users" do
    describe "when a user with matching email already exists" do
      test "does not create a new user record" do
        assert_no_difference "User.count" do
          post workshop_users_path, params: { user: { name: users(:site_user).name, email: users(:site_user).email } }
        end
      end

      test "authenticates the user" do
        post workshop_users_path, params: { user: { name: users(:site_user).name, email: users(:site_user).email } }
        assert_equal users(:site_user).id, session[:user_id]
      end

      test "redirects to workshop page" do
        post workshop_users_path, params: { user: { name: users(:site_user).name, email: users(:site_user).email } }
        assert_redirected_to workshop_path
      end
    end

    describe "when the email belongs to an admin" do
      before do
        post workshop_users_path, params: { user: { name: users(:site_admin).name, email: users(:site_admin).email } }
      end

      test "does not authenticate the user" do
        assert_nil session[:user_id]
      end

      test "redirects to admin login page" do
        assert_redirected_to login_path
      end
    end

    describe "when a user does not exist with matching email" do
      test "creates a new user record" do
        assert_difference "User.count", 1 do
          post workshop_users_path, params: { user: { name: "Riley", email: "riley@dafox.com" } }
        end
      end

      test "authenticates the user" do
        post workshop_users_path, params: { user: { name: "Riley", email: "riley@dafox.com" } }
        refute_nil session[:user_id]
      end

      test "redirects to workshop page" do
        post workshop_users_path, params: { user: { name: "Riley", email: "riley@dafox.com" } }
        assert_redirected_to workshop_path
      end
    end
  end

  describe "unsubscribe" do
    describe "with invalid unsubscribe key" do
      before do
        get unsubscribe_path(id: "invalid-unsubscribe key")
      end

      test "does not authenticate any users" do
        assert_nil session[:user_id]
      end

      test "redirects to workshop path with message" do
        assert_redirected_to workshop_path
        assert_equal flash[:notice], "We couldn't find you! You are either already unsubscribed, or you'll need to follow the unsubscribe link from your email again."
      end
    end

    describe "with valid unsubscribe key" do
      before do
        get unsubscribe_path(id: users(:site_user).unsubscribe_key)
      end

      test "authenticates user" do
        assert_equal users(:site_user).id, session[:user_id]
      end

      test "redirects to unsubscribe page" do
        follow_redirect!
        assert_select "p", /Are you sure you want to unsubscribe/
      end
    end
  end

  describe "destroy" do
    describe "when there is no authenticated user" do
      test "does not destroy user" do
        assert_no_difference "User.count" do
          delete user_path(users(:site_user), format: :turbo_stream)
        end
      end

      test "redirects to unsubscribe page with message" do
        delete user_path(users(:site_user), format: :turbo_stream)
        assert_redirected_to workshop_path
        assert_match /follow the unsubscribe link/, flash[:alert]
      end
    end

    describe "when authenticated user id is different than id in params" do
      before do
        get unsubscribe_path(id: users(:site_user).unsubscribe_key)
      end

      test "does not destroy user" do
        assert_no_difference "User.count" do
          delete user_path(users(:site_admin), format: :turbo_stream)
        end
      end

      test "redirects to unsubscribe page for the authenticated user with message" do
        delete user_path(users(:site_admin), format: :turbo_stream)
        # resets unsubscribe key based on authenticated user, not user in params
        assert_redirected_to unsubscribe_path(id: users(:site_user).unsubscribe_key)
        assert_equal "Something went wrong! Please try again.", flash[:alert]
      end
    end

    describe "when authenticated user is the same as id in params" do
      before do
        get unsubscribe_path(id: users(:site_user).unsubscribe_key)
      end

      test "destroys the user" do
        assert_difference "User.count", -1 do
          delete user_path(users(:site_user), format: :turbo_stream)
        end
      end

      test "redirects to the workshop page with message" do
        delete user_path(users(:site_user), format: :turbo_stream)
        assert_redirected_to workshop_path
        assert_equal "You have successfully unsubscribed.", flash[:notice]
      end
    end

    describe "when an authenticated admin makes a turbo stream request" do
      before do
        login_as(users(:site_admin))
      end

      test "destroys the target user" do
        assert_difference "User.count", -1 do
          delete user_path(users(:site_user), format: :turbo_stream)
        end
      end

      test "responds with turbo-remove" do
        delete user_path(users(:site_user), format: :turbo_stream)
        assert_match /turbo-stream action="remove"/, response.body
        assert_match /target="user_#{users(:site_user).id}"/, response.body
      end
    end
  end

  describe "#date_or_time_from" do
    test "parses a short month, short day, short year datetime string" do
      assert_equal Date.new(2021, 1, 3), UsersController.new.send(:date_or_time_from, "1/3/21")
    end

    test "parses a short month, long day, short year datetime string" do
      assert_equal Date.new(2021, 1, 15), UsersController.new.send(:date_or_time_from, "1/15/21")
    end

    test "parses a long month, long day, short year datetime string" do
      assert_equal Date.new(2021, 10, 15), UsersController.new.send(:date_or_time_from, "10/15/21")
    end

    test "parses a short month, short day, long year datetime string" do
      assert_equal Date.new(2021, 1, 3), UsersController.new.send(:date_or_time_from, "1/3/2021")
    end

    test "parses a short month, long day, long year datetime string" do
      assert_equal Date.new(2021, 1, 15), UsersController.new.send(:date_or_time_from, "1/15/2021")
    end

    test "parses a long month, long day, long year datetime string" do
      assert_equal Date.new(2021, 10, 15), UsersController.new.send(:date_or_time_from, "10/15/2021")
    end

    test "parses an integer timestamp" do
      assert_equal User.last.created_at.to_time.change(usec: 0), UsersController.new.send(:date_or_time_from, User.last.created_at.to_i)
    end

    test "parses a string timestamp" do
      assert_equal User.last.created_at.to_time.change(usec: 0), UsersController.new.send(:date_or_time_from, User.last.created_at.to_s)
    end

    test "raises on invalid date or time" do
      assert_raises UsersController::InvalidDateOrTime, "space_cats" do
        UsersController.new.send(:date_or_time_from, "space_cats")
      end
    end
  end

  private

  def login_as(user)
    post login_path, params: { email: user.email, password: "secret" }
  end
end
