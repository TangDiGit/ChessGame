--百人场界面
require("Controller/BaiRen/CtrlBaiRenNet")--百人场网络消息处理

local ControllerBaiRen = class("ControllerBaiRen")
local this = ControllerBaiRen
local contentView
local ply_info_list = { }                                   -- 其他玩家信息
local bet_num_tab = { }                                     -- 下注内容（服务端发过来）
local bet_num_slt_index = 1                                 -- 下注索引
local bet_num_slt_value                                     -- 下注值
local limit_score                                           -- 每个玩家最多下多少金币(防止溢出)
local head_condition                                        -- 坐在显示头像的分数限制
local banker_condition                                      -- 可以选择的下注分数，上庄条件
local self_score                                            -- 自己的输赢分数
local zhuang_score                                          -- 庄家输赢分数
local zhuang_res                                            -- 庄家通杀(0)，庄家通赔(1),还是有输有赢(2)
local card_res_banker
local card_res_other
local card_type_banker
local card_type_other
local area_res_list                                         -- 各区域结果
local chair_res_list                                        -- 各座位结果
local res_self_coin = 0                                     -- 最终金币自己
local res_zhuang_coin = 0                                   -- 最终金币庄家
local ply_self_coin = 0
local m_br_continue_list = { }
local totalBet = 0

function this:Init()
    self.m_view = UIPackage.CreateObject('bairen','bairenView').asCom
	UIManager.normal:AddChild(self.m_view)
    UIManager.AdaptiveAllotypy(self.m_view) --适配刘海屏水滴屏
    self.m_view.visible = false
    self.m_content = self.m_view:GetChild('content')
    contentView = self.m_content
    this:InitMain()

    CtrlBaiRenNet.Init(this)
end

function this:Show()
    UIManager.normal:AddChild(self.m_view)                    -- 保持在前面
    self.m_view.visible = true
    UIManager.Hide('ControllerHall')
    F_SoundManager.instance:PlayEffect('br_bgm', true)
    this:Clear()
    this:IdleJettonSelect()
end

function this:OnHide()
    self.m_view.visible = false
end

------------------ 初始化界面信息 ------------------
--初始化主界面
function this:InitMain()
    self.self_sit_index = -1                                                        -- 自己的座位id
    self.m_effZhuangAllWin = contentView:GetChild('effZhuang').asCom                -- 庄家通杀
    self.m_effZhuangAllLose = contentView:GetChild('effZhuang0').asCom              -- 庄家通赔
    self.m_tongPos = contentView:GetChild('tongPos')
    self.m_tongBG = contentView:GetChild('tongBG')
    self.m_tongBG.visible = false
    self.m_effXiaZhu = contentView:GetChild('effXiaZhu').asCom                      -- 请下注
    self.m_fenZhuangCom = contentView:GetChild('fenZhuang').asCom                   -- 庄家分数
    self.m_fenSelfCom = contentView:GetChild('fenSelf').asCom                       -- 自己分数
    self.m_prizePool = contentView:GetChild("pool")                                 -- 奖池
    self.m_prizePoolTxt = self.m_prizePool:GetChild('txtValue')

    self.m_propLayer = contentView:GetChild("prop")                                 -- 道具层做坐标转换用

    this:InitFaPaiCallback()
    self.m_faPai = contentView:GetChild("faPaiPos")                                 -- 发牌
    local faPaiOBJ = UIManager.SetDragonBonesAniObjPos('faPaiOBJ', self.m_faPai, Vector3.New(105,105,105))
    self.m_faPai_skeletonAnimation = faPaiOBJ.gameObject:GetComponent('Spine.Unity.SkeletonAnimation')
    self.m_faPai_skeletonAnimation.state.Complete = self.m_faPai_skeletonAnimation.state.Complete + self.m_faPaiCallback

    self.m_c_menu = contentView:GetController('c1')                                 --菜单
    self.m_playerSelf = {com = contentView:GetChild('headSelf').asCom}              --自己的用户信息
    self.m_playerZhuang = {com = contentView:GetChild('headZhuang').asCom}          --庄家

    this:InitPlayerInfo()
    this:InitAreaInfo()

    self.m_settlementInfoZhuang = {com = contentView:GetChild('csZhuang').asCom}    -- 庄家牌型
    self.m_settlementInfo = {}                                                      -- 其余四个区域的结算牌
    local order_str = { 3, 1, 2, 0 }                                                -- 顺序
    for i = 0, 3 do
        self.m_settlementInfo[i] = {com = contentView:GetChild('cs'..order_str[i + 1]).asCom}
    end

    self.m_timerShowCards = { }                                                     -- 翻牌的依次倒计时

    self.m_stateInfo = { }                                                          -- 倒计时状态
    self.m_stateInfo.timer = nil
    self.m_stateInfo.txtVal = contentView:GetChild('daoJiShi'):GetChild('txtVal')
    self.m_stateInfo.strFormat = "%s:[color=#F7D53A]%s[/color]s"
    self.m_stateInfo.val = 0

    self.m_persion = contentView:GetChild("btnPersion")

    this:InitBtnContinue()
    this:InitMenu()
    this:InitJettonArea()
    this:InitZhuangJia()
    this:ShowAreaBet()
    this:InitEvent()

    self.sound_list = { "gaopai", "yidui", "liangdui", "santiao", "shunzi", "tonghua", "hulu", "jingang", "tonghuasun", "huangjia" }
end

