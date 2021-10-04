--百人场说明界面
local ControllerBaiRenDes = class("ControllerBaiRenDes")

function ControllerBaiRenDes:Init()
	self.m_view=UIPackage.CreateObject('bairen','baiRenDesView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerBaiRenDes')
    end)
end

function ControllerBaiRenDes:Show(arg)
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true
end

function ControllerBaiRenDes:OnHide()
	self.m_view.visible=false
end
return ControllerBaiRenDes