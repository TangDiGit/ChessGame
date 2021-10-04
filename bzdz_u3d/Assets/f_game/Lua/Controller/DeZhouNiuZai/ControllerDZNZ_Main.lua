--德州牛仔
local ControllerDZNZ_Main = class("ControllerDZNZ_Main")
local this = ControllerDZNZ_Main
--德州牛仔网络消息处理
require("Controller/DeZhouNiuZai/CtrlDZNZ_Net")
require('Controller/DeZhouNiuZai/NiuNiuCard')
require('Controller/DeZhouNiuZai/CtrlDZNZ_Data')

--德州牛仔界面组件
local ui_define = require('Controller/DeZhouNiuZai/CtrlDZNZ_UIDefine')

local m_content = nil

local readyTime = nil
local makeWarTime = nil
local betsTime = nil
local scoreTime = nil 

local tab_DZNZEffectS = {}

local maxBets = 0 --每局个人最大下注数额
local myBets = 0 --每局自己下注数额

local userLimitScore = nil --每个玩家最多下多少金币(防止溢出)
local clientusersitcondition = nil --坐在显示头像的分数限制

local m_propLayer
local m_imagePos

local m_nz_continue_list = { }
local totalBet = 0

--spine 动画
local tab_spineAnim = 
{
    gamestart = nil,
    leftrole = nil,
    rightrole = nil,
--------------------------------
    redwin = nil,
    draw = nil,
    bluewin = nil,
    tonghua_win = nil,
    lianpai_win = nil,
    duizi_win = nil,
    tonghualianpai_win = nil,
    duiA_win = nil,
    gaopai_win = nil,
    liangdui_win = nil,
    santiao_win = nil,
    hulu_win = nil,
    jingang_win = nil,
    --------------------------
    red_star = nil,
    blue_start = nil,
    draw_star = nil,
}

-- 下注区域
tab_betArea = 
{
    --红 区域
    red_win = 0,
    --蓝 区域
    blue_win = 1,
    --平 区域
    pingshou = 2,
    --手牌 同花
    sp_tonghua = 3,
    --手牌 连牌
    sp_lianpai = 4,
    --手牌 对子
    sp_duizi = 5,
    --手牌 同花连牌
    sp_tonghualianpai = 6,
    --手牌 对A
    sp_duiA = 7,
    --手牌 高牌
    sp_gaopai = 8,
    --手牌 两对
    sp_liangdui = 9,
    --手牌 三条
    sp_santiao = 10,
    --手牌 葫芦
    sp_hulu = 11,
    --手牌 金刚
    sp_jingang = 12,
}

--选择下注分数
tab_betScore = 
{
    10,
    10,
    10,
    10
}

--记录其他玩家每个区域下注分数
local tab_OtherBetScore = {}

--记录自己每个区域下注分数
local tab_SlefBetScore = {}

--金币筹码区域
local tab_GoldChip = {}

--上座玩家座位表信息
local tab_downPlayers = {
    player0 = {},
    player1 = {},
    player2 = {},
    player3 = {},
    player4 = {},
    player5 = {},
    player6 = {},
    player7 = {},
}

--每个卡牌对应的ui
local tab_cards = {}
--牌型
local tab_cardtypes = {}
--每个卡牌的值
local tab_CardValue = 
{
    card1 = {value = nil,isflag = false},--左1
    card2 = {value = nil,isflag = false}, 
    card3 = {value = nil,isflag = false},--右1
    card4 = {value = nil,isflag = false}, 
    card5 = {value = nil,isflag = false},--中1
    card6 = {value = nil,isflag = false}, 
    card7 = {value = nil,isflag = false},
    card8 = {value = nil,isflag = false},
    card9 = {value = nil,isflag = false}
}

--下注区域输赢情况，应对插旗
local tab_areaWin = {}
--有效牌
local tab_maxCards = {}
--上座玩家赢钱的座位索引
local tab_winPlayer = {} --0-7 0代表第一个玩家
--自己输赢多少分
local selfWinScore = 0
--游戏过程阶段表
--开始阶段
local tab_rest={
    --播放牛仔和牛碰撞的开头动画
    {
        time = 2,
        func1 = function()
            -- print("1111111111111111111111111111111111111111")
            -- print(os.date("%Y-%m-%d %H:%M:%S"))
            tab_spineAnim['leftrole'].gameObject:SetActive(false)
            tab_spineAnim['rightrole'].gameObject:SetActive(false)
            this:PlaySpine(tab_spineAnim['gamestart'],'kaishi',false)
        end,

        func2 = function()
            this:PlaySpine(tab_spineAnim['leftrole'],'ren1',true)
            this:PlaySpine(tab_spineAnim['rightrole'],'niu1',true)
        end
    },
    --翻牌动画
	{
        time = 3,
        func1 = function()
            local mv = m_content:GetTransition('cardStart')
            mv:Play()
            table.insert(tab_DZNZEffectS,mv)
            mv:SetHook("card", function()
                this:ShowCardOn(5,true)
            end);
        end,

        func2 = function()
            this:PlaySpine(tab_spineAnim['leftrole'],'ren1',true)
            this:PlaySpine(tab_spineAnim['rightrole'],'niu1',true)
            for i=1,#tab_cards do
                tab_cards[i].visible = true
                if i==5 then
                    this:ShowCardOn(i,true)
                else
                    this:ShowCardOn(i,false)
                end
            end
        end
	}
}

