local ControllerTexas = class("ControllerTexas")
local H_TexasPlayer = require("Controller/Texas/H_TexasPlayer")
local H_TexasBtn = require("Controller/Texas/H_TexasBtn")
local H_TexasChat = require("Controller/Texas/H_TexasChat")
local H_TexasGuess = require("Controller/Texas/H_TexasGuess")
local H_TexasHongBao = require("Controller/Texas/H_TexasHongBao")
local H_TexasBetControl = require("Controller/Texas/H_TexasBetControl")
local H_TexasPondList = require("Controller/Texas/H_TexasPondList")
local Pos5P = {4,6,0,8,2}
local Pos6P = {4,5,6,0,1,2}
local Pos9P = {4,5,7,6,0,8,3,1,2}
--最大人数
local MaxP=9
--结算时特殊牌型的显示,顺序与显示对应
local CT_Special_Dic = {
    [CT_SINGLE] = 0,--单牌
    [CT_ONE_LONG] = 0,--对子
    [CT_TWO_LONG] = 0,--两对
    [CT_THREE_TIAO] = 0,--三条
    [CT_SHUN_ZI] = 0,--顺子
    [CT_TONG_HUA] = 4,--同花
    [CT_HU_LU] = 0,--葫芦
    [CT_TIE_ZHI] = 3,--铁支
    [CT_TONG_HUA_SHUN] = 2,--同花顺
    [CT_KING_TONG_HUA_SHUN] = 1,--皇家同花顺
}

--结算时特殊牌型的spine动画
local CT_Special_Dic_Spine_Ani = {
    [CT_TIE_ZHI] = 'ziObj1',--铁支
    [CT_HU_LU] = 'ziObj2',--葫芦
    [CT_TONG_HUA_SHUN] = 'ziObj3',--同花顺
    [CT_SHUN_ZI] = 'ziObj4',--顺子
    [CT_KING_TONG_HUA_SHUN] = 'ziObj5',--皇家同花顺
    [CT_TONG_HUA] = 'ziObj6',--同花
}
--数字变化次数
local ChangeCount = 15
function ControllerTexas:Init()
	self.m_view = UIPackage.CreateObject('texas','texasView').asCom
	UIManager.normal:AddChild(self.m_view)
	--适配刘海屏水滴屏
    UIManager.AdaptiveAllotypy(self.m_view)
    self.m_view.visible = false
    self.m_content = self.m_view:GetChild('content')
    --飞道具层级
    self.m_propLayer = self.m_content:GetChild("prop")
    self.m_friend_tips = self.m_content:GetChild("friend_tips")
    self.m_propLayer:AddChild(self.m_friend_tips)
    self.m_friend_tips.visible = false
    self.m_players = { }
    for i = 0, MaxP - 1 do
        local _p = H_TexasPlayer.new()
        _p:Init({
            view = self.m_content:GetChild("Item"..i),
            pos = i,
            effParent = self.m_propLayer,
            duanyu = self.m_content:GetChild("comDuanYu"..i),
            txtWinScore = self.m_content:GetChild("txtWinScore"..i),
            choumaParent = self.m_content:GetChild("chouMaParent"..i)
        })
        table.insert(self.m_players, _p)
    end

    --猜一猜的功能
    self.m_exasGuess = H_TexasGuess.new()
    self.m_exasGuess:Init({ view = self.m_view:GetChild("guess").asCom,controllerGuess = self.m_view:GetController("cShowGuess")})

    -- 红包功能
    self.m_texasHongBao = H_TexasHongBao.new()
    local hong_bao_arg =
    {
        view = self.m_view:GetChild("hongbao").asCom,
        controllerHongBao = self.m_view:GetController("showHongBao"),
    }
    self.m_texasHongBao:Init(hong_bao_arg)

    --下注控制
    self.m_texasBetControl = H_TexasBetControl.new()
    self.m_texasBetControl:Init({view=self.m_content:GetChild('btnControl'),controller=self})

    --聊天显示
    self.m_texasChat = H_TexasChat.new()
    self.m_texasChat:Init(self)

    --界面内其它按钮显示
    self.m_texasBtn = H_TexasBtn.new()
    self.m_texasBtn:Init(self)

    --牌桌奖池列表
    self.m_texasPondList = H_TexasPondList.new()
    self.m_texasPondList:Init(self)

    --房间号ID
    self.m_roomNameAndID = self.m_content:GetChild("txtRoomNameAndID")
    --等待游戏开始提示
    self.m_waitGameStart = self.m_content:GetChild("txtWaitGameStart")
    --显示盲注前注信息
    self.m_littleBlindAndLargeBlindAnDante = self.m_content:GetChild("txtLittleBlindAndLargeBlindAnDante")
    --补充筹码按钮
    self.m_btnAddCM = self.m_content:GetChild("btnAddCM")
    self.m_btnAddCM.visible = false
    --查看剩余牌
    self.m_lookRemainCard = self.m_content:GetChild("btnLook")
    self.m_lookRemainNum = self.m_lookRemainCard:GetChild("cost")
    self.m_lookRemainCard.visible = false
    --猜手牌
    self.m_btn_guess = self.m_content:GetChild("btnGuess")
    --当前加注
    self.m_followJet = self.m_content:GetChild("followJet")
    --牌桌底池
    self.m_txtTotalPool = self.m_content:GetChild("txtTotalPool")
    --公共牌列表
    self.m_publicCards = self.m_content:GetChild("publicCards")
    --当前出手玩家
    self.m_controllerPointer = self.m_content:GetController("cPointer")
    --结算特殊牌型提示
    self.m_settlement = self.m_content:GetChild("settlement")
    --结算黑色遮罩
    self.m_SettlementBG = self.m_content:GetChild("SettlementBG")
    --开始洗牌动画
    self.m_startAni = self.m_content:GetChild("startAni")
    self.m_startAniU3dObj = UIManager.SetDragonBonesAniObjPos('armatureName_xipai',self.m_startAni,Vector3.New(50,50,50))
    self.m_startAni.visible = false
    --自己是否参与游戏初始化
    self.m_self_gaming = false
    -- 比赛场的实例化
    self:InitMatchMangZhu()
    -- 换手牌的实例化
    self:InitChangeHandCard()
    self:AddEventListener()
    -- 自动坐下
    self:InitAutomaticSitDown()
    -- 背景桌子
    self.m_view_bg_slt = self.m_view:GetController("cBG")
    self.m_cont_bg_slt = self.m_content:GetController("cBG")
    self:Clear()
    --数据
    self.roomInfo = nil
    -- 顶部金币信息
    self.m_coinNum = self.m_content:GetChild("coin_num")
    --用户进场退场数据队列
    self.serverDataList = nil
    --是否在换椅子中
    self.isChangLocalChair = false
    --底池
    self.server_pool_bet = 0
    -- 最小跟注
    self.m_fallow_min = 0
    -- 最小加注
    self.m_add_min = 0

    --todo 需要考虑切后台
    Timer.New(function ()
        --换位置
        if not self.isChangLocalChair and self.serverDataList ~= nil and #self.serverDataList > 0 then
            local _t = self.serverDataList[1]
            table.remove(self.serverDataList,1)
            local msgType = _t.msgType
            local msg = _t.msg

            if msgType == 'UserSitdownBroadcast' then
                self:Handle_UserSitdownBroadcast(msg)
            elseif msgType == 'UserSitupBroadcast' then
                self:Handle_UserSitupBroadcast(msg)
            elseif msgType == 'ExitGameBroadcast' then
                self:Handle_ExitGameBroadcast(msg)
            elseif msgType == 'ClickShowPlayerInfo' then
                self:Handle_ClickShowPlayerInfo(msg)
            end
        end

        --中奖财神
        if self.m_caishenData and #self.m_caishenData > 0 and not self.m_isCaishen and self.m_isCanCaiShen then
            local msg=self.m_caishenData[1]
            table.remove( self.m_caishenData,1 )
            self.m_isCaishen=true

            local _list = self.m_content:GetChild('listCaiShen').asList
            _list:RemoveChildrenToPool()
            for k, v in ipairs(msg.potinfo) do
                local _p = self:GetPlayerWithUserID(v.userid)
                if _p then
                    self.m_content:GetController('c2').selectedIndex=1
                    local _comCaiShen=_list:AddItemFromPool()
                    _comCaiShen:GetChild('n90').text=string.format("恭喜[color=#FF0000]%s[/color]中得%s分得奖金[color=#FFB400]%s[/color]",_p.m_nickName.text,CT_Chinese_Dic[v.cardtype],v.wingold)
                    
                    --飞金币
                    local cmLs=CalcFlyCM(v.wingold,gameData.xmgold)
                    local fromPos=self.m_propLayer:GlobalToLocal(self.m_content:GetChild('prizePool'):LocalToGlobal(Vector2.zero))
                    local toPos=self.m_propLayer:GlobalToLocal(_p.m_head:LocalToGlobal(Vector2.zero))
                    for i=1,#cmLs do
                        local comChip = H_ComPoolManager.GetComFromPool("texas", "flyChip2")
                        self.m_propLayer:AddChild(comChip)
                        comChip.position = fromPos
                        comChip.visible = false
                        comChip:GetController('c1').selectedIndex=cmLs[i]
                        local _t = Vector2.Distance(fromPos, toPos)/800
                        comChip:TweenMove(toPos,_t):SetEase(EaseType.CubicOut):SetDelay(0.08*(i-1)):OnStart(function ()
                            comChip.visible = true
                        end):OnComplete(function ()
                            H_ComPoolManager.RemoveComToPool(comChip)
                        end)
                    end
                end
                
            end
            
            if self.m_caishenTimer then
                self.m_caishenTimer:Stop()
            end
            self.m_caishenTimer=Timer.New(function ()
                self.m_content:GetController('c2').selectedIndex=0
                self.m_isCaishen=false
            end,3,1)
            self.m_caishenTimer:Start()
        end
    end,0.01,-1):Start()

    --初始化踢人界面
    UIManager.InitController('ControllerOutPlayer')

    --加载音效
    loadSoundEffects()

    --荷官spine
    self.m_content:GetChild('humen').visible=false
    local nvheguanOBJ=UIManager.SetDragonBonesAniObjPos('nvheguan',self.m_content:GetChild("btnHumen"),Vector3.New(150,150,150))
    self.m_nvheguan_skeletonAnimation=nvheguanOBJ.gameObject:GetComponent('Spine.Unity.SkeletonAnimation')

    --滚动公告
    self.m_noticescroll = self.m_content:GetChild('noticescroll')
    self.m_noticescroll.visible = false
    self.m_noticescrollText = self.m_noticescroll:GetChild('noticeMiddle'):GetChild('notcieText'):GetChild('text')
    self.m_noticescrollData = { }
    self.m_noticescrollMove = false
    Timer.New(function ()
        if #self.m_noticescrollData>0 and not self.m_noticescrollMove then
            if self.m_noticescrollData[1].count<=0 then
                table.remove(self.m_noticescrollData,1)
                if #self.m_noticescrollData <= 0 then
                    self.m_noticescroll.visible = false
                end
            else
                self.m_noticescrollData[1].count = self.m_noticescrollData[1].count - 1
                self.m_noticescrollMove = true
                self.m_noticescroll.visible = true
                self.m_noticescrollText.text = self.m_noticescrollData[1].content
                self.m_noticescrollText.x = 1000--self.m_noticescroll.width
                local _duration = (self.m_noticescrollText.width + self.m_noticescroll.width)/200
                -- self.m_noticescrollText.width*-1
                self.m_noticescrollText:TweenMoveX(-1100, _duration):SetEase(EaseType.Linear):OnComplete(function ()
                    self.m_noticescrollMove = false
                end)
            end
        end
    end,0.5,-1):Start()

    --钞票
    self.chaopiao = UIManager.SetDragonBonesAniObjPos2('chaopiaoObj',self.m_content:GetChild("chaopiaoParent"),Vector3.New(120,120,120))
    self.chaopiao.visible = false
    self.chaopiao_val = 0
    H_EventDispatcher:addEventListener('playWen',function (arg)
        if arg.isMark then
            self.chaopiao_val = self.chaopiao_val + 1
            self.chaopiao.visible = true
        else
            self.chaopiao_val = self.chaopiao_val - 1
            if self.chaopiao_val <= 0 then
                self.chaopiao.visible = false
            end
        end
    end)

    -- 红包的动画
    self.hongBaoObj = UIManager.SetDragonBonesAniObjPos('hongbaoOBJ', self.m_content:GetChild("hongBaoPos"), Vector3.New(22,22,22)).gameObject
    local skeleton_anim = self.hongBaoObj:GetComponent('Spine.Unity.SkeletonAnimation')
    skeleton_anim.skeleton:SetToSetupPose()
    skeleton_anim.state:ClearTracks()
    skeleton_anim.state:SetAnimation(0, 'start01', true)
    self.hongBaoObj:SetActive(false)

    self.hongBaoTxtObj = self.m_content:GetChild("txtHongBao")
    self.hongBaoTxtObj.visible = false
end

