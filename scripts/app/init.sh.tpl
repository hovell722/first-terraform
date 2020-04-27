#!/bin/bash

echo "${my_name}"
cd /home/ubuntu/app
pm2 start app.js
