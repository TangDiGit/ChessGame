local H_TexasPlayer=class("H_TexasPlayer")

OperationType_Null='空'
OperationType_GuoPai='让牌'
OperationType_GenZhu='跟注'
OperationType_JiaZhu='加注'
OperationType_QiPai='弃牌'
OperationType_AllIn='Allin'
OperationType_Thinking='思考中'

OperationType_Image_Dic =
{
    [OperationType_GuoPai] = 1,
    [OperationType_GenZhu] = 2,
    [OperationType_JiaZhu] = 3,
    [OperationType_QiPai] = 4,
    [OperationType_AllIn] = 5,
    [OperationType_Thinking] = 6,
}

function H_TexasPlayer:Init(arg)
    self.m_view=arg.view
    self.m_pos=arg.pos
    self.m_userID=nil
    self.m_chair=nil
    self.m_expectSitDownChair=nil
    --动画容器
    self.m_effParent=arg.effParent

    --玩家基础数据(用于交换位置)
    self.m_baseData=nil
    --玩家的下注数值
    self.m_betVal=nil

    --玩家奖池数据
    self.m_jiangchi=nil

    --下注筹码组件
    --总的
    self.m_flyCMLs={}
    --当前回合
    self.m_currCMLs={}

    self.m_head=self.m_view:GetChild("head")
    self.m_frame=self.m_view:GetChild("frame")
    self.m_thinking=self.m_view:GetChild("thinking")
    self.m_thinkingDianParent=self.m_thinking:GetChild("dianParent")
    self.m_thinkingCenter=self.m_thinking:GetChild("center")
    --UIManager.SetDragonBonesAniObjPos2('dianObj',self.m_thinkingDianParent,Vector3.New(200,200,200))
    --
    UIManager.SetDragonBonesAniObjPos2('zhuanQuan',self.m_thinkingDianParent,Vector3.New(1,1,1))

    self.m_allInEffect=self.m_view:GetChild("allInEffect")
    --UIManager.SetDragonBonesAniObjPos('AllInEffect',self.m_allInEffect,Vector3.New(115,115,115))
    UIManager.SetDragonBonesAniObjPos2('yuanquanObj',self.m_allInEffect:GetChild('parent'),Vector3.New(115,115,115))

    self.m_btnSetDown=self.m_view:GetChild("btnSetDown")
    self.m_banker=self.m_view:GetChild("banker")
    self.m_nameBg=self.m_view:GetChild("nameBg")
    self.m_nickName=self.m_view:GetChild("txtNickName")
    self.m_state=self.m_view:GetChild("txtState")
    -- 牌型
    self.m_cardType=self.m_view:GetChild("txtCardType")
    self.m_score=self.m_view:GetChild("score")
    --大盲标识
    self.m_xiaoMang=self.m_view:GetChild("xiaoMang")
    --小盲标识
    self.m_daMang=self.m_view:GetChild("daMang")
    self.m_bet=self.m_view:GetChild("bet")
    --牌
    self.m_settlementCard1=self.m_view:GetChild("settlementCard1")
    self.m_settlementCard2=self.m_view:GetChild("settlementCard2")
    self.m_settlementBG=self.m_view:GetChild('settlementBG')
    --是否是主动亮牌的标记 Show card
    self.m_showCardActive = self.m_view:GetController("active_show")

    self.m_winLogo=self.m_view:GetChild("winLogo")
    self.m_txtWinScore=arg.txtWinScore
    self.m_shouCard1=self.m_view:GetChild("shouCard1")
    self.m_shouCard2=self.m_view:GetChild("shouCard2")
    self.m_patterns=self.m_view:GetChild("patterns")

    self.m_cardLogo1=self.m_view:GetChild("cardLogo1")
    self.m_cardLogo2=self.m_view:GetChild("cardLogo2")

    self.m_duanyu=arg.duanyu
    self.m_biaoQing=self.m_view:GetChild("iconBiaoQing")
    self.m_btnSetDown.onClick:Add(function ()
        local _ch = self.m_expectSitDownChair
        --print('点击坐下:'.._ch)
        UIManager.Show('ControllerAddCM',function ()
            local msg = Protol.GameBaseMsg_pb.UserSitdownRequst()
		    msg.tableid = -1
		    msg.seatid = _ch
		    local pb_data = msg:SerializeToString()
		    NetManager.SendMessage(GameServerConfig.logic,'UserSitdownRequst', pb_data)
        end)
    end)

    self.m_frame.onClick:Add(function ()
        --print('点击玩家头像,查看玩家信息')
        if self.m_baseData and self.m_baseData.seatid then
            local msg = Protol.Poker_pb.GetUserInfo()
            msg.seatid = self.m_baseData.seatid
            msg.userid = self.m_baseData.userid
            msg.info = ''
            NetManager.SendNetMsg(GameServerConfig.logic,'RequestClickShowPlayerInfo', msg:SerializeToString())
        end
    end)

    self.m_choumaParent=arg.choumaParent

    self.m_guang=self.m_view:GetChild('guang')

    self.m_comFanHuan=self.m_view:GetChild('comFanHuan')

    self:InitLookCard()
