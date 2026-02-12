FactoryBot.define do
  factory :conversation do
    association :user
    original_text { "走らないで" }
  end
end
