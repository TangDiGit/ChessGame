--财神转盘
awardMap={
    [1]={angle=-15,tit="VIP 周卡1张",localID=1,serverItemID=4,txtContent="恭喜获得 <img src='ui://luckytable/VIPhei' width='100' height='100'/>   X1"},
    [2]={angle=19.3,tit="2888 金币",localID=2,serverItemID=3,txtContent="恭喜获得 <img src='ui://luckytable/jinbi' width='100' height='100'/>   X2888"},
    [3]={angle=54.6,tit="VIP 月卡1张",localID=3,serverItemID=2,txtContent="恭喜获得 <img src='ui://luckytable/VIPhong' width='100' height='100'/>   X1"},
    [4]={angle=91.5,tit="3888 金币",localID=4,serverItemID=1,txtContent="恭喜获得 <img src='ui://luckytable/jinbi' width='100' height='100'/>   X3888"},
    [5]={angle=125,tit="谢谢惠顾",localID=5,serverItemID=10},
    [6]={angle=158.4,tit="99999 金币",localID=6,serverItemID=9,txtContent="恭喜获得 <img src='ui://luckytable/jinbi' width='100' height='100'/>   X99999"},
    [7]={angle=196.6,tit="喇叭 x1",localID=7,serverItemID=8,txtContent="恭喜获得 <img src='ui://luckytable/laba' width='100' height='100'/>   X1"},
    [8]={angle=233.4,tit="8888 金币",localID=8,serverItemID=7,txtContent="恭喜获得 <img src='ui://luckytable/jinbi' width='100' height='100'/>   X8888"},
    [9]={angle=270.9,tit="踢人卡 x1",localID=9,serverItemID=6,txtContent="恭喜获得 <img src='ui://luckytable/jiao' width='100' height='100'/>   X1"},
    [10]={angle=305.6,tit="6888 金币",localID=10,serverItemID=5,txtContent="恭喜获得 <img src='ui://luckytable/jinbi' width='100' height='100'/>   X6888"},
}

local ControllerGodTurret = class("ControllerGodTurret")

function ControllerGodTurret:Init()
	self.m_view=UIPackage.CreateObject('luckytable','luckyTable').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerGodTurret')
	end)

    --指针


    self.m_pointer=self.m_view:GetChild("pointer")
    self.m_view:GetChild("btnGo").onClick:Add(function ()
        print('请求转盘')
        if self.m_waitTimer and self.m_waitTimer.running then
            print('请求转盘 等待冷却')
            return
        end

        if self.m_leftcount<=0 then
            UIManager.AddPopTip({strTit='剩余转盘次数不足.'})
            return
        end

        self.m_waitTimer=Timer.New(function ()
            
        end,7,1)
        self.m_waitTimer:Start()

        
        self.m_dataInfo=nil
        coroutine.start(Lucky_GoGoGo,{
            userid=loginSucceedInfo.user_info.userid,
            callbackSuccess=function (info)
                self:Go(tonumber(info.yes))
                self.m_view:GetChild('n6').text=info.leftcount
                self.m_leftcount=tonumber(info.leftcount)
                self.m_dataInfo=info
                F_SoundManager.instance:PlayEffect('daZhuanPan');
            end
        });
    end)
    
    --记录
    self.m_view:GetChild("btnRecord").onClick:Add(function ()
        print('请求记录')
        coroutine.start(Lucky_Log,{
            userid=loginSucceedInfo.user_info.userid,
            callbackSuccess=function (info)
                UIManager.Show('ControllerLuckyTableLog',info)
            end
        });
        
    end)
    
    UIManager.SetDragonBonesAniObjPos2('caisheObj',self.m_view:GetChild("caishenObjParent"),Vector3.New(160,160,160))
    
end

function ControllerGodTurret:ServerItemID2LocalItemID(serverItemID)
    for i,v in pairs(awardMap) do
        if v.serverItemID==serverItemID then
            return v
        end
    end
end
function ControllerGodTurret:Go(serverItemID)
    local _info=self:ServerItemID2LocalItemID(serverItemID)
    local _endVal=_info.angle
    LeanTween.cancel(self.m_view.displayObject.gameObject);
    LeanTween.value(self.m_view.displayObject.gameObject,System.Action_float(function (x)
        self.m_pointer.rotation=x
    end),0,1080+_endVal,3):setEaseOutCubic():setOnComplete(System.Action(function ()
        print('end')

        --[[UIManager.Show('ControllerMessageBox',{
            strTit=_info.tit
        })]]
        setSelfMoney(tonumber(self.m_dataInfo.gold))
        if _info.serverItemID~=10 then
            self.m_view:GetChild('n13').text=_info.txtContent
            self.m_view:GetController('c1').selectedIndex=1
            self.m_view:GetTransition('t1'):Play()
            F_SoundManager.instance:PlayEffect('caiShen');
            if self.m_timer then
                self.m_timer:Stop()
            end
            self.m_timer=Timer.New(function ()
                self.m_view:GetController('c1').selectedIndex=0
            end,4,1)
            self.m_timer:Start()
        end
    end))
end

function ControllerGodTurret:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

    self.m_view:GetChild('n6').text=''
    self.m_leftcount=0
    print('请求转盘剩余次数')
    coroutine.start(Lucky_Residue,{
        userid=loginSucceedInfo.user_info.userid,
        callbackSuccess=function (info)
            self.m_view:GetChild('n6').text=info.leftcount
            self.m_leftcount=tonumber(info.leftcount)
        end
    });
    if self.m_timer then
        self.m_timer:Stop()
    end
    self.m_view:GetController('c1').selectedIndex=0
end

function ControllerGodTurret:OnHide()
	self.m_view.visible=false
end
return ControllerGodTurret