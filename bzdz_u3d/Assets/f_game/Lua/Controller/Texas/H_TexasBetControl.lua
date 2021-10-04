--下注控制
local H_TexasBetControl=class("H_TexasBetControl")
local H_SliderBet=require("Controller/Texas/H_SliderBet")
local H_IsBiXia

function H_TexasBetControl:Init(arg)
    local m_view = arg.view
    self.m_controllerTexas = arg.controller
    ------------------------------------------滑动操作面板
    local _betSlider = m_view:GetChild("betSlider")
    self.m_betSlider = _betSlider
    self.m_betSlider.visible = false
    self.m_sliderBet = H_SliderBet.new()
    self.m_sliderBet_result = nil
    self.m_sliderBet:Init({ view = _betSlider, onChangeCall = function (val)
        --val 0-1百分比
        self.m_sliderBet_result = math.ceil(gameMoney * (val >= 0.95 and 1 or val)) + self.add_bet_min
        self:ShowAddBtnNormalOrGray()
    end})
    
    _betSlider:GetChild("btnAllIn").onClick:Add(function ()
        --print('滑动列表,全下操作')
        self.m_betSlider.visible = false
        self:SendAllin()
    end)

    _betSlider:GetChild("btn5").onClick:Add(function ()
        --print('滑动列表,5倍大盲')
        self.m_betSlider.visible = false
        self:SendJiaZhu((gameData.currmaxgold * 5) + self.add_bet_min)
    end)

    _betSlider:GetChild("btn4").onClick:Add(function ()
        --print('滑动列表,4倍大盲')
        self.m_betSlider.visible = false
        self:SendJiaZhu((gameData.currmaxgold * 4) + self.add_bet_min)
    end)

    _betSlider:GetChild("btn3").onClick:Add(function ()
        --print('滑动列表,3倍大盲')
        self.m_betSlider.visible = false
        self:SendJiaZhu((gameData.currmaxgold * 3) + self.add_bet_min)
    end)

    _betSlider:GetChild("btnAdd").onClick:Add(function ()
        --print('滑动列表,加号按钮')
    end)

    _betSlider:GetChild("btnReduce").onClick:Add(function ()
        --print('滑动列表,减号按钮')
    end)

    _betSlider:GetChild("btnClose").onClick:Add(function ()
        --print('滑动列表,关闭滑动面板')
        self.m_betSlider.visible = false
    end)
    
    ------------------------------------------自己操作面板
    self.m_listMyOpen=m_view:GetChild("MyOpenList").asList
    self.m_listPoolAddBet = m_view:GetChild("poolAddBet").asList
    self.m_listPoolAddBtnHalf = self.m_listPoolAddBet:GetChildAt(0)
    self.m_listPoolAddBtnSame = self.m_listPoolAddBet:GetChildAt(1)
    self.m_listPoolAddBtnTwo = self.m_listPoolAddBet:GetChildAt(2)

    self.m_listPoolAddBtnHalf.onClick:Add(function ()
       self:AddBetFormPool(self.m_listPoolAddBtnHalf)
    end)

    self.m_listPoolAddBtnSame.onClick:Add(function ()
        self:AddBetFormPool(self.m_listPoolAddBtnSame)
    end)

    self.m_listPoolAddBtnTwo.onClick:Add(function ()
        self:AddBetFormPool(self.m_listPoolAddBtnTwo)
    end)

    self.m_listMyOpen.foldInvisibleItems = true
    self.m_cMyOpen = m_view:GetController("cShowMyOpen")

    -- 弃牌
    self.m_give_up = self.m_listMyOpen:GetChildAt(0)
    -- all_in
    self.m_add_in = self.m_listMyOpen:GetChildAt(3)
    -- 过牌
    self.m_pass = self.m_listMyOpen:GetChildAt(1)
    -- 跟注
    self.m_fallow = self.m_listMyOpen:GetChildAt(2)
    -- 加注
    self.m_addBet = self.m_listMyOpen:GetChildAt(4)

    self.m_give_up.onClick:Add(function ()
        --print('弃牌')
        self.m_betSlider.visible=false
        self:SendQi()
    end)

    self.m_fallow.onClick:Add(function ()
        --print('跟注')
        self.m_betSlider.visible = false
        self:SendGen()
    end)

    self.m_add_in.onClick:Add(function ()
        --print('全下')
        self.m_betSlider.visible=false
        self:SendAllin()
    end)

    self.m_pass.onClick:Add(function ()
        --print('让牌')
        self.m_betSlider.visible=false
        self:SendGuo()
    end)

    self.m_addBet.onClick:Add(function ()
        if self.m_addBet:GetController("c1").selectedIndex == 0 then
            self.m_betSlider.visible = false
            self:SendAllin()
            return
        end
        if self.m_betSlider.visible then
            if self.m_sliderBet_result <= 0 then
                return
            end
            
            if self.m_sliderBet_result > 0 then
                self:SendJiaZhu(self.m_sliderBet_result)
            end

            self.m_betSlider.visible = false
        else
            self.m_betSlider.visible = true
            self:ShowAddBtnNormalOrGray()
        end
    end)

    ------------------------------------------托管操作面板
    self.m_cShowAutoOpen=m_view:GetController("cShowAutoOpen")
    --选择项
    self.m_cAutoOpen=m_view:GetController("cAutoOpen")

    ------------------------------------------弃牌可选择亮牌
    self.m_settlementIsShow = m_view:GetChild("settlementIsShow").asButton
    self.m_settlementIsShow.onClick:Add(function ()
        --print('弃牌可选择亮牌:'..(self.m_settlementIsShow.selected and 't' or 'f'))
        local msg = Protol.Poker_pb.IsPublicCardsRequest()
        msg.ispublic = self.m_settlementIsShow.selected and 1 or 0
	    local pb_data = msg:SerializeToString()
	    NetManager.SendMessage(GameServerConfig.logic,'IsPublicCardsRequest', pb_data)
    end)

    ------------------------------------------最小加注数
    self.add_bet_min = 0
    self.fall_bet_min = 0
