-- local ControllerBaiRen_Net = class("ControllerBaiRen_Net")
-- BaiRenChang_GamePB_pb
-- BRNN_GamePb_pb
-- 192.168.1.7
CtrlBaiRenNet = {}
local self = CtrlBaiRenNet
local sceneReadyTime = 0    -- 进入游戏后的等待时间
local gameStatus = -1
local CtrlBaiRen = nil
local jackPotList = { }
local applyBankerScore      -- 上庄条件
local placeJettonMul        -- 下注倍率

function self.Init(controller_bairen)
    CtrlBaiRen = controller_bairen
	--self.registerUpdateUserSitInfo_NetMsg()
	self.registerUserSitDown_NetMsg()			-- 新玩家坐下
	self.registeUserSitUp_NetMsg()              -- 玩家起立
	self.registeEnterGameReponse_NetMsg()     	-- 进入牛牛(百人场)房间成功
	self.registerInitUserSitInfo_NetMsg()       -- 初始化占位信息
	self.registerGameReadyStart_NetMsg()        -- 约定下注的准备时间
	self.registerGameState_NetMsg()           	-- 游戏状态（公共状态）-- 重连用
	self.registerGameScene_NetMsg()           	-- 游戏场景（公共状态）-- 重连用
	self.registerGameStart_NetMsg()				-- 游戏开始
	self.registerGameEnd_NetMsg()				-- 游戏结束
	self.registerTableInfo_NetMsg()         	-- 桌子信息
	self.registerChangeBanker_NetMsg()			-- 庄家变化（游戏开始推一下，自己上下庄，不一定会改变，要排队）
	self.registerHistoryRecord_NetMsg()         -- 输赢走势
	self.registerUserList_NetMsg()              -- 玩家列表
	self.registerPlaceJetton_NetMsg()      		-- 下注
	self.registerGetBigWinPoolNum_NetMsg()      -- 大奖数字
	self.registerGetBigWinPoolUser_NetMsg()     -- 大奖玩家列表
	self.registerExitRoom()                     -- 离开房间
	self.registerApplyBankerList()              -- 上庄列表
	self:registerPlaceJettonFail()              -- 下注失败
	self.registerApplyBankerResult() 			-- 上庄情况（申请结果）
end

------------------ 请求 ------------------
-- 请求坐下
function self.Req_ApplySitDown(seat_index)
	local msg = Protol.BRNN_GamePb_pb.ClientSitChair()
	msg.sitindex = seat_index
	local pb_data = msg:SerializeToString()
	NetManager.SendNetMsg(GameServerConfig.logic,'ClientSitChair', pb_data)
end

-- 请求站立
function self.Req_ApplySitUp()
	NetManager.SendNetMsg(GameServerConfig.logic,'ClientStandUp')
end

--请求上庄
function self.Req_ApplyBanker()
	NetManager.SendNetMsg(GameServerConfig.logic,'BRNN_ApplyBankerReq')
end

--请求下庄
function self.Req_CancelBanker(userid)
	NetManager.SendNetMsg(GameServerConfig.logic,'BRNN_ExitBankerReq')
end

--请求下注
function self.Req_PlaceJetton(bet_area, bet_score)
	if placeJettonMul and placeJettonMul > 0 and placeJettonMul * bet_score > loginSucceedInfo.user_info.gold then
		UIManager.AddPopTip({ strTit = string.format("下注数的[color=#E6BC57]%s[/color]倍已超出总金币数", placeJettonMul) } )
		return
	end
	--print('请求投注: '..string.format('下注区域: %s 下注分数: %s', bet_area, bet_score))
	local msg = Protol.BRNN_GamePb_pb.C_PlaceJetton()
	msg.area = bet_area
	msg.socre = bet_score
	local pb_data = msg:SerializeToString()
	NetManager.SendNetMsg(GameServerConfig.logic,'C_PlaceJetton', pb_data)
end

-- 历史输赢纪录
function self.Req_GetHistoryRecord()
	NetManager.SendNetMsg(GameServerConfig.logic,'BRNN_HistoryRecordReq')
end

--获取玩家列表
function self.Req_GetUserList()
	local msg = Protol.BRNN_GamePb_pb.C_GetUserList()
	msg.startindex = 0
	msg.maxCount = 200
	local pb_data = msg:SerializeToString()
	NetManager.SendNetMsg(GameServerConfig.logic,'C_GetUserList', pb_data)
