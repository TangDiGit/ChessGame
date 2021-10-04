--FGUI Com对象池
H_ComPoolManager={}
local M=H_ComPoolManager
local _poolMap={}
function M.GetComFromPool(pkgName,resName)
    local _key=pkgName..'|'..resName
    if not _poolMap[_key] then
        _poolMap[_key]={}
    end
    for i,v in pairs(_poolMap[_key]) do
        if not v.isUse then
            v.isUse=true
            v.com.visible=true
            return v.com
        end
    end
    local _t={isUse=true,com=UIPackage.CreateObject(pkgName,resName).asCom}
    table.insert(_poolMap[_key],_t)
    _t.com.visible=true
    return _t.com
end
function M.RemoveComToPool(com)
    for i,v in pairs(_poolMap) do
        for i2,v2 in pairs(v) do
            if v2.com.id==com.id then
                v2.isUse=false
                v2.com.visible=false
                if GTween.IsTweening(v2.com) then
                    GTween.GetTween(v2.com):OnComplete(function ()
                    end):OnStart(function ()
                    end):SetDelay(0)
                    
                end
                GTween.Kill(v2.com)
                GRoot.inst:AddChild(v2.com);
                return
            end
        end
    end
    print('RemoveComToPool err')
end


