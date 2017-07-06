local skynet = require "skynet"
local httpc = require "http.httpc"
local dns = require "dns"
local cjson = require "cjson"
local packer = require "packer"
local print_t = require "print_t"

local service = require "service"
local md5 = require "md5"

skynet.start(function()
	httpc.dns()	-- set dns server
    --httpc.AckPay("00101011112111")
	--skynet.exit()
end)


function gettime()
    local respheader = {}
    local account_info = {}

    local userurl ="/index.php/Api/GetTime/index" 
	local ok, code, body = pcall(httpc.get,"sealywxb.lkgame.com",userurl)

    if not ok or code ~= 200 then
        skynet.error("http verify fail,code",tostring(code))
        account_info.errCode = 110 
        account_info.err='http request fail'
        return account_info
    end

    local ok, verify_ret = pcall(cjson.decode,body)
    if not ok then
        skynet.error('http verify return json decode err:%s',tostring(verify_ret))
        --返回消息错误
        account_info.errCode = 111
        account_info.err='http verify fail'
        return account_info
    else
		--print_t(verify_ret)
        -- ok
        if verify_ret.errcode==0 then
            skynet.error('http verify ok, time:',tostring(verify_ret.time))
            print('http verify ok, time:'..tostring(verify_ret.time))
            account_info.errCode = verify_ret.errcode
            account_info.err = verify_ret.errmsg
            account_info.time = verify_ret.time
            return account_info
        end
    end

    return account_info
end

function httpc.ackpay(mach_str)
    local url = "sealywxb.lkgame.com"
    local postfield = "/index.php/Api/Player/get_qrcode?qrscene="
    postfield= postfield..mach_str
    
    local account_info = gettime();
    if(account_info.errCode==0) then 
        postfield= postfield.."&time="..tostring(account_info.time)
    end

    sign = md5.sumhexa(postfield)
    postfield = postfield.."&sign="..sign
    --url = url..postfield
    print(url.."  "..postfield)
    local status, body = httpc.get(url, postfield, respheader)

end

service.init {
	command = httpc,
}
