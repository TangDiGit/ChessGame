--比赛场
local ControllerCompetition = class("ControllerCompetition")

function ControllerCompetition:Init()
    self.m_view = UIPackage.CreateObject('competition', 'hotGameMainView').asCom
    UIManager.normal:AddChild(self.m_view)
    UIManager.AdaptiveAllotypy(self.m_view)     -- 适配刘海屏水滴屏
    --self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height) btn_exit
    self.m_view.visible = false
    self.m_content = self.m_view:GetChild('content')

    self.m_rulePageBtn = self.m_content:GetChild("game_rule"):GetChild("btn_page")
    self.m_rulePageSlt = self.m_content:GetChild("game_rule"):GetController('page')

    self.m_best_rank = self.m_content:GetChild("self_best_rank")

    self.coin_num = self.m_view:GetChild('coin_num')
    self.m_cd_time = 0

    self:InitHotCompetitionList()
    self:InitMyCompetitionList()
    self:InitResCompetitionList()
    self:InitRewardCompetitionList()   -- 奖品列表

    -- 外面
    self.m_view:GetChild("btn_exit").onClick:Add(function ()
        UIManager.Hide('ControllerCompetition')
    end)

    self.m_content:GetChild("btn_hot").onClick:Add(function ()
        self:RequestHotCompetitionList()
    end)

    self.m_content:GetChild("btn_res").onClick:Add(function ()
        self:RequestResCompetitionList()
    end)

    self.m_content:GetChild("btn_reward").onClick:Add(function ()

    end)

    -- 1.刷新金币
    H_EventDispatcher:addEventListener('refreshSelfMoney',function (arg)
        self.coin_num.text = formatVal(tonumber(loginSucceedInfo.user_info.gold))
    end)

    -- 2.收到消息 - 强制刷新比赛信息
    --required int32 matchid = 1; //比赛ID
    --required int32 matchstage = 2; //修改状态
    --H_NetMsg:addEventListener('Match_ReceiveMatchStageChange',function (arg)
        --local msg = Protol.DzMatchPb_pb.MatchStageChange()
        --msg:ParseFromString(arg.pb_data)
        --print("111111")
        --if self.m_content.visible then
        --    print("22222")
        --    self:RequestHotCompetitionList()
        --end
    --end)

    self.m_rulePageBtn.onClick:Add(function ()
        if self.m_rulePageSlt.selectedIndex == 0 then
            self.m_rulePageBtn.text = "上一页"
            self.m_rulePageSlt.selectedIndex = 1
        elseif self.m_rulePageSlt.selectedIndex == 1 then
            self.m_rulePageBtn.text = "下一页"
            self.m_rulePageSlt.selectedIndex = 0
        end
    end)

    self.longhuObj = UIManager.SetDragonBonesAniObjPos('longhudouOBJ', self.m_content:GetChild("longhuPos"), Vector3.New(150,150,150)).gameObject
end

function ControllerCompetition:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true
    self:ShowLongHuAni()

    self:RequestHotCompetitionList()

    self:ShowRewardCompetitionList()

    self.coin_num.text = formatVal(tonumber(loginSucceedInfo.user_info.gold))
end

function ControllerCompetition:ShowLongHuAni()
    self:PlayAni(self.longhuObj, "animation3", false)
    self.m_ani_cd = Timer.New(function ()
        self.longhuObj:SetActive(false)
    end, 3, 1):Start()
end

function ControllerCompetition:PlayAni(spine_anim, anim_name, is_loop)
    spine_anim:SetActive(true)
    local skeleton_anim = spine_anim:GetComponent('Spine.Unity.SkeletonAnimation')
    skeleton_anim.skeleton:SetToSetupPose()
    skeleton_anim.state:ClearTracks()
    skeleton_anim.state:SetAnimation(0, anim_name, is_loop)
end

function ControllerCompetition:CloseAniCd()
    if self.m_ani_cd then
        self.m_ani_cd:Stop()
        self.m_ani_cd = nil
    end
