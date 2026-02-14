require "rails_helper"

RSpec.describe Suggestion, type: :model do
  describe "バリデーション" do
    it { is_expected.to validate_presence_of(:positive_text) }
    it { is_expected.to validate_length_of(:positive_text).is_at_most(255) }
  end

  describe "アソシエーション" do
    it { is_expected.to belong_to(:conversation) }
  end

  describe "デフォルト値" do
    it "is_selected のデフォルトが false であること" do
      suggestion = create(:suggestion)
      expect(suggestion.is_selected).to be false
    end
  end
end
