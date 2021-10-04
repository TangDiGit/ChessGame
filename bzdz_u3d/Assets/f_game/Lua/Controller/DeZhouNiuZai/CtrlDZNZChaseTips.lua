local CtrlDZNZChaseTips = class("CtrlDZNZChaseTips")

function CtrlDZNZChaseTips:Init()
    self.m_view = UIPackage.CreateObject('niuzai', 'niuZaiChaseTipsView').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    self.tips_type = 0     -- 提示的类型
    self.chase_type = 0    -- 选择的类型（金刚、同花等等）
    self.chase_count = 0   -- 追的局数
    self.chase_money = 0   -- 追的money

    self.tips_ctrl = self.m_view:GetController('c1')
    self.sub_confirm_content = self.m_view:GetChild("sub_confirm"):GetChild("content")
    self.sub_add_count = self.m_view:GetChild("sub_add_count")
    self.sub_add_money = self.m_view:GetChild("sub_add_money")

    self.total_num_count = self.sub_add_count:GetChild("total_num")
    self.total_num_money = self.sub_add_money:GetChild("total_num")
    self.comboBoxCount = self.sub_add_count:GetChild("comboBoxCount").asComboBox
    self.comboBoxMoney = self.sub_add_money:GetChild("comboBoxMoney").asComboBox

    self.calculation_num = 0

    self:InitEventListen()
end

function CtrlDZNZChaseTips:InitEventListen()
    self.comboBoxCount.onChanged:Add(function ()
        self:CalculationTotalScore()
    end)

    self.comboBoxMoney.onChanged:Add(function ()
        self:CalculationTotalScore()
    end)

    self.m_view:GetChild("btnConfirm").onClick:Add(function ()
        self:ClickConfirm()
    end)

    self.m_view:GetChild("btnCancel").onClick:Add(function ()
        UIManager.Hide('CtrlDZNZChaseTips')
    end)

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('CtrlDZNZChaseTips')
    end)
end

-- 0:确认追号 1:确认撤销 3:追加局数 4:追加金额
function CtrlDZNZChaseTips:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true

    self.tips_ctrl.selectedIndex = arg.tips_type

    self.tips_type = arg.tips_type
    self.chase_type = arg.chase_type
    self.chase_count = arg.chase_count
    self.chase_money = arg.chase_money
    self.chase_count_remain = arg.chase_count_remain or 0   -- 剩余局数（增加的金额只能在后面几局使用）
    self.chase_cancel = arg.chase_cancel or 1
    --本次追号(同花连牌/1000/10局)
    --共需要1万金币,确认下单吗？
    -- ChaseName
    local cost = formatVal(self.chase_count * self.chase_money)
    self.sub_confirm_content.text = string.format(
            "本次追号(%s/%s/%s局)\n共需要%s金币,确认下单吗？", ChaseName[self.chase_type], formatVal(self.chase_money), self.chase_count, cost)

    --亲，确认对(同花连牌/1000/10局)追加局数吗？
    --追加后下一局将按新的局数进行追号
    self.sub_add_count:GetChild("content").text = string.format(
            "亲，确认对(%s/%s/%s局)追加局数吗？\n追加后下一局将按新的局数进行追号", ChaseName[self.chase_type], formatVal(self.chase_money), self.chase_count)

    --亲，确认对(同花连牌/1000/10局)追加金额吗？
    --追加后下一局将按新的金额进行追号
    self.sub_add_money:GetChild("content").text = string.format(
            "亲，确认对(%s/%s/%s局)追加金额吗？\n追加后下一局将按新的金额进行追号", ChaseName[self.chase_type], formatVal(self.chase_money), self.chase_count)

    self:SetChaseCount()
    self:SetChaseMoney()

    self:CalculationTotalScore()
end

-- 下拉框的数量
function CtrlDZNZChaseTips:SetChaseCount()
    self.comboBoxCount.items = ChaseCount
    self.comboBoxCount.values = ChaseCount
    self.comboBoxCount.text = ChaseCount[1]
end

