--商圈推广系统界面
local ControllerExtensionSystem = class("ControllerExtensionSystem")

function ControllerExtensionSystem:Init()
	self.m_view=UIPackage.CreateObject('extensionsystem','extensionSystemView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
		UIManager.Hide('ControllerExtensionSystem')
		
		UIManager.Show('ControllerHall')
	end)

	self.share_url = nil
	self.save_url = nil

	--发送分享图片给别人（截屏）
	self.m_view:GetChild("btnShareQR1").onClick:Add(function ()
		--if (F_Util.isAndroid() or F_Util.isWin()) and self.save_url then
		if self.save_url then
			F_Tool.instance:DownloadSavePhotoAlbum(self.save_url, function () UIManager.AddPopTip({ strTit = "二维码已保存至相册"}) end)
		else
			UIManager.AddPopTip({ strTit = "该功能尚未开通"})
		end
	end)

	--复制链接
	self.m_view:GetChild("btnShareQR2").onClick:Add(function ()
		--if (F_Util.isAndroid() or F_Util.isWin()) and self.share_url and string.len(self.share_url) > 0 then
		if self.share_url and string.len(self.share_url) > 0 then
			UIManager.AddPopTip({ strTit = "分享链接复制成功"})
			F_Tool.instance:SetCopyStr(self.share_url)
		else
			UIManager.AddPopTip({ strTit = "该功能尚未开通"})
		end
	end)

	--新增成员
	self.m_view:GetChild("btn0").onClick:Add(function ()
		self:DefaultSelect()
	end)
	
	self.m_list0=self.m_view:GetChild('list0').asList
	self.m_list0:SetVirtual()
	self.m_list0.itemRenderer = function (theIndex,theGObj)
		local _com = theGObj.asCom
		local _t = self.m_listData0[theIndex + 1]
		_com.data = _t
		_com:GetController('c1').selectedIndex = _t.order_id <=4 and _t.order_id - 1 or 3
		_com:GetChild('4').text = _t.order_id
		--_com:GetChild("head"):GetChild("icon").asLoader.url=HandleWXIcon(_t.headurl)
		_com:GetChild('txtNickname').text = string.format("%s", _t.nickname)
		_com:GetChild('txtID').text = string.format( "%s",_t.userid)
		_com:GetChild('txtVal').text = formatVal(_t.sum_devote)
		_com:GetChild('txtState').text = _ServerName[_t.status]
	end

	--接受服务器数据后设置
	self.m_list0.numItems = 0
	self.m_listData0=nil

	--新增成员查找
	self.m_view:GetChild("btnFind").onClick:Add(function ()
		--print('新增成员查找')
		self.m_view:GetController('c2').selectedIndex=1
		self.m_list0_1.numItems = 0
		self.m_listData0_1 = nil
		coroutine.start(function ()
			local _www = WWW(string.format(Url_extensionSystem_newUser,
			tonumber(loginSucceedInfo.user_info.userid),tonumber(self.m_view:GetChild('txtFindID').text),loginSucceedInfo.token))
			coroutine.www(_www)
			if _www.error~=nil then
				UIManager.AddPopTip({strTit=_www.error})
				return 
			end
			--print(_www.text)
			local _info = json.decode(_www.text)
			self.m_listData0_1 = _info.data
			self.m_list0_1.numItems = #self.m_listData0_1
		end)
	end)

	self.m_list0_1 = self.m_view:GetChild('list0-1').asList
	self.m_list0_1:SetVirtual()
	self.m_list0_1.itemRenderer = function (theIndex,theGObj)
		local _com = theGObj.asCom
		local _t = self.m_listData0_1[theIndex+1]
		_com.data=_t
		_com:GetChild('txtNickName').text = _t.nickname
		_com:GetChild('txtID').text = _t.userid
		_com:GetChild('txtRoomID').text = _t.room_num
		_com:GetChild('txtRoom').text = _t.place_name
		_com:GetChild('txtShuiShou').text = formatVal(_t.tax)
		_com:GetChild('txtFanLi').text = formatVal(_t.fanli)
		_com:GetChild('txtTime').text = _t.add_time
	end
	--接受服务器数据后设置
	self.m_list0_1.numItems = 0
	self.m_listData0_1 = nil

	--直属收入
	self.m_view:GetChild("btnReceiveAll_1").onClick:Add(function ()
		self:RequestZhiShuReward()
	end)

	self.m_click_time = Time.time
	self.m_view:GetChild("btnZhiShuShuXin").onClick:Add(function ()
		if Time.time - self.m_click_time > 1 then
			self.m_click_time = Time.time
			self.m_funBtn1()
		else
			UIManager.AddPopTip({strTit='太累了，休息一下吧'})
		end
	end)

	self.m_view:GetChild("btnShouRuJiLu").onClick:Add(function ()
		UIManager.Show('ControllerExtensionIncome')
	end)

	self.m_funBtn1 = function ()
		self.m_list1.numItems = 0
		self.m_listData1=nil
		self.m_view:GetChild("btnReceiveAll_1").enabled = false
		local format_str = "可领取：[color=#FEBF50]%s[/color]"
		self.m_view:GetChild('txt1').text=string.format(format_str, 0)
		--print('直属收入')
		coroutine.start(function ()
			local _www = WWW(string.format(Url_extensionSystem_directIncome,loginSucceedInfo.user_info.userid,loginSucceedInfo.token))
			coroutine.www(_www)
			if _www.error~=nil then
				UIManager.AddPopTip({strTit=_www.error})
				return
			end
			--print(_www.text)
			local _info=json.decode(_www.text)
			self.m_listData1=_info.data.data
			self.m_list1.numItems = #self.m_listData1

			--self.m_view:GetChild('txt1').text = string.format(format_str , formatVal(_info.data.sum.sum_today),formatVal(_info.data.sum.sum_income), formatVal(_info.data.sum.claimable))
			self.m_view:GetChild('txt1').text = string.format(format_str,formatVal(_info.data.sum.claimable))
			if _info.data.sum.claimable==0 then
				self.m_view:GetChild("btnReceiveAll_1").enabled=false
			else
				self.m_view:GetChild("btnReceiveAll_1").enabled=true		
			end
		end)
	end
	self.m_view:GetChild("btn1").onClick:Add(self.m_funBtn1)
	self.m_list1=self.m_view:GetChild('list1').asList
	self.m_list1:SetVirtual()
	self.m_list1.itemRenderer = function (theIndex,theGObj)
		local _com = theGObj.asCom
		local _t = self.m_listData1[theIndex+1]
		_com.data = _t
		--_com:GetChild("head"):GetChild("icon").asLoader.url=HandleWXIcon(_t.headurl)
		_com:GetChild('txtNickname').text = string.format("%s", _t.nickname)
		_com:GetChild('txtID').text = string.format( "ID：%s 筹码：%s", _t.userid, formatVal(_t.gold))
		_com:GetChild('txtVal1').text = formatVal(_t.sum_devote)
		_com:GetChild('txtVal0').text = _ServerName[_t.status] --_t.status==1 and '在线' or '离线'
	end
	--接受服务器数据后设置
	self.m_list1.numItems = 0
	self.m_listData1=nil

	--团队收入
	self.m_view:GetChild("btnReceiveAll_2").onClick:Add(function ()
		coroutine.start(function ()
			local _www = WWW(string.format(Url_extensionSystem_getCoin,loginSucceedInfo.user_info.userid,1,loginSucceedInfo.token))
			coroutine.www(_www)
			if _www.error~=nil then
				UIManager.AddPopTip({strTit=_www.error})
				return 
			end
			--print(_www.text)
			local _info=json.decode(_www.text)
			if _info.data==false then
				UIManager.AddPopTip({strTit='领取失败'})
			else
				self.m_funBtn2()
			end
		end)
	end)

	self.m_funBtn2=function ()
		self.m_list2.numItems = 0
		self.m_listData2=nil
		self.m_view:GetChild("btnReceiveAll_2").enabled=false
		local format_str = "团队成员数：[color=#FEBF50]%s[/color]	             今日总收入：[color=#FEBF50]%s[/color]\n可领取：[color=#FEBF50]%s[/color]"
		self.m_view:GetChild('txt2').text=string.format(format_str, 0, 0, 0)
		--print('团队收入')
		coroutine.start(function ()
			local _www = WWW(string.format( Url_extensionSystem_groupIncome,loginSucceedInfo.user_info.userid,loginSucceedInfo.token ))
			coroutine.www(_www)
			if _www.error~=nil then
				UIManager.AddPopTip({strTit=_www.error})
				return 
			end

			--print(_www.text)
			local _info = json.decode(_www.text)
			self.m_listData2 = _info.data.data
			self.m_list2.numItems = #self.m_listData2

			self.m_view:GetChild('txt2').text=string.format(format_str,_info.data.sum.sum_team_member,formatVal(_info.data.sum.sum_today),formatVal(_info.data.sum.sum_income))

			if _info.data.sum.sum_income==0 then
				self.m_view:GetChild("btnReceiveAll_2").enabled=false
			else
				self.m_view:GetChild("btnReceiveAll_2").enabled=true
			end
		end)
	end
	self.m_view:GetChild("btn2").onClick:Add(self.m_funBtn2)
	self.m_list2=self.m_view:GetChild('list2').asList
	self.m_list2:SetVirtual()
	self.m_list2.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_listData2[theIndex+1]
		_com.data=_t
		--_com:GetChild("head"):GetChild("icon").asLoader.url=HandleWXIcon(_t.headurl)
		_com:GetChild('txtNickname').text = string.format("%s", _t.nickname)
		_com:GetChild('txtID').text = string.format( "%s", _t.userid)
		--他的收入
		_com:GetChild('txtVal0').text = formatVal(_t.user_devote)
		--我的收入
		_com:GetChild('txtVal1').text = formatVal(_t.pid_income)
		_com:GetChild('txtTime').text = _t.add_time

	end
	--接受服务器数据后设置
	self.m_list2.numItems = 0
	self.m_listData2=nil

	--领取记录
	self.m_view:GetChild("btn3").onClick:Add(function ()
		self.m_list3.numItems = 0
		self.m_listData3=nil
		--print('领取记录')
		coroutine.start(function ()
			local _www = WWW(string.format(Url_extensionSystem_receive,loginSucceedInfo.user_info.userid,loginSucceedInfo.token))
			coroutine.www(_www)
			if _www.error~=nil then
				UIManager.AddPopTip({strTit=_www.error})
				return 
			end
			--print(_www.text)
			local _info=json.decode(_www.text)
			self.m_listData3=_info.data
			self.m_list3.numItems = #self.m_listData3

			
		end)
	end)
	self.m_list3=self.m_view:GetChild('list3').asList
	self.m_list3:SetVirtual()
	self.m_list3.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_listData3[theIndex+1]
		_com.data=_t
		_com:GetChild('txtTime').text=_t.add_time
		_com:GetChild('txtVal').text=formatVal(_t.devote)
	end
	--接受服务器数据后设置
	self.m_list3.numItems = 0
	self.m_listData3=nil
