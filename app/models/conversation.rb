class Conversation < ApplicationRecord
  validates :original_text, presence: true, length: { maximum: 255 }

  belongs_to :user
end
