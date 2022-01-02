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
  * To get the server up and running with capistrano:
    ```
    cap production secrets_yml:setup
    cap production puma:nginx_config
    cap production puma:systemd:config puma:systemd:enable
    cap production deploy:initial
    cap production puma:start
    ```
* ...
