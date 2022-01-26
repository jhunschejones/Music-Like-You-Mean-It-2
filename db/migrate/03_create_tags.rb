class CreateTags < ActiveRecord::Migration[7.0]
  def change
    create_table :tags do |t|
      t.references :blog, null: false, foreign_key: {on_delete: :cascade}
      t.string :text, null: false

      t.timestamps
    end

    add_index :tags, [:blog_id, :text], unique: true
  end
end