--下注阶段
local tab_bets={
        --开始下注
        {
            time = 10,
            func1 = function()
                --print("什么都不做=====")
            end,

            func2 = function()
                -- this:PlaySpine(tab_spineAnim['leftrole'],'ren1',true)
                -- this:PlaySpine(tab_spineAnim['rightrole'],'niu1',true)
                -- this:ResetCard()
                -- this:setCardValue(5,tab_CardValue['card5']['value'])
                -- for i=1,#tab_cards do
                --     tab_cards[i].visible = true
                --     if i==5 then
                --         this:ShowCardOn(i,true)
                --     else
                --         this:ShowCardOn(i,false)
                --     end
                -- end
                this:resetGameStart()
            end
        }
}
--结算阶段
--前置条件
--牌  下注区域数据  牛仔动画
local tab_score={
        --播放开战动画，开牌动画和胜利方插旗
        {
            time = 4,
            func1 = function()
                --开战动效
                --翻牌
                local mv = m_content:GetTransition('cardEnd')
                mv:Play(function()
                --设置有效牌及牌型
                local left_win = false
                local right_win = false
                if tab_areaWin[3] == 1 then
                    left_win = true
                    right_win = true
                elseif tab_areaWin[1] == 1 then
                    left_win = true
                elseif tab_areaWin[2] == 1 then
                    right_win = true
                end

                this:show_cardtype(tab_cardtypes[1],0, left_win)
                this:show_cardtype(tab_cardtypes[2],1, right_win)

                for k,v in pairs(tab_CardValue) do
                    if v.isflag == false then
                        local str = string.sub(tostring(k),-1)
                        str = tonumber(str)
                        this:showCardMask(tonumber(str),true)
                    end
                end

                --更换牛仔动画
                if tab_areaWin[3] == 1 then
                    this:PlaySpine(tab_spineAnim['leftrole'],'ren3',true)
                    this:PlaySpine(tab_spineAnim['rightrole'],'niu3',true)
                elseif tab_areaWin[1] == 1 then
                    this:PlaySpine(tab_spineAnim['leftrole'],'ren3',true)
                    this:PlaySpine(tab_spineAnim['rightrole'],'niu2',true)
                    F_SoundManager.instance:PlayEffect('sng_winner_1')
                elseif tab_areaWin[2] == 1 then
                    this:PlaySpine(tab_spineAnim['leftrole'],'ren2',true)
                    this:PlaySpine(tab_spineAnim['rightrole'],'niu3',true)
                    F_SoundManager.instance:PlayEffect('niujiao')
                end

                local temp_tab = { }
                for i, v in ipairs(tab_areaWin) do
                    if v == 1 then
                        table.insert(temp_tab, i)
                    end
                end

                local ply_sound = false
                for k, v in ipairs(temp_tab) do
                    local winArea_spine = this:get_winarea(v)
                    if winArea_spine then
                        this:PlaySpine(winArea_spine,'mupai',false)
                        if not ply_sound then
                            F_SoundManager.instance:PlayEffect('bx_getCoin')
                            ply_sound = true
                        end
                    end
                end

                end)
                table.insert(tab_DZNZEffectS,mv)
            end,

            func2 = function()
                --无开战动效
                --直接翻牌
                --设置有效牌及牌型
                --直接插旗
            end
        },
        --系统收金币
        {
            time = 1,
            func1 = function()
                --local pos = UI_OtherFunc['topDian']:LocalToGlobal(Vector2.zero)
                --local pos = UI_OtherFunc['topDian']:LocalToRoot(Vector2.zero,GRoot.inst)
                local pos = m_propLayer:GlobalToLocal(UI_OtherFunc['topDian']:LocalToGlobal(Vector2.zero))
                for i,v in ipairs(tab_areaWin) do
                    if v == 0 then
                        for k1,v1 in pairs(tab_GoldChip) do
                            if i - 1 == tonumber(k1) then
                                for k2,v2 in pairs(v1) do
                                    v2:TweenMove(pos,1):SetEase(EaseType.CubicOut):OnComplete(function()
                                        v2:Dispose()
                                    end)
                                end
                            end
                        end
                    end
                end

            end,

            func2 = function()
                --无开战动效
                --直接翻牌
                --设置有效牌及牌型
                --直接插旗
                --直接桌面减少金币
            end
        },
        --系统赔金币
        {
            time = 1,
            func1 = function()
                --创建10个金币飞往下注区域
                --local pos = UI_OtherFunc['topDian']:LocalToGlobal(Vector2.zero)
                --local pos = UI_OtherFunc['topDian']:LocalToRoot(Vector2.zero,GRoot.inst)
                --local pos = m_propLayer:GlobalToLocal(UI_OtherFunc['topDian']:LocalToGlobal(Vector2.zero))
                for i1,v1 in ipairs(tab_areaWin) do
                    if v1 == 1 then
                        local tab_tempGold = {}
                        for m = 1,10 do
                            local chipGold = UIPackage.CreateObject('niuzai','chipGold').asCom
                            chipGold.opaque = false;
                            m_content:GetChild('chipGoldParent'):AddChild(chipGold)
                            local tempx = math.random(810,1110)
                            local tempy = math.random(70,230)
                            chipGold.position = Vector2(tempx,tempy)
                            table.insert(tab_tempGold,chipGold)
                        end

                        for k2 ,v2 in pairs(tab_tempGold) do
                            local betArea_position = this:get_betArea_position(i1 - 1)
                            v2:TweenMove(betArea_position,0.5):SetEase(EaseType.CubicOut)
                            local is_have = false
                            for k,v in pairs(tab_GoldChip) do
                                if k == i1 - 1 then
                                    is_have = true
                                end
                            end
                            local index = i1 - 1
                            if is_have == true then
                                table.insert(tab_GoldChip[index],v2)
                            else
                                tab_GoldChip[index] = {}
                                table.insert(tab_GoldChip[index],v2)
                            end
                        end
                    end
                end
            end,

            func2 = function()
                --无开战动效
                --直接翻牌
                --设置有效牌及牌型
                --直接插旗
                --桌面赔好金币
            end
        },
        --玩家收金币
        {
            time = 2,
            func1 = function()
                --玩家收金币
                --local pos = UI_OtherFunc['btn_allWanJia']:LocalToGlobal(Vector2.zero) btnWanJia
                --local pos = UI_OtherFunc['btn_allWanJia']:LocalToRoot(Vector2.zero,GRoot.inst)
                --local pos = m_content:GetChild('btnWanJia'):LocalToRoot(Vector2.zero, GRoot.inst)
                local pos = m_propLayer:GlobalToLocal(UI_OtherFunc['btn_allWanJia']:LocalToGlobal(Vector2.zero))
                for i,v in ipairs(tab_areaWin) do
                    if v == 1 then
                        local startidx = 1
                        local endpos = nil
                        for k2,v2 in pairs(tab_GoldChip[i-1]) do
                            if #tab_winPlayer == 0 then
                                endpos = pos
                            elseif startidx <= #tab_winPlayer then
                                local playerIdx = tab_winPlayer[startidx]
                                --endpos = m_content:GetChild('head'..playerIdx):LocalToGlobal(Vector2.zero)
                                --endpos = m_content:GetChild('head'..playerIdx):LocalToRoot(Vector2.zero,GRoot.inst)
                                endpos = m_propLayer:GlobalToLocal(m_content:GetChild('head'..playerIdx):LocalToGlobal(Vector2.zero))
                            else
                                endpos = pos
                            end
                            v2:TweenMove(endpos,1):SetEase(EaseType.CubicOut):OnComplete(function()
                                v2:Dispose()
                            end)
                            startidx = startidx + 1
                        end
                    end
                end
            end,

            func2 = function()
                --无开战动效
                --直接翻牌
                --设置有效牌及牌型
                --直接插旗
                --没有金币
                --更新走势图
            end
        },
        --更新走势图及玩家赢钱飘字
        {
            time = 2,
            func1 = function()

                local win = 0
                F_SoundManager.instance:PlayEffect('baccaratwin')
                if tab_areaWin[3] == 1 then
                    win = 0
                elseif tab_areaWin[1] == 1 then
                    win = 1
                elseif tab_areaWin[2] == 1 then
                    win = 2
                end
                if #Data_GameTrend >=10 then
                    table.remove(Data_GameTrend,1)
                end
                table.insert(Data_GameTrend,win)
                local updateGameTrend = function()
                    for i,v in ipairs(Data_GameTrend) do
                        this:showOneGameTrend(i,v)
                    end
                end
                if tab_areaWin[3] == 1 then
                    m_content:GetTransition('star2'):Play(function()
                        updateGameTrend()
                    end)
                elseif tab_areaWin[1] == 1 then
                    m_content:GetTransition('star0'):Play(function()
                        updateGameTrend()
                    end)
                elseif tab_areaWin[2] == 1 then
                    m_content:GetTransition('star1'):Play(function()
                        updateGameTrend()
                    end)
                end

                selfWinScore = tonumber(selfWinScore)
                if selfWinScore ~= 0  then
                    if selfWinScore > 0 then
                        m_content:GetChild('winscore').text = "+"..formatVal(selfWinScore)
                        --loginSucceedInfo.user_info.gold = loginSucceedInfo.user_info.gold + selfWinScore
                        this:UpdateSelfMoney()
                    else
                        selfWinScore = math.abs(selfWinScore)
                        m_content:GetChild('winscore').text = "-"..formatVal(selfWinScore)
                    end
                    m_content:GetTransition('win'):Play()
                end
                --同花
                if #Data_sptonghuarecords.data >= 5 then
                    table.remove(Data_sptonghuarecords.data,1)
                end
                table.insert(Data_sptonghuarecords.data,tab_areaWin[4])
                if tab_areaWin[4] == 0 then
                    if Data_sptonghuarecords.count == nil then
                        Data_sptonghuarecords.count = 0
                    end
                    Data_sptonghuarecords.count = Data_sptonghuarecords.count + 1
                    --print("同花未出局数===",Data_sptonghuarecords.count)
                elseif tab_areaWin[4] == 1 then
                    Data_sptonghuarecords.count = 0
                end
                --连牌
                if #Data_splianpairecords.data >= 5 then
                    table.remove(Data_splianpairecords.data,1)
                end
                table.insert(Data_splianpairecords.data,tab_areaWin[5])
                if tab_areaWin[5] == 0 then
                    if Data_splianpairecords.count == nil then
                        Data_splianpairecords.count = 0
                    end
                    Data_splianpairecords.count = Data_splianpairecords.count + 1
                    --print("连牌未出局数===",Data_splianpairecords.count)
                elseif tab_areaWin[5] == 1 then
                    Data_splianpairecords.count = 0
                end
                --对子
                if #Data_spduizirecords.data >= 5 then
                    table.remove(Data_spduizirecords.data,1)
                end
                table.insert(Data_spduizirecords.data,tab_areaWin[6])
                if tab_areaWin[6] == 0 then
                    if Data_spduizirecords.count == nil then
                        Data_spduizirecords.count = 0
                    end
                    Data_spduizirecords.count = Data_spduizirecords.count + 1
                    --print("对子未出局数===",Data_spduizirecords.count)
                elseif tab_areaWin[6] == 1 then
                    Data_spduizirecords.count = 0
                end
                --同花连牌
                if #Data_spthlianpairecords.data >= 5 then
                    table.remove(Data_spthlianpairecords.data,1)
                end
                table.insert(Data_spthlianpairecords.data,tab_areaWin[7])
                if tab_areaWin[7] == 0 then
                    if Data_spthlianpairecords.count == nil then
                        Data_spthlianpairecords.count = 0
                    end
                    Data_spthlianpairecords.count = Data_spthlianpairecords.count + 1
                    --print("同花连牌未出局数===",Data_spthlianpairecords.count)
                elseif tab_areaWin[7] == 1 then
                    Data_spthlianpairecords.count = 0
                end
                --对A
                if #Data_spduiarecords.data >= 5 then
                    table.remove(Data_spduiarecords.data,1)
                end
                table.insert(Data_spduiarecords.data,tab_areaWin[8])
                if tab_areaWin[8] == 0 then
                    if Data_spduiarecords.count == nil then
                        Data_spduiarecords.count = 0
                    end
                    Data_spduiarecords.count = Data_spduiarecords.count + 1
                    --print("对A未出局数===",Data_spduiarecords.count)
                elseif tab_areaWin[8] == 1 then
                    Data_spduiarecords.count = 0
                end
                --高牌一对
                if #Data_gaopaiyiduirecords.data >= 5 then
                    table.remove(Data_gaopaiyiduirecords.data,1)
                end
                table.insert(Data_gaopaiyiduirecords.data,tab_areaWin[9])
                if tab_areaWin[9] == 0 then
                    if Data_gaopaiyiduirecords.count == nil then
                        Data_gaopaiyiduirecords.count = 0
                    end
                    Data_gaopaiyiduirecords.count = Data_gaopaiyiduirecords.count + 1
                    --print("高牌一对未出局数===",Data_gaopaiyiduirecords.count)
                elseif tab_areaWin[9] == 1 then
                    Data_gaopaiyiduirecords.count = 0
                end
                --两对
                if #Data_lianduirecords.data >= 5 then
                    table.remove(Data_lianduirecords.data,1)
                end
                table.insert(Data_lianduirecords.data,tab_areaWin[10])
                if tab_areaWin[10] == 0 then
                    if Data_lianduirecords.count == nil then
                        Data_lianduirecords.count = 0
                    end
                    Data_lianduirecords.count = Data_lianduirecords.count + 1
                    --print("两对未出局数===",Data_lianduirecords.count)
                elseif tab_areaWin[10] == 1 then
                    Data_lianduirecords.count = 0
                end
                --三条顺子同花
                if #Data_st_sz_threcords.data >= 5 then
                    table.remove(Data_st_sz_threcords.data,1)
                end
                table.insert(Data_st_sz_threcords.data,tab_areaWin[11])
                if tab_areaWin[11] == 0 then
                    if Data_st_sz_threcords.count == nil then
                        Data_st_sz_threcords.count = 0
                    end
                    Data_st_sz_threcords.count = Data_st_sz_threcords.count + 1
                    --print("三条顺子同花未出局数===",Data_st_sz_threcords.count)
                elseif tab_areaWin[11] == 1 then
                    Data_st_sz_threcords.count = 0
                end
                --葫芦
                if #Data_hulurecords.data >= 5 then
                    table.remove(Data_hulurecords.data,1)
                end
                table.insert(Data_hulurecords.data,tab_areaWin[12])
                if tab_areaWin[12] == 0 then
                    if Data_hulurecords.count == nil then
                        Data_hulurecords.count = 0
                    end
                    Data_hulurecords.count = Data_hulurecords.count + 1
                    --print("葫芦未出局数===",Data_hulurecords.count)
                elseif tab_areaWin[12] == 1 then
                    Data_hulurecords.count = 0
                end
                --同花顺四条皇家
                if #Data_four_ths_hjrecords.data >= 5 then
                    table.remove(Data_four_ths_hjrecords.data,1)
                end
                table.insert(Data_four_ths_hjrecords.data,tab_areaWin[13])
                if tab_areaWin[13] == 0 then
                    if Data_four_ths_hjrecords.count == nil then
                        Data_four_ths_hjrecords.count = 0
                    end
                    Data_four_ths_hjrecords.count = Data_four_ths_hjrecords.count + 1
                    --print("同花顺四条皇家未出局数===",Data_four_ths_hjrecords.count)
                elseif tab_areaWin[13] == 1 then
                    Data_four_ths_hjrecords.count = 0
                end

                this:resp_BetAreaTrend()

            end,

            func2 = function()

            end
        }
}

