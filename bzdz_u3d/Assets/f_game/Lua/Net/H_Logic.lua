--写一些共用逻辑
--游戏服的信息,从登录获取
loginSucceedInfo=nil

--加载游戏音效
function loadSoundEffects()
    F_ResourceManager.instance:LoadAudioClip("sound_duanyu_ptm.unity3d",nil,function (arr)
        for i=0,arr.Length-1 do
            --print(arr[i].name)
            F_SoundManager.instance:Add(arr[i].name,arr[i])
        end
    end)

    F_ResourceManager.instance:LoadAudioClip("sound_duanyu_ptw.unity3d",nil,function (arr)
        for i=0,arr.Length-1 do
            --print(arr[i].name)
            F_SoundManager.instance:Add(arr[i].name,arr[i])
        end
    end)
end

function setSelfMoney(val)
    loginSucceedInfo.user_info.gold=val
    H_EventDispatcher:dispatchEvent({name='refreshSelfMoney'})
end

function setSelfIntegral(val)
    loginSucceedInfo.user_info.integral=val
    H_EventDispatcher:dispatchEvent({name='refreshSelfIntegral'})
end

function setVIPTime(val)
    loginSucceedInfo.user_info.viptime=val
    H_EventDispatcher:dispatchEvent({name='refreshVIPTime'})
end

function setHuShengTime(val)
    loginSucceedInfo.user_info.hushengEndTime=val
    H_EventDispatcher:dispatchEvent({name='refreshHuShengTime'})
end

function setHeadFrame(val)
    loginSucceedInfo.user_info.vipFaceFrameID = val
    H_EventDispatcher:dispatchEvent({name='refreshHeadFrame'})
end

