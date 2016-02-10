#!/usr/bin/env lua
-- FreeBSD dependency:
-- pkg install devel/lua-luarocks lang/lua52
-- luarocks install luasocket
--

local json = require "cjson"
local http = require"socket.http"
local ltn12 = require"ltn12"

local reqbody = '{"jsonrpc":"2.0","method": "template.get","params": {"output": "extend", "sortfield": "host"},"auth":"superpass","id":0}'

local respbody = {} -- for the response body

local result, respcode, respheaders, respstatus = http.request
{
method = "POST",
url = "http://zabbix.my.domain/zabbix/api_jsonrpc.php",
source = ltn12.source.string(reqbody),
headers = {
		["content-type"] = "application/json",
		["content-length"] = tostring(#reqbody)
	},
	sink = ltn12.sink.table(respbody)
}

-- get body as string by concatenating table filled by sink
-- respbody = table.concat(respbody)

if respbody[1] == nil then
	print "Nil from post: check credential"
	print ( respbody )

	print('body:' .. tostring(result))
	print('code:' .. tostring(respcode))
	--    print('headers:' .. util.tableToString(headers))
	print('status:' .. tostring(respstatus))

	return
end

local response = ""

for a,v in pairs ( respbody ) do
	response = response ..  v
end

-- print ( "Response: " .. response )

local t = json.decode( response )
local tdata = {}
local tid = {}

for k,v in pairs ( t ) do
	if ( k == "result" and type(v) == "table" ) then
		for x,y in pairs ( v ) do
			for a, b in pairs (y) do
				if a == "host" then
					tplname=(b)
				elseif a == "templateid" then
					tplindex=(b)
				end
			end
			table.insert(tdata,tplname)
			table.insert(tid,tplindex)
		end
	end
end


for a,b in pairs ( tdata ) do
	print ( tdata[a] .. "|" .. tid[a] )
end
