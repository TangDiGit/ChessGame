-- 比赛场的提示
local ControllerCompetitionResRank = class("ControllerCompetitionResRank")
function ControllerCompetitionResRank:Init()
    self.m_view = UIPackage.CreateObject('competition', 'hotGameResDetailView').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerCompetitionResRank')
    end)

    self:InitResCompetitionList()
end

function ControllerCompetitionResRank:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true

    self.m_resCompetitionData = arg
    self.m_resCompetitionList.numItems = #arg
end

function ControllerCompetitionResRank:InitResCompetitionList()
    self.m_resCompetitionList = self.m_view:GetChild('resGameList').asList
    self.m_resCompetitionList:SetVirtual()
    self.m_resCompetitionList.itemRenderer = function (theIndex,theGObj)
        local _com = theGObj.asCom
        local _data = self.m_resCompetitionData[theIndex + 1]
        _com:GetChild('ply_head'):GetChild('icon').asLoader.url = HandleWXIcon(_data.headurl)
        _com:GetChild('ply_name').text = _data.nickname
        _com:GetChild('open_time').text = _data.createtime

        local use_slt_index = _data.paiMing <= 3
        local rank_slt_index = 0
        if use_slt_index then
            rank_slt_index = _data.paiMing - 1
        else
            rank_slt_index = 3
            _com:GetChild('ranking4').text = _data.paiMing
        end
        _com:GetController('rank').selectedIndex = rank_slt_index
        _com:GetChild("btn_detailed").visible = false

        -- 比赛名字
        _com:GetController('game_name').selectedIndex = Match_Type[tonumber(_data.matchType)].name_index
        -- 比赛奖励的实物
        if _data.goodID then
            _com:GetChild('reward_count').text = string.format("%s%s%s",
                    Match_Good[tonumber(_data.goodID)],
                    Chinese_Num[tonumber(_data.goodCount)],
                    Match_Good_Unit[tonumber(_data.goodID)])
        else
            _com:GetChild('reward_count').text = string.format("%s金币", formatVal(_data.winScore))
        end
    end

    self.m_resCompetitionList.numItems = 0
    self.m_resCompetitionData = nil
end

function ControllerCompetitionResRank:OnHide()
    self.m_view.visible = false
end

return ControllerCompetitionResRank

