--聊天相关
local H_TexasChat=class("H_TexasChat")

function H_TexasChat:Init(controller)
	self.m_controller = controller
	self.m_chatComParent = self.m_controller.m_content:GetChild("chat")
	self.m_chatCom=self.m_chatComParent:GetChild("chatContent")
	--聊天 (查询喇叭的数量)
    self.m_controller.m_content:GetChild("btnMessage").onClick:Add(function ()
		--if gameData.chair == -1 then
		--	UIManager.AddPopTip({strTit='没有坐下'})
		--	return
		--end
		self.m_chatComParent.visible = true
		self.m_labaCount=0
		self.m_chatCom:GetChild('txtLaBaCount').text = string.format("(喇叭：%s)", self.m_labaCount)
		coroutine.start(Bag_Get, {
			userid=loginSucceedInfo.user_info.userid,
			callbackSuccess=function (info)
				for i,v in ipairs(info.package) do
					if tonumber(v.type)==10001 and tonumber(v.number)>0 then
						self.m_labaCount=tonumber(v.number)
						self.m_chatCom:GetChild('txtLaBaCount').text = string.format("(喇叭：%s)", self.m_labaCount)
					end
				end
			end
		})
	end)

	self.m_chatCom:GetChild("btnClose").onClick:Add(function ()
		self.m_chatComParent.visible=false
	end)

	self.m_controllerType = self.m_chatCom:GetController("c1")
	-- 选择信息类型
	self.m_controllerSltPanel = self.m_chatCom:GetController("c2") -- (0是打开 1 是关闭)
	-- 是否打开选择面板
	self.m_controllerSltInfo = self.m_chatCom:GetController("c3") -- (0是全服 1 是私聊 3是关闭)

	self.m_chatCom:GetChild("btnLaBa").onClick:Add(function ()
		self.m_controllerType.selectedIndex=0
		self.m_chatCom:GetChild("chatInput").text=''

		self:OpenIdleChat()
	end)

	-- 好友
	self.m_chatCom:GetChild("btnHaoYou").onClick:Add(function ()
		coroutine.start(ChatFriend_List, {
			userid = loginSucceedInfo.user_info.userid,
			callbackSuccess = function (info)
				if info.array then
					if utf8.len(info.array) > 0 then
						local _arry = json.decode(info.array)
						table.sort(_arry, function (a,b)
							return a.inServerID > b.inServerID
						end)
						self.m_friendListData = _arry
						self.m_friendList.numItems = #_arry
					end
				end
			end
		})

		self.m_controllerType.selectedIndex = 1
		self:HideInputChat()
	end)

	self.m_chatCom:GetChild("btnDuanYu").onClick:Add(function ()
		self.m_controllerType.selectedIndex=2
		self.m_chatCom:GetChild("chatInput").text=''

		self:HideInputChat()
	end)

	self.m_chatCom:GetChild("btnBiaoQing").onClick:Add(function ()
		self.m_controllerType.selectedIndex=3

		self:HideInputChat()
	end)

	self.m_chatCom:GetChild("btnBiaoQingVip").onClick:Add(function ()
		self.m_controllerType.selectedIndex = 4

		self:HideInputChat()
	end)

	--玩家文本聊天
	self.m_chatCom:GetChild("btnSend").onClick:Add(function ()
		if gameData.chair==-1 then
			UIManager.AddPopTip({strTit='发送失败,请坐下后重试'})
			return
		end
		if utf8.len(self.m_chatCom:GetChild("chatInput").text)>15 then
			UIManager.AddPopTip({strTit='长度15字以内'})
			return
		end
		--喇叭
		-- (0是全服 1 是私聊 3是关闭)
		if self.m_controllerSltInfo.selectedIndex == 3 then
			return
		end

		if self.m_controllerSltInfo.selectedIndex == 0 then
			print('发送喇叭消息')
			coroutine.start(function ()
				local _txt=self.m_chatCom:GetChild("chatInput").text
				self.m_chatCom:GetChild("chatInput").text=''

				local _info={
					type=1,
					context=_txt,
					nickname=loginSucceedInfo.user_info.nickname,
					headurl=HandleWXIcon(loginSucceedInfo.user_info.headurl)
				}
				--print(json.encode(_info))
				--local _str=string.format(Url_laBa,json.encode(_info),loginSucceedInfo.user_info.userid,loginSucceedInfo.token)
				--local _www = WWW(_str)

				local _form =UnityEngine.WWWForm()
				_form:AddField("message", json.encode(_info))
				_form:AddField("user_id", loginSucceedInfo.user_info.userid)
    			_form:AddField("token", loginSucceedInfo.token)
    			local _www = WWW(Url_laBa,_form)
    
				coroutine.www(_www)
				if _www.error~=nil then
					UIManager.AddPopTip({strTit=_www.error})
					return 
				end
				print('_www.text:'.._www.text)
				local info=json.decode(_www.text)
				if info.code~=1 then
					UIManager.AddPopTip({strTit=info.msg})
				else
					self.m_labaCount=self.m_labaCount-1
					self.m_chatCom:GetChild('txtLaBaCount').text = string.format("(喇叭：%s)", self.m_labaCount)
				end
			end)
		else
			--玩家聊天
			local _txt=self.m_chatCom:GetChild("chatInput").text
			self.m_chatCom:GetChild("chatInput").text=''
			local _info={
				from=loginSucceedInfo.user_info.userid,
				mtype=10005,
				c=_txt
			}
		
			local msg = Protol.GameBaseMsg_pb.UserChat()
			msg.senduserid=0
			msg.targetuserid=-1
			msg.jsoninfo=json.encode(_info)
			local pb_data = msg:SerializeToString()
		
			NetManager.SendMessage(GameServerConfig.logic,'UserChat',pb_data)
		end
	end)

	--初始化短语
	self.m_duanYuList=self.m_chatCom:GetChild("duanYuList").asList
	self.m_duanYuList:RemoveChildrenToPool()
	for i,v in ipairs(DuanYuMap) do
		local _com=self.m_duanYuList:AddItemFromPool()
		_com:GetChild("title").text=v[2]
		_com.data=v
	end
	self.m_duanYuList.onClickItem:Add(function (context)
		if gameData.chair==-1 then
			UIManager.AddPopTip({strTit='发送失败,请坐下后重试.'})
			return
		end
		local _gcom=context.data
		local _info =
		{
			from=loginSucceedInfo.user_info.userid,
			mtype=10002,
			c=_gcom.data[1]
		}

		local msg = Protol.GameBaseMsg_pb.UserChat()
        msg.senduserid=0
        msg.targetuserid=-1
        msg.jsoninfo=json.encode(_info)
		local pb_data = msg:SerializeToString()

		NetManager.SendMessage(GameServerConfig.logic,'UserChat',pb_data)

		self.m_chatComParent.visible=false
	end)
	
	--vip表情
	local _biaoQingVipList = self.m_chatCom:GetChild("faceVipList").asList
	_biaoQingVipList.onClickItem:Add(H_TexasChat._OnClickBiaoQingVIP, self)

	--表情
	local _biaoQingList=self.m_chatCom:GetChild("faceList").asList
	_biaoQingList.onClickItem:Add(H_TexasChat._OnClickBiaoQing, self)

	self.is_open_panel = false
	self.m_allChatEmpty = self.m_chatCom:GetChild("allChatEmpty")
	self.m_privateChatEmpty = self.m_chatCom:GetChild("privateChatEmpty")
	self:ChatNoneTips()

	--btnChange 打开选择面板
	self.m_chatCom:GetChild("btnChange").onClick:Add(function ()
		if self.is_open_panel then
			self.m_controllerSltPanel.selectedIndex = 1
		else
			self.m_controllerSltPanel.selectedIndex = 0
		end
		self.is_open_panel = not self.is_open_panel
	end)

	-- btnAll 全局消息
	self.m_chatCom:GetChild("btnAll").onClick:Add(function ()
		self.m_controllerSltInfo.selectedIndex = 0
		self.m_controllerSltPanel.selectedIndex = 1
		self.is_open_panel = false
	end)

	-- btnPrivate 私聊消息
	self.m_chatCom:GetChild("btnPrivate").onClick:Add(function ()
		self.m_controllerSltInfo.selectedIndex = 1
		self.m_controllerSltPanel.selectedIndex = 1
		self.is_open_panel = false
	end)

	--暂时只开放 表情vip 表情 语音短语
	--self.m_chatCom:GetChild("btnLaBa").visible=false
	--self.m_chatCom:GetChild("btnHaoYou").visible=false

	self.m_controllerType.selectedIndex = 2
	self:HideInputChat()

	-- 1.喇叭信息（全服）
	self.m_laBaList = self.m_chatCom:GetChild('laBaList').asList
	self.m_laBaList:SetVirtual()
	self.m_laBaList.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_laBaListData[theIndex+1]
		_com.data=_t

		local _info=json.decode(_t)
		_com:GetChild('n25').text = string.format("[全服喇叭]%s", _info.context)
		_com:GetChild('n28').text = _info.nickname
		_com:GetChild("head"):GetChild("icon").asLoader.url=HandleWXIcon(_info.headurl)
	end
	--接受服务器数据后设置
	self.m_laBaListData={}
	self.m_laBaList.numItems = 0

	-- 2.私人聊天
	self.m_privateList = self.m_chatCom:GetChild('siLiaoList').asList
	self.m_privateList:SetVirtual()
	self.m_privateList.itemRenderer = function (theIndex,theGObj)
		local _com = theGObj.asCom
		local _t = self.m_privateListData[theIndex+1]
		_com.data = _t
		--local _info = json.decode(_t)
		_com:GetChild('n25').text = string.format("[本房间]%s", _t.context)
		_com:GetChild('n28').text = _t.nickname
		_com:GetChild("head"):GetChild("icon").asLoader.url=HandleWXIcon(_t.headurl)
	end
	--接受服务器数据后设置
	self.m_privateListData = {}
	self.m_privateList.numItems = 0

	-- 3.好友信息（追踪）
	self.m_friendList = self.m_chatCom:GetChild('haoYouList').asList
	self.m_friendList:SetVirtual()
	self.m_friendList.itemRenderer = function (theIndex,theGObj)
		local _com = theGObj.asCom
		local _t = self.m_friendListData[theIndex+1]
		_com.data = _t
		-- man
		-- woman
		_com:GetChild('head'):GetChild('icon').asLoader.url = HandleWXIcon(_t.headurl)
		_com:GetChild('txtNickName').text=_t.nickname
		-- 追踪
		local has_room_go = _t["inServerID"] ~= 0
		-- 追踪按钮
		local btnGoRoom =_com:GetChild("btnYQ").asButton
		btnGoRoom.visible = has_room_go
		_com:GetChild("txtOnLine").text = has_room_go and "在线" or "离线"
		-- 房间名字
		local com_txt = _com:GetChild("txtBet")
		if has_room_go then
			-- 房间名字
			local server_name = _ServerName[_t.inServerID]
			if server_name then
				com_txt.text = string.format("%s(%s)", server_name, _t.tableID)
			else
				com_txt.text = ""
			end
			btnGoRoom:RemoveEventListeners()
			btnGoRoom.onClick:Add(function ()
				UIManager.Show('ControllerWaitTip')
				if self.m_controller:GetSelfGaming() then
					local cont_str = "确定离开游戏追踪好友吗？"
					UIManager.Show('ControllerHallTips', { title = "", content = cont_str, confirm = function()
						self.m_controller:SendGiveUp()
						self:GoToFriend(_t)
					end })
				else
					self:GoToFriend(_t)
				end
			end)
		else
			com_txt.text = ""
		end
	end
	--接受服务器数据后设置
	self.m_friendListData = {}
	self.m_friendList.numItems = 0
