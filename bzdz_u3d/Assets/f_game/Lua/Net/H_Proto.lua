--发送消息列表 (自定义的消息体,可以不塞数据)
local mCmd = 32
local game_Mcmd = 200
--桌子框架命令，一般没有游戏都会有这个消息
--框架命令(主命令)
local MDM_GF_FRAME = 100
local match_Mcmd = 400    -- 比赛

CMD_Send_Map =
{
    ['UserChat']={Scmd=0x4F},--玩家聊天

    ['EnterGameRequst']={Mcmd=mCmd,Scmd=0x11},--玩家请求进入游戏
    ['BeReadyBroadcast']={Mcmd=mCmd,Scmd=0x13},--玩家准备请求
    ['UserSitdownRequst']={Mcmd=mCmd,Scmd=0x14},--用户请求坐下
    ['UserSitupBroadcast']={Mcmd=mCmd,Scmd=0x15},--用户请求站起 
    ['ExitGameBroadcast']={Mcmd=mCmd,Scmd=0x16},--玩家请求退出游戏返回大厅请求
    ['ServerRoomInfoRequst']={Mcmd=mCmd,Scmd=0x20},--桌子信息

    ['ClientPing']={Mcmd=mCmd,Scmd=0x21},--心跳

    ['QiPaiReq']={Mcmd=mCmd,Scmd=0x50},--玩家弃牌
    ['GenZhuReq']={Mcmd=mCmd,Scmd=0x51},
    ['JiaZhuReq']={Mcmd=mCmd,Scmd=0x52},
    ['AllInReq']={Mcmd=mCmd,Scmd=0x53},
    ['GuoPaiReq']={Mcmd=mCmd,Scmd=0x54},
    ['GamePreOperate']={Mcmd=mCmd,Scmd=0x62},

    ['CardsReviewRequest']={Mcmd=mCmd,Scmd=0x63},--牌局回顾

    ['CreateTable']={Mcmd=mCmd,Scmd=0x64},--VIP桌子创建 
    ['TablePwdValidate']={Mcmd=mCmd,Scmd=0x65},--桌子密码验证 
    ['VipTableSearchRequst']={Mcmd=mCmd,Scmd=0x66},--桌子查找 
    ['IsPublicCardsRequest']={Mcmd=mCmd,Scmd=0x70},--玩家是否显示手牌 
    ['ChargeGoldRequest']={Mcmd=mCmd,Scmd=0x71},--玩家补充筹码 

    ['GuessHandCardsRequest']={Mcmd=mCmd,Scmd=0x80},--下注

    ['TPersonCardRequest']={Mcmd=mCmd,Scmd=0x82},--踢人请求

    ['UserInteractionRequest']={Mcmd=mCmd,Scmd=0x83},--使用打赏或者交互道具

    --百人场
    --['CEnterGameReq']={Mcmd=mCmd,Scmd=0x1080},--进入游戏请求 (上行) cmd_texas_game.proto->CEnterGameReq
    --['CLeaveGameReq']={Mcmd=mCmd,Scmd=0x1083},--离开游戏请求 (上行) cmd_texas_game.proto->CLeaveGameReq
    --['CSitDownReq']={Mcmd=mCmd,Scmd=0x1085},--玩家坐下请求 (上行) cmd_texas_game.proto->CSitDownReq
    --['CStandUpReq']={Mcmd=mCmd,Scmd=0x1087},--玩家站起请求 (上行) cmd_texas_game.proto->CStandUpReq
    --['CBetReq']={Mcmd=mCmd,Scmd=0x1091},--投注请求 (上行) cmd_texas_game.proto->CBetReq
    --['CApplyBankerReq']={Mcmd=mCmd,Scmd=0x1094},--上庄申请请求 (上行) cmd_texas_game.proto->CApplyBankerReq
    --['CGetApplyBankerListReq']={Mcmd=mCmd,Scmd=0x1096},--获取上庄申请列表请求 (上行) cmd_texas_game.proto->CGetApplyBankerListReq
    --['CExitBankerReq']={Mcmd=mCmd,Scmd=0x1098},--用户下庄请求 (上行) cmd_texas_game.proto->CExitBankerReq
    --['CGetUserListReq']={Mcmd=mCmd,Scmd=0x1102},--获取用户列表请求 (上行) cmd_texas_game.proto->CGetUserListReq
    --['CMD_GAME_BALANCE_TREND_REQ']={Mcmd=mCmd,Scmd=0x1106},--输赢走势请求 (上行) 空
    --['CMD_GAME_ROUND_LOOKBACK_REQ']={Mcmd=mCmd,Scmd=0x1108},--牌局回顾请求 (上行) 空


    --------- JOKER CODE ------------------------------------
    --请求下注
    ['C_PlaceJetton'] = {Mcmd = game_Mcmd, Scmd = 1},

    --获取玩家列表
    ['C_GetUserList'] = {Mcmd = game_Mcmd, Scmd = 2},

    --请求坐下
    ['ClientSitChair'] = {Mcmd = game_Mcmd, Scmd = 6},

    --获取手牌和牌型记录
    ['C_GetBigAreaWinInfo'] = {Mcmd = game_Mcmd, Scmd = 10},

    --请求获取金刚记录
    ['C_GetJinGangInfo'] = { Mcmd = game_Mcmd, Scmd = 12 },

    --追号-请求追号记录
    ['DZNZ_RequestZhuiHaoInfo'] = { Mcmd = game_Mcmd, Scmd = 13 },
    --追号-追号订单创建
    ['DZNZ_RequestCreateZhuiHao'] = { Mcmd = game_Mcmd, Scmd = 14 },
    --追号-追号追加
    ['DZNZ_RequestAddZhuiHao'] = { Mcmd = game_Mcmd, Scmd = 15 },
    --追号-追号取消
    ['DZNZ_RequestCancelZhuiHao'] = { Mcmd = game_Mcmd, Scmd = 16 },
    --请求的追号记录
    ['DZNZ_RequestZhuiHaoHistory'] = { Mcmd = game_Mcmd, Scmd = 17 },

    --请求站起
    ['ClientStandUp'] = {Mcmd = game_Mcmd, Scmd = 7},

    --请求历史记录
    ['ClientHistoryRecords'] = {Mcmd = game_Mcmd, Scmd = 11},
    ---------------------------------------------------------
    --点击查看玩家信息 ClickShowPlayerInfo
    ['RequestClickShowPlayerInfo'] = { Mcmd = mCmd, Scmd = 0x85}, --点击头像查看信息
    --新的百人场-上庄
    ['BRNN_ApplyBankerReq'] = { Mcmd=game_Mcmd, Scmd = 3 }, --上庄申请请求
    ['BRNN_ExitBankerReq'] = { Mcmd=game_Mcmd, Scmd = 4 },  --用户下庄请求
    ['BRNN_HistoryRecordReq'] = { Mcmd = game_Mcmd, Scmd = 11 }, -- 请求历史记录
    ['BRNN_BigWinPoolNumRep'] = { Mcmd = game_Mcmd, Scmd = 9 },       -- 请求奖池
    ['BRNN_BigWinPoolUserRep'] = { Mcmd = game_Mcmd, Scmd = 10 },       -- 请求奖池
    ['BRNN_ApplyBankerListRep'] = { Mcmd = game_Mcmd, Scmd = 5 }, -- 上庄列表

    --德州扑克，请求查看剩余牌（弃牌后）
    ['DZPK_RequestLookRemainCard'] = { Mcmd = game_Mcmd, Scmd = 0X89},
    --德州扑克，猜手牌
    ['DZPK_RequestGuessCard'] = { Mcmd = game_Mcmd, Scmd = 150},
    --德州扑克，红包结果
    ['DZPK_RequestHongBao'] = { Mcmd = game_Mcmd, Scmd = 152},
    --德州扑克，查看该玩家的手牌
    ['DZPK_RequestSeeOtherCard'] = { Mcmd = game_Mcmd, Scmd = 155},
    --德州扑克，切换玩家的手牌
    ['DZPK_RequestChangeHandCard'] = { Mcmd = game_Mcmd, Scmd = 157},
    -- 比赛场进入游戏
    ['Match_EnterGame'] = { Mcmd = match_Mcmd, Scmd = 1},
    -- 比赛场退出游戏
    ['Match_ExitGame'] = { Mcmd = match_Mcmd, Scmd = 2},
    -- 比赛场详细信息
    ['Match_ReqDetail'] = { Mcmd = match_Mcmd, Scmd = 11},
    -- 比赛场购买
    ['Match_ReqUserBuyScore'] = { Mcmd = match_Mcmd, Scmd = 12},
    -- 比赛场换桌
    ['Match_ReqChangeTable'] = { Mcmd = match_Mcmd, Scmd = 14},
}

