--游戏大厅界面
local ControllerGameHall = class("ControllerGameHall")

local RoomName={
	['白手起家']='ui://gamehall/text_1',
	['横财就手']='ui://gamehall/text_10',
	['黄袍加身']='ui://gamehall/text_11',
	['旗开得胜']='ui://gamehall/text_12',
	['杀气腾腾']='ui://gamehall/text_13',
	['所向披靡']='ui://gamehall/text_14',
	['万贯家财']='ui://gamehall/text_15',
	['王者荣耀']='ui://gamehall/text_16',
	['王者之争']='ui://gamehall/text_17',
	['小试牛刀']='ui://gamehall/text_18',
	['一决高下']='ui://gamehall/text_19',
	['比下高低']='ui://gamehall/text_2',
	['一展身手']='ui://gamehall/text_20',
	['遇佛杀佛']='ui://gamehall/text_21',
	['猪笼入水']='ui://gamehall/text_22',
	['财大气粗']='ui://gamehall/text_3',
	['财元广进']='ui://gamehall/text_4',
	['登峰造极']='ui://gamehall/text_5',
	['帝王之争']='ui://gamehall/text_6',
	['富可敌国']='ui://gamehall/text_7',
	--['更近一步']='ui://gamehall/text_8',
	['更进一步']='ui://gamehall/text_8',
	['恭喜发财']='ui://gamehall/text_9',
}


--得到 初级/中级/高级 房间列表
local _ServerMap =
{
	[1]={'gold_10',10},
	[2]={'gold_11',11},
	[3]={'gold_12',12},
	[4]={'gold_13',13},
	[5]={'gold_13',13},
	[6]={'gold_14',14},
}

-- 跳转用
local _ServerId =
{
	[10] = { map_id = 1, select_index = 0 },
	[11] = { map_id = 2, select_index = 1 },
	[12] = { map_id = 3, select_index = 2 },
	[13] = { map_id = 4, select_index = 3 },
	[14] = { map_id = 6, select_index = 5 },
}

