#!/bin/bash

apt-get update
apt-get install -y curl apt-utils

curl http://download.tarantool.org/tarantool/1.7/gpgkey | apt-key add -

apt-get -y install apt-transport-https

rm -f /etc/apt/sources.list.d/*tarantool*.list
echo "deb http://download.tarantool.org/tarantool/1.7/ubuntu/ xenial main" >> /etc/apt/sources.list.d/tarantool_1_7.list
echo "deb-src http://download.tarantool.org/tarantool/1.7/ubuntu/ xenial main" >> /etc/apt/sources.list.d/tarantool_1_7.list 

apt-get update
apt-get -y install tarantool

tarantoolctl rocks install http