--定时刷新好友红点
function RefreshTipFriend()
    if loginSucceedInfo and loginSucceedInfo.user_info then
        --print('定时器请求获取追求者列表')
        coroutine.start(Friend_Pursuer,{
            isHideWaitTip=true,
            userid=loginSucceedInfo.user_info.userid,
            callbackSuccess=function (info)
                if info.array then
                    local _arr=json.decode(info.array)
                    H_EventDispatcher:dispatchEvent({name='refreshTipFriend',isMark=#_arr>0})  
                else
                    H_EventDispatcher:dispatchEvent({name='refreshTipFriend',isMark=false})    
                end
            end
        });
    end
end

--定时刷新邮件红点
function RefreshTipMail()
    if loginSucceedInfo and loginSucceedInfo.user_info then
        --print('定时器请求获取邮件列表')
        coroutine.start(Mail_Get,{
            isHideWaitTip=true,
            userid=loginSucceedInfo.user_info.userid,
            callbackSuccess=function (info)
                if info.array then
                    local _arr=json.decode(info.array)
                    for i,v in pairs(_arr) do
                        if v.status==0 then
                            H_EventDispatcher:dispatchEvent({name='refreshTipMail',isMark=true})
                            return
                        end
                    end
                    H_EventDispatcher:dispatchEvent({name='refreshTipMail',isMark=false})  
                else
                    H_EventDispatcher:dispatchEvent({name='refreshTipMail',isMark=false})    
                end
            end
        });
    end
end

--定时器刷新任务
function RefreshTipTask()
    if loginSucceedInfo and loginSucceedInfo.user_info then
        --print('定时器刷新任务红点')
        H_EventDispatcher:dispatchEvent({name='refreshTipTask',isMark=false})

        coroutine.start(TaskDaily_Get,{
            isHideWaitTip=true,
            operatetype=1,
            userid=loginSucceedInfo.user_info.userid,
            callbackSuccess=function (info)
                for i,v in ipairs(info.resultArr) do
                    local _d=json.decode(v.val)
                    if tonumber(_d.status)==1 then
                        H_EventDispatcher:dispatchEvent({name='refreshTipTask',isMark=true}) 
                        return
                    end
                end
            end
        });

        coroutine.start(TaskDaily_Get,{
            isHideWaitTip=true,
            operatetype=2,
            userid = loginSucceedInfo.user_info.userid,
            callbackSuccess=function (info)
                for i,v in ipairs(info.resultArr) do
                    local _d=json.decode(v.val)
                    if tonumber(_d.status)==1 then
                        H_EventDispatcher:dispatchEvent({name='refreshTipTask',isMark=true}) 
                        return
                    end
                end
            end
        });

        coroutine.start(TaskDaily_Get,{
            isHideWaitTip=true,
            operatetype=3,
            userid=loginSucceedInfo.user_info.userid,
            callbackSuccess=function (info)
                for i,v in ipairs(info.resultArr) do
                    local _d=json.decode(v.val)
                    if tonumber(_d.status)==1 then
                        H_EventDispatcher:dispatchEvent({name='refreshTipTask',isMark=true}) 
                        return
                    end
                end
            end
        });
    end
end

function Refresh_Person_Gold()
    if loginSucceedInfo and loginSucceedInfo.user_info then
        coroutine.start(Person_Gold,{
            isHideWaitTip=true,
            userid=loginSucceedInfo.user_info.userid,
            callbackSuccess=function (info)
                local _data=json.decode(info.array)
    
                setSelfMoney(tonumber(_data.gold))
                setSelfIntegral(tonumber(_data.integral))
                --print('查询金币成功'.._data.gold)
                loginSucceedInfo.user_info.gamecount=tonumber(_data.gamecount)
                loginSucceedInfo.user_info.wincounts=tonumber(_data.wincounts)
                loginSucceedInfo.user_info.dropcardcount=tonumber(_data.dropcardcount)
                loginSucceedInfo.user_info.maxcards=_data.maxcards
                loginSucceedInfo.user_info.winmaxgold=_data.winmaxgold
                loginSucceedInfo.user_info.viptime=_data.viptime
            end
        })
    end
end

function Refresh_Token()
    if loginSucceedInfo and loginSucceedInfo.user_info and loginSucceedInfo.token then
        coroutine.start(function ()
            local _www = WWW(string.format(Url_refreshToken, loginSucceedInfo.token, loginSucceedInfo.user_info.userid))
            coroutine.www(_www)
            if _www.error ~= nil then
                UIManager.AddPopTip({strTit=_www.error})
                return 
            end
            --print('_www.text:'.._www.text)
            local _info=json.decode(_www.text)
            loginSucceedInfo.token=_info.data
        end)
    end
end

--错开网络请求
--Timer.New(function ()
--    if UIManager.IsShowState('ControllerHall') then
--        RefreshTipFriend()
--    end
--end,20,-1):Start()

--Timer.New(function ()
--    if UIManager.IsShowState('ControllerHall') then
--        RefreshTipMail()
--    end
--end,22,-1):Start()

--Timer.New(function ()
--    if UIManager.IsShowState('ControllerHall') then
--        RefreshTipTask()
--    end
--end,23,-1):Start()

-- 刷金币
--Timer.New(function ()
--    if UIManager.IsShowState('ControllerHall') or UIManager.IsShowState('ControllerGameHall') then
--        Refresh_Person_Gold()
--    end
--end, 24, -1):Start()

--服务器30分钟过期
Timer.New(function () Refresh_Token() end, 14*60, -1):Start()

--游戏数据

--小盲金币数
--gameData.xmgold

--发消息用的seq
--gameData.seq

--发聊天信息用的玩家的游戏椅子
--gameData.chair

--本轮下的最大注
--gameData.currmaxgold

--打赏荷官费用
--gameData.dasang_fee

--使用互动表情费用
--gameData.emotion_fee

gameData=nil

--游戏内操作延迟
waitOutCard=nil

--点击游戏列表记录房间信息
roomCfg=nil

--玩家游戏中的筹码
gameMoney=nil

-- 房间 1, 德州牛仔 2， 百人 3，
GameSubType = nil
GameType = { RoomHall = 1, DZNZ = 2, BRNN = 3, BISAI = 4 }

--得到 初级/中级/高级 房间列表
_ServerMap =
{
    [1] = {'gold_10',10},
    [2] = {'gold_11',11},
    [3] = {'gold_12',12},
    [4] = {'gold_13',13},
    [5] = {'gold_13',13},--gold_14 14
    [6] = {'gold_14',20},--德州牛仔
    [7] = {'gold_15',21},--百人牛牛
}

_ServerName =
{
    [0] = "离线",
    [10] = "初级场",
    [11] = "中级场",
    [12] = "必下场",
    [13] = "VIP房",
    [14] = "AllIn场",
    [20] = "德州牛仔",
    [21] = "夺宝骑兵"
}

-- 新的错误消息
H_NetMsg:addEventListener('GFGameMsg',function (arg)
    local msg = Protol.GameBaseMsg_pb.GF_GameMsg()
    msg:ParseFromString(arg.pb_data)
    UIManager.AddPopTip({ strTit = msg.msg })
end)

-- 旧的错误消息
H_NetMsg:addEventListener('ErrorMsg',function (arg)
    local msg = Protol.GameBaseMsg_pb.ErrorMsg()
    msg:ParseFromString(arg.pb_data)
    if msg.errmsg==-3 then
        if UIManager.IsShowState('ControllerTexas') then
            UIManager.Hide('ControllerTexas')
        end
    else
        UIManager.AddPopTip({strTit = msg.errmsg})
        UIManager.Hide('ControllerWaitTip')
    end
end)

H_NetMsg:addEventListener('PushErrorMsg',function (arg)
    local msg = Protol.GameBaseMsg_pb.PushErrorMsg()
    msg:ParseFromString(arg.pb_data)
    UIManager.Hide('ControllerTexas')
    UIManager.Show('ControllerLogin')
    UIManager.Show('ControllerMessageBox',{strTit=msg.errmsg})
    --取消心跳
    H_HeartbeatManager.Cancel(GameServerConfig.logic)
end)

--发送桌子验证
var_tableid=nil
var_passwd=nil

--只是为了取房间配置
function sendTablePwdValidate(tableid,passwd)
    local msg = Protol.Poker_pb.TablePwdValidate()
    msg.tableid=tableid
    msg.passwd=passwd
    var_tableid=tableid
    var_passwd=passwd
	local pb_data = msg:SerializeToString()
	NetManager.SendMessage(GameServerConfig.logic,'TablePwdValidate',pb_data)
end

H_NetMsg:addEventListener('TableValidateResponse',function (arg)
    local msg = Protol.Poker_pb.TableValidateResponse()
    msg:ParseFromString(arg.pb_data)
    if msg.validateno==100 then
        sendEnterGameRequst(var_tableid,var_passwd)
        roomCfg=msg.tableconfig
    else
        UIManager.Hide('ControllerWaitTip')
        UIManager.AddPopTip({strTit='房间号或者密码错误'})
    end
end)

function sendEnterGameRequst(tableid,table_pwd)
    -- print('joker -> sendEnterGameRequst')
    var_tableid = tableid
    var_passwd = table_pwd
    --同步给其他玩家的信息
    local _info={}
    _info.userid=loginSucceedInfo.user_info.userid
    _info.gold=loginSucceedInfo.user_info.gold
    _info.nickname=loginSucceedInfo.user_info.nickname
    _info.headurl=loginSucceedInfo.user_info.headurl
    _info.level=loginSucceedInfo.user_info.level
    _info.sex=loginSucceedInfo.user_info.sex
    _info.location=loginSucceedInfo.user_info.location
    _info.gamecount=loginSucceedInfo.user_info.gamecount or 0
    _info.wincounts=loginSucceedInfo.user_info.wincounts or 0
    _info.dropcardcount=loginSucceedInfo.user_info.dropcardcount or 0
    _info.winmaxgold=loginSucceedInfo.user_info.winmaxgold or 0

	--请求进入
	local msg = Protol.GameBaseMsg_pb.EnterGameRequst()
	msg.info=json.encode(_info)
    msg.tableid=tableid
    msg.table_pwd=table_pwd
	msg.userid=loginSucceedInfo.user_info.userid
	local pb_data = msg:SerializeToString()

	NetManager.SendMessage(GameServerConfig.logic,'EnterGameRequst',pb_data)
end

-- 进入牛仔
function sendEnterNiuZai()
    GameSubType = GameType.DZNZ
    local t=lua_string_split(loginSucceedInfo.server_info['gold_20'],'#')
    local _gs=t[1]
    local _ip=t[2]
    local _port=t[3]
    local _send_To=t[4]
    local _send_Mcmd=t[5]

    GameServerConfig.ipArr=_ip..':'.._port
    GameServerConfig.send_To=_send_To
    GameServerConfig.send_Mcmd=_send_Mcmd
    GameServerConfig.serverid=_ServerMap[6][2]

    UIManager.Show('ControllerWaitTip')

    F_ResourceManager.instance:AddPackage("newgamedznz",function ()
        F_ResourceManager.instance:AddPackage("niuzai",function ()
            UIManager.Hide('ControllerWaitTip')
            UIManager.InitController('ControllerDZNZ_Main')
            UIManager.Show("ControllerWaitTip",{strTit='',timeOut=5})
            NetManager.ConnectServer(GameServerConfig,function ()
                UIManager.Hide('ControllerWaitTip')
                UIManager.AddPopTip({strTit='连接服务器失败,请重试.'})
            end,function ()
                UIManager.Hide('ControllerWaitTip')
                H_HeartbeatManager.Restart(GameServerConfig.logic)
                sendEnterGameRequst(917505,0)
            end)
        end)
    end)

end

-- 进入百人场
function sendEnterBaiRen()
    GameSubType = GameType.BRNN
    local t=lua_string_split(loginSucceedInfo.server_info['gold_21'],'#')
    local _gs=t[1]
    local _ip=t[2]
    local _port=t[3]
    local _send_To=t[4]
    local _send_Mcmd=t[5]

    GameServerConfig.ipArr=_ip..':'.._port
    GameServerConfig.send_To=_send_To
    GameServerConfig.send_Mcmd=_send_Mcmd
    GameServerConfig.serverid=_ServerMap[6][2]

    UIManager.Show('ControllerWaitTip')

    F_ResourceManager.instance:AddPackage("newgamebairen", function ()
        F_ResourceManager.instance:AddPackage("bairen",function ()
            UIManager.Hide('ControllerWaitTip')
            UIManager.InitController('ControllerBaiRen')
            UIManager.Show("ControllerWaitTip",{strTit='',timeOut=5})
            NetManager.ConnectServer(GameServerConfig,function ()
                UIManager.Hide('ControllerWaitTip')
                UIManager.AddPopTip({strTit='连接服务器失败,请重试.'})
            end,function ()
                UIManager.Hide('ControllerWaitTip')
                --开启心跳
                H_HeartbeatManager.Restart(GameServerConfig.logic)
                sendEnterGameRequst(917505,0)
            end)
        end)
    end)
end

-- 进入比赛场
function sendEnterGameCompetition(tableid, table_pwd)
    -- print('joker -> sendEnterGameRequst')
    var_tableid = tableid
    var_passwd = table_pwd
    --同步给其他玩家的信息
    local _info = {}
    _info.userid = loginSucceedInfo.user_info.userid
    _info.gold = loginSucceedInfo.user_info.gold
    _info.nickname = loginSucceedInfo.user_info.nickname
    _info.headurl = loginSucceedInfo.user_info.headurl
    _info.level = loginSucceedInfo.user_info.level
    _info.sex = loginSucceedInfo.user_info.sex
    _info.location = loginSucceedInfo.user_info.location
    _info.gamecount = loginSucceedInfo.user_info.gamecount or 0
    _info.wincounts = loginSucceedInfo.user_info.wincounts or 0
    _info.dropcardcount = loginSucceedInfo.user_info.dropcardcount or 0
    _info.winmaxgold = loginSucceedInfo.user_info.winmaxgold or 0

    --请求进入
    local msg = Protol.DzMatchPb_pb.C_Login()
    msg.info = json.encode(_info)
    msg.matchid = roomCfg.matchID
    msg.userid = loginSucceedInfo.user_info.userid
    local pb_data = msg:SerializeToString()

    NetManager.SendNetMsg(GameServerConfig.logic,'Match_EnterGame', pb_data)
end
