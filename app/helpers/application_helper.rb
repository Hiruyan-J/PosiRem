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
    title.present? ? "#{base_title} | #{title}" : base_title
  end

  def page_top_title(title = nil)
    render "shared/page_top_title", title: title
  end

  def default_meta_tags
    {
      site: "PosiRem!",
      title: "子供への注意言葉をポジティブに変えるアプリ",
      reverse: false,
      charset: "utf-8",
      description: "PosiRem!では、生成AIで子供への注意言葉をポジティブに変換するお手伝いをします。",
      keywords: "子供,子育て,育児,幼児,ポジティブ,変換,AI",
      canonical: request.original_url,
      separator: "|",
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: request.original_url,
        image: image_url("PosiRem_OGP.png"),
        local: "ja-JP"
      },
      twitter: {
        card: "summary_image",
        site: "@obvyamdrss",
        image: image_url("PosiRem_OGP.png")
      }
    }
  end
end
