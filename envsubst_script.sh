#!/bin/bash

envsubst '${SERVER_NAME} ${INDEX_FILE}' < /etc/nginx/nginx.conf > /tmp/nginx.conf
mv /tmp/nginx.conf /etc/nginx/nginx.conf
