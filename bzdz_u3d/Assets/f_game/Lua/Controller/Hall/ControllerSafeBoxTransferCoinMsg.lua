--保险箱转账金额确定
local ControllerSafeBoxTransferCoinMsg = class("ControllerSafeBoxTransferCoinMsg")

function ControllerSafeBoxTransferCoinMsg:Init()
	self.m_view=UIPackage.CreateObject('hall','safeBoxTransferCoinMsgView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerSafeBoxTransferCoinMsg')
	end)

    self.m_view:GetChild("btnY").onClick:Add(function ()
        if self.data.state==0 then
            UIManager.Hide('ControllerSafeBoxTransferCoinMsg')
            return
        end
		coroutine.start(SafeBox_Deposit_Transfer,{
            sUserid=loginSucceedInfo.user_info.userid,
            dUserid=self.data.dUserid,
            gold=self.data.val,
            callbackSuccess=function (info)
                if self.data.callback then
                    self.data.callback(info)
                    UIManager.Hide('ControllerSafeBoxTransferCoinMsg')
                    UIManager.AddPopTip({strTit=info.content})
                end
            end
        });
	end)
end

function ControllerSafeBoxTransferCoinMsg:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true
    self.data=arg
    self.m_view:GetController('c1').selectedIndex=self.data.state
    if self.data.state==1 then
        self.m_view:GetChild('head'):GetChild('icon').asLoader.url=HandleWXIcon(self.data.headurl)
	    self.m_view:GetChild('txtNickName').text="昵称："..self.data.nickname
        self.m_view:GetChild('txtID').text="ID："..self.data.userid
        self.m_view:GetChild('n12').text=string.format( "转账数量：[color=#FFB400]%s[/color]", formatVal(self.data.val))
    end
    
end

function ControllerSafeBoxTransferCoinMsg:OnHide()
	self.m_view.visible=false
end
return ControllerSafeBoxTransferCoinMsg