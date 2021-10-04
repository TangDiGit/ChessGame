--保险箱登录界面
local ControllerGiveAway = class("ControllerGiveAway")

function ControllerGiveAway:Init()
    self.m_viewParent=UIPackage.CreateObject('hall','leftToRightContent').asCom
    UIManager.normal:AddChild(self.m_viewParent)
    self.m_viewParent:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_viewParent.visible=false

    self.m_view=UIPackage.CreateObject('hall','giveAway').asCom
    self.m_viewParent:GetChild('parent'):AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerGiveAway')
    end)

    self.ply_slt_index = self.m_view:GetController('c1')
    self.count_list = { }
    self.m_comboBoxCount = self.m_view:GetChild("comboBoxCount").asComboBox  -- 下拉选择
    self.find_ply_id = 0
    self.slt_item_type = 0

    self.m_view:GetChild("btnFind").onClick:Add(function ()
        local input_ply_id = self.m_view:GetChild('txtPW').text
        if #input_ply_id > 0 then
            input_ply_id = tonumber(input_ply_id)
            if input_ply_id and input_ply_id > 0 then

                if input_ply_id == loginSucceedInfo.user_info.userid then
                    UIManager.AddPopTip({ strTit = "道具不可赠送给自己" })
                    return
                end

                coroutine.start(Friend_Find, {
                    userid = input_ply_id,
                    callbackSuccess = function (info)
                        self.find_ply_id = info.userid
                        self.ply_slt_index.selectedIndex = 1
                        self.m_view:GetChild('head'):GetChild('icon').asLoader.url=HandleWXIcon(info.headurl)
                        self.m_view:GetChild('txtNickName').text=info.nickname
                        self.m_view:GetChild('txtID').text=info.userid
                        self.m_view:GetChild('txtLV').text=info.level
                        self.m_view:GetChild('txtCity').text=''
                        self.m_view:GetChild('txtDes').text=info.note

                        self:GetBagContent()  -- 获取背包信息
                    end
                })
            else
                UIManager.AddPopTip({ strTit = "请正确输入玩家id" })
            end
        else
            UIManager.AddPopTip({ strTit = "请正确输入玩家id" })
        end
    end)

    --绑定接口
    self.m_view:GetChild("btnY").onClick:Add(function ()
        if tonumber(self.slt_item_type) == 0 then
            UIManager.AddPopTip({ strTit = "暂无道具可赠送" })
            return
        end
        self:SendProp(self.m_view:GetChild('txt_count').text)
    end)
end

function ControllerGiveAway:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_viewParent)
    self.m_viewParent.visible = true
    self.m_viewParent:GetTransition('t0'):Play()
    self:SetFirstStatus()
end

function ControllerGiveAway:SetFirstStatus()
    self.m_view:GetChild('txtPW').text = ''
    self.m_view:GetChild('txt_count').text = 1
    self.find_ply_id = 0
    self.slt_item_type = 0
    self.ply_slt_index.selectedIndex = 0
end

function ControllerGiveAway:GetBagContent()
    self.slt_item_type = 0
    self.count_list = { }
    coroutine.start(Bag_Get, {
        userid = loginSucceedInfo.user_info.userid,
        callbackSuccess = function (info)
            local items_list = { }
            local values_list = { }
            local res_sort_list = { }
            local str_type

            for i, v in ipairs(info.package) do
                if tonumber(v.number) > 0 and v.type > 1020 then
                    local _config = Bag_Config[v.type]
                    if _config.is_send then
                        v.sort = _config.sort
                        v.name = _config.name
                        table.insert(res_sort_list, v)
                    end
                end
            end

            if #res_sort_list > 0 then
                table.sort(res_sort_list, function (a,b)
                    return a.sort > b.sort
                end)

                for i, v in ipairs(res_sort_list) do
                    str_type = tostring(v.type)
                    table.insert(items_list, string.format("%s：%s", v.name, v.number))
                    table.insert(values_list, str_type)
                    self.count_list[str_type] = tonumber(v.number)
                end

                local has_data = #items_list > 0
                if has_data then
                    self:InitChaseCount(items_list, values_list)
                else
                    self:InitChaseCount({"暂无道具"}, {"0"})
                    self.slt_item_type = 0
                end
            else
                self:InitChaseCount({"暂无道具"}, {"0"})
                self.slt_item_type = 0
            end
        end
    })
end

function ControllerGiveAway:SendProp(input_item_count)
    if #input_item_count > 0 then
        input_item_count = tonumber(input_item_count)
        if input_item_count and input_item_count > 0 then
            if input_item_count > self.count_list[self.slt_item_type] then
                UIManager.AddPopTip({ strTit = "输入物品数量大于拥有数量" })
                return
            end
            coroutine.start(Friend_Gift, {
                fromuserid = loginSucceedInfo.user_info.userid,
                touserid = self.find_ply_id,
                gifttype = self.slt_item_type,
                number = input_item_count,
                callbackSuccess = function(info)
                    UIManager.AddPopTip({ strTit = string.format('道具[color=#E6BC57]%s[/color]赠送成功', Bag_Config[tonumber(self.slt_item_type)].name) })
                    --UIManager.AddPopTip({ strTit = info.content })
                    self:SetFirstStatus()
                end
            })
        else
            UIManager.AddPopTip({ strTit = "请正确输入物品数量" })
        end
    else
        UIManager.AddPopTip({ strTit = "请正确输入物品数量" })
    end
end

function ControllerGiveAway:InitChaseCount(items, values)
    self.m_comboBoxCount.items = items
    self.m_comboBoxCount.values = values
    self.m_comboBoxCount.text = items[1]
    self.slt_item_type = values[1]
    self.m_comboBoxCount.onChanged:Add(function ()
        self.slt_item_type = self.m_comboBoxCount.value
    end)
end

function ControllerGiveAway:OnHide()
    self.m_viewParent.visible=false
end

return ControllerGiveAway