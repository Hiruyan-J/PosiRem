module ApplicationHelper
  def page_title(title = "")
    base_title = "PosiRem!"
    title.present? ? "#{title} | #{base_title}" : base_title
  end

  def page_top_title(title = nil)
    render "shared/page_top_title", title: title
  end
end
