--保险箱界面
local ControllerSafeBox2 = class("ControllerSafeBox2")

function ControllerSafeBox2:Init()
	self.m_viewParent=UIPackage.CreateObject('hall','leftToRightContent').asCom
	UIManager.normal:AddChild(self.m_viewParent)
	self.m_viewParent:SetSize(GRoot.inst.width, GRoot.inst.height)
	self.m_viewParent.visible=false

	self.m_view=UIPackage.CreateObject('hall','safeBoxView2').asCom
	self.m_viewParent:GetChild('parent'):AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)

    self.m_box_gold = 0  --保险箱数字

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerSafeBox2')
	end)

	-- n38是取出/存入公用
    self.m_select = self.m_view:GetController('c1')
    -- 取出/存入
    self.m_txtExternalCoin = self.m_view:GetChild('n38'):GetChild('n44')
    self.m_txtSafeBoxCoin = self.m_view:GetChild('n38'):GetChild('n45')
    self.m_inputNumber = self.m_view:GetChild('n38'):GetChild('n48').asTextInput
	--self.m_inputWan = self.m_view:GetChild('n38'):GetChild('n49')
	--self.m_inputWan.y = self.m_view:GetChild('n38'):GetChild('n47').y
	self.m_wanNumber = self.m_view:GetChild('n38'):GetChild('n49')
	self.m_wanNumber.text = ""

	-- 取出/存入按钮 点击后实时刷新数据
	self.m_view:GetChild('n31').onClick:Add(function ()
		self:RequestGoldNum()
	end)

	self.m_view:GetChild('n33').onClick:Add(function ()
		self:RequestGoldNum()
	end)

	--转入记录
	self.m_view:GetChild('n35').onClick:Add(function ()
		self:RequestRecordIn()
	end)

	--转出记录
	self.m_view:GetChild('n36').onClick:Add(function ()
		self:RequestRecordOut()
	end)

	-- 转账
	self.m_view:GetChild('n34').onClick:Add(function ()
		self:ClearZzNum()
	end)

	-- 输入框变化
	self.m_inputNumber.onChanged:Add(function ()
		local inout_coin = tonumber(self.m_inputNumber.text)
		if inout_coin then
			inout_coin = inout_coin * 10000
			self.m_wanNumber.text = formatVal(inout_coin)
		else
			self.m_wanNumber.text = ""
		end
	end)

    self.m_view:GetChild('n38'):GetChild('btnY').onClick:Add(function ()
        --0 取出 1 存入
		--local gold_num = #self.m_inputNumber.text > 0 and tonumber(self.m_inputNumber.text) * 10000 or 0 --去万
		local gold_num = #self.m_inputNumber.text > 0 and tonumber(self.m_inputNumber.text) * 10000 or 0
		if gold_num == 0 then
			return
		end

		if self.m_select.selectedIndex==0 then
			if gold_num > self.m_box_gold then
				UIManager.AddPopTip({strTit='取出金额超出保险箱金额'})
				return
			end
            coroutine.start(SafeBox_Deposit_Pull, {
				userid = loginSucceedInfo.user_info.userid,
				gold = gold_num,
				callbackSuccess = function (info)
					self:RefreshGold(info)
					UIManager.AddPopTip({strTit=info.content})
				end
			});
        else
			if gold_num > loginSucceedInfo.user_info.gold then
				UIManager.AddPopTip({strTit='存入金额超出携带金额'})
				return
			end
            coroutine.start(SafeBox_Deposit_Push,{
				userid = loginSucceedInfo.user_info.userid,
				gold = gold_num,
				callbackSuccess = function (info)
					self:RefreshGold(info)
					UIManager.AddPopTip({strTit=info.content})
				end
			});
        end
    end)

    self.m_view:GetChild('n38'):GetChild('btnAll').onClick:Add(function ()
        --self.m_inputNumber.text=math.floor(loginSucceedInfo.user_info.gold/10000)--去万
		if self.m_select.selectedIndex == 0 then
			self.m_inputNumber.text = self.m_box_gold / 10000
			self.m_wanNumber.text = formatVal(self.m_box_gold)
		else
			local all_coin = math.floor(loginSucceedInfo.user_info.gold)
			self.m_inputNumber.text = all_coin / 10000
			self.m_wanNumber.text = formatVal(all_coin)
		end
	end)

    self.m_zzUID = self.m_view:GetChild('n54'):GetChild('n56')
    self.m_zzMoney = self.m_view:GetChild('n54'):GetChild('n59').asTextInput
	self.m_zzWan = self.m_view:GetChild('n54'):GetChild('n61')

	self.m_zzMoney.onChanged:Add(function ()
		local inout_coin = tonumber(self.m_zzMoney.text)
		self.m_zzWan.text = inout_coin and (formatVal(inout_coin * 10000) or inout_coin) or ""
	end)

    self.m_view:GetChild('n54'):GetChild('btnY').onClick:Add(function ()
		--if loginSucceedInfo.user_info.proxyid ~= 1 then
		--	UIManager.AddPopTip({strTit = '抱歉，仅代理有转账权限'})
		--end
        local _dUserid = self.m_zzUID.text
		if #_dUserid == 0 or #self.m_zzMoney.text == 0 then
			UIManager.AddPopTip({strTit='请正确的输入对方信息'})
			return
		end
		
		local zz_money_num = tonumber(self.m_zzMoney.text)
		local safe_box_money_num = tonumber(self.m_txtSafeBoxCoin.text)
		if zz_money_num and safe_box_money_num then
			zz_money_num = zz_money_num * 10000
			if safe_box_money_num >= zz_money_num then
				coroutine.start(Friend_Find, {
					userid = _dUserid,
					callbackSuccess = function (info)
						UIManager.Show('ControllerSafeBoxTransferCoinMsg',{
							state = 1,
							headurl = info.headurl,
							nickname = info.nickname,
							userid = info.userid,
							val = zz_money_num,
							dUserid = _dUserid,
							callback = function (_info)
								self:RefreshGold(_info)
							end,
						})
					end,
					callbackFailure = function (info)
						self.m_zzUID.text = ""
						self.m_zzMoney.text = ""
						self.m_zzWan.text = ""
						UIManager.Show('ControllerSafeBoxTransferCoinMsg',{
							state=0
						})
					end
				})
			else
				UIManager.AddPopTip({strTit='保险箱金额不足'})
			end
		end
    end)
    
    --转入/转出记录
    --记录列表
	self.m_recordList=self.m_view:GetChild('n62'):GetChild('n78').asList
	self.m_recordList:SetVirtual()
	self.m_recordList.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_recordData[theIndex+1]
		_com:GetChild("n74").text=_t.nickname
		_com:GetChild("n75").text=_t.userid
		_com:GetChild("n76").text=_t.createtime
		_com:GetChild("n77").text=formatVal(_t.gold)
		--_com:GetChild('icon').asLoader.url=HandleWXIcon(_t.headurl)
	end
	--接受服务器数据后设置
	self.m_recordList.numItems = 0
	self.m_recordData=nil