end

function H_TexasChat:GoToFriend(_t)
	self.m_chatComParent.visible = false
	NetManager.SendMessage(GameServerConfig.logic,'ExitGameBroadcast')
	self.m_comGoBack = function()
		UIManager.Hide('ControllerWaitTip')
		local arg_info =
		{
			isSkipRefresh = true,
			isLinkToOpenRoom = true,
			inServerID = _t.inServerID,
			tableID = _t.tableID,
		}
		UIManager.Show('ControllerGameHall', arg_info)
		self.m_comGoBack = nil
	end
end

function H_TexasChat:_OnClickBiaoQingVIP(context)
	if tonumber(loginSucceedInfo.user_info.viptime) <= 0 then
		UIManager.AddPopTip({strTit='亲爱的玩家，您不是VIP暂时无法使用该功能'})
		return
	end
	self:_OnClickBiaoQing(context)
end

function H_TexasChat:_OnClickBiaoQing(context)
	local _com = context.data
	if gameData.chair==-1 then
		UIManager.AddPopTip({strTit='没有坐下'})
		return
	end

	local _info =
	{
		from=loginSucceedInfo.user_info.userid,
		mtype=10003,
		c=_com.name
	}

	local msg = Protol.GameBaseMsg_pb.UserChat()
	msg.senduserid=0
	msg.targetuserid=-1
	msg.jsoninfo=json.encode(_info)
	local pb_data = msg:SerializeToString()

	NetManager.SendMessage(GameServerConfig.logic,'UserChat',pb_data)

	self.m_chatComParent.visible = false
