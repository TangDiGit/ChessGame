-- local ControllerBaiRen_Net = class("ControllerBaiRen_Net")

--require 'Controller/DeZhouNiuZai/ControllerDZNZ_Main'

CtrlDZNZ_Net = {}
local self = CtrlDZNZ_Net
local gameStatus = -1
local DZNZ_Main = nil
local gametab = nil
local clientusersitcondition = 0 --上座分数限制
-- require "bit32"

function self.Init(dznz_main)

    DZNZ_Main = dznz_main

	self.registeEnterGameReponse_NetMsg()--进入房间成功反馈

	self.registerGameState_NetMsg()--

	self.registerGameScene_NetMsg()

	self.registerReadyWager_NetMsg()

	self.registerGameStart_NetMsg()

	self.registerUserWager_NetMsg()

	self.registerGameEnd_NetMsg()

	self.registerGameRecord_NetMsg()

	self.registerUserWagerFail_NetMsg()

	self.registerTableInfo_NetMsg()

	self.registerClearRecord_NetMsg()

	self.registerUserList_NetMsg()

	self.registerInitUserSitInfo_NetMsg()

	--self.registerUpdateUserSitInfo_NetMsg()

	self.registerUserSitDown_NetMsg()

	self.registeUserSitUp_NetMsg()

	self.registeBaseEnd_NetMsg()

    self.registeGetBigAreaWinInfo_NetMsg()
    
    self.registeClientHistoryRecordsInfo_NetMsg()

    self.resp_ExitRoom()

    self.resp_JinGangRecordsInfo()

    gametab = DZNZ_Main:GetGameCase()

	--print('(德州牛仔)初始化完成...')
end

--进入德州牛仔 房间成功
function self.registeEnterGameReponse_NetMsg()
    H_NetMsg:addEventListener('EnterGameReponse',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
    	UIManager.Show('ControllerDZNZ_Main')
    end)
end

--游戏状态
function self.registerGameState_NetMsg()
    H_NetMsg:addEventListener('GameState',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
        local msg = Protol.GameBaseMsg_pb.GF_GameStatus()
        msg:ParseFromString(arg.pb_data)
        gameStatus = msg.gameStatus
        --print('游戏状态====: '..gameStatus)
    end)
end

--游戏场景
function self.registerGameScene_NetMsg()
    H_NetMsg:addEventListener('GameScene',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
        local game_tab = DZNZ_Main:GetGameCase()
    	if gameStatus == 0 then
    		--等待开始
    		--print('gameStatus=====: '..gameStatus..' 等待开始')
    	elseif gameStatus == 101 then
    		--游戏进行中
            --对应数据包 ScenePlaceJetton
            --print('gameStatus=====: '..gameStatus..' 游戏进行中')
            local msg = Protol.DZNZ_GamePb_pb.ScenePlaceJetton()
            msg:ParseFromString(arg.pb_data)
            --print("下注阶段数据======"..msg.endTime)
            game_tab.bets(false,msg.endTime,msg.maxSelfCanInScore,msg.card,msg.areaInAllScore,msg.meAreaInAllScore)
    	elseif gameStatus == 102 then
    		--游戏结束
            --对应数据包 SceneGameEndf
            --print('gameStatus=====: '..gameStatus..' 游戏结束')
            local msg = Protol.DZNZ_GamePb_pb.SceneGameEnd()
            msg:ParseFromString(arg.pb_data)
            --print("游戏结算阶段======"..msg.endTime)
            -- game_tab.score(false,msg.endTime,msg.otherWinChairID,msg.otherWinScore,msg.areaWin,
            --     msg.cards,msg.maxCards,msg.cardTypes,msg.areaInAllScore)  		
    	elseif gameStatus == 100 then
    		--游戏准备
            --对应数据包 SceneReadyStart
            --print('gameStatus=====: '..gameStatus..' 游戏准备')
            local msg = Protol.DZNZ_GamePb_pb.SceneReadyStart()
            msg:ParseFromString(arg.pb_data)
            --print("准备阶段数据======",msg.endTime,msg.card)
            game_tab.rest(false,msg.endTime,msg.card)
    	end
    end)
end

