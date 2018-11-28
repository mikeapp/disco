class CreateResources < ActiveRecord::Migration[5.2]
  def change
    create_table :resources do |t|
      t.string :object_id
      t.string :object_type
      t.string :etag
      t.datetime :object_last_update

      t.timestamps
    end

    add_index :resources, :object_id, unique: true
  end
end
