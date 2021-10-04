--游戏内查看奖池信息 中奖记录
local ControllerBaiRenPrizePoolRecord = class("ControllerBaiRenPrizePoolRecord")

function ControllerBaiRenPrizePoolRecord:Init()
    self.m_view=UIPackage.CreateObject('bairen','bairenPrizePoolRecordView').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerBaiRenPrizePoolRecord')
    end)
end

function ControllerBaiRenPrizePoolRecord:Show(arg)
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible=true
    self.m_listData=arg
    self.m_list=self.m_view:GetChild('list').asList
    self.m_list:SetVirtual()
    self.m_list.itemRenderer = function (theIndex,theGObj)
        local _com=theGObj.asCom
        local _t=self.m_listData[theIndex+1]
        _com.data=_t
        _com:GetChild('head'):GetChild('icon').asLoader.url=HandleWXIcon(_t.icon_url)
        _com:GetChild('txtNickName').text=_t.nick_name
        _com:GetChild("txtMoney").text=_t.coin
        _com:GetChild("txtTime").text=os.date("%Y-%m-%d %H:%M %S", _t.create_time)
        for i=1,5 do
            UIManager.SetPoker(_com:GetChild("c"..i),tonumber(_t.poker_info[i]))
        end
    end
    self.m_list.numItems = #arg
end

function ControllerBaiRenPrizePoolRecord:OnHide()
    self.m_view.visible=false
end
return ControllerBaiRenPrizePoolRecord