--游戏阶段
local gameCase =
{
    rest = function(...)
        this:resetAllGameData()
        -- local tab_rest = this:GetTabRest()
        local args = {...}
        local isflag = args[1]
        local end_timer = args[2]
        tab_CardValue['card5']['value'] = args[3]
        --print("最左边中间牌数据==",string.format( "0x%X",args[3]))
        this:show_countdowntip(end_timer,1)
        this:setCardValue(5,args[3])
        this:DoCase(tab_rest,end_timer,isflag)
    end,

    bets = function(...)
        -- local tab_bets = this:GetTabBets()
        local args = {...}
        local isflag = args[1]
        local end_timer = args[2]
        maxBets = tonumber(args[3])
        if not isflag then
            tab_CardValue['card5']['value'] = args[4]
            --每个区域下注多少金币
            tab_OtherBetScore = {}
            for i,v in ipairs(args[5]) do
                tab_OtherBetScore[i-1] = tonumber(v)
            end
            -- for k,v in pairs(tab_OtherBetScore) do
            --     print("11111111=====",k,v)
            -- end
            this:UpdateOtherBetScore()
            --自己区域下注多少金币
            tab_SlefBetScore = {}
            myBets = 0
            for i,v in ipairs(args[6]) do
                tab_SlefBetScore[i-1] = tonumber(v)
                myBets = myBets + tonumber(v)
            end
            -- for k,v in pairs(tab_SlefBetScore) do
            --     print("222222222=====",k,v)
            -- end
            this:UpdateSelfBetScore()
        end
        this:showCountDown(end_timer,true)
        this:DoCase(tab_bets,end_timer,isflag)
    end,

    score = function(...)
        -- local tab_score = this:GetTabScore()
        local args = {...}
        local isflag = args[1]
        local end_timer = args[2]
        local otherWinChairID = args[3] --
        local otherWinScore = args[4] --
        tab_areaWin = args[5] --
        local cards = args[6] --
        local maxCards = args[7] --
        tab_cardtypes = args[8] --
        if isflag then
            selfWinScore = args[9]
            local selfRevenue = args[10]
        else
            local areaInAllScore = args[9]
        end
        --设置倒数计时
        this:show_countdowntip(end_timer,0)
-------------------------------------------------
        --其他玩家输赢区域
        --for i,v in ipairs(otherWinChairID) do
        --    print("其他玩家输赢区域===="..v)
        --end

        --其他玩家输赢金币
        --for i,v in ipairs(otherWinScore) do
        --    --print("其他玩家输赢金币===="..v)
        --end

        for i,v in ipairs(otherWinScore) do
            if tonumber(v) > 0 then
                table.insert(tab_winPlayer,otherWinChairID[i])
            end
        end

        --下注区域输赢
        --for i,v in ipairs(tab_areaWin) do
            --print("下注区域输赢===="..v)
        --end

        --牌数据
        for i,v in ipairs(cards) do
            tab_CardValue['card'..i]['value'] = v
            --print("牌数据====",string.format( "0x%X",v))
        end

        --有效牌
        --for i,v in ipairs(maxCards) do
            --print('有效牌====:'..string.format( "0x%X",v))
        --end

        for k,v in pairs(tab_CardValue) do
            v.isflag = false
        end
        local left_win = false
        local right_win = false
        if tab_areaWin[3] == 1 then
            left_win = true
            right_win = true
        elseif tab_areaWin[1] == 1 then
            left_win = true
        elseif tab_areaWin[2] == 1 then
            right_win = true
        end
        if left_win and right_win then
            for i1,v1 in ipairs(maxCards) do
                for k2,v2 in pairs(tab_CardValue) do
                    if v1 == v2.value then
                        v2.isflag = true
                    end
                end
            end
        elseif left_win then
            for i1 = 1,5 do
                for k2,v2 in pairs(tab_CardValue) do
                    if maxCards[i1] == v2.value then
                        v2.isflag = true
                    end
                end
            end
        elseif right_win then
            for i1 = 6,10 do
                for k2,v2 in pairs(tab_CardValue) do
                    if maxCards[i1] == v2.value then
                        v2.isflag = true
                    end
                end
            end
        end
        --牌型
        --for i, v in ipairs(tab_cardtypes) do
            --print("牌型===="..v)
        --end

        --设置牌
        for i, v in ipairs(cards) do
            this:setCardValue(i,v)
        end

        this:DoCase(tab_score, end_timer, isflag)
    end,

    syc = function(self_score, other_ply_id, other_ply_score)
        for i = 1, #other_ply_id do
            ui_define:UpdatePlayersCoin(other_ply_id[i], other_ply_score[i])
        end
        loginSucceedInfo.user_info.gold = self_score
    end,
}

function ControllerDZNZ_Main:Init()
    CtrlDZNZ_Net.Init(ControllerDZNZ_Main)
	self.m_view = UIPackage.CreateObject('niuzai','niuZaiView').asCom
	UIManager.normal:AddChild(self.m_view)
    UIManager.AdaptiveAllotypy(self.m_view)     -- 适配刘海屏水滴屏
    self.m_view.visible=false
    m_content = self.m_view:GetChild('content')
    m_propLayer = m_content:GetChild("prop")    -- 道具层做坐标转换用
    m_imagePos = m_propLayer:GlobalToLocal(m_content:GetChild('img_pos'):LocalToGlobal(Vector2.zero))
---------------- init panel logic ----------------------------
    -- 初始化 UI 界面
    ui_define:Init_UI(m_content,CtrlDZNZ_Net,this)
    -- 初始化 spine 动画
    this:InitSpineAnim()
    this:InitCards()
    readyTime = 5
    makeWarTime = 3
    betsTime = 10
    scoreTime = 10

    m_content:GetChild("btnChase").onClick:Add(function ()
        UIManager.Show('CtrlDZNZChaseMain')
    end)

    this:InitBtnContinue()
end

function ControllerDZNZ_Main:Show(arg)
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true
    -- 更新用户信息
    this:UpdateUserInfo()
    -- 续投
    this:CloseContinueBet()
    UIManager.Hide('ControllerHall')
    --在游戏内不播放背景音乐
    --F_SoundManager.instance:CloseMusicVolume()
    F_SoundManager.instance:PlayEffect('sng_bgm', true)
end