--准备阶段
function self.registerReadyWager_NetMsg()
    H_NetMsg:addEventListener('ReadyWager',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
        local msg = Protol.DZNZ_GamePb_pb.ReadyStart()
        msg:ParseFromString(arg.pb_data)
        gametab.rest(true,msg.endTime,msg.card)
        gameStatus = 100
        --DZNZ_Main:resp_ReadyWager(msg.endTime,msg.card)
    end)
end

--下注阶段
function self.registerGameStart_NetMsg()
    H_NetMsg:addEventListener('GameStart',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
        local msg = Protol.DZNZ_GamePb_pb.GameStart()
        msg:ParseFromString(arg.pb_data)
        gametab.bets(true,msg.endTime,msg.maxSelfCanInScore)
        --DZNZ_Main:resp_GameStart(msg.endTime,msg.maxSelfCanInScore)
        DZNZ_Main:resp_GameStart()
        gameStatus = 101
    end)
end

--用户下注
function self.registerUserWager_NetMsg()
    H_NetMsg:addEventListener('UserWager',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
        local msg = Protol.DZNZ_GamePb_pb.PlaceJetton()
        msg:ParseFromString(arg.pb_data)
        DZNZ_Main:resp_PlaceJetton(msg.userid,msg.jettonArea,msg.jettonScore)
    end)
end

--结算阶段
function self.registerGameEnd_NetMsg()
    H_NetMsg:addEventListener('GameEnd',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
        local msg = Protol.DZNZ_GamePb_pb.GameEnd()
        msg:ParseFromString(arg.pb_data)
        gametab.score(true,msg.endTime,msg.otherWinChairID,msg.otherWinScore,msg.areaWin,
            msg.cards,msg.maxCards,msg.cardTypes,msg.selfWinScore,msg.selfRevenue)

        gametab.syc(msg.curselfscore, msg.otherWinChairID, msg.otherSelfScore)

        gameStatus = 102

        H_EventDispatcher:dispatchEvent({name='updateNiuZaiData'})

        --DZNZ_Main:resp_GmaEnd(msg.endTime,msg.selfWinScore,msg.selfRevenue,msg.otherWinChairID,
            --msg.otherWinScore,msg.areaWin,msg.cards,msg.maxCards,msg.cardTypes)
        -- print('--------- 结算游戏 Start ---------')
        -- print('结算时间: '..msg.endTime)
        -- print('自己输赢多少分: '..msg.selfWinScore)
        -- print('自己税收: '..msg.selfRevenue)
        -- print('其他玩家 id: '..tostring(msg.otherWinChairID))
        -- print('其他玩家 score: '..tostring(msg.otherWinScore))
        --print('自己结算后的分数: '..msg.curselfscore)
        --print('其他玩家结算后的分数: '..tostring(msg.otherSelfScore))
        -- print('可下注区域输赢(可下注区域的输赢表) 0 :输, 1：赢: '..tostring(msg.areaWin))
        -- print('牌数据 1 :左边牌(2张), 2：右边牌(2张)， 3：中间牌(5张): '..tostring(msg.cards))
        -- print('最后组成最大的牌数据 1 :左边牌(5张), 2：右边牌(5张): '..tostring(msg.maxCards))
        -- print('最后牌型 1 :左边牌, 2：右边牌: '..tostring(msg.cardTypes))
        -- print('--------- 结算游戏 End ---------')
        -- DZNZ_Main:GameEnd(msg.endTime)
    end)
end


