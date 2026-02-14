require "rails_helper"

RSpec.describe "ログイン・ログアウト", type: :system do
  let(:user) { create(:user, email: "login@example.com", password: "password123") }

  describe "ログイン" do
    it "有効な情報でログインできること" do
      visit new_user_session_path

      fill_in "Eメール", with: user.email
      fill_in "パスワード", with: "password123"
      click_button "ログイン"

      expect(page).to have_current_path(conversations_path(format: :html))
    end

    it "無効な情報ではログインできないこと" do
      visit new_user_session_path

      fill_in "Eメール", with: user.email
      fill_in "パスワード", with: "wrongpassword"
      click_button "ログイン"

      expect(page).to have_content("Eメールまたはパスワードが違います。")
    end
  end

  describe "ログアウト" do
    it "ログアウトできること" do
      visit new_user_session_path
      fill_in "Eメール", with: user.email
      fill_in "パスワード", with: "password123"
      click_button "ログイン"

      expect(page).to have_current_path(conversations_path(format: :html))
      click_link "ログアウト"

      expect(page).to have_content("ログアウトしました")
      expect(page).to have_link("ログイン")
    end
  end
end
