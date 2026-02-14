FactoryBot.define do
  factory :suggestion do
    association :conversation
    positive_text { "ゆっくり歩こうね" }
    is_selected { false }
  end
end
