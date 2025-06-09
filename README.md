# README

This README documents the steps are necessary to get the application up and running.

* Ruby version
  * MRI 3.3.5

* System dependencies
  * PostgreSQL 17.5 or higher

* Services <!-- (job queues, cache servers, search engines, etc.) -->
  * Uses Delayed Job for background tasks

## Capistrano deployment

1. Install basic dependencies
   * rbenv + Ruby version
   * NodeJS + Yarn
   * PostgreSQL server (asuming local install)
   * PostgreSQL devel package
   * Nginx
   * Certbot

    If using Amazon Linux 2023:

    1. Install basic dependencies
        ```
        sudo yum install git perl zlib-devel libffi-devel libyaml-devel nginx certbot python3-certbot-nginx
        ```

    1. Install Postgres 17
        ```
        sudo dnf install postgresql17 postgresql17-server libpq-devel
        ```

    1. Install rbenv with ruby-build plugin, and setup ruby 3.3.5
        ```
        git clone https://github.com/rbenv/rbenv.git ~/.rbenv
        ~/.rbenv/bin/rbenv init

        # Restart the shell to load the rbenv
        exec bash

        git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

        rbenv install 3.3.5
        ```
    1. Install NodeJS + Yarn. Probably best to check for the latest version of nvm
        ```
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        nvm install --lts
        npm install -g yarn
        ```

1. Set up the Postgres database
    1. Login to the psql shell with root privileges
        ```
        sudo /usr/bin/postgresql-setup --initdb
        sudo service postgresql start
        sudo -u postgres psql
        ```

    1. Create the database and user
        ```
        CREATE DATABASE eve_industrial_production;
        CREATE USER eve_industrial WITH ENCRYPTED PASSWORD '<secure-password>';
        GRANT ALL PRIVILEGES ON DATABASE eve_industrial_production TO eve_industrial;
        GRANT ALL ON SCHEMA public TO eve_industrial;
        ```

    1. Configure the database to allow connections from the eve_industrial user
        Find config file (in my case it was on `/var/lib/pgsql/data/pg_hba.conf`)
        ```
        sudo -u postgres psql -c "SHOW hba_file;"
        sudo vim /var/lib/pgsql/data/pg_hba.conf
        ```

        Find the IPv4 local connections block in the file and update it to look like this:
        ```
        # IPv4 local connections:
        host    eve_industrial_production eve_industrial  127.0.0.1/32  md5
        host    all             all             127.0.0.1/32            ident
        ```
        Note that it's important that eve_industrial user is listed before the all user.

1. Copy SPECIAL? files. Assuming that:
    * You ssh into the server using a key located at `~/.ssh/eve-industrial.pem`
    * The cap deploy_to dir is `~/eve_industrial`
    * The domain is `eve-industrial.wikifuentes.com`

    Create the shared config dir
    ```
    mkdir -p ~/eve_industrial/shared/config
    ```

    Copy the master key to decrypt rails secrets
    ```
    scp -i ~/.ssh/eve-industrial.pem config/master.key ec2-user@eve-industrial.wikifuentes.com:~/eve_industrial/shared/config
    ```

    Copy the nginx and puma systemd files
    ```
    scp -i ~/.ssh/eve-industrial.pem \
    ops/eve_industrial.conf \
    ops/puma_eve_industrial.service \
    ec2-user@eve-industrial.wikifuentes.com:~/

    ssh -i ~/.ssh/eve-industrial.pem ec2-user@eve-industrial.wikifuentes.com \
    'sudo mv ~/eve_industrial.conf /etc/nginx/conf.d/ && \
     sudo mv ~/puma_eve_industrial.service /etc/systemd/system/'

    ssh -i ~/.ssh/eve-industrial.pem ec2-user@eve-industrial.wikifuentes.com \
    'sudo mv ~/eve_industrial.conf /etc/nginx/conf.d/ ; \
    sudo mv ~/puma_eve_industrial.service /etc/systemd/system/'
    ```

    Enable the puma service
    ```
    sudo systemctl enable puma_eve_industrial.service
    ```

1. Deploy!
    ```
    cap production deploy
    ```

1. Final configuration steps
    1. First ssh to the server
    ```
    ssh -i ~/.ssh/eve-industrial.pem ec2-user@eve-industrial.wikifuentes.com
    ```

    1. Create and setup the SSL certificate using certbot
    ```
    sudo certbot --nginx
    ```

    1. Restart Nginx
    ```
    sudo service nginx restart
    ```

1. Load the seed data
    1. When starting from scratch
    ```
    cd ~/eve_industrial/current
    RAILS_ENV="production" bundle exec rails db:seed
    ```

    1. When restoring from a backup
    ```
    # Careful! This will destroy any pre-existing data in the database
    pg_restore -U eve_industrial -d eve_industrial_production -h localhost -W --clean ~/db.dump
    ```
