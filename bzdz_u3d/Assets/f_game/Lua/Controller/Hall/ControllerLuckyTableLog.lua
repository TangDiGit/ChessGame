--转盘中奖记录
local ControllerLuckyTableLog = class("ControllerLuckyTableLog")

function ControllerLuckyTableLog:Init()
	self.m_view=UIPackage.CreateObject('hall','luckyTableLogView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerLuckyTableLog')
	end)
	
	self.m_list=self.m_view:GetChild('list').asList
	self.m_list:SetVirtual()
	self.m_list.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_listData[theIndex+1]
		_com.data=_t
		
		_com:GetChild('txtDes').text=_t.prize_name
		_com:GetChild('txtTime').text=_t.create_time
	end
	--接受服务器数据后设置
	self.m_list.numItems = 0
	self.m_listData=nil
end
function ControllerLuckyTableLog:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	
	self.m_listData=arg.results	
	self.m_list.numItems = #self.m_listData
end

function ControllerLuckyTableLog:OnHide()
	self.m_view.visible=false
end
return ControllerLuckyTableLog