end

--大奖奖池数字
function self.Req_GetBigWinPoolNum()
	NetManager.SendNetMsg(GameServerConfig.logic,'BRNN_BigWinPoolNumRep')
end

--大奖玩家列表
function self.Req_GetBigWinPoolUser()
	NetManager.SendNetMsg(GameServerConfig.logic,'BRNN_BigWinPoolUserRep')
end

--请求离开房间
function self.Req_ExitRoom()
	NetManager.Close(GameServerConfig.logic)
	UIManager.Show('ControllerHall')
	UIManager.Hide('ControllerBaiRen')
end

--请求庄家列表
function self.Req_ApplyBankerList()
	NetManager.SendNetMsg(GameServerConfig.logic,'BRNN_ApplyBankerListRep')
end

------------------ 响应 ------------------
--进入牛牛(百人场)房间成功
function self.registeEnterGameReponse_NetMsg()
	H_NetMsg:addEventListener('EnterGameReponse',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		UIManager.Show('ControllerBaiRen')
	end)
end

-- 游戏开始
function self.registerGameStart_NetMsg()
	H_NetMsg:addEventListener('GameStart',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local msg = Protol.BRNN_GamePb_pb.GameStart()
		msg:ParseFromString(arg.pb_data)
		CtrlBaiRen:resp_GameStart(msg.endTime, msg.maxSelfCanInScore)
		gameStatus = 101
	end)
end

--游戏结束
function self.registerGameEnd_NetMsg()
	H_NetMsg:addEventListener('GameEnd',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		gameStatus = 102
		local msg = Protol.BRNN_GamePb_pb.GameEnd()
		msg:ParseFromString(arg.pb_data)
		if msg then
			--print("msg.endTime:"..msg.endTime)					--结算时间（秒）
			--print("msg.selfWinScore:"..msg.selfWinScore)			--自己输赢多少分
			--print("msg.selfRevenue:"..msg.selfRevenue)			--自己税收
			--print("msg.areaWin:"..msg.areaWin)					--可下注区域输赢(可下注区域的输赢表) 0 :输, 1：赢
			--msg.otherWinChairID = 4
			--msg.otherSelfScore                                    --同步金币
			--msg.otherWinScore = 5
			--msg.curselfscore = 10;								--自己身上结算后的分数
			--msg.bankerscore = 11;								    --庄家身上结算后的分数(玩家庄才有用)
			local zhuang_res = 2
			local zhuang_score = tonumber(msg.bankerwinscore)
			local chair_res_list = { }
			for i = 1, 6 do
				local res = { has_player = false, chair_id = -1, score = 0 }
				local chair_id = tonumber(msg.otherWinChairID[i])
				if chair_id then
					res.has_player = true
					res.chair_id = chair_id
					res.score = tonumber(msg.otherSelfScore[i])
				end
				table.insert(chair_res_list, res)
			end

			local count_res = 0
			local area_res_list= { }                 -- 庄家通杀(0)，庄家通赔(1), 还是有输有赢(2)
			for m = 1, 4 do
				count_res = count_res + msg.areaWin[m]
				table.insert(area_res_list, { area_id = m - 1, is_win = msg.areaWin[m] == 1 and true or false })
			end

			if count_res == 0 then   	-- 区域全输 庄家通杀(0)
				zhuang_res = 0
			elseif count_res == 4 then 	-- 区域全赢 庄家通赔(1)
				zhuang_res = 1
			else
				zhuang_res = 2          -- 庄家有输有赢(2)
			end

			local card_res_banker = { }
			local card_res_other = { }
			local card_type_banker = { }
			local card_type_other = { }
			local count = 0				--牌数据 1 :庄家5张, 2：其他4闲家顺序 各5张
			for m = 1, 5 do
				local res = {}
				for n = 1, 5 do
					count = count + 1
					res[n] = tonumber(msg.cards[count])
				end
				if m == 1 then
					card_res_banker = res
				else
					table.insert(card_res_other , res)
				end
			end

			for k = 1, 5 do				-- 共5种类型最后牌型 庄家-闲家
				if k == 1 then
					card_type_banker = msg.cardTypes[k]
				else
					table.insert(card_type_other, tonumber(msg.cardTypes[k]))
				end
			end

			CtrlBaiRen:resp_GameEnd(msg.endTime, tonumber(msg.selfWinScore), card_res_banker, card_res_other, card_type_banker, card_type_other)
			CtrlBaiRen:resp_WinLoseResult(area_res_list, chair_res_list, zhuang_res, zhuang_score, tonumber(msg.curselfscore), tonumber(msg.bankerscore))
		end
	end)
