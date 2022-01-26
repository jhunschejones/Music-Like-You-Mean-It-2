class CreateEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :emails do |t|
      t.string :subject, null: false
      t.string :cta_text
      t.string :cta_link
      t.boolean :is_draft, default: true
      t.datetime :sent_at
      # body field is stored using ActionText and not on the model

      t.timestamps
    end
  end
end
