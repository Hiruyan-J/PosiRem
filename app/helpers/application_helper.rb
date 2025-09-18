module ApplicationHelper
  # DeviseなどのflashタイプをDaisyUIのクラス名に変換する
  def flash_class_for(type)
    case type.to_s
    when "notice"
      "success"
    when "alert"
      "error"
    else
      type.to_s
    end
  end

  def page_title(title = "")
    base_title = "PosiRem!"
    title.present? ? "#{title} | #{base_title}" : base_title
  end

  def page_top_title(title = nil)
    render "shared/page_top_title", title: title
  end
end