function this:InitMenu()
    contentView:GetChild("btnMenu").onClick:Add(function ()
        if self.m_c_menu.selectedIndex == 0 then
            self.m_c_menu.selectedIndex = 1
        else
            self.m_c_menu.selectedIndex = 0
        end
    end)
end

-- 下注区域
function this:InitJettonArea()
    contentView:GetChild("btnArea0").onClick:Add(function ()
        if CtrlBaiRenNet.GetCanPlaceJetton() then
            CtrlBaiRenNet.Req_PlaceJetton(0, bet_num_slt_value)
        else
            UIManager.AddPopTip({strTit='暂时不能下注'})
        end
    end)
    contentView:GetChild("btnArea1").onClick:Add(function ()
        if CtrlBaiRenNet.GetCanPlaceJetton() then
            CtrlBaiRenNet.Req_PlaceJetton(1, bet_num_slt_value)
        else
            UIManager.AddPopTip({strTit='暂时不能下注'})
        end
    end)
    contentView:GetChild("btnArea2").onClick:Add(function ()
        if CtrlBaiRenNet.GetCanPlaceJetton() then
            CtrlBaiRenNet.Req_PlaceJetton(2, bet_num_slt_value)
        else
            UIManager.AddPopTip({strTit='暂时不能下注'})
        end
    end)
    contentView:GetChild("btnArea3").onClick:Add(function ()
        if CtrlBaiRenNet.GetCanPlaceJetton() then
            CtrlBaiRenNet.Req_PlaceJetton(3, bet_num_slt_value)
        else
            UIManager.AddPopTip({strTit='暂时不能下注'})
        end
    end)
end

-- 下注筹码注数显示
function this:InitJettonNum()
    local temp_btn
    for i = 1, #bet_num_tab do
        temp_btn = contentView:GetChild('btnCM'..i)
        temp_btn.text = formatVal(bet_num_tab[i])
        temp_btn.onClick:Add(function ()
            bet_num_slt_index = i
            bet_num_slt_value = bet_num_tab[i]
        end)
    end
end

--庄家 申请上/下庄
function this:InitZhuangJia()
    self.m_btnBankerBecome = contentView:GetChild("btnZhuang")
    self.m_btnBankerBecome.onClick:Add(function ()
        if self.m_btnBankerBecome.data == 0 then
            CtrlBaiRenNet.Req_ApplyBankerList()
        else
            CtrlBaiRenNet.Req_CancelBanker() --下庄
        end
    end)
end

function this:InitPlayerInfo()
      self.m_players = { }                              -- 闲家
    for i = 0, 5 do
        local pCom = contentView:GetChild('p'..i).asCom
        self.m_players[i] = { com = pCom, data = {} }
        pCom:GetChild('btnZuoXia').onClick:Add(function ()
            if self.self_sit_index == -1 then           -- 自己没坐下
                CtrlBaiRenNet.Req_ApplySitDown(i)
            end
        end)
    end
end

function this:InitAreaInfo()
    self.m_areas = { }                                                       --投注桌子信息 投注区列表 投注区域ID （0~3） 0:方块 1:红心 2:梅花 3:黑桃
    for i = 0, 3 do
        self.m_areas[i] = { com = contentView:GetChild('btnArea'..i).asCom }
        self.m_areas[i].com.data = { areaID = i }
        self.m_areas[i].yesCom = self.m_areas[i].com:GetChild('yes')        --区域赢的亮灯
        self.m_areas[i].bet_total = 0
        self.m_areas[i].bet_self = 0
        self.m_areas[i].myCmCom = self.m_areas[i].com:GetChild('txtMyCM')   --没有下注
        self.m_areas[i].betCom = self.m_areas[i].com:GetChild('txtVal')     --下注
        for j = 1, 12 do                                                    --控制筹码飞的数量--每个区域有12个点
            self.m_areas[i].com:GetChild('p'..j).data = i * 100 + j         --这里唯一id性了
        end
    end
end

function this:InitEvent()
    contentView:GetChild("btnExit").onClick:Add(function ()             -- 离开桌子请求
        self.m_c_menu.selectedIndex = 0
        F_SoundManager.instance:StopPlayEffect()
        CtrlBaiRenNet.Req_ExitRoom()
        this:Clear()
    end)

    contentView:GetChild("btnHelp").onClick:Add(function ()             -- 点击帮助按钮
        self.m_c_menu.selectedIndex=0
        UIManager.Show('ControllerBaiRenDes')
    end)

    contentView:GetChild("btnSetting").onClick:Add(function ()          -- 点击设置按钮
        self.m_c_menu.selectedIndex=0
        UIManager.Show('ControllerSetting',true)
    end)

    contentView:GetChild("btnData").onClick:Add(function ()             -- 点击输赢走势
        CtrlBaiRenNet.Req_GetHistoryRecord()
    end)

    contentView:GetChild("btnPersion").onClick:Add(function ()          -- 点击获取玩家列表
        CtrlBaiRenNet.Req_GetUserList()
    end)

    contentView:GetChild("btnUp").onClick:Add(function ()               -- 点击站立
        CtrlBaiRenNet.Req_ApplySitUp()
    end)

    UIManager.SetDragonBonesAniObjPos('PrizePoolEnterBtn', self.m_prizePool, Vector3.New(100, 100, 100))
    self.m_prizePool.onClick:Add(function ()                            -- 奖池
        UIManager.Show('ControllerBaiRenPrizePool',self.m_prizePool.data or 0)
    end)