function ControllerDZNZ_Main:OnHide()
    --重置所有数据
    self.m_view.visible = false
    this:CloseContinueBet()
    -- self.m_view.visible:Dispose()
end

-- 初始化主界面
function this:InitMain()
    -- body
end
--------------------------------
-- 获取游戏过程表
function this:GetGameCase()
    return gameCase
end

-- 获取休息表
function this:GetTabRest()
    return tab_rest
end

-- 获取游戏过程表
function this:GetTabBets()
    return tab_bets
end

-- 获取游戏过程表
function this:GetTabScore()
    return tab_score
end

--游戏阶段处理函数
function this:DoCase(table,time,isflag)
    --coroutine.stopAll()
    this:stopDZNZEffectS()

    -- table.init(self)
    if isflag == true then
        coroutine.start(function ()
            for i,v in ipairs(table) do
                v.func1()
                coroutine.wait(v.time)
            end
        end)
    else
        local t = time
        local j = #table
        while(t > table[j].time) do
            t = t - table[j].time
            j = j-1
            if j == 0 then
                j = 1
                t = table[j].time
                break
            end
        end
        coroutine.start(function ()
            table[j].func2(t)
            coroutine.wait(time)
            for i = j+1, #table do
                table[i].func1()
                coroutine.wait(table[i].time)
            end
        end)
    end

end

-----------------------
-- 初始化 spine 动画
function this:InitSpineAnim()
	--获取德州牛仔动画位置
	--spine动画名字  承载spine动画的组件  位置
    local anim_gamestart = UIManager.SetDragonBonesAniObjPos2('dznz_Role',
        m_content:GetChild('anim_GameStartParent'),Vector3.New(100,100,100)).gameObject.transform:GetChild(0)

    local anim_leftrole = UIManager.SetDragonBonesAniObjPos2('dznz_Role',
        m_content:GetChild('anim_LeftRole'),Vector3.New(80,80,80)).gameObject.transform:GetChild(0)
    --anim_leftrole.localPosition = Vector3(560,-350,0)
    anim_leftrole.localPosition = Vector3(430,-260,0)

    local anim_rightrole = UIManager.SetDragonBonesAniObjPos2('dznz_Role',
        m_content:GetChild('anim_rightRole'),Vector3.New(80,80,80)).gameObject.transform:GetChild(0)
    --anim_rightrole.localPosition = Vector3(-500,-350,0)
    anim_rightrole.localPosition = Vector3(-406,-278,0)

    for i=1,13 do
        local size = Vector3(100,100,100)
        if i > 3 then
            size = Vector3(80,80,80)
        end
        local temp_anim = UIManager.SetDragonBonesAniObjPos2('dznz_MuBan',
            m_content:GetChild('anim_GameStartParent'),size).gameObject.transform:GetChild(0)
        if i == 1 then
            tab_spineAnim['redwin'] = temp_anim
            temp_anim.localPosition = Vector3(-475,153,0)
        elseif i == 2 then
            tab_spineAnim['draw'] = temp_anim
            temp_anim.localPosition = Vector3(0,153,0)
        elseif i == 3 then
            tab_spineAnim['bluewin'] = temp_anim
            temp_anim.localPosition = Vector3(526,153,0)
        elseif i == 4 then
            tab_spineAnim['tonghua_win'] = temp_anim
            temp_anim.localPosition = Vector3(-396,-80,0)
        elseif i == 5 then
            tab_spineAnim['lianpai_win'] = temp_anim
            temp_anim.localPosition = Vector3(-147,-80,0)
        elseif i == 6 then
            tab_spineAnim['duizi_win'] = temp_anim
            temp_anim.localPosition = Vector3(-638,-270,0)
        elseif i == 7 then
            tab_spineAnim['tonghualianpai_win'] = temp_anim
            temp_anim.localPosition = Vector3(-396,-270,0)
        elseif i == 8 then
            tab_spineAnim['duiA_win'] = temp_anim
            temp_anim.localPosition = Vector3(-147,-270,0)
        elseif i == 9 then
            tab_spineAnim['gaopai_win'] = temp_anim
            temp_anim.localPosition = Vector3(350,-80,0)
        elseif i == 10 then
            tab_spineAnim['liangdui_win'] = temp_anim
            temp_anim.localPosition = Vector3(630,-80,0)
        elseif i == 11 then
            tab_spineAnim['santiao_win'] = temp_anim
            temp_anim.localPosition = Vector3(140,-270,0)
        elseif i == 12 then
            tab_spineAnim['hulu_win'] = temp_anim
            temp_anim.localPosition = Vector3(350,-270,0)
        elseif i == 13 then
            tab_spineAnim['jingang_win'] = temp_anim
            temp_anim.localPosition = Vector3(630,-270,0)
        end
        temp_anim.gameObject:SetActive(false)
    end

    tab_spineAnim['gamestart'] = anim_gamestart
    tab_spineAnim['leftrole'] = anim_leftrole
    tab_spineAnim['rightrole'] = anim_rightrole

    anim_gamestart.gameObject:SetActive(false)
    anim_leftrole.gameObject:SetActive(false)
    anim_rightrole.gameObject:SetActive(false)

    self.anim_GameStartEnd = function (state,trackIndex,loopCount)
        -- body
        this:PlaySpine(tab_spineAnim['leftrole'],'ren1',true)
        this:PlaySpine(tab_spineAnim['rightrole'],'niu1',true)
        UI_OtherFunc['mask'].visible = false
    end
end

--更新用户信息
function this:UpdateUserInfo()
    local self_userinfo = loginSucceedInfo.user_info
    m_content:GetChild('txtNickName').text = self_userinfo.nickname
    m_content:GetChild('txtMoney').text = formatVal(tonumber(self_userinfo.gold))
    m_content:GetChild('head'):GetChild('icon').asLoader.url = HandleWXIcon(self_userinfo.headurl)
    --m_content:GetChild('head').asLoader.url = HandleWXIcon(loginSucceedInfo.headurl)
    --itemOBJ:GetChild('icon').asLoader.url = HandleWXIcon(user_info.headurl)
end

-- 播放spine动画
function this:PlaySpine(spine_anim,anim_name,is_loop)
    local skeleton_anim = spine_anim:GetComponent('Spine.Unity.SkeletonAnimation')
    skeleton_anim.skeleton:SetToSetupPose()
    skeleton_anim.state:ClearTracks()
    skeleton_anim.state:SetAnimation(0,anim_name,is_loop)
    spine_anim.gameObject:SetActive(true)

    if anim_name == 'kaishi' then
        UI_OtherFunc['mask'].visible = true
        skeleton_anim.state.Complete = skeleton_anim.state.Complete - self.anim_GameStartEnd
        skeleton_anim.state.Complete = skeleton_anim.state.Complete + self.anim_GameStartEnd
        F_SoundManager.instance:PlayEffect('duizhan')
    end
end

-- spine 动画开始动画播放结束
function this:anim_GameStartEnd()
    this:PlaySpine(tab_spineAnim['leftrole'],'ren1',true)
    this:PlaySpine(tab_spineAnim['rightrole'],'niu1',true)
end

--下注筹码动画
function this:BetChipAnim(bet_areaindex,score,startPosIdx)
    local betArea_position = this:get_betArea_position(bet_areaindex)
    local betStart_position = this:get_betStart_position(startPosIdx)
    local chipGold = UIPackage.CreateObject('niuzai','chipGold').asCom
    chipGold.opaque = false;
    m_content:GetChild('chipGoldParent'):AddChild(chipGold)
    chipGold.position = betStart_position
    chipGold:TweenMove(betArea_position,0.3):SetEase(EaseType.CubicOut)

    if startPosIdx == -1 then
        local mv = m_content:GetTransition("playerlist"):Play()
    else
        local mv = m_content:GetTransition("player"..startPosIdx):Play()
    end

    ----------------------------------------------------------------------------

    local is_have = false
    for k,v in pairs(tab_GoldChip) do
        local key = k
        if key == bet_areaindex then
            is_have = true
        end
    end

    if is_have == true then
        table.insert(tab_GoldChip[bet_areaindex],chipGold)
    else
        -- local temp_tab = {}
        -- table.insert(temp_tab,chipGold)
        -- table.insert(tab_GoldChip,bet_areaindex,temp_tab)
        tab_GoldChip[bet_areaindex] = {}
        table.insert(tab_GoldChip[bet_areaindex],chipGold)
    end
end