end

function ControllerSafeBox2:RequestRecordIn()
	coroutine.start(SafeBox_Deposit_Log_In,{
		userid = loginSucceedInfo.user_info.userid,
		indexStart = 0,
		indexEnd = 30,--默认查询30条记录
		callbackSuccess = function (info)
            local _arr = json.decode(info.array)
			if _arr then
				self.m_recordData = _arr
				self.m_recordList.numItems = #_arr
			end
		end
	})
end

function ControllerSafeBox2:RequestRecordOut()
	coroutine.start(SafeBox_Deposit_Log_Out,{
		userid = loginSucceedInfo.user_info.userid,
		indexStart = 0,
		indexEnd = 30,--默认查询30条记录
		callbackSuccess = function (info)
			local _arr = json.decode(info.array)
			if _arr then
				self.m_recordData = _arr
				self.m_recordList.numItems = #_arr
			end
		end
	})
end

function ControllerSafeBox2:RefreshGold(info)
	self.m_txtExternalCoin.text = info.gold
	self.m_txtSafeBoxCoin.text = info.strongboxgold
    setSelfMoney(tonumber(info.gold))
    self.m_inputNumber.text = ''
	self.m_box_gold = tonumber(info.strongboxgold)
	self.m_wanNumber.text = ''

	self:ClearZzNum()
end

function ControllerSafeBox2:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_viewParent)
	self.m_viewParent.visible = true
	self.m_viewParent:GetTransition('t0'):Play()

    self.m_select.selectedIndex = 0
    self.m_txtExternalCoin.text = ''
    self.m_txtSafeBoxCoin.text = ''

	self:ClearZzNum()
    self:RequestGoldNum()
end

function ControllerSafeBox2:RequestGoldNum()
	coroutine.start(SafeBox_Deposit_Check,{
		userid = loginSucceedInfo.user_info.userid,
		callbackSuccess = function (info)
			self:RefreshGold(info)
		end
	})
end

function ControllerSafeBox2:OnHide()
	self.m_viewParent.visible = false
end

function ControllerSafeBox2:ClearZzNum()
	self.m_zzUID.text = ''
	self.m_zzMoney.text = ''
	self.m_zzWan.text = ''
end

return ControllerSafeBox2