UI_Define={
    --通用界面
    ['ControllerMessageBox']=require("Controller/ControllerMessageBox"),
    ['ControllerWaitTip']=require("Controller/ControllerWaitTip"),
    ['ControllerPopTip']=require("Controller/ControllerPopTip"),

    --登录界面相关
    ['ControllerLogin']=require("Controller/Login/ControllerLogin"),
    ['ControllerReg']=require("Controller/Login/ControllerReg"),
    ['ControllerForgotPasswd']=require("Controller/Login/ControllerForgotPasswd"),
    ['ControllerForgotPasswd2']=require("Controller/Login/ControllerForgotPasswd2"),
    ['ControllerAccountLogin']=require("Controller/Login/ControllerAccountLogin"),

    --大厅界面
    ['ControllerHall']=require("Controller/Hall/ControllerHall"),
    --大厅追号
    ['ControllerHallZhuiHaoView'] = require("Controller/Hall/ControllerHallZhuiHaoView"),
    --大厅提示
    ['ControllerHallTips']=require("Controller/Hall/ControllerHallTips"),
    --重连提示
    ['ControllerHallConnectTips']=require("Controller/Hall/ControllerHallConnectTips"),
    --大厅仅仅描述
    ['ControllerHallDesc'] = require("Controller/Hall/ControllerHallDesc"),
    --排行榜
    ['ControllerRanking']=require("Controller/Hall/ControllerRanking"),
    ['ControllerRanking2']=require("Controller/Hall/ControllerRanking2"),
    --设置
    ['ControllerSetting']=require("Controller/Hall/ControllerSetting"),
    --个人分享游戏
    ['ControllerShare']=require("Controller/Hall/ControllerShare"),
    --财神转盘
    ['ControllerGodTurret2']=require("Controller/Hall/ControllerGodTurret2"),
    --财神转盘中奖记录
    ['ControllerLuckyTableLog']=require("Controller/Hall/ControllerLuckyTableLog"),

    --兑换码
    ['ControllerConversion']=require("Controller/Hall/ControllerConversion"),
    --活动
    ['ControllerActivity']=require("Controller/Hall/ControllerActivity"),
    -- 比赛场
    ['ControllerCompetition']=require("Controller/Hall/ControllerCompetition"),
    -- 比赛场游戏界面
    ['ControllerCompetitionWait']=require("Controller/Hall/ControllerCompetitionWait"),
    -- 比赛场的提示
    ['ControllerCompetitionTips']=require("Controller/Hall/ControllerCompetitionTips"),

    -- 预览
    ['ControllerCompetitionPreview'] = require("Controller/Hall/ControllerCompetitionPreview"),
    -- 比赛场的里面详细内容
    ['ControllerCompetitionDetail']=require("Controller/Hall/ControllerCompetitionDetail"),
    -- 比赛场成功
    ['ControllerCompetitionSuccess']=require("Controller/Hall/ControllerCompetitionSuccess"),
    -- 比赛场失败
    ['ControllerCompetitionFailure']=require("Controller/Hall/ControllerCompetitionFailure"),
    -- 详细的名次信息
    ['ControllerCompetitionResRank']=require("Controller/Hall/ControllerCompetitionResRank"),
    -- 比赛结果名次
    ['ControllerCompetitionEnd']=require("Controller/Hall/ControllerCompetitionEnd"),
    --商圈推广系统
    ['ControllerExtensionSystem']=require("Controller/Hall/ControllerExtensionSystem"),
    --商圈收入
    ['ControllerExtensionIncome']=require("Controller/Hall/ControllerExtensionIncome"),
    --客服
    ['ControllerService']=require("Controller/Hall/ControllerService"),
    --举报
    ['ControllerReport']=require("Controller/Hall/ControllerReport"),
    --留言板
    ['ControllerNote']=require("Controller/Hall/ControllerNote"),
    --消息榜
    ['ControllerMsg']=require("Controller/Hall/ControllerMsg"),
    --好友
    ['ControllerFriend']=require("Controller/Hall/ControllerFriend"),
    --好友请求
    ['ControllerFriendVerify']=require("Controller/Hall/ControllerFriendVerify"),
    --好友添加
    ['ControllerFriendAdd']=require("Controller/Hall/ControllerFriendAdd"),
    --好友礼物
    ['ControllerFriendPresented']=require("Controller/Hall/ControllerFriendPresented"),
    --背包
    ['ControllerBag']=require("Controller/Hall/ControllerBag"),
    ['ControllerBag2']=require("Controller/Hall/ControllerBag2"),
    -- 头像
    ['ControllerBagHead']=require("Controller/Hall/ControllerBagHead"),
    --修改昵称
    ['ControllerBagRename']=require("Controller/Hall/ControllerBagRename"),
    -- 头像框
    ['ControllerBagFrame']=require("Controller/Hall/ControllerBagFrame"),
    --保险箱登入
    ['ControllerSafeBoxLogin']=require("Controller/Hall/ControllerSafeBoxLogin"),
    ['ControllerSafeBoxLogin2']=require("Controller/Hall/ControllerSafeBoxLogin2"),
    --保险箱修改密码
    ['ControllerSafeBoxChangePasswd']=require("Controller/Hall/ControllerSafeBoxChangePasswd"),
    ['ControllerSafeBoxChangePasswd2']=require("Controller/Hall/ControllerSafeBoxChangePasswd2"),
    --保险箱
    ['ControllerSafeBox']=require("Controller/Hall/ControllerSafeBox"),
    ['ControllerSafeBox2']=require("Controller/Hall/ControllerSafeBox2"),
    --保险箱转账二次确定
    ['ControllerSafeBoxTransferCoinMsg']=require("Controller/Hall/ControllerSafeBoxTransferCoinMsg"),
    --绑定玩家（代理）
    ['ControllerBindPlayer']=require("Controller/Hall/ControllerBindPlayer"),
    --赠送道具
    ['ControllerGiveAway'] = require("Controller/Hall/ControllerGiveAway"),
    --绑定手机
    ['ControllerBindPhone']=require("Controller/Hall/ControllerBindPhone"),
    ['ControllerBindPhone2']=require("Controller/Hall/ControllerBindPhone2"),
    --个人信息
    ['ControllerUserInfo']=require("Controller/Hall/ControllerUserInfo"),
    ['ControllerUserInfo2']=require("Controller/Hall/ControllerUserInfo2"),
    ['ControllerUserData']=require("Controller/Hall/ControllerUserData"),
    --牌局记录
    ['ControllerUserInfoRoundRecord']=require("Controller/Hall/ControllerUserInfoRoundRecord"),
    --牌局记录详情
    ['ControllerLastreWithUserGameData']=require("Controller/Hall/ControllerLastreWithUserGameData"),
    

    --商城购买记录界面
    ['ControllerShopLog']=require("Controller/Hall/ControllerShopLog"),
    --商城界面
    ['ControllerShop']=require("Controller/Hall/ControllerShop"),

    --邮件详情界面
    ['ControllerMail']=require("Controller/Hall/ControllerMail"),

    --游戏大厅
    ['ControllerGameHall']=require("Controller/GameHall/ControllerGameHall"),
    --创建房间
    ['ControllerCreateRoom']=require("Controller/GameHall/ControllerCreateRoom"),
    --查看我创建的房间
    ['ControllerCreateRoomFromMe']=require("Controller/GameHall/ControllerCreateRoomFromMe"),
    --加入房间
    ['ControllerJoinRoom']=require("Controller/GameHall/ControllerJoinRoom"),
    --密码设置
    ['ControllerPW']=require("Controller/GameHall/ControllerPW"),

    --游戏界面
    ['ControllerTexas'] = require("Controller/Texas/ControllerTexas"),
    --游戏获得道具界面
    ['ControllerTexasGetItem'] = require("Controller/Texas/ControllerTexasGetItem"),
    --游戏内查看围观玩家
    ['ControllerOnLook']=require("Controller/Texas/ControllerOnLook"),
    --游戏内查看玩家信息
    ['ControllerPlayerInfo']=require("Controller/Texas/ControllerPlayerInfo"),
    --玩家信息->举报玩家
    ['ControllerGameReportPlayer']=require("Controller/Texas/ControllerGameReportPlayer"),
    --游戏内查看上局回顾
    ['ControllerLastre']=require("Controller/Texas/ControllerLastre"),
    --补充桌面筹码
    ['ControllerAddCM']=require("Controller/Texas/ControllerAddCM"),
    --奖池界面
    ['ControllerPrizePool']=require("Controller/Texas/ControllerPrizePool"),
    --奖池界面 中奖统计
    ['ControllerPrizePoolStatistical']=require("Controller/Texas/ControllerPrizePoolStatistical"),
    --奖池界面 中奖记录
    ['ControllerPrizePoolRecord']=require("Controller/Texas/ControllerPrizePoolRecord"),
    --奖池界面 规则
    ['ControllerPrizePoolRules']=require("Controller/Texas/ControllerPrizePoolRules"),
    --踢人界面
    ['ControllerOutPlayer']=require("Controller/Texas/ControllerOutPlayer"),
    --德州玩法说明界面
    ['ControllerDZDes']=require("Controller/Texas/ControllerDZDes"),
    --任务
    ['ControllerTask']=require("Controller/Hall/ControllerTask"),
    --AA手牌奖励
    ['ControllerGetAA'] = require("Controller/Texas/ControllerGetAA"),

    ------------------------ 牛牛百人场 -----------------------------------------------

    --视图:游戏主界面
    ['ControllerBaiRen'] = require("Controller/BaiRen/ControllerBaiRen"),

    --百人场说明界面
    ['ControllerBaiRenDes'] = require("Controller/BaiRen/ControllerBaiRenDes"),

    --百人场等待上庄界面
    ['ControllerBaiRenWaitBecomeBookmaker'] = require("Controller/BaiRen/ControllerBaiRenWaitBecomeBookmaker"),
    --百人场玩家列表
    ['ControllerBaiRenPlayerList'] = require("Controller/BaiRen/ControllerBaiRenPlayerList"),
    --百人场记录数据界面
    ['ControllerBaiRenRecord'] = require("Controller/BaiRen/ControllerBaiRenRecord"),
    --百人场奖池
    ['ControllerBaiRenPrizePool'] = require("Controller/BaiRen/ControllerBaiRenPrizePool"),
    --百人场中大奖记录
    ['ControllerBaiRenPrizePoolRecord'] = require("Controller/BaiRen/ControllerBaiRenPrizePoolRecord"),

    ------------------------ 德州牛仔 ---------------------------
    --视图:游戏主界面
    ['ControllerDZNZ_Main'] = require("Controller/DeZhouNiuZai/ControllerDZNZ_Main"),
    --视图:所有玩家列表
    ['CtrlDZNZ_AllPlayerView'] = require("Controller/DeZhouNiuZai/CtrlDZNZ_AllPlayerView"),
    --视图:保险箱
    ['CtrlDZNZ_SafeBoxView'] = require("Controller/DeZhouNiuZai/CtrlDZNZ_SafeBoxView"),
    --视图:数据走势图
    ['CtrlDZNZ_DataView'] = require("Controller/DeZhouNiuZai/CtrlDZNZ_DataView"),

    ------------------------ 牛仔追号 ---------------------------
    -- 主界面
    ['CtrlDZNZChaseMain'] = require("Controller/DeZhouNiuZai/CtrlDZNZChaseMain"),
    -- 规则
    ['CtrlDZNZChaseRule'] = require("Controller/DeZhouNiuZai/CtrlDZNZChaseRule"),
    -- 提示
    ['CtrlDZNZChaseTips'] = require("Controller/DeZhouNiuZai/CtrlDZNZChaseTips"),
    -- 结果
    ['CtrlDZNZChaseDetail'] = require("Controller/DeZhouNiuZai/CtrlDZNZChaseDetail"),
}

