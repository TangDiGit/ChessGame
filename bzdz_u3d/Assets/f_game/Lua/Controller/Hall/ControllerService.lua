--客服界面
local ControllerService = class("ControllerService")

function ControllerService:Init()
	self.m_view=UIPackage.CreateObject('hall','serviceView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerService')
	end)

    self.m_view:GetChild("btnReport").onClick:Add(function ()
		UIManager.Show('ControllerReport')
		--todo朋友圈
		--print('朋友圈')
		--F_MobManager.instance:FenXiangPYQ("【嗨游互娱】,随时随地约上三五好友玩起来!亲,大家都在玩,就等你了!", "http://www.haiyouchina.site/");
        --截图分享朋友圈
        --F_MobManager.instance:FenXiangPYQWithScreenshot();
    end)
    self.m_view:GetChild("btnNote").onClick:Add(function ()
		UIManager.Show('ControllerNote')
		--todo分享微信
		--print('微信')
		--F_MobManager.instance:FenXiangWX("【嗨游互娱】","随时随地约上三五好友玩起来!亲,大家都在玩,就等你了!", "http://www.haiyouchina.site/");
        --截图分享朋友圈
        --F_MobManager.instance:FenXiangWXWithScreenshot();
	end)
end

function ControllerService:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	--wechat:XXXXXX
	self.m_view:GetChild('btnReport'):GetChild('txtTel').text=''
	--wechat:XXXXXX
	self.m_view:GetChild('btnNote'):GetChild('txtTel').text=''
end

function ControllerService:OnHide()
	self.m_view.visible=false
end
return ControllerService