# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
  * MRI 3.0.0

* System dependencies
  * PostgreSQL 13.3 or higher

* Services <!-- (job queues, cache servers, search engines, etc.) -->
  * Uses Delayed Job for background tasks

* Capistrano deployment
  1. Install basic dependencies
    * Postgres server (local or remote)
    * rvm + Ruby version
    * NodeJS + Yarn
    * Postgres devel package

  2. Ensure ssh key exists and is available
    ```
    ~/.ssh/wallet-status.pem
    ```

  3. Login to the psql shell with root privileges
    ```
    CREATE DATABASE eve_industrial_production;
    CREATE USER eve_industrial WITH ENCRYPTED PASSWORD '<secure-password>';
    GRANT ALL PRIVILEGES ON DATABASE eve_industrial_production TO eve_industrial;
    ```

  4. Copy SPECIAL? files. Assuming that:
    * The cap deploy_to dir is `~/eve_industrial`
    * The domain is `eve_industrial.wikifuentes.com`
    ```
    mkdir -p ~/eve_industrial/shared/config

    # Copies the master key to decrypt rails secrets
    scp -i ~/.ssh/wikifuentes.pem config/master.key ec2-user@eve-industrial.wikifuentes.com:~/eve_industrial/shared/config

    # Sets up the puma service
    scp -i ~/.ssh/wikifuentes.pem ops/eve_industrial.conf ec2-user@eve-industrial.wikifuentes.com:/etc/nginx/conf.d

    # Sets up Nginx
    scp -i ~/.ssh/wikifuentes.pem ops/puma_eve_industrial.service ec2-user@eve-industrial.wikifuentes.com:/etc/systemd/system
    ```

  5. Deploy!
    ```
    cap production deploy
    ```

  6. Now ssh to the server `ssh -i ~/.ssh/wikifuentes.pem ec2-user@eve-industrial.wikifuentes.com` and
    * Create and setup the SSL certificate https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SSL-on-amazon-linux-2.html#letsencrypt

    * Patch app files permissions (This is lazy way, for safe way app should be outside home, like `/var/www/`)
      ```
      chmod +x ~
      chmod +x ~/eve_industrial -R
      ```

    * `sudo service nginx restart`

* Database initialization
    ```
    cd ~/eve_industrial/current
    RAILS_ENV="production" bundle exec rails db:seed
    ```

<!-- * Configuration -->

<!-- * How to run the test suite -->
