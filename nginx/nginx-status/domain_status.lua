-- 各参数用法:
-- count=status,host=xxx.com,status=404 统计xxx.com域名一分钟内404状态码个数.
-- count=statusUrl,host=xxx.com,status=404,exceed=50,output=30 当xxx.com域名404状态码一分钟内超过50个时,输出前30个url，否则返回空.
 
-- count=upT,host=xxx.com 统计xxx.com域名一分钟内平均upsteam耗时
-- count=upTUrl,host=xxx.com,exceed=0.5 输出upstreamTime超过0.5秒的url,没有就返回空
 
-- count=reqT,host=xxx.com 统计xxx.com域名一分钟内平均请求耗时
-- count=flow,host=xxx.com 统计xxx.com域名一分钟内流量(单位字节/秒)
 
-- 函数: 获取迭代器值
local get_field = function(iterator)
    local m,err = iterator
    if err then
        ngx.log(ngx.ERR, "get_field iterator error: ", err)
        ngx.exit(ngx.HTTP_OK)
    end
    return m[0]
end
 
-- 函数: 按值排序table
local getKeysSortedByValue = function (tbl, sortFunction)
  local keys = {}
  for key in pairs(tbl) do
    table.insert(keys, key)
  end
 
  table.sort(keys, function(a, b)
    return sortFunction(tbl[a], tbl[b])
  end)
 
  return keys
end
 
-- 函数: 判断table是否存在某元素
local tbl_contain = function(table,element)
    for k in pairs(table) do
        if k == element then
            return true
        end
    end
    return false
end
 
local access = ngx.shared.access
local now = ngx.time()
local one_minute_ago = now - 60
 
-- 获取参数
local args = ngx.req.get_uri_args()
local count_arg = args["count"]
local host_arg = args["host"]
local status_arg = args["status"]
local exceed_arg = args["exceed"]
local output_arg = args["output"]
local count_t = {["status"]=0,["statusUrl"]=0,["upT"]=0,["upTUrl"]=0,["reqT"]=0,["flow"]=0}
 
-- 检查参数是否满足
if not tbl_contain(count_t,count_arg) then
    ngx.print("count arg invalid.")
    ngx.exit(ngx.HTTP_OK)
end
 
if not host_arg then
    ngx.print("host arg not found.")
    ngx.exit(ngx.HTTP_OK)
end
 
if count_arg == "status" and not status_arg then
    ngx.print("status arg not found.")
    ngx.exit(ngx.HTTP_OK)
end
 
if count_arg == "statusUrl" and not (status_arg and exceed_arg and output_arg)  then
    ngx.print("status or exceed or output arg not found.")
    ngx.exit(ngx.HTTP_OK)
end
 
if count_arg == "upTUrl" and not exceed_arg then
    ngx.print("exceed arg not found.")
    ngx.exit(ngx.HTTP_OK)
end
 
-- 检查参数是否合法
if status_arg and ngx.re.find(status_arg, "^[0-9]{3}$") == nil then
    ngx.print("status arg must be a valid httpd code.")
    ngx.exit(ngx.HTTP_OK)
end
 
if exceed_arg and ngx.re.find(exceed_arg, "^[0-9.]+$") == nil then
    ngx.print("exceed arg must be a number.")
    ngx.exit(ngx.HTTP_OK)
end
 
if output_arg and ngx.re.find(output_arg, "^[0-9]+$") == nil then
    ngx.print("output arg must be a number.")
    ngx.exit(ngx.HTTP_OK)
end
 
-- 开始统计
local url
local status_code
local upstream_time
local status_total = 0
local host
local req_total = 0
local flow_total = 0
local reqtime_total = 0
local upstream_total = 0
local status_url_t = {}
local upstream_url_t = {}
local upstream_url_count_t = {}
 
local status_log
local upt_log
 
for second_num=one_minute_ago,now do
    local flow_key = table.concat({host_arg,"-flow-",second_num})
    local req_time_key = table.concat({host_arg,"-reqt-",second_num})
    local up_time_key = table.concat({host_arg,"-upt-",second_num})
    local total_req_key = table.concat({host_arg,"-total-",second_num})
    local log_key
    local log_line
 
    -- 合并状态码大于等于400的请求日志到变量status_log
    log_key = table.concat({"status-",second_num})
    log_line = access:get(log_key) or ""
    if not (log_line == "") then
        status_log = table.concat({log_line,"\n",status_log})
    end
 
    -- 合并upstream time大于0.5秒的请求日志到变量upt_log
    log_key = table.concat({"upt-",second_num})
    log_line = access:get(log_key) or ""
    if not (log_line == "") then
        upt_log = table.concat({log_line,"\n",upt_log})
    end
 
    -- 域名总请求数
    local req_sum = access:get(total_req_key) or 0
    req_total = req_total + req_sum
 
    if count_arg == "status" or count_arg == "statusUrl" then
        local status_key = table.concat({host_arg,"-",status_arg,"-",second_num})
        local status_sum = access:get(status_key) or 0
        status_total = status_total + status_sum
    end
 
    if count_arg == "flow" then
        local flow_sum = access:get(flow_key) or 0
        flow_total = flow_total + flow_sum
    end
 
    if count_arg == "reqT" then
        local req_time_sum = access:get(req_time_key) or 0
        reqtime_total = reqtime_total + req_time_sum
    end
 
    if count_arg == "upT" then
        local up_time_sum = access:get(up_time_key) or 0
        upstream_total = upstream_total + up_time_sum
    end
