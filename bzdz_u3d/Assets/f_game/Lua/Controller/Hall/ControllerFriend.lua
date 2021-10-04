--好友界面
local ControllerFriend = class("ControllerFriend")

function ControllerFriend:Init()
	self.m_view=UIPackage.CreateObject('hall','friendView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerFriend')
	end)

    --好友验证
    self.m_view:GetChild("btnFriendVerify").onClick:Add(function ()
        UIManager.Show('ControllerFriendVerify')
    end)
    --添加好友
    self.m_view:GetChild("btnFriendAdd").onClick:Add(function ()
        UIManager.Show('ControllerFriendAdd')
    end)
    
    self.m_list=self.m_view:GetChild("list")
    self.m_list:SetVirtual()
    self.m_list.itemRenderer = function (theIndex,theGObj)
        local _com=theGObj.asCom
        local _t=self.m_listData[theIndex+1]
        _com:GetChild('head'):GetChild('icon').asLoader.url=HandleWXIcon(_t.headurl)
        _com:GetChild('txtNickName').text=_t.nickname
        _com:GetChild("txtMoney").text=_t.userid
        _com.data=theIndex

        -- 赠送礼物
        local _btnPresented=_com:GetChild("btnPresented").asButton
        _btnPresented:RemoveEventListeners()
        _btnPresented.onClick:Add(function ()
            UIManager.Show('ControllerFriendPresented', _t)
        end)

        -- 追踪
        local has_room_go = _t["inServerID"] ~= 0
        -- 追踪按钮
        local btnGoRoom =_com:GetChild("btnGoRoom").asButton
        btnGoRoom.visible = has_room_go
        -- 房间名字
        local com_txt = _com:GetChild("room_name")
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
                -- 打开房间
                UIManager.Show('ControllerWaitTip')
                F_ResourceManager.instance:AddPackage("gamehall",function ()
                    UIManager.Hide('ControllerWaitTip')
                    local arg_info =
                    {
                        isSkipRefresh = true,
                        isLinkToOpenRoom = true,
                        inServerID = _t.inServerID,
                        tableID = _t.tableID,
                    }
                    UIManager.Hide('ControllerFriend')
                    UIManager.Show('ControllerGameHall', arg_info)
                end)
            end)
        else
            com_txt.text = ""
        end
    end

    --self.m_list.onClickItem:Add(function (context)
    --    local _t=self.m_listData[context.data.data+1]
	--    UIManager.Show('ControllerFriendPresented',_t)
    --end)

    --接受服务器数据后设置
    self.m_list.numItems = 0
    self.m_listData=nil

    --追求者提示
    self.m_tipFriend=self.m_view:GetChild('tFriendVerify')
    H_EventDispatcher:addEventListener('refreshTipFriend',function (arg)
        self.m_tipFriend.visible=arg.isMark
    end)

end

function ControllerFriend:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
    self.m_view.visible=true
    
    self.m_tipFriend.visible=false
    RefreshTipFriend()

    --接受服务器数据后设置
    self.m_list.numItems = 0
    self.m_listData=nil
    coroutine.start(Friend_List,{
		userid=loginSucceedInfo.user_info.userid,
        callbackSuccess=function (info)
            if info.array then
                if utf8.len(info.array)>0 then
                    local _arry=json.decode(info.array)

                    table.sort(_arry, function (a,b)
                        return a.inServerID > b.inServerID
                    end)

                    self.m_listData=_arry
                    self.m_list.numItems = #_arry

                end
            end
		end
	});
end

function ControllerFriend:OnHide()
	self.m_view.visible=false
end
return ControllerFriend