end

function H_TexasPlayer:ClickShowPlayerInfo()
    if loginSucceedInfo.user_info.userid ~= self:GetUserID() then
        UIManager.Show('ControllerPlayerInfo',{userid=self:GetUserID(),info=json.decode(self.m_baseData.info)})
    end
end

--预期服务器椅子.理论等于坐下玩家chair
--只用在玩家第一次椅子分配
function H_TexasPlayer:SetExpectSitDownChair(expectSitDownChair)
    self.m_expectSitDownChair=expectSitDownChair
end

function H_TexasPlayer:GetExpectSitDownChair()
    return self.m_expectSitDownChair
end

--设置玩家椅子
function H_TexasPlayer:SetChair(chair)
    self.m_chair = chair
end

function H_TexasPlayer:GetChair()
    return self.m_chair
end

--设置玩家userID
function H_TexasPlayer:SetUserID(userID)
    self.m_userID=userID
end

function H_TexasPlayer:GetUserID()
    return self.m_userID
end

function H_TexasPlayer:GetBaseData()
    return self.m_baseData
end

--设置显示玩家的基础数据(不含游戏内相关的数据)
function H_TexasPlayer:SetBaseData(data)
    self.m_baseData = data
    self.m_btnSetDown.visible = false
    self:SetChair(data.seatid)
    self:SetUserID(data.userid)

    local _info = json.decode(data.info)
    self.m_nickName.text = _info.nickname
    self.m_nickName.visible = true
    self.m_nameBg.visible = true

    --wx头像连接
    self.m_head:GetChild("icon").asLoader.url = GetPlayerHeadUrl(_info.headurl, _info.faceID)

    -- 头像框
    local frame_id = _info.vipFaceFrameID
    self.m_frame.asLoader.url = Bag_Config[frame_id and frame_id or 0].url

    self.m_head.visible=true
    --玩家身上的筹码
    self.m_score.text=''
    if data.gold then
        self.m_score.text=formatVal(data.gold)
    end

    self.m_has_check_card = false
    self.m_husheng_count = _info.bHushengFu and tonumber(_info.bHushengFu) or 0
    self.m_card_type.selectedIndex = 2

    self.m_score.visible = true
end

function H_TexasPlayer:GetDateHeadUrlAndName()
    local _info = json.decode(self.m_baseData.info)
    return { nickname = _info.nickname, headurl = _info.headurl }
end

function H_TexasPlayer:ClickPlayerData(data)
    self.m_baseData.info = data.info
end

--设置玩家身上的筹码/下注时也将更新
function H_TexasPlayer:SetGold(val)
    self.m_baseData.gold = val
    self.m_score.text = formatVal(self.m_baseData.gold)
    if self:GetUserID() == loginSucceedInfo.user_info.userid then
        gameMoney = self.m_baseData.gold
    end
    --print(debug.traceback('userid:'..self.m_userID..'筹码:'..self.m_baseData.gold))
