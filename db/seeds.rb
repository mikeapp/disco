# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

ActivityStreamsEventType.create(id: 1, event_type: 'Create')
ActivityStreamsEventType.create(id: 2, event_type: 'Update')
ActivityStreamsEventType.create(id: 3, event_type: 'Delete')
