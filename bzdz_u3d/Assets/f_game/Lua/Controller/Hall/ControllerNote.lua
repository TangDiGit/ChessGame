--留言板界面
local ControllerNote = class("ControllerNote")

function ControllerNote:Init()
	self.m_view=UIPackage.CreateObject('hall','noteView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerNote')
	end)

    self.m_view:GetChild("btnY").onClick:Add(function ()
		UIManager.Hide('ControllerNote')
		UIManager.AddPopTip({strTit='操作成功.'})
	end)
end

function ControllerNote:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

end

function ControllerNote:OnHide()
	self.m_view.visible=false
end
return ControllerNote