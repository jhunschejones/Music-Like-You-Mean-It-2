require 'test_helper'

# bundle exec ruby -Itest test/controllers/sessions_controller_test.rb
class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "admin login" do
    https!
    get login_path
    assert_response :success

    post login_path, params: { email: users(:site_admin).email, password: "secret" }
    follow_redirect!
    assert_equal blogs_path, path
  end

  test "logout" do
    login_as(users(:site_admin))
    delete logout_path
    follow_redirect!
    assert_equal "Succesfully logged out", flash[:notice]
    assert_equal login_path, path
  end

  private

  def login_as(user)
    post login_path, params: { email: user.email, password: "secret" }
  end
end
