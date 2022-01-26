module BlogHelper
  def truncate_after_two_paragraphs(action_text_rich_text)
    Nokogiri::HTML::DocumentFragment.parse(action_text_rich_text.body.to_html).children[0..1].to_html
  end
end