-- 下拉框的金额
function CtrlDZNZChaseTips:SetChaseMoney()
    self.comboBoxMoney.items = ChaseMoneyName
    self.comboBoxMoney.values = ChaseMoneyValue
    self.comboBoxMoney.text = ChaseMoneyName[1]
end

function CtrlDZNZChaseTips:CalculationTotalScore()
    if self.tips_ctrl.selectedIndex == 2 then
        -- 增加局数（延长局数）
        self.calculation_num = tonumber(self.comboBoxCount.value) * self.chase_money
        self.total_num_count.text = formatVal(self.calculation_num)
    elseif self.tips_ctrl.selectedIndex == 3 then
        -- 增加金额（仅仅对剩余的局数有效果）
        self.calculation_num = tonumber(self.comboBoxMoney.value) * self.chase_count_remain
        self.total_num_money.text = formatVal(self.calculation_num)
    end
end

-- 点击确定的判断
function CtrlDZNZChaseTips:ClickConfirm()
    if self.tips_ctrl.selectedIndex == 0 then
        self:SendChaseConfirm()
    elseif self.tips_ctrl.selectedIndex == 1 then
        self:SendChaseCancel()
    elseif self.tips_ctrl.selectedIndex == 2 then
        self:SendChaseAddCount()
    elseif self.tips_ctrl.selectedIndex == 3 then
        self:SendChaseAddMoney()
    end
end

--required int32 areatype = 1;		//下哪个区域
--required int32 totalcount = 2;		//共多少局
--required int32 everyroundscore = 3;		//每局下注多少
--required int32 bwincancel = 4;		//是否打完取消 1是取消 0是不取消
-- 1：确认追号
function CtrlDZNZChaseTips:SendChaseConfirm()
    local msg = Protol.DZNZ_GamePb_pb.C_CreateZhuiHao()
    msg.areatype = ChaseSend[self.chase_type]
    msg.totalcount = self.chase_count
    msg.everyroundscore = self.chase_money
    msg.bwincancel = self.chase_cancel
    NetManager.SendNetMsg(GameServerConfig.logic,'DZNZ_RequestCreateZhuiHao', msg:SerializeToString())
end

--required int32 areatype = 1;		//下哪个区域
-- 2：确认撤销
function CtrlDZNZChaseTips:SendChaseCancel()
    local msg = Protol.DZNZ_GamePb_pb.C_CancelZhuiHao()
    msg.areatype = ChaseSend[self.chase_type]
    NetManager.SendNetMsg(GameServerConfig.logic,'DZNZ_RequestCancelZhuiHao', msg:SerializeToString())
end

--required int32 areatype = 1;		//下哪个区域
--required int32 addcount = 2;		//增加多少局
--required int32 addroundscore = 3  //每局增加多少分
--3:追加局数
function CtrlDZNZChaseTips:SendChaseAddCount()
    if tonumber(loginSucceedInfo.user_info.gold) >= self.calculation_num then
        local msg = Protol.DZNZ_GamePb_pb.C_AddZhuiHao()
        msg.areatype = ChaseSend[self.chase_type]
        msg.addcount = tonumber(self.comboBoxCount.value)
        msg.addroundscore = 0
        NetManager.SendNetMsg(GameServerConfig.logic,'DZNZ_RequestAddZhuiHao', msg:SerializeToString())
    else
        UIManager.AddPopTip({ strTit = '亲爱的玩家，您当前的金币不足' })
    end
end

--3:追加金额
function CtrlDZNZChaseTips:SendChaseAddMoney()
    if tonumber(loginSucceedInfo.user_info.gold) >= self.calculation_num then
        local msg = Protol.DZNZ_GamePb_pb.C_AddZhuiHao()
        msg.areatype = ChaseSend[self.chase_type]
        msg.addcount = 0
        msg.addroundscore = tonumber(self.comboBoxMoney.value)
        NetManager.SendNetMsg(GameServerConfig.logic,'DZNZ_RequestAddZhuiHao', msg:SerializeToString())
    else
        UIManager.AddPopTip({ strTit = '亲爱的玩家，您当前的金币不足' })
    end
end

function CtrlDZNZChaseTips:OnHide()
    self.m_view.visible = false
end

return CtrlDZNZChaseTips