--ClickShowPlayerInfo
function ControllerTexas:Handle_ClickShowPlayerInfo(msg)
    if msg.seatid==-1 then
        return
    end
    local _player = self:GetPlayerWithExpectSitDownChair(msg.seatid)
    if not _player then
        return
    end
    _player:ClickPlayerData({ seatid = msg.seatid, userid = msg.userid, info = msg.info, })
    _player:ClickShowPlayerInfo()
end

function ControllerTexas:Handle_UserSitdownBroadcast(msg)
    --被房间踢出的用户,请求坐下无效
    if msg.seatid==-1 then
        return
    end
    local _player = self:GetPlayerWithExpectSitDownChair(msg.seatid)

    if not _player then
        return
    end

    _player:SetBaseData({
        seatid=msg.seatid,
        userid=msg.userid,
        faceID=msg.faceID,
        info=msg.info,
    })
    local _info = json.decode(msg.info)
    _player:SetGold(_info.bringcoin)
    if msg.userid == loginSucceedInfo.user_info.userid then
        for i,v in pairs(self.m_players) do
            v:HideBtnSetDown()
        end
        self:SetChair(msg.seatid)
        --在GameReadyBroacast消息之后加入游戏并成功
        if self.m_waitGameStart.visible then
            self:ChangePosCalc(true)
        end
        self:ShowAutomaticSit(false)
    end
end

function ControllerTexas:Handle_UserSitupBroadcast(msg)
    --隐藏站起玩家显示坐下按钮
    for i,v in ipairs(self.m_players) do
        if v:GetUserID()==msg.userid then
            v:Hide()
        end
    end
    if msg.userid == loginSucceedInfo.user_info.userid then
        self:SetChair(-1)
        self.m_self_gaming = false
        self:ShowAutomaticSit(true)
    end
    local _ps = self:GetSitChairNumTab()
    if _ps then
        if self:GetChair()==-1 then
            for i,v in ipairs(self.m_players) do
                if v:GetChair()==-1 then
                    for i2,v2 in ipairs(_ps) do
                        if v.m_pos==v2 then
                            v:ShowBtnSetDown()
                        end
                    end
                end
            end
        end
    end

    --ab两个玩家游戏,b退出定时器清空场景数据.此时考虑结算信息的显示
    --不需要显示结算了
    if self.m_waitPersonTime then
        self.m_waitPersonTime:Start()
    end
    self.m_waitPersonTime=Timer.New(function ()
        local _p=0
        for i,v in ipairs(self.m_players) do
            if v:GetChair()~=-1 then
                _p=_p+1
            end
        end
        if _p<2 then
            self:Clear(true)
        end
    end,0.01,1)
    self.m_waitPersonTime:Start()
end

function ControllerTexas:Handle_ExitGameBroadcast(msg)
    for i,v in ipairs(self.m_players) do
        if v:GetUserID()==msg.userid then
            v:Hide()
        end
    end

    local _ps = self:GetSitChairNumTab()
    if self:GetChair()==-1 then
        for i,v in ipairs(self.m_players) do
            if v:GetChair()==-1 then
                for i2,v2 in ipairs(_ps) do
                    if v.m_pos==v2 then
                        v:ShowBtnSetDown()
                    end
                end
            end
        end
    end

    --ab两个玩家游戏,b退出定时器清空场景数据.此时考虑结算信息的显示
    --不需要显示结算了
    if self.m_waitPersonTime then
        self.m_waitPersonTime:Start()
    end

    self.m_waitPersonTime=Timer.New(function ()
        local _p=0
        for i,v in ipairs(self.m_players) do
            if v:GetChair()~=-1 then
                _p=_p+1
            end
        end
        if _p<2 then
            self:Clear(true)
        end
    end,0.01,1)

    self.m_waitPersonTime:Start()

    if loginSucceedInfo.user_info.userid == msg.userid then
        self:SetChair(-1)
        self.m_self_gaming = false
        --从游戏返回游戏大厅跳过刷新
        F_SoundManager.instance:StopPlayEffect()
        self.isRePrizePool = false

        -- 比赛场
        self:HideMangZhuPanel()
        self:CloseMatchMangZhuCd()
        self.m_has_rank = false
        self.m_btn_add.visible = false
        self.temp_mangzhu_num = 0
        self.temp_qianzhu_num = 0
        self.m_competition_rank.text = ""
        -- 看手牌
        self:HideChangeHandCard()
        self:HideLookCard()
        UIManager.Hide('ControllerTexas')

        if roomCfg.is_competition then
            if not roomCfg.is_change_table then
                UIManager.Show('ControllerHall')
            end
            roomCfg.is_change_table = false
        else
            UIManager.Show('ControllerGameHall',{ isSkipRefresh = false })
        end
    end
end

function ControllerTexas:ClearStartAni()
    H_EffManager.ClearFlyCardWithStartGame()
    H_EffManager.ClearQiCardWithStartGame()
    self.m_startAni.visible=false
    for i,v in pairs(self.m_players) do
        v:HideCardLogo()
    end
end