end
function H_TexasPlayer:AddGold(val)
    self.m_baseData.gold = self.m_baseData.gold + val
    self:SetGold(self.m_baseData.gold)
end

--设置庄家的标识
function H_TexasPlayer:SetBankerIcon(isMark)
    self.m_banker.visible=isMark
end

--设置小盲的标识
function H_TexasPlayer:SetXiaoMangIcon(isMark)
    self.m_xiaoMang.visible=isMark
end

--设置大盲的标识
function H_TexasPlayer:SetDaMangIcon(isMark)
    self.m_daMang.visible=isMark
end

--设置玩家手牌
function H_TexasPlayer:SetShouPai(data,isTurn)
    self.m_shouCard1.visible=true
    UIManager.SetPoker(self.m_shouCard1,data[1],isTurn)

    self.m_shouCard2.visible=true
    UIManager.SetPoker(self.m_shouCard2,data[2],isTurn)
end

-- 查看手牌的时候，亮出手里的牌
function H_TexasPlayer:LookShowShouPai()
    if not self.m_shouCard1.visible then
        self.m_shouCard1.visible = true
        self.m_shouCard2.visible = true
    end

    if self.m_settlementCard1.visible then
        self.m_settlementCard1.visible = false
        self.m_settlementCard2.visible = false
    end
end

--设置下注
function H_TexasPlayer:SetBetWithRecoverScene(val)
    self.m_bet.visible=true
    self.m_betVal=val
    self.m_bet:GetChild("betText").text=formatVal(self.m_betVal)
    --local cmLs=CalcFlyCM(val,gameData.xmgold)
    local cmLs=CalcFlyCM(val,gameData.xmgold)

    local  toPos=self.m_effParent:GlobalToLocal(self.m_bet:GetChild('betBg'):LocalToGlobal(Vector2.zero))
    H_EffManager.FlyBetChip2WithRecoverScene({
        flyCMLs=self.m_currCMLs,
        cmLs=cmLs,
        effParent=self.m_effParent,
        toPos=toPos,
        scale=self.m_view.scale,
        maxCount=5
    })
end

-- 全下
function H_TexasPlayer:AddBetWithAllIn()
   self:AddBetWithAni(self.m_baseData.gold)
end

--设置下注带动画
function H_TexasPlayer:AddBetWithAni(val)
    self.m_bet.visible = true
    self.m_betVal = self.m_betVal + val
    self.m_bet:GetChild("betText").text = formatVal(self.m_betVal)
    self:AddGold(val * -1)

    local fromPos = self.m_effParent:GlobalToLocal(self.m_head:LocalToGlobal(Vector2.zero))
    local toPos = self.m_effParent:GlobalToLocal(self.m_bet:GetChild('betBg'):LocalToGlobal(Vector2.zero))

    local cmLs=CalcFlyCM(val,gameData.xmgold)
    
    H_EffManager.FlyBetChip2({
        flyCMLs=self.m_currCMLs,
        cmLs=cmLs,
        effParent=self.m_effParent,
        fromPos=fromPos,
        toPos=toPos,
        scale=self.m_view.scale,
        speed=800
    })
    --F_SoundManager.instance:PlayEffect('chouMaXiaZhu');
    F_SoundManager.instance:PlayEffect('chiptodesk')
end

--得到玩家下注值
function H_TexasPlayer:GetBetVal()
    return self.m_betVal
end

--下一轮下注前清空数据
function H_TexasPlayer:ClearBet()
    self.m_betVal=0
    self.m_bet.visible=false
    self.m_state.visible=false
    self.m_head.grayed=false

    --发公共牌时会清空下的筹码信息
    if self.m_operationType == OperationType_QiPai then
        self.m_state.visible = true
        self.m_head.grayed = true
    end
end

--手上的筹码飞到奖池上
function H_TexasPlayer:ClearBetAndFly(toPos)
    self:ClearBet()
    local _d=H_EffManager.FlyBetChip2ToPondList({
        flyCMLs = self.m_currCMLs,
        toPos = toPos,
        speed = 1000,
        fromPos = self.m_effParent:GlobalToLocal(self.m_bet:GetChild('betBg'):LocalToGlobal(Vector2.zero)),
    })
    for i,v in pairs(self.m_currCMLs) do
        table.insert(self.m_flyCMLs,v)
    end
    self.m_currCMLs={}
    return _d
