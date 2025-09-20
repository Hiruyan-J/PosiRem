class ConversationsController < ApplicationController
  def index
    @conversations = current_user.conversations.order(created_at: :asc)
    @conversation = current_user.conversations.build
    @suggestion = @conversation.suggestions.build
  end

  def create
    @conversation = current_user.conversations.build(conversation_params)
    if @conversation.save
      # AIへのリクエスト処理（非同期ジョブを推奨）
      # 1. フォームから食材の文字列を受け取る
      original_text = params[:original_text]

      # 2. AIへの指示（プロンプト）を作成する。今回はJSON形式での出力を厳密に指示する。
      prompt = <<-PROMPT
      あなたは、保育園の優秀な先生です。
      幼児に向けて、注意を促したいです。
      以下の注意の言葉をポジティブな言葉(実際にして欲しい行動)に変換してください。
      【変換して欲しい言葉】
      「#{original_text}」

      【例】
      「走らないで」→「ゆっくり歩こうね」
      「触らないで」→「見るだけにしようね」

      以下のJSON形式で、キーや値の型も完全に守って応答し、変換後の言葉を3つ提案して下さい。

      {
        "positive_texts": [
          "変換後の言葉1",
          "変換後の言葉2",
          "変換後の言葉3"
        ]
      }
      PROMPT

      # 3. OpenAI APIクライアントを初期化する
      client = OpenAI::Client.new

      begin
        # 4. APIにリクエストを送信する。JSONモードを有効にする。
        response = client.chat(
          parameters: {
            # model: 使用するAIモデルを指定します。
            # "gpt-4o-mini"は、高速かつ低コストでありながら高い性能を持つ最新モデルの一つです。
            model: "gpt-4o-mini",

            # messages: AIに渡す指示や会話の履歴を配列で指定します。
            # role: "user"は、ユーザーからの発言であることを示します。
            # content: ここに具体的な指示（プロンプト）を渡します。
            messages: [{ role: "user", content: prompt }],

            # response_format: AIの応答形式を指定します。
            # { type: "json_object" }とすることで、AIは必ず有効なJSONオブジェクトを返すようになります。
            response_format: { type: "json_object" },

            # temperature: 応答のランダム性（創造性）を制御します。0に近いほど決定的で、2に近いほど多様な応答になります。
            # 0.7は、ある程度の創造性を保ちつつ、安定した応答を得やすい一般的な値です。
            temperature: 0.7,
          }
        )

        # 5. AIからのJSON応答をパースし、インスタンス変数に格納する
        raw_positive_texts = response.dig("choices", 0, "message", "content")
        positive_texts = JSON.parse(raw_positive_texts)
        positive_texts.each do |text|
          @conversation.suggestions.create!(positive_text: text)
        end
      rescue OpenAI::Error => e
        # APIエラーが発生した場合の処理
        @error_message = "AIとの通信中にエラーが発生しました： #{e.message}"
      rescue JSON::ParserError => e
        # JSONのパースに失敗した場合の処理
        @error_message = "AIからの応答を正しく解析できませんでした。もう一度お試しください。"
      end

      # createアクションの後、indexテンプレートを再描画する
      # これにより、@suggestions変数がindex.html.erbで使用可能に
      @conversations = current_user.conversations.order(created_at: :asc)
      render :index, status: :ok
      # AIManager.generate_suggestions(@conversation)
      # redirect_to conversations_path, notice: "AIに言い換えを依頼しました！"
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def conversation_params
    params.require(:conversation).permit(:original_text)
  end
end
