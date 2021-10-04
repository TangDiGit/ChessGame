--活动界面
local ControllerActivity = class("ControllerActivity")

function ControllerActivity:Init()
	self.m_view = UIPackage.CreateObject('activity','activityView2').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

	self.content_des =
	{
		-- 0 是火爆 1是限时 2 是最新[玩牌获积分]
		--  兑换礼品
		--[1] = { id = 1, name = "[亿大利炮]\n 七星彩 ", type = 2 },
		--[2] = { id = 2, name = "[七星彩]\n 额外再奖 ", type = 2 },
		[1] = { id = 3, name = "[爆击AA]\n 额外奖励 ", type = 2 },
		[2] = { id = 4, name = "[牛仔赢亿]\n再奖888万", type = 2 },
		[3] = { id = 5, name = "[天降神卡]\n 卡卡神奇 ", type = 0 },
		[4] = { id = 6, name = "[王者福袋]\n 福鑫高照 ", type = 0 },
		[5] = { id = 7, name = "[赛事比赛]\n 手机奖励 ", type = 0 },
		--[8] = { id = 8, name = "[彩池火爆礼]\n  每日50亿", type = 0 },
		--[9] = { id = 9, name = "[绑定手机]\n 送VIP卡 ", type = 1 },
		--[8] = { id = 10, name = "[玩牌获积分]\n  兑换礼品 ", type = 1 },
	}

    self.m_info_list =
	{
		{ status  = 3 },
		{ status  = 3 }
	}

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerActivity')
	end)

	self.m_topPos = self.m_view:GetChild("topPos")
	self.m_middlePos = self.m_view:GetChild("middlePos")
	self.m_middleBG = self.m_view:GetChild('middleBG')
	self.m_middleBG.visible = false

	-- 福袋
	self.m_subWzfd = self.m_view:GetChild('sub_wzfd')
	self.sub_wzfd_type_1 = self.m_subWzfd:GetController("type_1")
	self.sub_wzfd_type_2 = self.m_subWzfd:GetController("type_2")
	self.sub_wzfd_type_1.selectedIndex = 0
	self.sub_wzfd_type_2.selectedIndex = 1
	self.m_refresh_count = 2
	self.m_refresh_list =
	{
		{0,1},
		{1,2},
		{2,3},
		{3,4},
	}

	self.m_subWzfd:GetChild('btn_refresh').onClick:Add(function ()
		self:ClickShowSubReward()
	end)

	-- 比赛场
	self.m_view:GetChild('sub_bsc'):GetChild('btn_open').onClick:Add(function ()
		UIManager.Hide('ControllerActivity')
		UIManager.Show('ControllerWaitTip')
		F_ResourceManager.instance:AddPackage("competition",function ()
			UIManager.Hide('ControllerWaitTip')
			UIManager.Show('ControllerCompetition')
		end)
	end)

	-- 七星彩
	self.m_subQxc = self.m_view:GetChild('sub_qxc')

	self.m_subQxc:GetChild("btn_rule").onClick:Add(function()
		UIManager.Show('ControllerHallDesc', { type = 0 })
	end)

	self.m_subQxc:GetChild("btn_reward").onClick:Add(function()
		UIManager.Show('ControllerHallDesc', { type = 1 })
	end)

	-- AA说明
	self.m_view:GetChild('sub_aa'):GetChild('btn_rule').onClick:Add(function ()
		local content = ""
		UIManager.Show('ControllerHallDesc', { type = 2 })
	end)

	-- 牛仔盈利
	self.m_view:GetChild('sub_nzyy'):GetChild('btn_rule').onClick:Add(function ()
		UIManager.Show('ControllerHallDesc', { type = 3 })
	end)

	-- 话费卡说明
	self.m_view:GetChild('sub_hfk'):GetChild('btn_rule').onClick:Add(function ()
		UIManager.Show('ControllerHallDesc', { type = 4 })
	end)

	-- 王者福袋说明
	self.m_subWzfd:GetChild("btn_rule").onClick:Add(function()
		UIManager.Show('ControllerHallDesc', { type = 5 })
	end)

	-- 活动列表
	self:InitResList()
	self:RefreshList(self.content_des[1].id)   -- 默认打开第一个
	self:InitQxcNumList()
end

function ControllerActivity:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible = true
	-- 大厅的数据
	self:RefreshQxcView()
	self:PlayTopAni()
end

---------------------------------------------------------------------------------
------------------------------- 活动按钮列表 --------------------------------------
function ControllerActivity:InitResList()
	self.m_resList = self.m_view:GetChild('list').asList
	self.m_resList:SetVirtual()
	self.m_resList.itemRenderer = function (theIndex,theGObj)
		local _com = theGObj.asCom
		local _data = self.m_resData[theIndex + 1]
		_com:GetChild('name').text = _data.name
		_com:GetController('slt').selectedIndex = _data.id == self.slt_index and 1 or 0
		_com:GetController('type').selectedIndex = _data.type

		local btn_click = _com:GetChild("btn_click").asButton
		btn_click:RemoveEventListeners()
		btn_click.onClick:Add(function ()
			self:RefreshList(_data.id)
		end)
	end
	self.m_resList.numItems = 0
	self.m_resData = nil
