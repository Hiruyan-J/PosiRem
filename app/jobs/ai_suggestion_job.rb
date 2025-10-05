class AiSuggestionJob < ApplicationJob
  queue_as :default

  def perform(conversation_id)
    conversation = Conversation.find(conversation_id)

    begin
      # APIにリクエストを送信。JSONモードを有効化。
      raw_suggestions = call_ai_api(conversation.original_text)

      # AIの返答をパース・DBに格納
      suggestions = JSON.parse(raw_suggestions)
      suggestions["positive_texts"].each do |text|
        conversation.suggestions.create!(positive_text: text)
      end

      # raise StandardError, "test error"

      # Turbo Streamで結果を配信
      broadcast_ai_response(conversation)

    rescue OpenAI::Error => e
      # APIエラーが発生した場合の処理
      error_message = "AIとの通信中にエラーが発生しました。もう一度お試しください。"
      broadcast_ai_error(conversation, e, error_message)
    rescue JSON::ParserError => e
      # JSONのパースに失敗した場合の処理
      error_message = "AIからの応答を正しく解析できませんでした。もう一度お試しください。"
      broadcast_ai_error(conversation, e, error_message)
    rescue StandardError => e
      error_message = "予期しないエラーが発生しました。しばらく時間をおいて再度お試しください。"
      broadcast_ai_error(conversation, e, error_message)
    end
  end

  private

  def call_ai_api(original_text)
    prompt = build_prompt(original_text)
    # OpenAI APIクライアントを初期化する
    client = OpenAI::Client.new

    response = client.chat(
      parameters: {
        # model: 使用するAIモデルを指定
        model: "gpt-4o-mini",

        # messages: AIに渡す指示や会話の履歴を配列で指定
        # role: "user"ユーザーからの発言である意味
        # content: プロンプト渡す
        messages: [ { role: "user", content: prompt } ],

        # response_format: AIの応答形式を指定
        # { type: "json_object" }…AIは必ず有効なJSONオブジェクトを返す
        response_format: { type: "json_object" },

        # temperature: 応答のランダム性（創造性）の制御。0に近いほど決定的。2に近いほど多様な応答。
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")
  end

  def build_prompt(original_text)
    # AIへの指示（プロンプト）を作成。今回はJSON形式での出力を厳密に指示する。
    prompt = <<-PROMPT
      あなたは、乳幼児心理学を学んだ保育園の先生です。
      幼児に向けて、禁止の言葉ではなく「実際にやってほしい行動」や「子どもが選べる前提の言葉」に言い換えて伝えてください。
      大切なのは、子どもが安心して行動できるようにポジティブでわかりやすい言葉にすることです。
      また、幼児が楽しくイメージできるように「動物」「ヒーロー」「身近なもの」などの分かりやすい例えを入れることもできますが、
      出力の5つの内、必要に応じて0～2つに例えを入れてください。他の出力はシンプルで分かりやすい表現にしてください。

      【変換してほしい言葉】
      「#{original_text}」

      【変換のポイント】
      ・「〜しないで」という禁止表現を避ける。
      ・「〜しようね」「〜してみよう」のように、やって欲しい行動を示す。
      ・必要に応じて「どっちがいい？」など選択肢を与える形にする。
      ・幼児が理解しやすく、優しい言葉を使う。
      ・動物・キャラクター・ごっこ遊びなどの例えを取り入れて、子どもが楽しく想像できるようにする。

      【例】
      「走らないで」→「ゆっくり歩こうね」
      「触らないで」→「見るだけにしようね」
      「騒がないで」→「リスさんにお話しするみたいに、コソコソ話にしようね」
      「ドタドタしないで」→「忍者みたいにソロリソロリに歩こうね」
      「お風呂に入って」→「今日はアヒルさんと遊ぶ？それともお船で遊ぶ？」
      「歯磨きをして」→「今日はパパとママのどっちに歯磨きしてもらう？」

      【出力形式】
      必ず以下のJSON形式で、キーや値の型を正確に守り、変換後の言葉を5つ提案してください。

      {
      "positive_texts": [
      "変換後の言葉1",
      "変換後の言葉2",
      "変換後の言葉3",
      "変換後の言葉4",
      "変換後の言葉5"
      ]
      }
    PROMPT
  end

  def broadcast_ai_response(conversation)
    # 思考中メッセージを削除
    broadcast_remove_thinking_message(conversation)

    # AIの回答を追加
    Turbo::StreamsChannel.broadcast_append_to(
      "user_#{conversation.user_id}",
      target: "chat-messages",
      partial: "conversations/ai_response",
      locals: { conversation: conversation }
    )
  end

  def broadcast_ai_error(conversation, exception, error_message)
    # 思考中メッセージを削除
    broadcast_remove_thinking_message(conversation)

    # ActiveRecord のエラーがあればそれを表示、なければ引数の error_message を表示
    # errors = conversation.errors.any? ? conversation.errors : [OpenStruct.new(full_message: error_message)]

    # binding.pry
    # エラーメッセージを表示
    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{conversation.user_id}",
      target: "ai_error_messages",
      partial: "shared/ai_error_messages",
      locals: { error_message: error_message }
    )

    # ログの出力
    Rails.logger.error "#{exception.class}: #{exception.message}"
    Rails.logger.error "Request details: #{conversation.original_text}"
  end

  def broadcast_remove_thinking_message(conversation)
    # 思考中メッセージを削除
    Turbo::StreamsChannel.broadcast_remove_to(
      "user_#{conversation.user_id}",
      target: "ai-thinking-#{conversation.id}"
    )
  end
end
