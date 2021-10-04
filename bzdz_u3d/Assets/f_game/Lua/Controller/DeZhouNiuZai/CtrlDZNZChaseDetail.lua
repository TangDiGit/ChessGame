local CtrlDZNZChaseDetail = class("CtrlDZNZChaseDetail")

function CtrlDZNZChaseDetail:Init()
    self.m_view = UIPackage.CreateObject('niuzai', 'niuZaiChaseDetailView').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false
    self.m_content = self.m_view:GetChild('content')
    self:InitResList()

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('CtrlDZNZChaseDetail')
    end)

    H_NetMsg:addEventListener('DZNZ_ReceiveZhuiHistory',function (arg)
        local msg = Protol.DZNZ_GamePb_pb.GetZhuiHaoHistory()
        msg:ParseFromString(arg.pb_data)
        self:ResponseResList(msg.oneroundinfo)
    end)
end

function CtrlDZNZChaseDetail:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true

    self.chase_type = arg.chase_type                    -- 选择的类型
    self.chase_money = arg.chase_money                  -- 选择的金额
    self.chase_count = arg.chase_count                  -- 选择的数量

    local status_str = arg.chase_playing and "进行中" or "已结束"
    self.m_content.text = string.format("%s/%s/%s局(%s)",
            ChaseName[self.chase_type], formatVal(self.chase_money), self.chase_count, status_str)

    self:RequestDetail(arg.chase_time)
end

function CtrlDZNZChaseDetail:RequestDetail(chase_time)
    self.m_resList.numItems = 0
    self.m_resData = nil
    local msg = Protol.DZNZ_GamePb_pb.C_GetZhuiHaoHistory()
    msg.id = chase_time
    NetManager.SendNetMsg(GameServerConfig.logic,'DZNZ_RequestZhuiHaoHistory', msg:SerializeToString())
end

--required int64 endtime = 1;		//结算时间（秒）
--required int64 winscore = 2;		//自己输赢多少分
--repeated int32 cards = 3;			//牌数据 1 :左边牌(2张), 2：右边牌(2张)， 3：中间牌(5张)
---------------------------------------------------------------------------------
----------------------------------- 详细 -----------------------------------------
function CtrlDZNZChaseDetail:InitResList()
    self.m_resList = self.m_view:GetChild('list').asList
    self.m_resList:SetVirtual()
    self.m_resList.itemRenderer = function (theIndex,theGObj)
        local _com = theGObj.asCom
        local _data = self.m_resData[theIndex + 1]
        local winScore = tonumber(_data.winscore)
        _com:GetChild('round').text = string.format("第%s局", theIndex + 1)
        _com:GetChild('time').text = os.date("%Y-%m-%d\n%H:%M:%S", _data.endtime)
        _com:GetChild('reward').text = winScore > 0 and formatVal(winScore) or "未中奖"

        -- 牌数据 1 :左边牌(2张), 2：右边牌(2张)， 3：中间牌(5张)
        local res_list = { "left1","left2","right1","right2","middle1","middle2","middle3","middle4","middle5"}
        for k, v in ipairs(_data.cards) do
            _com:GetChild(res_list[k]):GetChild("n0").asLoader.url = PokerUrlMap[v]
        end
    end

    self.m_resList.numItems = 0
    self.m_resData = nil
end

function CtrlDZNZChaseDetail:ResponseResList(result)
    self.m_resData = result
    self.m_resList.numItems = #result
end

function CtrlDZNZChaseDetail:OnHide()
    self.m_view.visible = false
end

return CtrlDZNZChaseDetail

