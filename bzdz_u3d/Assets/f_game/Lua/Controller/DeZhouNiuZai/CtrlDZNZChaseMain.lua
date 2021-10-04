local CtrlDZNZChaseMain = class("CtrlDZNZChaseMain")
local is_open = false
-- 发给服务端的类型
function CtrlDZNZChaseMain:Init()
    self.m_view = UIPackage.CreateObject('niuzai', 'niuZaiChaseMainView').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    self.m_ctrl_slt = self.m_view:GetController('slt')                          -- 选择的追号类型
    self.m_ctrl_revoke = self.m_view:GetController('revoke')                    -- 是否撤单
    self.m_comboBoxCount = self.m_view:GetChild("comboBoxCount").asComboBox     -- 下拉选择的局数
    self.m_comboBoxMoney = self.m_view:GetChild("comboBoxMoney").asComboBox     -- 下拉选择的金额
    self.m_total_num = self.m_view:GetChild("total_num")                        -- 总金额

    self.m_money = self.m_view:GetChild("txtMoney")

    self:InitChaseCount()
    self:InitChaseMoney()
    self:InitResList()
    self:InitProtocolNet()

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('CtrlDZNZChaseMain')
    end)

    self.m_view:GetChild("btnHelp").onClick:Add(function ()
        UIManager.Show('CtrlDZNZChaseRule')
    end)

    self.m_view:GetChild("btnBegin").onClick:Add(function ()
        self:BeginChase()
    end)
end

-- 协议监听
function CtrlDZNZChaseMain:InitProtocolNet()
    -- 监听结果列表
    H_NetMsg:addEventListener('DZNZ_ReceiveZhuiHaoInfo',function (arg)
        if is_open then
            local msg = Protol.DZNZ_GamePb_pb.GetInitZhuiHaoInfo()
            msg:ParseFromString(arg.pb_data)
            -- 可以下注的分数
            ChaseMoneyName = { }
            ChaseMoneyValue = { }

            for k, v in pairs(msg.chiparr) do
                if type(v) == "string" then
                    table.insert(ChaseMoneyValue, v)
                    table.insert(ChaseMoneyName, formatVal(v))
                end
            end

            self:SetChaseMoney()
            self:UpdateSelfMoney()
            self:CalculationTotalScore()
            self:ResponseResList(msg.zhuihaolist)
        end
    end)

    -- 追号的几个反馈结果
    H_NetMsg:addEventListener('DZNZ_ReceiveCreateZhuiHao',function (arg)
        local msg = Protol.DZNZ_GamePb_pb.ChangeZhuiHaoResult()
        msg:ParseFromString(arg.pb_data)
        self:UpdateNiuZaiMainMoney(msg.curselfscore)
        UIManager.AddPopTip({ strTit = '追号创建成功' })
        UIManager.Hide('CtrlDZNZChaseTips')
    end)

    H_NetMsg:addEventListener('DZNZ_ReceiveAddZhuiHao',function (arg)
        local msg = Protol.DZNZ_GamePb_pb.ChangeZhuiHaoResult()
        msg:ParseFromString(arg.pb_data)
        self:UpdateNiuZaiMainMoney(msg.curselfscore)
        UIManager.AddPopTip({ strTit = '追加订单成功' })
        UIManager.Hide('CtrlDZNZChaseTips')
    end)

    H_NetMsg:addEventListener('DZNZ_ReceiveCancelZhuiHao',function (arg)
        local msg = Protol.DZNZ_GamePb_pb.ChangeZhuiHaoResult()
        msg:ParseFromString(arg.pb_data)
        self:UpdateNiuZaiMainMoney(msg.curselfscore)
        UIManager.AddPopTip({ strTit = '取消订单成功' })
        UIManager.Hide('CtrlDZNZChaseTips')
    end)

    H_NetMsg:addEventListener('DZNZ_ReceiveZhuiWinMoney',function (arg)
        local msg = Protol.DZNZ_GamePb_pb.ChangeZhuiHaoResult()
        msg:ParseFromString(arg.pb_data)
        self:UpdateNiuZaiMainMoney(msg.curselfscore)
        UIManager.AddPopTip({ strTit = '亲爱的玩家，恭喜您追号成功' })
        self:RequestResList()
    end)
