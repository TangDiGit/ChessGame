--举报界面
local ControllerReport = class("ControllerReport")

function ControllerReport:Init()
	self.m_view=UIPackage.CreateObject('hall','reportView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerReport')
	end)

    self.m_view:GetChild("btnY").onClick:Add(function ()
		UIManager.Hide('ControllerReport')
		UIManager.AddPopTip({strTit='操作成功.'})
	end)
end

function ControllerReport:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

end

function ControllerReport:OnHide()
	self.m_view.visible=false
end
return ControllerReport