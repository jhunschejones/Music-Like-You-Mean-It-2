require "test_helper"

# bundle exec ruby -Itest test/controllers/tags_controller_test.rb
class TagsControllerTest < ActionDispatch::IntegrationTest
  describe "admin authentication" do
    describe "when no user is logged in" do
      test "user is blocked from deleting tags" do
        assert_no_difference "Tag.count" do
          delete tag_path(tags(:mixing_1), format: :turbo_stream)
        end
        assert_redirected_to login_path
      end
    end

    describe "when a site user is logged in" do
      before do
        login_as(users(:site_user))
      end

      test "user is blocked from deleting tags" do
        assert_no_difference "Tag.count" do
          delete tag_path(tags(:mixing_1), format: :turbo_stream)
        end
        assert_redirected_to login_path
      end
    end

    describe "when site admin is logged in" do
      before do
        login_as(users(:site_admin))
      end

      test "admin can delete tags" do
        assert_difference "Tag.count", -1 do
          delete tag_path(tags(:mixing_1), format: :turbo_stream)
        end
      end
    end
  end

  def login_as(user)
    post login_path, params: { email: user.email, password: "secret" }
  end
end