end

---------------------------------------------------------------------------------
----------------------------------- 热门赛事 --------------------------------------
function ControllerCompetition:RequestHotCompetitionList()
    UIManager.Show('ControllerWaitTip')
    self.m_hotCompetitionList.numItems = 0
    self.m_hotCompetitionData = nil

    self.m_myCompetitionList.numItems = 0
    self.m_myCompetitionData = nil

    coroutine.start(GameCompetitionInfo, {
        callbackSuccess = function(info)
            UIManager.Hide('ControllerWaitTip')
            self:ResponseHotCompetitionList(info)
        end
    })
end

-- 比赛信息展示
function ControllerCompetition:SetCompetitionItemView(_com, _data)
    local is_free = tonumber(_data.canSaiFei) + tonumber(_data.fuWuFei) == 0
    -- 报名费的说明，由后端控制
    local desc = _data.baoMingFeiTitle
    local cost_str
    if string.len(desc) > 0 then
        cost_str = desc
    else
        if tonumber(_data.matchType) == 9 then
            cost_str = "电影(比赛卡)"
        elseif _data.hasBisaiCard and _data.hasBisaiCard > 0 then
            cost_str = "免费(比赛卡)"
        else
            cost_str = is_free and "免费" or string.format("%s+%s", formatVal(_data.canSaiFei), formatVal(_data.fuWuFei))
        end
    end

    -- 附上值，详解也要用
    _data.costDesc = cost_str

    -- startTime:2021-02-22 22:08:0
    --local split_start_time = string.split(_data.startTime, " ")
    --local split_month_time = string.split(split_start_time[1], "-")
    --local month_str = string.format("%s月%s日", split_month_time[2], split_month_time[3])-- 1:换成每周六 周日
    --local seconds_str = string.split(split_start_time[2], ":")
    --string.format("%s:%s", seconds_str[1], seconds_str[2])
    --month_str 换成每周六 周日
    local open_data = string.split(_data.startTimeTitle, ",")
    _com:GetChild("open_month").text = open_data[1]
    _com:GetChild("open_seconds").text = open_data[2]
    _com:GetChild("game_name").text = ""
    _com:GetChild("people_count").text = _data.userCount
    _com:GetChild("coin_cost").text = cost_str
    _com:GetChild("way_r").visible = tonumber(_data.rebuyCount) >= 1
    _com:GetChild("way_a").visible = tonumber(_data.addonCount) >= 1

    -- 1：比赛状态
    -- 开始时间 （定点的）
    --"matchStage": "4",			//游戏状态 1, s显示 不能报名 2.s可以报名 3. s进场 4.s比赛中
    --"baoMing": 1				    //自己是否报名 0 没报名 1.已报名
    -- game_state 0 未开放 1 已报名（可取消） 2 可报名 3 可观战 4 可以进去（桌子）
    --print("_data.title".._data.title)
    --print("_data.matchStage:".._data.matchStage)
    --print("_data.baoMing:".._data.baoMing)
    local game_state_slt_index = 0
    local match_stage_num = tonumber(_data.matchStage)
    local has_sing_up = tonumber(_data.baoMing) == 1  --自己是否报名 0 没报名 1.已报名
    _com:GetChild("open_time").text = ""
    if match_stage_num == 1 then        -- 1.显示 不能报名
        if has_sing_up then
            game_state_slt_index = 1    -- 已报名
        else
            game_state_slt_index = 0    -- 未开放
            -- 3:赛前开放
            if _data.baoMingTimeDelayBefore then
                _com:GetChild("open_time").text = string.format("赛前%s开放", GetTimeTextDayHourMinSec(_data.baoMingTimeDelayBefore))
            else
                _com:GetChild("open_time").text = ""
            end
        end
    elseif match_stage_num == 2  then   -- 2.s可以报名
        if has_sing_up then
            game_state_slt_index = 1    -- 已报名
        else
            game_state_slt_index = 2    -- 可以报名
        end
    elseif match_stage_num == 3  then   -- 3.进场
        game_state_slt_index = 4
    elseif match_stage_num == 4  then   -- 4.观战
        game_state_slt_index = 3
    end
    _com:GetController('game_state').selectedIndex = game_state_slt_index
    -- 2：比赛类型
    -- game_type 0 金币 1 免费 2 实物
    local match_type_cfg = Match_Type[tonumber(_data.matchType)]
    _com:GetController('game_type').selectedIndex = match_type_cfg.type_index

    -- 3：比赛名字
    _com:GetController('game_name').selectedIndex = match_type_cfg.name_index

    --rebuyMaxLevel 盲注 15 之前，可以重购买
    --rebuyExpendScore
    --  "award": "1,100000（金币数）, 0（道具id 1：是手机 2；是xx）, 0（道具数量）; 2,50000,0,0;3,20000,0,0",
    -- 4 - 10 "1, 100000,没有道具
    -- cellUpList 升盲（自动升级）
    -- 升盲时间 cellScoreUpTime
    -- 赛前6小时开放 open_time

    -- 预览按钮
    local btn_preview = _com:GetChild("btn_preview").asButton
    btn_preview:RemoveEventListeners()
    btn_preview.onClick:Add(function ()
        UIManager.Show('ControllerCompetitionPreview', _data)
    end)
    
    -- 1.按钮 - 报名
    local _btnSignUp = _com:GetChild("btn_sign_up").asButton
    _btnSignUp:RemoveEventListeners()
    _btnSignUp.onClick:Add(function ()
        if tonumber(_data.matchType) == 9 and _data.hasDianYingBiSaiCard == 0 then
            UIManager.AddPopTip({strTit = "亲爱的玩家，您没有电影比赛卡，暂时无法报名" })
            return
        end
        UIManager.Show('ControllerCompetitionTips', { title = "", content = "确定要报名吗？", confirm = function()
            coroutine.start(GameCompetitionSignUp, {
                matchID = _data.matchID,
                callbackSuccess = function(info)
                    local title = string.format("[color=#FFB400]%s[/color]", "报名成功")
                    local content = string.format("赛事名称：%s\r\n报名费用：%s\r\n开赛时间：[color=#FFB400]%s[/color]",
                            _data.title,
                            cost_str,
                            string.format("%s-%s", open_data[1], open_data[2]))
                    UIManager.Show('ControllerCompetitionTips', { title = title, content = content } )
                    setSelfMoney(tonumber(info.gold))
                    self:RequestHotCompetitionList()
                end
            })
        end } )
    end)

    -- 2.按钮 - 取消报名
    local _btnCancel = _com:GetChild("btn_cancel").asButton
    _btnCancel:RemoveEventListeners()
    _btnCancel.onClick:Add(function ()
        UIManager.Show('ControllerCompetitionTips', { title = "", content = "确定要取消报名吗？", confirm = function()
            coroutine.start(GameCompetitionSignUpCancel, {
                matchID = _data.matchID,
                callbackSuccess = function(info)
                    UIManager.AddPopTip({strTit = "报名取消成功" })
                    setSelfMoney(tonumber(info.gold))
                    self:RequestHotCompetitionList()
                end
            })
        end})

    end)

    -- 3.按钮 - 进场
    local _btnEnter = _com:GetChild("btn_enter").asButton
    _btnEnter:RemoveEventListeners()
    _btnEnter.onClick:Add(function ()
        roomCfg = _data
        self:ConnectionCompetitionServer()
    end)

    -- 4.按钮 - 观战
    local _btnWatching = _com:GetChild("btn_watching").asButton
    _btnWatching:RemoveEventListeners()
    _btnWatching.onClick:Add(function ()
        roomCfg = _data
        self:ConnectionCompetitionServer()
    end)
