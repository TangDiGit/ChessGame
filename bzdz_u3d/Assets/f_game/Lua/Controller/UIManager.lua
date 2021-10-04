UIManager={}
local M=UIManager

local controllerMap={}
function M.Init()
    local root=UnityEngine.GameObject.Find("UIPanel"):GetComponent("UIPanel").ui
    M.bottom=root:GetChild("bottom").asCom
    M.normal=root:GetChild("normal").asCom
    M.top=root:GetChild("top").asCom

    M.InitPopTip()
end

function M.Show(controllerName,arg)
    if not controllerMap[controllerName] then
        controllerMap[controllerName]=UI_Define[controllerName].new()
        controllerMap[controllerName]:Init()
    end
    controllerMap[controllerName]:Show(arg)
end
--界面是否为显示状态
function M.IsShowState(controllerName)
    if not controllerMap[controllerName] then
        return false
    end
    return controllerMap[controllerName].m_view.visible 
end
function M.Hide(controllerName)
    if controllerMap[controllerName] then
        controllerMap[controllerName]:OnHide()
    end
end
--只初始化controller
function M.InitController(controllerName)
    if not controllerMap[controllerName] then
        --print(UI_Define[controllerName])
        controllerMap[controllerName] = UI_Define[controllerName].new()
        controllerMap[controllerName]:Init()
    end
end
--得到一个控制器
function M.GetController(controllerName)
    if controllerMap[controllerName] then
        return controllerMap[controllerName]
    end
end
--适配异形屏
function M.AdaptiveAllotypy(view)
    if GRoot.inst.width/GRoot.inst.height>=2 then
        view:SetSize(GRoot.inst.width, GRoot.inst.height)
        view:GetChild("content"):SetSize(GRoot.inst.width-180, GRoot.inst.height)
    else
        view:SetSize(GRoot.inst.width, GRoot.inst.height)
    end
end

local _prefabOriginalMap={}
--u3d预设
function M.AddPrefab(prefabOriginal)
    _prefabOriginalMap[prefabOriginal.name]=prefabOriginal
end
function M.GetPrefab(name)
    return _prefabOriginalMap[name]
end

--设置u3d龙骨动画 /spine动画
function M.SetDragonBonesAniObjPos(dragonBonesAniName,com,scale)
    local _u3dDragonBonesAniObj=UnityEngine.GameObject.Instantiate(UIManager.GetPrefab(dragonBonesAniName))
    _u3dDragonBonesAniObj.transform.localScale=scale
    com:GetChild("parent").asGraph:SetNativeObject(FairyGUI.GoWrapper(_u3dDragonBonesAniObj))
    return _u3dDragonBonesAniObj
end

function M.SetDragonBonesAniObjPos2(dragonBonesAniName,com,scale)--spine动画名字  承载spine动画的组件  位置
    local _u3dDragonBonesAniObj = UnityEngine.GameObject.Instantiate(UIManager.GetPrefab(dragonBonesAniName))
    _u3dDragonBonesAniObj.transform.localScale = scale --指定大小
    local _gw=FairyGUI.GoWrapper(_u3dDragonBonesAniObj)
    com.asGraph:SetNativeObject(_gw)
    return _gw
end

function M.SetDragonBonesAniObjPos3(dragonBonesAniName,com,scale,pos)--spine动画名字  承载spine动画的组件  位置
    local _u3dDragonBonesAniObj = UnityEngine.GameObject.Instantiate(UIManager.GetPrefab(dragonBonesAniName))
    _u3dDragonBonesAniObj.transform.localScale = scale--指定大小
    _u3dDragonBonesAniObj.transform.localPosition = pos--指定位置
    local _gw=FairyGUI.GoWrapper(_u3dDragonBonesAniObj)
    com.asGraph:SetNativeObject(_gw)
    return _gw
end

--PopTip
local timerPopTip=nil
local isShowPopTip=false
local arrPopTip={}
function M.InitPopTip()
    timerPopTip=Timer.New(function ()
        if isShowPopTip==false and #arrPopTip>0 then
            isShowPopTip=true
            local t=clone(arrPopTip[1])
            table.remove(arrPopTip,1)
            M.Show("ControllerPopTip",t)
        end
    end,0.1,-1)
    timerPopTip:Start()
end

--添加PopTip列表
function M.AddPopTip(arg)
    table.insert(arrPopTip,arg)
end

function M.EndPopTip()
    isShowPopTip=false
end

--设置poker显示
function M.SetPoker(com,card,isTurn)
    if not PokerUrlMap[card] then
        return
    end

    if card <= 0 and isTurn then
        return
    end
    com:GetController("cShowFrame").selectedIndex=0
    com:GetController("cGray").selectedIndex=0
    com:GetController("cStandUp").selectedIndex=0
    com:GetChild("n0").asLoader.url=PokerUrlMap[card]
    
    --只显示牌背
    if card<=0 then
        com:GetChild("n10").visible=true
        com:GetChild("n0").visible=false
    else
        com:GetChild("n10").visible=false
        com:GetChild("n0").visible=true

        if isTurn then
            F_ExtensionCardHelp.ConversionCard(com):Turn()
        end
    end
    
    com.data=card
end

function M.SetPokerCard(com,card)
    com:GetChild("card").asLoader.url = PokerUrlMap[card]
    com:GetChild("card").visible = true
    com:GetChild("cardbg").visible = false
    com.visible = true
end
