-- 比赛场的提示
local ControllerCompetitionPreview = class("ControllerCompetitionPreview")
-- ControllerCompetitionPreview
function ControllerCompetitionPreview:Init()
    self.m_view = UIPackage.CreateObject('competition', 'hotGamePreviewView').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false
    self.matchData = nil  -- 比赛的数据
    self.font_list = { }  -- 前注的数据

    self:InitMatchDesc()
    self:InitRankList()
    self:InitRewardList()
    self:InitMangZhuList()

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerCompetitionPreview')
    end)
end

function ControllerCompetitionPreview:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true

    self.matchData = arg

    -- 前注的计算
    self.font_list = { }
    -- 盲注级别的计算
    local str_info_mang = lua_string_split(arg.cellUpList,',')
    local str_info_qian = string.len(arg.fontList) > 0 and lua_string_split(arg.fontList,',') or { }
    local info_mang = { }
    local length_qian = #str_info_qian
    local total_qian = length_qian > 0 and tonumber(str_info_qian[length_qian]) or 0
    local curt_qian
    for k, v in ipairs(str_info_mang) do
        curt_qian = total_qian > 0 and (k > length_qian and total_qian or tonumber(str_info_qian[k])) or 0
        table.insert(self.font_list, { level = k, qianzhu = curt_qian * 1 })
        table.insert(info_mang, { level = k, mangzhu = tonumber(v) })
    end
    -- 盲注按级别排序
    --table.sort(info, function (a, b)
    --    return a.level < b.level
    --end)
    self.matchData.mangzhu_list = info_mang
    self:ShowRewardListInfo()
    self:ShowMangZhuListInfo()
    self:RequestRankInfo()
    self:ShowMatchDesc()
end

---------------------------------------------------------------------------------
----------------------------------- 详细介绍 --------------------------------------

function ControllerCompetitionPreview:InitMatchDesc()
    -- 标题
    self.m_gameNameCtrl = self.m_view:GetChild('comDesc'):GetController('game_name')
    self.m_comDescList = self.m_view:GetChild('comDesc'):GetChild('comList').asList
    -- 详细描述
    self.m_comDescList:SetVirtual()
    self.m_comDescList.itemRenderer = function (theIndex, theGObj)
        self:SetDescItemView(theGObj.asCom, self.m_comDescListData[theIndex + 1])
    end
    self.m_comDescList.numItems = 0
    self.m_comDescListData = nil
end

function ControllerCompetitionPreview:ShowMatchDesc()
    -- 比赛名字
    self.m_gameNameCtrl.selectedIndex = Match_Type[tonumber(self.matchData.matchType)].name_index

    --local is_free = tonumber(self.matchData.canSaiFei) + tonumber(self.matchData.fuWuFei) == 0
    --local cost_str = is_free and "免费" or string.format("%s+%s", formatVal(self.matchData.canSaiFei), formatVal(self.matchData.fuWuFei))
    --local split_start_time = string.split(self.matchData.startTime, " ")
    --local split_month_time = string.split(split_start_time[1], "-")
    --local month_str = string.format("%s月%s日", split_month_time[2], split_month_time[3])
    --local seconds_str = split_start_time[2]

    local open_data = string.split(self.matchData.startTimeTitle, ",")
    local res =
    {
        { content = string.format("报名费用：[color=#E6BC57]%s[/color]", self.matchData.costDesc) },
        { content = string.format("比赛时间：%s - %s", open_data[1], open_data[2]) },
        { content = string.format("参赛人数：%s - %s", self.matchData.minStartUserCount, self.matchData.maxStartUserCount) },
        { content = string.format("初始筹码：[color=#E6BC57]%s[/color]", formatVal(self.matchData.startMatchScore)) },
        { content = string.format("[color=#E6BC57]R[/color]可重购比赛[color=#E6BC57]%s[/color]次：1-%s盲注级可以[color=#E6BC57]%s金币购买%s筹码[/color]",
                self.matchData.rebuyCount, self.matchData.rebuyMaxLevel, formatVal(self.matchData.rebuyExpendScore), formatVal(self.matchData.rebuyBuyMatchScore)) },
        { content = string.format("[color=#E6BC57]A[/color]可增购比赛[color=#E6BC57]%s[/color]次：第%s盲注级可以[color=#E6BC57]%s金币购买%s筹码[/color]",
                self.matchData.addonCount, self.matchData.addonLevel, formatVal(self.matchData.addonExpendScore), formatVal(self.matchData.addonBuyMatchScore)) },
    }
    self.m_comDescListData = res
    self.m_comDescList.numItems = #res
end

function ControllerCompetitionPreview:SetDescItemView(_com, _data)
    _com:GetChild("content").text = _data.content
end