end

function ControllerCompetition:InitHotCompetitionList()
    self.m_hotCompetitionList = self.m_content:GetChild('hotGameList').asList
    self.m_hotCompetitionList:SetVirtual()
    self.m_hotCompetitionList.itemRenderer = function (theIndex, theGObj)
        self:SetCompetitionItemView(theGObj.asCom, self.m_hotCompetitionData[theIndex + 1])
    end
    self.m_hotCompetitionList.numItems = 0
    self.m_hotCompetitionData = nil
end

function ControllerCompetition:ResponseHotCompetitionList(msg)
    self.m_hotCompetitionData = msg.resultArr
    self.m_hotCompetitionList.numItems = #msg.resultArr
    local my_competition_list = { }
    for k, v in pairs(msg.resultArr) do
        if tonumber(v.matchStage) == 3 or tonumber(v.baoMing) == 1 then
            table.insert(my_competition_list, v)
        end
    end

    local has_my_competition = #my_competition_list > 0
    if has_my_competition then
        self:ResponseMyCompetitionList(my_competition_list)
    end

    local bet_num_slt = tonumber(msg.myMatchInfo.matchBestNum)
    self.m_best_rank:GetChild("txtJoinTimes").text = string.format("参赛次数\n%s", msg.myMatchInfo.matchCount)
    self.m_best_rank:GetChild("txtRewardTimes").text = string.format("获奖次数\n%s", msg.myMatchInfo.matchWinCount)
    self.m_best_rank:GetController("self_rank").selectedIndex = (bet_num_slt == 0 or bet_num_slt >= 4) and 3 or (bet_num_slt - 1)

    self.m_content:GetChild('myGameEmpty').text = has_my_competition and "" or "暂无参赛，快去报名参加吧！"