end

function CtrlDZNZChaseMain:InitChaseCount()
    self.m_comboBoxCount.items = ChaseCount
    self.m_comboBoxCount.values = ChaseCount
    self.m_comboBoxCount.text = ChaseCount[1]
    self.m_comboBoxCount.onChanged:Add(function ()
        self:CalculationTotalScore()
    end)
end

function CtrlDZNZChaseMain:InitChaseMoney()
    self.m_comboBoxMoney.onChanged:Add(function ()
        self:CalculationTotalScore()
    end)
end

function CtrlDZNZChaseMain:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true
    is_open = true
    self.m_ctrl_slt.selectedIndex = 0
    self.m_ctrl_revoke.selectedIndex = 0
    -- 局数的初始值
    self.m_comboBoxCount.value = ChaseCount[1]
    self:RequestResList()
end

-- 金额赋值
function CtrlDZNZChaseMain:SetChaseMoney()
    self.m_comboBoxMoney.items = ChaseMoneyName
    self.m_comboBoxMoney.values = ChaseMoneyValue
    self.m_comboBoxMoney.text = ChaseMoneyName[1]
end

-- 计算总分
function CtrlDZNZChaseMain:CalculationTotalScore()
    self.m_total_num.text = formatVal(tonumber(self.m_comboBoxCount.value) * tonumber(self.m_comboBoxMoney.value))
end

-- 刷新牛仔界面的金币
function CtrlDZNZChaseMain:UpdateNiuZaiMainMoney(num)
    loginSucceedInfo.user_info.gold = num
    if UIManager.IsShowState('ControllerDZNZ_Main') then
        UIManager.GetController('ControllerDZNZ_Main'):UpdateSelfMoney()
    end
end

-- 刷新自己的金币
function CtrlDZNZChaseMain:UpdateSelfMoney()
    self.m_money.text = formatVal(loginSucceedInfo.user_info.gold)
end

function CtrlDZNZChaseMain:BeginChase()
    if self.m_resData and #self.m_resData > 0 then
        local has_same_type = false   -- 相同类型校验
        for k, v in pairs(self.m_resData) do
            if v.bplaying == 1 and self.m_ctrl_slt.selectedIndex == ChaseReceive[v.areatype] then
                has_same_type = true
                break
            end
        end
        if has_same_type then
            UIManager.AddPopTip({strTit='您已经追加过该类型'})
        else
            self:ShowConfirmTips()
        end
    else
       self:ShowConfirmTips()
    end
end

-- 确定展示
function CtrlDZNZChaseMain:ShowConfirmTips()
    local chase_count_no = tonumber(self.m_comboBoxCount.value)
    local chase_money_no = tonumber(self.m_comboBoxMoney.value)

    if tonumber(loginSucceedInfo.user_info.gold) >= chase_count_no * chase_money_no then
        local arg =
        {
            tips_type = 0,                                       -- 提示用的类型
            chase_type = self.m_ctrl_slt.selectedIndex,          -- 选择的类型
            chase_count = chase_count_no,                        -- 选择的数量
            chase_money = chase_money_no,                        -- 选择的金额
            chase_cancel = self.m_ctrl_revoke.selectedIndex == 0 and 1 or 0  --UI这里 0是取消 1是不取消
        }
        UIManager.Show('CtrlDZNZChaseTips', arg)
    else
        UIManager.AddPopTip({ strTit = '亲爱的玩家，您当前的金币不足' })
    end
end

