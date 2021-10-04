--百人场玩家列表
local ControllerBaiRenPlayerList = class("ControllerBaiRenPlayerList")

function ControllerBaiRenPlayerList:Init()
	self.m_view=UIPackage.CreateObject('bairen','baiRenPersonListView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerBaiRenPlayerList')
    end)
end

function ControllerBaiRenPlayerList:Show(arg)
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible = true
    self.m_listData = arg
    self.m_list = self.m_view:GetChild('list').asList
    self.m_list:SetVirtual()
    self.m_list.itemRenderer = function (theIndex, theGObj)
        local _com = theGObj.asCom
        local _t = self.m_listData[theIndex + 1]
        _com.data = _t
        _com:GetChild('n34').text = theIndex + 1
        _com:GetChild("head"):GetChild("icon").asLoader.url = HandleWXIcon(_t.headurl)
        _com:GetChild('txtNickName').text = _t.nickname
        _com:GetChild('txtID').text = string.format( "ID:%s", _t.userid)
        _com:GetChild('txtGold').text = formatVal(tonumber(_t.score))
    end
    self.m_list.numItems = #arg
end

function ControllerBaiRenPlayerList:OnHide()
	self.m_view.visible=false
end

return ControllerBaiRenPlayerList