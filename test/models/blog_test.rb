require "test_helper"

# bundle exec ruby -Itest test/models/blog_test.rb
class BlogTest < ActiveSupport::TestCase
  test "formats the named url before save" do
    blog = Blog.create!(
      title: "A new blog about cool things",
      named_url: " a NEW blog about cool Things "
    )
    assert_equal "a-new-blog-about-cool-things", blog.named_url
  end
end
