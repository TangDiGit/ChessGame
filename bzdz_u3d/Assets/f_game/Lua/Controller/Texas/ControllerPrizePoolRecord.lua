--游戏内查看奖池信息 中奖记录
local ControllerPrizePoolRecord = class("ControllerPrizePoolRecord")

function ControllerPrizePoolRecord:Init()
	self.m_view=UIPackage.CreateObject('texas','texasPrizePoolRecordView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerPrizePoolRecord')
	end)
	
	self.m_list=self.m_view:GetChild('list').asList
	self.m_list:SetVirtual()
	self.m_list.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_listData[theIndex+1]
		_com.data=_t
		_com:GetChild('head'):GetChild('icon').asLoader.url=HandleWXIcon(_t.headurl)
        _com:GetChild('txtNickName').text=_t.nickname
		_com:GetChild("txtMoney").text=_t.wingold
		_com:GetChild("txtTime").text=os.date("%Y-%m-%d %H:%M %S", _t.createtime)
		local _sArry=lua_string_split(_t.cards,'#')
		for i=1,5 do
			UIManager.SetPoker(_com:GetChild("c"..i),tonumber(_sArry[i]))
		end
		
	end
	--接受服务器数据后设置
	self.m_list.numItems = 0
	self.m_listData=nil
end

function ControllerPrizePoolRecord:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.m_listData=arg.RecordInfo
	self.m_list.numItems = #arg.RecordInfo

	self.m_view:GetChild('head'):GetChild('icon').asLoader.url = GetPlySelfHeadUrl()
	self.m_view:GetChild('txtNickName').text=loginSucceedInfo.user_info.nickname

	local _result=json.decode(arg.RecordInfoFromMe.result)

	self.m_view:GetChild('txtLuckyCount').text=_result.wincount
	self.m_view:GetChild('txtMoneyCount').text=formatVal(_result.wintotal)
end

function ControllerPrizePoolRecord:OnHide()
	self.m_view.visible=false
end
return ControllerPrizePoolRecord