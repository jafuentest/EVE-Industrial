#!/bin/bash

echo "creating backup..."
heroku pg:backups capture --app eve-industrial

echo "downloading backup..."
curl -o latest.dump `heroku pg:backups public-url`

echo "updating local database..."
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d eveindustrial_dev latest.dump
rm latest.dump
echo "done."