end
 
-- 统计状态码url
if count_arg == "statusUrl" and status_log and not (status_log == "") then
    local iterator, err = ngx.re.gmatch(status_log,".+\n")
    if not iterator then
        ngx.log(ngx.ERR, "status_log iterator error: ", err)
        return
    end
    for line in iterator do
        if not line[0] then
            ngx.log(ngx.ERR, "line[0] is nil")
            return
        end
        local iterator, err = ngx.re.gmatch(line[0],"[^ \n]+")
        if not iterator then
            ngx.log(ngx.ERR, "line[0] iterator error: ", err)
            return
        end
 
        host = get_field(iterator())
        url = get_field(iterator())
        status_code = get_field(iterator())
 
        if status_code == status_arg then
            if status_url_t[url] then
                status_url_t[url] = status_url_t[url] + 1
            else
                status_url_t[url] = 1
            end
        end
 
    end   
end
 
-- 统计upstream time大于0.5秒url
if count_arg == "upTUrl" and upt_log and not (upt_log == "") then
    local iterator, err = ngx.re.gmatch(upt_log,".+\n")
    if not iterator then
        ngx.log(ngx.ERR, "upt_log iterator error: ", err)
        return
    end
    for line in iterator do
        if not line[0] then
            ngx.log(ngx.ERR, "line[0] is nil")
            return
        end
        local iterator, err = ngx.re.gmatch(line[0],"[^ \n]+")
        if not iterator then
            ngx.log(ngx.ERR, "line[0] iterator error: ", err)
            return
        end
 
        host = get_field(iterator())
        url = get_field(iterator())
        upstream_time = get_field(iterator())
        upstream_time = tonumber(upstream_time) or 0
 
        -- 统计各url upstream平均耗时
        if host == host_arg then
            if upstream_url_t[url] then
                upstream_url_t[url] = upstream_url_t[url] + upstream_time
            else
                upstream_url_t[url] = upstream_time
            end
 
            if upstream_url_count_t[url] then
                upstream_url_count_t[url] = upstream_url_count_t[url] + 1
            else
                upstream_url_count_t[url] = 1
            end
        end   
    end   
end
 
-- 输出结果
if count_arg == "status" then
    ngx.print(status_total," ",req_total)
 
elseif count_arg == "flow" then
    ngx.print(flow_total," ",req_total)
 
elseif count_arg == "reqT" then
    local reqt_avg = 0
    if req_total == 0 then
        reqt_avg = 0
    else
        reqt_avg = reqtime_total/req_total
    end
    ngx.print(reqt_avg," ",req_total)
 
elseif count_arg == "upT" then
    local upt_avg = 0
    if req_total == 0 then
            upt_avg = 0
    else
            upt_avg = upstream_total/req_total
    end
    ngx.print(upt_avg," ",req_total)
 
elseif count_arg == "statusUrl" then
    if status_total > tonumber(exceed_arg) then
        -- 排序table
        status_url_t_key = getKeysSortedByValue(status_url_t, function(a, b) return a > b end)
        local output_body = ""
        for i, uri in ipairs(status_url_t_key) do
            if output_body == "" then
                output_body = table.concat({uri," ",status_url_t[uri]})
            else   
                output_body = table.concat({output_body,"\n",uri," ",status_url_t[uri]})
            end
            if i >= tonumber(output_arg) then
                ngx.print(output_body)
                ngx.exit(ngx.HTTP_OK)
            end               
        end
 
        ngx.print(output_body)
        ngx.exit(ngx.HTTP_OK)
    end
 
elseif count_arg == "upTUrl" then
    local max_output = 30
    local total_time = 0
    local total_count = 0
    local output_body = ""
    local i = 0
    for url in pairs(upstream_url_t) do
        i = i + 1
        total_time = upstream_url_t[url]
        total_count = upstream_url_count_t[url]
        avg_time = upstream_url_t[url] / upstream_url_count_t[url]
        if avg_time > tonumber(exceed_arg) then
            output_body = table.concat({url," ",avg_time," ",total_count,"\n",output_body})
        end
 
        if i >= max_output then
            ngx.print(output_body)
            ngx.exit(ngx.HTTP_OK)
        end           
    end
    ngx.print(output_body)
    ngx.exit(ngx.HTTP_OK)
 
end