end

--初始化客户端占位信息
function self.registerInitUserSitInfo_NetMsg()
	H_NetMsg:addEventListener('InitUserSitInfo',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local index = 1
		local ply_info_list = { }
		local msg = Protol.BRNN_GamePb_pb.InitUserSitInfo()
		msg:ParseFromString(arg.pb_data)
		for k = 0, 5 do
			local res = { has_player = false, userid = 0, nickname = "", headurl = "", score = 0, sex = 0, sitindex = k }
			local user_info = msg.usersitinfo[index]
			if user_info and user_info.sitindex == k then
				--print("有玩家")
				index = index + 1
				res.has_player = true
				res.userid = user_info.userid
				res.nickname = user_info.nickname
				res.headurl = user_info.headurl
				res.score = tonumber(user_info.score)
				res.sex = user_info.sex
				res.sitindex = user_info.sitindex         -- 座位号（0-5）
			else
				--print("没有玩家")
			end
			table.insert(ply_info_list, res)
		end
		CtrlBaiRen:resp_PlayerInfo(ply_info_list)
	end)
end


--更新(主要更新金币)
function self.registerUpdateUserSitInfo_NetMsg()
	H_NetMsg:addEventListener('UpdateUserSitInfo',function (arg)
		print('更新(主要更新金币)')
	end)
end

function self.registerGameReadyStart_NetMsg()
	H_NetMsg:addEventListener('BRNN_ReadyStart',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local msg = Protol.BRNN_GamePb_pb.ReadyStart()
		msg:ParseFromString(arg.pb_data)
		CtrlBaiRen:resp_GameReady(msg.endTime, "准备中")
		gameStatus = 100
	end)
end

--游戏状态（公共状态）-- 重连用
function self.registerGameState_NetMsg()
	H_NetMsg:addEventListener('GameState',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local msg = Protol.GameBaseMsg_pb.GF_GameStatus()
		msg:ParseFromString(arg.pb_data)
		gameStatus = msg.gameStatus
	end)
end

--游戏场景（公共状态）-- 重连用
function self.registerGameScene_NetMsg()
	H_NetMsg:addEventListener('GameScene',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local des = ""
		if gameStatus == 0 then
			des = "等待玩家"
			sceneReadyTime = 99
		elseif gameStatus == 100 then
			--print('gameStatus=====: '..gameStatus..' 游戏准备')
			local msg = Protol.BRNN_GamePb_pb.SceneReadyStart()
			msg:ParseFromString(arg.pb_data)
			sceneReadyTime = msg.endTime
			des = "准备中"
		elseif gameStatus == 101 then
			des = "请下注" --print('gameStatus=====: '..gameStatus..' 游戏进行中')
			local msg = Protol.BRNN_GamePb_pb.ScenePlaceJetton()
			msg:ParseFromString(arg.pb_data)
			sceneReadyTime = msg.endTime
			--required int32 endTime = 1;				//剩下多少秒
			--repeated int64 areaInAllScore = 2; 		 // 每个区域下多少金币
			--repeated int64 meAreaInAllScore = 3;  		//自己每个区域下多少金币
			--required int64 maxSelfCanInScore = 4;		//自己最多能下多少分
			local area_score_all = {}
			local area_score_self = {}
			for k = 1, 4 do
				local all_value = msg.areaInAllScore[k]
				local self_value = msg.meAreaInAllScore[k]
				table.insert(area_score_all, all_value and tonumber(all_value) or 0)
				table.insert(area_score_self, self_value and tonumber(self_value) or 0)
			end
			CtrlBaiRen:resp_GameRunning(area_score_all, area_score_self)
		elseif gameStatus == 102 then
			des = "等待结束"
			local msg = Protol.BRNN_GamePb_pb.SceneGameEnd()
			msg:ParseFromString(arg.pb_data)
			sceneReadyTime = msg.endTime
		end
		CtrlBaiRen:resp_GameStatus(sceneReadyTime, des)

	end)
end

