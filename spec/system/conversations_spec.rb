require "rails_helper"

RSpec.describe "会話機能", type: :system do
  def login_as_new_user
    user = create(:user)
    visit new_user_session_path
    fill_in "Eメール", with: user.email
    fill_in "パスワード", with: "password123"
    click_button "ログイン"

    # ログインが成功したことを確認
    expect(page).to have_current_path(conversations_path(format: :html))
    user
  end

  describe "会話一覧画面" do
    context "会話が存在しない場合" do
      it "オンボーディングメッセージが表示されること" do
        login_as_new_user
        expect(page).to have_content("お子さまへの注意の言葉を、テキストボックスに入力してください")
      end
    end

    context "会話が存在する場合" do
      it "会話とAI提案が表示されること" do
        user = create(:user)
        conversation = create(:conversation, user: user, original_text: "走らないで")
        create(:suggestion, conversation: conversation, positive_text: "ゆっくり歩こうね")

        visit new_user_session_path
        fill_in "Eメール", with: user.email
        fill_in "パスワード", with: "password123"
        click_button "ログイン"

        expect(page).to have_content("走らないで")
        expect(page).to have_content("ゆっくり歩こうね")
      end
    end
  end

  describe "会話の作成" do
    it "テキストを入力して送信すると会話が作成されること" do
      login_as_new_user

      fill_in "conversation[original_text]", with: "走らないで"
      click_button "送信"

      expect(page).to have_content("走らないで")
    end

    it "空のテキストで送信するとエラーになること" do
      login_as_new_user

      fill_in "conversation[original_text]", with: ""
      click_button "送信"

      # Turbo Stream でフラッシュメッセージが更新されるまで待機
      expect(page).not_to have_content("ログインしました。")
      expect(page).to have_content("エラーが発生しました")
    end

    it "1000文字を超えるテキストで送信するとエラーになること" do
      login_as_new_user

      fill_in "conversation[original_text]", with: "あ" * 1001
      click_button "送信"

      # Turbo Stream でフラッシュメッセージが更新されるまで待機
      expect(page).not_to have_content("ログインしました。")
      expect(page).to have_content("エラーが発生しました")
    end
  end
end
