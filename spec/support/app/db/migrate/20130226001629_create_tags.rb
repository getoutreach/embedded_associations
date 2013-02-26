class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.references :post
      t.string :name
      t.timestamps
    end
  end
end