function ControllerTexas:AddEventListener()
    -------------------GameBaseMsg_pb消息
    --玩家付费聊天/打赏
    H_NetMsg:addEventListener('UserInteractionResponse',function (arg)
        --print('收到消息 玩家付费聊天/打赏 UserInteractionResponse')
        local msg = Protol.Poker_pb.UserInteractionResponse()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        if msg.ret == 1 then
            local msgUserChat = Protol.GameBaseMsg_pb.UserChat()
            msgUserChat.senduserid=0
            msgUserChat.targetuserid=-1
            msgUserChat.jsoninfo=msg.interaction_infos
            local pb_data = msgUserChat:SerializeToString()
            NetManager.SendMessage(GameServerConfig.logic,'UserChat',pb_data)
            --刷新玩家筹码
            local ply = self:GetPlayerWithUserID(loginSucceedInfo.user_info.userid)
            if ply then
                local _info = json.decode(msg.interaction_infos)
                if _info then
                    ply:AddGold(_info.chips * -1)
                end
            end
        else
            UIManager.AddPopTip({strTit='发送打赏或使用交互表情失败'})
        end
    end)

    --玩家聊天
    H_NetMsg:addEventListener('UserChat',function (arg)
        --print('收到消息 UserChat')
        local msg = Protol.GameBaseMsg_pb.UserChat()
        msg:ParseFromString(arg.pb_data)
        local senduserid = tonumber(msg.senduserid)

        if senduserid and senduserid== 100 then
            local _info = json.decode(msg.jsoninfo)
            --table.insert(self.m_noticescrollData,{content=string.format("[color=#FFB400]%s:　　[/color]%s",_info.nickname,_info.context),count=1})
            local content = ""
            if _info.nickname and string.len(_info.nickname) > 0 then
                -- 玩家
                content = string.format("[color=#FFFF00]%s[/color]:%s", _info.nickname, _info.context)
            else
                -- 系统
                content = string.format("[color=#FFFF00]%s[/color]", _info.context)
            end
            table.insert(self.m_noticescrollData,{ content = content , count = 1 })
        end

        local _info = json.decode(msg.jsoninfo)

        if not _info then
            return
        end

        local info_type = tonumber(_info.mtype)

        if not info_type then
            return
        end

        if info_type == 10001 then
            local info_c = tonumber(_info.c)
            if info_c then
                if info_c == 2 then
                    return
                end
                -- 一共就 12 个交互动画
                if info_c <= 12 then
                    local ply_from = self:GetPlayerWithUserID(_info.from)
                    local ply_to = self:GetPlayerWithUserID(_info.to)
                    if ply_from and ply_to then
                        local fromPos = ply_from.m_head:LocalToGlobal(Vector2.zero)
                        local toPos = ply_to.m_head:LocalToGlobal(Vector2.zero)
                        H_EffManager.FlyProp({
                            effParent = self.m_propLayer,
                            fromPos = self.m_propLayer:GlobalToLocal(fromPos),
                            toPos = self.m_propLayer:GlobalToLocal(toPos),
                            propIndex = info_c
                        })
                    end
                end
            end
        --聊天短语
        elseif info_type == 10002 then
            --print("_info.from:".._info.from)
            --for i,v in pairs(self.m_players) do
            --    v:SetDuanYu(_info.c)
            --end
            local ply = self:GetPlayerWithUserID(_info.from)
            if ply then
                local msg_chat_info = ply:GetDateHeadUrlAndName()
                msg_chat_info.context = DuanYuMap[_info.c][2]
                self.m_texasChat:AddPrivateChat(msg_chat_info, _info.from)
                self:GetPlayerWithUserID(_info.from):SetDuanYu(_info.c)
            end
        --玩家表情
        elseif info_type == 10003 then
            local ply = self:GetPlayerWithUserID(_info.from)
            if ply then
                ply:SetBiaoQing(_info.c)
            end
        --飞番茄交互等.荷官
        elseif info_type == 10004 then
            local from_ply = self:GetPlayerWithUserID(_info.from)
            if not from_ply then
                return
            end
            local fromPos = from_ply.m_head:LocalToGlobal(Vector2.zero)
            local toPos = self.m_content:GetChild("btnHumen"):LocalToGlobal(Vector2.zero)
            H_EffManager.FlyProp({
                effParent = self.m_propLayer,
                fromPos = self.m_propLayer:GlobalToLocal(fromPos),
                toPos = self.m_propLayer:GlobalToLocal(toPos),
                propIndex = _info.c
            })
            --晃脑袋
            self.m_nvheguan_skeletonAnimation.skeleton:SetToSetupPose()
            self.m_nvheguan_skeletonAnimation.state:ClearTracks()
            self.m_nvheguan_skeletonAnimation.state:SetAnimation(0, 'suiji3', false)

            self.m_nvheguan_skeletonAnimation.state.Complete=self.m_nvheguan_skeletonAnimation.state.Complete-self.m_nvheguanCallback
            self.m_nvheguan_skeletonAnimation.state.Complete=self.m_nvheguan_skeletonAnimation.state.Complete+self.m_nvheguanCallback
        --玩家手动输入
        elseif info_type == 10005 then
            --print(tostring(_info))
            local ply_from = self:GetPlayerWithUserID(_info.from)
            if ply_from then
                local msg_chat_info = ply_from:GetDateHeadUrlAndName()
                msg_chat_info.context = _info.c
                self.m_texasChat:AddPrivateChat(msg_chat_info, _info.from)
                ply_from:SetChat(_info.c)
            end
        --打赏kiss
        elseif info_type == 10006 then
            local ply_to = self:GetPlayerWithUserID(_info.from)
            if not ply_to then
                return
            end

            local toPos = self.m_propLayer:GlobalToLocal(ply_to.m_head:LocalToGlobal(Vector2.zero))
            local fromPos= self.m_propLayer:GlobalToLocal(self.m_content:GetChild("btnHumen"):LocalToGlobal(Vector2.zero))
            --local chouMaEndPos = self.m_txtTotalPool:LocalToGlobal(Vector2.zero)
            -- self.m_content:GetChild("btnKiss"):LocalToGlobal(Vector2.zero)
            --self.m_propLayer:GlobalToLocal(chouMaEndPos),
            H_EffManager.FlyKiss({
                effParent = self.m_propLayer,
                fromPos = fromPos,
                toPos = toPos,
                chouMaEndPos = fromPos + Vector2(0,85)
            })
            self.m_nvheguan_skeletonAnimation.skeleton:SetToSetupPose()
            self.m_nvheguan_skeletonAnimation.state:ClearTracks()
            self.m_nvheguan_skeletonAnimation.state:SetAnimation(0, 'dashang', false)

            self.m_nvheguan_skeletonAnimation.state.Complete=self.m_nvheguan_skeletonAnimation.state.Complete-self.m_nvheguanCallback
            self.m_nvheguan_skeletonAnimation.state.Complete=self.m_nvheguan_skeletonAnimation.state.Complete+self.m_nvheguanCallback
        end
    end)

    self.m_nvheguanCallback=function (state,trackIndex,loopCount)
        --待机
        self.m_nvheguan_skeletonAnimation.skeleton:SetToSetupPose()
        self.m_nvheguan_skeletonAnimation.state:ClearTracks()
        self.m_nvheguan_skeletonAnimation.state:SetAnimation(0, 'suiji2', true)
    end

    H_EventDispatcher:addEventListener('playnvheguan',function (arg)
        --晃脑袋
        self.m_nvheguan_skeletonAnimation.skeleton:SetToSetupPose()
        self.m_nvheguan_skeletonAnimation.state:ClearTracks()
        self.m_nvheguan_skeletonAnimation.state:SetAnimation(0, 'suiji3', false)

        self.m_nvheguan_skeletonAnimation.state.Complete=self.m_nvheguan_skeletonAnimation.state.Complete-self.m_nvheguanCallback
        self.m_nvheguan_skeletonAnimation.state.Complete=self.m_nvheguan_skeletonAnimation.state.Complete+self.m_nvheguanCallback
    end)

    --玩家进入游戏返回
    H_NetMsg:addEventListener('EnterGameReponse',function (arg)
        if GameSubType ~= GameType.RoomHall then
            return
        end

        local msg = Protol.GameBaseMsg_pb.EnterGameReponse()
        msg:ParseFromString(arg.pb_data)
        if self.paoche then
            self.paoche:Dispose()
            self.paoche = nil
        end

        if tonumber(loginSucceedInfo.user_info.viptime) > 0 and PlayerPrefs.GetInt("jinchangEff",1) > 0 then
            self.paoche=UIManager.SetDragonBonesAniObjPos2('paocheObj',self.m_content:GetChild("paocheParent"),Vector3.New(120,120,120))
            F_SoundManager.instance:PlayEffect('paoCheJinRuChang')
        end

        self.m_coinNum.text = formatVal(loginSucceedInfo.user_info.gold)

        self.m_nvheguan_skeletonAnimation.skeleton:SetToSetupPose()
        self.m_nvheguan_skeletonAnimation.state:ClearTracks()
        --待机
        self.m_nvheguan_skeletonAnimation.state:SetAnimation(0, 'suiji2', true)

        UIManager.Hide('ControllerWaitTip')
        self.serverDataList = nil
        self.serverDataList = {}

        gameData = nil
        gameData = {}
        self.m_caishenData = { }
        self.m_content:GetController('c2').selectedIndex = 0
        self:Clear()
        gameData.dasang_fee = msg.dasang_fee
        gameData.emotion_fee = msg.emotion_fee

        self.m_content:GetChild('humenProp'):GetChild('txtGiftPriceTips').text = string.format( "(%s金币每次)", gameData.emotion_fee )

        --设置房间信息
        self.m_roomNameAndID.text=string.format( "%s", roomCfg.tablename)

        if not roomCfg.is_competition then
            if roomCfg.frontbet > 0 then
                self.m_littleBlindAndLargeBlindAnDante.text=string.format("房间ID：%s 盲注：%s/%s 前注：%s", roomCfg.tableid, formatVal(roomCfg.xiaomangbet), formatVal(roomCfg.xiaomangbet*2), formatVal(roomCfg.frontbet))
            else
                self.m_littleBlindAndLargeBlindAnDante.text=string.format("房间ID：%s 盲注：%s/%s",roomCfg.tableid, formatVal(roomCfg.xiaomangbet), formatVal(roomCfg.xiaomangbet*2))
            end
        end

        UIManager.Hide('ControllerGameHall')

        self:Show()

        --分配椅子
        local _ps = self:GetSitChairNumTab()
        if not _ps then
            return
        end

        --显示椅子上的坐下按钮
        self:HideAllPlayer()
        for i,v in pairs(self.m_players) do
            for i2, v2 in ipairs(_ps) do
                if v.m_pos==v2 then
                    v:ShowBtnSetDown()
                end
            end
        end

        --显示坐下玩家的信息
        self:SetChair(msg.seatid)
        self.m_self_gaming = false

        for i,v in pairs(self.m_players) do
            v:SetExpectSitDownChair(-1)
        end

        --玩家未坐下
        local is_self_not_sit = self:GetChair() == -1
        self:ShowAutomaticSit(is_self_not_sit)
        if is_self_not_sit then
            --设置预期椅子
            local _serverIndex=0
            for i,v in ipairs(_ps) do
                local _player=self:GetPlayerWithPos(v)
                _player:SetExpectSitDownChair(_serverIndex)
                _serverIndex=_serverIndex+1
            end

            for i,v in ipairs(msg.users) do
                local _player = self:GetPlayerWithExpectSitDownChair(v.seatid)
                if _player then
                    _player:SetBaseData({
                        seatid=v.seatid,
                        userid=v.userid,
                        faceID=v.faceID,
                        info=v.info,
                    })
                    local _info = json.decode(v.info)
                    _player:SetGold(_info.bringcoin)
                end
            end
        else
            --将本地0号放最前面
            local _len=#_ps
            for i=1,_len do
                if _ps[1]~=0 then
                    local _pos=_ps[1]
                    table.remove(_ps,1)
                    table.insert(_ps,_pos)
                end
            end
            --设置预期椅子
            local _serverIndex=msg.seatid
            for i,v in ipairs(_ps) do
                local _player=self:GetPlayerWithPos(v)
                _player:SetExpectSitDownChair(_serverIndex)
                _serverIndex=(_serverIndex+1)%_len
            end
            --自己的信息
            local _player_self=self:GetPlayerWithExpectSitDownChair(msg.seatid)
            _player_self:SetBaseData({
                seatid=msg.seatid,
                userid=msg.userid,
                faceID=msg.faceID,
                info=msg.info,
                gold=msg.gold,
            })
            local _info_self = json.decode(msg.info)
            _player_self:SetGold(_info_self.bringcoin)

            for i,v in ipairs(msg.users) do
                local _player=self:GetPlayerWithExpectSitDownChair(v.seatid)
                _player:SetBaseData({
                    seatid=v.seatid,
                    userid=v.userid,
                    faceID=v.faceID,
                    info=v.info,
                })
                local _info=json.decode(v.info)
                _player:SetGold(_info.bringcoin)
            end
            for i,v in pairs(self.m_players) do
                v:HideBtnSetDown()
            end
        end
        self.isRePrizePool = true
        self:RePrizePool()
    end)

    self.m_texasBtn.m_prizePoolTxt = self.m_texasBtn.m_prizePool:GetChild('txtValue')
    Timer.New(function ()
        if self.isRePrizePool then
            self:RePrizePool(true)
        end
    end, 10, -1):Start()

    --广播玩家准备
    H_NetMsg:addEventListener('BeReadyBroadcast',function (arg)
        --print('收到消息 BeReadyBroadcast')
        local msg = Protol.GameBaseMsg_pb.BeReadyBroadcast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))

    end)

    --广播玩家进入游戏 暂时不做处理
    H_NetMsg:addEventListener('EnterGameBroadcast',function (arg)
        --print('收到消息 EnterGameBroadcast')
        local msg = Protol.GameBaseMsg_pb.EnterGameBroadcast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
    end)

    --广播用户坐下
    H_NetMsg:addEventListener('UserSitdownBroadcast',function (arg)
        --print('收到消息 UserSitdownBroadcast')
        local msg = Protol.GameBaseMsg_pb.UserSitdownBroadcast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        if self.isChangLocalChair then
            --队列处理数据
            table.insert(self.serverDataList,{msgType='UserSitdownBroadcast',msg=msg})
        else
            self:Handle_UserSitdownBroadcast(msg)
        end
    end)

    --新加 + 玩家点击头像刷新玩家数据
    H_NetMsg:addEventListener('RespondClickShowPlayerInfo',function (arg)
        --print('收到消息 UserSitdownBroadcast')
        local msg = Protol.Poker_pb.GetUserInfo()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        if self.isChangLocalChair then
            table.insert(self.serverDataList,{ msgType='ClickShowPlayerInfo', msg = msg })--队列处理数据
        else
            self:Handle_ClickShowPlayerInfo(msg)
        end
    end)

    --广播用户站起
    H_NetMsg:addEventListener('UserSitupBroadcast',function (arg)
        --print('收到消息 广播用户站起')
        local msg = Protol.GameBaseMsg_pb.UserSitupBroadcast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        if self.isChangLocalChair then
            --队列处理数据
            table.insert(self.serverDataList,{msgType='UserSitupBroadcast',msg=msg})
        else
            self:Handle_UserSitupBroadcast(msg)
        end
    end)

    --广播玩家退出游戏返回大厅广播
    H_NetMsg:addEventListener('ExitGameBroadcast',function (arg)
        --print('收到消息 广播玩家退出游戏返回大厅广播')
        local msg = Protol.GameBaseMsg_pb.ExitGameBroadcast()
        msg:ParseFromString(arg.pb_data)
        -- 自己退出，仅仅刷一次
        if loginSucceedInfo.user_info.userid ~= msg.userid then
            self:ReceiveExitGame(msg)
        end
    end)

    --广播玩家断线 暂时不做处理
    H_NetMsg:addEventListener('UserStatusBroadcast',function (arg)
        --print('收到消息 UserStatusBroadcast')
        local msg = Protol.GameBaseMsg_pb.UserStatusBroadcast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
    end)

    --服务器主动踢人 暂时不做处理
    H_NetMsg:addEventListener('0X18',function (arg)
        --print('收到消息 0X18')
    end)

    -------------------Poker_pb消息
    H_NetMsg:addEventListener('GameReadyBroacast',function (arg)
        --print('收到消息 GameReadyBroacast')
        local msg = Protol.Poker_pb.GameReadyBroacast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        self.m_isCanCaiShen=false
        self.m_caishenData={}
        if self.m_waitPersonTime then
            self.m_waitPersonTime:Stop()
        end

        self:Clear(true)
        self.m_waitGameStart.visible=true
        --播放1秒龙骨帧动画
        self.m_startAni.visible=true
        self.m_startAniU3dObj:GetComponent('DragonBones.UnityArmatureComponent').animationPlayer:Play()
        F_SoundManager.instance:PlayEffect('faPaiYinXiao')

        self:CloseLookRemainCard()     -- 关闭查看剩余牌

        --游戏开始时刷新玩家身上筹码数,服务器扣了前注/大小盲
        for i, v in ipairs(msg.infos) do
            local _info = json.decode(v)
            if _info then
                local _p = self:GetPlayerWithUserID(_info.userid)
                if _p then
                    _p:SetGold(_info.bringcoin)
                    _p:ClearPropCardStatus()
                end
            end
        end
        --交换位置!!!服务器需要留够动画时间
        self:ChangePosCalc()
    end)

    --游戏开始
    H_NetMsg:addEventListener('GameStartBroacast',function (arg)
        --print('收到消息 GameStartBroacast')
        local msg = Protol.Poker_pb.GameStartBroacast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        gameData.seq = msg.seq
        waitOutCard = msg.actiontime/1000
        self.m_texasBtn:ShowBtnMessageRecord(true)
        self.m_content:GetController('c2').selectedIndex = 0

        --立即结束换位置的动画
        self:ChangePosCalc(true)
        self.m_waitGameStart.visible = false
        --设置庄家标识
        self:GetPlayerWithUserID(msg.hostid):SetBankerIcon(true)
        --小盲标识
        self:GetPlayerWithUserID(msg.xmuserid):SetXiaoMangIcon(true)
        --大盲标识
        self:GetPlayerWithUserID(msg.dmuserid):SetDaMangIcon(true)
        --自己在参与游戏判断
        self.m_self_gaming = gameData.chair > 0 and true or false
        self:ClearStartAni()
        --设置一次发手牌
        self.m_isFaShouPai = true
        -- 关闭查看剩余手牌
        self:CloseLookRemainCard()
        -- 关闭比赛场的购买
        self.m_btn_add.visible = false
        -- 刷新盲注
        self:UpdateMangZhuNum()
        -- 关掉开启的等待界面
        UIManager.Hide('ControllerCompetitionWait')
        --小盲金币数
        gameData.xmgold = msg.xmgold
        gameData.currmaxgold = msg.xmgold * 2

        self.gameStartBroacastMsg = msg

        self:SetTotalPool(0)
        for i,v in pairs(self.m_players) do
            if v:GetChair() ~= -1 then
                v:SetIsPrepare(true)
            end
        end

        --必下前注更新玩家头像的分数
        if msg.frontbet>0 then
            --添加一个下前注的动画
            local _val=0
            for i,v in pairs(self.m_players) do
                if v:GetChair()~=-1 and v:GetIsPrepare() then
                    v:AddBetWithAni(msg.frontbet)
                    self:AddTotalPool(msg.frontbet)
                    _val=_val+msg.frontbet
                end
            end
            --数据结构为服务器,广播边池的结果
            local _bianchibet={_val}

            if self.startGameFlyCmTimer then
                self.startGameFlyCmTimer:Stop()
            end
            self.startGameFlyCmTimer=Timer.New(function ()
                self.m_texasPondList:SetWithMsg({bianchibet=_bianchibet})
            end,1,1)
            self.startGameFlyCmTimer:Start()
        end

        --更新底池
        self:AddTotalPool(self.gameStartBroacastMsg.xmgold)
        self:AddTotalPool(self.gameStartBroacastMsg.xmgold*2)

        F_SoundManager.instance:PlayEffect('oncountdown_music')
    end)

    --发玩家手牌
    H_NetMsg:addEventListener('FaShouPai',function (arg)
        --print('收到消息 FaShouPai')
        local msg = Protol.Poker_pb.FaShouPai()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        gameData.seq = msg.seq
        self.m_texasBtn:ShowBtnMessageRecord(true)
        self.server_pool_bet = msg.totalbetscore
        self.m_fallow_min = msg.turnlessscore
        self.m_add_min = msg.addlessscore
        if self.startGameFlyCmTimer then
            self.startGameFlyCmTimer:Stop()
        end
        if msg.userid==loginSucceedInfo.user_info.userid then
            self.m_shouPaiData=msg.cards
        end
        if self.m_isFaShouPai then
            self.m_isFaShouPai=false
            --print('发牌动画开始')
            --发手牌动画
            local toPosList1={}
            local toPosList2={}
            for i,v in pairs(self.m_players) do
                local _p=v
                if _p:GetChair()~=-1 and _p:GetIsPrepare() then
                    table.insert(toPosList1,{
                        toPos=self.m_propLayer:GlobalToLocal(_p:GetCardLogo1():LocalToGlobal(Vector2.zero)),
                        callback=function ()
                            _p:GetCardLogo1().visible=true
                        end,
                        gobj=_p:GetCardLogo1()
                    })
                    table.insert(toPosList2,{
                        toPos=self.m_propLayer:GlobalToLocal(_p:GetCardLogo2():LocalToGlobal(Vector2.zero)),
                        callback=function ()
                            _p:GetCardLogo2().visible=true
                        end,
                        gobj=_p:GetCardLogo2()
                    })
                end
            end

            H_EffManager.FlyCardWithStartGame({
                toPosList1=toPosList1,
                toPosList2=toPosList2,
                effParent=self.m_propLayer,
                fromPos=self.m_propLayer:GlobalToLocal(self.m_startAni:LocalToGlobal(Vector2.zero)),
                callback=function ()

                    local xmuserid_ply = self:GetPlayerWithUserID(self.gameStartBroacastMsg.xmuserid)
                    if xmuserid_ply then
                        xmuserid_ply:AddBetWithAni(self.gameStartBroacastMsg.xmgold)
                    end

                    local dmuserid_ply = self:GetPlayerWithUserID(self.gameStartBroacastMsg.dmuserid)
                    if dmuserid_ply then
                        dmuserid_ply:AddBetWithAni(self.gameStartBroacastMsg.xmgold*2)
                    end

                    self:HandleOp(self.gameStartBroacastMsg)
                    if self.m_shouPaiData then
                        local _p = self:GetPlayerWithUserID(loginSucceedInfo.user_info.userid)
                        if _p then
                            _p:SetShouPai(self.m_shouPaiData, true)
                            if not roomCfg.is_competition then
                                self:ShowChangeHandCard()
                            end
                        end
                    end
                end
            })

            self.m_startAni.visible=false
        end
    end)

    --弃牌广播
    H_NetMsg:addEventListener('QiPaiBroadcast',function (arg)
        --print('收到消息 QiPaiBroadcast')
        local msg = Protol.Poker_pb.QiPaiBroadcast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        --print("弃牌后的金币数:msg.selfscore:"..msg.selfscore)
        gameData.seq = msg.seq
        self.server_pool_bet = msg.totalbetscore
        self.m_fallow_min = msg.turnlessscore
        self.m_add_min = msg.addlessscore

        local ply = self:GetPlayerWithUserID(msg.userid)

        if not ply then
            return
        end

        if msg.userid == loginSucceedInfo.user_info.userid then
            self.m_isQiPai = true
            ply.m_patterns.visible=false
            self.m_self_gaming = false
            self:UpdateSelfSCoinNum(msg.selfscore)
            self:HideChangeHandCard()
            self.m_texasBtn:ShowBtnMessageRecord(true)
        end
        ply:SetOperationState(OperationType_QiPai)
        self:HandleOp(msg)

        --弃牌动画
        if msg.userid ~= loginSucceedInfo.user_info.userid then
            ply:HideCardLogo()
            --第一张牌
            local c1 = ply:GetCardLogo1()
            H_EffManager.QiCardWithStartGame({
                effParent=self.m_propLayer,
                fromPos=self.m_propLayer:GlobalToLocal(c1:LocalToGlobal(Vector2.zero)),
                toPos=self.m_propLayer:GlobalToLocal(self.m_startAni:LocalToGlobal(Vector2.zero)),
                rotation=c1.rotation
            })
            --第二张牌
            local c2 = ply:GetCardLogo1()
            H_EffManager.QiCardWithStartGame({
                effParent=self.m_propLayer,
                fromPos=self.m_propLayer:GlobalToLocal(c2:LocalToGlobal(Vector2.zero)),
                toPos=self.m_propLayer:GlobalToLocal(self.m_startAni:LocalToGlobal(Vector2.zero)),
                rotation=c2.rotation
            })
        end
        F_SoundManager.instance:PlayEffect(USER_STATUS_GAME__SOUND_DIC[USER_STATUS_GAME_QIPAI])
    end)

    --跟注广播
    H_NetMsg:addEventListener('GenZhuBroadcast',function (arg)
        --print('收到消息 GenZhuBroadcast')
        local msg = Protol.Poker_pb.GenZhuBroadcast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        gameData.seq = msg.seq
        self.server_pool_bet = msg.totalbetscore
        self.m_fallow_min = msg.turnlessscore
        self.m_add_min = msg.addlessscore
        local _p = self:GetPlayerWithUserID(msg.userid)
        if _p then
            _p:SetOperationState(OperationType_GenZhu)
            local _v = msg.gold - _p:GetBetVal()
            _p:AddBetWithAni(_v)
            self:AddTotalPool(_v)
            self:HandleOp(msg)
            gameData.currmaxgold = math.max(gameData.currmaxgold,msg.gold)

            F_SoundManager.instance:PlayEffect(USER_STATUS_GAME__SOUND_DIC[USER_STATUS_GAME_GENZHU])

            self:NvHeGuanXiaZhu()
        end

        if msg.userid == loginSucceedInfo.user_info.userid then
            self.m_texasBtn:ShowBtnMessageRecord(true)
            self:HideChangeHandCard()
        end
    end)

    --加注广播
    H_NetMsg:addEventListener('JiaZhuBroadcast',function (arg)
        --print('收到消息 JiaZhuBroadcast')
        local msg = Protol.Poker_pb.JiaZhuBroadcast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        gameData.seq = msg.seq
        self.server_pool_bet = msg.totalbetscore
        self.m_fallow_min = msg.turnlessscore
        self.m_add_min = msg.addlessscore
        local _p = self:GetPlayerWithUserID(msg.userid)
        if _p then
            _p:SetOperationState(OperationType_JiaZhu)
            local _v = msg.gold - _p:GetBetVal()
            _p:AddBetWithAni(_v)
            self:AddTotalPool(_v)
            self:HandleOp(msg)
            gameData.currmaxgold = math.max(gameData.currmaxgold,msg.gold)

            F_SoundManager.instance:PlayEffect(USER_STATUS_GAME__SOUND_DIC[USER_STATUS_GAME_JIAZHU])
            self:NvHeGuanXiaZhu()
        end

        if msg.userid == loginSucceedInfo.user_info.userid then
            self:HideChangeHandCard()
            self.m_texasBtn:ShowBtnMessageRecord(true)
        end
    end)

    --全下广播
    H_NetMsg:addEventListener('AllInBroadcast',function (arg)
        --print('收到消息 全下广播')
        local msg = Protol.Poker_pb.AllInBroadcast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        gameData.seq = msg.seq
        self.server_pool_bet = msg.totalbetscore
        self.m_fallow_min = msg.turnlessscore
        self.m_add_min = msg.addlessscore
        if msg.userid == loginSucceedInfo.user_info.userid then
            self.m_isAllin = true
            self:HideChangeHandCard()
            self.m_texasBtn:ShowBtnMessageRecord(true)
        end
        local _p = self:GetPlayerWithUserID(msg.userid)
        if _p then
            _p:SetOperationState(OperationType_AllIn)
            local _v = msg.gold - _p:GetBetVal()
            -- all in 的特殊处理
            _p:AddBetWithAllIn(_v)
            self:AddTotalPool(_v)
            self:HandleOp(msg)
            gameData.currmaxgold=math.max(gameData.currmaxgold, msg.gold)

            F_SoundManager.instance:PlayEffect(USER_STATUS_GAME__SOUND_DIC[USER_STATUS_GAME_ALLIN])
            self:NvHeGuanXiaZhu()
        end
    end)

    --让牌广播
    H_NetMsg:addEventListener('GuoPaiBroadcast',function (arg)
        --print('收到消息 GuoPaiBroadcast')
        local msg = Protol.Poker_pb.GuoPaiBroadcast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        gameData.seq=msg.seq
        self.server_pool_bet = msg.totalbetscore
        self.m_fallow_min = msg.turnlessscore
        self.m_add_min = msg.addlessscore

        local ply = self:GetPlayerWithUserID(msg.userid)
        if ply then
            ply:SetOperationState(OperationType_GuoPai)
        end

        self:HandleOp(msg)

        F_SoundManager.instance:PlayEffect(USER_STATUS_GAME__SOUND_DIC[USER_STATUS_GAME_GUOPAI])

        if msg.userid == loginSucceedInfo.user_info.userid then
            self:HideChangeHandCard()
            self.m_texasBtn:ShowBtnMessageRecord(true)
        end
    end)

    --奖池广播
    H_NetMsg:addEventListener('BianChiBroadcast',function (arg)
        --print('收到消息 BianChiBroadcast')
        local msg = Protol.Poker_pb.BianChiBroadcast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        self.m_texasPondList:SetWithMsg(msg)
        self:SetTotalPool(msg.totalgold)
    end)

    -- 看牌的费用
    H_NetMsg:addEventListener('DZPK_ReceiveLookCost',function (arg)
        --print('收到消息 是否可以看牌的费用')
        local msg = Protol.Poker_pb.UserCanSeePublicCard()
        msg:ParseFromString(arg.pb_data)
        self.m_lookRemainCard.visible = true
        local cost_coin = tonumber(msg.seeleftpubliccardscore)
        self.m_lookRemainNum.text = cost_coin == 0 and "本次免费" or string.format("消耗:%s金币", formatVal(cost_coin))
    end)

    -- 看牌的结果
    H_NetMsg:addEventListener('DZPK_ReceiveLookCard',function (arg)
        --print('收到消息 是否可以看牌的协议')
        self:CloseLookRemainCard()
        local msg = Protol.Poker_pb.UserSeePublicCard()
        msg:ParseFromString(arg.pb_data)
        if msg.ret == 0 then
            self:UpdateSelfSCoinNum(msg.selfscore)
            local card_length = #msg.publiccards
            if not self.m_publicCards.visible then
                self.m_publicCards.visible = true
            end

            local _p = self:GetPlayerWithUserID(loginSucceedInfo.user_info.userid)
            if _p then
                _p:LookShowShouPai()
            end

            if card_length == 5 then
                for i = 1, 5 do
                    local _com = self.m_publicCards:GetChild('card'..i)
                    local _timer = Timer.New(function ()
                        _com.visible = true
                        UIManager.SetPoker(_com, msg.publiccards[i],true)
                        F_SoundManager.instance:PlayEffect('fanPai')
                    end, 0.1 * (i - 1), 1)
                    _timer:Start()
                    table.insert( self.m_timerYinXiaos, _timer)
                end
            elseif card_length == 2 then
                local count_index = 1
                for i = 4, 5 do
                    local _com = self.m_publicCards:GetChild('card'..i)
                    if _com.visible == false then
                        _com.visible = true
                        UIManager.SetPoker(_com, msg.publiccards[count_index],true)
                        F_SoundManager.instance:PlayEffect('fanPai')
                        count_index = count_index + 1
                    end
                end
            elseif card_length == 1 then
                local _com = self.m_publicCards:GetChild('card5')
                if _com.visible == false then
                    _com.visible = true
                    UIManager.SetPoker(_com, msg.publiccards[1],true)
                    F_SoundManager.instance:PlayEffect('fanPai')
                end
            end
        end
    end)

    --游戏结算广播
    H_NetMsg:addEventListener('GameOverBroadcast',function (arg)
        --print('收到消息 游戏结算广播')
        local msg = Protol.Poker_pb.GameOverBroadcast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        self.m_texasBetControl:HideMyOpenBtn()
        self.m_texasBetControl:HideAutoOpen()
        self.m_texasBetControl:HideSettlementIsShow()
        self.m_texasBtn:ShowBtnMessageRecord(true)
        self:SetCountdownAndPointer(-1)
        self.m_self_gaming = false

        self:HideChangeHandCard()
        self:HideLookCard()

        --显示玩家最终的牌
        --todo 包含自己的牌/包含弃牌选择亮牌的玩家
        local _isMark = true
        for i, v in ipairs(msg.usercards) do
            local _p = self:GetPlayerWithUserID(v.userid)
            if _p then
                _p:SetGameOverCardInfo(v)
            end

            if _isMark and v.userid == loginSucceedInfo.user_info.userid then
                _isMark = false
            end
        end

        --将自己的牌型显示到一边
        if self.m_shouPaiData ~= nil and self:GetChair() ~= -1 and _isMark then
            local _p = self:GetPlayerWithUserID(loginSucceedInfo.user_info.userid)
            if _p then
                _p:SetMySelfSettlementCard()
            end
        end

        --结算前最终固定每个边池的值
        self.m_texasPondList:PondListFinallyVal()

        self.m_roundsData={}
        self.m_usercards={}

        for i,v in ipairs(msg.rounds) do
            table.insert(self.m_roundsData,v)
        end

        for i,v in ipairs(msg.usercards) do
            self.m_usercards[v.userid] = v
            if v.userid == loginSucceedInfo.user_info.userid then
                self:UpdateSelfSCoinNum(v.selfscore)
            end
        end

        self:PlayGameOverAni()
    end)

    H_NetMsg:addEventListener('PushRecoverScene',function (arg)
        --print('收到消息 PushRecoverScene')
        local msg = Protol.Poker_pb.PushRecoverScene()
        msg:ParseFromString(arg.pb_data)
        self.server_pool_bet = msg.totalbetscore and msg.totalbetscore or 0
        self.m_fallow_min = msg.turnlessscore and msg.turnlessscore or 0
        self.m_add_min = msg.addlessscore and msg.addlessscore or 0
        --print(tostring(msg))
        gameData.seq=msg.seq
        waitOutCard=msg.actiontime or 15
        self:ClearStartAni()
        for i,v in ipairs(msg.cards) do
            self.m_publicCards.visible=true
            local _com=self.m_publicCards:GetChild('card'..i)
            _com.visible=true
            UIManager.SetPoker(_com,v,true)
        end
        --前注值
        local _frontbet=roomCfg.frontbet
        --小盲金币数
        gameData.xmgold=msg.xmgold
        gameData.currmaxgold=msg.currmaxgold
        --设置手牌
        for i,v in ipairs(msg.pokerusers) do
            if v.userid==loginSucceedInfo.user_info.userid then
                self.m_shouPaiData = v.cards

                local ply_self = self:GetPlayerWithUserID(loginSucceedInfo.user_info.userid)
                if ply_self then
                    if v.cards[1] > 0 and v.cards[2] > 0 then
                        ply_self:SetShouPai(v.cards)
                    end

                    if v.cardkind > 0 then
                        ply_self:SetSelfCardkind(v.cardkind)
                    end
                end

                self.m_isQiPai=v.status==USER_STATUS_GAME_QIPAI
                self.m_isAllin=v.status==USER_STATUS_GAME_ALLIN
                self.m_texasBtn:ShowBtnMessageRecord(true)
            end

            local _p = self:GetPlayerWithUserID(v.userid)
            if _p then
                if v.curroundbet > 0 then
                    _p:SetBetWithRecoverScene(v.curroundbet)
                end
                _p:AddGold(v.tempgold * -1)
                _p:AddGold(_frontbet * -1)
                if v.status == USER_STATUS_GAME_QIPAI then
                    _p:SetOperationState(OperationType_QiPai)
                elseif v.status == USER_STATUS_GAME_GENZHU then
                    _p:SetOperationState(OperationType_GenZhu)
                elseif v.status == USER_STATUS_GAME_GUOPAI then
                    _p:SetOperationState(OperationType_GuoPai)
                elseif v.status == USER_STATUS_GAME_JIAZHU then
                    _p:SetOperationState(OperationType_JiaZhu)
                elseif v.status == USER_STATUS_GAME_ALLIN then
                    _p:SetOperationState(OperationType_AllIn)
                end
            end
        end

        --设置庄家标识 小/大盲标识
        if msg.hostid and msg.hostid > 0 then
            local ply = self:GetPlayerWithUserID(msg.hostid)
            if ply then
                ply:SetBankerIcon(true)
            end
        end

        self:HandleOp(msg)
        self:SetTotalPool(msg.totalgold)

        --设置边池
        self.m_texasPondList:SetWithRecoverScene(msg.bianchibet)

    end)

    --repeated int32 userid = 1;
    --repeated int32 cards  = 2;
    H_NetMsg:addEventListener('AllUserAllInCards',function (arg)
        --print('收到消息 AllUserAllInCards')
        local msg = Protol.Poker_pb.AllUserAllInCards()
        msg:ParseFromString(arg.pb_data)
        local ply
        local card1
        local card2
        local move_index = 1
        for i = 1, #msg.userid do
            ply = self:GetPlayerWithUserID(msg.userid[i])
            if ply then
                card1 = msg.cards[move_index]
                move_index = move_index + 1
                card2 = msg.cards[move_index]
                move_index = move_index + 1
                ply:SetAllUserAllInCard(card1, card2)
            end
        end
    end)

    -- 发桌子底牌
    H_NetMsg:addEventListener('FaZhuoZiPaiBroadcast',function (arg)
        --print('收到消息 FaZhuoZiPaiBroadcast')
        local msg = Protol.Poker_pb.FaZhuoZiPaiBroadcast()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        self:HideChangeHandCard()
        self.m_texasBtn:ShowBtnMessageRecord(true)
        gameData.seq = msg.seq
        self.server_pool_bet = msg.totalbetscore
        self.m_fallow_min = msg.turnlessscore
        self.m_add_min = msg.addlessscore
        self.m_publicCards.visible = true
        if msg.cardcount == 3 then
            for i=1,3 do
                local _com=self.m_publicCards:GetChild('card'..i)
                local _timer=Timer.New(function ()
                    _com.visible=true
                    UIManager.SetPoker(_com,msg.cards[i],true)
                    F_SoundManager.instance:PlayEffect('fanPai')
                end,0.1*(i-1),1)
                _timer:Start()
                table.insert( self.m_timerYinXiaos, _timer)
            end
        else
            local mark=true
            for i=4,5 do
                local _com=self.m_publicCards:GetChild('card'..i)
                if _com.visible==false and mark then
                    _com.visible=true
                    UIManager.SetPoker(_com,msg.cards[1],true)
                    mark=false
                    F_SoundManager.instance:PlayEffect('fanPai')
                end
            end
        end
        --设置自己手牌加公共牌能组什么牌型
        local ply = self:GetPlayerWithUserID(loginSucceedInfo.user_info.userid)
        if ply then
            if self:GetChair()~=-1 and ply:GetIsPrepare() then
                --自己在当前局
                if msg.cardkind > 0 then
                    ply:SetSelfCardkind(msg.cardkind)
                end
            end
        end

        self:HandleOp(msg)
        self.m_texasBetControl:SetAutoOpenCode(0)
    end)

    --中奖奖池
    self.m_content:GetController('c2').selectedIndex=0
    UIManager.SetDragonBonesAniObjPos2('caisheObj',self.m_content:GetChild("caishenObjParent"),Vector3.New(160,160,160))

    ---------------------------------------------------------------------------------
    --------------------------------- 看手牌的道具功能 --------------------------------
    -- required int32 seehandcardcount  = 1 ;       //剩余查看卡数量
    -- required int32 fee = 2;                      //当前费用
    -- repeated int32 useridlist  = 3 ;             //可以看其他玩家的ID表
    -- 看其他玩家的手牌
    H_NetMsg:addEventListener('DZPK_ReceiveUpdateSeeOtherCard', function (arg)
        local msg = Protol.Poker_pb.UpdateSeeOtherCard()
        msg:ParseFromString(arg.pb_data)
        -- 可查看手牌的玩家列表
        for i = 1, #msg.useridlist do
            local ply = self:GetPlayerWithUserID(msg.useridlist[i])
            if ply then
                ply:CheckPropCardStatus(msg.seehandcardcount, msg.fee)
            end
        end

        -- 检查自己是否有护身卡
        local ply = self:GetPlayerWithUserID(loginSucceedInfo.user_info.userid)
        if ply then
            ply:CheckSelfHuSheng()
        end
    end)

    -- required int32 userid = 1;               //目标玩家
    -- repeated int32 handcards   = 2;          //手牌
    -- required int64 selfscore = 3;            //玩家身上金币数
    -- required int64 tablemaxscore = 4;        //桌子上最大下注数
    -- required int32 cardtype = 5;             //牌型
    -- 看其他玩家的手牌的结果
    H_NetMsg:addEventListener('DZPK_ReceiveSeeOtherCardResult',function (arg)
        local msg = Protol.Poker_pb.SeeOtherCardResult()
        msg:ParseFromString(arg.pb_data)
        local ply = self:GetPlayerWithUserID(msg.userid)
        if ply then
            ply:SetLookPlyCardRes(msg.handcards, msg.cardtype)
        end
        self:UpdateSelfSCoinNum(msg.selfscore)
    end)

    --required int32 goodid  = 1 ;      // 道具ID
    --required int32 goodcount = 2;     // 数量
    --required int32 goodtype = 3;      //
    -- 获取道具
    H_NetMsg:addEventListener('DZPK_ReceiveUserGetGood',function (arg)
        if not roomCfg.is_competition then
            local msg = Protol.Poker_pb.UserGetGood()
            msg:ParseFromString(arg.pb_data)
            UIManager.Show('ControllerTexasGetItem', { goodid = msg.goodid, goodcount = msg.goodcount })
        end
    end)

    ---------------------------------------------------------------------------------
    ----------------------------------- 换手牌 --------------------------------------
    --required int32  shuaxincardcount  = 1 ;      //剩余刷新卡数量
    --required int32  niubcardcount  = 2 ;      //剩余牛B卡数量
    --required int32 fee = 3;               //当前费用
    -- 换手牌场景信息
    H_NetMsg:addEventListener('DZPK_ReceiveChangeHandCardFeeInfo',function (arg)
        local msg = Protol.Poker_pb.ChangeHandCardFeeInfo()
        msg:ParseFromString(arg.pb_data)
        self:SetChangeHandCardInfo(msg.fee, msg.shuaxincardcount, msg.niubcardcount)
    end)

    -- 换手牌结果
    --required int32  ret  = 1 ;      //0成功 1.失败
    --repeated int32 handcards   = 2;             //手牌
    --required int64 selfscore = 3; //玩家身上金币数
    --required int64 tablemaxscore = 4; //桌子上最大下注数
    H_NetMsg:addEventListener('DZPK_ReceiveChangeHandCardResult',function (arg)
        local msg = Protol.Poker_pb.ChangeHandCardResult()
        msg:ParseFromString(arg.pb_data)
        if msg.ret == 0 then
            if gameData.chair ~= -1 then
                UIManager.AddPopTip({ strTit = '手牌刷新成功！' })
                local ply = self:GetPlayerWithUserID(loginSucceedInfo.user_info.userid)
                if ply then
                    ply:SetShouPai(msg.handcards, true)
                    self:HideChangeHandCard()
                end
            end
            self:UpdateSelfSCoinNum(msg.selfscore)
        else
            UIManager.AddPopTip({ strTit = '换手牌结果错误码：！'..msg.ret})
        end
    end)

    ---------------------------------------------------------------------------------
    ----------------------------------- 比赛场 --------------------------------------
    -- 等待游戏开始
    H_NetMsg:addEventListener('Match_ReceiveWaitScene',function (arg)
        local msg = Protol.DzMatchPb_pb.WaitSceneInfo()
        msg:ParseFromString(arg.pb_data)
        self:HideMangZhuPanel()
        UIManager.Show('ControllerCompetitionWait', { is_play = false, info = msg })
    end)

    -- 比赛场游戏开始
    --required int32 usercount = 1; //玩家数
    --required int32 selfno = 2; //自己排名（观战为0）
    --required int32 updatecellscoreleavetime = 3; //下次升盲时间(秒)
    --required int32 curcellscoreindex = 4; //当前盲注级别
    --required int64 cellscore = 5; //底分
    --required int32 tablecount = 6; //桌子多少
    H_NetMsg:addEventListener('Match_ReceivePlayScene',function (arg)
        local msg = Protol.DzMatchPb_pb.PlaySceneInfo()
        msg:ParseFromString(arg.pb_data)
        -- 开放 panel
        self:ShowMangZhuPanel()
        self:OpenMatchMangZhuCd(msg.updatecellscoreleavetime)
        self:UpdatePlyCount(msg.usercount)
        self:ShowMangZhuNum(msg.curcellscoreindex, tonumber(msg.frontgold))

        -- 我的排名
        self.m_competition_rank.text = string.format("我的排名：%s", msg.selfno == 0 and "无" or msg.selfno)

        -- 决赛圈判断
        self.m_view_bg_slt.selectedIndex = 0
        self.m_cont_bg_slt.selectedIndex = msg.tablecount == 1 and 3 or 4

        UIManager.Show('ControllerCompetitionWait', { is_play = true })
    end)

    -- 更新比赛玩家数量 UpdateUserCount
    --required int32 usercount = 1; //玩家数
    --required int32 selfno = 2; //自己排名（观战为0）
    H_NetMsg:addEventListener('Match_ReceiveUpdateUserCount',function (arg)
        local msg = Protol.DzMatchPb_pb.UpdateUserCount()
        msg:ParseFromString(arg.pb_data)
        self:UpdatePlyCount(msg.usercount)
        -- 我的排名
        self.m_competition_rank.text = string.format("我的排名：%s", msg.selfno == 0 and "无" or msg.selfno)
    end)

    --更新比赛底分 UpdateCellScore
    --required int32 updatecellscoreleavetime = 1; //下次升盲时间(秒)
    --required int64 cellscore = 2; // 下一个盲注的底分
    --required int32 curcellscoreindex = 3; //当前盲注级别
    H_NetMsg:addEventListener('Match_ReceiveUpdateCellScore',function (arg)
        local msg = Protol.DzMatchPb_pb.UpdateCellScore()
        msg:ParseFromString(arg.pb_data)
        self:OpenMatchMangZhuCd(msg.updatecellscoreleavetime)
        self:ShowMangZhuNum(msg.curcellscoreindex, tonumber(msg.frontgold))

        -- 提示：下一个盲注的底分
        UIManager.AddPopTip({ strTit = string.format("下局盲注将升至%s/%s", formatVal(msg.cellscore), formatVal(msg.cellscore * 2)) })
    end)

    -- 换桌通知
    --required int32 type = 1; //1.通知等待换桌 2.换桌完成 3.其他玩家拼桌子
    --required int32 tablecount = 2; //还剩多少桌子
    H_NetMsg:addEventListener('Match_ReceiveUpdateChangeTable',function (arg)
        --print("换桌通知换桌通知")
        roomCfg.is_change_table = true   -- 比赛场的换桌特殊处理
        local msg = Protol.DzMatchPb_pb.UpdateChangeTable()
        msg:ParseFromString(arg.pb_data)
        if msg.type == 1 then
            UIManager.AddPopTip({ strTit = "请耐心等待系统换桌！" })
            UIManager.Show('ControllerCompetitionWait', { is_play = false, info = { starttime = 1200 } })
        elseif msg.type == 2 then
            UIManager.AddPopTip({ strTit = "换桌已完成，游戏马上开始！" })
        elseif msg.type == 3 then
            --UIManager.AddPopTip({ strTit = string.format("您已晋级，请耐心等待系统换桌！", msg.nickname) })
        end

        if msg.tablecount == 1 then
            UIManager.AddPopTip({ strTit = "您已进入决赛局！" })
            self.m_view_bg_slt.selectedIndex = 3
            self.m_cont_bg_slt.selectedIndex = 3
            UIManager.Show('ControllerCompetitionSuccess')
        end
    end)

    -- 被淘汰
    --required int32 userid = 1; //
    --required string nickname = 2; //
    --required int32 paiming = 3; //
    --required int32 rewardscore = 4; //
    --required int32 goodsid = 5; //
    --required int32 goodscount = 6; //
    H_NetMsg:addEventListener('Match_ReceiveUserExitMatch',function (arg)
        --print("被淘汰被淘汰")
        local msg = Protol.DzMatchPb_pb.UserExitMatch()
        msg:ParseFromString(arg.pb_data)
        if msg.userid == loginSucceedInfo.user_info.userid then
            UIManager.Hide('ControllerCompetitionTips')
            self.m_btn_add.visible = false
            if tonumber(msg.rewardscore) > 0 then
                self.m_has_rank = msg.paiming == 1 or msg.paiming == 2
                UIManager.Show('ControllerCompetitionEnd', msg)
            else
                UIManager.Show('ControllerCompetitionFailure')
            end
        else
            if msg.paiming > 1 then  -- 第一名不能给被淘汰的提示
                UIManager.AddPopTip({ strTit = string.format("玩家:[color=#E6BC57]%s[/color]已被淘汰", msg.nickname) })
            end
        end
    end)

    -- 比赛全部结束
    H_NetMsg:addEventListener('Match_ReceiveGameEnd',function (arg)
        if not self.m_has_rank then
            UIManager.Show('ControllerCompetitionTips', { title = "", content = "本场比赛已经结束！", force_exit = true } )
        end
    end)

    -- 购买实时更新
    --required int32 type = 1; //1.rebuy（重购） 2.addon（增购）
    --required int32 bcanbuy = 2; //0:不能买入 1.可以买入
    --required int32 curmatchscore = 3; //当前多少分数
    H_NetMsg:addEventListener('Match_ReceiveUpdateBuyScore',function (arg)
        --print("购买购买购买判断")
        local msg = Protol.DzMatchPb_pb.UpdateBuyScore()
        msg:ParseFromString(arg.pb_data)
        self.m_add_type = msg.type
        self.m_btn_add.visible = msg.bcanbuy == 1
        self.m_btn_add_tips = string.format("%s筹码", self.m_add_type == 1 and "重购" or "增购")
        if msg.curmatchscore == 0 then
            local total_buy_count = self.m_add_type == 1 and roomCfg.rebuyCount or roomCfg.addonCount
            local remain_buy_count = total_buy_count - msg.buycount
            local cont = string.format("点击确定即可%s分数\n[color=#E6BC57]剩余次数：%s / %s[/color]", self.m_add_type == 1 and "重购" or "增购", remain_buy_count, total_buy_count)
            UIManager.Show('ControllerCompetitionTips', { title = "分数不足提示", content = cont, confirm = function()
                local bug_msg = Protol.DzMatchPb_pb.C_UserBuyScore()
                bug_msg.type = self.m_add_type
                NetManager.SendNetMsg(GameServerConfig.logic,'Match_ReqUserBuyScore', bug_msg:SerializeToString())
            end } )
        end
    end)

    -- 购买成功
    --required int32 type = 1; //1.rebuy 2.addon
    --required int32 matchscore = 2; //分数
    H_NetMsg:addEventListener('Match_ReceiveBuyScoreRes',function (arg)
        --print("购买成功购买成功购买成功")
        local msg = Protol.DzMatchPb_pb.BuyScoreRes()
        msg:ParseFromString(arg.pb_data)
        self.m_btn_add.visible = false
        self:UpdateSelfScoreTableScore(msg.score, msg.matchscore)
        UIManager.AddPopTip({ strTit = string.format("%s:[color=#E6BC57]%s[/color]成功！", msg.type == 1 and "重购" or "增购", formatVal(msg.addmatchscore)) })
    end)

    ---------------------------------------------------------------------------------
    ----------------------------------- AA奖励 --------------------------------------
    H_NetMsg:addEventListener('DZPK_ReceiveRewardAA', function (arg)
        local msg = Protol.Poker_pb.AAShouPaiWinRes()
        msg:ParseFromString(arg.pb_data)
        UIManager.Show('ControllerGetAA', { num = formatVal(msg.winscore) })
    end)
