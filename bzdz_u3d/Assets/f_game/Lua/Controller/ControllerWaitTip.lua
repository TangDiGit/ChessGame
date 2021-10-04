--转圈界面
local ControllerWaitTip = class("ControllerWaitTip")

function ControllerWaitTip:Init()
	self.m_view=UIPackage.CreateObject('main','WaitTipView').asCom
	UIManager.top:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.txt = self.m_view:GetChild("n2").asTextField;
end

function ControllerWaitTip:Show(arg)
    --李总要求
    if true then
        return
    end

	--保持在前面
	UIManager.top:AddChild(self.m_view)
    self.m_view.visible=true
    
    
    arg=arg or {}
    self.txt.text=arg.strTit or ''
    if self.timer then
        self.timer:Stop()
    end
    if arg.timeOut and arg.timeOut>0 then
        self.timer=Timer.New(function ()
            UIManager.Show('ControllerMessageBox',{
                strTit='请求失败,请稍后重试...',
                callY=arg.actionTimeOut
            })
            UIManager.Hide('ControllerWaitTip')
        end,arg.timeOut,1)
        self.timer:Start()
    end
end

function ControllerWaitTip:OnHide()
    self.m_view.visible=false
    if self.timer then
        self.timer:Stop()
    end
end
return ControllerWaitTip