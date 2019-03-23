#!/usr/bin/env tarantool


local httpd = require('http.server')
local log = require('log')
local json = require('json')

box.cfg{
	log = 'tarantool.log'
}

box.once('schema', 
	function()
		box.schema.create_space('kv_store',
			{ 
				format = {
					{ name = 'key';   type = 'string' },
					{ name = 'value'; type = '*' },
				};
				if_not_exists = true;
			}
		)
		box.space.kv_store:create_index('primary', 
			{ type = 'hash'; parts = {1, 'string'}; if_not_exists = true; }
		)
	end
)


local function invalid_body(req, func_name,  msg)
	local resp = req:render{json = { info = msg }}
	resp.status = 400
	log.info("%s(%d) invalid body: %s", func_name, resp.status, body)
	return resp
end

local function read_json(request)
	local status, body = pcall(function() return request:json() end)
	log.info("pcall(request:json()): %s %s", status, body)

	return body
end
	

local function create(req)
	local body = read_json(req)
	
	if ( type(body) == 'string' ) then
		return invalid_body(req, 'create', 'invlid json')
	end

	if body['key'] == nil or body['value'] == nil then
		return invalid_body(req, 'create', 'missing value or key')
	end
		
	local key = body['key']

	local duplicate = box.space.kv_store:select(key)
	if ( table.getn(duplicate) ~= 0 ) then
		local resp = req:render{json = { info = "duplicate keys" }}
		resp.status = 409
		log.info("create(%d) conflict keys: %s", resp.status, key)
		return resp
	end
	
	box.space.kv_store:insert{ key, body['value'] }
	local resp = req:render{json = { info = "Successfully created" }}
	resp.status = 201

	log.info("create(%d) key: %s", resp.status, key)

	return resp
end


local function delete(req)
	local key = req:stash('key')

	local tuple = box.space.kv_store:select(key)
	if( table.getn( tuple ) == 0 ) then
		local resp = req:render{json = { info = "Key doesn't exist" }}
		resp.status = 404
		return resp
	end

	box.space.kv_store:delete{ key }

	local resp = req:render{json = { info = "Successfully deleted" }}
	resp.status = 200

	return resp
end

local function get_tuple(req)
	local key = req:stash('key')

	local tuple = box.space.kv_store:select{ key }
	if( table.getn( tuple ) == 0 ) then
		local resp = req:render{json = { info = "Key doesn't exist" }}
		resp.status = 404
		return resp
	end

	log.info("GET(key: %s)" , key)
	local resp = req:render{json = {key = tuple[1][1], value = tuple[1][2]}}
	resp.status = 200

	return resp
end

local function update(req)
	local body = read_json(req)
	
	if ( type(body) == 'string' ) then
		return invalid_body(req, 'update', 'invlid json')
	end

	if body['value'] == nil then
		return invalid_body(req, 'update', 'missing value')
	end

	local key = req:stash('key')

	if key == nil then
		local resp = req:render{json = { info = msg }}
		resp.status = 400
		log.info("update(%d) invalid key: '%s'", resp.status, key)
		return resp
	end

	local tuple = box.space.kv_store:select{ key }
	if( table.getn( tuple ) == 0 ) then
		local resp = req:render{json = { info = "Key doesn't exist" }}
		resp.status = 404
		return resp
	end

	log.info("PUT(key: %s): value: %s" , key, body['value'])
	local tuple = box.space.kv_store:update({key}, {{'=', 2, body['value']}})

	local resp = req:render{json = { info = "Successfully updated" }}
	resp.status = 200

	return resp
end

local function get_all_kv(req)
	local resp = req:render{json = { store = box.space.kv_store:select{} }}
	resp.status = 200
	log.info("get_all_kv(200)")
	return resp
end


local server = httpd.new('127.0.0.1', 80)

server:route({ path = '/kv', method = 'POST' }, create)
server:route({ path = '/kv/:key', method = 'DELETE' }, delete)
server:route({ path = '/kv/:key', method = 'GET' }, get_tuple)
server:route({ path = '/kv/:key', method = 'PUT' }, update)

server:route({ path = '/kv/all_records', method = 'GET' }, get_all_kv)


server:start()