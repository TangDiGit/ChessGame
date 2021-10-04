--商城界面
local ControllerShop = class("ControllerShop")

function ControllerShop:Init()
	self.m_view=UIPackage.CreateObject('shop','shopView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerShop')
	end)

    self.m_view:GetChild("btnDuiHuan").onClick:Add(function ()
		--print('请求商品兑换记录')
		coroutine.start(Shop_Log,{
        	userid=loginSucceedInfo.user_info.userid,
        	callbackSuccess=function(info)
				self.m_listLogData = info.resData
				self.m_listLog.numItems = #info.resData
        	end
    	})
	end)

	self.m_listLog=self.m_view:GetChild('listLog').asList
	self.m_listLog:SetVirtual()
	self.m_listLog.itemRenderer = function (theIndex,theGObj)
		--今日累计 明日积分 奖励分数 创建时间
		local _com = theGObj.asCom
		local _t = self.m_listLogData[theIndex + 1]
		local created_date = lua_string_split(_t.created_date,' ')
		_com:GetChild('todayJiFen').text = formatVal(_t.todayJiFen)
		_com:GetChild('tomorrowJiFen').text = formatVal(_t.tomorrowJiFen)
		_com:GetChild('awardScore').text = formatVal(_t.awardScore)
		_com:GetChild('created_date').text = created_date and created_date[1] or formatVal(_t.created_date)
		--_com.data = _t
		--local _goodInfo=Shop_Config[_t.goodsid]
		--local str = string.format( "花费%s积分兑换【%s】X%s",_t.integral,_goodInfo.name,_t.goodsnumber)
		--_com:GetChild('n54').text=str
		--_com:GetChild('n55').text=_t.createtime
		--_com:GetChild('icon').asLoader.url=_goodInfo.url
	end
	--接受服务器数据后设置
	self.m_listLog.numItems = 0
	self.m_listLogData=nil

	self.m_listShop=self.m_view:GetChild('listShop').asList
	self.m_listShop.onClickItem:Add(function (context)
		local _gcom=context.data
		--print(_gcom.data.config.serverID)
		--print('请求商品兑换')
		coroutine.start(Shop_GOGOGO,{
			isHideWaitTip=true,
			userid=loginSucceedInfo.user_info.userid,
			goodsid=_gcom.data.config.serverID,
			number=1,
			callbackSuccess=function (info)
				self.m_view:GetChild('txtJiFen').text=formatVal(tonumber(info.integral))
				setSelfIntegral(tonumber(info.integral))

				self:RefreshItem(true)

				if self.m_efftimer then
					self.m_efftimer:Stop()
				end
				self.m_eff.visible=true
				self.m_effBG.visible=true
				local trans = self.m_eff:GetTransition("t0")
    			trans:Play()
				self.m_efftimer=Timer.New(function ()
					self.m_eff.visible=false
					self.m_effBG.visible=false
				end,2,1)
				self.m_efftimer:Start()

				self.m_eff:GetChild('n71').text=string.format( "花费%s积分兑换【%s】X1",_gcom.data.serverData.price,_gcom.data.config.name)
			end
		})
	end)

	--倒计时
	self.m_txtTime1=self.m_view:GetChild('txtTime1')
	self.m_txtTime2=self.m_view:GetChild('txtTime2')
	self.m_txtTime3=self.m_view:GetChild('txtTime3')
	Timer.New(function ()
		if not self.m_view.visible then
			return
		end
		if self.refreshCountdown and self.refreshCountdown>0 then
			self.refreshCountdown=self.refreshCountdown-1

			local _d=self.refreshCountdown
			local _v1=0
			local _v2=0
			
			if _d/3600>0 then
				_v1=math.floor(_d/3600)
				_d=_d-_v1*3600
			end
			if _d/60>0 then
				_v2=math.floor(_d/60)
				_d=_d-_v2*60
			end
			
			self.m_txtTime1.text=_v1
			if _v1<10 then
				self.m_txtTime1.text='0'.._v1
			end
			
			self.m_txtTime2.text=_v2
			if _v2<10 then
				self.m_txtTime2.text='0'.._v2
			end

			self.m_txtTime3.text=_d
			if _d<10 then
				self.m_txtTime3.text='0'.._d
			end
		else
			self.m_txtTime1.text="00"
			self.m_txtTime2.text="00"
			self.m_txtTime3.text="00"
		end
	end,1,-1):Start()


	self.m_eff=self.m_view:GetChild('n68')
	self.m_eff.visible=false

	self.m_effBG=self.m_view:GetChild('n70')
	self.m_effBG.visible=false
end

function ControllerShop:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible = true
	--接受服务器数据后设置
	self.m_listLog.numItems = 0
	self.m_listLogData = nil
	self:RefreshItem()
end

function ControllerShop:RefreshItem(isHideWaitTip)
	self.m_listShop:RemoveChildrenToPool()
	self.m_view:GetChild('txtJiFen').text=0

	self.m_txtTime1.text="00"
	self.m_txtTime2.text="00"
	self.m_txtTime3.text="00"
	self.refreshCountdown =0
	--print('请求商品列表')
	coroutine.start(Shop_Get,{
		isHideWaitTip=isHideWaitTip,
        userid=loginSucceedInfo.user_info.userid,
		callbackSuccess=function (info)
			--排序
			local _conf={}
			for i,v in pairs(Shop_Config) do
				table.insert( _conf,v)
			end
			table.sort( _conf, function (a,b)
				return a.sort<b.sort
			end)

			for i,v in ipairs(_conf) do
				local com=self.m_listShop:AddItemFromPool()
				com:GetChild('icon').asLoader.url=v.url
				local serverData=json.decode(info.goods[tostring(v.serverID)])
				com:GetChild('n44').text=string.format( "%s积分",serverData.price)
				com:GetChild('n43').text=string.format( "库存:%s",serverData.number)
				com:GetChild('n45').text=serverData.name
				com.data={serverData=serverData,config=v}
			end
			self.m_view:GetChild('txtJiFen').text=formatVal(tonumber(info.integral))
			setSelfIntegral(tonumber(info.integral))


			self.refreshCountdown =info.goodsExpireDate or 0
        end
    })
end

function ControllerShop:OnHide()
	self.m_view.visible=false
end
return ControllerShop