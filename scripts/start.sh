#!/bin/sh

supervisord
supervisorctl reread
supervisorctl update
supervisorctl start laravel-worker:*

php-fpm --nodaemonize
