-- 比赛场的提示
local ControllerCompetitionDetail = class("ControllerCompetitionDetail")
-- ControllerCompetitionDetail
function ControllerCompetitionDetail:Init()
    self.m_view = UIPackage.CreateObject('competition', 'hotGameDetailView').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    self.m_comDetail = self.m_view:GetChild('comDetail')

    self.m_view:GetChild("btnBg").onClick:Add(function ()
        self:OnHide()
    end)

    self.mangzhu_time = 0
    self.mangzhu_text = self.m_comDetail:GetChild('cd_time')

    self:InitRankList()
    self:InitRewardList()
    self:InitMangZhuList()

    -- 打开弹出当前比赛的详细信息
    H_NetMsg:addEventListener('Match_ReceiveCurtInfo',function (arg)
        local msg = Protol.DzMatchPb_pb.MatchCurInfo()
        msg:ParseFromString(arg.pb_data)
        self:ShowDetailInfo(msg)
    end)
end

function ControllerCompetitionDetail:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true

    self:ShowRewardListInfo()
    self:ShowMangZhuListInfo()

    self:RequestRankInfo()
    self:RequestDetailInfo()
end

---------------------------------------------------------------------------------
----------------------------------- 详细信息 --------------------------------------

function ControllerCompetitionDetail:RequestDetailInfo()
    NetManager.SendNetMsg(GameServerConfig.logic,'Match_ReqDetail')
end

--required int32 playusercount = 1; //玩家数量
--required int32 cansaiusercount = 2; //参赛数量
--required int32 awardcount = 3; //奖励玩家人数
--required int32 matchplaytime = 4; //比赛耗时 秒
--required int64 preusermatchscore = 5; //平均筹码
--required int64 totalusermatchscore = 6; //总筹码
--required int64 cellscore = 7; //当前盲注
--required int64 nextcellscore = 8; //下级盲注
--required int64 curcellscoreindex = 9; //当前盲注级别
--required int32 updatecellscoreleavetime = 10; //下次升盲时间(秒)
function ControllerCompetitionDetail:ShowDetailInfo(data)
    -- 剩余玩家 当前耗时 参赛人数 平均筹码 奖励人数 筹码总数 盲注 前注 下一级别
    self.m_comDetail:GetChild('remain_ply').text = data.playusercount or 0
    self.m_comDetail:GetChild('cost_time').text = data.matchplaytime and GetTimeText(data.matchplaytime) or "00:00"
    self.m_comDetail:GetChild('join_ply').text = data.cansaiusercount or 0
    self.m_comDetail:GetChild('ava_chip').text = data.preusermatchscore or 0
    self.m_comDetail:GetChild('reward_ply').text = data.awardcount or 0
    self.m_comDetail:GetChild('total_chip').text = data.totalusermatchscore or 0
    self.m_comDetail:GetChild('mangzhu_count').text = string.format("%s/%s", formatVal(data.cellscore), formatVal(data.nextcellscore))
    self.m_comDetail:GetChild('qianzhu_count').text = roomCfg.frontbet

    local is_total = false
    local next_mangzhu = roomCfg.mangzhu_list[data.curcellscoreindex + 1]

    next_mangzhu = next_mangzhu and next_mangzhu.mangzhu or roomCfg.mangzhu_list[data.curcellscoreindex].mangzhu

    self.m_comDetail:GetChild('next_level_1').text = string.format("%s/%s", formatVal(next_mangzhu), formatVal(next_mangzhu * 2))
    self.m_comDetail:GetChild('next_level_2').text = is_total and "已滿" or data.curcellscoreindex + 1

    self.mangzhu_time = data.updatecellscoreleavetime

    -- 升盲倒计时
    self:UpdateMangZhuCd()
    self:OpenMangZhuCd()
end

----------------------------------- 倒计时 ---------------------------------------
function ControllerCompetitionDetail:OpenMangZhuCd()
    self:CloseMangZhuCd()
    self.m_cd = Timer.New(function ()
        self:UpdateMangZhuCd()
    end, 1, -1)

    self.m_cd:Start()
end

function ControllerCompetitionDetail:UpdateMangZhuCd()
    self.mangzhu_text.text = string.format("00 %s", GetTimeTextNoSymbol(self.mangzhu_time))
    self.mangzhu_time = self.mangzhu_time - 1
    if self.mangzhu_time < 0 then
        self.mangzhu_time = 0
        self:CloseMangZhuCd() -- 倒计时清空
    end
end

function ControllerCompetitionDetail:CloseMangZhuCd()
    if self.m_cd then
        self.m_cd:Stop()
    end
    self.mangzhu_text.text = "00:00:00"
end


---------------------------------------------------------------------------------
----------------------------------- 盲注列表 --------------------------------------
function ControllerCompetitionDetail:ShowMangZhuListInfo()
    self.m_mangZhuData = roomCfg.mangzhu_list
    self.m_mangZhuList.numItems = #roomCfg.mangzhu_list
end

function ControllerCompetitionDetail:InitMangZhuList()
    self.m_mangZhuList = self.m_view:GetChild('comMangZhu').asList
    self.m_mangZhuList:SetVirtual()
    self.m_mangZhuList.itemRenderer = function (theIndex, theGObj)
        self:SetMangZhuItemView(theGObj.asCom, self.m_mangZhuData[theIndex + 1], roomCfg.qianzhu_list[theIndex + 1])
    end
    self.m_mangZhuList.numItems = 0
    self.m_mangZhuData = nil
