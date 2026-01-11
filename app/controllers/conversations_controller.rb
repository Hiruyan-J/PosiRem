class ConversationsController < ApplicationController
  def index
    @conversation = current_user.conversations.build

    conversations = current_user.conversations.includes(:suggestions).order(created_at: :desc)

    if params[:before_id].present?
      conversations = conversations.where("id < ?", params[:before_id])
    end

    @conversations = conversations.limit(5).reverse

    respond_to do |format|
      format.html
      format.turbo_stream
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
