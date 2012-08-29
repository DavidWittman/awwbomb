# awwbomb

A Sinatra app to display a random image scraped from [r/aww](http://reddit.com/r/aww). Written to be deployed on [Heroku](https://www.heroku.com) and originally inspired by Alex Godin's [corgibomb](https://github.com/alexgodin/corgibomb).

## Configuration

Relies on Rackspace Cloud Files to store and deliver the images, and expects the following environment variables to be set:

| **Variable Name** | **Description** |
|:------------------|:----------------|
|CF_USERNAME|Cloud Files Username|
|CF_APIKEY|Cloud Files API Key|
|CF_CONTAINER|Cloud Files Container|

