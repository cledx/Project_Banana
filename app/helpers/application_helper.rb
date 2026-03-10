module ApplicationHelper
  def render_markdown(text)
    Kramdown::Document.new(text, input: 'GFM', syntax_highlighter: "rouge").to_html
  end

  def on_weeks_new?
    params[:controller] == "weeks" && params[:action] == "new"
  end
end
