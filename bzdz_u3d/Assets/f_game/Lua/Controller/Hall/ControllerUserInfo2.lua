--个人信息界面
local ControllerUserInfo2 = class("ControllerUserInfo2")
--个人简介最大长度
local MaxDes=60
function ControllerUserInfo2:Init()
    self.m_viewParent=UIPackage.CreateObject('hall','leftToRightContent').asCom
	UIManager.normal:AddChild(self.m_viewParent)
	self.m_viewParent:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_viewParent.visible=false

    self.m_view=UIPackage.CreateObject('hall','userInfoView2').asCom
    self.m_viewParent:GetChild('parent'):AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)

	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerUserInfo2')
        UIManager.Hide('ControllerSafeBox2')
        UIManager.Hide('ControllerSafeBoxLogin2')
        UIManager.Hide('ControllerBag2')
        UIManager.Hide('ControllerUserData')
        UIManager.Hide('ControllerBindPhone2')
        UIManager.Hide('ControllerBindPlayer')
        UIManager.Hide('ControllerGiveAway')
        UIManager.Hide('ControllerBagFrame')
        UIManager.Hide('ControllerBagHead')
        UIManager.Hide('ControllerBagRename')
    end)

    -- 修改昵称
    self.m_view:GetChild("btn_rename").onClick:Add(function ()
        if tonumber(loginSucceedInfo.user_info.viptime) > 0 then
            UIManager.Show('ControllerBagRename')
            self:SetTopOneUPUPUP()
        else
            UIManager.AddPopTip({strTit='亲爱的玩家，您不是VIP暂时无法修改昵称'})
        end
    end)

    --我的物品
    self.m_view:GetChild("btnWuPin").onClick:Add(function ()
        UIManager.Show('ControllerBag2')
        self:SetTopOneUPUPUP()
    end)

    --选择相框
    self.m_view:GetChild("btn_frame").onClick:Add(function ()
        UIManager.Show('ControllerBagFrame')
        self:SetTopOneUPUPUP()
    end)

    --保险箱
    self.m_view:GetChild("btnBaoXianXiang").onClick:Add(function ()
        if loginSucceedInfo.user_info.proxyid == 1 then
            UIManager.Show('ControllerSafeBox2')
        else
            UIManager.Show('ControllerSafeBoxLogin2')
        end
        self:SetTopOneUPUPUP()
    end)

    --手机绑定
    self.m_view:GetChild("btnShouJi").onClick:Add(function ()
        if utf8.len(loginSucceedInfo.user_info.phone)>0 then
            UIManager.AddPopTip({strTit='已绑定手机号'})
            return
        end
        UIManager.Show('ControllerBindPhone2')
        self:SetTopOneUPUPUP()
    end)

    --数据统计
    self.m_view:GetChild("btnData").onClick:Add(function ()
        UIManager.Show('ControllerUserData')
        self:SetTopOneUPUPUP()
    end)

    --绑定玩家（代理）
    self.m_view:GetChild("btnBangDing").onClick:Add(function ()
        UIManager.Show('ControllerBindPlayer')
        self:SetTopOneUPUPUP()
    end)

    --赠送玩家道具（代理）
    self.m_view:GetChild("btnZengSong").onClick:Add(function ()
        UIManager.Show('ControllerGiveAway')
        self:SetTopOneUPUPUP()
    end)

    -- 换头像按钮
    self.m_view:GetChild('frame').onClick:Add(function ()
        --UIManager.Show('ControllerBagHead')
        --self:SetTopOneUPUPUP()
    end)

    -- 换昵称
    H_EventDispatcher:addEventListener('refreshSelfName',function (arg)
        self.m_view:GetChild('NickNameInput').text = loginSucceedInfo.user_info.nickname
    end)

    -- 换头像
    H_EventDispatcher:addEventListener('refreshSelfHead',function (arg)
        self.m_view:GetChild('head'):GetChild('icon').asLoader.url = GetPlySelfHeadUrl()
    end)

    --头像预览
    H_EventDispatcher:addEventListener('previewSelfHead',function (arg)
        self.m_view:GetChild('head'):GetChild('icon').asLoader.url = arg.head_url
    end)

    H_EventDispatcher:addEventListener('refreshVIPTime',function (arg)
        local num_viptime = tonumber(loginSucceedInfo.user_info.viptime)
        --VIP时间
        if num_viptime>0 then
            self.m_view:GetChild('txtVipTime').text=string.format( "VIP到期时间:%s",os.date("%Y-%m-%d %H:%M:%S", num_viptime))
        end
        self.m_view:GetChild('vip_icon').visible = num_viptime > 0
        self.m_view:GetChild('txtVipTime').visible = num_viptime > 0
    end)


    self.m_view:GetChild('txtID').text='ID:'..loginSucceedInfo.user_info.userid

    H_EventDispatcher:addEventListener('refreshHuShengTime',function (arg)
        local num_hu_shengTime = tonumber(loginSucceedInfo.user_info.hushengEndTime)
        --护身卡时间
        if num_hu_shengTime > 0 then
            self.m_view:GetChild('txtProtectTime').text=string.format( "护身卡到期时间:%s",os.date("%Y-%m-%d %H:%M:%S", num_hu_shengTime))
        end
        self.m_view:GetChild('txtProtectTime').visible = num_hu_shengTime > 0
    end)

    H_EventDispatcher:addEventListener('refreshHeadFrame',function (arg)
        self.m_view:GetChild("frame").asLoader.url = Bag_Config[loginSucceedInfo.user_info.vipFaceFrameID].url
    end)