end

--播放筹码动画使用
function H_TexasPlayer:GetBetPos()
    return self.m_effParent:GlobalToLocal(self.m_bet:GetChild('betBg'):LocalToGlobal(Vector2.zero))
end

--"空","过牌","跟注","加注","弃牌","全押"
function H_TexasPlayer:SetOperationState(operationType)
    self.m_state.visible=true
    self.m_state:GetController('c1').selectedIndex=OperationType_Image_Dic[operationType]
    if operationType==OperationType_AllIn then
        self.m_allInEffect.visible=true

        self.m_cardLogo1.visible=false
        self.m_cardLogo2.visible=false

        if not F_Util.isWin()  then
            self.m_nickName.visible=false
            self.m_nameBg.visible=false
            self.m_score.visible=false
        end
    end
    if operationType==OperationType_QiPai then
        self.m_head.grayed=true
    end
    self.m_operationType=operationType
end

function H_TexasPlayer:GetOperationType()
    return self.m_operationType
end

-- 游戏结算
function H_TexasPlayer:SetGameOverCardInfo(data)
    if data.cards and data.cards[1] and data.cards[1]>0  then
        self.m_settlementCard1.visible=true
        self.m_settlementCard2.visible=true
        UIManager.SetPoker(self.m_settlementCard1,data.cards[1])
        UIManager.SetPoker(self.m_settlementCard2,data.cards[2])

        if data.cardkind<=0 then
            self.m_cardType.visible=false
            self.m_settlementBG.visible=false
        else
            self.m_cardType.visible=true
            self.m_settlementBG.visible=true
            self.m_cardType:GetController('c1').selectedIndex=data.cardkind
        end

        self.m_showCardActive.selectedIndex = (data.status and data.status <= 1) and data.status or 0
    end

    self:HideCardLogo()
    self.m_patterns.visible=false
    self.m_state.visible=false
    self.m_shouCard1.visible=false
    self.m_shouCard2.visible=false

    self.m_xiaoMang.visible=false
    self.m_daMang.visible=false
    self.m_banker.visible=false
    self.m_allInEffect.visible=false

    self:SetPlyCardTypeEmpty()
end

--筹码信息
function H_TexasPlayer:SetGameOverDataInfo(data,sum,goldtype)
    self:SetGold(data.totalgold)
    if sum>0 then
        if goldtype==1 then
            self.m_winLogo.visible=true
        else
            self.m_comFanHuan.visible=true
        end
        self.m_txtWinScore.text=string.format("+%s",formatVal(sum))
        self.m_txtWinScore.visible=true
        self.m_guang.visible=true
    end
end

function H_TexasPlayer:HideGameOverDataInfo()
    self.m_winLogo.visible=false
    self.m_txtWinScore.visible=false
    self.m_guang.visible=false
    self.m_choumaParent.visible=false
    self.m_comFanHuan.visible=false
end

function H_TexasPlayer:PlayChouMaEff()
    self.m_choumaParent.visible=true
    if self.m_comChouMa_gw then
        self.m_comChouMa_gw:Dispose()
    end
    self.m_comChouMa_gw=UIManager.SetDragonBonesAniObjPos2('choumaObj',self.m_choumaParent,Vector3.New(70,70,70))

end

--结算时将手牌信息移动
function H_TexasPlayer:SetMySelfSettlementCard()
    self.m_settlementCard1.visible=true
    self.m_settlementCard2.visible=true
    
    UIManager.SetPoker(self.m_settlementCard1,tonumber(self.m_shouCard1.data))
    UIManager.SetPoker(self.m_settlementCard2,tonumber(self.m_shouCard2.data))

    self:HideCardLogo()
    self.m_patterns.visible=false
    self.m_state.visible=false
    self.m_shouCard1.visible=false
    self.m_shouCard2.visible=false

    self.m_xiaoMang.visible=false
    self.m_daMang.visible=false
    self.m_banker.visible=false
    self.m_allInEffect.visible=false