end

------------------ 界面信息 ------------------

function this:IdleJettonSelect()
    contentView:GetController('c2').selectedIndex = 1 --下注默认选中最低的那个(貌似没效果)
end
--required int32 sex = 5;		//
--required int32 sitindex = 6;		//位置0-7
-- 庄家信息
function this:ShowZhuangJiaInfo(is_system, banker_info)
    if not is_system then
        self:SetPlayerInfo(self.m_playerZhuang.com,{
            uid = banker_info.userid,
            icon_url = banker_info.headurl,
            nick_name = banker_info.nickname,
            coin = banker_info.score
        })
    else
        self:SetPlayerInfo(self.m_playerZhuang.com,{
            uid = 0,
            icon_url = "",
            nick_name = "博众扑克",
            coin = 990000000
        })
    end
    this:SetBankerUID(is_system and 0 or banker_info.userid)
end

--自己的上下庄信息
function this:SetBankerUID(bankerUID)
    --self.m_currBankerUID=bankerUID
    if bankerUID == loginSucceedInfo.user_info.userid then
        self.m_btnBankerBecome.text="申请下庄"
        self.m_btnBankerBecome.data = 1
    else
        self.m_btnBankerBecome.text="申请上庄"
        self.m_btnBankerBecome.data = 0
    end
end

function this:ShowSelfInfo()
    this:SetPlayerInfo(self.m_playerSelf.com, {
        uid = loginSucceedInfo.user_info.userid,
        icon_url = loginSucceedInfo.user_info.headurl,
        nick_name = loginSucceedInfo.user_info.nickname,
        coin = loginSucceedInfo.user_info.gold
    })
    ply_self_coin = loginSucceedInfo.user_info.gold * 1
end

-- 其他玩家信息
function this:ShowPlayerInfo()
    for i = 0, 5 do
        local ply_data = ply_info_list[i + 1]
        local has_player = ply_data.has_player
        local ply_info =
        {
            has_player = has_player,
            uid = ply_data.userid,
            icon_url = ply_data.headurl,
            nick_name = ply_data.nickname,
            coin = ply_data.score
        }
        self.m_players[i].data = ply_info
        if has_player then
            this:SetPlayerInfo(self.m_players[i].com, ply_info)
        else
            this:EmptyPlayer(self.m_players[i].com)
        end
    end
end

function this:EmptyPlayer(com)
    com:GetChild('txtNickName').text = "暂无玩家"
    com:GetChild('txtJinBi').text = 0
    com:GetChild("head"):GetChild("icon").asLoader.url = ""
    com:GetController('c1').selectedIndex = 0
end

function this:SetPlayerInfo(com, arg)
    local icon = arg.uid == 0 and "ui://bairen/icon_sys" or HandleWXIcon(arg.icon_url)
    com.visible = true
    com.data = arg
    if icon then
        com:GetChild("head"):GetChild("icon").asLoader.url = icon
    end
    com:GetChild('txtNickName').text = arg.nick_name
    com:GetChild('txtJinBi').text = formatVal(tonumber(arg.coin))
    local _cc = com:GetController('c1')
    if _cc then
        _cc.selectedIndex = 1
    end
end

---------------------------------- 响应以及表现 ----------------------------------
-- 刚进入房间的状态
function this:resp_GameStatus(cd_time, game_des)
    this:OpenCountDown(cd_time, game_des)
    CtrlBaiRenNet.Req_GetBigWinPoolNum()
end

-- 游戏正在运行中
function this:resp_GameRunning(score_all, score_self)
    this:InitAreaInfo()
    for k = 1, 4 do
        local all_value = score_all[k]
        local self_value = score_self[k]
        self.m_areas[k - 1].bet_total = all_value
        self.m_areas[k - 1].bet_self = self_value
        if all_value > 0 then
            this:CreateJetton(false, true, false, 0, k, all_value - self_value)
            this:CreateJetton(true, false, false, 0, k, self_value)
        end
    end
    this:ShowAreaBet()
    -- is_self, is_robot, is_player, sit_index, area_id, number
end

-- 响应庄家变化
function this:resp_GameChangeBanker(is_system, banker_info)
    this:ShowZhuangJiaInfo(is_system, banker_info)
end

-- 桌子信息（每个玩家最多下多少金币(防止溢出)，坐在显示头像的分数限制，可以选择的下注分数，上庄条件）
function this:resp_GameTableInfo(_limit_score, _head_condition, chip_list, _banker_condition)
    limit_score = _limit_score
    head_condition = _head_condition
    banker_condition = _banker_condition
    bet_num_slt_index = 1

    bet_num_tab = { }
    if chip_list then
        for k, v in pairs(chip_list) do
            table.insert(bet_num_tab, tonumber(v))
        end
        table.sort(bet_num_tab, function (a,b) return a < b end)
        bet_num_slt_value = bet_num_tab[bet_num_slt_index]
    end

    if #bet_num_tab > 1 then
        this:InitJettonNum()
    end
end

-- 玩家信息（游戏开始要知道玩家的信息）
function this:resp_PlayerInfo(info_list)
    ply_info_list = info_list
    this:ShowSelfInfo()
    this:ShowPlayerInfo()
end

-- 玩家坐下
function this:resp_PlayerSitDown(ply_info)
    if ply_info.userid == loginSucceedInfo.user_info.userid and self.self_sit_index == -1 then
        self.self_sit_index = ply_info.sitindex
    end
    ply_info_list[ply_info.sitindex + 1] = ply_info
    this:ShowPlayerInfo()
