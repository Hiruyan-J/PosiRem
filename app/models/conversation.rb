# == Schema Information
#
# Table name: conversations
#
#  id            :bigint           not null, primary key
#  original_text :text             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_conversations_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Conversation < ApplicationRecord
  validates :original_text, presence: true, length: { maximum: 65_535 }

  belongs_to :user
  has_many :suggestions, dependent: :destroy
end
