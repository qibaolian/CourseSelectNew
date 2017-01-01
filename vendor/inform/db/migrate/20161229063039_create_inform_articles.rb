class CreateInformArticles < ActiveRecord::Migration
  def change
    create_table :inform_articles do |t|
      t.string :title
      t.text :text

      t.timestamps null: false
    end
  end
end
