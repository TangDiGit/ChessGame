-- 比赛场的提示
local ControllerHallDesc = class("ControllerHallDesc")

function ControllerHallDesc:Init()
    self.m_view = UIPackage.CreateObject('hall', 'hallDescView').asCom
    UIManager.top:AddChild(self.m_view)   -- 层级搞高点，换桌会重新刷新界面
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false
    self.m_ctrl_type = self.m_view:GetController("type")

    -- 还需要自动关闭 _com:GetController('type').=3
    self.m_view:GetChild("btnBg").onClick:Add(function ()
        UIManager.Hide('ControllerHallDesc')
    end)

    self.m_view:GetChild("btn_confirm").onClick:Add(function ()
        UIManager.Hide('ControllerHallDesc')
    end)
end

function ControllerHallDesc:Show(arg)
    --保持在前面
    UIManager.top:AddChild(self.m_view)
    self.m_view.visible = true
    self.m_ctrl_type.selectedIndex = arg.type
end

function ControllerHallDesc:OnHide()
    self.m_view.visible = false
end

return ControllerHallDesc

