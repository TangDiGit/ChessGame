--游戏内查看奖池信息 中奖统计
local ControllerPrizePoolStatistical = class("ControllerPrizePoolStatistical")

function ControllerPrizePoolStatistical:Init()
	self.m_view=UIPackage.CreateObject('texas','texasPrizePoolStatisticalView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerPrizePoolStatistical')
	end)
	
end

function ControllerPrizePoolStatistical:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	local _info=json.decode(arg.result)
	self.m_view:GetChild('txtValue1').text=_info.firstcount..'次'  
	self.m_view:GetChild('txtValue2').text=_info.secondcount..'次'  
	self.m_view:GetChild('txtValue3').text=_info.thirdcount..'次'    
	self.m_view:GetChild('txtValueSum').text=_info.wintotal
end

function ControllerPrizePoolStatistical:OnHide()
	self.m_view.visible=false
end
return ControllerPrizePoolStatistical