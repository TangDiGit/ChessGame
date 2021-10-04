local ControllerGetAA = class("ControllerGetAA")

function ControllerGetAA:Init()
    self.m_view = UIPackage.CreateObject('texas', 'texasGetAA').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false
    self.m_tips = self.m_view:GetChild('tips')

    self.m_view:GetChild("btnBg").onClick:Add(function ()
        UIManager.Hide('ControllerGetAA')
    end)
end

function ControllerGetAA:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true
    self.m_tips.text = string.format("恭喜你拿到手牌AA 奖励（[color=#E6BC57]%s[/color]）金币，奖励已发放至您的保险箱", arg.num)
end

function ControllerGetAA:OnHide()
    self.m_view.visible = false
end

return ControllerGetAA

