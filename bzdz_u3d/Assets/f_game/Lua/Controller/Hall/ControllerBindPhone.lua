--绑定手机界面
local ControllerBindPhone = class("ControllerBindPhone")

function ControllerBindPhone:Init()
	self.m_view=UIPackage.CreateObject('hall','bindPhoneView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerBindPhone')
	end)

	self.m_PhoneNumberInput=self.m_view:GetChild("txtPhone")
	self.m_VerifyCodeInput=self.m_view:GetChild("txtVerifyCode")
    self.m_view:GetChild("btnY").onClick:Add(function ()
		print('请求绑定手机')
		if utf8.len(self.m_PhoneNumberInput.text)~=11 then
            UIManager.AddPopTip({strTit='手机号长度错误'})
            return
        end
        
        if utf8.len(self.m_VerifyCodeInput.text)<=0 then
            UIManager.AddPopTip({strTit='请输入验证码'})
            return
		end
		
		coroutine.start(Phone_Bind,{
			phone=self.m_PhoneNumberInput.text,
			userid=loginSucceedInfo.user_info.userid,
			smscode=self.m_VerifyCodeInput.text,
            callbackSuccess=function (info)
				UIManager.AddPopTip({strTit=info.content})
				loginSucceedInfo.user_info.phone=self.m_PhoneNumberInput.text
			end
        });
	end)

	self.m_btnVerifyCode=self.m_view:GetChild("btnVerifyCode")
    self.m_btnVerifyCode.onClick:Add(function ()
        print('获取验证码')
        if utf8.len(self.m_PhoneNumberInput.text)~=11 then
            return
        end
        if self.m_timer==nil then
            print('请求验证码')
            coroutine.start(Phone_GetCode,{
                phone=self.m_PhoneNumberInput.text
            });
            local _val=30
            self.m_btnVerifyCode.text=string.format( "(%s)",_val)
            self.m_timer=Timer.New(function ()
                _val=_val-1
                self.m_btnVerifyCode.text=string.format( "(%s)",_val)
                if _val<=0 then
                    self.m_btnVerifyCode.text='获取验证码'
                    self.m_timer=nil
                end
            end,1,30)
            self.m_timer:Start()
        end
	end)
end

function ControllerBindPhone:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

end

function ControllerBindPhone:OnHide()
	self.m_view.visible=false
end
return ControllerBindPhone