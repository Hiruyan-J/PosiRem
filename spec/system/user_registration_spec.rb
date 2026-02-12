require "rails_helper"

RSpec.describe "ユーザー登録", type: :system do
  describe "正常な登録" do
    it "有効な情報で新規登録できること" do
      visit new_user_registration_path

      fill_in "ニックネーム", with: "テスト太郎"
      fill_in "Eメール", with: "test@example.com"
      fill_in "パスワード", with: "password123", match: :first
      fill_in "パスワード（確認用）", with: "password123"
      click_button "アカウント登録"

      expect(page).to have_current_path(conversations_path(format: :html))
    end
  end

  describe "バリデーションエラー" do
    it "名前が空の場合にエラーが表示されること" do
      visit new_user_registration_path

      fill_in "ニックネーム", with: ""
      fill_in "Eメール", with: "test@example.com"
      fill_in "パスワード", with: "password123", match: :first
      fill_in "パスワード（確認用）", with: "password123"
      click_button "アカウント登録"

      expect(page).to have_content("ニックネームを入力してください")
    end

    it "メールアドレスが空の場合にエラーが表示されること" do
      visit new_user_registration_path

      fill_in "ニックネーム", with: "テスト太郎"
      fill_in "Eメール", with: ""
      fill_in "パスワード", with: "password123", match: :first
      fill_in "パスワード（確認用）", with: "password123"
      click_button "アカウント登録"

      expect(page).to have_content("Eメールを入力してください")
    end

    it "パスワードが短すぎる場合にエラーが表示されること" do
      visit new_user_registration_path

      fill_in "ニックネーム", with: "テスト太郎"
      fill_in "Eメール", with: "test@example.com"
      fill_in "パスワード", with: "12345", match: :first
      fill_in "パスワード（確認用）", with: "12345"
      click_button "アカウント登録"

      expect(page).to have_content("パスワードは6文字以上で入力してください")
    end
  end
end
