--背包界面
local ControllerBagRename = class("ControllerBagRename")

function ControllerBagRename:Init()
    self.m_viewParent=UIPackage.CreateObject('hall','leftToRightContent').asCom
    UIManager.normal:AddChild(self.m_viewParent)
    self.m_viewParent:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_viewParent.visible=false

    self.m_view=UIPackage.CreateObject('hall','bagRename').asCom
    self.m_viewParent:GetChild('parent'):AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerBagRename')
    end)

    self.m_input_name = self.m_view:GetChild('NickNameInput')

    self.m_view:GetChild("btnY").onClick:Add(function ()
        local input_text = self.m_input_name.text
        if string.len(input_text) > 0 then
            coroutine.start(Person_Update, {
                userid = loginSucceedInfo.user_info.userid,
                nickname = input_text,
                sex = tonumber(loginSucceedInfo.user_info.sex),
                location='',
                note='',
                callbackSuccess = function (info)
                    loginSucceedInfo.user_info.nickname = input_text
                    loginSucceedInfo.user_info.sex = tonumber(loginSucceedInfo.user_info.sex)
                    loginSucceedInfo.user_info.location = ''
                    loginSucceedInfo.user_info.note = ''

                    H_EventDispatcher:dispatchEvent({name='refreshSelfName'})

                    self.m_input_name.text = ""
                    UIManager.AddPopTip({strTit='昵称修改成功'})
                end
            })
        else
            UIManager.AddPopTip({strTit='请输入正确的昵称'})
        end
    end)
end

function ControllerBagRename:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_viewParent)
    self.m_viewParent.visible=true
    self.m_viewParent:GetTransition('t0'):Play()
    self.m_input_name.text = ""
end

function ControllerBagRename:OnHide()
    self.m_viewParent.visible=false
end
return ControllerBagRename