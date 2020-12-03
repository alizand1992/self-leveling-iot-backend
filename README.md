# README
#### This is the backend service for the Portal application of the self leveling IoT Device.  

## Backend
* Ruby version
  * 2.7.0

* System dependencies
  * OS: Ubuntu 20.04 
  
* Setup
  * Install ruby 2.7.0 using rvm
  * clone repository into your desired directory
  * go to the repository path
  * rvm 2.7.0 do gem install rails
  * rvm 2.7.0 do gem install bundle
  * rvm 2.7.0 do bundle (Please note that this will take a while)

* Database creation/initialization/migration
  * Setup encrypted database credentials according to instructions:
    * https://medium.com/@kirill_shevch/encrypted-secrets-credentials-in-rails-6-rails-5-1-5-2-f470accd62fc
  * rails db:setup
  * rails db:migrate

* How to run the test suite
  * go into the project directory
  * `rspec` or `rspec -f d` for verbose output.

## AWS:
#### The JS lambda functions are located in the AWS directory within this repositories. 

* Create a lambda function for each of the files in the AWS directory
  * Lambda functions that use DynamoDB need permissions in IAM to read/write from/to DynamoDB
  * Lambda functions that publish to a topic need permissions in IAM to access IoTClient
  
* API gateway needs to be setup for the lambda functions that need to be accessed by the backend service.
  * Please set this up according to your project needs and settings.

* Database:
  * Create a DynamoDB table called `devices`
  
* IoT Core:
  * Create a `thing` for every leveling device that you'd like to run.
  * Please be sure to generate the Certificate and add the appropriate policy to allow it to publish and subscribe to the topic. 