end

function H_TexasChat:HideChat()
	self.m_chatComParent.visible=false
	--清空喇叭信息
	self.m_laBaListData={}
	self.m_laBaList.numItems = 0
	--清空私聊信息
	self.m_privateListData = {}
	self.m_privateList.numItems = 0

	self:ChatNoneTips()
end

-- 喇叭消息
function H_TexasChat:AddLaBaChat(content, from_id)
	table.insert(self.m_laBaListData, content)
	if #self.m_laBaListData>100 then
		table.remove(self.m_laBaListData, 1)
	end
	self.m_laBaList.numItems = #self.m_laBaListData
	self.m_allChatEmpty.text = ""
	if from_id == loginSucceedInfo.user_info.userid then
		self.m_chatComParent.visible = false
	end
end

-- 私聊消息
function H_TexasChat:AddPrivateChat(content, from_id)
	table.insert(self.m_privateListData, content)
	if #self.m_privateListData > 100 then
		table.remove(self.m_privateListData, 1)
	end
	self.m_privateList.numItems = #self.m_privateListData
	self.m_privateChatEmpty.text = ""
	if from_id == loginSucceedInfo.user_info.userid then
		self.m_chatComParent.visible = false
	end
end

-- 私聊没有数据的提示
function H_TexasChat:ChatNoneTips()
	self.m_privateChatEmpty.text = "暂无房间聊天记录"
	self.m_allChatEmpty.text = "暂无全服聊天记录"
end
-- 默认就是私聊
function H_TexasChat:OpenIdleChat()
	self.m_controllerSltPanel.selectedIndex = 1
	self.m_controllerSltInfo.selectedIndex = 1
end

function H_TexasChat:HideInputChat()
	self.is_open_panel = false
	self.m_controllerSltPanel.selectedIndex = 1
	self.m_controllerSltInfo.selectedIndex = 2
end

function H_TexasChat:CheckGoBackSuccess()
	if self.m_comGoBack then
		self.m_comGoBack()
	end
end

return H_TexasChat