end

function ControllerTexas:RePrizePool(istimer)
    --请求奖池
    if not istimer then
        self.m_texasBtn.m_prizePool.visible=false
        self.m_texasBtn.m_prizePool.data=0
    end
    coroutine.start(Jackpot_GetCount,{
        userid = loginSucceedInfo.user_info.userid,
        serverid = GameServerConfig.serverid,
        xiaoMan = roomCfg.xiaomangbet,
        qianzhu = roomCfg.frontbet,
        callbackSuccess=function (info)
            if tonumber(info.jockpot)>0 then
                self.m_texasBtn.m_prizePool.visible = true
                self:SetRolling(tonumber(info.jockpot))
                --self.m_texasBtn.m_prizePool:GetChild('txtValue').text=info.jockpot
                self.m_texasBtn.m_prizePool.data=tonumber(info.jockpot)
            end
        end
    })
end

function ControllerTexas:SetRolling(val)
    if self.m_timerRolling then
        self.m_timerRolling:Stop()
    end
    if val==self.m_texasBtn.m_prizePool.data then
        return
    end
    
    local v=val/ChangeCount
    local curr=0
    local showCurr=0
    local _c=0
    self.m_timerRolling=Timer.New(function ()
        curr=curr+v
        curr=math.min(curr,val)
        showCurr=math.floor(curr)
        self.m_texasBtn.m_prizePoolTxt.text=showCurr

        _c=_c+1
        if _c==ChangeCount then
            self.m_texasBtn.m_prizePoolTxt.text=val
        end
    end,0.01,ChangeCount)
    self.m_timerRolling:Start()