--接收消息列表
CMD_Receive_Map =
{
    ['PushErrorMsg']={Mcmd=mCmd,Scmd=0x19},--错误推送
    ['UserChat']={Mcmd=mCmd,Scmd=0x4F},--玩家聊天
    ['ErrorMsg']={Mcmd=mCmd,Scmd=0x10},--客户端请求错误返回
    ['EnterGameReponse']={Mcmd=mCmd,Scmd=0x11},--玩家登录返回
    ['EnterGameBroadcast']={Mcmd=mCmd,Scmd=0x12},--广播玩家进入游戏
    ['BeReadyBroadcast']={Mcmd=mCmd,Scmd=0x13},--广播玩家准备
    ['UserSitdownBroadcast']={Mcmd=mCmd,Scmd=0x14},--广播用户坐下
    ['UserSitupBroadcast']={Mcmd=mCmd,Scmd=0x15},--广播用户站起
    ['ExitGameBroadcast']={Mcmd=mCmd,Scmd=0x16},--广播玩家退出游戏返回大厅广播
    ['UserStatusBroadcast']={Mcmd=mCmd,Scmd=0x17},--玩家状态
    ['ServerRoomInfoReponse']={Mcmd=mCmd,Scmd=0x20},--桌子信息

    ['ClientPing'] = {Mcmd=mCmd,Scmd=0x21},--心跳

    ['GameReadyBroacast']={Mcmd=mCmd,Scmd=0x57},
    ['GameStartBroacast']={Mcmd=mCmd,Scmd=0x58},
    ['FaShouPai']={Mcmd=mCmd,Scmd=0x55},

    ['GameOverBroadcast']={Mcmd=mCmd,Scmd=0x60},

    ['QiPaiBroadcast']={Mcmd=mCmd,Scmd=0x50},--玩家弃牌广播
    ['GenZhuBroadcast']={Mcmd=mCmd,Scmd=0x51},
    ['JiaZhuBroadcast']={Mcmd=mCmd,Scmd=0x52},
    ['AllInBroadcast']={Mcmd=mCmd,Scmd=0x53},
    ['GuoPaiBroadcast']={Mcmd=mCmd,Scmd=0x54},

    ['PushRecoverScene']={Mcmd=mCmd,Scmd=0x5a},
    ['FaZhuoZiPaiBroadcast']={Mcmd=mCmd,Scmd=0x56},
    ['AllUserAllInCards'] = {Mcmd=mCmd,Scmd = 0X87 },  -- 所有玩家 all in
    ['BianChiBroadcast']={Mcmd=mCmd,Scmd=0x59},

    ['CardsReviewRespone']={Mcmd=mCmd,Scmd=0x63},--牌局回顾

    ['CreateTableResponse']={Mcmd=mCmd,Scmd=0x64},--VIP桌子创建
    ['TableValidateResponse']={Mcmd=mCmd,Scmd=0x65},--桌子密码验证 
    ['VipTableSearchResponse']={Mcmd=mCmd,Scmd=0x66},--桌子查找 

    ['GuessHandCardsResponse']={Mcmd=mCmd,Scmd=0x80},--下注返回
    ['GuessHandCardsWinNotice']={Mcmd=mCmd,Scmd=0x81},--玩家猜手牌中奖通知
    ['TPersonCardResponse']={Mcmd=mCmd,Scmd=0x82},--踢人反馈

    ['UserInteractionResponse']={Mcmd=mCmd,Scmd=0x83},--使用打赏或者交互道具

    ['UserWinJackPotBroadcast']={Mcmd=mCmd,Scmd=0x84},--奖池广播

    ------------------ 新的错误消息 ---------------------

    ['GFGameMsg']={ Mcmd = MDM_GF_FRAME, Scmd = 3},--新的客户端请求错误返回

    --点击查看玩家信息 ClickShowPlayerInfo
    ['RespondClickShowPlayerInfo'] = { Mcmd = mCmd, Scmd = 0x85}, --点击头像查看信息

    ------------------ 德州牛仔 ---------------------
    --游戏状态:100
    ['GameState'] = {Mcmd = MDM_GF_FRAME,Scmd = 1},
    --游戏场景
    ['GameScene'] = {Mcmd = MDM_GF_FRAME,Scmd = 2},
    --退出房间
    ['SLeaveGameResp'] = {Mcmd = mCmd, Scmd = 21},
    --游戏命令 主命令:200
    --准备下注
    ['ReadyWager'] = {Mcmd = game_Mcmd, Scmd = 1},
    --游戏开始
    ['GameStart'] = {Mcmd = game_Mcmd, Scmd = 2},
    --用户下注
    ['UserWager'] = {Mcmd = game_Mcmd, Scmd = 3},
    --游戏结束
    ['GameEnd'] = {Mcmd = game_Mcmd, Scmd = 4},
    --游戏记录
    ['GameRecord'] = {Mcmd = game_Mcmd, Scmd = 5},
    --下注失败
    ['UserWagerFail'] = {Mcmd = game_Mcmd, Scmd = 6},
    --场景信息
    ['TableInfo'] = {Mcmd = game_Mcmd, Scmd = 11},
    --重设记录
    ['ClearRecord'] = {Mcmd = game_Mcmd, Scmd = 12},
    --玩家列表
    ['UserList'] = {Mcmd = game_Mcmd, Scmd = 13},
    --初始化客户端占位信息
    ['InitUserSitInfo'] = {Mcmd = game_Mcmd, Scmd = 14},
    --更新(主要更新金币)
    ['UpdateUserSitInfo'] = {Mcmd = game_Mcmd, Scmd = 15},
    --新玩家占位坐下
    ['UserSitDown'] = {Mcmd = game_Mcmd, Scmd = 16},
    --客户端占位起立
    ['UserSitUp'] = {Mcmd = game_Mcmd, Scmd = 17},
    --结束标记
    ['BaseEnd'] = {Mcmd = game_Mcmd, Scmd = 18},
    -- --大奖记录
    ['GetBigAreaWinInfo'] = {Mcmd = game_Mcmd, Scmd = 20},
    -- 收到历史记录
    ['GetHistoryRecordsInfo'] = {Mcmd = game_Mcmd, Scmd = 21},
    --获取金刚记录
    ['GetJinGangRecordsInfo'] = { Mcmd = game_Mcmd, Scmd = 22 },

    --追号-追号记录
    ['DZNZ_ReceiveZhuiHaoInfo'] = { Mcmd = game_Mcmd, Scmd = 23 },
    ['DZNZ_ReceiveCreateZhuiHao'] = { Mcmd = game_Mcmd, Scmd = 24 },
    ['DZNZ_ReceiveAddZhuiHao'] = { Mcmd = game_Mcmd, Scmd = 25 },
    ['DZNZ_ReceiveCancelZhuiHao'] = { Mcmd = game_Mcmd, Scmd = 26 },
    ['DZNZ_ReceiveZhuiHistory'] = { Mcmd = game_Mcmd, Scmd = 27 },   -- 点击一次查看一次追号结果列表
    ['DZNZ_ReceiveZhuiWinMoney'] = { Mcmd = game_Mcmd, Scmd = 28 },

    ------------------ 百人场 ---------------------
    ['BRNN_ReadyStart'] = { Mcmd = game_Mcmd, Scmd = 1 },
    ['BRNN_PlaceJetton'] = { Mcmd = game_Mcmd, Scmd = 3 },
    ['BRNN_ChangeBanker'] = { Mcmd = game_Mcmd, Scmd = 9 },
    ['BRNN_HistoryRecord'] = { Mcmd = game_Mcmd, Scmd = 21 },
    ['BRNN_BigWinPoolNumRes'] = { Mcmd = game_Mcmd, Scmd = 19 },
    ['BRNN_BigWinPoolUserRes'] = { Mcmd = game_Mcmd, Scmd = 20 },
    ['BRNN_ApplyBankerResultRes'] = { Mcmd = game_Mcmd, Scmd = 7 },    -- 上下庄结果
    ['BRNN_ApplyBankerListRes'] = { Mcmd = game_Mcmd, Scmd = 10 },     -- 上庄列表
    ['BRNN_PlaceJettonFail'] = { Mcmd = game_Mcmd, Scmd = 6 },         -- 下注失败
    -- ['SEnterGameResp']={Mcmd=game_Mcmd,Scmd=0x1081},--进入房间失败应答 (下行) cmd_texas_game.proto->SEnterGameFaildResp
    -- ['SUpdateGameScene']={Mcmd=game_Mcmd,Scmd=0x1082},--场景下发 (下行) cmd_texas100_game.proto->SUpdateGameScene
    -- ['SLeaveGameResp']={Mcmd=game_Mcmd,Scmd=0x1084},--离开游戏应答 (下行) cmd_texas_game.proto->SLeaveGameResp
    -- ['SSitDownResp']={Mcmd=game_Mcmd,Scmd=0x1086},--玩家坐下应答 (下行) cmd_texas_game.proto->SSitDownResp
    -- ['SStandUpResp']={Mcmd=game_Mcmd,Scmd=0x1088},--玩家站起应答 (下行) cmd_texas_game.proto->SStandUpResp
    -- ['SUpdatePlayerOnlineState']={Mcmd=mCmd,Scmd=0x1089},--座位玩家在线状态 (下行) cmd_texas_game.proto->SUpdatePlayerOnlineState
    -- ['SGameStatusChg']={Mcmd=game_Mcmd,Scmd=0x1090},--游戏状态改变通知 (下行) cmd_texas_game.proto->SGameStatusChg
    -- ['SBetResp']={Mcmd=game_Mcmd,Scmd=0x1092},--投注应答 (下行) cmd_texas_game.proto->SBetResp
    -- ['SUpdateBetInfo']={Mcmd=game_Mcmd,Scmd=0x1093},--更新投注信息广播 (下行) cmd_texas_game.proto->SUpdateBetInfo
    -- ['SApplyBankerResp']={Mcmd=game_Mcmd,Scmd=0x1095},--上庄申请应答 (下行) cmd_texas_game.proto->SApplyBankerResp
    -- ['SGetApplyBankerListResp']={Mcmd=game_Mcmd,Scmd=0x1097},--获取上庄申请列表应答 (下行) cmd_texas_game.proto->SGetApplyBankerListResp
    -- ['SExitBankerResp']={Mcmd=game_Mcmd,Scmd=0x1099},--用户下庄应答 (下行) cmd_texas_game.proto->SExitBankerResp
    -- ['SBankerChangeNofity']={Mcmd=game_Mcmd,Scmd=0x1100},--庄家变更通知 (下行) cmd_texas_game.proto->SBankerChangeNofity
    -- ['SBetSettle']={Mcmd=game_Mcmd,Scmd=0x1101},--投注结算广播 (下行) cmd_texas_game.proto->SBetSettle
    -- ['SGetUserListResp']={Mcmd=game_Mcmd,Scmd=0x1103},--获取用户列表应答 (下行) cmd_texas_game.proto->SGetUserListResp
    -- ['SBalanceResp']={Mcmd=game_Mcmd,Scmd=0x1107},--输赢走势应答 (下行) cmd_texas_game.proto->SBalanceResp
    -- ['SRoundLookbackResp']={Mcmd=game_Mcmd,Scmd=0x1109},--牌局回顾应答 (下行) cmd_texas_game.proto->SRoundLookbackResp

    --德州扑克，接收查看剩余牌（弃牌后）
    ['DZPK_ReceiveLookCost'] = { Mcmd = mCmd, Scmd = 0X88},
    ['DZPK_ReceiveLookCard'] = { Mcmd = mCmd, Scmd = 0X89},
    --德州扑克，猜手牌结果
    ['DZPK_ReceiveGuessCard'] = { Mcmd = mCmd, Scmd = 151},
    --德州扑克，红包结果
    ['DZPK_ReceiveHongBao'] = { Mcmd = mCmd, Scmd = 152},
    --德州扑克-收到道具掉落
    ['DZPK_ReceiveUserGetGood'] = { Mcmd = mCmd, Scmd = 153 },
    --德州扑克-主动收到--更新可以看手牌的玩家列表
    ['DZPK_ReceiveUpdateSeeOtherCard'] = { Mcmd = mCmd, Scmd = 154},
    --德州扑克-收到其它玩家的手牌的卡片信息
    ['DZPK_ReceiveSeeOtherCardResult'] = { Mcmd = mCmd, Scmd = 155},
    --德州扑克-换手牌的信息，进场景主动推送
    ['DZPK_ReceiveChangeHandCardFeeInfo'] = { Mcmd = mCmd, Scmd = 156},
    --德州扑克-换手牌的结果
    ['DZPK_ReceiveChangeHandCardResult'] = { Mcmd = mCmd, Scmd = 157},
    --德州扑克-收到AA结果
    ['DZPK_ReceiveRewardAA'] = { Mcmd = mCmd, Scmd = 160},

    -- 比赛场详细信息
    ['Match_ReceiveCurtInfo'] = { Mcmd = match_Mcmd, Scmd = 11},
    -- 比赛场-状态 -- 等待开始场景
    ['Match_ReceiveWaitScene'] = { Mcmd = match_Mcmd, Scmd = 3},
    -- 比赛场-状态 -- 已经开始场景
    ['Match_ReceivePlayScene'] = { Mcmd = match_Mcmd, Scmd = 4},
    --比赛场-更新比赛玩家数量
    ['Match_ReceiveUpdateUserCount'] = { Mcmd = match_Mcmd, Scmd = 5},
    --比赛场-更新比赛底分
    ['Match_ReceiveUpdateCellScore'] = { Mcmd = match_Mcmd, Scmd = 6},
    --比赛场-换桌通知
    ['Match_ReceiveUpdateChangeTable'] = { Mcmd = match_Mcmd, Scmd = 7},
    --比赛场-是否可以购买-实时更新
    ['Match_ReceiveUpdateBuyScore'] = { Mcmd = match_Mcmd, Scmd = 8},
    --比赛场-购买成功返回
    ['Match_ReceiveBuyScoreRes'] = { Mcmd = match_Mcmd, Scmd = 12},
    -- 比赛场刷新
    ['Match_ReceiveMatchStageChange'] = { Mcmd = match_Mcmd, Scmd = 15},
    -- 被淘汰
    ['Match_ReceiveUserExitMatch'] = { Mcmd = match_Mcmd, Scmd = 9},
    -- 比赛结束
    ['Match_ReceiveGameEnd'] = { Mcmd = match_Mcmd, Scmd = 10},
}