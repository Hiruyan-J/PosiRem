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

  def page_heading(title = nil)
    render "shared/page_heading", title: title
  end

  def default_meta_tags
    {
      site: "PosiRem!",
      title: content_for?(:title) ? content_for(:title) : "",
      reverse: false,
      charset: "utf-8",
      description: "「つい強く言ってしまう…」そんな後悔を減らしたいママ・パパへ。PosiRem!は、子供への注意言葉をやさしく言い換えるAIアプリです。今日から、もっと笑顔で伝えられる子育てを。",
      keywords: "子育て,育児,幼児,ポジティブ,言い換え,AI,声かけ,しつけ,親子コミュニケーション,優しい言い方,注意の言葉,ポジティブ育児,ママ,パパ,AIアプリ",
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
        card: "summary",
        image: image_url("PosiRem_OGP.png")
      }
    }
  end
end
