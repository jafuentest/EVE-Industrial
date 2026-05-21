# EVE-Industrial

Rails app for EVE Online industrial planning. Currently supporting:

* Industry jobs
* Market orders
* Planetary colonies
* Planetary commodities

## Basic System Requirements

* Ruby version
  * MRI 3.3.5

* System dependencies
  * PostgreSQL 17 or higher

* Services
  * Uses Delayed Job for background tasks

## Running the Test Suite

Just run Rspec
```
bundle exec rspec
```

## Capistrano Deployment

1. Install system dependencies
   * rbenv + Ruby version
   * NodeJS + Yarn
   * PostgreSQL server (assuming local install)
   * PostgreSQL devel package
   * Nginx
   * Certbot

    If using Amazon Linux 2023:

    1. Install basic dependencies
        ```bash
        sudo dnf install git perl zlib-devel libffi-devel libyaml-devel nginx certbot python3-certbot-nginx
        ```

    1. Install Postgres
        ```bash
        sudo dnf install postgresql17 postgresql17-server libpq-devel
        ```

    1. Install rbenv with ruby-build plugin, and setup ruby 3.3.5
        ```bash
        git clone https://github.com/rbenv/rbenv.git ~/.rbenv
        ~/.rbenv/bin/rbenv init

        # Restart the shell to load the rbenv
        exec bash

        git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

        rbenv install 3.3.5
        ```
    1. Install NodeJS + Yarn. Probably best to check for the latest version of nvm
        ```bash
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        nvm install --lts
        npm install -g yarn
        ```

1. Set up the Postgres database
    1. Login to the psql shell with root privileges
        ```bash
        sudo /usr/bin/postgresql-setup --initdb
        sudo service postgresql start
        sudo -u postgres psql
        ```

    1. Create the database and user
        ```sql
        CREATE DATABASE eve_industrial_production;
        CREATE USER eve_industrial WITH ENCRYPTED PASSWORD '<secure-password>';
        GRANT ALL PRIVILEGES ON DATABASE eve_industrial_production TO eve_industrial;
        \c eve_industrial_production
        GRANT ALL ON SCHEMA public TO eve_industrial;
        ```

    1. Configure the database to allow connections from the eve_industrial user
        Find config file (in my case it was on `/var/lib/pgsql/data/pg_hba.conf`)
        ```bash
        sudo -u postgres psql -c "SHOW hba_file;"
        sudo vim /var/lib/pgsql/data/pg_hba.conf
        ```

        Find the IPv4 local connections block in the file and update it to look like this:
        ```
        # IPv4 local connections:
        host    eve_industrial_production eve_industrial  127.0.0.1/32  scram-sha-256
        host    all             all             127.0.0.1/32            ident
        ```
        **Note that it's important that eve_industrial user is listed before the all user.**

        Reload postgresql config
        ```bash
        sudo systemctl reload postgresql
        ```

1. Copy config files. Assuming that:
    * You ssh into the server using a key located at `~/.ssh/eve-industrial.pem`
    * The cap deploy_to dir is `~/eve_industrial`
    * The domain is `eve-industrial.wikifuentes.com`

    Create the shared config dir
    ```bash
    mkdir -p ~/eve_industrial/shared/config
    ```

    Copy the master key to decrypt rails secrets
    ```bash
    scp -i ~/.ssh/eve-industrial.pem config/master.key ec2-user@eve-industrial.wikifuentes.com:~/eve_industrial/shared/config
    ```

    Copy the nginx and puma systemd files
    ```bash
    scp -i ~/.ssh/eve-industrial.pem \
    ops/eve_industrial.conf \
    ops/puma_eve_industrial.service \
    ec2-user@eve-industrial.wikifuentes.com:~/

    ssh -i ~/.ssh/eve-industrial.pem ec2-user@eve-industrial.wikifuentes.com \
    'sudo mv ~/eve_industrial.conf /etc/nginx/conf.d/ && \
     sudo mv ~/puma_eve_industrial.service /etc/systemd/system/'
    ```

    Enable the puma service
    ```bash
    sudo systemctl enable puma_eve_industrial.service
    ```

1. Deploy!
    From your local system:
    ```bash
    cap production deploy
    ```

1. Final configuration steps
    1. First ssh to the server
        ```bash
        ssh -i ~/.ssh/eve-industrial.pem ec2-user@eve-industrial.wikifuentes.com
        ```

    1. Create and setup the SSL certificate using certbot
        ```bash
        sudo certbot --nginx
        ```

    1. Restart Nginx
        ```bash
        sudo service nginx restart
        ```

1. Load the seed data
    1. When starting from scratch
        ```bash
        cd ~/eve_industrial/current
        RAILS_ENV="production" bundle exec rails db:seed
        ```

    1. When restoring from a backup
        ```bash
        # Careful! This will destroy any pre-existing data in the database
        pg_restore -U eve_industrial -d eve_industrial_production -h localhost -W --clean ~/db.dump
        ```