--获取下注区域的坐标
function this:get_betArea_position(bet_areaindex)
    local betArea_position = Vector2.zero
    local random_y = math.random(260,400)
    local random_x = 0
    local pos = m_propLayer:GlobalToLocal(ui_define:Get_UIBetArea(bet_areaindex):LocalToGlobal(Vector2.zero))
    --local pos = ui_define:Get_UIBetArea(bet_areaindex):LocalToRoot(Vector2.zero,GRoot.inst)
    if bet_areaindex == tab_betArea['red_win'] then
        --random_x = math.random(pos.x + 10,pos.x + 400)
        --random_y = math.random(pos.y + 10,pos.y + 150)
        random_x = math.random(pos.x,pos.x + 380)
        random_y = math.random(pos.y,pos.y + 120)
        --random_x = math.random(260,600)
    elseif bet_areaindex == tab_betArea['blue_win'] then
        --random_x = math.random(pos.x + 10,pos.x + 400)
        --random_y = math.random(pos.y + 10,pos.y + 150)
        random_x = math.random(pos.x,pos.x + 380)
        random_y = math.random(pos.y,pos.y + 120)
        --random_x = math.random(1260,1700)
    elseif bet_areaindex == tab_betArea['pingshou'] then
        --random_x = math.random(pos.x + 10,pos.x + 400)
        --random_y = math.random(pos.y + 10,pos.y + 150)
        random_x = math.random(pos.x,pos.x + 380)
        random_y = math.random(pos.y,pos.y + 120)
        --random_x = math.random(760,1200)
    elseif bet_areaindex == tab_betArea['sp_lianpai'] then
        --random_x = math.random(pos.x + 10,pos.x + 180)
        --random_y = math.random(pos.y + 10,pos.y + 100)
        random_x = math.random(pos.x,pos.x + 150)
        random_y = math.random(pos.y,pos.y + 80)
    elseif bet_areaindex == tab_betArea['sp_tonghua'] then
        --random_x = math.random(pos.x + 10,pos.x + 160)
        --random_y = math.random(pos.y + 10,pos.y + 100)
        random_x = math.random(pos.x,pos.x + 140)
        random_y = math.random(pos.y,pos.y + 80)
    elseif bet_areaindex == tab_betArea['sp_duizi'] then
        --random_x = math.random(pos.x + 10,pos.x + 160)
        --random_y = math.random(pos.y + 10,pos.y + 100)
        random_x = math.random(pos.x,pos.x + 140)
        random_y = math.random(pos.y,pos.y + 80)
    elseif bet_areaindex == tab_betArea['sp_tonghualianpai'] then
        --random_x = math.random(pos.x + 10,pos.x + 160)
        --random_y = math.random(pos.y + 10,pos.y + 100)
        random_x = math.random(pos.x,pos.x + 140)
        random_y = math.random(pos.y,pos.y + 80)
    elseif bet_areaindex == tab_betArea['sp_duiA'] then
        --random_x = math.random(pos.x + 10,pos.x + 180)
        --random_y = math.random(pos.y + 10,pos.y + 100)
        random_x = math.random(pos.x,pos.x + 150)
        random_y = math.random(pos.y,pos.y + 80)
    elseif bet_areaindex == tab_betArea['sp_gaopai'] then
        --random_x = math.random(pos.x + 10,pos.x + 180)
        --random_y = math.random(pos.y + 10,pos.y + 100)
        random_x = math.random(pos.x,pos.x + 150)
        random_y = math.random(pos.y,pos.y + 80)
    elseif bet_areaindex == tab_betArea['sp_liangdui'] then
        --random_x = math.random(pos.x + 10,pos.x + 180)
        --random_y = math.random(pos.y + 10,pos.y + 100)
        random_x = math.random(pos.x,pos.x + 150)
        random_y = math.random(pos.y,pos.y + 80)
    elseif bet_areaindex == tab_betArea['sp_santiao'] then
        --random_x = math.random(pos.x + 10,pos.x + 220)
        --random_y = math.random(pos.y + 10,pos.y + 100)
        random_x = math.random(pos.x,pos.x + 190)
        random_y = math.random(pos.y,pos.y + 80)
    elseif bet_areaindex == tab_betArea['sp_hulu'] then
        --random_x = math.random(pos.x + 10,pos.x + 120)
        --random_y = math.random(pos.y + 10,pos.y + 90)
        random_x = math.random(pos.x,pos.x + 90)
        random_y = math.random(pos.y,pos.y + 70)
    elseif bet_areaindex == tab_betArea['sp_jingang'] then
        --random_x = math.random(pos.x + 10,pos.x + 250)
        --random_y = math.random(pos.y + 10,pos.y + 100)
        random_x = math.random(pos.x,pos.x + 220)
        random_y = math.random(pos.y,pos.y + 80)
    end
    betArea_position = Vector2(random_x,random_y)
    return betArea_position
end

-- 获取下注起始坐标
function this:get_betStart_position(type_index)
    -- body
    local betStart_position = Vector2.zero

    if type_index == -1 then
        --从玩家列表飞出金币
        --betStart_position = m_content:GetChild('btnWanJia'):LocalToGlobal(Vector2.zero)
		--betStart_position = m_content:GetChild('btnWanJia'):LocalToRoot(Vector2.zero, GRoot.inst)
        betStart_position = m_propLayer:GlobalToLocal(m_content:GetChild('btnWanJia'):LocalToGlobal(Vector2.zero))
    -- elseif type_index == 1 then
    --     --从自己头像飞出金币
    --     betStart_position = m_content:GetChild('n28'):LocalToGlobal(Vector2.zero)
    else
        --从其他头像飞出金币
        --betStart_position = m_content:GetChild('head'..type_index):LocalToGlobal(Vector2.zero)
        --betStart_position = m_content:GetChild('head'..type_index):LocalToRoot(Vector2.zero,GRoot.inst)
        betStart_position = m_propLayer:GlobalToLocal(m_content:GetChild('head'..type_index):LocalToGlobal(Vector2.zero))
    end
    return betStart_position
end

-- 显示倒计时提示信息
-- timer,type_index
function this:show_countdowntip(...)
    local args = {...}
    local temp_timer = args[1]
    local tip_content = ''
    local tip_image = nil

    if args[2] == 0 then
        tip_content = '开牌中   '
        tip_image = UI_WarTip['MakeWar']
    elseif args[2] == 1 then
        tip_content = '正在发牌   '
        tip_image = UI_WarTip['GotoWar']
    end
    UI_Tip['tipText'].text = tip_content..temp_timer
    local mtimer = Timer.New(function ()
        if (args[2] == 0 and temp_timer == betsTime) or (args[2] == 1 and temp_timer == makeWarTime) then
            tip_image:TweenMoveX(-1000, 0.1):OnComplete(function ()
                tip_image.visible = true
                tip_image:TweenMoveX(m_imagePos.x, 0.5):OnComplete(function ()
                    tip_image:TweenMoveX(2500, 0.6):SetDelay(1):OnComplete(function ()
                        tip_image.visible = false
                    end)
                end)
            end)
        end
        temp_timer = temp_timer - 1
        UI_Tip['tipText'].text = tip_content..temp_timer
        if temp_timer == 0 then
            UI_Tip['tipBg'].visible = false
            UI_Tip['tipText'].visible = false
        end
    end,1,temp_timer)
    mtimer:Start()
    UI_Tip['tipBg'].visible = true
    UI_Tip['tipText'].visible = true
end

-- 获取胜利区域
function this:get_winarea(area_index)
    if area_index == 1 then
        return tab_spineAnim['redwin']
    --红色区域赢
    elseif area_index == 2 then
    --蓝色区域赢
        return tab_spineAnim['bluewin']
    elseif area_index == 3 then
    --平手区域赢
        return tab_spineAnim['draw']
    elseif area_index == 4 then
    --同花区域赢
        return tab_spineAnim['tonghua_win']
    elseif area_index == 5 then
    --连牌区域赢
        return tab_spineAnim['lianpai_win']
    elseif area_index == 6 then
    --对子区域赢
        return tab_spineAnim['duizi_win']
    elseif area_index == 7 then
    --同花连牌区域赢
        return tab_spineAnim['tonghualianpai_win']
    elseif area_index == 8 then
    --对A区域赢
        return tab_spineAnim['duiA_win']
    elseif area_index == 9 then
    --高牌区域赢
        return tab_spineAnim['gaopai_win']
    elseif area_index == 10 then
    --两对区域赢
        return tab_spineAnim['liangdui_win']
    elseif area_index == 11 then
    --三条区域赢
        return tab_spineAnim['santiao_win']
    elseif area_index == 12 then
    --葫芦区域赢
        return tab_spineAnim['hulu_win']
    elseif area_index == 13 then
    --金刚区域赢
        return tab_spineAnim['jingang_win']
    end
end

--准备阶段初始化牌
function this:InitCards()
    --设置所有牌全部隐藏
    tab_cards = {}
    table.insert(tab_cards,UI_Card['left_card_1'])
    table.insert(tab_cards,UI_Card['left_card_2'])
    table.insert(tab_cards,UI_Card['right_card_1'])
    table.insert(tab_cards,UI_Card['right_card_2'])
    table.insert(tab_cards,UI_Card['middle_card_1'])
    table.insert(tab_cards,UI_Card['middle_card_2'])
    table.insert(tab_cards,UI_Card['middle_card_3'])
    table.insert(tab_cards,UI_Card['middle_card_4'])
    table.insert(tab_cards,UI_Card['middle_card_5'])
    for i=1,#tab_cards do
        tab_cards[i].visible = false
        this:ShowCardOn(i,false)
    end
end

--设置中间牌
function this:setCardValue(index,value)
    tab_cards[index]:GetChild('card').asLoader.url = PokerUrlMap[value]
end

