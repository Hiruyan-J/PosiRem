class Suggestion < ApplicationRecord
  validates :positive_text, presence: true, length: { maximum: 255 }

  belongs_to :conversation
end
