--猜一猜的逻辑
local H_TexasGuess=class("H_TexasGuess")
function H_TexasGuess:Init(arg)
    local m_view = arg.view
    self.m_controllerGuess = arg.controllerGuess

    self.m_controllerSltType = m_view:GetController("c1")
    self.m_controllerRecord = m_view:GetController("c2")
    self.m_controllerSltCount = m_view:GetController("c3")

    --self.sltBetCount = 1    -- 1 ， 10， -1
    self.sltBetType = DZ_Guess_GC_A * 1

    self.m_bet_1 = m_view:GetChild("btnBet1")
    self.m_bet_2 = m_view:GetChild("btnBet2")
    self.m_bet_3 = m_view:GetChild("btnBet3")

    -- 默认关闭记录，默认选择最小的倍数
    self.m_hasOpenRecord = false
    self.m_controllerRecord.selectedIndex = 1
    self.m_controllerSltType.selectedIndex = 3

    m_view:GetChild("btnBg").onClick:Add(function ()
        self.m_controllerGuess.selectedIndex = 0
    end)

    m_view:GetChild("btnRecod1").onClick:Add(function ()
        self:RecordClick()
    end)

    m_view:GetChild("btnRecod2").onClick:Add(function ()
        self:RecordClick()
    end)

    -- 押注值选择
    self.m_bet_1.onClick:Add(function ()
        self:SendGuessBet(1)
    end)

    self.m_bet_2.onClick:Add(function ()
        self:SendGuessBet(5)
    end)

    self.m_bet_3.onClick:Add(function ()
        self:SendGuessBet(10)
    end)

    --1: AA 对A DZ_Guess_GC_AA
    m_view:GetChild("btn0").onClick:Add(function ()
        self.m_controllerSltType.selectedIndex = 0
        self.sltBetType = DZ_Guess_GC_AA * 1
    end)

    --2: A_K 含AK DZ_Guess_GC_A_K
    m_view:GetChild("btn1").onClick:Add(function ()
        self.sltBetType = DZ_Guess_GC_A_K * 1
        self.m_controllerSltType.selectedIndex = 1
    end)

    --3: 对子 DZ_Guess_GC_DUIZI
    m_view:GetChild("btn2").onClick:Add(function ()
        self.sltBetType = DZ_Guess_GC_DUIZI * 1
        self.m_controllerSltType.selectedIndex = 2
    end)

    -- 含A DZ_Guess_GC_A
    m_view:GetChild("btn3").onClick:Add(function ()
        self.sltBetType = DZ_Guess_GC_A * 1
        self.m_controllerSltType.selectedIndex = 3
    end)

    self.m_view = m_view

    self.m_controllerGuess.selectedIndex = 0

    --required int32 leftcount = 2;               //剩下多少局 0是停止下注,如果金币不够也返回0,自动停止
    -- 猜手牌结果
    H_NetMsg:addEventListener('DZPK_ReceiveGuessCard',function (arg1)
        local msg = Protol.Poker_pb.GuessCardResult()
        msg:ParseFromString(arg1.pb_data)
        --print('收到消息 猜手牌结果：'..tostring(msg))
        local win_score = tonumber(msg.winscore)
        local bet_type_name = self:GetBetNameByType(msg.sptype)
        if win_score < 0 then
            UIManager.AddPopTip({strTit=string.format("非常遗憾:投注[color=#FFB400]%s[/color],没有中，请再接再厉.", bet_type_name)})
        elseif win_score > 0 then
            UIManager.AddPopTip({strTit=string.format( "恭喜投注[color=#FFB400]%s[/color],你将获[color=#FFB400]%s[/color]金币奖励", bet_type_name, formatVal(win_score))})
        end

        UIManager.GetController('ControllerTexas'):UpdateSelfScoreTableScore(msg.selfscore, msg.tablemaxscore)
    end)

    --押注记录
    self.m_recordList = m_view:GetChild('list_record').asList
    self.m_recordList:SetVirtual()
    self.m_recordList.itemRenderer = function (theIndex, theGObj)
        local _com = theGObj.asCom
        local _t = self.m_recordListData[theIndex + 1]
        _com.data = _t
        _com:GetChild('time').text = string.sub(_t.created_date,6, #_t.created_date)
        _com:GetChild('slt').text = self:GetBetNameByType(_t.cardType)
        _com:GetChild('bet').text = formatVal(tonumber(_t.betScore))
        _com:GetChild('res').text = tonumber(_t.winScore) > 0 and "中" or "不中"

    end
    --接受服务器数据后设置
    self.m_recordListData = { }
    self.m_recordList.numItems = 0
end

function H_TexasGuess:RecordClick()
    if not self.m_hasOpenRecord then
        coroutine.start(GuessCard_Data_Get, {
            userid=loginSucceedInfo.user_info.userid,
            callbackSuccess=function (info)
                local res_length = #info.result
                if info.result and res_length > 0 then
                    self.m_recordListData = info.result
                    self.m_recordList.numItems = res_length
                end
            end
        })
    end

    self.m_controllerRecord.selectedIndex = self.m_hasOpenRecord and 1 or 0
    self.m_hasOpenRecord = not self.m_hasOpenRecord
end

function H_TexasGuess:SetControllerGuess(index)
    --if index==1 then
    --    self:Send(0)
    --else
    --    self.m_controllerGuess.selectedIndex=0
    --end
end

function H_TexasGuess:ShowGuessPanel()
    self.m_controllerGuess.selectedIndex = 1
    self.m_bet_1.text = roomCfg.bringmingold and formatVal(math.ceil(roomCfg.bringmingold * (1 / 100))) or 0
    self.m_bet_2.text = roomCfg.bringmingold and formatVal(math.ceil(roomCfg.bringmingold * (5 / 100))) or 0
    self.m_bet_3.text = roomCfg.bringmingold and formatVal(math.ceil(roomCfg.bringmingold * (10 / 100))) or 0
    --self.m_bet_1.text = "1%"
    --self.m_bet_2.text = "5%"
    --self.m_bet_3.text = "10%"
end

--required int32 sptype = 1;               //猜手牌类型
--required int32 betscore = 2;             //下注多少
--required int32 playcount = 3;            //局数 -1： 一直追
function H_TexasGuess:SendGuessBet(percent)
    if gameData.chair == -1 then
        UIManager.AddPopTip({ strTit = '没有坐下'})
        return
    end

    if loginSucceedInfo.user_info.gold < math.ceil(roomCfg.bringmingold * (percent / 100)) then
        UIManager.AddPopTip({ strTit = '金币不足'})
        return
    end

    local bet_count = 1
    local slt_count_index = self.m_controllerSltCount.selectedIndex
    if slt_count_index == 0 then
        bet_count = 1
    elseif slt_count_index == 1 then
        bet_count = 10
    elseif slt_count_index == 2 then
        bet_count = -1
    end

    local msg = Protol.Poker_pb.UserGuessCardResponse()
    msg.sptype = self.sltBetType
    msg.betscore = math.ceil(roomCfg.bringmingold * (percent / 100))
    msg.playcount = bet_count
    local pb_data = msg:SerializeToString()
    self.m_controllerGuess.selectedIndex = 0
    UIManager.AddPopTip({strTit=string.format( "成功投注[color=#FFB400]%s:%s金币[/color]", self:GetBetNameByType(), msg.betscore), dt = 2})

    NetManager.SendNetMsg(GameServerConfig.logic,'DZPK_RequestGuessCard', pb_data)
end

function H_TexasGuess:GetBetNameByType(bet_type)
    --对A AK 对子 含A DZ_Guess_GC_AA DZ_Guess_GC_A_K DZ_Guess_GC_DUIZI DZ_Guess_GC_A
    local self_bet_type = bet_type and bet_type or self.sltBetType
    if self_bet_type == DZ_Guess_GC_AA then
        return "对A"
    elseif self_bet_type == DZ_Guess_GC_A_K then
        return "AK"
    elseif self_bet_type == DZ_Guess_GC_DUIZI then
        return "对子"
    elseif self_bet_type == DZ_Guess_GC_A then
        return "含A"
    end
end

return H_TexasGuess