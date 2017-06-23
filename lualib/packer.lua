local cjson = require "cjson"
local print_r = require "print_r"
cjson.encode_sparse_array(true, 1, 1)

local packer = {}

function packer.pack (v)
	
	--print_r(v)
	local temp = cjson.encode (v)
	--print(temp)

	return temp
end

function packer.unpack (v)
	--print(v)
	local temp = cjson.decode (v)
	--print_r(temp)
	
	return temp
end

return packer
