#!/usr/bin/python

import redis
#redis://redistogo:f1db4c46048e62e42446dd35a77ece4e@grideye.redistogo.com:9644/
r = redis.Redis(host='localhost', port=9644, db=0)
r.set('foo', 'bar')   # or r['foo'] = 'bar'
r.get('foo')   # or r['foo']

