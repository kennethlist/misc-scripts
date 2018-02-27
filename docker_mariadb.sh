#!/bin/bash
docker run --name mariadb -p 3306:3306 \
    -v <mysql>:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=<password> \
    -d mariadb:latest