end

function ControllerTexas:PlayGameOverAni()
    if #self.m_roundsData<1 then
        local _timer3 = Timer.New(function ()
            self.m_isCanCaiShen = true
        end, 2, 1)
        _timer3:Start()
        table.insert(self.m_timerFlyPoindList, _timer3)
        --print("结束")
        return
    end

    local v = self.m_roundsData[1]
    table.remove(self.m_roundsData,1)

    for i2,v2 in pairs(self.m_players) do
        self.m_content:SetChildIndex(v2.m_view,self.m_content:GetChildIndex(self.m_SettlementBG)-1)
        v2:HideGameOverDataInfo()
    end

    --参与比牌的玩家数量
    local _sums={}
    for i2,v2 in ipairs(v.winuserdatas) do
        local _sum=0
        for i3,v3 in ipairs(v2.bianchigold) do
            _sum=_sum+v3
        end
        _sums[v2.userid]=_sum
    end

    local _maxUsers={}
    for i2,v2 in ipairs(v.winuserdatas) do
        table.insert(_maxUsers,v2)
    end

    for i2,v2 in ipairs(v.winuserdatas) do
        local _p = self:GetPlayerWithUserID(v2.userid)
        if _p then
            _p:SetGameOverDataInfo(v2,_sums[v2.userid],v.goldtype)
            self.m_content:SetChildIndex(_p.m_view,self.m_content:GetChildIndex(self.m_SettlementBG)+1) --设置层级
        end
    end
    
    self.m_settlement.visible=false
    self.m_SettlementBG.visible=false
    local _comCards =
    {
        self.m_publicCards:GetChild('card1'),
        self.m_publicCards:GetChild('card2'),
        self.m_publicCards:GetChild('card3'),
        self.m_publicCards:GetChild('card4'),
        self.m_publicCards:GetChild('card5'),
    }

    for i2,_com in ipairs(_comCards) do
        _com:GetController("cGray").selectedIndex=0
        _com:GetController("cStandUp").selectedIndex=0
        _com:GetController("cShowFrame").selectedIndex=0
    end

    for i,vv in pairs(self.m_players) do
        vv.m_settlementCard1:GetController("cGray").selectedIndex=0
        vv.m_settlementCard1:GetController("cStandUp").selectedIndex=0
        vv.m_settlementCard1:GetController("cShowFrame").selectedIndex=0
        vv.m_settlementCard2:GetController("cGray").selectedIndex=0
        vv.m_settlementCard2:GetController("cStandUp").selectedIndex=0
        vv.m_settlementCard2:GetController("cShowFrame").selectedIndex=0
    end
    
    --比牌信息显示
    local _xVal = self:IsTangShengLi()
    if _xVal > 1 and self.m_publicCards:GetChild('card5').visible and v.goldtype==1 then
        self.m_settlement.visible = true
        self.m_SettlementBG.visible = true
        --平分奖池
        self.m_settlement:GetChild("n6"):GetChild("txtPingFen").visible=#_maxUsers>1
                
        local trans = self.m_settlement:GetTransition("t0")
    	trans:Play()
        --self.m_settlement:GetController("c1").selectedIndex=CT_Special_Dic[self.m_usercards[_maxUsers[1].userid].cardkind]
        self.m_settlement:GetController("c1").selectedIndex=0
        if self.paixingEff then
            self.paixingEff:Dispose()
            self.paixingEff=nil
        end
        if CT_Special_Dic_Spine_Ani[self.m_usercards[_maxUsers[1].userid].cardkind] then
            self.paixingEff = UIManager.SetDragonBonesAniObjPos2(CT_Special_Dic_Spine_Ani[self.m_usercards[_maxUsers[1].userid].cardkind], self.m_settlement:GetChild("spineParent"), Vector3.New(120,120,120))
        end

        self.m_settlement:GetChild("n6"):GetChild("txtCardType").text = CT_Chinese_Dic[self.m_usercards[_maxUsers[1].userid].cardkind]
        local _cardsList = self.m_settlement:GetChild("n6"):GetChild("listCards").asList
        _cardsList:RemoveChildrenToPool()
        for i2,v2 in ipairs(self.m_usercards[_maxUsers[1].userid].cardmax) do
            local _c=_cardsList:AddItemFromPool()
            _c:GetChild('txtCardName').text = PokerConversionStr2[v2]
        end
    end
    --最大成牌显示
    if _xVal > 1 and self.m_publicCards:GetChild('card5').visible and v.goldtype==1 then
        local _p = self:GetPlayerWithUserID(_maxUsers[1].userid)
        if _p then
            local _comCards_ =
            {
                _p.m_settlementCard1,
                _p.m_settlementCard1,
                self.m_publicCards:GetChild('card1'),
                self.m_publicCards:GetChild('card2'),
                self.m_publicCards:GetChild('card3'),
                self.m_publicCards:GetChild('card4'),
                self.m_publicCards:GetChild('card5'),
            }
            for i2,_com in ipairs(_comCards_) do
                _com:GetController("cGray").selectedIndex=1
                _com:GetController("cShowFrame").selectedIndex=0
                _com:GetController("cStandUp").selectedIndex=0
            end
            for i2,v2 in ipairs(self.m_usercards[_maxUsers[1].userid].cardmax) do
                local _mark=true
                for i3,_com in ipairs(_comCards_) do
                    if _mark and _com.data==v2 and _com:GetController("cGray").selectedIndex == 1 then
                        _com:GetController("cGray").selectedIndex=0
                        --公共牌才站起来
                        if i3>2 then
                            _com:GetController("cStandUp").selectedIndex=1
                        end
                        _com:GetController("cShowFrame").selectedIndex=1
                        _mark=false
                    end
                end
            end
        end
    end

    --飞金币
    local _delay=0
    for i2, v2 in ipairs(v.winuserdatas) do
        local _info = v2
        local _p = self:GetPlayerWithUserID(_info.userid)
        if _p then
            if _sums[_info.userid]>0 then
                local _timer = Timer.New(function ()
                    _p:PlayChouMaEff()
                end, _delay, 1)
                _timer:Start()
                table.insert(self.m_chouMaTimers, _timer)
            end
            --todo 奖池飞完就隐藏
            local _end_pos = self.m_propLayer:GlobalToLocal(_p.m_head:LocalToGlobal(Vector2.zero))
            _delay = self.m_texasPondList:PondListFlyCMToPlayer(_delay, _info.bianchigold, _end_pos) + _delay
        end
    end

    --print('一次结算的时长'.._delay)
    --下一次的结算信息

    local _timer2 = Timer.New(function () self:PlayGameOverAni() end, _delay + 4, 1)
    _timer2:Start()
    table.insert(self.m_chouMaTimers, _timer2)
