![Build Status](https://travis-ci.org/mikeapp/disco.svg?branch=master)
![Coverage Status](https://coveralls.io/repos/github/mikeapp/disco/badge.svg?branch=master)

# Disco: Change Notification Server     

## What is this?
This application is a Ruby on Rails implementation of the [IIIF Change Discovery API](https://iiif.io/api/discovery/0). 
It supports a [Level 2](https://iiif.io/api/discovery/0.2/#level-2-complete-change-list) implementation, including publication of `Create`, `Update`, and `Delete` events.   
The application can be used to monitor the state of IIIF Manifests through periodic fixity checks via HTTP.

## Loading Manifests

There are a few ways to load manifests into the application:
- Directly via SQL
- Individually via the `add_resource` Rake task:
```$ruby
  rake disco:add_resource[https://example.org/manifest/1,Manifest]
```
- Posting data to the `/resources` endpoint.  This expects a JSON document in the following format:
```$json
{
  "items": [
    {
      "id": "https://example.org/manifest/1",
      "type": "Manifest"
    },
    {
      "id": "https://example.org/manifest/2",
      "type": "Manifest"
    }
  ]
}
```

## Populating the Activity Stream

To populate the ActivityStream, you must trigger a check of the Manifest(s):

- Individually via the `check_resource` Rake task:
```$ruby
 rake disco:check_resource[https://example.org/manifest/1]
```

- Queue a check of the entire set of Manifests via the `check_all_resources` Rake task.
 ```$ruby
  rake disco:check_all_resources
 ```
 
- Posting data to the `/resources/refresh` endpoint.  This expects a JSON document in the format shown above, although 
the `type` is optional and ignored for the purposes of a refresh.

- Directly via SQL.  Note that if you choose to populate all
  events via SQL, there is no need to load Manifests into the database, as fixity tracking will not be required.
  
## Viewing the Activity Stream

The `OrderedCollection` will be published to `/activity/all`, while the `OrderedCollectionPage` instances will be 
published at `/activity/page/0`, `/activity/page/1`, etc.    

## Notes

 - The application uses ActiveJob and Resque to queue fixity checks.  Redis is required.  Be sure to start a worker 
 to process the fixity checks.   The `Procfile` should be configured appropriately for deployment to Heroku.  It will 
 start a single thread.  If monitoring third party Manifests be sure to be mindful of others' servers if you increase 
 the number of concurrent workers.
 
