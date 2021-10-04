--游戏内查看踢掉某位玩家
local ControllerOutPlayer = class("ControllerOutPlayer")

function ControllerOutPlayer:Init()
	self.m_view=UIPackage.CreateObject('texas','texasKickingView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerOutPlayer')
    end)
	self.m_view:GetChild("btn1").onClick:Add(function ()
        print('同意')
        self:Send(2)
    end)
    self.m_view:GetChild("btn0").onClick:Add(function ()
        print('拒绝')
        self:Send(3)
    end)

    H_NetMsg:addEventListener('TPersonCardResponse',function (arg)
        print('收到消息 TPersonCardResponse')
        local msg = Protol.Poker_pb.TPersonCardResponse()
        msg:ParseFromString(arg.pb_data)
        print(tostring(msg))
        gameData.seq=msg.seq

        if UIManager.GetController('ControllerTexas'):GetPlayerWithUserID(msg.touserid)==nil then
            UIManager.AddPopTip({strTit='当前玩家不存在'})
            print('当前玩家不存在')
            return
        end
        local _toInfo=json.decode(UIManager.GetController('ControllerTexas'):GetPlayerWithUserID(msg.touserid):GetBaseData().info)
        self.m_toInfo=_toInfo
        self.m_view:GetChild("btn1").enabled=true
        self.m_view:GetChild("btn0").enabled=true
        if loginSucceedInfo.user_info.userid==msg.fromuserid then
            self.m_view:GetChild("btn1").enabled=false
            self.m_view:GetChild("btn0").enabled=false
        end
        --如果是被踢的玩家是自己
        if loginSucceedInfo.user_info.userid==msg.touserid then
            UIManager.Hide('ControllerOutPlayer')
            return
        end
        if msg.req_type==4 then
            UIManager.AddPopTip({strTit=string.format( "踢出玩家:%s成功",_toInfo.nickname),dt=2})
            UIManager.Hide('ControllerOutPlayer')
            return
        end
        if msg.req_type==5 then
            UIManager.AddPopTip({strTit=string.format( "踢出玩家:%s失败",_toInfo.nickname)})
            UIManager.Hide('ControllerOutPlayer')
            return
        end
        if msg.req_type==1 then
            self:Show()
            self.m_d=10
        end
        self.m_view:GetChild('n7').asProgress.value = msg.agree_count/msg.total_count*100
        self.m_view:GetChild('txt1').text=msg.agree_count
        self.m_view:GetChild('txt0').text=msg.reject_count

        local _fromInfo=json.decode(UIManager.GetController('ControllerTexas'):GetPlayerWithUserID(msg.fromuserid):GetBaseData().info)
        self.m_view:GetChild('n1').text=string.format( "玩家:[color=#E6BC57]%s[/color]发起投票踢人",_fromInfo.nickname)

        
        self.m_view:GetChild('head'):GetChild("icon").asLoader.url=HandleWXIcon(_toInfo.headurl)
        self.m_view:GetChild('txtNickName').text=_toInfo.nickname

        
    end)

    self.m_txt_djs=self.m_view:GetChild('n12')
    self.m_d=nil
    Timer.New(function ()
        if self.m_d and self.m_d>=0 then
            self.m_txt_djs.text=string.format( "(%ss)",self.m_d)
            self.m_d=self.m_d-1
            if self.m_d<=0 then
                UIManager.Hide('ControllerOutPlayer')
            end
        end
    end,1,-1):Start()
end

function ControllerOutPlayer:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

end

function ControllerOutPlayer:OnHide()
	self.m_view.visible=false
end
function ControllerOutPlayer:Send(req_type)
    local msg = Protol.Poker_pb.TPersonCardRequest()
    msg.seq=gameData.seq
   	msg.fromuserid=loginSucceedInfo.user_info.userid
    msg.touserid=self.m_toInfo.userid
    msg.req_type=req_type
    	
    local pb_data = msg:SerializeToString()
    NetManager.SendMessage(GameServerConfig.logic,'TPersonCardRequest',pb_data)
    
    UIManager.Hide('ControllerOutPlayer')
end
return ControllerOutPlayer