end

function ControllerTexas:ClearBetAllAndFly(toPos)
    local t=0
    for i,v in ipairs(self.m_players) do
        local _t=v:ClearBetAndFly(toPos)
        t=math.max(t,_t)
    end
    --print('需要服务器预留筹码到奖池变化时间'..t)
    return t
end

--得到场上所有玩家的下注总值,防止奖池,收到多次消息时的莫名刷新
function ControllerTexas:GetAllBetVal()
    local t=0
    for i,v in ipairs(self.m_players) do
        local _t=v:GetBetVal()
        t=t+_t
    end
    return t
end

--所有玩家弃牌
function ControllerTexas:IsTangShengLi()
    local _val=0
    for i,v in ipairs(self.m_players) do
        if v:GetChair()~=-1 and v:GetIsPrepare() and v:GetOperationType()~=OperationType_QiPai then
            _val=_val+1
        end
    end
    return _val
end

--处理玩家的广播操作 跟注/加注/让牌/allin
function ControllerTexas:HandleOp(msg)
    --userid表示当前出手
    if msg.userid == loginSucceedInfo.user_info.userid then
        self.m_texasBetControl:HideMyOpenBtn()
    end
    if msg.nextActionUserId == loginSucceedInfo.user_info.userid then
        self.m_texasBtn:ShowBtnMessageRecord(false)
        self.m_texasBetControl:ShowMyOpenBtn(self:CalcIsCheck())
    else
        self.m_texasBetControl:HideAutoOpen()
        --坐下未弃牌/全下
        if self.m_isQiPai == false and self.m_isAllin == false and self.m_shouPaiData ~= nil then
            self.m_texasBetControl:ShowAutoOpen()   
        end
        --弃牌可选择亮牌
        if self.m_shouPaiData ~= nil and self.m_isQiPai == true then
            self.m_texasBetControl:ShowSettlementIsShow()
        end
    end
    
    self:SetCountdownAndPointer(msg.nextActionUserId)