function ControllerGameHall:Init()
	self.m_view=UIPackage.CreateObject('gamehall','gameHallView').asCom
	UIManager.normal:AddChild(self.m_view)
	--适配刘海屏水滴屏
    UIManager.AdaptiveAllotypy(self.m_view)
	self.m_view.visible = false
	--保留当前选择的房间索引
	self.m_select_index = 0
	self.m_content=self.m_view:GetChild('content')
	-- 是否是链接打开
	self.m_linkToOpenTableId = 0

    --返回主大厅界面
    self.m_view:GetChild("btnBack").onClick:Add(function ()
        UIManager.Show('ControllerHall')
        UIManager.Hide('ControllerGameHall')
    end)

	self.m_hasFirstKuang = false
	--创建房间
	self.m_content:GetChild("btnCreateRoom").onClick:Add(function ()
        UIManager.Show('ControllerCreateRoom')
	end)

	--加入房间
	self.m_content:GetChild("btnJoinRoom").onClick:Add(function ()
        UIManager.Show('ControllerJoinRoom')
	end)

	--初级场
	self.m_content:GetChild("btnLevel1").onClick:Add(function ()
		self:GetCommonRoomList(1)
		self.m_content:GetController("c1").selectedIndex=0
		self.m_select_index = 0
	end)

	--中级场
	self.m_content:GetChild("btnLevel2").onClick:Add(function ()
		self:GetCommonRoomList(2)
		self.m_content:GetController("c1").selectedIndex=1
		self.m_select_index = 1
	end)

	--高级场
	self.m_content:GetChild("btnLevel3").onClick:Add(function ()
		self:GetCommonRoomList(3)
		self.m_content:GetController("c1").selectedIndex=2
		self.m_select_index = 2
	end)

	--私人房
	self.m_content:GetChild("btnLevel4").onClick:Add(function ()
		self:GetCommonRoomList(4)
        self.m_content:GetController("c1").selectedIndex = 3
		self.m_select_index = 3
	end)

	--查询私人房,根据房间号
	self.m_content:GetChild("btnvip").onClick:Add(function ()
		self:GetCommonRoomList(5)
		self.m_content:GetController("c1").selectedIndex = 4
		self.m_select_index = 4
	end)

	--必下房
	self.m_content:GetChild("btnLevel5").onClick:Add(function ()
		self:GetCommonRoomList(6)
		self.m_content:GetController("c1").selectedIndex = 5
		self.m_select_index = 5
	end)

	self.m_commonRoomList = self.m_content:GetChild('commonRoomList').asList
	--self.m_commonRoomList:SetVirtual()
	self.m_commonRoomList.itemRenderer = function (theIndex,theGObj)
		local _com = theGObj.asCom
		local _t = self.m_commonRoomData.infos[theIndex + 1]
		_com.data = _t
		local _tableconf = _t
		--大小盲
		_com:GetChild("txtBlinds").text=string.format("[color=#FFE42F]%s[/color]/%s", formatVal(_tableconf.xiaomangbet),formatVal(_tableconf.xiaomangbet*2))
		--房间号
		_com:GetChild("txtRoomNumber").text=_tableconf.tableid
		--房间名
		local _s=lua_string_split(_tableconf.tablename,'-')
		--BG
		--if _s[2] and tonumber(_s[2]) <= 7 then
		--	_com:GetChild("bg").asLoader.url='ui://gamehall/icon_bj'.._s[2]
		--else
		--	_com:GetChild("bg").asLoader.url='ui://gamehall/icon_bj1'
		--end
		--_com:GetChild("bg").asLoader.url='ui://hall/bisai_bg'
		--_com:GetChild("name").asLoader.url=RoomName[_s[1]]
		--_com:GetChild("name2").text=_s[2]

		local is_bi_xia = self:GetIsBiXiaReal()
		local bring_min = formatVal(_tableconf.bringmingold)
		local bring_max = formatVal(_tableconf.bringmaxgold)
		--最大最小携带
		--local bring_str = is_bi_xia and string.format("最小带入：[size=50]%s[/size]",bring_max) or string.format("带入：%s/%s",bring_max,bring_min)
		local bring_str = is_bi_xia and bring_min or string.format("%s/%s",bring_min,bring_max)
		_com:GetChild("txtBringLimit").text = bring_str
	
		--人数
		_com:GetController('c2').selectedIndex = _tableconf.person <= 6 and 0 or 1
		_com:GetChild('xx'):GetController('c2').selectedIndex = _tableconf.person <= 6 and 0 or 1
		_com:GetChild('xx'):GetController('c1').selectedIndex = _tableconf.online_person

		_com:GetChild('txtroomName').text = string.format("%s人桌", _tableconf.person <= 6 and "6" or "9")

		-- 前注

		local has_font_bet = _tableconf.frontbet > 0
		_com:GetController('font_bet').selectedIndex = has_font_bet and 1 or 0
		if has_font_bet then
			_com:GetChild('txtPlayerFontBet').text = string.format("前注\n%s", formatVal(_tableconf.frontbet))
		end

		_com:GetChild("txtMustBet").visible=false

		-- 必下标图
		_com:GetChild("bixia").visible = self:GetIsBiXia()

		-- 红包图标
		local table_info = json.decode(_t.tableinfo)
		_com:GetChild("hongbao").visible = table_info.Hd_hongBao and table_info.Hd_hongBao == 1

		-- 边框特效
		local kuang_pos = _com:GetChild("kuang_pos")

		--if not self.m_hasFirstKuang then
		--	UIManager.SetDragonBonesAniObjPos('biankuangOBJ', _com:GetChild("kuang_pos"), Vector3.New(100,100,100))
		--end
		--
		--if not self.m_hasFirstKuang and theIndex + 1 == #self.m_effList then
		--	self.m_hasFirstKuang = true
		--end

		kuang_pos.visible = theIndex == 0

		-- 来自动跳转（非私人房）
		if self.m_linkToOpenTableId > 0 and _t.tableid == self.m_linkToOpenTableId then
			sendEnterGameRequst(_t.tableid,0)
			roomCfg = _t
		end
	end

	self.m_commonRoomList.onClickItem:Add(function (context)
		local _gcom = context.data
		--print("_gcom.data.tableid:".._gcom.data.tableid)
		sendEnterGameRequst(_gcom.data.tableid,0)
		roomCfg = _gcom.data
	end)

	--接受服务器数据后设置
	self.m_commonRoomList.numItems = 0
	self.m_commonRoomData=nil

	--定时器刷新
	Timer.New(function ()
		if self.m_view.visible  then
			--print('0000')
			self:sendServerRoomInfoRequst()
			self:sendVipTableSearchRequst(-1,0)
		end
		
	end,60,-1):Start()  -- 60s刷新
	
	--返回桌子信息
    H_NetMsg:addEventListener('ServerRoomInfoReponse',function (arg)
        --print('收到消息 ServerRoomInfoReponse')
        local msg = Protol.GameBaseMsg_pb.ServerRoomInfoReponse()
		local index = 0
        msg:ParseFromString(arg.pb_data)
		-- 1：人 2：大小盲
		self.m_commonRoomData = msg

		self.m_effList = { }
		for k, v in ipairs(self.m_commonRoomData.infos) do
			index = index + 1
			self.m_effList[index] = index
		end

		table.sort(self.m_commonRoomData.infos, function (a, b)
			local a_full_status = a.online_person == a.person and 1 or 0
			local b_full_status = b.online_person == b.person and 1 or 0
			--if a_full_status ~= b_full_status then
			--	return a_full_status < b_full_status
			--local a_is_empty = a.online_person == 0 and 0 or 1
			--local b_is_empty = b.online_person == 0 and 0 or 1
			-- 人最多 钱多 满人 空桌

			if a.online_person ~= b.online_person then
				return a.online_person > b.online_person
			elseif a.bringmingold ~= b.bringmingold then
				return a.bringmingold > b.bringmingold
			elseif a.person ~= b.person then
				return a.person > b.person
			end
				return a.xiaomangbet > b.xiaomangbet
			end)

		self.m_commonRoomList.numItems = #self.m_commonRoomData.infos
    end)

	--查看我创建的私人房
	self.m_content:GetChild("btnCreateRoomFromMe").onClick:Add(function ()
		self:sendVipTableSearchRequst(1,loginSucceedInfo.user_info.userid)
	end)

	--刷新,显示所有的私人房
	self.m_content:GetChild("btnRefresh").onClick:Add(function ()
		self:sendVipTableSearchRequst(-1,0)
	end)

	--查询私人房,根据房间号
	self.m_content:GetChild("btnSearch").onClick:Add(function ()
		self:sendVipTableSearchRequst(2,tonumber(self.m_content:GetChild("txtSearchRoomNumber").text))
	end)

	--返回私人房信息
    H_NetMsg:addEventListener('VipTableSearchResponse',function (arg)
        local msg = Protol.Poker_pb.VipTableSearchResponse()
        msg:ParseFromString(arg.pb_data)
		UIManager.Hide('ControllerWaitTip')
		if msg.searchtype==1 then
			UIManager.Show('ControllerCreateRoomFromMe',msg)
		else
			self.m_privateRoomData=msg.tableconfig
			self.m_privateRoomList.numItems = #msg.tableconfig
		end
	end)
	self.m_privateRoomList=self.m_content:GetChild('privateRoomList').asList
	self.m_privateRoomList:SetVirtual()
	self.m_privateRoomList.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_privateRoomData[theIndex+1]
		_com.data=_t
		local _tableconf=_t

		_com:GetChild("txtRoomName").text=_tableconf.tablename
		_com:GetChild("txtRoomID").text=_tableconf.tableid
		_com:GetChild("txtPlayerCount").text=string.format("%s/%s",_tableconf.online_person,_tableconf.person)
		_com:GetChild("txtReMainTime").text=string.format("%s分",_tableconf.lefttime)

		if _tableconf.frontbet>0 then
			_com:GetChild("txtBlinds").text=string.format("%s/%s 前注:%s",formatVal(_tableconf.xiaomangbet),formatVal(_tableconf.xiaomangbet*2),formatVal(_tableconf.frontbet))
		else
			_com:GetChild("txtBlinds").text=string.format("%s/%s",formatVal(_tableconf.xiaomangbet),formatVal(_tableconf.xiaomangbet*2))
		end

		if self.m_linkToOpenTableId > 0 and _t.tableid == self.m_linkToOpenTableId then
			UIManager.Show('ControllerPW',{callback=function (arg)
				UIManager.Show('ControllerWaitTip')
				sendTablePwdValidate(_t.tableid, arg)
			end})
			roomCfg = _t
		end
	end
	self.m_privateRoomList.onClickItem:Add(function (context)
		local _gcom=context.data
		print(_gcom.data.tableid)

		local _tableid=_gcom.data.tableid
		UIManager.Show('ControllerPW',{callback=function (arg)
			UIManager.Show('ControllerWaitTip')
			--sendEnterGameRequst(_tableid,arg)
			sendTablePwdValidate(_tableid,arg)
		end})
		roomCfg=_gcom.data
	end)
	--接受服务器数据后设置
	self.m_privateRoomList.numItems = 0
	self.m_privateRoomData = nil

	H_EventDispatcher:addEventListener('refreshSelfMoney',function (arg)
        self.m_content:GetChild('txtMoney').text=formatVal(tonumber(loginSucceedInfo.user_info.gold))
    end)
