class InitialTables < ActiveRecord::Migration
  def self.up

    create_table :user_review_types do |t|
      t.string :name
      t.integer :content_model_id
      t.integer :content_model_field_id
      t.string :relation_field
      t.text :user_relations
      t.timestamps
    end

    create_table :user_review_results do |t|
      t.integer :user_review_type_id
      t.integer :container_node_id
      t.integer :num_ratings
      t.integer :rating_stars
      t.decimal :rating, :precision=> 14, :scale => 2
    end

    create_table :user_review_reviews do |t|
      t.integer :user_review_type_id
      t.integer :end_user_id
      t.string :title
      t.string :permalink
      t.text :review_body
      t.integer :container_node_id
      t.integer :rating
      t.timestamps
      t.integer :approval, :default => 0
    end

    add_index :user_review_reviews, :end_user_id, :name => 'Users Reviews'
    add_index :user_review_reviews, :container_node_id, :name => 'Content Index'
  end

  def self.down
    drop_table :user_review_reviews
    drop_table :user_review_results
    drop_table :user_review_types
  end
end