end

--全部 all in 直接结算
function H_TexasPlayer:SetAllUserAllInCard(card1, card2)
    self.m_settlementCard1.visible=true
    self.m_settlementCard2.visible=true

    UIManager.SetPoker(self.m_settlementCard1, card1)
    UIManager.SetPoker(self.m_settlementCard2, card2)

    self:HideCardLogo()
    self.m_patterns.visible=false
    self.m_state.visible=false
    self.m_shouCard1.visible=false
    self.m_shouCard2.visible=false

    self.m_xiaoMang.visible=false
    self.m_daMang.visible=false
    self.m_banker.visible=false
    self.m_allInEffect.visible=false
end

--设置结算为第一
function H_TexasPlayer:SetOne()
    self.m_settlementCard1:GetController("cShowFrame").selectedIndex=1
    self.m_settlementCard2:GetController("cShowFrame").selectedIndex=1
end

function H_TexasPlayer:HideCardLogo()
    self.m_cardLogo1.visible=false
    self.m_cardLogo2.visible=false
end

--播放发牌/弃牌动画使用
function H_TexasPlayer:GetCardLogo1()
    return self.m_cardLogo1
end

function H_TexasPlayer:GetCardLogo2()
    return self.m_cardLogo2
end

--设置为准备
function H_TexasPlayer:SetIsPrepare(isMark)
    self.m_isPrepare = isMark
end

function H_TexasPlayer:GetIsPrepare()
    return self.m_isPrepare
end

--------------------------------- 看手牌的功能 ---------------------------------
function H_TexasPlayer:InitLookCard()
    -- 查看剩余手牌功能 1
    self.m_husheng_count = 0
    self.m_check_card_cost = 0     -- 看牌花费
    self.m_check_card_count = 0    -- 看牌剩余次数
    self.m_has_check_card = false  -- 是否以看过手牌的判断
    self.m_card_type = self.m_view:GetController("card_type")
    self.m_protect_time = self.m_view:GetChild("txtProtectTime")
    self.m_card_type.selectedIndex = 2

    self.m_view:GetChild("btnLook").onClick:Add(function ()
        if tonumber(loginSucceedInfo.user_info.viptime) > 0 then
            if self.m_check_card_count == 0 then
                UIManager.AddPopTip({ strTit = '亲爱的玩家，您的查看卡已经用完了' })
                return
            end

            if self.m_has_check_card then
                UIManager.AddPopTip({ strTit = '亲爱的玩家，您已经看过该玩家手牌了' })
                return
            end

            if loginSucceedInfo.user_info.gold < self.m_check_card_cost then
                UIManager.AddPopTip({ strTit = string.format('亲爱的玩家，您的金币不足[color=#E6BC57]%s[/color]',formatVal(self.m_check_card_cost)) })
                return
            end

            local tips_str = string.format("你强制查看对方手牌消耗：%s金币 + 1张查看卡",
                    self.m_check_card_cost == 0 and "首次免费" or  formatVal(self.m_check_card_cost))

            UIManager.AddPopTip({ strTit = tips_str })

            local msg = Protol.Poker_pb.C_SeeOtherCard()
            msg.userid = self:GetUserID()
            local pb_data = msg:SerializeToString()
            NetManager.SendNetMsg(GameServerConfig.logic, 'DZPK_RequestSeeOtherCard', pb_data)
        else
            UIManager.AddPopTip({ strTit = '亲爱的玩家，你还不是VIP月卡用户，暂时无法使用此功能。' })
        end
    end)

    self.m_view:GetChild("btnProtect").onClick:Add(function ()
        if loginSucceedInfo.user_info.userid == self:GetUserID() then
            UIManager.AddPopTip({ strTit = '亲爱的玩家，您拥有护身卡，对方无法强制查看您的手牌' })
        else
            UIManager.AddPopTip({ strTit = '玩家使用了护身卡，你无法强制查看对方手牌' })
        end
    end)

    self.m_view:GetChild("btnProtectSelf").onClick:Add(function ()
        if loginSucceedInfo.user_info.userid == self:GetUserID() then
            UIManager.AddPopTip({ strTit = '亲爱的玩家，您拥有护身卡，对方无法强制查看您的手牌' })
        else
            UIManager.AddPopTip({ strTit = '玩家使用了护身卡，你无法强制查看对方手牌' })
        end
    end)