end

function ControllerGameHall:GetIsBiXia()
	return self.m_select_index == 2
end

function ControllerGameHall:GetIsBiXiaReal()
	return self.m_select_index == 5
end

function ControllerGameHall:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.m_linkToOpenTableId = 0

	--保留选定房间
	if arg.isSkipRefresh == false then
		self:GetCommonRoomList(self.m_select_index + 1)
		self.m_content:GetController("c1").selectedIndex = self.m_select_index
	end

	-- 房间跳转
	if arg.isLinkToOpenRoom then
		--print("arg.inServerID:"..arg.tableID)
		--print("type:"..type(arg.tableID))
		self.m_linkToOpenTableId = arg.tableID
		if _ServerId[arg.inServerID] then
			self.m_select_index = _ServerId[arg.inServerID].select_index
			self:GetCommonRoomList(self.m_select_index + 1)
			self.m_content:GetController("c1").selectedIndex = self.m_select_index
		end
	end

	-- 重新进入新的房间
	self.m_content:GetChild('txtMoney').text = formatVal(tonumber(loginSucceedInfo.user_info.gold))
	Refresh_Person_Gold()
	
	F_SoundManager.instance:OpenMusicVolume()

	UIManager.Hide('ControllerHall')
	GameSubType = GameType.RoomHall
