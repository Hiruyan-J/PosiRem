class ConversationsController < ApplicationController
  def index
    @conversation = current_user.conversations.build

    @conversations = current_user.conversations
                                  .includes(:suggestions)
                                  .before_id(params[:before_id])
                                  .recent_for_scroll(Conversation::CHAT_PAGE_SIZE)
                                  .reverse

    respond_to do |format|
      format.html
      format.turbo_stream do
        if @conversations.any?
          # 無限スクロールで会話を追加読み込み
          logger.debug "Loading more conversations before ID: #{params[:before_id]}"
        else
          # 無限スクロールの終端に到達した場合の処理
          render turbo_stream: turbo_stream.update("infinite-scroll-target",
            render_to_string(partial: "sentinel", locals: { message: "これ以上メッセージはありません。", all_loaded: true }))
        end
      end
    end
  end

  def create
    @conversation = current_user.conversations.build(conversation_params)
    if @conversation.save
      # AI処理をバックグラウンドジョブで実行
      AiSuggestionJob.perform_later(@conversation.id)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to conversations_path, info: "AIに言い換えを依頼しました。しばらくたってから、画面の再読み込みを行ってください。" }
      end
    else
      # バリデーションエラー時の処理
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to conversations_path, error: @conversation.errors.full_messages.join(", ") }
      end
    end
  end

  private

  def conversation_params
    params.require(:conversation).permit(:original_text)
  end
end
