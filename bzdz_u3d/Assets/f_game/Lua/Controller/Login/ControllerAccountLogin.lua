--账号登入界面
local ControllerAccountLogin = class("ControllerAccountLogin")

function ControllerAccountLogin:Init()
	self.m_view=UIPackage.CreateObject('main','AccountLoginView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerAccountLogin')
	end)

    self.m_PhoneNumberInput=self.m_view:GetChild("PhoneNumberInput")
	self.m_PasswordInput=self.m_view:GetChild("PasswordInput")
	
	self.m_PhoneNumberInput.text=PlayerPrefs.GetString("phoneNumber",'')
	self.m_PasswordInput.text=PlayerPrefs.GetString("pw",'')

	self.m_view:GetChild("btnEnter").onClick:Add(function ()
		--local _unionid=self.m_PhoneNumberInput.text
        --print(self.m_PhoneNumberInput.text)
		--print("账号登陆")

		if utf8.len(self.m_PhoneNumberInput.text)~=11 then
            UIManager.AddPopTip({strTit='手机号长度错误'})
            return
        end

		local password_str = self.m_PasswordInput.text

        if utf8.len(password_str) < 6 or utf8.len(password_str) > 10  then
            UIManager.AddPopTip({strTit='密码长度6-10'})
            return
        end

		login_send({ phone = self.m_PhoneNumberInput.text, password = password_str, })
	end)
end

function ControllerAccountLogin:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

end

function ControllerAccountLogin:OnHide()
	self.m_view.visible=false
end
return ControllerAccountLogin