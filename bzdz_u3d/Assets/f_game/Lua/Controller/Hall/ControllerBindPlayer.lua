--保险箱登录界面
local ControllerBindPlayer = class("ControllerBindPlayer")

function ControllerBindPlayer:Init()
    self.m_viewParent=UIPackage.CreateObject('hall','leftToRightContent').asCom
    UIManager.normal:AddChild(self.m_viewParent)
    self.m_viewParent:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_viewParent.visible=false

    self.m_view=UIPackage.CreateObject('hall','bindPlayer').asCom
    self.m_viewParent:GetChild('parent'):AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerBindPlayer')
    end)

    --绑定接口
    self.m_view:GetChild("btnY").onClick:Add(function ()
        local input_str = self.m_view:GetChild('txtPW').text
        if #input_str > 0 and tonumber(input_str) then
            coroutine.start(function ()
                local _www = WWW(string.format(
                        Url_Personal_bingUser,
                        loginSucceedInfo.user_info.userid,
                        input_str,
                        loginSucceedInfo.token
                ))
                coroutine.www(_www)
                local _info = json.decode(_www.text)
                UIManager.AddPopTip({ strTit = _info.msg })
            end)
        else
            UIManager.AddPopTip({ strTit = "请正确输入玩家id！" })
        end
    end)
end

function ControllerBindPlayer:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_viewParent)
    self.m_viewParent.visible=true
    self.m_viewParent:GetTransition('t0'):Play()
    self.m_view:GetChild('txtPW').text=''
end

function ControllerBindPlayer:OnHide()
    self.m_viewParent.visible=false
end

return ControllerBindPlayer