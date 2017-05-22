local access = ngx.shared.access
local host = ngx.var.host or "unknow"
local status = ngx.var.status
local body_bytes_sent = ngx.var.body_bytes_sent
local request_time = ngx.var.request_time
local upstream_response_time = ngx.var.upstream_response_time or 0
local request_uri = ngx.var.request_uri or "/unknow"
local timestamp = ngx.time()
local expire_time = 70
 
local status_key = table.concat({host,"-",status,"-",timestamp})
local flow_key = table.concat({host,"-flow-",timestamp})
local req_time_key = table.concat({host,"-reqt-",timestamp})
local up_time_key = table.concat({host,"-upt-",timestamp})
local total_key = table.concat({host,"-total-",timestamp})
 
-- 域名总请求数
local n,e = access:incr(total_key,1)
if not n then
access:set(total_key, 1, expire_time)
end
 
-- 域名状态码请求数
local n,e = access:incr(status_key,1)
if not n then
access:set(status_key, 1, expire_time)
end
 
-- 域名流量
local n,e = access:incr(flow_key,body_bytes_sent)
if not n then
access:set(flow_key, body_bytes_sent, expire_time)
end
 
-- 域名请求耗时
local n,e = access:incr(req_time_key,request_time)
if not n then
access:set(req_time_key, request_time, expire_time)
end
 
-- 域名upstream耗时
local n,e = access:incr(up_time_key,upstream_response_time)
if not n then
access:set(up_time_key, upstream_response_time, expire_time)
end
 
-- 获取不带参数的uri
local m, err = ngx.re.match(request_uri, "(.*?)\\?")
local request_without_args = m and m[1] or request_uri
 
-- 存储状态码大于400的url
if tonumber(status) >= 400 then
-- 拼接url,状态码,字节数等字段
local request_log_t = {}
table.insert(request_log_t,host)
table.insert(request_log_t,request_without_args)
table.insert(request_log_t,status)
local request_log = table.concat(request_log_t," ")
 
-- 把拼接的字段储存在字典中
local log_key = table.concat({"status-",timestamp})
local request_log_dict = access:get(log_key) or ""
if request_log_dict == "" then
request_log_dict = request_log
else
request_log_dict = table.concat({request_log_dict,"\n",request_log})
end
access:set(log_key, request_log_dict, expire_time)
end
 
-- 存储upstream time大于0.5的url
if tonumber(upstream_response_time) > 0.5 then
-- 拼接url,状态码,字节数等字段
local request_log_t = {}
table.insert(request_log_t,host)
table.insert(request_log_t,request_without_args)
table.insert(request_log_t,upstream_response_time)
local request_log = table.concat(request_log_t," ")
 
-- 把拼接的字段储存在字典中
local log_key = table.concat({"upt-",timestamp})
local request_log_dict = access:get(log_key) or ""
if request_log_dict == "" then
request_log_dict = request_log
else
request_log_dict = table.concat({request_log_dict,"\n",request_log})
end
access:set(log_key, request_log_dict, expire_time)
end
