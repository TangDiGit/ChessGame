--游戏内查看围观玩家
local ControllerOnLook = class("ControllerOnLook")

function ControllerOnLook:Init()
	self.m_view=UIPackage.CreateObject('texas','texasOnlookerView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerOnLook')
    end)
end

function ControllerOnLook:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

end

function ControllerOnLook:OnHide()
	self.m_view.visible=false
end
return ControllerOnLook