--背包界面
local ControllerBag = class("ControllerBag")

function ControllerBag:Init()
	self.m_view=UIPackage.CreateObject('hall','bagView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerBag')
	end)

	--从好友赠送礼物界面过来的
	self.m_txtGift=self.m_view:GetChild("txtPresentedCount")
	self.m_giftCount=nil

	self.m_view:GetChild("btnAdd").onClick:Add(function ()
		if self.m_selectItem.is_phone_bill or self.m_selectItem.type == 10010 then
			UIManager.AddPopTip({ strTit = '抱歉，该道具暂不支持赠送' })
			return
		end
        self:SetAddGift(1)
	end)

	self.m_view:GetChild("btnLess").onClick:Add(function ()
		if self.m_selectItem.is_phone_bill or self.m_selectItem.type == 10010 then
			UIManager.AddPopTip({ strTit = '抱歉，该道具暂不支持赠送' })
			return
		end
		self:SetAddGift(-1)
	end)


	self.m_view:GetChild("btnPreparePresented").onClick:Add(function ()
		if self.m_selectItem.is_phone_bill or self.m_selectItem.type == 10010 then
			UIManager.AddPopTip({ strTit = '抱歉，该道具暂不支持赠送' })
			return
		end
		if self.m_giftCount > 0 then
			H_EventDispatcher:dispatchEvent({name='refreshFriendGift',giftCount = self.m_giftCount, selectItem = self.m_selectItem})
			UIManager.Hide('ControllerBag')
		else
			UIManager.AddPopTip({ strTit = '请添加正确的物品数量' })
		end
	end)

	self.m_c=self.m_view:GetController('c1')
	self.m_list=self.m_view:GetChild('list').asList
	self.m_list.onClickItem:Add(function (context)
		local _gcom=context.data
		local _data=_gcom.data
		self:ShowOneItem(_data)
	end)

	self.m_view:GetChild("btnUser").onClick:Add(function ()
		coroutine.start(Prop_Use,{
			userid=loginSucceedInfo.user_info.userid,
            type=self.m_selectItem.type,
            callbackSuccess=function (info)
				self:Refresh()
				setVIPTime(tonumber(info.viptime))
			end
		})
	end)
end

function ControllerBag:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.m_data=arg
	self:Refresh()
end
function ControllerBag:Refresh()
	self.m_c.selectedIndex=0
	self.m_txtGift.text=''
	self.m_giftCount=0
	--当前选择
	self.m_selectItem=nil
	coroutine.start(Bag_Get,{
		userid=loginSucceedInfo.user_info.userid,
		callbackSuccess=function (info)
			local _isZore=true
			for i,v in ipairs(info.package) do
				if tonumber(v.number)>0 then
					_isZore=false
				end
			end

			if _isZore then
				return
			end
			if self.m_data and self.m_data.isWithFriendOpen then
				self.m_c.selectedIndex=2
			else
				self.m_c.selectedIndex=1
			end
			
			self.m_list:RemoveChildrenToPool()
			local _isMark=true
			for i,v in ipairs(info.package) do
				if tonumber(v.number) > 0 then
					local _com = self.m_list:AddItemFromPool()
					local _config = v.type <= 1020 and Bag_Config[v.type - 1000] or Bag_Config[v.type]
					_com:GetController('c1').selectedIndex = 1
					_com:GetChild('icon').asLoader.url=_config.url

					if _config.is_frame then
						_com:GetChild('txt_card').text = ""
						_com:GetChild('txt_frame').text = string.format("拥有：%s", v.number)
					else
						_com:GetChild('txt_frame').text = ""
						_com:GetChild('txt_card').text = string.format("拥有：%s", v.number)
					end

					_com.data =
					{
						url = _config.url,
						des = _config.des,
						number = tonumber(v.number),
						type = v.type,
						is_frame = _config.is_frame,
						is_phone_bill = _config.is_phone_bill,
					}

					if _isMark then
						_isMark = false
						self:ShowOneItem(_com.data)
					end
				end
				
			end
			
		end
	})
end

--显示一个道具的详细信息
function ControllerBag:ShowOneItem(data)
	self.m_view:GetChild('icon').asLoader.url = data.url
	self.m_view:GetChild('txtCount').text = string.format('[color=#%s]拥有：%s[/color]', data.is_frame and "FFFFFF" or "550103", data.number)
	self.m_view:GetChild('txtDes').text = data.des
	self.m_selectItem = data
	self:SetAddGift(0)
	self.m_view:GetChild('btnUser').visible = false
	if data.type == 10003 or data.type == 10004 then
		self.m_view:GetChild('btnUser').visible = true
	end
end

function ControllerBag:SetAddGift(val)
	if self.m_selectItem then
		self.m_giftCount = self.m_giftCount+val
		self.m_giftCount = math.max(0, self.m_giftCount)
		self.m_giftCount = math.min(self.m_selectItem.number, self.m_giftCount)
		self.m_txtGift.text = self.m_giftCount
	end
end

function ControllerBag:OnHide()
	self.m_view.visible=false
end
return ControllerBag