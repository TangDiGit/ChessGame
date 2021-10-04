--保险箱登录界面
local ControllerSafeBoxLogin2 = class("ControllerSafeBoxLogin2")

function ControllerSafeBoxLogin2:Init()
    self.m_viewParent=UIPackage.CreateObject('hall','leftToRightContent').asCom
	UIManager.normal:AddChild(self.m_viewParent)
	self.m_viewParent:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_viewParent.visible=false

	self.m_view=UIPackage.CreateObject('hall','safeBoxLoginView2').asCom
	self.m_viewParent:GetChild('parent'):AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerSafeBoxLogin2')
	end)

    --忘记密码
    self.m_view:GetChild("btnForgotPasswd").onClick:Add(function ()
        UIManager.Show('ControllerForgotPasswd2',{m_type='SafeBox'})
    end)
    --修改密码
    self.m_view:GetChild("btnSafeBoxChangePasswd").onClick:Add(function ()
        UIManager.Show('ControllerSafeBoxChangePasswd2')
    end)
    
    --进入保险箱界面
    self.m_view:GetChild("btnY").onClick:Add(function ()
        coroutine.start(SafeBox_Deposit_Login,{
            userid=loginSucceedInfo.user_info.userid,
            pwd=self.m_view:GetChild('txtPW').text,
            callbackSuccess=function (info)
                UIManager.Show('ControllerSafeBox2')
                UIManager.Hide('ControllerSafeBoxLogin2')
                UIManager.GetController('ControllerUserInfo2'):SetTopOneUPUPUP()
            end
        });
        
    end)
end

function ControllerSafeBoxLogin2:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_viewParent)
	self.m_viewParent.visible=true
    self.m_viewParent:GetTransition('t0'):Play()

    self.m_view:GetChild('txtPW').text=''
end

function ControllerSafeBoxLogin2:OnHide()
	self.m_viewParent.visible=false
end
return ControllerSafeBoxLogin2