-- 比赛场的提示
local ControllerHallZhuiHaoView = class("ControllerHallZhuiHaoView")

function ControllerHallZhuiHaoView:Init()
    self.m_view = UIPackage.CreateObject('hall', 'hallZhuiHaoListView').asCom
    UIManager.top:AddChild(self.m_view)   -- 层级搞高点，换桌会重新刷新界面
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    -- 还需要自动关闭 _com:GetController('type').=3
    self.m_view:GetChild("btn_cancel").onClick:Add(function ()
        UIManager.Hide('ControllerHallZhuiHaoView')
    end)

    self.m_view:GetChild("btn_confirm").onClick:Add(function ()
        self:ClickConfirm()
    end)

    self.niuZaiData =
    {
        [1] = { id = 1, area = tab_betArea.red_win, money = 0, name = "红方", is_slt = false },
        [2] = { id = 2, area = tab_betArea.blue_win, money = 0, name = "蓝方", is_slt = false },
        [3] = { id = 3, area = tab_betArea.pingshou, money = 0, name = "平", is_slt = false },
        [4] = { id = 4, area = tab_betArea.sp_tonghua, money = 0, name = "同花", is_slt = false },
        [5] = { id = 5, area = tab_betArea.sp_lianpai, money = 0, name = "连牌", is_slt = false },
        [6] = { id = 6, area = tab_betArea.sp_duizi, money = 0, name = "对子", is_slt = false },
        [7] = { id = 7, area = tab_betArea.sp_tonghualianpai, money = 0, name = "同花连牌", is_slt = false },
        [8] = { id = 8, area = tab_betArea.sp_duiA, money = 0, name = "对A", is_slt = false },
        [9] = { id = 9, area = tab_betArea.sp_gaopai, money = 0, name = "高牌", is_slt = false },
        [10] = { id = 10, area = tab_betArea.sp_liangdui, money = 0, name = "两对", is_slt = false },
        [11] = { id = 11, area = tab_betArea.sp_santiao, money = 0, name = "三条", is_slt = false },
        [12] = { id = 12, area = tab_betArea.sp_hulu, money = 0, name = "葫芦", is_slt = false },
        [13] = { id = 13, area = tab_betArea.sp_jingang, money = 0, name = "金刚", is_slt = false },
    }

    self.baiRenData =
    {
        [1] = { id = 1, area = 0, money = 0, name = "区域1", is_slt = false },
        [2] = { id = 2, area = 1, money = 0, name = "区域2", is_slt = false },
        [3] = { id = 3, area = 2, money = 0, name = "区域3", is_slt = false },
        [4] = { id = 4, area = 3, money = 0, name = "区域4", is_slt = false },
    }

    self.temp_slt = { }

    self.is_niuZai = false
    self:InitBetList()
end

function ControllerHallZhuiHaoView:Show(arg)
    --保持在前面
    UIManager.top:AddChild(self.m_view)
    self.m_view.visible = true

    self.slt_money_name = { }
    self.slt_money_value = { }
    local money_list = arg.slt_money_list
    for i = 1, #money_list do
        table.insert(self.slt_money_name, formatVal(money_list[i]))
        table.insert(self.slt_money_value, tostring(money_list[i]))
    end
    self.is_niuZai = arg.is_niuzai
    self:ShowBetList(arg.is_niuzai and self.niuZaiData or self.baiRenData)
end

function ControllerHallZhuiHaoView:InitBetList()
    self.m_betAreaList = self.m_view:GetChild('list').asList
    --self.m_betAreaList:SetVirtual()
    self.m_betAreaList.itemRenderer = function (theIndex, theGObj)
        local _com = theGObj.asCom
        local _data = self.m_betData[theIndex + 1]
        local comboBox = _com:GetChild("comboBoxCount").asComboBox
        local btn_slt = _com:GetChild("btn_slt")
        -- comboBox的赋值给data
        _data.comboBox = comboBox
        -- btn_slt赋值给 data（默认都不选中）
        _data.btnSltCtrl = btn_slt:GetController("button")
        _data.btnSltCtrl.selectedIndex = _data.is_slt and 1 or 0
        -- 名字
        _com:GetChild("name").text = _data.name
        -- 金额
        self:SetItemMoney(comboBox)
    end
    self.m_betAreaList.numItems = 0
    self.m_betData = nil
end

function ControllerHallZhuiHaoView:ShowBetList(list)
    self.m_betData = list
    self.m_betAreaList.numItems = #list
end

-- 金额
function ControllerHallZhuiHaoView:SetItemMoney(comboBox)
    comboBox.items = self.slt_money_name
    comboBox.values = self.slt_money_value
    comboBox.text = self.slt_money_name[1]
    comboBox.value = self.slt_money_value[1]
end

-- 点击确认
function ControllerHallZhuiHaoView:ClickConfirm()
    self.temp_slt = { }
    local dataValue
    for i = 1, #self.m_betData do
        dataValue = self.m_betData[i]
        if dataValue.btnSltCtrl.selectedIndex == 1 or dataValue.btnSltCtrl.selectedIndex == 3 then
            dataValue.is_slt = true
            table.insert(self.temp_slt, { area = dataValue.area, num = tonumber(dataValue.comboBox.value) })
        else
            dataValue.is_slt = false
        end
    end
    if #self.temp_slt > 0 then
        if self.is_niuZai then
            UIManager.GetController('ControllerDZNZ_Main'):ContinueBetSuccess(self.temp_slt)
        else
            UIManager.GetController('ControllerBaiRen'):ContinueBetSuccess(self.temp_slt)
        end
        self:OnHide()
    else
        UIManager.AddPopTip({strTit = '没有选择任何续投项'})
    end
end

function ControllerHallZhuiHaoView:OnHide()
    self.m_view.visible = false
end

return ControllerHallZhuiHaoView

