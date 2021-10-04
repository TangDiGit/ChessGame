--个人信息界面
local ControllerUserInfo = class("ControllerUserInfo")
--个人简介最大长度
local MaxDes=60
function ControllerUserInfo:Init()
	self.m_view=UIPackage.CreateObject('hall','userInfoView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        

        if utf8.len(self.m_inputDes.text)>60 then
            UIManager.AddPopTip({strTit='修改失败,长度60字以内'})
            UIManager.Hide('ControllerUserInfo')
            return
        end
        UIManager.Hide('ControllerUserInfo')

        coroutine.start(Person_Update,{
			userid=loginSucceedInfo.user_info.userid,
            nickname=self.m_view:GetChild('NickNameInput').text,
            sex=self.m_comboSex.selectedIndex,
            location=json.encode({region=self.m_Address1.text,city=self.m_Address2.text}),
            note=self.m_inputDes.text,
            callbackSuccess=function (info)
                loginSucceedInfo.user_info.nickname=self.m_view:GetChild('NickNameInput').text
                loginSucceedInfo.user_info.sex=self.m_comboSex.selectedIndex
                loginSucceedInfo.user_info.location=json.encode({region=self.m_Address1.text,city=self.m_Address2.text})
                loginSucceedInfo.user_info.note=self.m_inputDes.text
			end
		})
    end)

    --查看数据
    self.m_controller=self.m_view:GetController("c1")
    self.m_view:GetChild("btnData").onClick:Add(function ()
        if self.m_controller.selectedIndex==0 then
            self.m_controller.selectedIndex=1
        else
            self.m_controller.selectedIndex=0
        end
    end)
    self.m_view:GetChild("btnRoundRecord").onClick:Add(function ()
        coroutine.start(Game_Data_Get,{
			userid=loginSucceedInfo.user_info.userid,
            callbackSuccess=function (info)
                UIManager.Show('ControllerUserInfoRoundRecord',info)
			end
		})
        
    end)


    --地区
    local addrs1={}
    local addrs2={}
    for i,v in pairs(city) do
        table.insert(addrs1,v.name)
        addrs2[v.name]={}
        for i2,v2 in pairs(v.city) do
            table.insert( addrs2[v.name], v2.name)
        end
    end
    self.m_Address1=self.m_view:GetChild("comboBoxAddress1").asComboBox
    self.m_Address1.items=addrs1
    self.m_Address1.onChanged:Add(function ()
        local _t2=addrs2[self.m_Address1.text] or {}
        self.m_Address2.items=_t2
        self.m_Address2.text=_t2[1] or ''
    end)

    self.m_Address2=self.m_view:GetChild("comboBoxAddress2").asComboBox
    local _t2=addrs2[self.m_Address1.text] or {}
    self.m_Address2.items=_t2
    self.m_Address2.text=_t2[1] or ''
    
    
    --背包
    self.m_view:GetChild("btnBag").onClick:Add(function ()
        UIManager.Show('ControllerBag')
    end)

    --保险箱
    self.m_view:GetChild("btnSafeBoxLogin").onClick:Add(function ()
        UIManager.Show('ControllerSafeBoxLogin2')
    end)

    --绑定手机
    self.m_view:GetChild("btnBindPhone").onClick:Add(function ()
        if utf8.len(loginSucceedInfo.user_info.phone)>0 then
            UIManager.AddPopTip({strTit='已绑定手机号'})
            return
        end
        UIManager.Show('ControllerBindPhone')
    end)

    --性别
    self.m_comboSex=self.m_view:GetChild('comboBoxSex').asComboBox
    --个性签名
    self.m_inputDes=self.m_view:GetChild('txtDes').asTextInput
    self.m_inputDes.onChanged:Add(function ()
        self.m_view:GetChild("txtDesCount").text=string.format("%s/%s",utf8.len(self.m_inputDes.text),MaxDes)
    end)

    H_EventDispatcher:addEventListener('refreshVIPTime',function (arg)
        self.m_view:GetChild('vip_icon').visible=false
        self.m_view:GetChild('txtVipTime').visible=false
        if tonumber(loginSucceedInfo.user_info.viptime)>0 then
            self.m_view:GetChild('vip_icon').visible=true
            self.m_view:GetChild('txtVipTime').visible=true
            self.m_view:GetChild('txtVipTime').text=string.format( "到期时间:%s",os.date("%Y-%m-%d %H:%M %S", tonumber(loginSucceedInfo.user_info.viptime)))
        end
    end)

    
