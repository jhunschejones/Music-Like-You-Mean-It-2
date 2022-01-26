require 'test_helper'

# bundle exec ruby -Itest test/controllers/blogs_controller_test.rb
class BlogsControllerTest < ActionDispatch::IntegrationTest
  describe "admin authentication" do
    describe "when no user is logged in" do
      test "user is blocked from the new blog page" do
        get new_blog_path
        assert_redirected_to login_path
      end

      test "user is blocked from the edit blog page" do
        get edit_blog_path(blogs(:mixing_snare))
        assert_redirected_to login_path
      end

      test "user is blocked from the blogs admin page" do
        get blogs_path
        assert_response :success
        assert_select "h2.title", { text: /All blogs/, count: 0 }, "User should not be able to access blogs admin page"
      end

      test "user is blocked from seeing draft blog" do
        blogs(:mixing_snare).update(is_draft: true)
        get blog_path(blogs(:mixing_snare))
        assert_redirected_to blogs_path
      end

      test "user can view blogs" do
        get blogs_path
        assert_response :success
        assert_select "h2.title", blogs(:mixing_snare).title
      end

      test "user can view blog" do
        get blog_path(blogs(:mixing_snare))
        assert_response :success
        assert_select "h2.title", blogs(:mixing_snare).title
      end

      test "user is blocked from creating blogs" do
        assert_no_difference 'Blog.count' do
          post blogs_path, params: { blog: { title: "My New Blog" } }
        end
        assert_redirected_to login_path
      end

      test "user is blocked from updating blogs" do
        assert_no_changes -> { Blog.find(blogs(:mixing_snare).id).title } do
          patch blog_path(blogs(:mixing_snare)), params: { blog: { title: "Change The Title" } }
        end
        assert_redirected_to login_path
      end
    end

    describe "when site user is logged in" do
      before do
        login_as(users(:site_user))
      end

      test "user is blocked from the new blog page" do
        get new_blog_path
        assert_redirected_to login_path
      end

      test "user is blocked from the edit blog page" do
        get edit_blog_path(blogs(:mixing_snare))
        assert_redirected_to login_path
      end

      test "user is blocked from the blogs admin page" do
        get blogs_path
        assert_response :success
        assert_select "h2.title", { text: /All blogs/, count: 0 }, "User should not be able to access blogs admin page"
      end

      test "user is blocked from seeing draft blog" do
        blogs(:mixing_snare).update(is_draft: true)
        get blog_path(blogs(:mixing_snare))
        assert_redirected_to blogs_path
      end

      test "user can view blogs" do
        get blogs_path
        assert_response :success
        assert_select "h2.title", blogs(:mixing_snare).title
      end

      test "user can view blog" do
        get blog_path(blogs(:mixing_snare))
        assert_response :success
        assert_select "h2.title", blogs(:mixing_snare).title
      end

      test "user is blocked from creating blogs" do
        assert_no_difference 'Blog.count' do
          post blogs_path, params: { blog: { title: "My New Blog" } }
        end
        assert_redirected_to login_path
      end

      test "user is blocked from updating blogs" do
        assert_no_changes -> { Blog.find(blogs(:mixing_snare).id).title } do
          patch blog_path(blogs(:mixing_snare)), params: { blog: { title: "Change The Title" } }
        end
        assert_redirected_to login_path
      end
    end

    describe "when site admin is logged in" do
      before do
        login_as(users(:site_admin))
      end

      test "user can access new blog page" do
        get new_blog_path
        assert_response :success
        assert_select "h2.title", "New blog"
      end

      test "user can access edit blog page" do
        get edit_blog_path(blogs(:mixing_snare))
        assert_response :success
        assert_select 'form input[name="blog[title]"][value=?]', blogs(:mixing_snare).title
      end

      test "user can access blogs admin page" do
        get blogs_path
        assert_response :success
        assert_select "h2.title", /All blogs/
      end

      test "user can access draft blogs" do
        blogs(:mixing_snare).update(is_draft: true)
        get blog_path(blogs(:mixing_snare))
        assert_response :success
        assert_select "h2.title", blogs(:mixing_snare).title
      end

      test "user can view blog" do
        get blog_path(blogs(:mixing_snare))
        assert_response :success
        assert_select "h2.title", blogs(:mixing_snare).title
      end

      test "user can create blogs" do
        assert_difference 'Blog.count', 1 do
          post blogs_path, params: { blog: { title: "My New Blog" } }
        end
      end

      test "user can update blogs" do
        refute_equal "Change The Title", Blog.find(blogs(:mixing_snare).id).title
        assert_changes -> { Blog.find(blogs(:mixing_snare).id).title } do
          patch blog_path(blogs(:mixing_snare)), params: { blog: { title: "Change The Title" } }
        end
        assert_equal "Change The Title", Blog.find(blogs(:mixing_snare).id).title
      end
    end
  end

  private

  def login_as(user)
    post login_path, params: { email: user.email, password: "secret" }
  end
end
