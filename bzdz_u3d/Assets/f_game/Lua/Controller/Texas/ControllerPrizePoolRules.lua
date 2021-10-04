--游戏内查看奖池信息 中奖统计
local ControllerPrizePoolRules = class("ControllerPrizePoolRules")

function ControllerPrizePoolRules:Init()
	self.m_view=UIPackage.CreateObject('texas','texasPrizePoolRulesView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerPrizePoolRules')
	end)
	
end

function ControllerPrizePoolRules:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	
end

function ControllerPrizePoolRules:OnHide()
	self.m_view.visible=false
end
return ControllerPrizePoolRules