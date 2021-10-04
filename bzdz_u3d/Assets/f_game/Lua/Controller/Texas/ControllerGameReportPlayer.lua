 --玩家信息->举报玩家
local ControllerGameReportPlayer = class("ControllerGameReportPlayer")

function ControllerGameReportPlayer:Init()
	self.m_view=UIPackage.CreateObject('texas','texasReportView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btn0").onClick:Add(function ()
        UIManager.Hide('ControllerGameReportPlayer')
    end)
    self.m_view:GetChild("btn1").onClick:Add(function ()
        UIManager.Hide('ControllerGameReportPlayer')

        UIManager.AddPopTip({strTit='操作成功.'})
    end)
end

function ControllerGameReportPlayer:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
    self.m_view.visible=true
end

function ControllerGameReportPlayer:OnHide()
	self.m_view.visible=false
end
return ControllerGameReportPlayer