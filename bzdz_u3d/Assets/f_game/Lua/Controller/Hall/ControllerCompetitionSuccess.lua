-- 比赛场的提示
local ControllerCompetitionSuccess = class("ControllerCompetitionSuccess")

function ControllerCompetitionSuccess:Init()
    self.m_view = UIPackage.CreateObject('competition', 'hotGameSuccessView').asCom
    UIManager.top:AddChild(self.m_view)   -- 层级搞高点，换桌会重新刷新界面
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    -- 还需要自动关闭
    self.m_view:GetChild("btn_cancel").onClick:Add(function ()
        UIManager.Hide('ControllerCompetitionSuccess')
    end)
end

function ControllerCompetitionSuccess:Show(arg)
    --保持在前面
    UIManager.top:AddChild(self.m_view)
    self.m_view.visible = true

    self.m_close_cd = Timer.New(function ()
        UIManager.Hide('ControllerCompetitionSuccess')
    end, 5, 1):Start()
end

function ControllerCompetitionSuccess:CloseCd()
    if self.m_close_cd then
        self.m_close_cd:Stop()
        self.m_close_cd = nil
    end
end

function ControllerCompetitionSuccess:OnHide()
    self:CloseCd()
    self.m_view.visible = false
end

return ControllerCompetitionSuccess

