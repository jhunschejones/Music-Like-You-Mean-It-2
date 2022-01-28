require 'test_helper'

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
    end
  end

  describe "POST new" do
    describe "when user is a site_user" do
      before do
        login_as(users(:site_user))
      end

      test "does not create a new user" do
        assert_no_difference 'User.count' do
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
          assert_no_difference 'User.count' do
            post users_path, params: { user: { name: users(:site_user).name, email: users(:site_user).email } }
          end
        end
      end

      describe "when a user does not exist with matching email" do
        test "creates a new user record" do
          assert_difference 'User.count', 1 do
            post users_path, params: { user: { name: "Riley", email: "riley@dafox.com" } }
          end
        end
      end
    end
  end

  describe "POST create_workshop_users" do
    describe "when a user with matching email already exists" do
      test "does not create a new user record" do
        assert_no_difference 'User.count' do
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
        assert_difference 'User.count', 1 do
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

      test "redirects to workshop path" do
        assert_redirected_to workshop_path
      end
    end

    describe "with valid unsubscribe key" do
      before do
        get unsubscribe_path(id: users(:site_user).unsubscribe_key)
      end

      test "authenticates user" do
        assert_equal users(:site_user).id, session[:user_id]
      end

      test "loads unsubscribe page" do
        assert_select 'p', /Are you sure you want to unsubscribe/
      end
    end
  end

  describe "destroy" do
    describe "when there is no authenticated user" do
      test "does not destroy user" do
        assert_no_difference 'User.count' do
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
        assert_no_difference 'User.count' do
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
        assert_difference 'User.count', -1 do
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
        assert_difference 'User.count', -1 do
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

  private

  def login_as(user)
    post login_path, params: { email: user.email, password: "secret" }
  end
end
