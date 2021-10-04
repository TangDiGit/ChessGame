--修改保险箱密码界面
local ControllerSafeBoxChangePasswd2 = class("ControllerSafeBoxChangePasswd2")

function ControllerSafeBoxChangePasswd2:Init()
	self.m_view=UIPackage.CreateObject('hall','safeBoxChangePasswdView2').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerSafeBoxChangePasswd2')
	end)

	self.m_view:GetChild("btnY").onClick:Add(function ()
		if self.m_view:GetChild('txtPWNew').text~=self.m_view:GetChild('txtPWNew2').text then
			UIManager.AddPopTip({strTit='两次密码不一致'})
			return
		end
        coroutine.start(SafeBox_ChangePasswd,{
            userid=loginSucceedInfo.user_info.userid,
			oldpwd=self.m_view:GetChild('txtPWOld').text,
			newpwd=self.m_view:GetChild('txtPWNew').text,
            callbackSuccess=function (info)
                UIManager.AddPopTip({strTit=info.content})
            end
        });
	end)
end

function ControllerSafeBoxChangePasswd2:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.m_view:GetChild('txtPWOld').text=''
	self.m_view:GetChild('txtPWNew').text=''
	self.m_view:GetChild('txtPWNew2').text=''
end

function ControllerSafeBoxChangePasswd2:OnHide()
	self.m_view.visible=false
end
return ControllerSafeBoxChangePasswd2