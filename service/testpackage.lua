local skynet = require "skynet"
local socket = require "socket"
local proxy = require "socket_proxy"
local packer = require "packer"
local print_t = require "print_t"

local client_info={}

local function wechatlogin(jsondata)
	client_info["openid"]=jsondata["openid"]
	client_info["mach"] =jsondata["mach"]
end

local function wechatpayack(jsondata)
	httpc = skynet.newservice("testhttpc")
	skynet.call(httpc,"lua","ackpay",str)
end

local function read(fd)
	return skynet.tostring(proxy.read(fd))
end

function new_package(fd, addr)
	skynet.error(string.format("%s connected as %d" , addr, fd))
	proxy.subscribe(fd)
	while true do
		local ok, s = pcall(read, fd)
		if not ok then
			skynet.error("CLOSE")
			break
		end
		if s == "quit" then
			proxy.close(fd)
			break
		end

		print("I receive data: "..s.." length:"..#s)
		jsondata = packer.unpack(s)
		--print_t(jsondata)
		
		if jsondata ~= nil then
			if jsondata["type"]=="login" then
				wechatlogin(jsondata)
			elseif jsondata["type"]=="pay" then
				wechatpayack(jsondata)
			else
				wechatpayack(jsondata)
			end

			--proxy.write(fd,"server receive:"..s)
		end
		-- skynet.error(s)
	end
end

skynet.start(function()
	local id = assert(socket.listen("0.0.0.0", 6666))
	socket.start(id,new_package)
end)