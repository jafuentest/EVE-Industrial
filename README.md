# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions
  * Make sure you have installed base dependencies in your server

  * Store the appropiate ssh key on your own PC
  ```
  ~/.ssh/eve-industrial.pem
  ```

  * Run
  ```
  cap production deploy
  ```

  * Now go to your server and:
  ```
  # Assuming you installed the app on your /home/your-user/eve_industrial
  cd ~/eve_industrial/current
  
  # Sets up the puma service
  cp ./ops/puma_eve_industrial.service /etc/systemd/system
  
  # Sets up Nginx
  cp ./ops/eve_industrial.conf /etc/nginx/conf.d
  ```
  
  * Run seeds (after a successful deployment)
  ```
  cd ~/eve_industrial/current
  RAILS_ENV="production" bundle exec rails db:seed
  ```
