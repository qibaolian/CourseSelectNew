# This migration comes from inform (originally 20161229063039)
class CreateInformArticles < ActiveRecord::Migration
  def change
    create_table :inform_articles do |t|
      t.string :title
      t.text :text

      t.timestamps null: false
    end
  end
end
