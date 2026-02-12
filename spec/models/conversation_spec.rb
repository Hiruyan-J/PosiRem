require "rails_helper"

RSpec.describe Conversation, type: :model do
  describe "バリデーション" do
    it { is_expected.to validate_presence_of(:original_text) }
    it { is_expected.to validate_length_of(:original_text).is_at_most(1_000) }
  end

  describe "アソシエーション" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:suggestions).dependent(:destroy) }
  end

  describe "定数" do
    it "CHAT_PAGE_SIZE が 5 であること" do
      expect(Conversation::CHAT_PAGE_SIZE).to eq 5
    end
  end

  describe "スコープ" do
    let(:user) { create(:user) }

    describe ".before_id" do
      it "指定したIDより小さいIDのレコードのみ取得すること" do
        conv1 = create(:conversation, user: user)
        conv2 = create(:conversation, user: user)
        conv3 = create(:conversation, user: user)

        result = Conversation.before_id(conv3.id)
        expect(result).to include(conv1, conv2)
        expect(result).not_to include(conv3)
      end

      it "IDが未指定の場合はフィルタしないこと" do
        conv1 = create(:conversation, user: user)
        conv2 = create(:conversation, user: user)

        result = Conversation.before_id(nil)
        expect(result).to include(conv1, conv2)
      end
    end

    describe ".recent_for_scroll" do
      it "作成日時の降順で指定件数を取得すること" do
        6.times { create(:conversation, user: user) }

        result = Conversation.recent_for_scroll(5)
        expect(result.size).to eq 5
        expect(result).to eq result.sort_by(&:created_at).reverse
      end
    end
  end
end
