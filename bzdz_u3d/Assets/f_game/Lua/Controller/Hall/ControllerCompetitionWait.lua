-- 比赛场的游戏界面
local ControllerCompetitionWait = class("ControllerCompetitionWait")

function ControllerCompetitionWait:Init()
    self.m_view = UIPackage.CreateObject('competition', 'hotGameWaitView').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    self.m_btn_exit = self.m_view:GetChild("btn_exit")

    self.m_time_tips = self.m_view:GetChild("time_tips")
    self.m_time_minutes = self.m_view:GetChild("time_minutes")
    self.m_time_seconds = self.m_view:GetChild("time_seconds")

    self.m_btn_exit.onClick:Add(function ()
        self:OnHide()
    end)
end

function ControllerCompetitionWait:Show(arg)
    --保持在前面
    if arg.is_play then
        self:OnHide()
        return
    end
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true

    self.game_info = arg.info

    self:UpdateCd()
    self:OpenCd()
end

----------------------------------- 倒计时 ---------------------------------------
function ControllerCompetitionWait:OpenCd()
    self:CloseCd()
    self.m_cd = Timer.New(function ()
        self:UpdateCd()
    end, 1, -1)

    self.m_cd:Start()
end

function ControllerCompetitionWait:UpdateCd()
    local split_list = string.split(GetTimeText(self.game_info.starttime), ":")
    self.m_time_minutes.text = split_list[1]
    self.m_time_seconds.text = split_list[2]
    self.game_info.starttime = self.game_info.starttime - 1
    if self.game_info.starttime < 0 then
        self.game_info.starttime = 0

        -- 倒计时清空
        self:CloseCd()
        self:OnHide()
    end
end

function ControllerCompetitionWait:CloseCd()
    if self.m_cd then
        self.m_cd:Stop()
    end
end

-- 等待开始
-- is_play = false
-- info = msg
--required int32 starttime = 1; //离比赛开始多少秒，比赛中为0
--required int32 usercount = 2; //进场玩家
----------------------------------- 比赛开始的倒计时显示 ---------------------------------------
function ControllerCompetitionWait:ShowGameStarCd()
    self.m_time_tips.visible = true
end

function ControllerCompetitionWait:HideGameStarCd()
    self.m_time_tips.visible = false
    self.m_time_minutes.text = ""
    self.m_time_seconds.text = ""
end

function ControllerCompetitionWait:OnHide()
    self:CloseCd()
    self.m_view.visible = false
end


return ControllerCompetitionWait

