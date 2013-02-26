class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.references :user
      t.references :category
      t.timestamps
    end
  end
end
