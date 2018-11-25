class CreateActivityStreamsEventTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_streams_event_types do |t|
      t.string :event_type
      t.timestamps
    end
  end
end
