-- 比赛场的提示
local ControllerCompetitionTips = class("ControllerCompetitionTips")

function ControllerCompetitionTips:Init()
    self.m_view = UIPackage.CreateObject('competition', 'hotGameTipsView').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    self.m_force_exit = false

    self.m_confirm = nil

    self.m_btn_confirm = self.m_view:GetChild('btn_confirm')

    self.m_tips_title = self.m_view:GetChild('tips_title')
    self.m_tips_cont = self.m_view:GetChild('tips_cont')

    self.m_view:GetChild("btnBg").onClick:Add(function ()
        UIManager.Hide('ControllerCompetitionTips')
        if self.m_force_exit then
            UIManager.GetController('ControllerTexas'):ExitMatchGame()
        end
    end)

    -- 取消
    self.m_view:GetChild("btn_cancel").onClick:Add(function ()
        UIManager.Hide('ControllerCompetitionTips')
        if self.m_force_exit then
            UIManager.GetController('ControllerTexas'):ExitMatchGame()
        end
    end)

    -- 确定
    self.m_btn_confirm.onClick:Add(function ()
        UIManager.Hide('ControllerCompetitionTips')
        if self.m_confirm then
            self.m_confirm()
        end
        if self.m_force_exit then
            UIManager.GetController('ControllerTexas'):ExitMatchGame()
        end
    end)

end

function ControllerCompetitionTips:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true
    self.m_tips_title.text = arg.title
    self.m_tips_cont.text = arg.content

    self.m_confirm = arg.confirm
    --if self.m_confirm then
    --    self.m_btn_confirm.visible = true
    --else
    --    self.m_btn_confirm.visible = false
    --end
    self.m_force_exit = arg.force_exit
end

function ControllerCompetitionTips:OnHide()
    self.m_view.visible = false
end

return ControllerCompetitionTips

