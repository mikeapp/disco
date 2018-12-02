![Build Status](https://travis-ci.org/mikeapp/disco.svg?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/mikeapp/disco/badge.svg?branch=master)](https://coveralls.io/github/mikeapp/disco?branch=master)
# Disco: Change Notification Server     

This application is a Ruby on Rails implementation of the [IIIF Change Discovery API](https://iiif.io/api/discovery/0).
It supports a [Level 2](https://iiif.io/api/discovery/0.2/#level-2-complete-change-list) implementation, including publication of `Create`, `Update`, and `Delete` events. 
The application can be used to monitor the state of IIIF Manifests through periodic fixity checks via HTTP.

## Getting Started

```ruby
rake db:migrate
rake db:seed
rails server
```
The application uses ActiveJob and Resque to queue fixity checks; 
[Redis](https://redis.io) is required.  Be sure to start a worker to process 
 the background jobs. If performing fixity checks on third party 
 resources be mindful of the load placed on others' servers if you increase 
 the number of concurrent workers.

## Registering Manifests

There are a few ways to register manifests with the application:
- Individually via the `add_resource` Rake task, supplying the `id` and `type` as parameters:
```$ruby
  rake disco:add_resource[https://example.org/manifest/1,Manifest]
```
- In bulk by POSTing a list or resources to the `/resource` endpoint.  If an `id` value already exists in the database 
it will be skipped.  The call will return JSON document that lists the newly created resources.  In order 
to use this method, an authorization key must be configured 
(see _Configuring an Authorization Key_ below).
 The format of both the input and response is: 
```$json
[
    {
      "id": "https://example.org/manifest/1",
      "type": "Manifest"
    },
    {
      "id": "https://example.org/manifest/2",
      "type": "Manifest"
    }
 ]
```

## Populating the Activity Stream

To populate the ActivityStream, you may trigger a fixity check 
of the resources by one of the following methods:

- Individually via the `check_resource` Rake task:
```$ruby
 rake disco:check_resource[https://example.org/manifest/1]
```

- Queue a check of all resources the via the `check_all_resources` Rake task.
 ```$ruby
  rake disco:check_all_resources
 ```
 
- Posting data to the `/resource/refresh` endpoint.  This expects a JSON document 
in the format shown above, although the `type` is optional and 
ignored for the purposes of a refresh. In order to use this method, an authorization key must be configured
 (see _Configuring an Authorization Key_ below).
 
## Fixity Checks

When performing an initial check on a resource the application will calculate an 
MD5 checksum.  It will also record the `Etag` and `Last-Modified` headers, if 
received from the server.  For subsequent checks the application will perform a 
conditional GET, if either the `ETag` or `Last-Modified` values were supplied. 
If the GET returns the resource, the application will calculate the MD5 and 
peformed a comparison with the stored checksum value. 
  
## Viewing the Activity Stream

The `OrderedCollection` will be published to `/activity/all`, while the `OrderedCollectionPage` instances will be 
published at `/activity/page/0`, `/activity/page/1`, etc.  Examples:
- [OrderedCollection](https://discovery-beta.herokuapp.com/activity/all)
- [OrderedCollectionPage](https://discovery-beta.herokuapp.com/activity/page/0)

## Configuring an Authorization Key
 
To enable the API, set the environment variable `BASIC_AUTH_PASSWORD` to the desired secret key.
When POSTing data, set the `Authorization` header to the key, for example:
```bash
curl -H "Authorization: mysecretkeyvalue" ...
``` 