--required int64 createtime = 1;		//创建时间
--required int32 areatype = 2;		//下哪个区域
--required int32 totalcount = 3;		//共多少局
--required int32 curcount = 4;		//进行多少局
--required int32 everyroundscore = 5;		//每局下注多少
--required int64 totalwinscore = 6;		//总共赢
--required int32 bplaying = 7;		//是否正在打 0 打完 1.正在打
--repeated ZhuiHaoOneRoundInfo oneroundinfo  = 8;		//每局记录
---------------------------------------------------------------------------------
----------------------------------- 结果 ----------------------------------------
function CtrlDZNZChaseMain:InitResList()
    self.m_resList = self.m_view:GetChild('list').asList
    self.m_resList:SetVirtual()
    self.m_resList.itemRenderer = function (theIndex,theGObj)
        local _com = theGObj.asCom
        local _data = self.m_resData[theIndex + 1]
        local chase_type = ChaseReceive[_data.areatype]
        _com:GetChild('poker_type').text = ChaseName[chase_type]                                                -- 购买牌型
        _com:GetChild('round_num').text = string.format("%s/%s", _data.curcount, _data.totalcount)  -- 连追局数
        _com:GetChild('round_money').text = formatVal(_data.everyroundscore)                                    -- 每局金额
        _com:GetChild('reward').text = formatVal(_data.totalwinscore)                                           -- 累计盈利
        _com:GetChild('time').text = os.date("%Y-%m-%d\n%H:%M:%S", _data.createtime)                    -- 开始时间
        _com:GetController('status').selectedIndex = _data.bplaying == 1 and 0 or 1                             -- 0 进行中 1 已完成

        -- 1.按钮 - 细节 btn_detail
        local btn_detailed = _com:GetChild("btn_detail").asButton
        btn_detailed:RemoveEventListeners()
        btn_detailed.onClick:Add(function ()
            local arg =
            {
                chase_type = chase_type,                        -- 选择的类型
                chase_count = _data.totalcount,                 -- 选择的数量
                chase_money = _data.everyroundscore,            -- 选择的金额
                chase_playing = _data.bplaying == 1,            -- 是否正在打
                chase_time = _data.createtime,                  -- 时间
            }
            UIManager.Show("CtrlDZNZChaseDetail", arg)

            self:RequestResList()  -- 再刷一次
        end)

        -- 2.撤销
        local btn_cancel = _com:GetChild("btn_cancel").asButton
        btn_cancel:RemoveEventListeners()
        btn_cancel.onClick:Add(function ()
            local arg = { tips_type = 1, chase_type = chase_type, chase_count = 0, chase_money = 0, }
            UIManager.Show("CtrlDZNZChaseTips", arg)
        end)

        -- 3.增加局数
        local btn_num = _com:GetChild("btn_num").asButton
        btn_num:RemoveEventListeners()
        btn_num.onClick:Add(function ()
            local arg =
            {
                tips_type = 2,
                chase_type = chase_type,                        -- 选择的类型
                chase_count = _data.totalcount,                 -- 选择的数量
                chase_money = _data.everyroundscore,            -- 选择的金额
            }
            UIManager.Show("CtrlDZNZChaseTips", arg)
        end)

        -- 4.增加金额
        local btn_money = _com:GetChild("btn_money").asButton
        btn_money:RemoveEventListeners()
        btn_money.onClick:Add(function ()
            local arg =
            {
                tips_type = 3,
                chase_type = chase_type,                                -- 选择的类型
                chase_count = _data.totalcount,                         -- 选择的数量
                chase_money = _data.everyroundscore,                    -- 选择的金额
                chase_count_remain = _data.totalcount - _data.curcount  -- 剩余局数
            }
            UIManager.Show("CtrlDZNZChaseTips", arg)
        end)
    end

    self.m_resList.numItems = 0
    self.m_resData = nil
end

-- 请求结果列表
function CtrlDZNZChaseMain:RequestResList()
    if is_open then
        self.m_resList.numItems = 0
        self.m_resData = nil
        NetManager.SendNetMsg(GameServerConfig.logic,'DZNZ_RequestZhuiHaoInfo')
    end
end

function CtrlDZNZChaseMain:ResponseResList(result)
    self.m_resData = result
    self.m_resList.numItems = #result
end

function CtrlDZNZChaseMain:OnHide()
    self.m_view.visible = false
    is_open = false
end

return CtrlDZNZChaseMain