end

---------------------------------------------------------------------------------
----------------------------------- 我的比赛 --------------------------------------
function ControllerCompetition:InitMyCompetitionList()
    self.m_myCompetitionList = self.m_content:GetChild('myGameList').asList
    self.m_myCompetitionList:SetVirtual()
    self.m_myCompetitionList.itemRenderer = function (theIndex, theGObj)
        self:SetCompetitionItemView(theGObj.asCom, self.m_myCompetitionData[theIndex + 1])
    end
    self.m_myCompetitionList.numItems = 0
    self.m_myCompetitionData = nil
end

function ControllerCompetition:ResponseMyCompetitionList(msg)
    self.m_myCompetitionData = msg
    self.m_myCompetitionList.numItems = #msg
end

---------------------------------------------------------------------------------
----------------------------------- 比赛结果 -------------------------------------
function ControllerCompetition:InitResCompetitionList()
    self.m_resCompetitionList = self.m_content:GetChild('resGameList').asList
    self.m_resCompetitionList:SetVirtual()
    self.m_resCompetitionList.itemRenderer = function (theIndex,theGObj)
        local _com = theGObj.asCom
        local _data = self.m_resCompetitionData[theIndex + 1]
        local _first_data
        for k, v in pairs(_data.userList) do
            if v.paiMing == 1 then
                _first_data = v
                break
            end
        end

        _com:GetChild('ply_head'):GetChild('icon').asLoader.url = HandleWXIcon(_first_data.headurl)
        _com:GetChild('ply_name').text = _first_data.nickname
        _com:GetChild('open_time').text = _first_data.createtime

        if _first_data.goodID then
            _com:GetChild('reward_count').text = string.format("%s%s%s",
                    Match_Good[tonumber(_first_data.goodID)],
                    Chinese_Num[tonumber(_first_data.goodCount)],
                    Match_Good_Unit[tonumber(_first_data.goodID)])
        else
            _com:GetChild('reward_count').text = string.format("%s金币", formatVal(_first_data.winScore))
        end

        -- 隐藏 rank 1,2,3 的比赛图片
        _com:GetChild("ranking1").visible = false
        _com:GetChild("ranking2").visible = false
        _com:GetChild("ranking3").visible = false
        _com:GetChild('ranking4').text = _first_data.paiMing
        -- 按钮 - 细节
        local btn_detailed = _com:GetChild("btn_detailed").asButton
        btn_detailed:RemoveEventListeners()
        btn_detailed.onClick:Add(function ()
            UIManager.Show('ControllerCompetitionResRank', _data.userList)
        end)

        -- 比赛名字 matchType
        _com:GetController('game_name').selectedIndex = Match_Type[tonumber(_data.matchType)].name_index
        --_com:GetChild('game_name').text = _first_data.title
    end

    self.m_resCompetitionList.numItems = 0
    self.m_resCompetitionData = nil
