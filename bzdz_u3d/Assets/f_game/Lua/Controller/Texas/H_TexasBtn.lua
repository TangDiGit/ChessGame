--控制游戏类零零碎碎的按钮功能
local H_TexasBtn = class("H_TexasBtn")
function H_TexasBtn:Init(controllerTexas)
    self.m_controllerTexas=controllerTexas
    self.m_menu=self.m_controllerTexas.m_content:GetChild('menu')
    self.m_menu.visible=false

    self.m_menuController=self.m_controllerTexas.m_content:GetController('c1')
    self.m_menuController.selectedIndex=0
   
    --围观玩家
    self.m_controllerTexas.m_content:GetChild("btnLookers").onClick:Add(function ()
        UIManager.Show('ControllerOnLook')
    end)
    self.m_controllerTexas.m_content:GetChild("btnLookers").visible=false

    --消息
    self.btn_message = self.m_controllerTexas.m_content:GetChild("btnMessage")

    --上局回顾
    self.btn_record = self.m_controllerTexas.m_content:GetChild("btnRecord")
    self.btn_record.onClick:Add(function ()
        coroutine.start(Game_Data_Get,{
            userid=loginSucceedInfo.user_info.userid,
            callbackSuccess=function (info)
                UIManager.Show('ControllerUserInfoRoundRecord',info)
            end
        })

        --经典数据详情（弹出无响应改成全部的牌局记录）
		--coroutine.start(Game_Data_Details_WithGame,{
        --    userid=loginSucceedInfo.user_info.userid,
        --    table_id=roomCfg.tableid,
        --    server_id=GameServerConfig.serverid,
		--	callbackSuccess=function (info)
		--		UIManager.Show('ControllerLastre',{data2=info})
		--	end
		--})

        --[[--数量1
        local msg = Protol.Poker_pb.CardsReviewRequest()
        msg.tableid=roomCfg.tableid
        msg.endrecord=0
		local pb_data = msg:SerializeToString()
		NetManager.SendMessage(GameServerConfig.logic,'CardsReviewRequest',pb_data)
        UIManager.Show('ControllerWaitTip')]]
    end)
    
    --[[H_NetMsg:addEventListener('CardsReviewRespone',function (arg)
        print('收到消息 CardsReviewRespone')

        local msg = Protol.Poker_pb.CardsReviewRespone()
        msg:ParseFromString(arg.pb_data)
        print(tostring(msg))

        UIManager.Hide('ControllerWaitTip')
        UIManager.Show('ControllerLastre',msg)
    end)]]

    --补充筹码
    self.m_controllerTexas.m_content:GetChild("btnAddCM").onClick:Add(function ()
        UIManager.Show('ControllerAddCM')
    end)

    -- 发送kiss
    self.m_controllerTexas.m_content:GetChild("btnKiss").onClick:Add(function ()
        if roomCfg.is_competition then
            UIManager.AddPopTip({ strTit = "比赛场暂时不可打赏！"})
            return
        end

        if gameData.chair==-1 then
			UIManager.AddPopTip({strTit='发送失败,请坐下后重试.'})
			return
        end

        if gameMoney<gameData.dasang_fee then
			UIManager.AddPopTip({strTit='筹码不足'})
			return
		end
        local _info={
            from=loginSucceedInfo.user_info.userid,
            mtype=10006,
            chips=gameData.dasang_fee
        }

        local msg = Protol.Poker_pb.UserInteractionRequest()
        msg.userid=0
        msg.interaction_infos=json.encode(_info)
        local pb_data = msg:SerializeToString()

        NetManager.SendMessage(GameServerConfig.logic,'UserInteractionRequest',pb_data)
    end)

    --点击荷官
    self.m_controllerTexas.m_content:GetChild("btnHumen").onClick:Add(function ()
        --print('点击荷官')
        if roomCfg.is_competition then
            UIManager.AddPopTip({ strTit = "比赛场暂时不可打赏！"})
            return
        end

        if gameData.chair==-1 then
			UIManager.AddPopTip({strTit='发送失败,请坐下后重试.'})
			return
		end

        self:ShowComHumenProp()
    end)
    
    --对荷官使用道具
    self.m_comHumenProp=self.m_controllerTexas.m_content:GetChild("humenProp")
    self.m_isAddEvent=nil
    local _propList=self.m_comHumenProp:GetChild("propList").asList
	_propList.onClickItem:Add(function (context)
		if gameData.chair==-1 then
			UIManager.AddPopTip({strTit='发送失败,请坐下后重试.'})
			return
        end
        if gameMoney<gameData.emotion_fee then
			UIManager.AddPopTip({strTit='筹码不足'})
			return
		end
        local _com = context.data
        --print(_com.name)
        local _comName=_com.name
        local _info={
            from=loginSucceedInfo.user_info.userid,
            mtype=10004,
            c=_comName,
            chips=gameData.emotion_fee
        }

        local msg = Protol.Poker_pb.UserInteractionRequest()
        msg.userid=loginSucceedInfo.user_info.userid
        msg.interaction_infos=json.encode(_info)
        local pb_data = msg:SerializeToString()

        NetManager.SendMessage(GameServerConfig.logic,'UserInteractionRequest',pb_data)
	end)

    --奖池
    self.m_prizePool=self.m_controllerTexas.m_content:GetChild("prizePool")
    UIManager.SetDragonBonesAniObjPos('PrizePoolEnterBtn',self.m_prizePool,Vector3.New(100,100,100))
    self.m_prizePool.onClick:Add(function ()
        UIManager.Show('ControllerPrizePool',self.m_prizePool.data)
    end)
    --self.m_prizePool.visible=false
    -------------------------menu
    --左上角菜单
    self.m_controllerTexas.m_content:GetChild("btnOpenMenuView").onClick:Add(function ()
        self.m_menu.visible=true
        self.m_menuController.selectedIndex=1
    end)

    --菜单列表
    self.m_menu.onClick:Add(function ()
        --print('菜单关闭')
        self.m_menu.visible=false
        self.m_menuController.selectedIndex=0
    end)

    --返回
    self.m_menu:GetChild("btnExit").onClick:Add(function ()
        --print('点击返回')
        if roomCfg.is_competition then
            -- 比赛结束
            UIManager.Show('ControllerCompetitionTips', { title = "", content = "确定要离开比赛场吗？", confirm = function()
                self.m_controllerTexas:ExitMatchGame()
                UIManager.Hide('ControllerCompetitionTips')
            end } )
        else
            if self.m_controllerTexas:GetSelfGaming() then
                local cont_str = "确定离开游戏吗？"
                UIManager.Show('ControllerHallTips', { title = "", content = cont_str, confirm = function()
                    self.m_controllerTexas:SendGiveUp()
                    self.m_controllerTexas:ExitNormalGame()

                end })
            else
                self.m_controllerTexas:ExitNormalGame()
            end
        end
    end)

    --站起
    self.m_menu:GetChild("btnUp").onClick:Add(function ()
        --print('点击站起')
        if gameData.chair == -1 then
            UIManager.AddPopTip({strTit='没有坐下'})
        else
            if self.m_controllerTexas:GetSelfGaming() then
                local cont_str = "确定要站起吗？"
                UIManager.Show('ControllerHallTips', { title = "", content = cont_str, confirm = function()
                    self.m_controllerTexas:SendGiveUp()
                    NetManager.SendMessage(GameServerConfig.logic,'UserSitupBroadcast')
                end })
                --UIManager.AddPopTip({strTit='您在游戏中，暂时不能离开哦!'})
            else
                NetManager.SendMessage(GameServerConfig.logic,'UserSitupBroadcast')
            end
        end
    end)

    --帮助 -- 暂时是换桌
    self.m_menu:GetChild("btnHelp").onClick:Add(function ()
        UIManager.Show('ControllerDZDes')
    end)

    -- 换桌
    self.m_menu:GetChild("btnChange").onClick:Add(function ()
        if roomCfg.is_competition then
            if gameData.chair == -1 then
                roomCfg.is_change_table = true   -- 比赛场的换桌特殊处理
                NetManager.SendNetMsg(GameServerConfig.logic,'Match_ReqChangeTable')
            else
                UIManager.AddPopTip({ strTit = '比赛尚未结束，暂时不能换桌' })
            end
        else
            UIManager.AddPopTip({ strTit = '您不在比赛场内' })
        end
    end)

    --设置
    self.m_menu:GetChild("btnSetting").onClick:Add(function ()
        UIManager.Show('ControllerSetting',true)
    end)

    -- 查看剩余牌
    self.m_controllerTexas.m_content:GetChild("btnLook").onClick:Add(function ()
        NetManager.SendNetMsg(GameServerConfig.logic,'DZPK_RequestLookRemainCard')
    end)

    -- 猜手牌
    self.m_controllerTexas.m_content:GetChild("btnGuess").onClick:Add(function ()
        if gameData.chair == -1 then
            UIManager.AddPopTip({strTit='没有坐下'})
            return
        end
        self.m_controllerTexas.m_exasGuess:ShowGuessPanel()
    end)

    -- 红包按钮
    self.m_controllerTexas.m_content:GetChild("btnHongBao").onClick:Add(function ()
        self.m_controllerTexas.m_texasHongBao:ShowHongBaoPanel()
    end)

end

--隐藏给荷官送礼物的面板
function H_TexasBtn:HideComHumenProp()
    self.m_comHumenProp.visible=false
    if self.m_isAddEvent then
        Stage.inst.onClick:Remove(H_TexasBtn.HideComHumenProp,self)
        self.m_isAddEvent=false
    end
end

function H_TexasBtn:ShowComHumenProp()
    Stage.inst.onClick:Add(H_TexasBtn.HideComHumenProp,self)
    self.m_isAddEvent=true
    self.m_comHumenProp.visible=true
end

function H_TexasBtn:ShowBtnMessageRecord(is_show)
    self.btn_record.visible = is_show
    self.btn_message.visible = is_show
end

return H_TexasBtn