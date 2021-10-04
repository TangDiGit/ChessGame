--临时头像
local _tempHeadUrl={
'https://pic4.zhimg.com/v2-9bd8f3b3a0d9eaf67989a00fc4e7bb56_xl.jpg',
'https://pic3.zhimg.com/7c9f997f084b91df4f7b391ad0893147_xl.jpg',
'https://pic4.zhimg.com/v2-62fbf69ea73030471f11e475c72b8e78_xl.jpg',
'https://pic4.zhimg.com/v2-590a26b33fbb92df6218a70a60990011_xl.jpg',
'https://pic4.zhimg.com/v2-8c04205aa7ac27d5fd6723fcdc0031ac_xl.jpg',
'https://pic1.zhimg.com/v2-73083c109c8a48a53dce448dba892496_xl.jpg',
'https://pic1.zhimg.com/v2-73d925fac48a954103c044c6eda9c59a_xl.jpg',
'https://pic1.zhimg.com/v2-5ea9a91a41732618aba11ce1d68d3c98_xl.jpg',
'https://pic1.zhimg.com/v2-c11e961ccd8c4d28a0cbff080a5e2f91_xl.jpg',
'https://pic4.zhimg.com/b5543496123681127f392870b4e413a9_xl.jpg',
'https://pic1.zhimg.com/d5c5a7989a9e3d32d1835b5f8cc4e6e2_xl.jpg',
'https://pic3.zhimg.com/v2-ff9944d0c0e97fe6795a742765b2f84d_xl.jpg',
'https://pic3.zhimg.com/v2-ad52763b5348c881409d4d60b19c0f16_t.jpg',
'https://pic3.zhimg.com/v2-001b27b238d9c05f484ddfffc8c2217b_xl.jpg',
'https://pic2.zhimg.com/v2-78f8a972b7469dd8d6287d4f2e28da5d_xl.jpg',
'https://pic4.zhimg.com/v2-b7060e369cbba40dd4907913f84a4bb1_xl.jpg',
'https://pic1.zhimg.com/v2-776d2dfc376a7a8de0c454d40e1555b1_xl.jpg',
'https://pic3.zhimg.com/v2-8fcfc3f42d804bae450d417bccbda790_xl.jpg',
'https://pic4.zhimg.com/v2-19231137289accfbe4c7a2cfec59dba4_xl.jpg',
'https://pic2.zhimg.com/v2-47cbfb0336b5f8701d90b62f7212bf08_xl.jpg',
'https://pic4.zhimg.com/v2-d8ae31100dbee45755b75ee8b91b3965_xl.jpg',
'https://pic4.zhimg.com/v2-c3283a48d46413a37c1d31c001a35ce0_xl.jpg',
'https://pic4.zhimg.com/v2-73d09e6df9ed0e3b1d7ce6ef99237994_xl.jpg',
'https://pic4.zhimg.com/382835c78bd487bda8afde8b3f8dceb3_xl.jpg',
'https://pic1.zhimg.com/v2-059648d9d0aa7176d9eae6624944033a_xl.jpg',
'https://pic1.zhimg.com/v2-a814a9180651cd4d6b335c6e6aab2ff8_xl.jpg',
}



--注册账号界面
local ControllerReg = class("ControllerReg")

function ControllerReg:Init()
    self.m_view=UIPackage.CreateObject('main','AccountRegisterView').asCom
    UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
        
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerReg')
    end)

    self.m_PhoneNumberInput=self.m_view:GetChild("PhoneNumberInput")
    self.m_PasswordInput=self.m_view:GetChild("PasswordInput")
    self.m_VerifyCodeInput=self.m_view:GetChild("VerifyCodeInput")

    
	self.m_view:GetChild("btnRegisterEnter").onClick:Add(function ()
        print('注册并登录')
        if utf8.len(self.m_PhoneNumberInput.text)~=11 then
            UIManager.AddPopTip({strTit='手机号长度错误'})
            return
        end
        if utf8.len(self.m_PasswordInput.text)<6 or utf8.len(self.m_PasswordInput.text)>10  then
            UIManager.AddPopTip({strTit='密码长度6-10'})
            return
        end
        if utf8.len(self.m_VerifyCodeInput.text)<=0 then
            UIManager.AddPopTip({strTit='请输入验证码'})
            return
        end

        print(self.m_PhoneNumberInput.text)
        print(self.m_PasswordInput.text)
        print(self.m_VerifyCodeInput.text)

        local _funLogin = function ()
            login_send({ phone=self.m_PhoneNumberInput.text, password=self.m_PasswordInput.text, })
        end

        local _userinfo = {
            phone=self.m_PhoneNumberInput.text,
            smscode=self.m_VerifyCodeInput.text,
            password=self.m_PasswordInput.text,
            nickname=GetRandomName()
        }

        coroutine.start(reg,{
            userinfo=json.encode(_userinfo),
            callbackSuccess=_funLogin
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

function ControllerReg:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible=true
end

function ControllerReg:OnHide()
	self.m_view.visible=false
end
return ControllerReg