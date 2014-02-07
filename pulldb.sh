#!/bin/bash

echo "creating backup..."
heroku pgbackups:capture

echo "downloading backup..."
curl -o latest.dump `heroku pgbackups:url`

echo "updating local database..."
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U eveindustrial -d eveindustrial_dev latest.dump
rm latest.dump
echo "done."
