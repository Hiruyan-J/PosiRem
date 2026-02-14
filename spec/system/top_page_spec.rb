require "rails_helper"

RSpec.describe "トップページ", type: :system do
  it "未ログイン状態でトップページにアクセスできること" do
    visit root_path
    expect(page).to have_content("「〜しないで」を「〜しようね」に。")
    expect(page).to have_link("始める")
  end

  it "「始める」ボタンをクリックするとログインページにリダイレクトされること" do
    visit root_path
    click_link "始める"
    expect(page).to have_current_path(new_user_session_path)
  end
end
