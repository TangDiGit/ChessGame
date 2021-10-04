--百人场等待上庄界面
local ControllerBaiRenWaitBecomeBookmaker = class("ControllerBaiRenWaitBecomeBookmaker")

function ControllerBaiRenWaitBecomeBookmaker:Init()
	self.m_view = UIPackage.CreateObject('bairen','baiRenGameWaitView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false
    self.is_open = false
    self.m_view:GetChild("btnCancel"):GetChild("title").text = "申请上庄"
    -- 申请上庄
    self.m_view:GetChild("btnCancel").onClick:Add(function ()
        CtrlBaiRenNet.Req_ApplyBanker()  -- 上庄
    end)
    -- 继续等待
    self.m_view:GetChild("btnY").visible = false
    --self.m_view:GetChild("btnY").onClick:Add(function ()
    --    UIManager.Hide('ControllerBaiRenWaitBecomeBookmaker')
    --end)
    -- 关闭
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerBaiRenWaitBecomeBookmaker')
    end)
end

--required int32 userid = 1;		//
--required string nickname = 2;		//
--required string headurl = 3;		//
--required int64 score = 4;		    //
function ControllerBaiRenWaitBecomeBookmaker:Show(arg)
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible = true
    self.is_open = true
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
        _com:GetChild('txtGold').text = formatVal(_t.score)
    end
    self.m_list.numItems = #arg
    --自己的排名
    self.m_view:GetChild('txtRanking').text = string.format("上庄条件 : [color=#FFB400]%s[/color]", CtrlBaiRenNet.GetApplyBankerScore())
    self.m_view:GetChild("head"):GetChild("icon").asLoader.url = GetPlySelfHeadUrl()
    self.m_view:GetChild("txtNickName").text = loginSucceedInfo.user_info.nickname
    self.m_view:GetChild("txtID").text = string.format("ID:%s", loginSucceedInfo.user_info.userid)
    self.m_view:GetChild("txtGold").text = formatVal(tonumber(loginSucceedInfo.user_info.gold))
end

function ControllerBaiRenWaitBecomeBookmaker:OnHide()
	self.m_view.visible = false
    self.is_open = false
end

function ControllerBaiRenWaitBecomeBookmaker:GetIsOpen()
    return self.is_open
end

return ControllerBaiRenWaitBecomeBookmaker