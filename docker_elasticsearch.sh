#!/bin/bash
docker run --name elasticsearch -p 9200:9200 -p 9300:9300 \
    -v <data>:/usr/share/elasticsearch/data \
    -d elasticsearch