end

function ControllerCompetitionDetail:SetMangZhuItemView(_com, _data, _dataQian)
    _com:GetChild("level").text = _data.level
    _com:GetChild("mangzhu").text = string.format("%s/%s", formatVal(_data.mangzhu), formatVal(_data.mangzhu * 2))
    _com:GetChild("qianzhu").text = formatVal(_dataQian.qianzhu)
    _com:GetChild("shijian").text = GetTimeText(roomCfg.cellScoreUpTime) --string.format("%s分钟", roomCfg.cellScoreUpTime / 60)

    local type_ctrl = _com:GetController('type')
    if _data.level <= roomCfg.rebuyMaxLevel then
        type_ctrl.selectedIndex = 0
    elseif _data.level == roomCfg.addonLevel then
        type_ctrl.selectedIndex = 1
    else
        type_ctrl.selectedIndex = 2
    end
end

---------------------------------------------------------------------------------
----------------------------------- 排行榜 --------------------------------------
-- "nickname":"沁晚离殇","headurl":"http:\/\/192.168.1.7\/static\/f_game\/headImg\/boy\/1101.jpg","score":"20000","paiMing":"0"
function ControllerCompetitionDetail:RequestRankInfo()
    UIManager.Show('ControllerWaitTip')
    coroutine.start(GameCompetitionRank, {
        matchID = roomCfg.matchID,
        callbackSuccess = function(info)
            UIManager.Hide('ControllerWaitTip')
            self:ShowRankListInfo(info)
        end
    })
end

-- comRank
function ControllerCompetitionDetail:ShowRankListInfo(info)
    if info then
        local res_list = info.resList
        --table.sort(res_list, function (a, b)
        --    return a.score > b.score
        --end)
        self.m_rankData = res_list
        self.m_rankList.numItems = #res_list
    end
end

function ControllerCompetitionDetail:InitRankList()
    self.m_rankList = self.m_view:GetChild('comRank').asList
    self.m_rankList:SetVirtual()
    self.m_rankList.itemRenderer = function (theIndex, theGObj)
        self:SetRankItemView(theGObj.asCom, self.m_rankData[theIndex + 1])
    end
    self.m_rankList.numItems = 0
    self.m_rankData = nil
end

function ControllerCompetitionDetail:SetRankItemView(_com, _data)
    _com:GetChild('ply_head'):GetChild('icon').asLoader.url = HandleWXIcon(_data.headurl)
    _com:GetChild("name").text = _data.nickname
    _com:GetChild("reward").text = string.format("%s", formatVal(_data.score))
end

---------------------------------------------------------------------------------
----------------------------------- 奖励列表 --------------------------------------
-- comReward
function ControllerCompetitionDetail:ShowRewardListInfo()
    local info = lua_string_split(roomCfg.award,';')
    self.m_rewardData = info
    self.m_rewardList.numItems = #info
end

function ControllerCompetitionDetail:InitRewardList()
    self.m_rewardList = self.m_view:GetChild('comReward').asList
    self.m_rewardList:SetVirtual()
    self.m_rewardList.itemRenderer = function (theIndex, theGObj)
        self:SetRewardItemView(theGObj.asCom, self.m_rewardData[theIndex + 1])
    end
    self.m_rewardList.numItems = 0
    self.m_rewardDatam_rewardData = nil
end

function ControllerCompetitionDetail:SetRewardItemView(com, data)
    local _data = lua_string_split(data,',')
    local range = lua_string_split(_data[1], '-')
    if range[1] and tonumber(range[1]) > 3 then
        com:GetController('rank').selectedIndex = 3
        com:GetChild('rank').text = string.format("%s名", _data[1])
        if _data[3] and tonumber(_data[3]) > 0 then
            com:GetChild('reward').text = string.format("%s%s%s",
                    Match_Good[tonumber(_data[3])],
                    Chinese_Num[tonumber(_data[4])],
                    Match_Good_Unit[tonumber(_data[3])])
        else
            com:GetChild('reward').text = string.format("%s金币", formatVal(_data[2]))
        end
        --_com:GetChild('reward').text = string.format("%s金币", formatVal(_data[2]))
    else
        local rank = tonumber(_data[1])
        local use_slt_index = rank <= 3
        local rank_slt_index = 0
        if use_slt_index then
            rank_slt_index = rank - 1
            com:GetChild('rank').text = ""
        else
            rank_slt_index = 3
            com:GetChild('rank').text = rank
        end

        if _data[3] and tonumber(_data[3]) > 0 then
            com:GetChild('reward').text = string.format("%s%s%s",
                    Match_Good[tonumber(_data[3])],
                    Chinese_Num[tonumber(_data[4])],
                    Match_Good_Unit[tonumber(_data[3])])
        else
            com:GetChild('reward').text = string.format("%s金币", formatVal(_data[2]))
        end
        com:GetController('rank').selectedIndex = rank_slt_index
        --_com:GetChild('reward').text = string.format("%s金币", formatVal(_data[2]))
    end
end

function ControllerCompetitionDetail:OnHide()
    self.m_view.visible = false
end

return ControllerCompetitionDetail