end

--返回是否可以过牌,下注值相等!!!
function ControllerTexas:CalcIsCheck()
    local _val=-1
    for i,v in ipairs(self.m_players) do
        if v:GetChair()~=-1 and v:GetIsPrepare() and v:GetOperationType()~=OperationType_QiPai then
            --初始化一个数值
            if _val==-1 then
                _val=v:GetBetVal()
            else
                if _val~=v:GetBetVal() then
                    return false
                end
            end
        end
    end
    return true
end

--设置倒计时加指针
function ControllerTexas:SetCountdownAndPointer(nextActionUserId,countdown)
    --倒计时
    self:SetCountdown(nextActionUserId)
    if nextActionUserId>0 then
        local ply = self:GetPlayerWithUserID(nextActionUserId)
        if ply then
            self.m_controllerPointer.selectedIndex = ply.m_pos
        end
    else
        --设置不显示当前操作玩家指针
        self.m_controllerPointer.selectedIndex=9
    end
end

--设置当前出手玩家的倒计时
function ControllerTexas:SetCountdown(userID, countdown)
    for i,v in pairs(self.m_players) do
        v:SetThinking(-1)
    end
    if userID>0 then
        local ply = self:GetPlayerWithUserID(userID)
        if ply then
            ply:SetThinking(countdown)
            ply:SetOperationState(OperationType_Thinking)
        end
    end
end

--游戏开始后,将自己玩家显示到0
function ControllerTexas:ChangePosCalc(isSkip)
    if self:GetChair()~=-1 and self:GetPlayerWithPos(0):GetChair()~=self:GetChair() then
        self.isChangLocalChair=true
        --分配椅子
        local _ps = self:GetSitChairNumTab()
        if not _ps then
            return
        end

        local _len = #_ps
        
        --假设自己当前位置是7,得到索引下标值7
        local _posIndex = -1
        local ply = self:GetPlayerWithUserID(loginSucceedInfo.user_info.userid)
        if ply then
            for i, v in ipairs(_ps) do
                if v == ply.m_pos then
                    _posIndex = i
                end
            end
        end

        --依次传递数据 7->6 6->0 0->8...
        local _fromPos=_ps[_posIndex]
        local _fromPlayer=self:GetPlayerWithPos(_fromPos)

        local _fromBaseData=_fromPlayer:GetBaseData()
        local _fromExpectSitDownChair=_fromPlayer:GetExpectSitDownChair()
        local _fromIsPrepare=_fromPlayer:GetIsPrepare()

        for i=1,_len do
            _posIndex=_posIndex+1
            if _posIndex>_len then
                _posIndex=1
            end
            local _toPos=_ps[_posIndex]
            local _toPlayer=self:GetPlayerWithPos(_toPos)
            local _toBaseData=_toPlayer:GetBaseData()
            local _toExpectSitDownChair=_toPlayer:GetExpectSitDownChair()
            local _toIsPrepare=_toPlayer:GetIsPrepare()

            if _fromBaseData==nil then
                _toPlayer:Hide()
            else
                _toPlayer:SetBaseData(_fromBaseData)
            end
            _toPlayer:SetExpectSitDownChair(_fromExpectSitDownChair)
            _toPlayer:SetIsPrepare(_fromIsPrepare)

            _fromBaseData=_toBaseData
            _fromExpectSitDownChair=_toExpectSitDownChair
            _fromIsPrepare=_toIsPrepare
        end
        if isSkip==nil then
            --切后台/收到游戏开始重新计算一次
            self.m_timerChangLocalChair=Timer.New(function ()
                self:ChangePosCalc()
            end,0.15,1)
            self.m_timerChangLocalChair:Start()
        else
            self:ChangePosCalc()
        end
    else
        self.isChangLocalChair = false
        if self.m_timerChangLocalChair then
            self.m_timerChangLocalChair:Stop()
        end
    end
end

--隐藏所有玩家
function ControllerTexas:HideAllPlayer()
    for i,v in pairs(self.m_players) do
        v:Hide()
        self.m_content:SetChildIndex(v.m_view,self.m_content:GetChildIndex(self.m_SettlementBG)-1)
    end
end
--隐藏上局结算信息
function ControllerTexas:HideWithAgain()
    for i,v in pairs(self.m_players) do
        v:HideWithAgain()
        self.m_content:SetChildIndex(v.m_view,self.m_content:GetChildIndex(self.m_SettlementBG)-1)
    end
end

--服务器分配的UserID
function ControllerTexas:GetPlayerWithUserID(userID)
    for i,v in pairs(self.m_players) do
        if v:GetUserID() == userID then
            return v
        end
    end
    return nil
end

--服务器预计分配,只用作初始化分配椅子!!!
function ControllerTexas:GetPlayerWithExpectSitDownChair(expectSitDownChair)
    for i,v in pairs(self.m_players) do
        if v:GetExpectSitDownChair()==expectSitDownChair then
            return v
        end
    end
end
--服务器分配的椅子
function ControllerTexas:GetPlayerWithChair(chair)
    for i,v in pairs(self.m_players) do
        if v:GetChair()==chair then
            return v
        end
    end
end
--本地位置
function ControllerTexas:GetPlayerWithPos(pos)
    for i,v in pairs(self.m_players) do
        if v.m_pos==pos then
            return v
        end
    end
end
--设置自己的椅子
function ControllerTexas:SetChair(chair)
    self.m_chair=chair
    gameData.chair=chair
end

function ControllerTexas:GetChair()
    return self.m_chair
end

--清空当前信息
function ControllerTexas:Clear(isAgain)
    --如果是再次开始游戏就跳过这些数据
    if not isAgain then
        self:HideAllPlayer()
        self.m_texasChat:HideChat()
        self.m_texasBtn:HideComHumenProp()
    else
        self:HideWithAgain()
    end
    
    self.m_waitGameStart.visible=false
    --播放1秒龙骨帧动画
    self.m_startAni.visible=false
    self.m_followJet.visible=false

    self.m_texasPondList:ClearTexasPondList()
    
    self:SetTotalPool(-1)
    self.m_publicCards.visible=false
    for i=1,5 do
        self.m_publicCards:GetChild('card'..i).visible=false
        self.m_publicCards:GetChild('card'..i):GetChild('n10').visible=true
    end
    --设置不显示当前操作玩家指针
    self.m_controllerPointer.selectedIndex=9
    self.m_settlement.visible=false
    self.m_SettlementBG.visible=false
    self.m_texasBetControl:HideMyOpenBtn()
    self.m_texasBetControl:SetAutoOpenCode(0)
    self.m_texasBetControl:HideSettlementIsShow()
    self.m_texasBetControl:HideAutoOpen()
    --数据
    self.m_isQiPai=false
    self.m_isAllin=false
    self.m_shouPaiData=nil
    -- 服务端同步的底池
    self.server_pool_bet = 0
    self.m_fallow_min = 0
    self.m_add_min = 0
    if gameData then
        gameData.currmaxgold=0
        gameData.seq=nil
    end

    if self.m_timerChangLocalChair then
        self.m_timerChangLocalChair:Stop()
    end
    if self.startGameFlyCmTimer then
        self.startGameFlyCmTimer:Stop()
    end
    if self.m_timerFlyPoindList then
        for i,v in ipairs(self.m_timerFlyPoindList) do
            v:Stop()
        end
    end
    self.m_timerFlyPoindList={}

    if self.m_chouMaTimers then
        for i,v in ipairs(self.m_chouMaTimers) do
            v:Stop()
        end
    end
    self.m_chouMaTimers={}

    if self.paixingEff then
        self.paixingEff:Dispose()
        self.paixingEff=nil
    end

    if self.m_timerYinXiaos then
        for i,v in ipairs(self.m_timerYinXiaos) do
            v:Stop()
        end
    end
    self.m_timerYinXiaos = { }
    self.m_roundsData = { }
    for i,v in pairs(self.m_players) do
        v:SetIsPrepare(false)
    end
end

function ControllerTexas:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible = true

    --在游戏内不播放背景音乐
    --F_SoundManager.instance:CloseMusicVolume()
    F_SoundManager.instance:PlayEffect('br_bgm', true)
    self.m_texasBetControl:ShowIsBiXia()   -- 必下按钮判断

    -- 猜手牌屏蔽
    self.m_btn_guess.visible = not roomCfg.is_competition

    self:CheckHongBaoOpen()

    --只有初级场是绿的
    if not roomCfg.is_competition then
        if GameServerConfig.serverid == 10 then
            self.m_view_bg_slt.selectedIndex = 0
            self.m_cont_bg_slt.selectedIndex = 0
        elseif GameServerConfig.serverid == 11 then
            self.m_view_bg_slt.selectedIndex = 1
            self.m_cont_bg_slt.selectedIndex = 1
        elseif GameServerConfig.serverid == 12 then
            self.m_view_bg_slt.selectedIndex = 2
            self.m_cont_bg_slt.selectedIndex = 2
        elseif GameServerConfig.serverid == 13 then
            self.m_view_bg_slt.selectedIndex = 3
            self.m_cont_bg_slt.selectedIndex = 3
        end
        -- 必下场判断
        if UIManager.GetController('ControllerGameHall'):GetIsBiXiaReal() then
            self.m_view_bg_slt.selectedIndex = 0
            self.m_cont_bg_slt.selectedIndex = 5
        end
    end
end

function ControllerTexas:OnHide()
	self.m_view.visible=false
end

--设置底池值
function ControllerTexas:SetTotalPool(val)
    if val<0 then
        self.m_txtTotalPool.text=''
        self.m_totalPoolVal=0
    else
        self.m_totalPoolVal=val
        self.m_txtTotalPool.text=string.format("底池：[color=#FFDA77]%s[/color]",formatVal(self.m_totalPoolVal))
    end
    --print(debug.traceback('SetTotalPool '..val))
end

function ControllerTexas:AddTotalPool(val)
    --[[self.m_totalPoolVal=self.m_totalPoolVal+val
    self:SetTotalPool(self.m_totalPoolVal)]]
end

function ControllerTexas:NvHeGuanXiaZhu()
    --敲桌子
    self.m_nvheguan_skeletonAnimation.skeleton:SetToSetupPose()
    self.m_nvheguan_skeletonAnimation.state:ClearTracks()
    self.m_nvheguan_skeletonAnimation.state:SetAnimation(0, 'suiji4', false)

    self.m_nvheguan_skeletonAnimation.state.Complete=self.m_nvheguan_skeletonAnimation.state.Complete-self.m_nvheguanCallback
    self.m_nvheguan_skeletonAnimation.state.Complete=self.m_nvheguan_skeletonAnimation.state.Complete+self.m_nvheguanCallback
end

-- 玩家加好友
function ControllerTexas:ShowAddFriendFly(from_id, to_id)
    local ply_from = self:GetPlayerWithUserID(from_id)
    local ply_to = self:GetPlayerWithUserID(to_id)
    if ply_from and ply_to then
        local fromPos = self.m_propLayer:GlobalToLocal(ply_from.m_head:LocalToGlobal(Vector2.zero))
        local toPos = self.m_propLayer:GlobalToLocal(ply_to.m_head:LocalToGlobal(Vector2.zero))
        self.m_friend_tips.position = fromPos
        self.m_friend_tips.visible = true
        local _t = Vector2.Distance(fromPos, toPos)/1000
        self.m_friend_tips:TweenMove(toPos, _t):OnComplete(function ()
            self.m_friend_tips.visible = false
        end)
    end
