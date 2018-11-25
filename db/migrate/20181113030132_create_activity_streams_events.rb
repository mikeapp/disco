class CreateActivityStreamsEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_streams_events do |t|
      t.integer :event_type_id
      t.string :object_id
      t.string :object_type
      t.timestamp :end_time, index: true

      t.timestamps
    end
  end
end