--显示牌正面还是反面
function this:ShowCardOn(index,isflag)
    tab_cards[index]:GetChild('card').visible = isflag
    tab_cards[index]:GetChild('cardbg').visible = not isflag
end

--重置所有的卡牌
function this:ResetCard(index,isflag)
    for i=1,#tab_cards do
        tab_cards[i].visible = false
        tab_cards[i]:GetTransition("reset"):Play()
        this:ShowCardOn(i,false)
    end
end

-- 初始化牌
function this:UpdateCards(is_show,card)
    local _tab_cards = {}
    table.insert(_tab_cards,UI_Card['left_card_1'])
    table.insert(_tab_cards,UI_Card['left_card_2'])
    table.insert(_tab_cards,UI_Card['middle_card_1'])
    table.insert(_tab_cards,UI_Card['middle_card_2'])
    table.insert(_tab_cards,UI_Card['middle_card_3'])
    table.insert(_tab_cards,UI_Card['middle_card_4'])
    table.insert(_tab_cards,UI_Card['middle_card_5'])
    table.insert(_tab_cards,UI_Card['right_card_1'])
    table.insert(_tab_cards,UI_Card['right_card_2'])

    for i=1,#_tab_cards do
        _tab_cards[i].visible = false
    end

    if is_show == false then
        return
    end

    local card_index = 1
    local m_timer = Timer.New(function ()
        if card_index <= #_tab_cards then
            _tab_cards[card_index].visible = true
            _tab_cards[card_index]:GetChild('card').visible = false
            _tab_cards[card_index]:GetChild('cardbg').visible = true
            if _tab_cards[card_index].name == 'middle_card1' then
                _tab_cards[card_index]:GetChild('card').asLoader.url = PokerUrlMap[card]
                _tab_cards[card_index]:GetChild('card').visible = true
                _tab_cards[card_index]:GetChild('cardbg').visible = false
            end
        end
        -- tab_cards[card]
        card_index = card_index + 1
    end,0.2,0.2*9)
    m_timer:Start()

end

--显示牌型
function this:show_cardtype(card,cardtype_dir,is_win)
    local card_url = ''
    if is_win == true then
        card_url = NN_CardUrlMap_Win[card]
    else
        card_url = NN_CardUrlMap_Lose[card]
    end

    if cardtype_dir == 0 then
        UI_CardTyoe['Left_CardType'].asLoader.url = card_url
        UI_CardTyoe['Left_CardType'].visible = true
    elseif cardtype_dir == 1 then
        UI_CardTyoe['Right_CardType'].asLoader.url = card_url
        UI_CardTyoe['Right_CardType'].visible = true
    end
end

--隐藏牌型
function this:hide_cardtype()
    UI_CardTyoe['Left_CardType'].visible = false
    UI_CardTyoe['Right_CardType'].visible = false
end

--更新其他玩家下注分数
function this:UpdateOtherBetScore()
    for k,v in pairs(tab_OtherBetScore) do
        local key_bet = k
        local bet_area = ui_define:Get_UIBetArea(key_bet)
        bet_area:GetChild('txtOtherScore').text = v == 0 and "" or formatVal(v)
        bet_area:GetChild('txtOtherScore').visible = v ~= 0
        bet_area:GetChild('imgOtherScorebg').visible = v ~= 0
        -- if v == "0" then
        --     bet_area:GetChild('txtOtherScore').text = ""
        --     bet_area:GetChild('txtOtherScore').visible =false
        -- else
        --     bet_area:GetChild('txtOtherScore').text = v
        --     bet_area:GetChild('txtOtherScore').visible =true
        -- end
    end
end

--更新自己下注分数
function this:UpdateSelfBetScore()
    for k,v in pairs(tab_SlefBetScore) do
        local key_bet = k
        local bet_area = ui_define:Get_UIBetArea(key_bet)
        bet_area:GetChild('txtSelfScore').text = v == 0 and "" or formatVal(v)
        bet_area:GetChild('txtSelfScore').visible = v ~= 0
        bet_area:GetChild('imgSelfScorebg').visible = v ~= 0
    end
end

--更新连续未出局数
function this:UpdateNotOutJuShu()
    -- body
    UI_BetAre['sp_duiA']:GetChild('txtAreaInfo').visible = false
    UI_BetAre['sp_hulu']:GetChild('txtAreaInfo').visible = false
    UI_BetAre['sp_jingang']:GetChild('txtAreaInfo').visible = false

    if Data_ContinuityNotOut['duiA'] ~= 0 then
        UI_BetAre['sp_duiA']:GetChild('txtAreaInfo').visible = true
        UI_BetAre['sp_duiA']:GetChild('txtAreaInfo').text = Data_ContinuityNotOut['duiA']..'局未出'
    end

    if Data_ContinuityNotOut['hulu'] ~= 0 then
        UI_BetAre['sp_hulu']:GetChild('txtAreaInfo').visible = true
        UI_BetAre['sp_hulu']:GetChild('txtAreaInfo').text = Data_ContinuityNotOut['hulu']..'局未出'
    end

    if Data_ContinuityNotOut['tonghuasitiao'] ~= 0 then
        UI_BetAre['sp_jingang']:GetChild('txtAreaInfo').visible = true
        UI_BetAre['sp_jingang']:GetChild('txtAreaInfo').text = Data_ContinuityNotOut['tonghuasitiao']..'局未出'
    end
end

-- -- 回收金币
-- function this:RecoveryGold()
--     -- 输的区域金币先回收 到中间区域
-- 结算的时候 有胜利图标的 就是代表 开中的牌  那就是需要赔付出去的  收回去的 就是代表压输的区域
-- 所以飞到中间区域去了

-- 结算的时候 先是收 压输的区域的金币 然后 压赢的区域的金币不收  返回 是指退给压中的人
-- 然后中间又会有金币吐出来 是表示 压中的区域 需要再赔付出去

-- 例如 压中的区域 中了200万 如果是1赔1 那就是中间区域 需要在赔付1倍的金币出去
-- end

--------------------------------- net handle ---------------------------------

-- 响应游戏记录
function this:resp_GameRecord(...)
    local args = {...}
end

-- 响应游戏记录 -> 连续未出记录局数
function this:resp_NotOutRecord(...)
    local args = {...}
    local duiA = args[1]    --对A连续未出局数
    local hulu = args[2]    --葫芦连续未出局数
    local THSTHJ = args[3]  --同花四条皇家连续未出

    Data_ContinuityNotOut['duiA'] = duiA
    Data_ContinuityNotOut['hulu'] = hulu
    Data_ContinuityNotOut['tonghuasitiao'] = THSTHJ
    --this:UpdateNotOutJuShu()
end

-- 响应游戏记录 -> 红 、 蓝 、 平手 同花 对A 葫芦 金刚 胜负统计次数
function this:resp_WinLoserRecord(...)
    local args = {...}
    Data_WinOrLoser['red_win'] = args[1]
    Data_WinOrLoser['blue_win'] = args[2]
    Data_WinOrLoser['pingshou'] = args[3]
    Data_WinOrLoser['tonghualianpai_win'] = args[4]
    Data_WinOrLoser['duiA_win'] = args[5]
    Data_WinOrLoser['hulu_win'] = args[6]
    Data_WinOrLoser['jingang_win'] = args[7]
end

-- 响应游戏开始
function this:resp_GameStart(...)
    self:ContinuePlaceJetton()
end

-- 响应用户下注
function this:resp_PlaceJetton(...)
    local args = {...}
    local userid = args[1]          --下注id
    local jettonArea = args[2]      --下注区域
    local jettonScore = tonumber(args[3])     --下注分数

    local startPos = -1
    for k,v in pairs(tab_downPlayers) do
        if v.userid == args[1] then
            startPos = v.sitindex
        end
    end
    this:BetChipAnim(jettonArea,jettonScore,startPos)


------------------------ 更新区域下注分数 -------------------------------------

    ------------------------所有玩家
    local other_have = false
    for k,v in pairs(tab_OtherBetScore) do
        if jettonArea == k then
            other_have = true
        end
    end

    if other_have == true then
        tab_OtherBetScore[jettonArea] = tab_OtherBetScore[jettonArea] + jettonScore
    else
        --table.insert(tab_OtherBetScore,jettonArea,jettonScore)
        tab_OtherBetScore[jettonArea] = jettonScore
    end

    this:UpdateOtherBetScore()
    ------------------------ 自己
    if userid ~= loginSucceedInfo.user_info.userid then
        return
    end

    local self_have = false
    for k,v in pairs(tab_SlefBetScore) do
        if jettonArea == k then
            self_have = true
        end
    end

    if self_have == true then
        tab_SlefBetScore[jettonArea] = tab_SlefBetScore[jettonArea] + jettonScore
    else
        --table.insert(tab_SlefBetScore,jettonArea,jettonScore)
        tab_SlefBetScore[jettonArea] = jettonScore
    end

    myBets = myBets + jettonScore

    this:UpdateSelfBetScore()

    --更新自己的金币
    loginSucceedInfo.user_info.gold = loginSucceedInfo.user_info.gold - tonumber(jettonScore)
    if loginSucceedInfo.user_info.gold < 0 then
        loginSucceedInfo.user_info.gold = 0
    end

    this:UpdateSelfMoney()
