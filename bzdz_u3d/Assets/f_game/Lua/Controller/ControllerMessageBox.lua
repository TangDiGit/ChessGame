--弹窗提示界面
local ControllerMessageBox = class("ControllerMessageBox")

function ControllerMessageBox:Init()
	self.m_view=UIPackage.CreateObject('main','MessageBoxView').asCom
	UIManager.top:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.txt = self.m_view:GetChild("n8").asTextField
    self.btnY = self.m_view:GetChild("btnY").asButton
    self.btnN = self.m_view:GetChild("btnN").asButton
end

function ControllerMessageBox:Show(arg)
	--保持在前面
	UIManager.top:AddChild(self.m_view)
    self.m_view.visible=true
    
    self.txt.text=arg.strTit
    self.btnY.text=arg.strY or "确定"
    self.btnN.text=arg.strN or "取消"
    self.btnN.visible=arg.callN and true or false
    self.m_view:GetController("c1").selectedIndex=arg.callN and 1 or 0
    self.btnY:RemoveEventListeners()
    self.btnN:RemoveEventListeners()
    self.btnY.onClick:Add(function ()
        if arg.callY then
            arg.callY()
        end
        UIManager.Hide('ControllerMessageBox')
    end)
    self.btnN.onClick:Add(function ()
        if arg.callN then
            arg.callN()
        end
        UIManager.Hide('ControllerMessageBox')
    end)
end

function ControllerMessageBox:OnHide()
	self.m_view.visible=false
end
return ControllerMessageBox