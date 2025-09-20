class CreateSuggestions < ActiveRecord::Migration[7.2]
  def change
    create_table :suggestions do |t|
      t.references :conversation, null: false, foreign_key: true
      t.string :positive_text, null: false
      t.boolean :is_selected, default: false
      t.timestamps
    end
  end
end