end

function ControllerUserInfo2:SetTopOneUPUPUP()
    --保持在前面
	UIManager.normal:AddChild(self.m_viewParent)
	self.m_viewParent.visible=true
end

function ControllerUserInfo2:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_viewParent)
	self.m_viewParent.visible=true
    self.m_viewParent:GetTransition('t0'):Play()

    if loginSucceedInfo.user_info.vipnumber then
        self.m_view:GetChild('txtID').text='ID:'..loginSucceedInfo.user_info.vipnumber
    end

    self.m_view:GetChild('NickNameInput').text = loginSucceedInfo.user_info.nickname
    self.m_view:GetChild('head'):GetChild('icon').asLoader.url = GetPlySelfHeadUrl()

    --0男 1女 2未知
    self.m_view:GetChild('iconNan').visible=tonumber(loginSucceedInfo.user_info.sex)==0
    self.m_view:GetChild('iconNv').visible=tonumber(loginSucceedInfo.user_info.sex)~=0

    self.m_view:GetChild("frame").asLoader.url=Bag_Config[loginSucceedInfo.user_info.vipFaceFrameID].url
    self.m_view:GetChild('vip_icon').visible=false
    self.m_view:GetChild('txtVipTime').visible=false
    self.m_view:GetChild('txtProtectTime').visible=false

    --代理才可以绑定玩家
    self.m_view:GetChild("btnBangDing").visible = loginSucceedInfo.user_info.proxyid == 1

    --代理才可以赠送玩家
    self.m_view:GetChild("btnZengSong").visible = loginSucceedInfo.user_info.proxyid == 1

    --VIP时间
    if tonumber(loginSucceedInfo.user_info.viptime) > 0 then
        self.m_view:GetChild('vip_icon').visible=true
        self.m_view:GetChild('txtVipTime').visible=true
        self.m_view:GetChild('txtVipTime').text=string.format( "VIP到期时间:%s",os.date("%Y-%m-%d %H:%M:%S", tonumber(loginSucceedInfo.user_info.viptime)))
    end

    --护身卡时间
    if tonumber(loginSucceedInfo.user_info.hushengEndTime) > 0 then
        self.m_view:GetChild('txtProtectTime').visible=true
        self.m_view:GetChild('txtProtectTime').text=string.format( "护身卡到期时间:%s",os.date("%Y-%m-%d %H:%M:%S", tonumber(loginSucceedInfo.user_info.hushengEndTime)))
    end
end

function ControllerUserInfo2:OnHide()
    self.m_viewParent.visible=false
end

return ControllerUserInfo2