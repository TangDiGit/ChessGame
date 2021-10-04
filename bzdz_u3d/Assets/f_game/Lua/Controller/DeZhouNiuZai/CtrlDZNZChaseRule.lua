local CtrlDZNZChaseRule = class("CtrlDZNZChaseRule")

function CtrlDZNZChaseRule:Init()
    self.m_view = UIPackage.CreateObject('niuzai', 'niuZaiChaseRuleView').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('CtrlDZNZChaseRule')
    end)
end

function CtrlDZNZChaseRule:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true
end

function CtrlDZNZChaseRule:OnHide()
    self.m_view.visible = false
end

return CtrlDZNZChaseRule

