#!/usr/bin/env tarantool


local httpd = require('http.server')
local log = require('log')
local json = require('json')

box.cfg{}

box.once(
	'schema', 
	function()
		box.schema.create_space(
			'kv_store',
			{ 
				format = {
					{ name = 'key';   type = 'string' },
					{ name = 'value'; type = '*' },
				};
				if_not_exists = true;
			}
		)
		box.space.kv_store:create_index(
			'primary', 
			{ 
				type = 'hash'; 
				parts = {1, 'string'}; 
				if_not_exists = true;
			}
		)
	end
)

local function create(req)
	local body = req:json()
	-- log.info( json.encode(body) )
	local key = body['key']

	local duplicate = box.space.kv_store:select(key)
	if ( table.getn(duplicate) ~= 0 ) then
		local resp = req:render{ json = { status = "duplicate keys" }}
		resp.status = 409
		return resp
	end

	box.space.kv_store:insert{ key, body['value'] }

	local resp = req:render{ json = box.space.kv_store:select() }
	resp.status = 201

	return resp
end


local function delete(req)
	local key = req:stash('key')

	local tuple = box.space.kv_store:select(key)
	if( table.getn( tuple ) == 0 ) then
		local resp = req:render{json = { status = "Key not found" }}
		resp.status = 404
		return resp
	end

	box.space.kv_store:delete{ key }

	local resp = req:render{ json = box.space.kv_store:select() }
	resp.status = 200

	return resp
end

local function get_tuple(req)
	local key = req:stash('key')

	local tuple = box.space.kv_store:select{ key }
	if( table.getn( tuple ) == 0 ) then
		local resp = req:render{json = { status = "Key not found" }}
		resp.status = 404
		return resp
	end

	log.info("GET(key: %s)" , key)
	local resp = req:render{json = {key = tuple[1][1], value = tuple[1][2]}}
	resp.status = 200

	return resp
end

local function update(req)
	local key = req:stash('key')

	local tuple = box.space.kv_store:select{ key }
	if( table.getn( tuple ) == 0 ) then
		local resp = req:render{json = { status = "Key not found" }}
		resp.status = 404
		return resp
	end

	local body = req:json()

	log.info("PUT(key: %s)" , key)
	local tuple = box.space.kv_store:update({key}, {{'=', 2, body['value']}})

	local resp = req:render{ json = box.space.kv_store:select() }
	resp.status = 200

	return resp
end

local server = httpd.new('127.0.0.1', 80)

server:route({ path = '/kv', method = 'POST' }, create)
server:route({ path = '/kv/:key', method = 'DELETE' }, delete)
server:route({ path = '/kv/:key', method = 'GET' }, get_tuple)
server:route({ path = '/kv/:key', method = 'PUT' }, update)




server:start()