end

function H_TexasBetControl:SendGuo()
    local msg = Protol.Poker_pb.GuoPaiReq()
    msg.seq = gameData.seq
	local pb_data = msg:SerializeToString()
	NetManager.SendMessage(GameServerConfig.logic,'GuoPaiReq',pb_data)
end

function H_TexasBetControl:SendGen()
    local msg = Protol.Poker_pb.GenZhuReq()
    msg.seq=gameData.seq
    msg.gold=-1
    msg.score=0
	local pb_data = msg:SerializeToString()
	NetManager.SendMessage(GameServerConfig.logic,'GenZhuReq', pb_data)
end

function H_TexasBetControl:SendQi()
    local msg = Protol.Poker_pb.QiPaiReq()
	msg.seq=gameData.seq
	local pb_data = msg:SerializeToString()
	NetManager.SendMessage(GameServerConfig.logic,'QiPaiReq',pb_data)
end

function H_TexasBetControl:SendAllin()
    local msg = Protol.Poker_pb.AllInReq()
    msg.seq=gameData.seq
	local pb_data = msg:SerializeToString()
	NetManager.SendMessage(GameServerConfig.logic,'AllInReq', pb_data)
end

function H_TexasBetControl:SendJiaZhu(val)
    if val > gameMoney then
        UIManager.AddPopTip({ strTit = "金币不足" })
        return
    end

    local msg = Protol.Poker_pb.JiaZhuReq()
    msg.seq=gameData.seq
    msg.gold=val
    msg.score=0
    local pb_data = msg:SerializeToString()
    NetManager.SendMessage(GameServerConfig.logic,'JiaZhuReq',pb_data)
end

--弃牌/跟注/AllIn/让牌/加注
function H_TexasBetControl:ShowMyOpenBtn(isCheck)
    --print('自动操作面板的选择:'..self.m_cAutoOpen.selectedIndex)
    local _s=self.m_cAutoOpen.selectedIndex
    self:SetAutoOpenCode(0)
    if _s~=0 then
        --[[local msg = Protol.Poker_pb.GamePreOperate()
		msg.seq=gameData.seq
		msg.operatetype=_s
		local pb_data = msg:SerializeToString()

		NetManager.SendMessage(GameServerConfig.logic,'GamePreOperate',pb_data)
        self:SetAutoOpenCode(0)
        return]]

        --1 让/弃
        if _s==1 then
            if isCheck then
                self:SendGuo()
            else
                self:SendQi()
            end
            self:HideMyOpenBtn()
            return
        --2 自动让牌  
        elseif _s==2 then
            if isCheck then
                self:SendGuo()
                self:HideMyOpenBtn()
                return
            end
        --3 任意跟注
        elseif _s==3 then
            if not isCheck then
                self:SendGen()
                self:HideMyOpenBtn()
                return
            end
        end
    end

    self.m_cMyOpen.selectedIndex=1
    self.m_betSlider.visible=false
    if not H_IsBiXia then
        --让牌控制
        self.m_pass.visible = isCheck
        --跟注
        self.m_fallow.visible = not isCheck
    end
    if not H_IsBiXia then
        self.m_addBet:GetChild('Content').text='加注'
    end
    --默认显示一个筹码
    self.m_sliderBet:SetVal(0.025)

    self:HideAutoOpen()

    if not H_IsBiXia then
        self.m_addBet.visible=true
    end

    --只显示 弃牌 和 all
    if self.m_controllerTexas:IsOnly_Qi_Allin() then
        self.m_addBet.visible = false
        -- 让牌
        self.m_pass.visible = false
        -- 跟注
        self.m_fallow.visible = false
    end

    -- 加注
    self:ShowAddBetMin()
    -- 加注奖池
    self:ShowBetBtnNormalOrGray()
    --显示跟注的数字
    self.m_fallow:GetChild('Content').text = string.format( "跟注:%s", formatVal(self.m_controllerTexas:GetFallowBetMin()))
