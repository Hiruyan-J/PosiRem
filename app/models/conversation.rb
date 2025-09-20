class Conversation < ApplicationRecord
  validates :original_text, presence: true, length: { maximum: 65_535 }

  belongs_to :user
  has_many :suggestions, dependent: :destroy
end