end

function ControllerUserInfo:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

    self.m_inputDes.text=loginSucceedInfo.user_info.note
    self.m_view:GetChild("txtDesCount").text=string.format("%s/%s",utf8.len(loginSucceedInfo.user_info.note),MaxDes)

    self.m_view:GetChild('NickNameInput').text=loginSucceedInfo.user_info.nickname
    self.m_view:GetChild('txtID').text='游戏ID:'..loginSucceedInfo.user_info.userid
    if loginSucceedInfo.user_info.vipnumber then
        self.m_view:GetChild('txtID').text='游戏ID:'..loginSucceedInfo.user_info.vipnumber
    end
    --0男 1女 2未知
    self.m_comboSex.selectedIndex=tonumber(loginSucceedInfo.user_info.sex)
    self.m_view:GetChild('txtLV').text=string.format( "等级：LV [color=#FFF2B5,#F1C83C]%s[/color]",loginSucceedInfo.user_info.level)
    self.m_view:GetChild('head'):GetChild('icon').asLoader.url=GetPlySelfHeadUrl()

    self.m_Address1.text=''
    self.m_Address2.text=''
    if utf8.len(loginSucceedInfo.user_info.location)>0 then
        local _info=json.decode(loginSucceedInfo.user_info.location)
        self.m_Address1.text=_info.region
        self.m_Address2.text=_info.city
    end

    self.m_view:GetChild('vip_icon').visible=false
    self.m_view:GetChild('txtVipTime').visible=false
    if tonumber(loginSucceedInfo.user_info.viptime)>0 then
        self.m_view:GetChild('vip_icon').visible=true
        self.m_view:GetChild('txtVipTime').visible=true
        self.m_view:GetChild('txtVipTime').text=string.format( "到期时间:%s",os.date("%Y-%m-%d %H:%M %S", tonumber(loginSucceedInfo.user_info.viptime)))
    end

    --胜率
    self.m_view:GetChild('txtWinRate').text=string.format( "胜率:[color=#FFFFFF]%s[/color]",0)
    --弃牌率
    self.m_view:GetChild('txtDropCardRate').text=string.format( "弃牌率:[color=#FFFFFF]%s[/color]",0)
    --最大赢取
    self.m_view:GetChild('txtMaximumIncome').text=string.format( "最大赢取:[color=#FFFFFF]%s[/color]",0)

    self.m_view:GetChild('txtToatlRoundCount').text=string.format( "总局数:[color=#FFFFFF]%s[/color]",0)
    if loginSucceedInfo.user_info.gamecount then
        local _v=tonumber(loginSucceedInfo.user_info.wincounts)/tonumber(loginSucceedInfo.user_info.gamecount)
        _v=string.format('%.2f',_v)
        self.m_view:GetChild('txtWinRate').text=string.format( "胜率:[color=#FFFFFF]%s[/color]",_v*100)..'%'

        if loginSucceedInfo.user_info.dropcardcount then
            local _v=tonumber(loginSucceedInfo.user_info.dropcardcount)/tonumber(loginSucceedInfo.user_info.gamecount)
            _v=string.format('%.2f',_v)
            self.m_view:GetChild('txtDropCardRate').text=string.format( "弃牌率:[color=#FFFFFF]%s[/color]",_v*100)..'%'
        end

        self.m_view:GetChild('txtToatlRoundCount').text=string.format( "总局数:[color=#FFFFFF]%s[/color]",formatVal(tonumber(loginSucceedInfo.user_info.gamecount)))
    end

    if loginSucceedInfo.user_info.winmaxgold  then
        self.m_view:GetChild('txtMaximumIncome').text=string.format( "最大赢取:[color=#FFFFFF]%s[/color]",formatVal(tonumber(loginSucceedInfo.user_info.winmaxgold)))
    end

    if loginSucceedInfo.user_info.maxcards then
        local _strs=lua_string_split(loginSucceedInfo.user_info.maxcards,'#')
        for i=1,5 do
            UIManager.SetPoker(self.m_view:GetChild('card'..i),tonumber(_strs[i]))
        end
    else
        for i=1,5 do
            UIManager.SetPoker(self.m_view:GetChild('card'..i),0)
        end  
    end
end

function ControllerUserInfo:OnHide()
	self.m_view.visible=false
end
return ControllerUserInfo