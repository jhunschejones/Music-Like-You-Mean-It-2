class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :site_role, default: "user"
      t.bigint :workshop_page_views, default: 0

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
