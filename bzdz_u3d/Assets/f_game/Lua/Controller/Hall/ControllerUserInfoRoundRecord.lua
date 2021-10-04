--牌局记录界面
local ControllerUserInfoRoundRecord = class("ControllerUserInfoRoundRecord")

function ControllerUserInfoRoundRecord:Init()
	self.m_view=UIPackage.CreateObject('hall','userInfoRoundRecordView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerUserInfoRoundRecord')
    end)

    self.m_list=self.m_view:GetChild('list').asList
	self.m_list:SetVirtual()
	self.m_list.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_listData[theIndex+1]
		_com.data=_t

		_com:GetChild('txtIndexString').visible=false

		local _s=lua_string_split(_t.hands_cards,'#')
		
		UIManager.SetPoker(_com:GetChild('card1'),tonumber(_s[1]))
		UIManager.SetPoker(_com:GetChild('card2'),tonumber(_s[2]))

		local _table_conf=json.decode(_t.table_conf)
		_com:GetChild('txtRoomLevelBindsString').text=string.format( "%s房(%s人):%s/%s", _table_conf.nickname, _table_conf.gamecount, _table_conf.smallblind, _table_conf.smallblind*2)
		local str_num = tonumber(_t.win_gold) >= 0 and formatVal(_t.win_gold) or string.format("-%s", formatVal(math.abs(_t.win_gold)))
		_com:GetChild('txtProfit').text=string.format( "盈利:[color=#C48E1C]%s[/color]", str_num)
		_com:GetChild('txtTime').text=os.date("%Y-%m-%d %H:%M:%S", _t.created_date)
	end
	self.m_list.onClickItem:Add(function (context)
		local _gcom=context.data
		--print(_gcom.data.game_log_id)
		UIManager.Show('ControllerWaitTip')
		F_ResourceManager.instance:AddPackage("texas",function ()
			UIManager.Hide('ControllerWaitTip')

			--经典数据详情
			coroutine.start(Game_Data_Details_WithHall,{
				userid=loginSucceedInfo.user_info.userid,
				game_log_id=_gcom.data.game_log_id,
				callbackSuccess=function (info)
					UIManager.Show('ControllerLastreWithUserGameData',{data1=_gcom.data,data2=info})
				end
			})
			
		end)
	end)
	--接受服务器数据后设置
	self.m_list.numItems = 0
	self.m_listData=nil

	
	self.m_view:GetChild("toggleTime").onClick:Add(function ()
        table.sort(self.m_listData, function (a,b)
			return a.created_date>b.created_date
		end)

		self.m_list:ScrollToView(0)
		self.m_list:RefreshVirtualList()
	end)
	self.m_view:GetChild("toggleMoney").onClick:Add(function ()
		table.sort(self.m_listData, function (a,b)
			return a.win_gold>b.win_gold
		end)
		self.m_list:ScrollToView(0)
		self.m_list:RefreshVirtualList()
    end)
end

function ControllerUserInfoRoundRecord:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	--接受服务器数据后设置
	self.m_listData=arg.result
	self.m_list.numItems = #arg.result
	
end

function ControllerUserInfoRoundRecord:OnHide()
	self.m_view.visible=false
end
return ControllerUserInfoRoundRecord