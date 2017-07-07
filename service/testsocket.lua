local skynet = require "skynet"
local socket = require "socket"
local packer = require "packer"
local print_t = require "print_t"
local mode , id = ...

local client_info={}

local function create (name, race, class)
	local character = { 
		general = {
			name = name,
			race = race,
			class = class,
		}, 
		attribute = {
			level = tostring(1),
			exp = tostring(0),
		},
	}
	return character
end

local function wechatlogin(jsondata)
	client_info["openid"]="sdsdf"
	client_info["mach"] ="010101001"
end

local function wechatpayack(jsondata)
	httpc = skynet.newservice("testhttpc")
	skynet.call(httpc,"lua","ackpay",str)
end

local function echo(id)
	socket.start(id)
		socket.write(id, "Hello, I'm Skynet Server\n")
		while true do

		-- skynet.fork(function()
		-- 	while true do
		-- 		socket.write(id,"heart beat every 5 second\n")
		-- 		skynet.sleep(500)
		-- 	end
		-- end)

		local str = socket.read(id)
		if str then
			print("I receive data : "..str.." length:"..#str)
			
			-- local character = create ("name111", "123", "sdffdss")
			-- json = packer.pack(character)
			-- print("pack data :"..json)

			-- 客户端以下面字符串形式发送json数据。
			--{"name":"test5","race":"human","class":"warrior"}

			-- jsondata = packer.unpack(str)
			--print_t(temptable)
			--temptable.name = "12345"
			--str = packer.pack(temptable)

			--list = packer.unpack(str)
			--print_t(list)	

 			jsondata = packer.unpack(str)

			if jsondata ~= nil then
				if jsondata["type"]=="login" then
					wechatlogin(jsondata)
				elseif jsondata["type"]=="pay" then
					wechatpayack(jsondata)
				else
					wechatpayack(jsondata)
				end

				socket.write(id,"server receive:"..str)
			end
		else
			print("clost socket!")
			socket.close(id)
			return
		end
	end
end

if mode == "agent" then
	id = tonumber(id)
	print("agent:"..id)
	skynet.start(function()
		skynet.fork(function()
			echo(id)
			skynet.exit()
		end)
	end)
else
	local function accept(id)
		socket.start(id)
		--socket.write(id, "Hello Skynet\n")
		skynet.newservice(SERVICE_NAME, "agent", id)
		-- notice: Some data on this connection(id) may lost before new service start.
		-- So, be careful when you want to use start / abandon / start .
		socket.abandon(id)
	end

	skynet.start(function()

		local id = socket.listen("0.0.0.0", 6666)
		print("Listen socket :", "0.0.0.0", 6666)

		socket.start(id , function(id, addr)
			print("connect from " .. addr .. " " .. id)
			-- you have choices :
			-- 1. skynet.newservice("testsocket", "agent", id)
			-- 2. skynet.fork(echo, id)
			-- 3. accept(id)

			--accept(id)
			--skynet.fork(echo,id)
			skynet.newservice("testsocket", "agent", id)
		end)
	end)
end