--桌子信息 每个玩家最多下多少金币(防止溢出)，坐在显示头像的分数限制，可以选择的下注分数，上庄条件
function self.registerTableInfo_NetMsg()
	H_NetMsg:addEventListener('TableInfo',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local msg = Protol.BRNN_GamePb_pb.TableInfo()
		msg:ParseFromString(arg.pb_data)
		if msg then
			--每个玩家最多下多少金币(防止溢出):".userLimitScore)-"坐在显示头像的分数限制:"..clientusersitcondition) 可以选择的下注分数，上庄条件:".applybankercondition)
			local user_limit = tonumber(msg.userLimitScore)
			local sit_score = tonumber(msg.clientusersitcondition)
			applyBankerScore = tonumber(msg.applybankercondition)
			placeJettonMul = tonumber(msg.maxaddlimittimes)
			CtrlBaiRen:resp_GameTableInfo(user_limit, sit_score, msg.chiparr, applyBankerScore)
		end
	end)
end

--庄家变化
function self.registerChangeBanker_NetMsg()
	H_NetMsg:addEventListener('BRNN_ChangeBanker',function (arg)
		local msg = Protol.BRNN_GamePb_pb.ChangeBanker()
		msg:ParseFromString(arg.pb_data)
		CtrlBaiRen:resp_GameChangeBanker(msg.bsystembank == 1 and true or false, msg.user)
	end)
end

--用户下注
function self.registerPlaceJetton_NetMsg()
	H_NetMsg:addEventListener('BRNN_PlaceJetton',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local msg = Protol.BRNN_GamePb_pb.PlaceJetton()
		msg:ParseFromString(arg.pb_data)
		CtrlBaiRen:resp_PlaceJetton(msg.userid, msg.jettonArea, tonumber(msg.jettonScore))
	end)
end

--新玩家占位坐下
function self.registerUserSitDown_NetMsg()
	H_NetMsg:addEventListener('UserSitDown',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local msg = Protol.BRNN_GamePb_pb.UserSitInfo()
		msg:ParseFromString(arg.pb_data)
		if string.len(msg.nickname) > 0 then
			local res =
			{
				has_player = true,
				userid = msg.userid,
				nickname = msg.nickname,
				headurl = msg.headurl,
				score = tonumber(msg.score),
				sex = msg.sex,
				sitindex = msg.sitindex,
			}
			CtrlBaiRen:resp_PlayerSitDown(res)
		end
	end)
end

--客户端占位起立
function self.registeUserSitUp_NetMsg()
	H_NetMsg:addEventListener('UserSitUp',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local msg = Protol.BRNN_GamePb_pb.ClientSitChair()
		msg:ParseFromString(arg.pb_data)
		CtrlBaiRen:resp_PlayerSitUp(msg.sitindex)
	end)
end

-- 输赢走势
function self.registerHistoryRecord_NetMsg()
	H_NetMsg:addEventListener('BRNN_HistoryRecord',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local msg = Protol.BRNN_GamePb_pb.GetHistoryRecord()
		msg:ParseFromString(arg.pb_data)
		local record_list = { }
		local length = #msg.createtime
		local count_win_and_lose = 0                                   	-- 输赢
		local count_poker_type = 0                                   	-- 牌型
		local count_poker_info = 0                                   	-- 牌信息
		for m = 1, length do
			record_list[m] = { }
			local res_win_and_lose = { }
			for n = 1, 4 do
				count_win_and_lose = count_win_and_lose + 1
				local win_result = msg.winrecords[count_win_and_lose]
				res_win_and_lose[n] = win_result and win_result or 0
			end
			record_list[m].win_and_lose = res_win_and_lose

			record_list[m].poker_info = { }
			for n = 1, 5 do
				count_poker_type = count_poker_type + 1
				record_list[m].poker_info[n] = { }
				record_list[m].poker_info[n].poker_type = msg.cardtypes[count_poker_type]
			end

			for n = 1, 5 do
				local res_in = { }
				for k = 1, 5 do
					count_poker_info = count_poker_info + 1
					res_in[k] = msg.cards[count_poker_info]
				end
				record_list[m].poker_info[n].poker_value = res_in
			end
			record_list[m].datatime = msg.createtime[m]
		end
		if #record_list > 0 then
			UIManager.Show('ControllerBaiRenRecord', record_list)
		end
	end)
end