end

-- 玩家站起
function this:resp_PlayerSitUp(sitindex)
    if self.self_sit_index == sitindex then
        self.self_sit_index = -1
    end
    if #ply_info_list > 0 and ply_info_list[sitindex + 1]  then
        ply_info_list[sitindex + 1].has_player = false
        this:ShowPlayerInfo()
    end
end

-- 响应游戏准备阶段
function this:resp_GameReady(cd_time, game_des)
    this:OpenCountDown(cd_time, game_des)
    this:HideCard()
    this:HideJetton()
    this:ClearAreaBet()
end

-- 响应游戏开始
function this:resp_GameStart(_endTime, _maxSelfCanInScore)
    local endTime = _endTime                             --结束时间
    local maxSelfCanInScore = _maxSelfCanInScore         --下注最大分数
    self.m_effXiaZhu.visible = true
    self.m_tongBG.visible = false
    local trans = self.m_effXiaZhu:GetTransition("t0")
    trans:Play()
    this:OpenCountDown(_endTime, "请下注")
    F_SoundManager.instance:PlayEffect('kaisixiazhu')
    this:ContinuePlaceJetton()
end

-- 响应用户下注（包括自己和其他玩家）
function this:resp_PlaceJetton(userid, jetton_area, jetton_score)
    local is_self = loginSucceedInfo.user_info.userid == userid and true or false
    local is_robot = true
    local is_player = true
    local sit_index = 0
    local ply_info_t
    for i = 1, 6 do
        ply_info_t = ply_info_list[i]
        if ply_info_t.has_player and ply_info_t.userid == userid then
            is_robot = false
            is_player = true
            ply_info_list[i].score = ply_info_list[i].score - jetton_score
            if ply_info_list[i].score < 0 then
                ply_info_list[i].score = 0
            end
            self.m_players[i - 1].com:GetChild('txtJinBi').text = formatVal(ply_info_list[i].score)
            self.m_players[i - 1].data.coin = ply_info_list[i].score
            sit_index = i - 1
        end
    end

    self.m_areas[jetton_area].bet_total = self.m_areas[jetton_area].bet_total + jetton_score
    if is_self then
        self.m_areas[jetton_area].bet_self = self.m_areas[jetton_area].bet_self + jetton_score
        ply_self_coin = ply_self_coin - jetton_score
        if ply_self_coin < 0 then
            ply_self_coin = 0
        end
        self.m_playerSelf.com:GetChild('txtJinBi').text = formatVal(ply_self_coin)
        loginSucceedInfo.user_info.gold = ply_self_coin * 1
    end
    this:ShowJettonFly(is_self, is_robot, is_player, sit_index, jetton_area, jetton_score)
    this:ShowAreaBet()
end

-- 游戏结束牌型参数值
function this:resp_GameEnd(cd_time, self_win_score, res_banker, res_other, type_banker, type_other)
    card_res_banker = res_banker
    card_res_other = res_other
    card_type_banker = type_banker
    card_type_other = type_other
    self_score = self_win_score

    this:OpenCountDown(cd_time, "开牌中")
    this:FaiPai()
    F_SoundManager.instance:PlayEffect('tingzhixiazhu')
end

-- 拿到输赢结果参数值
function this:resp_WinLoseResult(area_res, chair_res, zhuang_result, zhuang_scores, self_coin, zhuang_coin)
    area_res_list = area_res
    chair_res_list = chair_res
    zhuang_res = zhuang_result
    zhuang_score = zhuang_scores
    res_self_coin = self_coin
    res_zhuang_coin = zhuang_coin
end

-- 更新自己和庄家的金币数目
function this:ShowUpdateCoinNum(self_coin, zhuang_coin)
    ply_self_coin = self_coin > 0 and self_coin or 0
    loginSucceedInfo.user_info.gold = ply_self_coin * 1
    self.m_playerSelf.com:GetChild('txtJinBi').text = formatVal(tonumber(self_coin > 0 and self_coin or 0))
    if self.m_playerZhuang.com.data.uid == 0 then
        self.m_playerZhuang.com:GetChild('txtJinBi').text = "9.9亿"
    else
        self.m_playerZhuang.com:GetChild('txtJinBi').text = formatVal(tonumber(zhuang_coin > 0 and zhuang_coin or 0))
    end

end

function this:res_BigWinNum(num)
    self.m_prizePoolTxt.text = num
    self.m_prizePool.data = num
end

---------------------------------- 扑克 ----------------------------------
-- 开始发牌
function this:FaiPai()
    self.m_faPai.visible = true
    self.m_faPai_skeletonAnimation.skeleton:SetToSetupPose()
    self.m_faPai_skeletonAnimation.state:ClearTracks()
    self.m_faPai_skeletonAnimation.state:SetAnimation(0, 'animation2', false)

    for i = 1, 5 do
        local _timer = Timer.New(function ()
            F_SoundManager.instance:PlayEffect("fapaib")
        end, i, 1)
        _timer:Start()
        table.insert(self.m_timerShowCards, _timer)
    end
end

-- 发牌回调
function this:InitFaPaiCallback()
    self.m_faPaiCallback = function (state, trackIndex, loopCount)
        self:ShowCardResult()
    end
end