--游戏记录
function self.registerGameRecord_NetMsg()
    H_NetMsg:addEventListener('GameRecord',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
        local msg = Protol.DZNZ_GamePb_pb.CardsRecord()
        msg:ParseFromString(arg.pb_data)        
        --print(BitAND(4257,1))        
        --print("桌面游戏走势表数组长度====",#msg.simpleWinRecords)
        Data_GameTrend = {}
        for i=1,#msg.simpleWinRecords do
            --1位为1 :红赢, 2位：蓝赢， 3位：平
            --print('游戏桌面走势表: '..i,msg.simpleWinRecords[i],BitAND(msg.simpleWinRecords[i],1),BitAND(msg.simpleWinRecords[i],2),BitAND(msg.simpleWinRecords[i],4))
            local temp = nil
            if BitAND(msg.simpleWinRecords[i],4) == 4 then 
                temp = 0
            elseif BitAND(msg.simpleWinRecords[i],1) == 1 then
                temp = 1
            elseif BitAND(msg.simpleWinRecords[i],2) == 2 then
                temp = 2
            end
            table.insert(Data_GameTrend,temp)            
        end
        DZNZ_Main:resp_GameTrend()

        --        
        Data_sptonghuarecords.count = msg.sptonghualostcount
        Data_splianpairecords.count = msg.splianpailostcount
        Data_spduizirecords.count = msg.spduizilostcount
        Data_spthlianpairecords.count = msg.spthlianpailostcount
        Data_spduiarecords.count = msg.spduialostcount
        Data_gaopaiyiduirecords.count = msg.gaopaiyiduilostcount
        Data_lianduirecords.count = msg.lianduilostcount
        Data_st_sz_threcords.count = msg.st_sz_thlostcount
        Data_hulurecords.count = msg.hululostcount
        Data_four_ths_hjrecords.count = msg.four_ths_hjlostcount

        --print("初始化(同花)连续未出次数====",msg.sptonghualostcount)
        --print("初始化(连牌)连续未出次数====",msg.splianpailostcount)
        --print("初始化(对子)连续未出次数====",msg.spduizilostcount)
        --print("初始化(同花连牌)连续未出次数====",msg.spthlianpailostcount)
        --print("初始化(对A)连续未出次数====",msg.spduialostcount)
        --print("初始化(高牌一对)连续未出次数====",msg.gaopaiyiduilostcount)
        --print("初始化(两对)连续未出次数====",msg.lianduilostcount)
        --print("初始化(三条顺子同花)连续未出次数====",msg.st_sz_thlostcount)
        --print("初始化(葫芦)连续未出次数====",msg.hululostcount)
        --print("初始化(同花顺四条皇家)连续未出次数====",msg.four_ths_hjlostcount)

        Data_sptonghuarecords.data = {}
        Data_splianpairecords.data = {}
        Data_spduizirecords.data = {}
        Data_spthlianpairecords.data = {}
        Data_spduiarecords.data = {}
        Data_gaopaiyiduirecords.data = {}
        Data_lianduirecords.data = {}
        Data_st_sz_threcords.data = {}
        Data_hulurecords.data = {}
        Data_four_ths_hjrecords.data = {}

        Data_sptonghuarecords.data = msg.sptonghuarecords
        Data_splianpairecords.data = msg.splianpairecords
        Data_spduizirecords.data = msg.spduizirecords
        Data_spthlianpairecords.data = msg.spthlianpairecords
        Data_spduiarecords.data = msg.spduiarecords
        Data_gaopaiyiduirecords.data = msg.gaopaiyiduirecords
        Data_lianduirecords.data = msg.lianduirecords
        Data_st_sz_threcords.data = msg.st_sz_threcords
        Data_hulurecords.data = msg.hulurecords
        Data_four_ths_hjrecords.data = msg.four_ths_hjrecords

        DZNZ_Main:resp_BetAreaTrend()

        --print('--------------- 黄金分割线 --------------')
        --print("弹窗游戏走势表数组长度====",#msg.winRecords)
        -- Data_CardGaneTrend = {}
        -- for i=1,#msg.winRecords do
        --     --1位 :红赢, 2位：蓝赢， 3位：平
        --     local tab_temp = {wintype=BitAND(msg.winRecords[i],1),cardtype=msg.winCardTypes[i]}
        --     --print("wintype========",BitAND(msg.winRecords[i],1))
        --     table.insert(Data_CardGaneTrend,tab_temp)
        --     -- print('走势输赢: '..i..' '..msg.winRecords[i]..' '..BitAND(msg.winRecords[i],1))
        -- end

        -- for i=1,#msg.winCardTypes do
        --     print('赢牌牌型: '..i..' '..msg.winCardTypes[i]..' '..BitAND(msg.winCardTypes[i],1))
        -- end


        --  更新持续未出记录
        -- required int32 spduialostcount = 11;             //(对A)连续未出次数
        -- required int32 hululostcount = 12;               //(葫芦)连续未出次数
        -- required int32 four_ths_hjlostcount = 13;        //(同花顺四条皇家)连续未出次数

        --DZNZ_Main:resp_NotOutRecord(msg.spduialostcount,msg.hululostcount,msg.four_ths_hjlostcount)

        --  更新今日胜负记录
        -- required int32 hongWinTimes = 4;                 //今日红赢次数
        -- required int32 lanWinTimes = 5;                  //今日蓝赢次数
        -- required int32 pingWinTimes = 6;                 //今日平赢次数
        -- required int32 spTongHuaLian_WinTimes = 7;       //今日同花连次数
        -- required int32 spDuiA_WinTimes = 8;              //今日对A次数
        -- required int32 huLu_WinTimes = 9;                //今日葫芦次数
        -- required int32 four_Ths_hj_WinTimes = 10;        //今日金刚同花顺皇家次数
        
        -- DZNZ_Main:resp_WinLoserRecord(msg.hongWinTimes,msg.lanWinTimes,msg.pingWinTimes,
        --     msg.spTongHuaLian_WinTimes,msg.spDuiA_WinTimes,msg.huLu_WinTimes,msg.four_Ths_hj_WinTimes)

    end)
end

 function BitAND(a,b)--Bitwise and
    a = tonumber(a)
    b = tonumber(b)
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

--  function BitOR(a,b)--Bitwise or
--     local p,c=1,0
--     while a+b>0 do
--         local ra,rb=a%2,b%2
--         if ra+rb>0 then c=c+p end
--         a,b,p=(a-ra)/2,(b-rb)/2,p*2
--     end
--     return c
-- end

--  function BitNOT(n)
--     local p,c=1,0
--     while n>0 do
--         local r=n%2
--         if r<1 then c=c+p end
--         n,p=(n-r)/2,p*2
--     end
--     return c
-- end



--下注失败
function self.registerUserWagerFail_NetMsg()
    H_NetMsg:addEventListener('UserWagerFail',function (arg)
        --print('下注失败')
        UIManager.AddPopTip({strTit='下注失败'})
    end)
end

--场景信息
function self.registerTableInfo_NetMsg()
    H_NetMsg:addEventListener('TableInfo',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
        local msg = Protol.DZNZ_GamePb_pb.TableInfo()
        msg:ParseFromString(arg.pb_data)
        clientusersitcondition = msg.clientusersitcondition
        DZNZ_Main:resp_CoinsInfo(msg.userLimitScore, msg.clientusersitcondition, msg.chiparr)
    end)
end

--重设记录
function self.registerClearRecord_NetMsg()
    -- H_NetMsg:addEventListener('ClearRecord',function (arg)
    -- 	print('重设记录')
    -- end)
end

--玩家列表
function self.registerUserList_NetMsg()
    H_NetMsg:addEventListener('UserList',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
        local msg = Protol.DZNZ_GamePb_pb.GetUserInfoList()
        msg:ParseFromString(arg.pb_data)
        DZNZ_Main:resp_UserList(msg.startindex,msg.totalusercount,msg.userinfo)
    end)
end

--初始化客户端占位信息
function self.registerInitUserSitInfo_NetMsg()
    H_NetMsg:addEventListener('InitUserSitInfo',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
        local msg = Protol.DZNZ_GamePb_pb.InitUserSitInfo()
        msg:ParseFromString(arg.pb_data)
        local tab_temp = msg.usersitinfo
        DZNZ_Main:UpdateUserSit(tab_temp)      
        -- DZNZ_Main:UpdateUserSit(msg.userid,msg.nickname,msg.headurl,msg.score,
        --     msg.sex,msg.sitindex)
    end)
end

--更新(主要更新金币)
function self.registerUpdateUserSitInfo_NetMsg()
    H_NetMsg:addEventListener('UpdateUserSitInfo',function (arg)
    	print('更新(主要更新金币)')
    end)
end

--新玩家占位坐下
function self.registerUserSitDown_NetMsg()
    H_NetMsg:addEventListener('UserSitDown',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
        --print('新玩家占位坐下')
        local msg = Protol.DZNZ_GamePb_pb.UserSitInfo()
        msg:ParseFromString(arg.pb_data) 
        DZNZ_Main:UpdateSitDown(msg)         
    end)
end

--客户端占位起立
function self.registeUserSitUp_NetMsg()
    H_NetMsg:addEventListener('UserSitUp',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
    	--print('--------- 客户端占位起立 Start ---------')
        local msg = Protol.DZNZ_GamePb_pb.ClientSitChair()
        msg:ParseFromString(arg.pb_data)
        DZNZ_Main:UpdateStandUp(msg)
        -- print('--------- 客户端占位起立 End ---------')
    end)
end

--结束标记
function self.registeBaseEnd_NetMsg()
    -- H_NetMsg:addEventListener('BaseEnd',function (arg)
    -- 	print('结束标记')
    -- end)
end

--大奖记录 -- 包含输赢走势
function self.registeGetBigAreaWinInfo_NetMsg()
    H_NetMsg:addEventListener('GetBigAreaWinInfo',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
        local msg = Protol.DZNZ_GamePb_pb.GetBigAreaWinInfo()
        msg:ParseFromString(arg.pb_data)
        if msg.index == 0 then
            --手牌记录
            DZNZ_Main:resp_HandCardsRecord(msg.totalscore,msg.lastcards,msg.lasttime,msg.userinfo)
        elseif msg.index == 1 then
            --牌型记录
            DZNZ_Main:resp_GameCardRecord(msg.totalscore,msg.lastcards,msg.lasttime,msg.userinfo)
        end
    end)
end

--胜负走势
function self.registeClientHistoryRecordsInfo_NetMsg()
    H_NetMsg:addEventListener('GetHistoryRecordsInfo',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
        local msg = Protol.DZNZ_GamePb_pb.GetHistoryRecord()
        msg:ParseFromString(arg.pb_data)
        Data_CardGaneTrend = {}
        for i=1,#msg.winRecords do
            --1位 :红赢, 2位：蓝赢， 3位：平
            local tab_temp = {wintype=BitAND(msg.winRecords[i],1),cardtype=msg.winCardTypes[i]}
            --print("wintype========",BitAND(msg.winRecords[i],1))
            table.insert(Data_CardGaneTrend,tab_temp)
            -- print('走势输赢: '..i..' '..msg.winRecords[i]..' '..BitAND(msg.winRecords[i],1))
        end
        --DZNZ_Main:resp_NotOutRecord(msg.spduialostcount,msg.hululostcount,msg.four_ths_hjlostcount)
        DZNZ_Main:resp_WinLoserRecord(msg.hongWinTimes,msg.lanWinTimes,msg.pingWinTimes,
                msg.spTongHuaLian_WinTimes,msg.spDuiA_WinTimes,msg.huLu_WinTimes,msg.four_Ths_hj_WinTimes)
    end)
end

--离开房间应答
function self.resp_ExitRoom()
    --print('resp_ExitRoom')
    local _SLeaveGameRespErrorCode=
    {
        [0]='成功',
        [1]='系统错误',
        [2]='用户投注中',
        [3]='用户是庄家',
    }
    H_NetMsg:addEventListener('SLeaveGameResp',function (arg)
        local msg = Protol.cmd_texas100_game_pb.SLeaveGameResp()
        msg:ParseFromString(arg.pb_data)
        --// 返回结果 0.成功 1.系统错误 2.用户投注中 3.用户是庄家
        if msg.code ~=0 then
            UIManager.AddPopTip({strTit=_SLeaveGameRespErrorCode[msg.code]})
        else
            UIManager.Show('ControllerHall')
            UIManager.Hide('ControllerDZNZ_Main')
        end
    end)
end

-- 金刚记录
function self.resp_JinGangRecordsInfo()
    H_NetMsg:addEventListener('GetJinGangRecordsInfo',function (arg)
        if GameSubType ~= GameType.DZNZ then
            return
        end
        --print("历史牌局记录")
        local msg = Protol.DZNZ_GamePb_pb.JinGangRecordsInfo()
        msg:ParseFromString(arg.pb_data)

        Data_JinGangRecord = { }

        for k, v in ipairs(msg.records) do
            if v.roundcount then
                table.insert(Data_JinGangRecord, v)
            end
        end
    end)
end

--请求退出房间
function self.req_ExitRoom()
    -- self.m_c1.selectedIndex=0
    -- local msg = Protol.cmd_texas100_game_pb.CLeaveGameReq()
    -- msg.uid = loginSucceedInfo.user_info.userid
    -- local pb_data = msg:SerializeToString()   
    -- NetManager.SendMessage(GameServerConfig.logic,'CLeaveGameReq',pb_data)\
    F_SoundManager.instance:StopPlayEffect()
    NetManager.Close(GameServerConfig.logic)
    UIManager.Show('ControllerHall')
    UIManager.Hide('ControllerDZNZ_Main')
end

--请求下注
function self.req_PlaceJetton(bet_area,bet_score)
    -- print('请求投注: '..string.format('下注区域: %s 下注分数: %s',bet_area,bet_score))
    local msg = Protol.DZNZ_GamePb_pb.C_PlaceJetton()
    msg.area = bet_area
    msg.socre = bet_score
    local pb_data = msg:SerializeToString()
    NetManager.SendNetMsg(GameServerConfig.logic,'C_PlaceJetton',pb_data)
end

--获取玩家列表
function self.req_GetUserList()
    local msg = Protol.DZNZ_GamePb_pb.C_GetUserList()
    msg.startindex = 0
    msg.maxCount = 200
    local pb_data = msg:SerializeToString()
    NetManager.SendNetMsg(GameServerConfig.logic,'C_GetUserList',pb_data)
end

--获取手牌和牌型记录
--type_id 奖池ID  0:手牌记录 1:牌型记录
function self.req_GetBigAreaWinInfo(type_id)
    local msg = Protol.DZNZ_GamePb_pb.C_GetBigAreaWinInfo()
    msg.index = type_id
    local pb_data = msg:SerializeToString()
    NetManager.SendNetMsg(GameServerConfig.logic,'C_GetBigAreaWinInfo',pb_data)
end

-- 金刚记录
function self.req_GetJinGangInfo()
    NetManager.SendNetMsg(GameServerConfig.logic,'C_GetJinGangInfo')
end

--请求坐下
function self.req_ClientSitChair(index)
    local gold = loginSucceedInfo.user_info.gold
    if tonumber(clientusersitcondition) > tonumber(gold) then
        UIManager.AddPopTip({strTit='没达到坐下标准，无法上座'})
        return 
    end
    local msg = Protol.DZNZ_GamePb_pb.ClientSitChair()
    msg.sitindex = index
    local pb_data = msg:SerializeToString()
    NetManager.SendNetMsg(GameServerConfig.logic,'ClientSitChair',pb_data)
end

--请求站起
function self.req_StandUp()
    -- local msg = Protol.DZNZ_GamePb_pb.ClientSitChair()
    -- local pb_data = msg:SerializeToString()
    NetManager.SendNetMsg(GameServerConfig.logic,'ClientStandUp')  
end

--请求历史记录
function self.req_ClientHistoryRecords()
    -- local msg = Protol.DZNZ_GamePb_pb.ClientHistoryRecords()
    -- local pb_data = msg:SerializeToString()
    NetManager.SendNetMsg(GameServerConfig.logic,'ClientHistoryRecords')
end

function self.GetCanPlaceJetton()
    return gameStatus == 101
end

-------------------------------- c - s request ------------------------------
        -- if GameSubType~=1 then
        --     return
        -- end
        -- local msg = Protol.GameBaseMsg_pb.EnterGameReponse()
        -- msg:ParseFromString(arg.pb_data)
        -- print('EnterGameReponse '..tostring(msg))

        -- self.m_mySeat_id=nil

        -- --计算玩家下注档位
        -- local _x=CalcXiaZhuLevel(loginSucceedInfo.user_info.gold)
        -- if _x<5 then
        --     _x=5
        -- end
        -- for i=5,1,-1 do
        --     local _btn=self.m_content:GetChild('btnCM'..i)
        --     _btn.text=formatVal(CM_Level_BaiRen[_x-5+i].val)
        --     _btn.data=CM_Level_BaiRen[_x-5+i].val
        -- end

        -- --进入游戏请求
        -- local msg = Protol.cmd_texas100_game_pb.CEnterGameReq()
        -- msg.uid=loginSucceedInfo.user_info.userid
        
        -- local pb_data = msg:SerializeToString()
        -- NetManager.SendMessage(GameServerConfig.logic,'CEnterGameReq',pb_data)
        -- print('CEnterGameReq')

        -- --请求坐下位置
-- function self.ClientSitChair_Req(sit_index)
--  -- body
--  -- print('请求坐下: '..sit_index)
--  -- local msg = Protol.DZNZ_GamePb_pb.ClientSitChair()
--  -- msg.sitindex = sit_index
--  -- -- msg.socre = bet_score
--  -- local pb_data = msg:SerializeToString()
--  -- NetManager.SendNetMsg(GameServerConfig.logic,'ClientSitChair',pb_data)
-- end