end

function H_TexasPlayer:CheckPropCardStatus(count, cost)
    self.m_check_card_count = count
    self.m_check_card_cost = cost
    if loginSucceedInfo.user_info.userid ~= self:GetUserID() then
        if not self.m_has_check_card then
            self.m_card_type.selectedIndex = self.m_husheng_count > 0 and 1 or 0
        else
            self.m_card_type.selectedIndex = 2
       end
    else
        self.m_card_type.selectedIndex = 2
    end
end

function H_TexasPlayer:SetLookPlyCardRes(card_list, card_type)
    self.m_has_check_card = true
    self:SetShouPai(card_list, true)
    if card_type and card_type > 0 then
        self:SetCardKind(card_type)
    end
    self.m_card_type.selectedIndex = 2
end

function H_TexasPlayer:SetPlyCardTypeEmpty()
    self.m_card_type.selectedIndex = 2
end

function H_TexasPlayer:ClearPropCardStatus()
    self.m_has_check_card = false
    self.m_card_type.selectedIndex = 2
end

-- 检查自己是否有护身卡
function H_TexasPlayer:CheckSelfHuSheng()
    self.m_card_type.selectedIndex = self.m_husheng_count > 0 and 3 or 2
    if tonumber(loginSucceedInfo.user_info.hushengEndTime) > 0 and self.m_husheng_count > 0 then
        self.m_protect_time.text =string.format( "到期时间:%s",os.date("%Y-%m-%d %H:%M:%S", tonumber(loginSucceedInfo.user_info.hushengEndTime)))
    else
        self.m_protect_time.text = ""
    end
end

function H_TexasPlayer:Hide()
    self:HideWithAgain()
    self.m_head.visible=false
    self.m_frame.asLoader.url = ""
    self.m_btnSetDown.visible=false
    self.m_nameBg.visible=false
    self.m_nickName.visible=false
    self.m_score.visible=false
    self.m_baseData=nil
    self:SetChair(-1)
    self:SetUserID(-1)
    self.m_duanyu.visible=false
    self.m_biaoQing.visible=false
    self.m_isPrepare=false
    self.m_husheng_count = 0
    self.m_card_type.selectedIndex = 2
    self.m_showCardActive.selectedIndex = 0
end

function H_TexasPlayer:HideWithAgain()
    self.m_shouCard1.visible=false
    self.m_shouCard2.visible=false
    self.m_settlementCard1.visible=false
    self.m_settlementCard2.visible=false
    self.m_settlementBG.visible=false
    self.m_winLogo.visible=false
    self.m_txtWinScore.visible=false
    self.m_bet.visible=false
    self.m_state.visible=false
    self.m_head.grayed=false
    self.m_cardType.visible=false
    self.m_xiaoMang.visible=false
    self.m_daMang.visible=false
    self.m_banker.visible=false
    self.m_allInEffect.visible=false
    self.m_patterns.visible=false
    self:SetThinking(-1)
    self:HideCardLogo()
    self.m_jiangchi=nil
    --当ALL IN时，头像处的 昵称 金币数，以及背牌，都取消，只显示头像以及 ALL IN 字样 以及特效。
    if self.m_operationType==OperationType_AllIn then
        self.m_nickName.visible=true
        self.m_nameBg.visible=true
        self.m_score.visible=true
    end
    self.m_operationType=nil
    self:ClearBet()
    
    for i,v in ipairs(self.m_flyCMLs) do
        H_ComPoolManager.RemoveComToPool(v)
    end
    self.m_flyCMLs={}

    for i,v in ipairs(self.m_currCMLs) do
        H_ComPoolManager.RemoveComToPool(v)
    end
    self.m_currCMLs={}

    self.m_choumaParent.visible=false

    self.m_guang.visible=false
    self.m_comFanHuan.visible=false
    self.m_showCardActive.selectedIndex = 0