end

function ControllerActivity:RefreshList(slt)
	self.slt_index = slt
	self.m_view:GetController('c1').selectedIndex = slt - 1
	self.m_resData = self.content_des
	self.m_resList.numItems = #self.content_des
end

---------------------------------------------------------------------------------
---------------------------------- 福袋 ------------------------------------------
function ControllerActivity:ClickShowSubReward()
	self.sub_wzfd_type_1.selectedIndex = self.m_refresh_list[self.m_refresh_count][1]
	self.sub_wzfd_type_2.selectedIndex = self.m_refresh_list[self.m_refresh_count][2]
	self.m_refresh_count = self.m_refresh_count + 1
	if self.m_refresh_count == 5 then
		self.m_refresh_count = 1
	end
end

---------------------------------------------------------------------------------
--------------------------------- 七星彩 -----------------------------------------

function ControllerActivity:InitQxcNumList()
	-- 中奖类型
	self.m_rewardName = self.m_subQxc:GetChild('reward_name')
	-- 倒计时
	self.m_QxcCdCom = nil
	self.m_QxcCdTime = 0
	self.m_QxcCdText = self.m_subQxc:GetChild('cd')
	self.m_QxcSltCtrl = self.m_subQxc:GetController('status')
	-- 数据
	self.m_numData = nil
	--可选次数
	self.m_remainSltTimes = 0
	-- 中奖
	self.m_numListReward = self.m_subQxc:GetChild('list_reward').asList
	self.m_numListReward:SetVirtual()
	self.m_numListReward.itemRenderer = function (theIndex, theGObj)
		self:SetQxcNumSingle(theGObj.asCom, self.m_numData[theIndex + 1].num)
	end
	self.m_numListReward.numItems = 0

	-- 上一期自己选
	self.m_numListLast = self.m_subQxc:GetChild('list_last').asList
	self.m_numListLast:SetVirtual()
	self.m_numListLast.itemRenderer = function (theIndex, theGObj)
		self:SetQxcNumSingle(theGObj.asCom, self.m_numData[theIndex + 1].num)
	end
	self.m_numListLast.numItems = 0

	-- 本期自己选
	self.m_numListNow = self.m_subQxc:GetChild('list_now').asList
	self.m_numListNow:SetVirtual()
	self.m_numListNow.itemRenderer = function (theIndex, theGObj)
		self:SetQxcNumSingle(theGObj.asCom, self.m_numData[theIndex + 1].num)
	end
	self.m_numListNow.numItems = 0

	for i = 0, 14 do
		self.m_subQxc:GetChild(string.format("btn_%s", i)).onClick:Add(function()
			self:QxcSltNum(i)
		end)
	end

	self.m_subQxc:GetChild("btn_clear").onClick:Add(function()
		self:ClearQxcSltNum()
	end)

	self.m_subQxc:GetChild("btn_confirm").onClick:Add(function()
		self:SendQxcSltNumList()
	end)
end

function ControllerActivity:RefreshQxcView()
	coroutine.start(GameActivity_Info, {
		userid = loginSucceedInfo.user_info.userid,
		callbackSuccess = function(info)
			self:ShowQxcSltStatus(info)
		end
	})
end

-- 0 不能选择 1 可以选择
function ControllerActivity:ShowQxcSltStatus(info)
	self.m_remainSltTimes = info.leftSelTime
	self.m_rewardName.text = info.winLevel == 0 and "未中奖" or string.format("%s等奖", Chinese_Num[info.winLevel])
	self.m_QxcCdTime = tonumber(info.leftBeginTime)
	if self.m_QxcCdTime > 0 then
		self:OpenQxcCd()
	else
		self.m_QxcCdText.text = "等待开奖"
	end

	self.m_QxcSltCtrl.selectedIndex = self.m_remainSltTimes > 0 and 1 or 0
	self:SetQxcNumList(self.m_numListReward, self:GetQxcServerNumList(info.lastSysNum))
	self:SetQxcNumList(self.m_numListLast, self:GetQxcServerNumList(info.selfLastBuyNum))
	self:SetQxcNumList(self.m_numListNow,self:GetQxcServerNumList(info.selfBuyNum))
end

-- 再次选择
function ControllerActivity:ClearQxcSltNum()
	local emptyList = { {num = -1}, {num = -1}, {num = -1}, {num = -1}, {num = -1}, {num = -1}, {num = -1} }
	self:SetQxcNumList(self.m_numListNow, emptyList)
end

