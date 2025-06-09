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
  * Postgres server (local or remote)
  * rvm + Ruby version
  * NodeJS + Yarn
  * Postgres devel package

sudo yum install git perl zlib-devel libffi-devel libyaml-devel nginx certbot python3-certbot-nginx
sudo dnf install postgresql17 postgresql17-server libpq-devel

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
~/.rbenv/bin/rbenv init
eval "$(~/.rbenv/bin/rbenv init - --no-rehash bash)"
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

yum install perl

create teh master.key

??? rbenv global 3.3.5

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install --lts

npm install -g yarn

2. Ensure ssh key exists and is available
    ```
    ~/.ssh/wallet-status.pem
    ```

3. Login to the psql shell with root privileges
    sudo /usr/bin/postgresql-setup --initdb
    sudo service postgresql start
    sudo -u postgres psql
    ```
    CREATE DATABASE eve_industrial_production;
    CREATE USER eve_industrial WITH ENCRYPTED PASSWORD '<secure-password>';
    GRANT ALL PRIVILEGES ON DATABASE eve_industrial_production TO eve_industrial;
    ```

    Find config file
    sudo -u postgres psql -c "SHOW hba_file;"

    order matters
    # IPv4 local connections:
    host    eve_industrial_production eve_industrial  127.0.0.1/32  md5
    host    all             all             127.0.0.1/32            ident

4. Copy SPECIAL? files. Assuming that:
  * The cap deploy_to dir is `~/eve_industrial`
  * The domain is `eve_industrial.wikifuentes.com`
    ```
    mkdir -p ~/eve_industrial/shared/config

    # Copies the master key to decrypt rails secrets
    scp -i ~/.ssh/wikifuentes.pem config/master.key ec2-user@eve-industrial.wikifuentes.com:~/eve_industrial/shared/config

    scp -i ~/.ssh/wikifuentes.pem \
    ops/eve_industrial.conf \
    ops/puma_eve_industrial.service \
    ec2-user@eve-industrial.wikifuentes.com:~/

    ssh -i ~/.ssh/wikifuentes.pem ec2-user@eve-industrial.wikifuentes.com \
    'sudo mv ~/eve_industrial.conf /etc/nginx/conf.d/ && \
     sudo mv ~/puma_eve_industrial.service /etc/systemd/system/ && \
     sudo systemctl enable puma_eve_industrial.service'


    ssh -i ~/.ssh/wikifuentes.pem ec2-user@eve-industrial.wikifuentes.com \
    'sudo mv ~/eve_industrial.conf /etc/nginx/conf.d/ ; \
    sudo mv ~/puma_eve_industrial.service /etc/systemd/system/'

    sudo systemctl enable puma_eve_industrial.service

    puma shared file
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

  * Restart Nginx
    ```
    sudo service nginx restart
    ```

7. Initialize the database
    ```
    cd ~/eve_industrial/current
    RAILS_ENV="production" bundle exec rails db:seed
    ```

<!-- * Configuration -->

<!-- * How to run the test suite -->
