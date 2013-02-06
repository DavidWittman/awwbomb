# awwbomb

A Sinatra app to display random images from a [Rackspace Cloud Files](http://www.rackspace.com/cloud/files/) container. The [awwbomb](http://awwbomb.herokuapp.com) itself scrapes images from [r/aww](http://reddit.com/r/aww). Originally inspired by Alex Godin's [corgibomb](https://github.com/alexgodin/corgibomb).

## Deployment

For easy deployment of awwbomb, use either of the following methods:
* Using Chef, with the [awwbomb-cookbook](https://github.com/DavidWittman/awwbomb-cookbook)
* On [Heroku](https://www.heroku.com)

## Configuration

Relies on Rackspace Cloud Files to store and deliver the images, and expects the following environment variables to be set:

| **Variable Name** | **Description** |
|:------------------|:----------------|
|CF_USERNAME|Cloud Files Username|
|CF_APIKEY|Cloud Files API Key|
|CF_CONTAINER|Cloud Files Container|

