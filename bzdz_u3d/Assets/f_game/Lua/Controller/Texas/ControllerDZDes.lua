--游戏内查看德州玩法说明
local ControllerDZDes = class("ControllerDZDes")

function ControllerDZDes:Init()
	self.m_view=UIPackage.CreateObject('texas','dzDesView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerDZDes')
    end)
end
function ControllerDZDes:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
    self.m_view.visible=true
end
function ControllerDZDes:OnHide()
	self.m_view.visible=false
end
return ControllerDZDes