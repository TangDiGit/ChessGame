local DuiHua={'嘻嘻,很好玩哦!','我在游戏里面等你哦~','快来玩吧~','嗯,今天天气真不错.'}

--大厅主界面
local ControllerHall = class("ControllerHall")

function ControllerHall:Init()
	self.m_view = UIPackage.CreateObject('hall','hallView').asCom
    UIManager.normal:AddChild(self.m_view)
    --适配刘海屏水滴屏
    UIManager.AdaptiveAllotypy(self.m_view)
    self.m_view.visible = false
    self.m_content = self.m_view:GetChild('content')

    self:Load_Prefab()
    self:Load_SpineBg()

    LoadBgm()

    self.m_content:GetChild("GodTurret").y=self.m_content:GetChild("GodTurret").y + 25

    self.m_duihua = self.m_content:GetChild('duihua')
    self.m_duihua.visible=false
    self.m_content:GetChild("Dealer").onClick:Add(function ()
        if self.m_duihua.visible==false then
            self.m_duihua.visible=true
            self.m_duihua:GetChild('txtTit').text=DuiHua[math.random(1,#DuiHua)]
            Timer.New(function ()
                self.m_duihua.visible=false
            end,2,1):Start()
        end
    end)

    --财神转盘
    self.m_content:GetChild("GodTurret").onClick:Add(function ()
        if main_can_click then
            UIManager.Show('ControllerWaitTip')
            F_ResourceManager.instance:AddPackage("luckytable", function ()
                UIManager.Hide('ControllerWaitTip')
                UIManager.Show('ControllerGodTurret2')
            end)
        end
    end)

    --商城
    self.m_content:GetChild("shop").onClick:Add(function ()
        UIManager.Show('ControllerWaitTip')
        F_ResourceManager.instance:AddPackage("shop",function ()
            UIManager.Hide('ControllerWaitTip')

			UIManager.Show('ControllerShop')
		end)
    end)

    --任务
    self.m_content:GetChild("btnTask").onClick:Add(function ()
        
        UIManager.Show('ControllerWaitTip')
        F_ResourceManager.instance:AddPackage("task",function ()
            UIManager.Hide('ControllerWaitTip')

			UIManager.Show('ControllerTask')
		end)
    end)

    --个人信息
    self.m_content:GetChild("head").onClick:Add(function ()
        --UIManager.Show('ControllerUserInfo')
    end)

    self.m_content:GetChild("btnUserInfo").onClick:Add(function ()
        UIManager.Show('ControllerUserInfo2')
    end)

    --设置
    self.m_content:GetChild("btnSetting").onClick:Add(function ()
        UIManager.Show('ControllerSetting')
    end)

    --游戏大厅
    self.m_content:GetChild("n61"):GetChild("n5").onClick:Add(function ()
        if main_can_click then
            UIManager.Show('ControllerWaitTip')
            F_ResourceManager.instance:AddPackage("gamehall",function ()
                UIManager.Hide('ControllerWaitTip')

                UIManager.Show('ControllerGameHall',{isSkipRefresh=false})
            end)
        end
    end)
    
    self.m_content:GetChild("n61"):GetChild("btnBaiRen").onClick:Add(function ()
        --点击德州牛仔
        if main_can_click then
            self:Enter_DZNZ()
        end
    end)

    self.m_content:GetChild("n61"):GetChild("btnDB").onClick:Add(function ()
        if main_can_click then
            self:Enter_DBQB()
        end
    end)

    self.m_content:GetChild("n61"):GetChild("n7").onClick:Add(function ()
        -- 比赛场
        if main_can_click then
            UIManager.Show('ControllerWaitTip')
            F_ResourceManager.instance:AddPackage("newbgbisai",function ()
                F_ResourceManager.instance:AddPackage("competition",function ()
                    UIManager.Hide('ControllerWaitTip')
                    UIManager.Show('ControllerCompetition')
                end)
            end)
        end
    end)

    --兑换
    self.m_content:GetChild("btnConversion").onClick:Add(function ()
        UIManager.Show('ControllerConversion')
    end)

    -- 商城
    self.m_content:GetChild("btnShop").onClick:Add(function ()
        UIManager.Show('ControllerWaitTip')
        F_ResourceManager.instance:AddPackage("shop",function ()
            UIManager.Hide('ControllerWaitTip')
			UIManager.Show('ControllerShop')
		end)
    end)

    --公告/排行榜
    --默认显示公告
    --self.isRanking=false
    --显示排行榜
    self.isRanking = false
    self.is_open_rank = false
    --self.m_content:GetTransition("tShowRanking"):Play()
    self.m_content:GetChild("notice"):GetChild("n37").visible=false
    self.m_content:GetChild("notice"):GetChild("n36").visible=false
    self.m_content:GetChild("notice"):GetChild("txtNotice").visible=false
    self.m_content:GetChild("notice"):GetChild("btnArr").onClick:Add(function ()
        if self.isRanking == false then
            self.isRanking = true
            self.m_content:GetTransition("tShowRanking"):Play()
            if not self.is_open_rank then
                self.is_open_rank = true
                self:ShowRanking()
            end
        end
    end)

    self.m_content:GetChild("ranking"):GetChild("btnArr").onClick:Add(function ()
        if self.isRanking==true then
            self.isRanking=false
            self.m_content:GetTransition("tHideRanking"):Play()
        end
    end)

    --排行榜查看更多
    self.m_content:GetChild("ranking"):GetChild("btnLock").onClick:Add(function ()
        if self.m_RankingData and #self.m_RankingData > 0 then
            UIManager.Show('ControllerRanking2')
        end
    end)

    --活动界面
    self.m_content:GetChild("btnActivity").onClick:Add(function ()
        F_ResourceManager.instance:AddPackage("newbgactivity", function()
            F_ResourceManager.instance:AddPackage("activity", function()
                UIManager.Show('ControllerActivity')
            end)
        end)
    end)
    
    --商圈
    self.m_content:GetChild("btnExtensionSystem").onClick:Add(function ()
        UIManager.Show('ControllerWaitTip')
        F_ResourceManager.instance:AddPackage("extensionsystem2",function ()
            F_ResourceManager.instance:AddPackage("extensionsystem",function ()
                UIManager.Hide('ControllerWaitTip')
                UIManager.Show('ControllerExtensionSystem')
            end)
		end)
    end)

    --分享
    self.m_content:GetChild("btnShare").onClick:Add(function ()
        UIManager.Show('ControllerWaitTip')
        F_ResourceManager.instance:AddPackage("share",function ()
            UIManager.Hide('ControllerWaitTip')
			UIManager.Show('ControllerShare')
		end)
    end)

    --客服
    self.m_content:GetChild("btnService").onClick:Add(function ()
        UIManager.Show('ControllerService')
    end)

    --消息榜
    self.m_content:GetChild("btnMsg").onClick:Add(function ()
        UIManager.Show('ControllerMsg')
    end)

    --好友
    self.m_content:GetChild("btnFriend").onClick:Add(function ()
        UIManager.Show('ControllerFriend')
    end)

    -- 换昵称
    H_EventDispatcher:addEventListener('refreshSelfName',function (arg)
        self.m_content:GetChild("txtNickName").text = loginSucceedInfo.user_info.nickname
    end)

    -- 换头像
    H_EventDispatcher:addEventListener('refreshSelfHead',function (arg)
        self.m_content:GetChild("head"):GetChild("icon").asLoader.url = GetPlySelfHeadUrl()
    end)

    H_EventDispatcher:dispatchEvent({ name = 'ReName', content = "" })

    H_EventDispatcher:addEventListener('refreshSelfMoney',function (arg)
        self.m_content:GetChild("txtCurrency0").text = formatVal(tonumber(loginSucceedInfo.user_info.gold))
    end)

    H_EventDispatcher:addEventListener('refreshSelfIntegral',function (arg)
        self.m_content:GetChild("txtCurrency1").text = formatVal(tonumber(loginSucceedInfo.user_info.integral))
    end)

    H_EventDispatcher:addEventListener('refreshHeadFrame',function (arg)
        self.m_content:GetChild("frame").asLoader.url = Bag_Config[loginSucceedInfo.user_info.vipFaceFrameID].url
    end)

    --追求者红点提示
    self.m_tipFriend=self.m_content:GetChild('tipFriend')
    H_EventDispatcher:addEventListener('refreshTipFriend',function (arg)
        self.m_tipFriend.visible=arg.isMark
    end)

    --邮件红点提示
    self.m_tipMail=self.m_content:GetChild('tipMsg')
    H_EventDispatcher:addEventListener('refreshTipMail',function (arg)
        self.m_tipMail.visible=arg.isMark
    end)

    --任务红点提示
    self.m_tipTask=self.m_content:GetChild('tipTask')
    H_EventDispatcher:addEventListener('refreshTipTask',function (arg)
        self.m_tipTask.visible=arg.isMark
    end)

    --公告信息 使用本地
    coroutine.start(Notice_Get,{
        userid = loginSucceedInfo.user_info.userid,
        callbackSuccess=function (info)
            self.m_content:GetChild("notice"):GetChild('txtNotice').text=info.gamenotice
        end
    })

    --排行榜信息
    self:InitRanking()

    --截图分享二维码
    --H_EventDispatcher:addEventListener('shareQRCode',function (arg)
        --截屏组件分享出去 0微信 1朋友圈
        --F_MobManager.instance:ShareQRCode(self.m_content:GetChild("shareCommon"),arg.mtype)
    --end)

    --滚动公告
    self.m_noticescroll=self.m_content:GetChild('noticescroll')
    self.m_noticescroll.visible = false
    self.m_noticescrollText = self.m_noticescroll:GetChild('noticeMiddle'):GetChild('notcieText'):GetChild('text')
    self.m_noticescrollData = {}
    self.m_noticescrollMove = false
    Timer.New(function ()
        if #self.m_noticescrollData>0 and not self.m_noticescrollMove then
            if self.m_noticescrollData[1].count<=0 then
                table.remove(self.m_noticescrollData,1)
                if #self.m_noticescrollData<=0 then
                    self.m_noticescroll.visible=false
                end
            else
                self.m_noticescrollData[1].count=self.m_noticescrollData[1].count - 1
                self.m_noticescrollMove = true
                self.m_noticescroll.visible = true
                self.m_noticescrollText.text = self.m_noticescrollData[1].content
                self.m_noticescrollText.x = 1000--self.m_noticescroll.width
                local _duration = (self.m_noticescrollText.width + self.m_noticescroll.width)/200
                -- self.m_noticescrollText.width* - 1
                self.m_noticescrollText:TweenMoveX(-1100, _duration):SetEase(EaseType.Linear):OnComplete(function ()
                    self.m_noticescrollMove = false
                end)
            end
        end
    end,0.5,-1):Start()

    --玩家聊天
    H_NetMsg:addEventListener('UserChat',function (arg)
        --print('收到消息 UserChat')
        local msg = Protol.GameBaseMsg_pb.UserChat()
        msg:ParseFromString(arg.pb_data)
        --print(tostring(msg))
        --喇叭信息
        if msg.senduserid == 100 then
            local _info = json.decode(msg.jsoninfo)
            local content = ""
            if _info.nickname and string.len(_info.nickname) > 0 then
                -- 玩家
                content = string.format("[color=#FFFF00]%s[/color]:%s", _info.nickname, _info.context)
            else
                -- 系统
                content = string.format("[color=#FFFF00]%s[/color]", _info.context)
            end
            table.insert(self.m_noticescrollData,{ content = content , count = 1 })
            return
        end
    end)

    self.m_loadSpineBg = false
    self.m_loadPrefab = false
    self.m_openActivity = false
end

function ControllerHall:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
    self.m_view.visible=true
    
    UIManager.Hide('ControllerLogin')
    UIManager.Hide('ControllerAccountLogin')
    UIManager.Hide('ControllerReg')

    self.m_content:GetChild("txtNickName").text = loginSucceedInfo.user_info.nickname
    self.m_content:GetChild("head"):GetChild("icon").asLoader.url = GetPlySelfHeadUrl()

    self.m_content:GetChild("txtID").text=string.format("ID:%s",loginSucceedInfo.user_info.userid)
    if loginSucceedInfo.user_info.vipnumber then
        self.m_content:GetChild("txtID").text=string.format("ID:%s",loginSucceedInfo.user_info.vipnumber)
    end
    --self.m_content:GetChild("txtLV").text=string.format("LV:%s",loginSucceedInfo.user_info.level)
    self.m_content:GetChild("txtCurrency0").text=formatVal(tonumber(loginSucceedInfo.user_info.gold))
    self.m_content:GetChild("txtCurrency1").text=formatVal(tonumber(loginSucceedInfo.user_info.integral))

    self.m_content:GetChild("frame").asLoader.url = Bag_Config[loginSucceedInfo.user_info.vipFaceFrameID].url

    self.m_tipFriend.visible=false
    self.m_tipMail.visible=false
    RefreshTipFriend()
    RefreshTipMail()
    RefreshTipTask()

    Refresh_Person_Gold()

    --self.m_content:GetChild("vip_icon").visible=false
    --if tonumber(loginSucceedInfo.user_info.viptime)>0 then
    --    self.m_content:GetChild("vip_icon").visible=true
    --end
    
    F_SoundManager.instance:OpenMusicVolume()

    --todo 赋值二维码 可能存在失败
    loginSucceedInfo.user_info.QRCodeLoaderUrl=nil
    loginSucceedInfo.user_info.QRCodeUrl=nil
    coroutine.start(function ()
        local _www = WWW(string.format(Url_extensionSystem_getQRUrl,loginSucceedInfo.user_info.userid,loginSucceedInfo.token))
        coroutine.www(_www)
        if _www.error~=nil then
            --UIManager.AddPopTip({strTit=_www.error})
            return 
        end
        --print('_www.text:'.._www.text)
        local _info=json.decode(_www.text)

        loginSucceedInfo.user_info.QRCodeUrl=_info.data[1]
        coroutine.start(getQRCode,{text=string.gsub(_info.data[1], "&", "%%26"),callbackSuccess=function (url)
            self.m_content:GetChild("shareCommon"):GetChild("n1").asLoader.url=url
            loginSucceedInfo.user_info.QRCodeLoaderUrl=url
        end})
    end)

    if self.m_timerQRCode then
        self.m_timerQRCode:Stop()
    end

    --默认连第一个场(喇叭)
    local _index=1
	--连接socket
	local t=lua_string_split(loginSucceedInfo.server_info[_ServerMap[_index][1]],'#')
	local _gs=t[1]
	local _ip=t[2]
	local _port=t[3]
	local _send_To=t[4]
	local _send_Mcmd=t[5]

	GameServerConfig.ipArr=_ip..':'.._port
	GameServerConfig.send_To=_send_To
	GameServerConfig.send_Mcmd=_send_Mcmd
    GameServerConfig.serverid=_ServerMap[_index][2]
    
    UIManager.Show("ControllerWaitTip",{strTit='',timeOut=10})
	NetManager.ConnectServer(GameServerConfig,function ()
		UIManager.Hide('ControllerWaitTip')
		UIManager.AddPopTip({strTit='连接服务器失败,请重试.'})
        self:PopUpActivityView()
	end,function ()
		UIManager.Hide('ControllerWaitTip')
		H_HeartbeatManager.Restart(GameServerConfig.logic) --开启心跳
        self:PopUpActivityView()
    end)
    loginSucceedInfo.user_info.proxyid=loginSucceedInfo.user_info.proxyid or 0
    self.m_content:GetChild("btnExtensionSystem").visible=loginSucceedInfo.user_info.proxyid == 1
    self.m_content:GetChild("btnShare").visible=loginSucceedInfo.user_info.proxyid == 0
end

function ControllerHall:PopUpActivityView()
    if not self.m_openActivity then
        self.m_openActivity = true
        UIManager.Show('ControllerWaitTip')

        F_ResourceManager.instance:AddPackage("newbgactivity", function()
            F_ResourceManager.instance:AddPackage("activity", function()
                UIManager.Show('ControllerActivity')
                UIManager.Hide('ControllerWaitTip')
            end)
        end)

    end
end

function ControllerHall:OnHide()
	self.m_view.visible=false
end

--请求进入夺宝奇兵
function ControllerHall:Enter_DBQB()
    sendEnterBaiRen()
end

--请求进入德州牛仔
function ControllerHall:Enter_DZNZ()
    sendEnterNiuZai()
end

-- 加载背景 Spine bg
function ControllerHall:Load_SpineBg()
    --spine大厅背景
    if not self.m_loadSpineBg then
        self.m_loadSpineBg = true
        local _u3dOBJ = UnityEngine.GameObject.Instantiate(UIManager.GetPrefab('puke_obj'))
        local _gw = FairyGUI.GoWrapper(_u3dOBJ)
        self.m_view:GetChild('spineBG').asGraph:SetNativeObject(_gw)
        local designWidth = 1920
        local designHeight = 1080
        local designScale = designWidth/designHeight
        local scaleRate = UnityEngine.Screen.width/UnityEngine.Screen.height
        local scaleFactor = 1
        if scaleRate < designScale then
            scaleFactor = designScale/scaleRate
        else
            scaleFactor = scaleRate/designScale
        end
        _u3dOBJ.transform.localScale = Vector3.New(100 * scaleFactor, 100 * scaleFactor, 100 * scaleFactor)
    end
end

-- 加载龙骨
function ControllerHall:Load_Prefab()
    -- jinbi2OBJ
    -- huodongOBJ
    -- puke_obj
    if not self.m_loadPrefab then
        self.m_loadPrefab = true
        UIManager.SetDragonBonesAniObjPos2('jueseOBJ',self.m_content:GetChild("n61"):GetChild("n5"):GetChild("n6"),Vector3.New(60,60,60))
        UIManager.SetDragonBonesAniObjPos2('quanquanOBJ',self.m_content:GetChild("n61"):GetChild("n5"):GetChild("n7"),Vector3.New(120,120,120))
        UIManager.SetDragonBonesAniObjPos2('shaoguang1OBJ',self.m_content:GetChild("n61"):GetChild("n5"):GetChild("n8"),Vector3.New(100,100,100))
        UIManager.SetDragonBonesAniObjPos2('shaoguang2OBJ',self.m_content:GetChild("n61"):GetChild("n7"):GetChild("n11"),Vector3.New(100,100,100))
        UIManager.SetDragonBonesAniObjPos('caishen2',self.m_content:GetChild("GodTurret"),Vector3.New(70,70,70))
        --UIManager.SetDragonBonesAniObjPos('button_Shop',self.m_content:GetChild("shop"),Vector3.New(100,100,100))
    end
end

----------------------------------- 排行榜 -------------------------------------
function ControllerHall:InitRanking()
    self.m_RankingData = nil
    self.m_RankingList = self.m_content:GetChild("ranking"):GetChild('list').asList
    self.m_RankingList:SetVirtual()
    self.m_RankingList.itemRenderer = function (theIndex,theGObj)
        local _com = theGObj.asCom
        local _data = self.m_RankingData[theIndex + 1]
        _com:GetController('c1').selectedIndex = theIndex >=3 and 3 or theIndex
        _com:GetChild('icon'):GetChild('icon').asLoader.url = GetPlayerHeadUrl(_data.headurl, _data.faceID)
        _com:GetChild('frame').asLoader.url = Bag_Config[_data.vipFaceFrameID].url
        _com:GetChild('txtNickName').text=_data.nickname
        _com:GetChild('txtMoney').text=formatVal(tonumber(_data.gold))
    end
end

function ControllerHall:ShowRanking(data_list)
    if data_list then
        local length = #data_list
        self.m_RankingData = data_list
        self.m_RankingList.numItems = length >= 4 and 4 or length
    else
        coroutine.start(Ranking_Get, {
            userid = loginSucceedInfo.user_info.userid,
            operatetype = 1,
            callbackSuccess = function(info)
                local _array = json.decode(info.array)
                if _array then
                    local length = #_array
                    self.m_RankingData = _array
                    self.m_RankingList.numItems = length >= 4 and 4 or length
                end
            end
        })
    end
end

return ControllerHall