end

function H_TexasBetControl:HideMyOpenBtn()
    self.m_cMyOpen.selectedIndex=0
    self.m_betSlider.visible=false
end

--显示自动托管面板
function H_TexasBetControl:ShowAutoOpen()
    if not H_IsBiXia then
        self.m_cShowAutoOpen.selectedIndex=1
    end
end

function H_TexasBetControl:HideAutoOpen()
    if not H_IsBiXia then
        self.m_cShowAutoOpen.selectedIndex=0
    end
end

--得到选择的操作
function H_TexasBetControl:GetAutoOpenCode()
    return self.m_cAutoOpen.selectedIndex
end

function H_TexasBetControl:SetAutoOpenCode(index)
    self.m_cAutoOpen.selectedIndex=index
end

--弃牌后 结算时选择亮牌
function H_TexasBetControl:ShowSettlementIsShow()
    if not H_IsBiXia then
        self.m_settlementIsShow.visible=true
    end
end

function H_TexasBetControl:HideSettlementIsShow()
    self.m_settlementIsShow.visible = false
    self.m_settlementIsShow.selected = false
end

function H_TexasBetControl:ShowIsBiXia()
    if roomCfg.tableid == 0 then
        H_IsBiXia = false
    else
        H_IsBiXia = UIManager.GetController('ControllerGameHall'):GetIsBiXiaReal()
    end
    --self.m_settlementIsShow.visible = not H_IsBiXia
    -- 跟注
    self.m_fallow.visible = not H_IsBiXia
    -- 让牌
    self.m_pass.visible = not H_IsBiXia
    -- 加注
    self.m_addBet.visible = not H_IsBiXia
    -- 新加注（底池）
    self.m_listPoolAddBet.visible = not H_IsBiXia
end

----------------------------------- 正常加注(服务端发过来) ---------------------------------------
function H_TexasBetControl:ShowAddBetMin()
    self.add_bet_min = self.m_controllerTexas:GetAddBetMin()
    self.m_sliderBet_result = self.add_bet_min * 1
    self.m_addBet:GetController("c1").selectedIndex = self.m_sliderBet_result > gameMoney and 0 or 1
end

----------------------------------- 底池加注 ---------------------------------------
function H_TexasBetControl:AddBetFormPool(btn)
    local slt_index = btn:GetController("c1").selectedIndex
    if slt_index == 1 then
        self:SendJiaZhu(btn.data)
    else
        UIManager.AddPopTip({ strTit = "金币不足" })
    end
end

function H_TexasBetControl:ShowBetBtnNormalOrGray()
    local pool_mum = self.m_controllerTexas:GetTotalServerPoolBet()
    self.fall_bet_min = self.m_controllerTexas:GetFallowBetMin()
    --print("pool_mum:"..pool_mum)
    --print("fall_mum:"..fall_mum)
    self:SetItemNormalOrGray(self.m_listPoolAddBtnHalf, math.ceil(pool_mum * 0.5) + self.fall_bet_min)
    self:SetItemNormalOrGray(self.m_listPoolAddBtnSame, math.ceil(pool_mum * 1) + self.fall_bet_min)
    self:SetItemNormalOrGray(self.m_listPoolAddBtnTwo, math.ceil(pool_mum * 2) + self.fall_bet_min)
end

function H_TexasBetControl:SetItemNormalOrGray(btn, num)
    btn:GetController("c1").selectedIndex = gameMoney >= num and 1 or 0
    btn.data = math.ceil(num)
end

----------------------------------- 正常加注 ---------------------------------------
function H_TexasBetControl:ShowAddBtnNormalOrGray()
    if not H_IsBiXia then
        self.m_addBet:GetChild('Content').text = string.format("加注:%s", formatVal(self.m_sliderBet_result))
        self.m_addBet:GetController("c1").selectedIndex = self.m_sliderBet_result > gameMoney and 0 or 1
    end
end

return H_TexasBetControl