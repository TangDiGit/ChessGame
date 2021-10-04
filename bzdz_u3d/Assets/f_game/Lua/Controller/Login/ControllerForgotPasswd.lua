--修改密码界面
local ControllerForgotPasswd = class("ControllerForgotPasswd")

function ControllerForgotPasswd:Init()
	self.m_view=UIPackage.CreateObject('main','ForgotPasswdView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerForgotPasswd')
    end)
    
    self.m_PhoneNumberInput=self.m_view:GetChild("PhoneNumberInput")
    self.m_PasswordInput=self.m_view:GetChild("PasswordInput")
    self.m_VerifyCodeInput=self.m_view:GetChild("VerifyCodeInput")

    
	self.m_view:GetChild("btnEnter").onClick:Add(function ()
        print('修改密码并登录')
        print(self.m_PhoneNumberInput.text)
        print(self.m_PasswordInput.text)
        print(self.m_VerifyCodeInput.text)

        if self.data.m_type=='Login' then
            --登录忘记密码
            coroutine.start(Login_ForgotPasswd,{
                phone=self.m_PhoneNumberInput.text,
                smscode=self.m_VerifyCodeInput.text,
                newpwd=self.m_PasswordInput.text,
                callbackSuccess=function (info)
                    UIManager.AddPopTip({strTit=info.content})
                end
            });
        else
            --保险箱忘记密码
            coroutine.start(SafeBox_ForgotPasswd,{
                phone=self.m_PhoneNumberInput.text,
                smscode=self.m_VerifyCodeInput.text,
                newpwd=self.m_PasswordInput.text,
                callbackSuccess=function (info)
                    UIManager.AddPopTip({strTit=info.content})
                end
            });
        end
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

function ControllerForgotPasswd:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

    self.data=arg
    self.m_PhoneNumberInput.text=''
    self.m_VerifyCodeInput.text=''
    self.m_PasswordInput.text=''
end

function ControllerForgotPasswd:OnHide()
	self.m_view.visible=false
end
return ControllerForgotPasswd