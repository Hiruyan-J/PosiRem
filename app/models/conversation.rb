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
  CHAT_PAGE_SIZE = 5 # チャット画面の1ページあたりのチャット表示件数

  belongs_to :user
  has_many :suggestions, dependent: :destroy

  validates :original_text, presence: true, length: { maximum: 1_000 }

  scope :before_id, ->(id) { where("id < ?", id) if id.present? } # 指定されたIDより前のレコードを取得するスコープ
  scope :recent_for_scroll, ->(limit) { order(created_at: :desc).limit(limit) } # 無限スクロール用の最近のレコードを取得するスコープ
end
