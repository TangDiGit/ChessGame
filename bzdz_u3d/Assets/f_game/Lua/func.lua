local setmetatableindex_
setmetatableindex_ = function(t, index)
    if type(t) == "userdata" then
        local peer = tolua.getpeer(t)
        if not peer then
            peer = {}
            tolua.setpeer(t, peer)
        end
        setmetatableindex_(peer, index)
    else
        local mt = getmetatable(t)
        if not mt then mt = {} end
        if not mt.__index then
            mt.__index = index
            setmetatable(t, mt)
        elseif mt.__index ~= index then
            setmetatableindex_(mt, index)
        end
    end
end
setmetatableindex = setmetatableindex_

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local newObject = {}
        lookup_table[object] = newObject
        for key, value in pairs(object) do
            newObject[_copy(key)] = _copy(value)
        end
        return setmetatable(newObject, getmetatable(object))
    end
    return _copy(object)
end

function class(classname, ...)
    local cls = {__cname = classname}

    local supers = {...}
    for _, super in ipairs(supers) do
        local superType = type(super)
        assert(superType == "nil" or superType == "table" or superType == "function",
            string.format("class() - create class \"%s\" with invalid super class type \"%s\"",
                classname, superType))

        if superType == "function" then
            assert(cls.__create == nil,
                string.format("class() - create class \"%s\" with more than one creating function",
                    classname))
            -- if super is function, set it to __create
            cls.__create = super
        elseif superType == "table" then
            if super[".isclass"] then
                -- super is native class
                assert(cls.__create == nil,
                    string.format("class() - create class \"%s\" with more than one creating function or native class",
                        classname))
                cls.__create = function() return super:create() end
            else
                -- super is pure lua class
                cls.__supers = cls.__supers or {}
                cls.__supers[#cls.__supers + 1] = super
                if not cls.super then
                    -- set first super pure lua class as class.super
                    cls.super = super
                end
            end
        else
            error(string.format("class() - create class \"%s\" with invalid super type",
                        classname), 0)
        end
    end

    cls.__index = cls
    if not cls.__supers or #cls.__supers == 1 then
        setmetatable(cls, {__index = cls.super})
    else
        setmetatable(cls, {__index = function(_, key)
            local supers = cls.__supers
            for i = 1, #supers do
                local super = supers[i]
                if super[key] then return super[key] end
            end
        end})
    end

    if not cls.ctor then
        -- add default constructor
        cls.ctor = function() end
    end
    cls.new = function(...)
        local instance
        if cls.__create then
            instance = cls.__create(...)
        else
            instance = {}
        end
        setmetatableindex(instance, cls)
        instance.class = cls
        instance:ctor(...)
        return instance
    end
    cls.create = function(_, ...)
        return cls.new(...)
    end

    return cls
end

local iskindof_
iskindof_ = function(cls, name)
    local __index = rawget(cls, "__index")
    if type(__index) == "table" and rawget(__index, "__cname") == name then return true end

    if rawget(cls, "__cname") == name then return true end
    local __supers = rawget(cls, "__supers")
    if not __supers then return false end
    for _, super in ipairs(__supers) do
        if iskindof_(super, name) then return true end
    end
    return false
end

function iskindof(obj, classname)
    local t = type(obj)
    if t ~= "table" and t ~= "userdata" then return false end

    local mt
    if t == "userdata" then
        if tolua.iskindof(obj, classname) then return true end
        mt = tolua.getpeer(obj)
    else
        mt = getmetatable(obj)
    end
    if mt then
        return iskindof_(mt, classname)
    end
    return false
end

--lua 字符串分割函数
--参数:待分割的字符串,分割字符
--返回:子串表.(含有空串)
function lua_string_split(str, split_char)    
	local sub_str_tab = {}
	while (true) do        
		local pos = string.find(str, split_char)  
		if (not pos) then            
			local size_t = table.getn(sub_str_tab)
			table.insert(sub_str_tab,size_t+1,str)
			break  
		end
		local sub_str = string.sub(str, 1, pos - 1)              
		local size_t = table.getn(sub_str_tab)
		table.insert(sub_str_tab,size_t+1,sub_str)
		local t = string.len(str)
		str = string.sub(str, pos + 1, t)   
	end    
	return sub_str_tab
end

function cloneTab(tab)
    local _t={}
    for i,v in pairs(tab) do
        table.insert(_t,v)
    end
    return _t
end

function cloneTabList(tab)
    local _t = { }
    for i, v in pairs(tab) do
        table.insert(_t, v)
    end
    return _t
end

--格式化数值显示
function formatVal(val)
    if not val then
        return ""
    end

    if type(val) == 'string' then
        val = tonumber(val)
    end

    if val >= 100000000 then
        --亿 能整除
        if val%100000000 == 0 then
            return (val/100000000)..'亿'
        else
            return (string.format('%.2f',val/100000000))..'亿'
        end
    elseif val >= 10000000 then
        --千万 能整除
        if val%10000 == 0 then
            return (val/10000)..'万'
        else
            return (string.format('%.1f',val/10000))..'万'
        end
    elseif val >= 10000 then
        --百万 能整除
        if val%10000 == 0 then
            return (val/10000)..'万'
        else
            return (string.format('%.2f',val/10000))..'万'
        end
    else
        return tostring(val)
    end
end

-- 旧的
--function getApitoken(_module, _controller, _funname)
--    local temp = os.date("*t", os.time())
--    local _t = temp.year..'/'..temp.month..'/'..temp.day
--    local _m = 'bz0987654321'
--    return F_Util.EncryptString(_module.._controller.._funname.._t.._m)
--end

function getApitoken(_module, _controller, _funname)
    local _m = 'bz0987654321'
    local _time = os.time()
    return F_Util.EncryptString(_module.._controller.._funname.._time.._m)
end

--获取00:00格式时间文本
function GetTimeText(time)
    local function getFulText(num)
        if (num > 9) then
            return tostring(num)
        else
            return "0"..num
        end
    end

    local zHour = math.floor(time / 3600)
    local zMinute = math.floor((time - zHour * 3600) / 60)
    local zSecond = time - zHour * 3600 - zMinute * 60

    local zText = ""

    if zHour > 0 then
        zText = getFulText(zHour)..":"..getFulText(zMinute)..":"..getFulText(zSecond)
    elseif zMinute > 0 then
        zText = getFulText(zMinute)..":"..getFulText(zSecond)
    else
        zText = "00"..":"..getFulText(zSecond)
    end

    return zText
end

-- 没有标点符号
function GetTimeTextNoSymbol(time)
    local function getFulText(num)
        if (num > 9) then
            return tostring(num)
        else
            return "0"..num
        end
    end

    local zHour = math.floor(time / 3600)
    local zMinute = math.floor((time - zHour * 3600) / 60)
    local zSecond = time - zHour * 3600 - zMinute * 60

    local zText = ""

    if zHour > 0 then
        zText = getFulText(zHour).." "..getFulText(zMinute).." "..getFulText(zSecond)
    elseif zMinute > 0 then
        zText = getFulText(zMinute).." "..getFulText(zSecond)
    else
        zText = "00".." "..getFulText(zSecond)
    end

    return zText
end

--显示为：“剩余时间：X天XX小时XX分钟”
--或者	：“剩余时间：X天XX小时XX分钟XX秒”
function GetTimeTextDayHourMinSec(time, showSec)
    local function getFulText( num )
        if (num > 9) then
            return tostring(num)
        else
            return ""..num
        end
    end

    local zDay = math.floor(time / 3600 / 24)
    local zHour = math.floor((time - zDay*24 * 3600) / 3600)
    local zMinute = math.floor((time - zDay*24 * 3600 - zHour*3600) / 60)
    local zSecond = time - zDay*24 * 3600 - zHour * 3600 - zMinute * 60

    local zText = ""

    if zDay > 0 then
        zText = zText..getFulText(zDay).."天"
        if zDay > 0 and zHour > 0 then
            zText = zText..getFulText(zHour).."时"
        end
        if zMinute > 0 then
            zText = zText..getFulText(zMinute).."分"
        end
    else
        if zHour > 0 then
            zText = zText..getFulText(zHour).."时"
        end
        if zMinute > 0 then
            zText = zText..getFulText(zMinute).."分"
        end
    end
    if showSec then
        if zSecond >= 0 then zText = zText..getFulText(zSecond).."秒" end
    end
    return zText
end

function TableToString(v, len)
    len = len or 0
    local pre = string.rep(' ', len)
    local ret = ""
    if type(v) == "table" then
        local isarr = true
        for k, v in pairs(v) do
            if type(k) ~= "number" then
                isarr = false
            end
        end

        local t = ""
        for k, v1 in pairs(v) do
            if isarr then
                t = t .. "\n " .. pre
            else
                t = t .. "\n " .. pre .. "[\""..tostring(k) .. "\"] = "
            end
            t = t .. table.tostring(v1, len + 1)
        end
        if t == "" then
            ret = ret .. pre .. "{}\t"
        else
            if len > 0 then
                ret = ret
            end
            ret = ret .. pre .. "{" .. t .. "\n" .. pre .. "},"
        end
    else
        if type(v) == "string" then
            ret = ret .. "\"".. tostring(v) .. "\","
        else
            ret = ret .. tostring(v) .. ","
        end
    end
    return ret
end

function reverseTable(tab)
	local tmp = {}
	for i = 1, #tab do
		
		tmp[i] = table.remove(tab)
	end

	return tmp
end