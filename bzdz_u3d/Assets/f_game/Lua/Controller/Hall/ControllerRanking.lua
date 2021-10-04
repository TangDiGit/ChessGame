--排行榜界面
local ControllerRanking = class("ControllerRanking")

function ControllerRanking:Init()
	self.m_view=UIPackage.CreateObject('hall','rankingView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerRanking')
    end)

	self.m_list=self.m_view:GetChild('list').asList
	self.m_list:SetVirtual()
	self.m_list.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_listData[theIndex+1]
		_com.data=_t

		local i=theIndex+1
		
		if i<4 then
			_com:GetController('c1').selectedIndex=i-1
		else
			_com:GetController('c1').selectedIndex=3
			_com:GetChild('4').text=i
		end
		_com:GetChild('head'):GetChild('icon').asLoader.url=HandleWXIcon(_t.headurl)
		_com:GetChild('txtNickName').text=_t.nickname
		_com:GetChild('txtMoney').text=formatVal(tonumber(_t.gold))
	end
	--接受服务器数据后设置
	self.m_list.numItems = 0
	self.m_listData=nil
end

function ControllerRanking:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.m_listData=arg
	self.m_list.numItems = #arg
end

function ControllerRanking:OnHide()
	self.m_view.visible=false
end
return ControllerRanking