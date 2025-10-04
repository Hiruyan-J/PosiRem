class ConversationsController < ApplicationController
  def index
    @conversations = current_user.conversations.order(created_at: :asc)
    @conversation = current_user.conversations.build
  end

  def create
    @conversation = current_user.conversations.build(conversation_params)
    if @conversation.save
      # AIへのリクエスト処理（非同期ジョブを推奨）

      # AI処理をバックグラウンドジョブで実行
      AiSuggestionJob.perform_later(@conversation.id)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to conversations_path, notice: "AIに言い換えを依頼しました！" }
      end
    else
      # バリデーションエラー時の処理
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to conversations_path, alert: @conversation.errors.full_messages.join(', ') }
      end
    end
  end

  private

  def conversation_params
    params.require(:conversation).permit(:original_text)
  end
end
