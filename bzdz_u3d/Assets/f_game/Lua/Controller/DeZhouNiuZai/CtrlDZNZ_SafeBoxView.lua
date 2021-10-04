
--控制器德州牛仔: 保险箱
local CtrlDZNZ_SafeBoxView = class("CtrlDZNZ_SafeBoxView")



function CtrlDZNZ_SafeBoxView:Init()
	self.m_view=UIPackage.CreateObject('niuzai','niuZaiSafeBoxView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('CtrlDZNZ_SafeBoxView')
    end)
end

function CtrlDZNZ_SafeBoxView:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible = true

end

function CtrlDZNZ_SafeBoxView:OnHide()
	self.m_view.visible = false
end

return CtrlDZNZ_SafeBoxView