-- 显示扑克结果动画
function this:ShowCardResult()
    this:HideCardOpenAni()
    -- 翻牌-区域
    for i = 0, 3 do
        local _timer = Timer.New(function ()
            if self.m_settlementInfo[i] then
                self.m_settlementInfo[i].com.visible = true
                this:ShowCard(self.m_settlementInfo[i].com,{ poker_value = card_res_other[i + 1], poker_type = card_type_other[i + 1] })
            end
        end, 0.8 * i, 1)
        _timer:Start()
        table.insert(self.m_timerShowCards, _timer)
    end
    -- 翻牌-庄家
    local _timer1 = Timer.New(function ()
        if self.m_settlementInfoZhuang then
            self.m_faPai.visible = false
            self.m_settlementInfoZhuang.com.visible = true
            this:ShowCard(self.m_settlementInfoZhuang.com,{ poker_value = card_res_banker, poker_type = card_type_banker })
            this:ShowWinAreaLight()
        end
    end, 3.2, 1)
    _timer1:Start()
    table.insert(self.m_timerShowCards, _timer1)

    -- 筹码结算
    local _timer2 = Timer.New(function ()
        this:ShowResultInfo()
    end, 4.2, 1)
    _timer2:Start()

    table.insert(self.m_timerShowCards, _timer2)
end

-- 隐藏翻扑克牌等一系列的延迟调用动画
function this:HideCardOpenAni()
    if #self.m_timerShowCards > 0 then
        for i,v in ipairs(self.m_timerShowCards) do
            v:Stop()
        end
        self.m_timerShowCards = { }
    end
end

-- 隐藏扑克牌
function this:HideCard()
    for i = 0, 3 do
        self.m_settlementInfo[i].com.visible = false
    end
    self.m_settlementInfoZhuang.com.visible = false
end

-- 扑克开牌
function this:ShowCard(comCS, arg)
    for i = 1, 5 do
        if BaiRenPokerCardConversionMap[arg.poker_value[i]] <= 0 then
            UIManager.SetPoker(comCS:GetChild('c'..i), BaiRenPokerCardConversionMap[arg.poker_value[i]])
        else
            UIManager.SetPoker(comCS:GetChild('c'..i), BaiRenPokerCardConversionMap[arg.poker_value[i]],true)
        end
     end
    if arg.poker_type then
        if arg.area_id then
            comCS:GetController("c1").selectedIndex=arg.area_id
        else
            comCS:GetController("c1").selectedIndex=0  --庄
        end
        comCS:GetChild('n20').text= CT_Chinese_Dic[arg.poker_type + 1]
        this:ShowPokerSound(arg.poker_type + 1)
    else
        comCS:GetController("c1").selectedIndex=4
    end
end

function this:ShowPokerSound(poker_type)
    F_SoundManager.instance:PlayEffect(self.sound_list[poker_type])
end

function this:ClearAreaBet()
    for i = 0, 3 do
        self.m_areas[i].bet_total = 0
        self.m_areas[i].bet_self = 0
        self.m_areas[i].betCom.text = "0"
        self.m_areas[i].myCmCom.text = "没有下注"
    end
end

-- 区域下注（自己和全部的）
function this:ShowAreaBet()
    for i = 0, 3 do
        self.m_areas[i].betCom.text = formatVal(self.m_areas[i].bet_total)
        self.m_areas[i].myCmCom.text = self.m_areas[i].bet_self == 0 and "没有下注" or formatVal(self.m_areas[i].bet_self)
    end
end

--生产一个CM （金币或者是筹码）
function this:ProduceOneCM(resName, pos, endPos, is_self)
    local cm = H_ComPoolManager.GetComFromPool("bairen", resName)
    self.m_propLayer:AddChild(cm)
    cm.position = pos
    cm.visible = true
    cm.scale = Vector2.New(0.8, 0.8)
    cm.rotation = math.random(-30,30)
    cm.data =
    {
        mtype = 1,
        areaID = -1,
        areaPosID = -1,
        fromPos = is_self and self.m_propLayer:GlobalToLocal(self.m_playerSelf.com:GetChild('head'):LocalToGlobal(Vector2.zero)) or pos,
        endPos = endPos
    }
    return cm
end

--倒计时
function this:OpenCountDown(cd_time, game_des)
    this:CloseCountDown()
    self.m_stateInfo.val = cd_time
    self.m_stateInfo.timer = Timer.New(function ()
        if self.m_stateInfo.val and self.m_stateInfo.val > -1 then
            self.m_stateInfo.txtVal.text = string.format(self.m_stateInfo.strFormat, game_des, self.m_stateInfo.val)
            self.m_stateInfo.val = self.m_stateInfo.val - 1
        else
            this:CloseCountDown()
        end
    end, 1, cd_time)
    self.m_stateInfo.timer:Start()
end

function this:CloseCountDown()
    if self.m_stateInfo.timer then
        self.m_stateInfo.timer:Stop()
    end
end

-- 输赢结果展示
function this:ShowResultInfo()
    this:ShowAreaJetton()
end

function this:ShowAreaJetton()
    this:ShowAreaJettonLose()

    local _timer1 = Timer.New(function ()
        this:ShowAreaJettonWin()
    end, 1, 1)
    _timer1:Start()

    local _timer2 = Timer.New(function ()
        this:ShowResultSelfScore(self_score)
        this:ShowResultPlyScore(chair_res_list)
        this:ShowResultBankerScore(zhuang_score)
        this:ShowUpdateCoinNum(res_self_coin, res_zhuang_coin)
    end, 2, 1)
    _timer2:Start()

    local _timer3 = Timer.New(function ()
        this:ShowResultBankerType()
    end, 3, 1)
    _timer3:Start()

    local _timer4 = Timer.New(function ()
        this:HideResultBankerEffect()
        this:CloseWinAreaLight()
    end, 5, 1)
    _timer4:Start()

