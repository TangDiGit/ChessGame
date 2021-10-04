-- 比赛场的提示
local ControllerCompetitionFailure = class("ControllerCompetitionFailure")

function ControllerCompetitionFailure:Init()
    self.m_view = UIPackage.CreateObject('competition', 'hotGameFailureView').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    self.m_view:GetChild("btn_close").onClick:Add(function ()
        UIManager.Hide('ControllerCompetitionFailure')
    end)

end

function ControllerCompetitionFailure:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true
end

function ControllerCompetitionFailure:OnHide()
    self.m_view.visible = false
end

return ControllerCompetitionFailure

