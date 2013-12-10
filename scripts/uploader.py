#!/usr/bin/python

import json
import redis


# read credentials into dictionary
json_data=open('../credentials.json')
credentials = json.load(json_data)
json_data.close()


#connect to redis
r = redis.Redis(host=credentials["host"], port=credentials["port"], password=credentials["password"], charset=credentials["charset"], errors=credentials["errors"]) 



#r.set('foo', 'bar')   # or r['foo'] = 'bar'
#r.get('foo')   # or r['foo']

