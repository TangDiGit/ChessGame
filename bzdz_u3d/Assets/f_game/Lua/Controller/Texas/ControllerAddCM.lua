--游戏内查看上局回顾
local ControllerAddCM = class("ControllerAddCM")

function ControllerAddCM:Init()
	self.m_view=UIPackage.CreateObject('texas','texasReplenishbetView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false
	self.is_bi_xia = false
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerAddCM')
	end)

	self.m_txtBiXia = self.m_view:GetChild("txtBiXia")

	self.m_autoAddBetContent=self.m_view:GetChild("autoAddBetContent").asButton
    self.m_autoAddBetContent.onClick:Add(function ()
        --print('游戏币为0时自动买入x游戏币:'..(self.m_autoAddBetContent.selected and 't' or 'f'))
		if not self.is_bi_xia then
			if self.m_autoAddBetContent.selected then
				self.m_autoMinBringContent.selected=false
			end
		end
	end)

	self.m_autoMinBringContent=self.m_view:GetChild("autoMinBringContent").asButton
    self.m_autoMinBringContent.onClick:Add(function ()
		if not self.is_bi_xia then
			--print('每局自动买入到最大值x游戏币:'..(self.m_autoMinBringContent.selected and 't' or 'f'))
			if self.m_autoMinBringContent.selected then
				self.m_autoAddBetContent.selected = false
				self:SetVal(100)
			end
		end
	end)

	self.m_view:GetChild("btnSureBtn").onClick:Add(function ()
		--print('坐下')
		local msg = Protol.Poker_pb.ChargeGoldRequest()
		if self.is_bi_xia then
			msg.chargegold = roomCfg.bringmaxgold
			msg.autocharge=2
		else
			msg.chargegold = math.min(self.m_f, loginSucceedInfo.user_info.gold)
			msg.autocharge = 0
			if self.m_autoAddBetContent.selected then
				msg.autocharge = 1
			elseif self.m_autoMinBringContent.selected then
				msg.autocharge = 2
			end
		end

		if loginSucceedInfo.user_info.gold < msg.chargegold then
			UIManager.AddPopTip({strTit='您带的金币不足！'})
			return
		end

	    local pb_data = msg:SerializeToString()
		NetManager.SendMessage(GameServerConfig.logic,'ChargeGoldRequest', pb_data)
		if self.m_data then
			self.m_data()
		end
		UIManager.Hide('ControllerAddCM')
	end)

	self.m_slider=self.m_view:GetChild("slider").asSlider
	self.m_slider.onChanged:Add(function ()
		--if self.is_bi_xia then
		--	self.m_slider.value = 100
		--	return
		--end
		self:SetVal(self.m_slider.value)
	end)
	self.m_valText=self.m_view:GetChild('txtNowBringValue')

	self.m_autoMinBringContent.selected=false
	self.m_autoAddBetContent.selected=false

	H_EventDispatcher:addEventListener('refreshSelfMoney',function (arg)
        self.m_view:GetChild('txtSafeBoxMoney').text=string.format( "我的携带总资产：[color=#F7D262]%s[/color]",formatVal(loginSucceedInfo.user_info.gold))
    end)
end

function ControllerAddCM:SetVal(val)
	self.m_slider.value = val
	local _v = roomCfg.bringmaxgold / 100
	local _min = roomCfg.bringmingold / _v
	if self.m_slider.value < _min then
		self.m_slider.value = _min
	end
	self.m_f = math.max(roomCfg.bringmingold, math.min(roomCfg.bringmaxgold, math.floor(self.m_slider.value * _v)))
	self.m_f = math.min(self.m_f, loginSucceedInfo.user_info.gold)
	if not self.is_bi_xia then
		self.m_autoAddBetContent.text = string.format("游戏币为0时自动买入%s游戏币", formatVal(self.m_f))
	end
	self.m_valText.text = formatVal(self.m_f)
end

function ControllerAddCM:Show(arg)
	if roomCfg.is_competition then
		return
	end
	
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true
	Refresh_Person_Gold()
	self.m_view:GetChild('txtSafeBoxMoney').text=string.format( "我的携带总资产：[color=#F7D262]%s[/color]",formatVal(loginSucceedInfo.user_info.gold))
	self.m_view:GetChild('txtSmallBlindValue').text=string.format( "%s/%s",formatVal(roomCfg.xiaomangbet),formatVal(roomCfg.xiaomangbet*2))
	self.m_autoMinBringContent.text=string.format("每局自动买入到最大值%s游戏币",formatVal(roomCfg.bringmaxgold))
	self.m_data=arg

	self.is_bi_xia = UIManager.GetController('ControllerGameHall'):GetIsBiXiaReal()
	self.m_view:GetChild('txtBringValue').text=formatVal(self.is_bi_xia and roomCfg.bringmaxgold or roomCfg.bringmingold)
	self.m_autoAddBetContent.selected = false
	if self.is_bi_xia then  -- 必下
		self:SetVal(100)
		self.m_slider.changeOnClick = false
		self.m_autoMinBringContent.selected = true
		self.m_autoMinBringContent.changeStateOnClick = false
		self.m_txtBiXia.visible = true
		self.m_autoAddBetContent.visible = false
		self.m_slider.visible = false
	else
		self:SetVal(50)
		self.m_slider.changeOnClick = true
		self.m_autoMinBringContent.selected = false
		self.m_autoMinBringContent.changeStateOnClick = true
		self.m_txtBiXia.visible = false
		self.m_autoAddBetContent.visible = true
		self.m_slider.visible = true
	end
end

function ControllerAddCM:OnHide()
	self.m_view.visible=false
end

return ControllerAddCM