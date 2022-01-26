require "test_helper"

# bundle exec ruby -Itest test/models/tag_test.rb
class TagTest < ActiveSupport::TestCase
  test "formats tag text on save" do
    tag = Tag.create!(
      text: " A tAg with WEIRD formatting ",
      blog: blogs(:mixing_snare)
    )
    assert_equal "A tag with weird formatting", tag.text
  end
end
