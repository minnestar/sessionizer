#!/bin/bash

echo '-----------------------------'
echo 'sudo service postgresql start'
sudo service postgresql start

echo '--------------------------------------------------'
echo 'View page in your browser at http://localhost:3000'
echo 'If you are using Docker with a non-zero port offset,'
echo 'then the appropriate port number is different from 3000.'

if [ -f '/home/winner/shared/ports.txt' ]; then
  cat /home/winner/shared/ports.txt;
fi

echo '-------------------------------'
echo 'rails server -b 0.0.0.0 -p 3000'
rails server -b 0.0.0.0 -p 3000
