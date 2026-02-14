require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
  end

  describe "アソシエーション" do
    it { is_expected.to have_many(:conversations).dependent(:destroy) }
  end

  describe "ユーザー作成" do
    context "有効な属性の場合" do
      it "正常に作成できること" do
        user = build(:user)
        expect(user).to be_valid
      end
    end

    context "名前が空の場合" do
      it "無効であること" do
        user = build(:user, name: "")
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include("を入力してください")
      end
    end

    context "メールアドレスが重複している場合" do
      it "無効であること" do
        create(:user, email: "duplicate@example.com")
        user = build(:user, email: "duplicate@example.com")
        expect(user).not_to be_valid
      end
    end
  end
end
