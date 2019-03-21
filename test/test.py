#!/usr/bin/python

from unittest import TestCase
import requests
import json


DELETE = 'DELETE'
POST = 'POST'
PUT = 'PUT'
GET = 'GET'


class KeyValueStoreApi():
    host = '127.0.0.1'
    port = 5000
    
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.methods = {
            GET: requests.get,
            PUT: requests.put,
            POST: requests.post,
            DELETE: requests.delete
        }
    
    def make_url(self, path):
        return 'http://{domain}:{port}/{path}'.format(
            domain=self.host,
            port=self.port,
            path=path if path[0] != '/' else path[1:]
        )

    def make_request(self, method, path, **kwargs):
        r = self.methods[method](self.make_url(path), **kwargs)
        return r.status_code, r.json()

    @staticmethod
    def make_payload(key, value):
        return json.dumps({'key': key, 'value': value})


api = KeyValueStoreApi('127.0.0.1', 80)
payload = KeyValueStoreApi.make_payload(420, {'v1': 15, 'v2': [1, 3, 5]})
print payload
status, responce = api.make_request(POST, '/kv', data=payload)
print status
print responce