--背包界面
local ControllerBag2 = class("ControllerBag2")

function ControllerBag2:Init()
	self.m_viewParent=UIPackage.CreateObject('hall','leftToRightContent').asCom
	UIManager.normal:AddChild(self.m_viewParent)
	self.m_viewParent:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_viewParent.visible=false

	self.m_view=UIPackage.CreateObject('hall','bagView2').asCom
	self.m_viewParent:GetChild('parent'):AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerBag2')
	end)

	self.m_list=self.m_view:GetChild('list').asList
	self.m_list.onClickItem:Add(function (context)
		local _gcom=context.data
		local _data=_gcom.data
		self:ShowOneItem(_data)
	end)
end

function ControllerBag2:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_viewParent)
	self.m_viewParent.visible=true
    self.m_viewParent:GetTransition('t0'):Play()
	self:Refresh()
end
function ControllerBag2:Refresh()
	--当前选择
    self.m_selectItem=nil
    self.m_list:RemoveChildrenToPool()
	coroutine.start(Bag_Get,{
		userid = loginSucceedInfo.user_info.userid,
		callbackSuccess = function (info)
			local _isZero = true

			for i, v in ipairs(info.package) do
				if tonumber(v.number) > 0 then
					_isZero = false
				end
			end

			self.m_list:RemoveChildrenToPool()
			local _isMark = true

			for i, v in ipairs(info.package) do
				local _config
				-- 头像框 -- 10000 以上才是道具
				local is_frame = false
				if v.type <= 1020 then
					is_frame = true
					_config = Bag_Config[v.type - 1000]
				else
					_config = Bag_Config[v.type]
				end

				-- 背包不再显示头像框
				if not is_frame then
					local _com = self.m_list:AddItemFromPool()
					_com:GetChild('icon').asLoader.url = _config.url
					_com:GetChild('txtDes').text = _config.des
					if _config.is_frame then
						_com:GetChild('txt_card').text = ""
						_com:GetChild('txt_frame').text = string.format("拥有：%s", v.number)
					else
						_com:GetChild('txt_frame').text = ""
						_com:GetChild('txt_card').text = string.format("拥有：%s", v.number)
					end

					_com.data =
					{
						name = _config.name,
						number = v.number,
						url = _config.url,
						des = _config.des,
						number = tonumber(v.number),
						type = v.type,
						is_frame = _config.is_frame,
						is_card = _config.is_card,
						is_tips = _config.is_tips,
						is_phone_bill = _config.is_phone_bill,
						is_rebirth = _config.is_rebirth,
						is_protect = _config.is_protect,
					}
					--if _isMark then
					--	_isMark = false
					--	self:ShowOneItem(_com.data)
					--end
				end
			end
		end
	})
end

--显示一个道具的详细信息
function ControllerBag2:ShowOneItem(data)
	if data.number == 0 then
		UIManager.AddPopTip({ strTit = '抱歉，您暂未获得该物品' })
		return
	end
	self.m_selectItem = data
	-- 重生卡 护身卡
	if data.is_rebirth or data.is_protect then
		local content = string.format('确定要使用 [color=#E6BC57]%s[/color] 吗?', data.name)
		UIManager.Show('ControllerHallTips', { title = "", content = content, confirm = function()
			coroutine.start(UsePropsCard, {
				type = data.type,
				callbackSuccess = function (info)
					self:Refresh()
					if info.finishDate then
						setHuShengTime(tonumber(info.finishDate))
					end
					UIManager.AddPopTip({ strTit = string.format('[color=#E6BC57]%s[/color]使用成功', data.name) })
				end
			})
		end })

		return
	end

	if data.is_phone_bill then
		if data.type == 10012 then
			if data.number < 50 then
				UIManager.AddPopTip({ strTit = '抱歉，您当前话费总额不足50' })
				return
			end
		elseif data.type == 10013 then
			if data.number < 25 then
				UIManager.AddPopTip({ strTit = '抱歉，您当前话费总额不足50' })
				return
			end
		elseif data.type == 10014 then
			if data.number < 10 then
				UIManager.AddPopTip({ strTit = '抱歉，您当前话费总额不足50' })
				return
			end
		elseif data.type == 10015 then
			if data.number < 5 then
				UIManager.AddPopTip({ strTit = '抱歉，您当前话费总额不足50' })
				return
			end
		end

		local content = "确定兑换50元话费充值卡\n兑换后自动充值"
		UIManager.Show('ControllerHallTips', { title = "", content = content, input = true, confirm = function(pone_num_str)
			-- 要把电话号码传进去
			coroutine.start(UsePropsPhoneCard, {
				type = data.type,
				phoneNum = pone_num_str,
				callbackSuccess = function (info)
					self:Refresh()
					UIManager.AddPopTip({ strTit = string.format('50话费卡兑换成功', data.name) })
				end
			})
		end } )
		return
	end

	if data.is_card then
		if data.type == 10011 then
			UIManager.AddPopTip({ strTit = '拥有此卡比赛场报名免费' })
			return
		end

		UIManager.AddPopTip({ strTit = '游戏场内自动使用该卡' })
		return
	end

	if data.type == 10003 or data.type == 10004 then
		-- 头像只有 月卡或者周卡用户才能使用
		if tonumber(loginSucceedInfo.user_info.viptime) > 0 then
			UIManager.AddPopTip({ strTit = 'VIP未到期' })
			return
		end

		coroutine.start(Prop_Use, {
			userid = loginSucceedInfo.user_info.userid,
            type = self.m_selectItem.type,
            callbackSuccess = function (info)
				self:Refresh()
				if info.viptime then
					Refresh_Person_Gold() -- 刷新玩家的金币
					setVIPTime(tonumber(info.viptime))
				end

				UIManager.AddPopTip({ strTit = 'VIP卡使用成功' })
			end
		})
	end
end

function ControllerBag2:OnHide()
	self.m_viewParent.visible=false
end
return ControllerBag2