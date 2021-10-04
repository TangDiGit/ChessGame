--背包界面
local ControllerBagFrame = class("ControllerBagFrame")

function ControllerBagFrame:Init()
    self.m_viewParent=UIPackage.CreateObject('hall','leftToRightContent').asCom
    UIManager.normal:AddChild(self.m_viewParent)
    self.m_viewParent:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_viewParent.visible=false

    self.m_view=UIPackage.CreateObject('hall','bagFrame').asCom
    self.m_viewParent:GetChild('parent'):AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerBagFrame')
    end)

    self.m_list=self.m_view:GetChild('list').asList
    self.m_list.onClickItem:Add(function (context)
        local _gcom=context.data
        local _data=_gcom.data
        self:ShowOneItem(_data)
    end)
end

function ControllerBagFrame:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_viewParent)
    self.m_viewParent.visible=true
    self.m_viewParent:GetTransition('t0'):Play()
    self:Refresh()
end

function ControllerBagFrame:Refresh()
    --当前选择
    self.m_selectItem=nil
    self.m_list:RemoveChildrenToPool()

    coroutine.start(Bag_Get,{
        userid = loginSucceedInfo.user_info.userid,
        callbackSuccess = function (info)
            local _isZore = true
            for i, v in ipairs(info.package) do
                if tonumber(v.number)>0 then
                    _isZore = false
                end
            end

            self.m_list:RemoveChildrenToPool()
            for i, v in ipairs(info.package) do
                local _config
                -- 头像框 -- 10000 以上才是道具
                local is_frame = false
                if v.type <= 1020 then
                    is_frame = true
                    _config = Bag_Config[v.type - 1000]
                else
                    _config = Bag_Config[v.type]
                end

                if is_frame then
                    local _com = self.m_list:AddItemFromPool()
                    _com:GetChild('icon').asLoader.url = _config.url
                    _com:GetChild('txtDes').text = _config.des
                    if _config.is_frame then
                        _com:GetChild('txt_card').text = ""
                        _com:GetChild('txt_frame').text = "点击使用"
                    else
                        _com:GetChild('txt_frame').text = ""
                        _com:GetChild('txt_card').text = "点击使用"
                    end

                    _com.data =
                    {
                        name = _config.name,
                        number = v.number,
                        url = _config.url,
                        des = _config.des,
                        number = tonumber(v.number),
                        type = v.type,
                        is_frame = _config.is_frame,
                        is_card = _config.is_card,
                        is_tips = _config.is_tips,
                        is_phone_bill = _config.is_phone_bill,
                        is_rebirth = _config.is_rebirth,
                        is_protect = _config.is_protect,
                    }
                end
            end
        end
    })
end

--显示一个道具的详细信息
function ControllerBagFrame:ShowOneItem(data)
    if data.number == 0 then
        UIManager.AddPopTip({ strTit = '抱歉，您暂未获得该物品' })
        return
    end
    self.m_selectItem = data
    local is_frame = data.type <= 1020
    if data.type == 10003 or data.type == 10004 or is_frame then
        -- 头像只有 月卡或者周卡用户才能使用
        if is_frame then
            if tonumber(loginSucceedInfo.user_info.viptime) == 0 then
                UIManager.AddPopTip({ strTit = '尚未开通VIP卡' })
                return
            end
        end

        coroutine.start(Prop_Use, {
            userid = loginSucceedInfo.user_info.userid,
            type=self.m_selectItem.type,
            callbackSuccess = function (info)
                if data.type <= 1020 then
                    setHeadFrame(data.type - 1000)
                end
            end
        })
    end
end

function ControllerBagFrame:OnHide()
    self.m_viewParent.visible=false
end
return ControllerBagFrame