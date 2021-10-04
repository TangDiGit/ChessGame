-- 大厅的提示
local ControllerHallConnectTips = class("ControllerHallConnectTips")

function ControllerHallConnectTips:Init()
    self.m_view = UIPackage.CreateObject('hall', 'hallConnectTipsView').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    -- 取消
    self.m_view:GetChild("btn_confirm").onClick:Add(function ()
        UIManager.Hide('ControllerHallConnectTips')
    end)
end

function ControllerHallConnectTips:Show(arg)
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true
end

function ControllerHallConnectTips:OnHide()
    self.m_view.visible = false
end

return ControllerHallConnectTips

