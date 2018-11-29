class CreateResources < ActiveRecord::Migration[5.2]
  def change
    create_table :resources do |t|
      t.string :object_id
      t.string :object_type
      t.string :http_etag
      t.datetime :http_last_modified
      t.string :fixity_md5

      t.timestamps
    end

    add_index :resources, :object_id, unique: true
  end
end