end

function ControllerCompetition:RequestResCompetitionList()
    UIManager.Show('ControllerWaitTip')
    self.m_resCompetitionList.numItems = 0
    self.m_resCompetitionData = nil
    coroutine.start(GameCompetitionResult, {
        callbackSuccess = function(info)
            UIManager.Hide('ControllerWaitTip')
            local res = info.resultArr
            if #res > 0 then
                self:ResponseResCompetitionList(res)
            end
        end
    })
end

function ControllerCompetition:ResponseResCompetitionList(result_arr)
    for k, v in pairs(result_arr) do
        for kk, vv in ipairs(v.userList) do
            vv.matchID = v.matchID
            vv.matchType = v.matchType
            vv.title = v.title
            vv.createtime = os.date("%Y-%m-%d %H:%M %S", tonumber(v.createtime))
        end
    end
    self.m_resCompetitionData = result_arr
    self.m_resCompetitionList.numItems = #result_arr
end

---------------------------------------------------------------------------------
----------------------------------- 比赛奖品 -------------------------------------
function ControllerCompetition:InitRewardCompetitionList()
    self.m_rewardCompetitionList = self.m_content:GetChild('rewardGameList').asList
    self.m_rewardCompetitionList:SetVirtual()
    self.m_rewardCompetitionList.itemRenderer = function (theIndex,theGObj)
        local _com = theGObj.asCom
        local _data = self.m_rewardCompetitionData[theIndex + 1]
        _com:GetChild('name').text = _data.name
        local btn_receive = _com:GetChild("btn_receive").asButton
        btn_receive:RemoveEventListeners()
        btn_receive.onClick:Add(function ()
            if _data.can_receive then
                UIManager.AddPopTip({ strTit = "尚未获得该奖品" })
            else
                UIManager.AddPopTip({ strTit = "尚未获得该奖品" })
            end
        end)
        _com:GetController('btn_status').selectedIndex = 2
        _com:GetController('reward_type').selectedIndex = _data.key - 1
    end

    self.m_rewardCompetitionList.numItems = 0
    self.m_rewardCompetitionData = nil
end

function ControllerCompetition:ShowRewardCompetitionList()
    local res =
    {
        { key = 1, name = "iPone11", can_receive = false },
        { key = 2, name = "华为Nova8 ", can_receive = false },
        { key = 3, name = "小米11", can_receive = false },
        { key = 4, name = "OPPO_ACE2", can_receive = false },
        { key = 5, name = "VIVO_iQoo5 ", can_receive = false },
        { key = 6, name = "电影票", can_receive = false },
    }
    self.m_rewardCompetitionData = res
    self.m_rewardCompetitionList.numItems = #res
end

----------------------------------- 倒计时 ---------------------------------------
function ControllerCompetition:OpenCd()
    self:CloseCd()
    self.m_cd = Timer.New(function ()
        self:UpdateCd()
    end, 1, -1)
    self.m_cd:Start()
end

function ControllerCompetition:UpdateCd()
    self.m_cd_time = self.m_cd_time - 1
    if self.m_cd_time < 0 then
        self.m_cd_time = 0
        self:CloseCd()
    end
end

function ControllerCompetition:CloseCd()
    if self.m_cd then
        self.m_cd:Stop()
    end