-- 确定选择
function ControllerActivity:SendQxcSltNumList()
	local list = { }
	for k, v in ipairs(self.m_numData) do
		if v.num == -1 then
			UIManager.AddPopTip({strTit = '您的号码选择不正确，请重新选择'})
			return
		else
			table.insert(list, v.num * 1)
		end
	end

	coroutine.start(GameActivity_SltNum,{
		userid = loginSucceedInfo.user_info.userid,
		selNum = string.format("%s,%s,%s,%s,%s,%s,%s",list[1],list[2],list[3],list[4],list[5],list[6],list[7]),
		callbackSuccess = function(info)
			UIManager.AddPopTip({ strTit = "七星彩选号成功"})
			self:RefreshQxcView()
		end
	})
end

function ControllerActivity:SetQxcNumList(com_list, num_list)
	self.m_numData = num_list
	com_list.numItems = #num_list
end

function ControllerActivity:SetQxcNumSingle(com, num)
	com:GetController('num').selectedIndex = num >= 0 and num or 15
end

function ControllerActivity:QxcSltNum(num)
	if self.m_remainSltTimes > 0 then
		local is_all_slt = true
		for k, v in ipairs(self.m_numData) do
			if v.num == -1 then
				is_all_slt = false
				if k == 7 then
					v.num = num
					break
				else
					if num > 9 then
						UIManager.AddPopTip({strTit = '前[color=#E6BC57]6[/color]位请选择[color=#E6BC57]9[/color]以内的数字'})
						return
					else
						v.num = num
						break
					end
				end
			end
		end
		if is_all_slt then
			UIManager.AddPopTip({strTit = '亲爱的玩家，您的号码已经全部选择'})
			return
		end

		self:SetQxcNumList(self.m_numListNow, self.m_numData)
	else
		UIManager.AddPopTip({strTit = '亲爱的玩家，您暂时不能选号'})
	end
end

function ControllerActivity:GetQxcServerNumList(info_num_str)
	local res_num_list = { {num = -1}, {num = -1}, {num = -1}, {num = -1}, {num = -1}, {num = -1}, {num = -1} }
	if string.len(info_num_str) > 0 then
		local _data = lua_string_split(info_num_str,',')
		for k, v in ipairs(res_num_list) do
			v.num = tonumber(_data[k])
		end
	end
	return res_num_list
end

function ControllerActivity:OpenQxcCd()
	self:CloseQxcCd()
	self:UpdateQxcCd()
	self.m_QxcCdCom = Timer.New(function ()
		self:UpdateQxcCd()
	end, 1, -1)
	self.m_QxcCdCom:Start()
end

function ControllerActivity:UpdateQxcCd()
	self.m_QxcCdTime = self.m_QxcCdTime - 1
	self.m_QxcCdText.text = GetTimeText(self.m_QxcCdTime)
	if self.m_QxcCdTime < 0 then
		self.m_QxcCdTime = 0
		self:CloseQxcCd()
		self:RefreshQxcView()
	end
end

function ControllerActivity:CloseQxcCd()
	if self.m_QxcCdCom then
		self.m_QxcCdCom:Stop()
	end
end

---------------------------------------------------------------------------------
---------------------------------- 动画 -----------------------------------------
function ControllerActivity:PlayCoinAni()
	self.m_middlePos.visible = true
	self.m_middleBG.visible = true
	if not self.m_middle_ani then
		self.m_middle_ani = UIManager.SetDragonBonesAniObjPos('jinbi2OBJ', self.m_middlePos, Vector3.New(120,120,120))
	else
		self:PlayAni(self.m_middle_ani.gameObject, 'animation3', false)
	end

	self.m_timerEff1=Timer.New(function ()
		self.m_middlePos.visible = false
		self.m_middleBG.visible = false
	end, 2, 1)
	self.m_timerEff1:Start()
	F_SoundManager.instance:PlayEffect("jinbi2")
end

function ControllerActivity:PlayTopAni()
	if not self.m_comOver_gw then
		self.m_comOver_gw = UIManager.SetDragonBonesAniObjPos('huodongOBJ', self.m_topPos, Vector3.New(60,60,60))
	else
		self:PlayAni(self.m_comOver_gw.gameObject, 'start', true)
		self.m_timerEff2=Timer.New(function ()
			self:PlayAni(self.m_comOver_gw.gameObject, 'idle', true)
		end, 3, 1)
		self.m_timerEff2:Start()
	end
end

function ControllerActivity:PlayAni(spine_anim,anim_name,is_loop)
	spine_anim:SetActive(true)
	local skeleton_anim = spine_anim:GetComponent('Spine.Unity.SkeletonAnimation')
	skeleton_anim.skeleton:SetToSetupPose()
	skeleton_anim.state:ClearTracks()
	skeleton_anim.state:SetAnimation(0,anim_name,is_loop)
	spine_anim.gameObject:SetActive(true)
end

function ControllerActivity:OnHide()
	self:CloseQxcCd()
	self.m_view.visible = false
end

return ControllerActivity