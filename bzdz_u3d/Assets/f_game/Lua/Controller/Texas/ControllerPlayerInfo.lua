--游戏内查看玩家信息
local ControllerPlayerInfo = class("ControllerPlayerInfo")

function ControllerPlayerInfo:Init()
	self.m_view = UIPackage.CreateObject('texas','roomPlayerInfoView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerPlayerInfo')
	end)

	self.m_view:GetChild("btnAddFriend").onClick:Add(function ()
		if gameData.chair == -1 then
		    UIManager.AddPopTip({strTit='没有坐下'})
			return
		end
		coroutine.start(Friend_Add,{
			fromuserid = loginSucceedInfo.user_info.userid,
			touserid = self.m_data.info.userid,
            callbackSuccess = function (info)
				-- 展示爱心
				UIManager.GetController('ControllerTexas'):ShowAddFriendFly(loginSucceedInfo.user_info.userid, self.m_data.info.userid)
				UIManager.AddPopTip({strTit = info.content})
            end
        })
		UIManager.Hide('ControllerPlayerInfo')
	end)

	self.m_view:GetChild("btnOutPlayer").onClick:Add(function ()
		--print('踢掉')
		if gameData.seq ~= nil then
			if tonumber(loginSucceedInfo.user_info.viptime) <= 0 then
				UIManager.AddPopTip({strTit = '亲爱的玩家，您不是VIP暂时无法使用该功能'})
				return
			end

			local msg = Protol.Poker_pb.TPersonCardRequest()
			msg.seq=gameData.seq
			msg.fromuserid=loginSucceedInfo.user_info.userid
			msg.touserid=self.m_data.info.userid
			msg.req_type=1

			NetManager.SendMessage(GameServerConfig.logic,'TPersonCardRequest', msg:SerializeToString())
		end
	end)

	self.m_view:GetChild("btnJuBao").onClick:Add(function ()
		--print('举报玩家')
		UIManager.Show('ControllerGameReportPlayer')
	end)

	self.m_btn_ten = self.m_view:GetChild("btn_ten").asButton
	self.m_btn_ten.onClick:Add(function ()
		self.m_btn_ten.selected = not self.m_btn_ten.selected
	end)
	self.m_send_ten = false
	self.m_btn_ten.selected = false
	self.m_btn_ten.changeStateOnClick = true
	self.m_btn_ten.visible = false

	local _propList=self.m_view:GetChild("propList").asList
	_propList.onClickItem:Add(function (context)
		if gameData.chair==-1 then
			UIManager.AddPopTip({strTit='发送失败,请坐下后重试.'})
			return
		end
		if gameMoney < gameData.emotion_fee then
			UIManager.AddPopTip({strTit='筹码不足'})
			return
		end
		local _com = context.data
		local _comName=_com.name
		local _toUserid=self.m_data.userid
		local _info =
		{
			from=loginSucceedInfo.user_info.userid,
			to=_toUserid,
			mtype=10001,
			c=_comName,
			chips=gameData.emotion_fee
		}

		if _comName == "3" and self.m_btn_ten.selected then
			self.m_send_ten = true
			for i = 0, 9 do
				local _timer = Timer.New(function ()
					self:SendGift(_info)
					if i == 9 then
						self.m_send_ten = false
					end
				end, 0.3 * i, 1)
				_timer:Start()
			end
		else
			self:SendGift(_info)
		end

		UIManager.Hide("ControllerPlayerInfo")
	end)
	
	self.m_view:GetChild('txtGiftPriceTips').text=string.format( "(%s金币每次)",gameData.emotion_fee ) 
end

function ControllerPlayerInfo:SendGift(_info)
	if roomCfg.is_competition then
		UIManager.AddPopTip({ strTit = "比赛场暂时不可赠送礼物！"})
		return
	end
	local msg = Protol.Poker_pb.UserInteractionRequest()
	msg.userid=loginSucceedInfo.user_info.userid
	msg.interaction_infos=json.encode(_info)
	local pb_data = msg:SerializeToString()
	NetManager.SendMessage(GameServerConfig.logic,'UserInteractionRequest',pb_data)
end

function ControllerPlayerInfo:Show(arg)
	if self.m_send_ten then
		return
	end
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.m_data=arg

	self.m_view:GetChild('head'):GetChild('icon').asLoader.url = HandleWXIcon(self.m_data.info.headurl)
	self.m_view:GetChild('txtNickName').text=self.m_data.info.nickname
	self.m_view:GetChild('txtChip').text=self.m_data.info.gold
	self.m_view:GetChild('txtID').text=string.format("ID：%s", self.m_data.info.userid)
	--self.m_view:GetChild('txtLV').text=self.m_data.info.level
	local vip_type = tonumber(self.m_data.info.vipType)
	self.m_view:GetChild('txtLV').text = vip_type and (vip_type == 0 and "" or (vip_type == 1 and "VIP周卡" or "VIP月卡")) or ""
	self.m_view:GetController('c1').selectedIndex=self.m_data.info.sex

	--胜率
    self.m_view:GetChild('txtWinRate').text=string.format( "胜率：[color=#FFFFFF]%s[/color]",0)
    --弃牌率
    self.m_view:GetChild('txtDropCardRate').text=string.format( "摊牌率：[color=#FFFFFF]%s[/color]",0)
    --最大赢取
    self.m_view:GetChild('txtMaximumIncome').text=string.format( "最大赢取：[color=#FFFFFF]%s[/color]",0)
	--总局数
    self.m_view:GetChild('txtToatlRoundCount').text=string.format( "总局数：[color=#FFFFFF]%s[/color]",0)
	--参赛次数
	self.m_view:GetChild('txtJoinTimes').text=string.format( "参赛次数：[color=#FFFFFF]%s[/color]",0)
	--获奖次数
	self.m_view:GetChild('txtRewardTimes').text=string.format( "获奖次数：[color=#FFFFFF]%s[/color]",0)

    if self.m_data.info.gamecount then
        local _v = tonumber(self.m_data.info.wincounts)/tonumber(self.m_data.info.gamecount)
        _v=string.format('%.2f',_v)
        self.m_view:GetChild('txtWinRate').text=string.format( "胜率：[color=#FFFFFF]%s%s[/color]",_v*100,'%')

        if self.m_data.info.dropcardcount then
            local _vv = 1 - tonumber(self.m_data.info.dropcardcount)/tonumber(self.m_data.info.gamecount)
            _vv = string.format('%.2f', _vv)
            self.m_view:GetChild('txtDropCardRate').text=string.format( "摊牌率：[color=#FFFFFF]%s%s[/color]",_vv*100,'%')
        end
        self.m_view:GetChild('txtToatlRoundCount').text=string.format( "总局数：[color=#FFFFFF]%s[/color]",formatVal(tonumber(self.m_data.info.gamecount)))
		self.m_view:GetChild('txtJoinTimes').text=string.format( "参赛次数：[color=#FFFFFF]%s[/color]",self.m_data.info.matchCount)
		self.m_view:GetChild('txtRewardTimes').text=string.format( "获奖次数：[color=#FFFFFF]%s[/color]",self.m_data.info.matchWinCount)
	end

    if self.m_data.info.winmaxgold then
        self.m_view:GetChild('txtMaximumIncome').text=string.format( "最大赢取：[color=#FFFFFF]%s[/color]", formatVal(tonumber(self.m_data.info.winmaxgold)))
    end
end

function ControllerPlayerInfo:OnHide()
	self.m_view.visible=false
end
return ControllerPlayerInfo