end

-- 区域赢的亮灯
function this:ShowWinAreaLight()
    for k, v in pairs(area_res_list) do
        if v.is_win then
            self.m_areas[v.area_id].yesCom.visible = true
        end
    end
end

-- 关闭区域灯
function this:CloseWinAreaLight()
    for i = 0, 3 do
        self.m_areas[i].yesCom.visible = false
    end
end

-- 区域筹码输的到庄家
function this:ShowAreaJettonLose()
    local play_once = true
    local _zhuangPos = self.m_propLayer:GlobalToLocal(self.m_playerZhuang.com:GetChild('head'):LocalToGlobal(Vector2.zero))
    for k, v in pairs(area_res_list) do
        if not v.is_win then
            if play_once then
                F_SoundManager.instance:PlayEffect('jinbi')
                play_once = false
            end
            local _effComs = self.m_propLayer:GetChildren()
            for i = 0, _effComs.Length - 1 do
                local _com = _effComs[i]
                if _com.data and _com.data.areaID == v.area_id then
                    _com:TweenMove(_zhuangPos, Vector2.Distance(_com.data.endPos, _zhuangPos)/600):SetEase(EaseType.CubicOut):OnStart(function ()
                        if _com then
                            _com.visible = true
                        end
                    end):OnComplete(function()
                        if _com then
                            H_ComPoolManager.RemoveComToPool(_com)
                            _com.visible = false
                        end
                    end)
                end
            end
        end
    end
end

-- 区域赢的返回自己原来的位置
function this:ShowAreaJettonWin()
    local play_once_coin = true
    local play_once_chip = true
    for k, v in pairs(area_res_list) do
        if v.is_win then
            if play_once_coin then
                F_SoundManager.instance:PlayEffect("jinbi")
                play_once_coin = false
            end
            local _effComs = self.m_propLayer:GetChildren()
            for i = 0, _effComs.Length - 1 do
                local _com = _effComs[i]
                if _com.data and _com.data.areaID == v.area_id then
                    _com:TweenMove(_com.data.fromPos, Vector2.Distance(_com.data.fromPos, _com.data.endPos)/600):SetEase(EaseType.CubicOut):OnStart(function ()
                        if _com and _com.visible and play_once_chip then
                            F_SoundManager.instance:PlayEffect('chip')
                            play_once_chip = false
                        end
                    end):OnComplete(function()
                        if _com then
                            _com.visible = false
                            H_ComPoolManager.RemoveComToPool(_com)
                        end
                    end)
                end
            end
        end
    end
end

-- 庄家（通杀还是通赔） 庄家通杀(0)，庄家通赔(1), 还是有输有赢(2)
function this:ShowResultBankerType()
    if zhuang_res == 0 then
        --self.m_effZhuangAllWin.visible = true
        --self.m_effZhuangAllWin:GetTransition("t0"):Play()
        F_SoundManager.instance:PlayEffect("tongsha")
        this:PlayTongAni(0)
    elseif zhuang_res == 1 then
        --self.m_effZhuangAllLose.visible = true
        --self.m_effZhuangAllLose:GetTransition("t0"):Play()
        this:PlayTongAni(1)
        F_SoundManager.instance:PlayEffect("tongpei")
    end
end

function this:PlayTongAni(res)
    local obj_name = res == 0 and "tongchiOBJ" or "tongpeiOBJ"
    self.m_tongPos.visible = true
    self.m_tongBG.visible = true

    if res == 0 then
        if not self.m_tong_ani_win then
            self.m_tong_ani_win = UIManager.SetDragonBonesAniObjPos(obj_name, self.m_tongPos, Vector3.New(120, 120, 120))
        else
            this:PlayAni(self.m_tong_ani_win.gameObject, 'animation')
        end
        if self.m_tong_ani_lose then
            self.m_tong_ani_lose.gameObject:SetActive(false)
        end
    else
        if not self.m_tong_ani_lose then
            self.m_tong_ani_lose = UIManager.SetDragonBonesAniObjPos(obj_name, self.m_tongPos, Vector3.New(120, 120, 120))
        else
            this:PlayAni(self.m_tong_ani_lose.gameObject, 'animation')
        end
        if self.m_tong_ani_win then
            self.m_tong_ani_win.gameObject:SetActive(false)
        end
    end

    self.m_timerEff = Timer.New(function ()
        self.m_tongPos.visible = false
        self.m_tongBG.visible = false
    end,3,1)
    self.m_timerEff:Start()
end

function this:PlayAni(spine_anim,anim_name)
    spine_anim:SetActive(true)
    local skeleton_anim = spine_anim:GetComponent('Spine.Unity.SkeletonAnimation')
    skeleton_anim.skeleton:SetToSetupPose()
    skeleton_anim.state:ClearTracks()
    skeleton_anim.state:SetAnimation(0,anim_name,false)
    spine_anim.gameObject:SetActive(true)
end

function this:ShowResultBankerScore(score)
    if score ~= 0 then
        self.m_fenZhuangCom.visible = true
        self.m_fenZhuangCom:GetChild("txtWinScoreZhuang").text = (score < 0 and "-" or "+")..formatVal(math.abs(score))
        self.m_fenZhuangCom:GetTransition('t0'):Play()
    end