end

---------------------------------------------------------------------------------
----------------------------------- 方法 -----------------------------------------
-- 连接比赛场
function ControllerCompetition:ConnectionCompetitionServer()
    local t = lua_string_split(loginSucceedInfo.server_info['gold_15'],'#')
    local _ip = t[2]
    local _port = t[3]
    local _send_To = t[4]
    local _send_Mcmd = t[5]

    GameServerConfig.ipArr = _ip..':'.._port
    GameServerConfig.send_To = _send_To
    GameServerConfig.send_Mcmd = _send_Mcmd
    GameServerConfig.serverid = 15

    UIManager.Show('ControllerWaitTip')
    F_ResourceManager.instance:AddPackage("newbgdzpk1",function ()
        F_ResourceManager.instance:AddPackage("newbgdzpk2",function ()
            F_ResourceManager.instance:AddPackage("texas",function ()
                F_ResourceManager.instance:AddPackage("biaoqing",function ()
                    F_ResourceManager.instance:LoadPrefab("spine_bq.unity3d",nil,function (arr)
                        for i = 0, arr.Length - 1 do
                            UIManager.AddPrefab(arr[i])
                        end
                        UIManager.InitController('ControllerTexas')
                        UIManager.Show("ControllerWaitTip",{ strTit='',timeOut = 10} )
                        NetManager.ConnectServer(GameServerConfig,function ()
                            UIManager.Hide('ControllerWaitTip')
                            UIManager.AddPopTip({ strTit = '连接服务器失败,请重试.' })
                        end,function ()
                            self:OnHide()
                            GameSubType = GameType.RoomHall

                            roomCfg.is_competition = true
                            roomCfg.is_change_table = false
                            roomCfg.person = 9
                            roomCfg.tablename = ""
                            roomCfg.frontbet = 0
                            roomCfg.tableid = 0
                            roomCfg.xiaomangbet = 0

                            -- 盲注级别的计算
                            -- 前注的计算
                            local str_info_mang = lua_string_split(roomCfg.cellUpList,',')
                            local str_info_qian = string.len(roomCfg.fontList) > 0 and lua_string_split(roomCfg.fontList,',') or { }
                            local info_mang = { }
                            local info_qian = { }
                            local length_qian = #str_info_qian
                            local total_qian = length_qian > 0 and tonumber(str_info_qian[length_qian]) or 0
                            local curt_qian
                            for k, v in pairs(str_info_mang) do
                                curt_qian = total_qian > 0 and (k > length_qian and total_qian or tonumber(str_info_qian[k])) or 0
                                table.insert(info_mang, { level = k, mangzhu = tonumber(v) })
                                table.insert(info_qian, { level = k, qianzhu = curt_qian * 1 })
                            end

                            -- 盲注按级别排序
                            --table.sort(info_mang, function (a, b)
                            --    return a.level < b.level
                            --end)

                            roomCfg.mangzhu_list = info_mang
                            roomCfg.qianzhu_list = info_qian

                            sendEnterGameCompetition(0, 0)

                            UIManager.Hide('ControllerWaitTip')
                            --开启心跳
                            H_HeartbeatManager.Restart(GameServerConfig.logic)
                        end)
                    end)
                end)
            end)
        end)
    end)
end


function ControllerCompetition:PlayAni(spine_anim, anim_name, is_loop)
    spine_anim:SetActive(true)
    local skeleton_anim = spine_anim:GetComponent('Spine.Unity.SkeletonAnimation')
    skeleton_anim.skeleton:SetToSetupPose()
    skeleton_anim.state:ClearTracks()
    skeleton_anim.state:SetAnimation(0,anim_name,is_loop)
    spine_anim.gameObject:SetActive(true)
end

function ControllerCompetition:OnHide()
    self:CloseAniCd()
    self:CloseCd()
    self.m_view.visible = false
end

return ControllerCompetition