end

--显示坐下按钮
function H_TexasPlayer:ShowBtnSetDown()
    self.m_btnSetDown.visible = true
end

function H_TexasPlayer:HideBtnSetDown()
    self.m_btnSetDown.visible = false
end

function H_TexasPlayer:GetHasPlayer()
    return self.m_btnSetDown.visible
end

function H_TexasPlayer:RequestSitDown()
    local msg = Protol.GameBaseMsg_pb.UserSitdownRequst()
    msg.tableid = -1
    msg.seatid = self.m_expectSitDownChair
    local pb_data = msg:SerializeToString()
    NetManager.SendMessage(GameServerConfig.logic,'UserSitdownRequst', pb_data)
end

--显示玩家出手倒计时
function H_TexasPlayer:SetThinking(countdown)
    if self.m_timerCountdown then
        self.m_timerCountdown:Stop()
    end
    countdown=countdown or waitOutCard
    if countdown==-1 then
        self.m_thinking.visible=false
        self.m_play2Eff=false
    else
        --播放2秒音效
        self.m_play2Eff=true
        self.m_thinking.visible=true
        self.m_countdown=countdown
        --print('countdown:'..countdown)
        self.m_timerCountdown=Timer.New(function ()
            self.m_countdown=self.m_countdown-Time.unscaledDeltaTime
            self.m_countdown=math.max(0,self.m_countdown)
            local _v=self.m_countdown/waitOutCard
            self.m_thinking.value=_v*100

            local _v2=math.rad(360-_v*360-90)

            self.m_thinkingDianParent.xy=Vector2(self.m_thinkingCenter.x+math.cos(_v2)*110,
            self.m_thinkingCenter.y+math.sin(_v2)*110)

            if self.m_play2Eff and  self.m_countdown<=2 then
                self.m_play2Eff=false
                F_SoundManager.instance:PlayEffect('8106');

                H_EventDispatcher:dispatchEvent({name='playnvheguan'})  
            end
        end,0.01,-1,true)
        self.m_timerCountdown:Start()
    end
end

--设置自己的牌型
function H_TexasPlayer:SetSelfCardkind(cardkind)
    if self.m_operationType==OperationType_QiPai then
        return
    end
    self:SetCardKind(cardkind)
end

-- 这是牌型
function H_TexasPlayer:SetCardKind(cardkind)
    self.m_patterns.visible = true
    self.m_patterns:GetChild('n23'):GetController('c1').selectedIndex = cardkind
end

--设置交互短语
function H_TexasPlayer:SetDuanYu(index)
    self:SetChat(DuanYuMap[index][2])
    F_SoundManager.instance:PlayEffect(DuanYuMap[index][3])
end

function H_TexasPlayer:SetChat(content)
    self.m_duanyu.visible=true
    self.m_duanyu:GetChild("title").text=content
    local trans = self.m_duanyu:GetTransition("t0")
    trans:Play()
end

--设置交互表情
function H_TexasPlayer:SetBiaoQing(index)
    local face_info = FaceDic[index..'_Obj']
    if not face_info then
        return
    end
    if self.m_timerBiaoQing then
        self.m_timerBiaoQing:Stop()
    end
    if self.m_bqgw then
        self.m_bqgw:Dispose()
        self.m_bqgw=nil
    end

    local face_scale = face_info.is_vip and Vector3.New(90,90,90) or Vector3.New(150,150,150)
    self.m_biaoQing.visible=true
    self.m_bqgw = UIManager.SetDragonBonesAniObjPos2(face_info.name, self.m_biaoQing:GetChild('n0'), face_scale)
    self.m_timerBiaoQing=Timer.New(function ()
        self.m_biaoQing.visible=false
    end,3,1)
    self.m_timerBiaoQing:Start()
    
    --self.m_view:GetTransition("t0"):Play()
end

return H_TexasPlayer