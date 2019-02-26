class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.belongs_to :post, index: true
      t.belongs_to :user, index: true
      t.text :content
      
      t.timestamps
    end

    create_table :posts do |t|
      t.belongs_to :user, index: true
      t.text :title
      t.text :content
      
      t.timestamps
    end

    create_table :users do |t|
      t.text :name
      t.text :phone
      
      t.timestamps
    end
  end
end
