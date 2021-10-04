--保险箱登录界面
local ControllerSafeBoxLogin = class("ControllerSafeBoxLogin")

function ControllerSafeBoxLogin:Init()
	self.m_view=UIPackage.CreateObject('hall','safeBoxLoginView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerSafeBoxLogin')
	end)

    --忘记密码
    self.m_view:GetChild("btnForgotPasswd").onClick:Add(function ()
        UIManager.Show('ControllerForgotPasswd',{m_type='SafeBox'})
    end)
    --修改密码
    self.m_view:GetChild("btnSafeBoxChangePasswd").onClick:Add(function ()
        UIManager.Show('ControllerSafeBoxChangePasswd')
    end)
    
    --进入保险箱界面
    self.m_view:GetChild("btnY").onClick:Add(function ()
        coroutine.start(SafeBox_Deposit_Login,{
            userid=loginSucceedInfo.user_info.userid,
            pwd=self.m_view:GetChild('txtPW').text,
            callbackSuccess=function (info)
                UIManager.Show('ControllerSafeBox')
                UIManager.Hide('ControllerSafeBoxLogin')
            end
        })
    end)
end

function ControllerSafeBoxLogin:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

    self.m_view:GetChild('txtPW').text=''
end

function ControllerSafeBoxLogin:OnHide()
	self.m_view.visible=false
end
return ControllerSafeBoxLogin