end

function ControllerTexas:GetSelfGaming()
    return self.m_self_gaming
end

-- 猜手牌：更新右上角金币数和桌子携带的分数
function ControllerTexas:UpdateSelfScoreTableScore(self_score_str, table_score_str)
    self:UpdateSelfSCoinNum(self_score_str)
    local self_ply = self:GetPlayerWithUserID(loginSucceedInfo.user_info.userid)
    if self_ply then
        self_ply:SetGold(tonumber(table_score_str))
    end
end

-- 关闭看剩余牌
function ControllerTexas:CloseLookRemainCard()
    self.m_lookRemainCard.visible = false
end

-- 红包功能
function ControllerTexas:CheckHongBaoOpen()
    local is_hong_bao = false
    if roomCfg and roomCfg.tableinfo then
        local table_info = json.decode(roomCfg.tableinfo)
        is_hong_bao = table_info.Hd_hongBao and table_info.Hd_hongBao == 1
    end
    self.hongBaoObj:SetActive(is_hong_bao)
    self.hongBaoTxtObj.visible = is_hong_bao
end

----------------------------------- 比赛场 ---------------------------------------
function ControllerTexas:InitMatchMangZhu()
    self.m_com_bisai = self.m_content:GetChild("comBiSai")
    self.m_btn_add = self.m_content:GetChild("comBtnAdd")
    self.m_btn_add_tips = self.m_btn_add:GetChild("btnTips")
    self.m_btn_detail = self.m_com_bisai:GetChild("btnDetail")
    self.m_remain_ply = self.m_com_bisai:GetChild("remain_ply")
    self.m_remain_time = self.m_com_bisai:GetChild("remain_time")
    self.m_competition_rank = self.m_content:GetChild("competition_rank")
    self.m_competition_rank.text = ""
    self.m_mangzhu_cd = 0
    self.m_has_rank = false
    self.temp_mangzhu_num = 0
    self.temp_qianzhu_num = 0
    self.m_btn_detail.onClick:Add(function ()
        UIManager.Show('ControllerCompetitionDetail')
    end)

    self.m_add_type = 0
    self.m_btn_add.visible = false
    self.m_btn_add:GetChild("btnAdd").onClick:Add(function ()
        local msg = Protol.DzMatchPb_pb.C_UserBuyScore()
        msg.type = self.m_add_type
        local pb_data = msg:SerializeToString()
        NetManager.SendNetMsg(GameServerConfig.logic,'Match_ReqUserBuyScore', pb_data)
    end)

    self:HideMangZhuPanel()
end

function ControllerTexas:ShowMangZhuPanel()
    self.m_com_bisai.visible = true
end

function ControllerTexas:HideMangZhuPanel()
    self.m_com_bisai.visible = false
end

function ControllerTexas:UpdatePlyCount(ply_count)
    self.m_remain_ply.text = ply_count
end

function ControllerTexas:OpenMatchMangZhuCd(mangzhu_cd)
    self:CloseMatchMangZhuCd()
    self.m_mangzhu_cd = mangzhu_cd
    self.m_remain_time.text = GetTimeText(mangzhu_cd)
    self.m_cd = Timer.New(function ()
        self:UpdateMatchMangZhuCd()
    end, 1, -1)

    self.m_cd:Start()
end

function ControllerTexas:UpdateMatchMangZhuCd()
    self.m_mangzhu_cd = self.m_mangzhu_cd - 1
    if self.m_mangzhu_cd < 0 then
        self.m_mangzhu_cd = 0
    end
    self.m_remain_time.text = GetTimeText(self.m_mangzhu_cd)
end

function ControllerTexas:CloseMatchMangZhuCd()
    if self.m_cd then
        self.m_cd:Stop()
    end
end

-- 比赛场显示盲注
function ControllerTexas:ShowMangZhuNum(curcellscoreindex, qianzhunum)
    local get_mangzhu_num = 0
    roomCfg.curt_mangzhu_index = curcellscoreindex
    for k, v in pairs(roomCfg.mangzhu_list) do
        if v.level == roomCfg.curt_mangzhu_index then
            get_mangzhu_num = v.mangzhu
            break
        end
    end

    if self.temp_mangzhu_num == 0 then
        self.temp_mangzhu_num = get_mangzhu_num
        self.temp_qianzhu_num = qianzhunum * 1
        roomCfg.xiaomangbet = get_mangzhu_num * 1
        roomCfg.frontbet = qianzhunum
        self:UpdateMangZhuNum()
    else
        self.temp_mangzhu_num = get_mangzhu_num
        self.temp_qianzhu_num = qianzhunum * 1
    end
end

function ControllerTexas:UpdateMangZhuNum()
    if roomCfg.is_competition and roomCfg.xiaomangbet then
        roomCfg.xiaomangbet = self.temp_mangzhu_num * 1
        roomCfg.frontbet = self.temp_qianzhu_num * 1
        self.m_littleBlindAndLargeBlindAnDante.text = string.format("[color=#FFE476]%s  [/color]盲注：%s/%s  前注：%s  当前级别：%s",
                roomCfg.title,
                formatVal(roomCfg.xiaomangbet),
                formatVal(roomCfg.xiaomangbet * 2),
                formatVal(roomCfg.frontbet),
                roomCfg.curt_mangzhu_index)
    end
end

-- 比赛场强制退出游戏
function ControllerTexas:ExitMatchGame()
    if roomCfg and roomCfg.is_change_table then
        roomCfg.is_change_table = false
    end
    self.isChangLocalChair = false
    NetManager.SendNetMsg(GameServerConfig.logic,'Match_ExitGame')
    self:ReceiveExitGame( { userid = loginSucceedInfo.user_info.userid } )
end

-- 普通场退出游戏
function ControllerTexas:ExitNormalGame()
    if roomCfg and roomCfg.is_change_table then
        roomCfg.is_change_table = false
    end
    self.isChangLocalChair = false
    NetManager.SendMessage(GameServerConfig.logic,'ExitGameBroadcast')
    self:ReceiveExitGame( { userid = loginSucceedInfo.user_info.userid } )
end

----------------------------------- 换手牌 ---------------------------------------
function ControllerTexas:InitChangeHandCard()
    self.m_change_card = self.m_view:GetChild('comChangeCard')
    self.m_change_card.visible = false
    self.m_change_cost = 0
    self.m_change_card_refresh = 0
    self.m_change_card_niubi = 0

    self.m_change_card:GetChild('btnChange').onClick:Add(function ()
        if self.m_change_card_refresh == 0 then
            UIManager.AddPopTip({ strTit = '亲爱的玩家，您的刷新卡不足，暂时无法使用此功能。' })
            return
        end

        if self.m_change_card_niubi == 0 then
            UIManager.AddPopTip({ strTit = '亲爱的玩家，您的牛逼卡不足，暂时无法使用此功能。' })
            return
        end

        if loginSucceedInfo.user_info.gold < self.m_change_cost then
            UIManager.AddPopTip({ strTit = '\'亲爱的玩家，您的金币不足，暂时无法使用此功能。' })
            return
        end

        NetManager.SendNetMsg(GameServerConfig.logic,'DZPK_RequestChangeHandCard')
    end)
end

function ControllerTexas:SetChangeHandCardInfo(cost, count_refresh, count_niubi)
    self.m_change_cost = cost
    self.m_change_card_refresh = count_refresh
    self.m_change_card_niubi = count_niubi
end

function ControllerTexas:ShowChangeHandCard()
    self.m_change_card.visible = true
    local str1 = self.m_change_cost == 0 and "免费" or formatVal(self.m_change_cost)
    local str2 = string.format("需要[color=#E6BC57]刷新卡(%s/1)[/color]+[color=#E6BC57]牛逼卡(%s/1)[/color]", self.m_change_card_refresh, self.m_change_card_niubi)
    self.m_change_card:GetChild('cost_tips').text = string.format("消耗金币：[color=#E6BC57]%s[/color]", str1)
    self.m_change_card:GetChild('card_tips').text = str2
end

function ControllerTexas:HideChangeHandCard()
    self.m_change_card.visible = false
end

----------------------------------- 查看手牌的道具显示 ---------------------------------------
function ControllerTexas:HideLookCard()
    for i, v in pairs(self.m_players) do
        v:SetPlyCardTypeEmpty()
    end
end

----------------------------------- 收到退出消息 ---------------------------------------
function ControllerTexas:ReceiveExitGame(msg)
    if self.isChangLocalChair then
        --队列处理数据
        table.insert(self.serverDataList,{ msgType = 'ExitGameBroadcast', msg = msg })
    else
        self:Handle_ExitGameBroadcast(msg)
    end
    self.m_texasChat:CheckGoBackSuccess()
    -- 继续刷新打开比赛界面
    --UIManager.Show('ControllerCompetition')
end

----------------------------------- 底池数 ---------------------------------------
function ControllerTexas:GetTotalServerPoolBet()
    return tonumber(self.server_pool_bet)
end

---------------------------------- 最小跟注 ---------------------------------------
function ControllerTexas:GetFallowBetMin()
    return tonumber(self.m_fallow_min)
end

---------------------------------- 最小加注 ---------------------------------------
function ControllerTexas:GetAddBetMin()
    return tonumber(self.m_add_min)
end

---------------------------------- 旧的 ---------------------------------------
--得到应该要跟注的值
--场上最大的下注值减自己下注值
function ControllerTexas:GetFallowVal()
    local t = 0
    for i, v in ipairs(self.m_players) do
        local _t = v:GetBetVal()
        t = math.max(t,_t)
    end
    local ply = self:GetPlayerWithUserID(loginSucceedInfo.user_info.userid)
    if ply then
        return t - ply:GetBetVal()
    end
    return t
end

-- 是否只有弃牌和全下
function ControllerTexas:IsOnly_Qi_Allin()
    return gameMoney <= self:GetFallowBetMin()
end

----------------------------------- 座位数 ---------------------------------------
function ControllerTexas:GetSitChairNumTab()
    if roomCfg then
        if roomCfg.person == 5 then
            return cloneTab(Pos5P)
        elseif roomCfg.person == 6 then
            return cloneTab(Pos6P)
        elseif roomCfg.person == 9 then
            return cloneTab(Pos9P)
        end
    end
    return cloneTab(Pos9P)
end

----------------------------------- 弃牌 ---------------------------------------
function ControllerTexas:SendGiveUp()
    local msg = Protol.Poker_pb.QiPaiReq()
    msg.seq = gameData.seq
    local pb_data = msg:SerializeToString()
    NetManager.SendMessage(GameServerConfig.logic,'QiPaiReq',pb_data)
end

----------------------------------- 自动坐下 ---------------------------------------
function ControllerTexas:InitAutomaticSitDown()
    self.m_automaticSit = self.m_content:GetChild("btnAutomSit")
    self.m_automaticSit.onClick:Add(function ()
        self:ClickAutomaticSitDown()
    end)
end

function ControllerTexas:ShowAutomaticSit(is_show)
    if is_show then
        is_show = is_show and not roomCfg.is_competition
    end
    self.m_automaticSit.visible = is_show
end

function ControllerTexas:ClickAutomaticSitDown()
    local is_bi_xia = UIManager.GetController('ControllerGameHall'):GetIsBiXiaReal()
    local _v = roomCfg.bringmaxgold / 100
    local _min = roomCfg.bringmingold / _v
    local m_slider_value = is_bi_xia and 100 or 50
    if m_slider_value < _min then
        m_slider_value = _min
    end

    local m_f = math.max(roomCfg.bringmingold, math.min(roomCfg.bringmaxgold, math.floor(m_slider_value * _v)))
    m_f = math.min(m_f, loginSucceedInfo.user_info.gold)

    local msg = Protol.Poker_pb.ChargeGoldRequest()
    if is_bi_xia then
        msg.chargegold = roomCfg.bringmaxgold
        msg.autocharge = 2
    else
        msg.chargegold = math.min(m_f, loginSucceedInfo.user_info.gold)
        msg.autocharge = 1
    end

    if loginSucceedInfo.user_info.gold < msg.chargegold then
        UIManager.AddPopTip({strTit = '您带的金币不足'})
        return
    end

    local find_sit = false
    for i, v in pairs(self.m_players) do
        if v:GetHasPlayer() then
            v:RequestSitDown()
            find_sit = true
            local pb_data = msg:SerializeToString()
            NetManager.SendMessage(GameServerConfig.logic,'ChargeGoldRequest', pb_data)
            break
        end
    end

    if not find_sit then
        UIManager.AddPopTip({strTit = '座位已满'})
    end
end

----------------------------------- 更新左上角金币 -----------------------------------
function ControllerTexas:UpdateSelfSCoinNum(score)
    local self_score = tonumber(score)
    self.m_coinNum.text = formatVal(self_score)
    loginSucceedInfo.user_info.gold = self_score
end

return ControllerTexas