end

--默认选择 新增成员
function ControllerExtensionSystem:DefaultSelect()
	self.m_list0.numItems = 0
	self.m_listData0=nil
	--print('默认选择 新增成员')
	coroutine.start(function ()
		local _www = WWW(string.format(Url_extensionSystem_newUser2,loginSucceedInfo.user_info.userid,loginSucceedInfo.token ))
		coroutine.www(_www)
		if _www.error ~= nil then
			UIManager.AddPopTip({strTit=_www.error})
			return 
		end
		--print(_www.text)
		local _info = json.decode(_www.text)
		self.m_listData0 = _info.data

		table.sort(self.m_listData0, function (a,b)
			return a.order_id < b.order_id
		end)

		self.m_list0.numItems = #self.m_listData0
		
	end)
	self.m_view:GetController('c2').selectedIndex=0
end

function ControllerExtensionSystem:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	--不能删除影响截图分享
	--UIManager.Hide('ControllerHall')
	self.m_view:GetChild('txtNickName').text=loginSucceedInfo.user_info.nickname
	self.m_view:GetChild('txtID').text=string.format("ID：%s",loginSucceedInfo.user_info.userid)
	if loginSucceedInfo.user_info.vipnumber then
		self.m_view:GetChild('txtID').text=string.format("ID：%s",loginSucceedInfo.user_info.vipnumber)
	end

	self.m_view:GetChild("head"):GetChild("icon").asLoader.url = GetPlySelfHeadUrl()

	self.m_view:GetChild('txtTotalMemberCount').text='直属人数：0'
	self.m_view:GetChild('txtTodayNewMemberCount').text='今日新增：0'
	self.m_view:GetChild('txtTodayContributeNumber').text='今日收入：0'
	self.m_view:GetChild('txtTotalContributeNumber').text='总共收入：0'
	self.m_view:GetChild('txtDirectScaleNumber').text='返利比例：0'
	coroutine.start(function ()
        local _www = WWW(string.format( Url_extensionSystem_index,loginSucceedInfo.user_info.userid,loginSucceedInfo.token ))
        coroutine.www(_www)
        if _www.error~=nil then
            UIManager.AddPopTip({strTit=_www.error})
            return 
        end
		local _info=json.decode(_www.text)
		self.m_view:GetChild('txtTotalMemberCount').text='直属人数：'.._info.data.sum_id
		self.m_view:GetChild('txtTodayNewMemberCount').text='今日新增：'.._info.data.today_id
		self.m_view:GetChild('txtTodayContributeNumber').text='今日收入：'..formatVal(_info.data.today_money)
		self.m_view:GetChild('txtTotalContributeNumber').text='总共收入：'..formatVal(_info.data.sum_money)
		self.m_view:GetChild('txtDirectScaleNumber').text='返利比例：'.._info.data.directScale.."%"
	end)

	-- 分享链接部分
	if not self.share_url then
		local spreadId = loginSucceedInfo.user_info.spreadId
		if spreadId and spreadId > 0 then
			--旧版本
			--self.share_url = string.format("http://%s/?spreadId=%s", ServerInfo.shareIpArr, spreadId)
			--新服务器版本
			self.share_url = string.format("http://%s/?spreadId=%s", ServerInfo.shareIpAddress, spreadId)

			-- 新的二维码
			coroutine.start(getQRCode, { text = string.gsub(self.share_url, "&", "%%26"), callbackSuccess = function (url)
				self.m_view:GetChild('n48').asLoader.url = url
				self.save_url = url
			end})
		else
			--旧的二维码部分, 苹果可能要用
			self.share_url = ""
			if loginSucceedInfo.user_info.QRCodeLoaderUrl then
				self.save_url = loginSucceedInfo.user_info.QRCodeLoaderUrl
				self.m_view:GetChild('n48').asLoader.url = loginSucceedInfo.user_info.QRCodeLoaderUrl
			end
		end
	end

	self.m_view:GetChild('share_ip').text = self.share_url
	self:DefaultSelect()
end

function ControllerExtensionSystem:RequestZhiShuReward()
	coroutine.start(function ()
		local _www = WWW(string.format(Url_extensionSystem_getCoin,loginSucceedInfo.user_info.userid,0,loginSucceedInfo.token))
		coroutine.www(_www)
		if _www.error ~= nil then
			UIManager.AddPopTip({strTit=_www.error})
			return
		end
		--print(_www.text)
		local _info = json.decode(_www.text)
		if _info.data == false then
			UIManager.AddPopTip({strTit = '已经领取'})
		else
			self.m_funBtn1()
		end
	end)
end

function ControllerExtensionSystem:OnHide()
	self.m_view.visible=false
end
return ControllerExtensionSystem