end

-- 发牌阶段 响应开始游戏 -> 准备下注
function this:resp_ReadyWager(...)

    local args = {...}
    local end_timer = args[1]
    local card = args[2]

    if card == 0 then
        return
    end

    this:UpdateCards(true,card)
    this:show_countdowntip(end_timer,1)
    for k, v in pairs(tab_spineAnim) do
        v.gameObject:SetActive(false)
    end

    --清空记录其他玩家每个区域下注分数
    tab_OtherBetScore = {}
    --清空记录自己每个区域下注分数
    tab_SlefBetScore = {}

    for k,v in pairs(UI_BetAre) do
        local key_name = k
        v:GetChild('txtOtherScore').visible = false
        v:GetChild('imgOtherScorebg').visible = false
        v:GetChild('txtSelfScore').visible = false
        v:GetChild('txtAreaInfo').visible = false
        v:GetChild('imgSelfScorebg').visible = false
    end

    this:hide_cardtype()


end

--   响应游戏结束
-- 1 显示开牌提示倒计时
-- 2 翻转牌
-- 3 显示牌型
function this:resp_GmaEnd(...)
    local args = {...}
    local end_timer = args[1]
    --
    local _tab_areaWin = {}
    local tab = 1
    for i=1,#args[6] do
        if args[6][i] == 1 then
            table.insert(_tab_areaWin,i)
        end
    end

    --牌local tab_cards = args[7]

    --牌型
    local _tab_cardtypes = args[9]

-- DZNZ_Main:resp_GmaEnd(msg.endTime,msg.selfWinScore,
-- msg.selfRevenue,msg.otherWinChairID,
-- msg.otherWinScore,msg.areaWin,msg.cards,msg.maxCards,msg.cardTypes)

