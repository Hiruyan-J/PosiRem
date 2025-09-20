# == Schema Information
#
# Table name: suggestions
#
#  id              :bigint           not null, primary key
#  is_selected     :boolean          default(FALSE)
#  positive_text   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  conversation_id :bigint           not null
#
# Indexes
#
#  index_suggestions_on_conversation_id  (conversation_id)
#
# Foreign Keys
#
#  fk_rails_...  (conversation_id => conversations.id)
#
class Suggestion < ApplicationRecord
  validates :positive_text, presence: true, length: { maximum: 255 }

  belongs_to :conversation
end
