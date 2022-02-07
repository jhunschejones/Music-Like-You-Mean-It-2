require "test_helper"

# bundle exec ruby -Itest test/controllers/static_pages_controller_test.rb
class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  describe "workshop" do
    describe "on the users first page visit" do
      test "loads the new workshop user page" do
        get workshop_path
        assert_response :success
        assert_select "h2.title", /Sign up/
      end
    end

    describe "on the users second page visit" do
      describe "when the user is already authenticated" do
        before do
          post workshop_users_path, params: { user: { name: "Riley", email: "riley@dafox.com" } }
        end

        test "loads the workshop page directly" do
          get workshop_path
          assert_response :success
          assert_select "h2.workshop-title"
        end

        test "increments workshop_page_views for the user" do
          riley = User.where(email: "riley@dafox.com").first

          assert_equal 0, riley.workshop_page_views
          get workshop_path
          riley.reload
          assert_equal 1, riley.workshop_page_views
        end
      end

      describe "when the user is not yet authenticated" do
        describe "with a valid workshop key" do
          test "authenticates the user" do
            get workshop_path(id: users(:site_user).workshop_key)
            assert_equal users(:site_user).id, session[:user_id]
          end

          test "redirects to the workshop page" do
            get workshop_path(id: users(:site_user).workshop_key)
            follow_redirect!
            assert_select "h2.workshop-title"
          end

          test "increments workshop_page_views for the user" do
            assert_equal 0, users(:site_user).workshop_page_views
            get workshop_path(id: users(:site_user).workshop_key)
            follow_redirect!
            assert_equal 1, users(:site_user).reload.workshop_page_views
          end
        end

        describe "with an nivalid workshop key" do
          test "does not authenticate the user" do
            get workshop_path(id: "invalid-key")
            assert_nil session[:user_id]
          end

          test "loads the signup page with a message" do
            get workshop_path(id: "invalid-key")
            assert_response :success
            assert_select "h2.title", /Sign up/
            assert_equal "Sorry, but we couldn't find your workshop! Please follow the link from your email or enter your information on the signup form.", flash[:notice]
          end
        end
      end
    end
  end
end