end

function ControllerGameHall:OnHide()
	self.m_view.visible=false
end

function ControllerGameHall:GetCommonRoomList(index)
	--self.m_commonRoomList.numItems = 0
	--self.m_commonRoomData = nil
	--
	--self.m_privateRoomList.numItems = 0
	--self.m_privateRoomData = nil
	local _index = index
	--连接socket

	local t = lua_string_split(loginSucceedInfo.server_info[_ServerMap[index][1]],'#')
	local _gs = t[1]
	local _ip = t[2]
	local _port = t[3]
	local _send_To = t[4]
	local _send_Mcmd = t[5]

	GameServerConfig.ipArr=_ip..':'.._port
	GameServerConfig.send_To=_send_To
	GameServerConfig.send_Mcmd=_send_Mcmd
	GameServerConfig.serverid=_ServerMap[index][2]

	UIManager.Show('ControllerWaitTip')

	F_ResourceManager.instance:AddPackage("newbgdzpk1", function ()
		F_ResourceManager.instance:AddPackage("newbgdzpk2", function ()
			F_ResourceManager.instance:AddPackage("texas",function ()
				F_ResourceManager.instance:AddPackage("biaoqing",function ()
					F_ResourceManager.instance:LoadPrefab("spine_bq.unity3d",nil,function (arr)
						for i=0,arr.Length-1 do
							UIManager.AddPrefab(arr[i])
						end
						UIManager.InitController('ControllerTexas')
						UIManager.Show("ControllerWaitTip",{strTit='',timeOut=10})
						NetManager.ConnectServer(GameServerConfig,function ()
							UIManager.Hide('ControllerWaitTip')
							UIManager.AddPopTip({strTit='连接服务器失败,请重试.'})
						end,function ()
							UIManager.Hide('ControllerWaitTip')
							--开启心跳
							H_HeartbeatManager.Restart(GameServerConfig.logic)
							if _index == 1 or _index == 2 or _index == 3 then
								self:sendServerRoomInfoRequst()
							elseif _index == 4  then
								self:sendVipTableSearchRequst(-1,0)
							elseif _index == 5 then

							elseif _index == 6 then
								self:sendServerRoomInfoRequst()
							end
						end)
					end)
				end)
			end)
		end)
	end)
end

function ControllerGameHall:sendServerRoomInfoRequst()
	--todo 默认请求50
	local msg = Protol.GameBaseMsg_pb.ServerRoomInfoRequst()
	msg.table_startindex=0
	msg.table_endindex=50
	local pb_data = msg:SerializeToString()
	--请求桌子信息
	NetManager.SendMessage(GameServerConfig.logic,'ServerRoomInfoRequst', pb_data)
end

function ControllerGameHall:sendVipTableSearchRequst(searchtype,searchvalue)
	UIManager.Show('ControllerWaitTip')
	--todo 默认请求50
	local msg = Protol.Poker_pb.VipTableSearchRequst()
	msg.searchtype=searchtype
	msg.searchvalue=searchvalue
	msg.table_startindex=0
	msg.table_endindex=50
	local pb_data = msg:SerializeToString()
	--请求桌子信息
	NetManager.SendMessage(GameServerConfig.logic,'VipTableSearchRequst',pb_data)
end

return ControllerGameHall