# Tarantool simple key-value store

[![Build Status](https://travis-ci.com/Alex-Kuz/tarantool-key-value-store.svg?branch=master)](https://travis-ci.com/Alex-Kuz/tarantool-key-value-store)

![tarantool + lua](https://cdn-images-1.medium.com/max/1600/0*mztHqUerTUp95DmH.)

## Heroku url: https://key-value-tarantool.herokuapp.com/

## Keywords
  - [Tarantool](https://www.tarantool.io/en/)
  - [Lua](https://www.lua.org)
  - [Docker](https://hub.docker.com/r/ax4docker/ax_tarantool)
 
## API
Path | Method | Body (json) | Description
--- | --- | --- | --- 
/kv | POST | ```{"key": "Your key", "value": ...your object...} ``` | Add a new pair if key was not in the database
/kv/:key | GET |  | Select pair by key and return result
/kv/:key | DELETE | | Delete pair if key was in the database
/kv/:key | PUT | ```{ "value": ...your new object...} ``` | Update new pair if the key was in the database
/info/kv/all_records | GET |  | Return all pairs in database

## Commands
This project  requires [docker](https://www.docker.com) to run.

### Installation
```sh
$ make docker
```

### Application launch
```sh
$ make run
```
### Test (require python 2.7 and some modules)
```sh
$ pip install requests simplejson  # install modules for testing
$ make tests                       # local tests
$ make heroku-test                 # test heroku app
```

### Stop Application
```sh
$ make stop
```