-- 1 print('结算时间: '..msg.endTime)
-- 2 print('自己输赢多少分: '..msg.selfWinScore)
-- 3 print('自己税收: '..msg.selfRevenue)
-- 4 print('其他玩家 id: '..tostring(msg.otherWinChairID))
-- 5 print('其他玩家 score: '..tostring(msg.otherWinScore))
-- 6 print('可下注区域输赢(可下注区域的输赢表) 0 :输, 1：赢: '..tostring(msg.areaWin))
-- 7 print('牌数据 1 :左边牌(2张), 2：右边牌(2张)， 3：中间牌(5张): '..tostring(msg.cards))
-- 8 print('最后组成最大的牌数据 1 :左边牌(5张), 2：右边牌(5张): '..tostring(msg.maxCards))
-- 9 print('最后牌型 1 :左边牌, 2：右边牌: '..tostring(msg.cardTypes))

    -- 胜利区域显示动画
    local winArea_index = 1
    local mTimer = Timer.New(function ()
        if winArea_index <= #_tab_areaWin then
            local winArea_spine = this:get_winarea(_tab_areaWin[winArea_index])
            this:PlaySpine(winArea_spine,'mupai',false)
        end
        winArea_index = winArea_index + 1
    end,0.2, #_tab_areaWin*0.2)
    mTimer:Start()

    ControllerDZNZ_Main:show_countdowntip(end_timer,0)

    -- 显示开牌
    local _tab_cards = args[7]
    UIManager.SetPokerCard(UI_Card['left_card_1'],_tab_cards[1])
    UIManager.SetPokerCard(UI_Card['left_card_2'],_tab_cards[2])

    UIManager.SetPokerCard(UI_Card['middle_card_1'],_tab_cards[3])
    UIManager.SetPokerCard(UI_Card['middle_card_2'],_tab_cards[4])
    UIManager.SetPokerCard(UI_Card['middle_card_3'],_tab_cards[5])
    UIManager.SetPokerCard(UI_Card['middle_card_4'],_tab_cards[6])
    UIManager.SetPokerCard(UI_Card['middle_card_5'],_tab_cards[7])

    UIManager.SetPokerCard(UI_Card['right_card_1'],_tab_cards[8])
    UIManager.SetPokerCard(UI_Card['right_card_2'],_tab_cards[9])

    -- -- 显示牌型
    local left_win = false
    local right_win = false
    if args[6][1] == 1 then
        left_win = true
    end
    if args[6][2] == 1 then
        right_win = true
    end
    if args[6][3] == 1 then
        left_win = true
        right_win = true
    end
    this:show_cardtype(_tab_cardtypes[1],0,left_win)
    this:show_cardtype(_tab_cardtypes[2],1,right_win)

    -- 开始回收金币
    for k,v in pairs(tab_GoldChip) do

        for i=1,#v do
            v[i]:Dispose()
        end

    end
    tab_GoldChip = {}
end

--设置玩家筹码及上座限制及下注限制
function this:resp_CoinsInfo(...)
    local args = {...}
    userLimitScore = args[1]
    clientusersitcondition = args[2]
    tab_betScore = {}
    for i,v in ipairs(args[3]) do
        table.insert(tab_betScore, v)
    end
    ui_define:InitUI_BetButton(m_content)
end

--响应玩家列表
function this:resp_UserList(...)
    local args = {...}
    local start_index = args[1]
    local all_count = args[2]
    local user_info = args[3]
    UIManager.Show('CtrlDZNZ_AllPlayerView',user_info)
end

--响应手牌记录
function this:resp_HandCardsRecord(...)
    local args = {...}
    Data_HandCards['totalscore'] = args[1]
    Data_HandCards['lastcards'] = args[2]
    Data_HandCards['lasttimer'] = args[3]
    Data_HandCards['userinfos'] = args[4]
end

--响应牌型记录
function this:resp_GameCardRecord(...)
    local args = {...}
    Data_GameCardRecord['totalscore'] = args[1]
    Data_GameCardRecord['lastcards'] = args[2]
    Data_GameCardRecord['lasttimer'] = args[3]
    Data_GameCardRecord['userinfos'] = args[4]
    UIManager.Show('CtrlDZNZ_DataView')
end

-- 响应初始化玩家坐下列表
function ControllerDZNZ_Main:UpdateUserSit(msg)
    -- local args = {...}
    -- for i=1,#args do
    --     print(args[i])
    -- end

    -- msg={
    --     {
    --         userid=1,
    --         nickname = 2,
    --         headurl = 3,
    --         score = 3,
    --         sex = 3,
    --         sitindex = 1,
    --     },
    --     {
    --         userid=1,
    --         nickname = 2,
    --         headurl = 3,
    --         score = 3,
    --         sex = 3,
    --         sitindex = 2,
    --     }
    -- }
    for i,v in ipairs(msg) do
        --print("上座玩家信息====",v.userid,v.score,v.sitindex)
    end
    if #msg ~= 0 then
        for k,v in pairs(tab_downPlayers) do
            tab_downPlayers[k] = {}
        end
        ui_define:ClearDownPlayers()
        for i,v in ipairs(msg) do
            if v.sitindex >= 0 and v.sitindex <= 7 then
                tab_downPlayers['player'..v.sitindex] = v
            end
        end
    end

    ui_define:UpdataDownPlayers(msg)
end

-- 响应新玩家坐下
function ControllerDZNZ_Main:UpdateSitDown(msg)
    --print("坐下去的id===",msg.sitindex)
    if msg.sitindex >= 0 and msg.sitindex <= 7 then
        tab_downPlayers['player'..msg.sitindex] = msg
    end
    ui_define:setDownPlayers(msg)
    ui_define:showHead(msg.sitindex,true)
end

-- 响应新玩家站起
function ControllerDZNZ_Main:UpdateStandUp(msg)
    --print("站起来的id===",msg.sitindex)
    if  msg.sitindex >= 0 and msg.sitindex <= 7 then
        tab_downPlayers['player'..msg.sitindex] = {}             
    end  
    if  msg.sitindex >= 0 and msg.sitindex <= 7 then
        ui_define:showHead(msg.sitindex,false)        
    end 
end
------------------------------------------------------------------

-- -- 是否显示倒计时闹钟
-- function ControllerDZNZ_Main:IsOpenCountDown_Func(timer,is_show)
--     local view_countDown = m_content:GetChild('daoJiShi')
--     view_countDown:GetChild('n14').text = timer
--     if is_show then
--         view_countDown:TweenMoveY(-200,0):OnComplete(function ()
--             view_countDown.visible = true
--             view_countDown:TweenMoveY(65,0.5)
--             local timer_temp = timer
--             local _timer = Timer.New(function ()
--                 timer_temp = timer_temp - 1
--                 if timer_temp == 0 then
--                     ControllerDZNZ_Main:IsOpenCountDown_Func(timer,false)
--                 end
--                 view_countDown:GetChild('n14').text = timer_temp
--             end,1,timer)
--             _timer:Start()
--         end)
--     else
--         view_countDown:TweenMoveY(-200,0.5):OnComplete(function ()
--             view_countDown.visible = false
--         end)
--     end    
-- end

--是否显示倒计时
function ControllerDZNZ_Main:showCountDown(time,isflag) 
    --找到闹钟ui
    local daojishi = m_content:GetChild('daoJiShi')
    daojishi:GetChild('n14').text = time
    --定时器设置闹钟
    if isflag then
        daojishi:TweenMoveY(-200,0):OnComplete(function()
            daojishi.visible = true
            daojishi:TweenMoveY(65,0.5)
            local temp_time = time  
            Timer.New(function ()
                temp_time = temp_time - 1
                daojishi:GetChild('n14').text = temp_time
                if temp_time == 2 or temp_time == 1 then
                    F_SoundManager.instance:PlayEffect('half_time')
                end
                if temp_time == 0 then
                    daojishi:TweenMoveY(-200,0.5):OnComplete(function()
                        daojishi.visible = false 
                    end)
                end
            end,1,time):Start()          
        end)
    else
        daojishi:TweenMoveY(-200,0.5):OnComplete(function()
            daojishi.visible = false 
        end)
    end
end

--初始化桌面走势图
function ControllerDZNZ_Main:resp_GameTrend() 
    if #Data_GameTrend == 0 then return end
    for i,v in ipairs(Data_GameTrend) do
        this:showOneGameTrend(i,v)
    end    
end

--桌面走势图显示单独一个走势
function ControllerDZNZ_Main:showOneGameTrend(index,value)
    UI_OtherFunc['topDian']:GetChild('dian'..index):GetController('c1').selectedIndex = value
end

--结算阶段桌面走势图变化
-- function ControllerDZNZ_Main:showOneGameTrend(index,value) 
--     Data_GameTrend
--     UI_OtherFunc['topDian']:GetChild('dian'..index):GetController('c1').selectedIndex = value   
-- end

--停止所有的fgui动效
function ControllerDZNZ_Main:stopDZNZEffectS() 
    for k,v in pairs(tab_DZNZEffectS) do
        v:Stop()
    end
end

--设置对应的卡牌出现暗遮罩
function ControllerDZNZ_Main:showCardMask(index,isflag) 
    tab_cards[index]:GetChild('mask').visible = isflag 
end

--重置断线重连进下注阶段数据
function ControllerDZNZ_Main:resetGameStart() 
    --牛仔动画
    this:PlaySpine(tab_spineAnim['leftrole'],'ren1',true)
    this:PlaySpine(tab_spineAnim['rightrole'],'niu1',true)
    --牌
    this:ResetCard()
    this:setCardValue(5,tab_CardValue['card5']['value'])
    for i=1,#tab_cards do
        tab_cards[i].visible = true
        if i==5 then
            this:ShowCardOn(i,true)
        else
            this:ShowCardOn(i,false)
        end                
    end     
end

--重置所有的数据
function ControllerDZNZ_Main:resetAllGameData() 
    --准备阶段
    --牌
    this:ResetCard()
    --动画
    for k,v in pairs(tab_spineAnim) do
        v.gameObject:SetActive(false)
    end
    --下注阶段
    --结算阶段
    --清空记录其他玩家每个区域下注分数
    tab_OtherBetScore = {}
    --清空记录自己每个区域下注分数
    tab_SlefBetScore = {} 
    --清除所有下注区域的数据
    for k,v in pairs(UI_BetAre) do
        local key_name = k
        v:GetChild('txtOtherScore').visible = false
        v:GetChild('imgOtherScorebg').visible = false
        v:GetChild('txtSelfScore').visible = false
        -- v:GetChild('txtAreaInfo').visible = false
        v:GetChild('imgSelfScorebg').visible = false
    end 
    --牌型 
    this:hide_cardtype() 
    --清除金币
    for k,v in pairs(tab_GoldChip) do
        for i=1,#v do
            v[i]:Dispose()
        end
    end
    tab_GoldChip = {} 
    --清掉有效牌
    for i,v in ipairs(tab_cards) do
        v:GetChild('mask').visible = false
    end
    --赢钱区域清除
    tab_areaWin = {}
    --有效牌
    tab_maxCards = {}
    --上座玩家赢钱的座位索引
    tab_winPlayer = {}
    --自己输赢多少分
    selfWinScore = 0

end

--更新下注区域的趋势表
function ControllerDZNZ_Main:resp_BetAreaTrend()
    --同花
    for i,v in ipairs(Data_sptonghuarecords.data) do
        this:setBetAreaTrend(3,i,Data_sptonghuarecords.count,v)
    end
    --连牌
    for i,v in ipairs(Data_splianpairecords.data) do
        this:setBetAreaTrend(4,i,Data_splianpairecords.count,v)
    end
    --对子
    for i,v in ipairs(Data_spduizirecords.data) do
        this:setBetAreaTrend(5,i,Data_spduizirecords.count,v)
    end
    --同花连牌
    for i,v in ipairs(Data_spthlianpairecords.data) do
        this:setBetAreaTrend(6,i,Data_spthlianpairecords.count,v)
    end
    --对A
    for i,v in ipairs(Data_spduiarecords.data) do
        this:setBetAreaTrend(7,i,Data_spduiarecords.count,v)
    end
    --高牌一对
    for i,v in ipairs(Data_gaopaiyiduirecords.data) do
        this:setBetAreaTrend(8,i,Data_gaopaiyiduirecords.count,v)
    end
    --两对
    for i,v in ipairs(Data_lianduirecords.data) do
        this:setBetAreaTrend(9,i,Data_lianduirecords.count,v)
    end
    --三条顺子同花
    for i,v in ipairs(Data_st_sz_threcords.data) do
        this:setBetAreaTrend(10,i,Data_st_sz_threcords.count,v)
    end
    --葫芦
    for i,v in ipairs(Data_hulurecords.data) do
        this:setBetAreaTrend(11,i,Data_hulurecords.count,v)
    end
    --同花顺四条皇家
    for i,v in ipairs(Data_four_ths_hjrecords.data) do
        this:setBetAreaTrend(12,i,Data_four_ths_hjrecords.count,v)
    end
end

--设置某一下注区域的趋势表
function ControllerDZNZ_Main:setBetAreaTrend(areaIdx,iconIdx,count,data)    
    local area = ui_define:Get_UIBetArea(areaIdx)
    if count ~= nil and count >= 10 then               
        this:setBetAreaTrendVisible(area,false)
        area:GetChild('txtAreaInfo').visible = true
        area:GetChild('txtAreaInfo').text = formatVal(tonumber(count)).."局未出"
    elseif data == 0 then
        this:setBetAreaTrendVisible(area,true)
        area:GetChild('tend'..iconIdx).url = 'ui://niuzai/tendOff'
    elseif data == 1 then
        this:setBetAreaTrendVisible(area,true)
        area:GetChild('tend'..iconIdx).url = 'ui://niuzai/tendOn'
    end     
end

--设置下注区域趋势表跟多少局未显示文字显隐
function ControllerDZNZ_Main:setBetAreaTrendVisible(area,isflag)
    area:GetChild('txtAreaInfo').visible = not isflag 
    area:GetChild('tend1').visible = isflag
    area:GetChild('tend2').visible = isflag
    area:GetChild('tend3').visible = isflag
    area:GetChild('tend4').visible = isflag
    area:GetChild('tend5').visible = isflag
end

--减去下注的金币值
function ControllerDZNZ_Main:UpdateSelfMoney()
    m_content:GetChild('txtMoney').text = formatVal(tonumber(loginSucceedInfo.user_info.gold))
    if UIManager.IsShowState('CtrlDZNZChaseMain') then
        UIManager.GetController('CtrlDZNZChaseMain'):UpdateSelfMoney()
    end
end

------------------------------------- 续投 --------------------------------
function ControllerDZNZ_Main:InitBtnContinue()
    m_content:GetChild("btnJiXu").onClick:Add(function ()
        UIManager.Show('ControllerHallZhuiHaoView', { slt_money_list = tab_betScore, is_niuzai = true })
    end)

    m_content:GetChild("btnQuXiao").onClick:Add(function ()
        this:CloseContinueBet()
        UIManager.AddPopTip({strTit = '续投取消成功'})
    end)

    self.m_continue_ctrl = m_content:GetController('continue')
    this:CloseContinueBet()
end

function ControllerDZNZ_Main:ContinueBetSuccess(bet_list)
    m_nz_continue_list = { }
    totalBet = 0
    for k, v in pairs(bet_list) do
        totalBet = totalBet + v.num
        table.insert(m_nz_continue_list, { area = v.area, num = v.num })
    end
    self.m_continue_ctrl.selectedIndex = 1
    UIManager.AddPopTip({strTit = '续投选择成功'})
end

-- 游戏开始续投
function ControllerDZNZ_Main:ContinuePlaceJetton()
    if #m_nz_continue_list > 0 then
        if tonumber(loginSucceedInfo.user_info.gold) < totalBet then
            UIManager.AddPopTip({strTit = '续投金币不足，续投已自动取消'})
            this:CloseContinueBet()
            return
        end

        for k, v in pairs(m_nz_continue_list) do
            CtrlDZNZ_Net.req_PlaceJetton(v.area, v.num)
        end

        UIManager.AddPopTip({strTit = '续投成功'})
    end

end

function ControllerDZNZ_Main:CloseContinueBet()
    totalBet = 0
    m_nz_continue_list = { }
    self.m_continue_ctrl.selectedIndex = 0
end

return ControllerDZNZ_Main