end

-- 隐藏通杀通赔的效果
function this:HideResultBankerEffect()
    self.m_fenZhuangCom.visible = false
    self.m_effZhuangAllWin.visible = false
    self.m_effZhuangAllLose.visible = false
end

-- 自己
function this:ShowResultSelfScore(score)
    if score ~= 0 then
        self.m_fenSelfCom.visible = true
        self.m_fenSelfCom:GetTransition('t0'):Play()
        self.m_fenSelfCom:GetChild("txtWinScoreZhuang").text = (score > 0 and '+' or '-')..formatVal(math.abs(score))
        this:ShowRemainJetton(score, self.m_propLayer:GlobalToLocal(self.m_playerSelf.com:GetChild('head'):LocalToGlobal(Vector2.zero)))
        local _timer = Timer.New(function ()
            if self.m_fenSelfCom.visible then
                self.m_fenSelfCom.visible = false
            end
        end, 3, 1)
        _timer:Start()
    end
    --table.insert(self.m_timerShowCards, _timer2)
end

--其余玩家的筹码表现形式
function this:ShowResultPlyScore(all_chair_res)
    if not all_chair_res then
        return
    end
    local ply_res_data
    for i = 1, 6 do
        ply_res_data = all_chair_res[i]
        if ply_res_data.has_player then
            ply_info_list[ply_res_data.chair_id + 1].score = ply_res_data.score
            self.m_players[ply_res_data.chair_id].com:GetChild('txtJinBi').text = formatVal(ply_res_data.score)
            self.m_players[ply_res_data.chair_id].data.coin = ply_res_data.score
        end
    end
end

-- 剩余的筹码补偿：是庄家到目标位置，还是目标位置到庄家
function this:ShowRemainJetton(score, target_pos)
    local _number_list = CalcFlyCMWithBaiRen(math.abs(score))
    local _zhuangPos = self.m_propLayer:GlobalToLocal(self.m_playerZhuang.com:GetChild('head'):LocalToGlobal(Vector2.zero))
    local _fromPos
    local _toPos
    if score < 0 then           -- 还要输庄家
        _fromPos = target_pos
        _toPos = _zhuangPos
    else
        _fromPos = _zhuangPos   -- 赢了庄家
        _toPos = target_pos
    end

    for i = 1, #_number_list do
        local _cm = self:ProduceOneCM(_number_list[i].resName, _fromPos, _toPos, false)
        _cm.visible = false
        _cm:TweenMove(_toPos, Vector2.Distance(_fromPos, _toPos)/1200):SetEase(EaseType.CubicOut):SetDelay(0.05 * (i-1)):OnStart(function ()
            if _cm then
                _cm.visible = true
            end
        end):OnComplete(function()
            if _cm then
                _cm.visible = false
                H_ComPoolManager.RemoveComToPool(_cm)
            end
        end)
    end
end

---------------------------------- 筹码 ----------------------------------
-- 生成筹码（重连用）
function this:CreateJetton(is_self, is_robot, is_player, sit_index, area_id, number)
    if not self.m_areas[area_id] or not self.m_areas[area_id].com then
        return
    end
    local _fromPos
    local _toPos
    local _number_list = CalcFlyCMWithBaiRen(number)
    if is_self then
        _fromPos = self.m_propLayer:GlobalToLocal(self.m_playerSelf.com:GetChild('head'):LocalToGlobal(Vector2.zero))
    elseif is_robot then
        _fromPos = self.m_propLayer:GlobalToLocal(self.m_persion:LocalToGlobal(Vector2.zero))
    elseif is_player then
        _fromPos = self.m_propLayer:GlobalToLocal(self.m_players[sit_index].com:GetChild('head'):LocalToGlobal(Vector2.zero))
    else
        _fromPos = self.m_propLayer:GlobalToLocal(self.m_persion:LocalToGlobal(Vector2.zero))
    end
    for i = 1, #_number_list do
        local _areaChildData = self.m_areas[area_id].com:GetChild('p'..math.random(1,12))
        _toPos = self.m_propLayer:GlobalToLocal(_areaChildData:LocalToGlobal(Vector2.zero))
        local _cm = self:ProduceOneCM(_number_list[i].resName, _toPos, _toPos, is_self)
        _cm.data.fromPos = _fromPos
        _cm.visible = true
        --if #self.m_areasPosList[_areaChildData.data] > 0 then
        --    for k, v in pairs(self.m_areasPosList[_areaChildData.data]) do
        --        if v.data.areaPosID == _areaChildData.data  then
        --            self.m_areasPosList[_areaChildData.data] = { }
        --            H_ComPoolManager.RemoveComToPool(_cm)
        --        end
        --    end
        --else
            _cm.data.areaID = area_id
            _cm.data.areaPosID = _areaChildData.data
            --table.insert(self.m_areasPosList[_areaChildData.data], _cm)
        --end
    end
end