---------------------------------------------------------------------------------
----------------------------------- 盲注列表 --------------------------------------
function ControllerCompetitionPreview:ShowMangZhuListInfo()
    self.m_mangZhuData = self.matchData.mangzhu_list
    self.m_mangZhuList.numItems = #self.matchData.mangzhu_list
end

function ControllerCompetitionPreview:InitMangZhuList()
    self.m_mangZhuList = self.m_view:GetChild('comMangZhu').asList
    self.m_mangZhuList:SetVirtual()
    self.m_mangZhuList.itemRenderer = function (theIndex, theGObj)
        self:SetMangZhuItemView(theGObj.asCom, self.m_mangZhuData[theIndex + 1], self.font_list[theIndex + 1])
    end
    self.m_mangZhuList.numItems = 0
    self.m_mangZhuData = nil
end

function ControllerCompetitionPreview:SetMangZhuItemView(_com, _data, _dataQian)
    _com:GetChild("level").text = _data.level
    _com:GetChild("mangzhu").text = string.format("%s/%s", formatVal(_data.mangzhu), formatVal(_data.mangzhu * 2))
    _com:GetChild("qianzhu").text = formatVal(_dataQian.qianzhu)
    _com:GetChild("shijian").text = GetTimeText(self.matchData.cellScoreUpTime)
    --string.format("%s分钟", self.matchData.cellScoreUpTime / 60)

    local type_ctrl = _com:GetController('type')
    if _data.level <= self.matchData.rebuyMaxLevel then
        type_ctrl.selectedIndex = 0
    elseif _data.level == self.matchData.addonLevel then
        type_ctrl.selectedIndex = 1
    else
        type_ctrl.selectedIndex = 2
    end
end

---------------------------------------------------------------------------------
----------------------------------- 排行榜 ---------------------------------------
function ControllerCompetitionPreview:RequestRankInfo()
    UIManager.Show('ControllerWaitTip')
    coroutine.start(GameCompetitionRank, {
        matchID = self.matchData.matchID,
        callbackSuccess = function(info)
            UIManager.Hide('ControllerWaitTip')
            self:ShowRankListInfo(info)
        end
    })
end

-- comRank
function ControllerCompetitionPreview:ShowRankListInfo(info)
    if info and info.resList then
        local res_list = info.resList
        self.m_rankData = res_list
        self.m_rankList.numItems = #res_list
    end
end

function ControllerCompetitionPreview:InitRankList()
    self.m_rankList = self.m_view:GetChild('comRank').asList
    self.m_rankList:SetVirtual()
    self.m_rankList.itemRenderer = function (theIndex, theGObj)
        self:SetRankItemView(theGObj.asCom, self.m_rankData[theIndex + 1])
    end
    self.m_rankList.numItems = 0
    self.m_rankData = nil
end

function ControllerCompetitionPreview:SetRankItemView(_com, _data)
    _com:GetChild('ply_head'):GetChild('icon').asLoader.url = HandleWXIcon(_data.headurl)
    _com:GetChild("name").text = _data.nickname
    _com:GetChild("reward").text = string.format("%s", formatVal(_data.score))
end

---------------------------------------------------------------------------------
----------------------------------- 奖励列表 --------------------------------------
-- comReward
function ControllerCompetitionPreview:ShowRewardListInfo()
    local info = lua_string_split(self.matchData.award,';')
    self.m_rewardData = info
    self.m_rewardList.numItems = #info
end

function ControllerCompetitionPreview:InitRewardList()
    self.m_rewardList = self.m_view:GetChild('comReward').asList
    self.m_rewardList:SetVirtual()
    self.m_rewardList.itemRenderer = function (theIndex, theGObj)
        self:SetRewardItemView(theGObj.asCom, self.m_rewardData[theIndex + 1])
    end
    self.m_rewardList.numItems = 0
    self.m_rewardDatam_rewardData = nil
end

function ControllerCompetitionPreview:SetRewardItemView(com, data)
    -- 奖励要修改 xx手机等等
    local _data = lua_string_split(data,',')
    -- 这个是范围判断
    local range = lua_string_split(_data[1], '-')
    if range[1] and tonumber(range[1]) > 3 then
        if _data[3] and tonumber(_data[3]) > 0 then
            com:GetChild('reward').text = string.format("%s%s%s",
                    Match_Good[tonumber(_data[3])],
                    Chinese_Num[tonumber(_data[4])],
                    Match_Good_Unit[tonumber(_data[3])])
        else
            com:GetChild('reward').text = string.format("%s金币", formatVal(_data[2]))
        end
        com:GetController('rank').selectedIndex = 3
        com:GetChild('rank').text = string.format("%s名", _data[1])
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
    end

end

function ControllerCompetitionPreview:OnHide()
    self.m_view.visible = false
end

return ControllerCompetitionPreview

