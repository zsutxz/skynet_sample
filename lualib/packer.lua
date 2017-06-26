local cjson = require "cjson"
local print_t = require "print_t"
cjson.encode_sparse_array(true, 1, 1)

local packer = {}

function packer.pack (v)
	
	--print_t(v)
	local temp = cjson.encode (v)
	--print(temp)

	return temp
end

function packer.unpack (v)
	--print(v)
	local temp = cjson.decode (v)
	--print_t(temp)
	
	return temp
end

return packer