--玩家列表
function self.registerUserList_NetMsg()
	H_NetMsg:addEventListener('UserList',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local msg = Protol.BRNN_GamePb_pb.GetUserInfoList()
		msg:ParseFromString(arg.pb_data)
		UIManager.Show('ControllerBaiRenPlayerList', msg.userinfo)
	end)
end

--大奖数字
function self.registerGetBigWinPoolNum_NetMsg()
	H_NetMsg:addEventListener('BRNN_BigWinPoolNumRes',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local msg = Protol.BRNN_GamePb_pb.GetJackPotInfo()
		msg:ParseFromString(arg.pb_data)
		CtrlBaiRen:res_BigWinNum(math.abs(tonumber(msg.curscore)))
	end)
end

--玩家列表
function self.registerGetBigWinPoolUser_NetMsg()
	H_NetMsg:addEventListener('BRNN_BigWinPoolUserRes',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		--repeated string nickname = 1;		//
		--repeated string headurl = 2;		//
		--repeated int64 winscore = 3;		//
		--repeated int64 createtime = 4;	//创建时间
		--repeated int32 cards = 5;			//牌 (每个玩家5张)
		local msg = Protol.BRNN_GamePb_pb.GetJackPotUserRecord()
		msg:ParseFromString(arg.pb_data)
		local length = #msg.createtime
		local count_poker = 0
		for m = 1, length do
			local res =
			{
				nick_name = msg.nickname[m],
				icon_url = msg.headurl[m],
				coin = msg.winscore[m],
				create_time = msg.createtime[m],
				poker_info = { },
			}
			for n = 1, 5 do
				count_poker = count_poker + 1
				res.poker_info[n] = msg.cards[count_poker]
			end
			jackPotList[m] = res
		end
	end)
end

--离开房间应答
function self.registerExitRoom()
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
		if msg.code ~=0 then
			UIManager.AddPopTip({strTit=_SLeaveGameRespErrorCode[msg.code]})
		else
			UIManager.Show('ControllerHall')
			UIManager.Hide('ControllerBaiRen')
		end
	end)
end

-- 庄家列表应答 BRNN_ApplyBankerListRep
function self.registerApplyBankerList()
	H_NetMsg:addEventListener('BRNN_ApplyBankerListRes',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local msg = Protol.BRNN_GamePb_pb.ApplyBankerList()
		msg:ParseFromString(arg.pb_data)
		UIManager.Show('ControllerBaiRenWaitBecomeBookmaker', msg.userinfo)
	end)
end

--message PlaceJettonFail
--{
--required int32 userid = 1;		    //下注玩家
--required int32 jettonArea = 2;		//下在什么区域
--required int64 jettonScore = 3;		//下多少金币
--}
-- 下注失败应答
function self.registerPlaceJettonFail()
	H_NetMsg:addEventListener('BRNN_PlaceJettonFail',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local msg = Protol.BRNN_GamePb_pb.PlaceJettonFail()
		msg:ParseFromString(arg.pb_data)
		-- userid jettonArea jettonScore
		UIManager.AddPopTip({ strTit = "下注失败" } )
	end)
end
--required int32 userid = 1;// 申请上庄玩家ID ，申请错误不返回该数据包
--required int32 applybankercount = 2;// 当前上庄人数
--上下庄结果 BRNN_ApplyBankerResultRes
function self.registerApplyBankerResult()
	H_NetMsg:addEventListener('BRNN_ApplyBankerResultRes',function (arg)
		if GameSubType ~= GameType.BRNN then
			return
		end
		local msg = Protol.BRNN_GamePb_pb.ApplyBanker()
		msg:ParseFromString(arg.pb_data)
		-- 如果列表打开，直接刷新
		if UIManager.IsShowState('ControllerBaiRenWaitBecomeBookmaker') then
			CtrlBaiRenNet.Req_ApplyBankerList()
		end
	end)
end

------------------ 展示大奖记录 ------------------
function self.ShowJackPotContent()
	if #jackPotList > 0 then
		UIManager.Hide('ControllerBaiRenPrizePool')
		UIManager.Show('ControllerBaiRenPrizePoolRecord', jackPotList)
	else
		UIManager.AddPopTip({strTit = "抱歉，暂无记录"} )
	end
end

function self.GetApplyBankerScore()
	return formatVal(applyBankerScore)
end

function self.GetCanPlaceJetton()
	return gameStatus == 101
end