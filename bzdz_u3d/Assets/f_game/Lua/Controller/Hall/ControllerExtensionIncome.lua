-- 收入
local ControllerExtensionIncome = class("ControllerExtensionIncome")

function ControllerExtensionIncome:Init()
    self.m_view = UIPackage.CreateObject('extensionsystem', 'extension_income').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    self:InitList()

    self.m_view:GetChild("btn_close").onClick:Add(function ()
        UIManager.Hide('ControllerExtensionIncome')
    end)
end

function ControllerExtensionIncome:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true

    self:ShowList()
end

function ControllerExtensionIncome:InitList()
    self.m_listIncomeList = self.m_view:GetChild('income_list').asList
    self.m_listIncomeList:SetVirtual()
    self.m_listIncomeList.itemRenderer = function (theIndex,theGObj)
        local _com = theGObj.asCom
        local _t = self.m_listIncomeData[theIndex+1]
        _com.data=_t
        _com:GetChild('wanjia').text = formatVal(_t.UserFanLi)
        _com:GetChild('daili').text = formatVal(_t.AgentFanLi)
        _com:GetChild('shijian').text = _t.Date
    end
    self.m_listIncomeList.numItems = 0
    self.m_listIncomeData = nil
end

function ControllerExtensionIncome:ShowList()
    coroutine.start(function ()
        local _www = WWW(string.format(Url_extensionSystem_everyDayIncome,loginSucceedInfo.user_info.userid,0,loginSucceedInfo.token))
        coroutine.www(_www)
        if _www.error~=nil then
            UIManager.AddPopTip({strTit=_www.error})
            return
        end
        local _info = json.decode(_www.text)
        local res = { }
        for i, v in ipairs(_info.data) do
            if v.UserFanLi > 0 or v.AgentFanLi > 0 then
                table.insert(res, v)
            end
        end
        self.m_listIncomeData = res
        self.m_listIncomeList.numItems = #self.m_listIncomeData
    end)
end

function ControllerExtensionIncome:OnHide()
    self.m_view.visible = false
end

return ControllerExtensionIncome

