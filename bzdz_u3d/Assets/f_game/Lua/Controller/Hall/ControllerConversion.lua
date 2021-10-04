--兑换界面
local ControllerConversion = class("ControllerConversion")

function ControllerConversion:Init()
	self.m_view=UIPackage.CreateObject('hall','conversionView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerConversion')
    end)

    self.m_view:GetChild("btnY").onClick:Add(function ()
		print(self.m_view:GetChild("DuiHuanMaInput").text)
		
		coroutine.start(CDKEY_Use,{
			userid=loginSucceedInfo.user_info.userid,
			exchangecode=self.m_view:GetChild("DuiHuanMaInput").text,
			callbackSuccess=function (info)
				if info.gold then
					setSelfMoney(tonumber(info.gold))
				end
				UIManager.AddPopTip({strTit=info.content})
			end
		})
    end)

end

function ControllerConversion:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.m_view:GetChild("DuiHuanMaInput").text=''
end

function ControllerConversion:OnHide()
	self.m_view.visible=false
end
return ControllerConversion