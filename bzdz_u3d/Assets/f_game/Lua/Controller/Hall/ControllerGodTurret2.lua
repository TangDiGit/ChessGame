--财神转盘
awardMap={
    [1]={angle=0,tit="踢人卡 x1",localID=1,serverItemID=6,txtContent="恭喜获得 <img src='ui://luckytable/jiao' width='100' height='100'/>   X1"},
    [2]={angle=0,tit="6888 金币",localID=2,serverItemID=5,txtContent="恭喜获得 <img src='ui://luckytable/jinbi' width='100' height='100'/>   X6888"},
    [3]={angle=0,tit="VIP 周卡1张",localID=3,serverItemID=4,txtContent="恭喜获得 <img src='ui://luckytable/VIPhei' width='100' height='100'/>   X1"},
    [4]={angle=0,tit="2888 金币",localID=4,serverItemID=3,txtContent="恭喜获得 <img src='ui://luckytable/jinbi' width='100' height='100'/>   X2888"},
    [5]={angle=0,tit="VIP 月卡1张",localID=5,serverItemID=2,txtContent="恭喜获得 <img src='ui://luckytable/VIPhong' width='100' height='100'/>   X1"},
    [6]={angle=0,tit="3888 金币",localID=6,serverItemID=1,txtContent="恭喜获得 <img src='ui://luckytable/jinbi' width='100' height='100'/>   X3888"},
    [7]={angle=0,tit="谢谢惠顾",localID=7,serverItemID=10},
    [8]={angle=0,tit="99999 金币",localID=8,serverItemID=9,txtContent="恭喜获得 <img src='ui://luckytable/jinbi' width='100' height='100'/>   X99999"},
    [9]={angle=0,tit="喇叭 x1",localID=9,serverItemID=8,txtContent="恭喜获得 <img src='ui://luckytable/laba' width='100' height='100'/>   X1"},
    [10]={angle=0,tit="8888 金币",localID=10,serverItemID=7,txtContent="恭喜获得 <img src='ui://luckytable/jinbi' width='100' height='100'/>   X8888"},
}

local ControllerGodTurret2 = class("ControllerGodTurret2")

function ControllerGodTurret2:Init()
	self.m_view = UIPackage.CreateObject('luckytable', 'luckyTable2').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerGodTurret2')
	end)

    --剩余次数
    self.m_remainCount = self.m_view:GetChild('btn_remain')
    self:InitRecord()

    --self.m_pointer=self.m_view:GetChild("pointer")
    self.m_view:GetChild("btnStart").onClick:Add(function ()
        --print('请求转盘')
        if self.m_waitTimer and self.m_waitTimer.running then
           --print('请求转盘 等待冷却')
            return
        end
        if self.m_leftcount <= 0 then
            UIManager.AddPopTip({strTit='剩余转盘次数不足'})
            return
        end

        self:HideEff()
        self.m_dataInfo = nil
        coroutine.start(Lucky_GoGoGo, {
            userid=loginSucceedInfo.user_info.userid,
            callbackSuccess = function (info)
                if self.m_view.visible then
                    F_SoundManager.instance:PlayEffect('daZhuanPan')
                    self:Go(tonumber(info.yes))
                    self.m_dataInfo=info

                    self.m_waitTimer = Timer.New(function ()
                        self.m_remainCount.text = string.format("抽奖次数:%s", info.leftcount)
                        self.m_leftcount = tonumber(info.leftcount)
                        self:ShowRecord()
                    end,7,1)

                    self.m_waitTimer:Start()
                end
            end
        })
    end)

    UIManager.SetDragonBonesAniObjPos2('caisheObj',self.m_view:GetChild("caishenObjParent"),Vector3.New(160,160,160))
    
    for i=1,10 do
        awardMap[i].com=self.m_view:GetChild('item'..i).asCom
        awardMap[i].mask=awardMap[i].com:GetChild('mask')
        awardMap[i].spineAni=awardMap[i].com:GetChild("spineAni")
        UIManager.SetDragonBonesAniObjPos2('zishaoguangObj',awardMap[i].spineAni,Vector3.New(100,100,100))
    end

    UIManager.SetDragonBonesAniObjPos2('caisheObj',self.m_view:GetChild("caishenUI"),Vector3.New(160,160,160))
end

function ControllerGodTurret2:ServerItemID2LocalItemID(serverItemID)
    for i,v in pairs(awardMap) do
        if v.serverItemID==serverItemID then
            return v
        end
    end
end

function ControllerGodTurret2:Go(serverItemID)
    local _info=self:ServerItemID2LocalItemID(serverItemID)
    --转三圈
    local _endVal=_info.localID+30
    LeanTween.cancel(self.m_view.displayObject.gameObject)
    LeanTween.value(self.m_view.displayObject.gameObject,System.Action_float(function (x)
        local _showID=math.floor(x)%10
        for i=1,10 do
            awardMap[i].mask.visible=false
            if _showID==i then
                awardMap[_showID].mask.visible=true
            end
        end
        
    end),0,_endVal,3):setEaseOutCubic():setOnComplete(System.Action(function ()
        if _info.serverItemID~=10 then
            self.m_view:GetChild('txtZJ').text=_info.txtContent
            self.m_view:GetController('c1').selectedIndex=1
            self.m_view:GetTransition('t1'):Play()
            F_SoundManager.instance:PlayEffect('caiShen')
            awardMap[_info.localID].spineAni.visible=true
            if self.m_timer then
                self.m_timer:Stop()
            end
            self.m_timer=Timer.New(function ()
                self.m_view:GetController('c1').selectedIndex=0
                self:HideEff()
            end,4,1)
            self.m_timer:Start()
        end
        setSelfMoney(tonumber(self.m_dataInfo.gold))
    end))
end

function ControllerGodTurret2:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

    self.m_remainCount.text = string.format("抽奖次数:%s", 0)
    --self.m_view:GetChild('txtCount').text='免费选择剩余次数:0'
    self.m_leftcount = 0
    coroutine.start(Lucky_Residue,{
        userid=loginSucceedInfo.user_info.userid,
        callbackSuccess = function (info)
            self.m_remainCount.text = string.format("抽奖次数:%s", info.leftcount)
            --self.m_view:GetChild('txtCount').text = '免费选择剩余次数:'..info.leftcount
            self.m_leftcount = tonumber(info.leftcount)
        end
    })
    if self.m_timer then
        self.m_timer:Stop()
    end
    self.m_view:GetController('c1').selectedIndex = 0
    self:HideEff()

    self:ShowRecord()
end

function ControllerGodTurret2:InitRecord()
    self.m_list = self.m_view:GetChild('list').asList
    self.m_list:SetVirtual()
    self.m_list.itemRenderer = function (theIndex,theGObj)
        local _com=theGObj.asCom
        local _t = self.m_listData[theIndex+1]
        _com.data = _t
        _com:GetChild('txtDes').text = _t.prize_name
        _com:GetChild('txtTime').text = _t.create_time
    end
    --接受服务器数据后设置
    self.m_list.numItems = 0
    self.m_listData = nil
end

function ControllerGodTurret2:ShowRecord()
    --记录放在外面了
    coroutine.start(Lucky_Log, {
        userid=loginSucceedInfo.user_info.userid,
        callbackSuccess = function (info)
            self.m_listData = info.results
            self.m_list.numItems = #info.results
        end
    })
end

function ControllerGodTurret2:HideEff( )
    for i = 1, 10 do
        awardMap[i].mask.visible = false
        awardMap[i].spineAni.visible = false
    end
end
function ControllerGodTurret2:OnHide()
	self.m_view.visible=false
end
return ControllerGodTurret2