-- 下注飞筹码
function this:ShowJettonFly(is_self, is_robot, is_player, sit_index, area_id, number)
    local _fromPos
    local _toPos
    local _number_list = CalcFlyCMWithBaiRen(number)
    if is_self then
        _fromPos = self.m_propLayer:GlobalToLocal(contentView:GetChild('btnCM'..bet_num_slt_index):LocalToGlobal(Vector2.zero))
    elseif is_robot then
        _fromPos = self.m_propLayer:GlobalToLocal(self.m_persion:LocalToGlobal(Vector2.zero))
    elseif is_player then
        _fromPos = self.m_propLayer:GlobalToLocal(self.m_players[sit_index].com:GetChild('head'):LocalToGlobal(Vector2.zero))
    else
        _fromPos = self.m_propLayer:GlobalToLocal(self.m_persion:LocalToGlobal(Vector2.zero))
    end

    for i = 1, #_number_list do
        local _areaChildData = self.m_areas[area_id].com:GetChild('p'..math.random(1,12))
        _toPos = self.m_propLayer:GlobalToLocal(_areaChildData:LocalToGlobal(Vector2.zero))
        local _cm = self:ProduceOneCM(_number_list[i].resName, _fromPos, _toPos, is_self)
        _cm.visible = false
        _cm:TweenMove(_toPos, Vector2.Distance(_fromPos, _toPos)/1200):SetEase(EaseType.CubicOut):SetDelay(0.08 * (i-1)):OnStart(function ()
            if _cm then
                _cm.visible = true
                F_SoundManager.instance:PlayEffect('chip')
            end
        end):OnComplete(function()
            if _cm then
                --if #self.m_areasPosList[_areaChildData.data] > 0 then
                --    for k, v in pairs(self.m_areasPosList[_areaChildData.data]) do
                --        if v.data.areaPosID == _areaChildData.data  then
                --            self.m_areasPosList[_areaChildData.data] = { }
                --            H_ComPoolManager.RemoveComToPool(_cm)
                --        end
                --    end
                --else
                    _cm.data.areaID = area_id
                    _cm.data.areaPosID = _areaChildData.data
                    --table.insert(self.m_areasPosList[_areaChildData.data], _cm)
                --end
            end
        end)
    end
end

-- 筹码信息打印
function this:PrintJettonInfo()
    local _effComs = self.m_propLayer:GetChildren()
    for i = 0, _effComs.Length - 1 do
        local _cm = _effComs[i]
        print("区域id:".._cm.data.areaID)
        print("PosID".._cm.data.areaPosID)
    end
end

-- 回收筹码（情况桌面筹码）
function this:HideJetton()
    local _effComs = self.m_propLayer:GetChildren()
    for i = 0, _effComs.Length - 1 do
        local _com = _effComs[i]
        if _com and _com.data then
            H_ComPoolManager.RemoveComToPool(_com)
        end
    end
end

------------------------------------- 续投 --------------------------------
function this:InitBtnContinue()
    contentView:GetChild("btnJiXu").onClick:Add(function ()
        UIManager.Show('ControllerHallZhuiHaoView', { slt_money_list = bet_num_tab, is_niuzai = false })
    end)
    contentView:GetChild("btnQuXiao").onClick:Add(function ()
        this:CloseContinueBet()
        UIManager.AddPopTip({strTit = '续投取消成功'})
    end)
    self.m_continue_ctrl = contentView:GetController('continue')
    this:CloseContinueBet()
end

function this:ContinueBetSuccess(bet_list)
    m_br_continue_list = { }
    totalBet = 0
    for k, v in pairs(bet_list) do
        totalBet = totalBet + v.num
        table.insert(m_br_continue_list, { area = v.area * 1, num = v.num * 1 })
    end
    self.m_continue_ctrl.selectedIndex = 1
    UIManager.AddPopTip({strTit = '续投选择成功'})
end

function this:ContinuePlaceJetton()
    if #m_br_continue_list > 0 then
        if tonumber(loginSucceedInfo.user_info.gold) < totalBet then
            UIManager.AddPopTip({strTit = '续投金币不足，续投已自动取消'})
            this:CloseContinueBet()
            return
        end

        for k, v in pairs(m_br_continue_list) do
            CtrlBaiRenNet.Req_PlaceJetton(v.area, v.num)
        end

        UIManager.AddPopTip({strTit = '续投成功'})
    end
end

function this:CloseContinueBet()
    totalBet = 0
    m_br_continue_list = { }
    self.m_continue_ctrl.selectedIndex = 0
end

---------------------------------- 清理主界面 ----------------------------------
function this:Clear(isAgain)
    self.self_sit_index = -1
    self.m_effXiaZhu.visible = false
    self.m_fenSelfCom.visible = false

    this:CloseContinueBet()
    this:HideResultBankerEffect()
    this:HideCard()
    this:HideJetton()
    this:HideCardOpenAni()
    if not isAgain then
        self.m_playerZhuang.com.visible=false
        contentView:GetController("c2").selectedIndex=0
        self.m_currStatus = nil
    end

    if self.m_timerOverAni1 then
        self.m_timerOverAni1:Stop()
    end
    if self.m_timerOverAni2 then
        self.m_timerOverAni2:Stop()
    end
    if self.m_timerOverAni3 then
        self.m_timerOverAni3:Stop()
    end

    for i = 0, 3 do
        self.m_areas[i].yesCom.visible = false
        self.m_areas[i].myCmCom.text = '没有下注'
        self.m_areas[i].myCmCom.data = 0
        self.m_areas[i].bet_total = 0
        self.m_areas[i].bet_self = 0
    end

    self.m_faPai.visible = false

    --当前位置有一个筹码则删除它
    self.m_areasPosList={}
    for i = 0, 3 do
        for j = 1, 12 do
            self.m_areasPosList[i * 100 + j] = { }
        end
    end
    self.m_stateInfo.txtVal.text = ""
end

return ControllerBaiRen
