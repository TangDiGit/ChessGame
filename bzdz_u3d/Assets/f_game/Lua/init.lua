json = require "cjson"
local _EventDispatcher = require "EventDispatcher"
H_EventDispatcher = _EventDispatcher()
require("FairyGUI")
require("func")
require("Net/init")
require("H_ComPoolManager")
require("H_EffManager")
require("poker")
require("Controller/UI_Define")
require("Controller/UIManager")
require("H_GetName")

WWW = UnityEngine.WWW
PlayerPrefs = UnityEngine.PlayerPrefs
--来自客户端刚启动时
ServerInfo = json.decode(F_AppConst.jsonServerInfo)

--xInstall唤醒信息
local awakeInfo = F_AppConst.xInstallAwakeInfo
XInstallAwakeInfo = (awakeInfo and string.len(awakeInfo) > 0) and json.decode(awakeInfo) or nil

--xInstall安装信息
local installInfo = F_AppConst.xInstallInstallInfo
XInstallInstallInfo = (installInfo and string.len(installInfo) > 0) and json.decode(installInfo) or nil

-- 1.自己的头像
function GetPlySelfHeadUrl()
    --local face_id = tonumber(loginSucceedInfo.user_info.faceID)
    --if face_id and face_id > 0 then
    --    return HandleFaceIcon(face_id)
    --end
    
    if loginSucceedInfo.user_info.headurl then
        return HandleWXIcon(loginSucceedInfo.user_info.headurl)
    end
end

-- 2.玩家的头像
function GetPlayerHeadUrl(wxurl, face_id)
    --if face_id then
    --    face_id = tonumber(face_id)
    --    if face_id > 0 then
    --        return HandleFaceIcon(face_id)
    --    end
    --    return HandleWXIcon(wxurl)
    --end
    return HandleWXIcon(wxurl)
end

-- 微信头像
function HandleWXIcon(wxurl)
    if wxurl == nil then
        return DefaultIcon
    end

    if utf8.len(wxurl) <= 0 then
        return DefaultIcon
    end

    return wxurl
end

-- 更换后的头像
function HandleFaceIcon(face_id)
    local face_cfg = HeadIconConfig[face_id]
    if face_cfg then
        return face_cfg.url
    end
    return DefaultIcon
end

--获取二维码
Url_QRCode='https://cli.im/api/qrcode/code?text='
function getQRCode(arg)
    local _www = WWW(Url_QRCode..arg.text)
    coroutine.www(_www)
    if _www.error ~= nil then
        UIManager.AddPopTip({ strTit = _www.error })
        return 
    end

    local _s1=string.match(_www.text, 'var qrcode_plugins_img =.*</head>')
    --print(_s1)
    local _s2=string.match(_s1,'".*"')
    --print(_s2)
    local _s3=string.sub(_s2,2,utf8.len(_s2)-1)
    --print(_s3) 
    local _s4='http:'.._s3
    --print(_s4) 
    if arg.callbackSuccess then
        arg.callbackSuccess(_s4)
    end
end

--获取本地ip地址
Url_ipinfo='http://ip.taobao.com/service/getIpInfo2.php'
function getIPInfo(arg)
    local _form =UnityEngine.WWWForm()
    _form:AddField("ip", 'myip')
    local _www = WWW(Url_ipinfo,_form)
    coroutine.www(_www)
    if _www.error ~= nil then
        UIManager.AddPopTip({strTit = _www.error })
        --print('请求ip查询错误,定时器再次请求')
        --Timer.New(function ()
        --    UpdateLocation()
        --end,10,1):Start()
        return 
    end
    --print(_www.text)
    local _info=json.decode(_www.text)
    if _info.code==0 then
        --根据ip保存地区
        if arg.callbackSuccess then
            arg.callbackSuccess(_info.data)
        end
    end
end

function UpdateLocation()
    --coroutine.start(getIPInfo,{
    --    callbackSuccess=function (info)
    --        if loginSucceedInfo and loginSucceedInfo.user_info then
    --            coroutine.start(Person_Update,{
    --                isHideWaitTip=true,
    --                userid=loginSucceedInfo.user_info.userid,
    --                nickname='',
    --                sex='',
    --                location=json.encode({region=info.region,city=info.city}),
    --                note='',
    --                callbackSuccess=function (data)
    --                    if utf8.len(loginSucceedInfo.user_info.location)<=0 then
    --                        loginSucceedInfo.user_info.location=json.encode({region=info.region,city=info.city})
    --                    end
    --                end
    --            })
    --        end
    --    end
    --})
end

--[[
{"code":0,"data":{"ip":"113.110.234.30","country":"中国","area":"","region":"广东",
"city":"深圳","county":"XX","isp":"电信","country_id":"CN","area_id":"","region_id":"440000",
"city_id":"440300","county_id":"xx","isp_id":"100017"}}
]]

--获取

--旧版本
--M_HttpStr = ServerInfo.testIpArr and ServerInfo.testIpArr or 'bzpoker.cn:80'

--新服务器版本
M_HttpStr = ServerInfo.gameJsonIpAddress

Url_registerGameUser='http://'..M_HttpStr..'/game/InterfaceApi/registerGameUser'

Url_gameHallMainInterface='http://'..M_HttpStr..'/game/InterfaceApi/gameHallMainInterface'
Url_gameHallInterface='http://'..M_HttpStr..'/game/InterfaceApi/gameHallInterface'

Url_laBa='http://'..M_HttpStr..'/api/Horn/receive?message=%s&user_id=%s&token=%s'
--绑定下属
Url_Personal_bingUser='http://'..M_HttpStr..'/api/TradeGroup/bingUser?userid=%s&sonid=%s&token=%s'
--商圈 extensionSystem
Url_extensionSystem_getQRUrl='http://'..M_HttpStr..'/api/WxLogin/web_login?user_id=%s&token=%s'

Url_extensionSystem_index='http://'..M_HttpStr..'/api/TradeGroup/index?user_id=%s&token=%s'
--新增成员
Url_extensionSystem_newUser='http://'..M_HttpStr..'/api/TradeGroup/newUser?user_id=%s&son_id=%s&token=%s'
Url_extensionSystem_newUser2='http://'..M_HttpStr..'/api/TradeGroup/newUser?user_id=%s&token=%s'
--直属收入
Url_extensionSystem_directIncome='http://'..M_HttpStr..'/api/TradeGroup/directIncome?user_id=%s&token=%s'
--团队收入
Url_extensionSystem_groupIncome='http://'..M_HttpStr..'/api/TradeGroup/groupIncome?user_id=%s&token=%s'
--领取记录
Url_extensionSystem_receive='http://'..M_HttpStr..'/api/TradeGroup/receive?user_id=%s&token=%s'
--领取 直属收入/团队收入
Url_extensionSystem_getCoin='http://'..M_HttpStr..'/api/TradeGroup/submitReceive?user_id=%s&type=%s&token=%s'
--收入记录
Url_extensionSystem_everyDayIncome='http://'..M_HttpStr..'/api/TradeGroup/everyDayIncome?user_id=%s&token=%s'

--刷新token
Url_refreshToken='http://'..M_HttpStr..'/api/Token/RefreshToken?token=%s&userid=%s'

--注册账号
function reg(arg)
    local _form =UnityEngine.WWWForm()
    _form:AddField("userinfo", arg.userinfo)
    _form:AddField("curTime", os.time())
    _form:AddField("apitoken", getApitoken('game','InterfaceApi','registerGameUser'))
    local _www = WWW(Url_registerGameUser,_form)
    coroutine.www(_www)
    if _www.error ~= nil then
        UIManager.AddPopTip({strTit = _www.error})
        return 
    end
    --print(_www.text)
    local _info=json.decode(_www.text)
    --print(F_Util.Unescape(_info.content))

    if tonumber(_info.code)==100101 then
        UIManager.AddPopTip({strTit="注册成功"})
        if arg.callbackSuccess then
            arg.callbackSuccess()
        end
    else
        UIManager.AddPopTip({strTit=string.format( "%s(%s)",_info.content,_info.code)})
    end
end

--账号登入
function login_logic(arg)
    local _form = UnityEngine.WWWForm()
    _form:AddField("param", json.encode(arg.param))
    _form:AddField("curTime", os.time())
    _form:AddField("apitoken", getApitoken('game','InterfaceApi','gameHallMainInterface'))

    local _www = WWW(Url_gameHallMainInterface, _form)
    coroutine.www(_www)
    if _www.error ~= nil then
        UIManager.AddPopTip({ strTit = _www.error })
        return
    end

    local _info = json.decode(_www.text)
    if _info then
        if tonumber(_info.code) == 100107 then
            if arg.callbackSuccess then
                arg.callbackSuccess(_info)
            end
        else
            UIManager.AddPopTip({strTit=string.format( "%s(%s)", _info.content, _info.code)})
        end
    end
end

function login_send(arg)
    coroutine.start(login_logic,{
        param={
            operatetype='10',
            param =
            {
                phone = arg.phone,
                password = arg.password,
                device_name = UnityEngine.SystemInfo.deviceModel,
            }
        },
        callbackSuccess=function (info)
            loginSucceedInfo = info
            PlayerPrefs.SetString("phoneNumber", arg.phone)
            PlayerPrefs.SetString("pw",arg.password)
            PlayerPrefs.Save()
            UIManager.Show('ControllerHall')
            UpdateLocation()
            loginSucceedInfo.user_info.spreadId = loginSucceedInfo.user_info.proxyid == 1 and loginSucceedInfo.user_info.userid or 0
        end
    })
end

function login_sendWX(arg)
    -- xInstall的上级id获取
    local spreadId = 0

    if XInstallInstallInfo and XInstallInstallInfo.data and XInstallInstallInfo.data.uo then
        local res
        local type_uo = type(XInstallInstallInfo.data.uo)
        if type_uo == "string"  then
            res = json.decode(XInstallInstallInfo.data.uo)
        elseif type_uo == "table" then
            res = XInstallInstallInfo.data.uo
        end

        if res then
            spreadId = tonumber(res.spreadId)
        else
            spreadId = 0
        end
    end

    coroutine.start(login_logic,{
        param =
        {
            operatetype='20',
            param =
            {
                unionid = arg.unionid,
                nickname = arg.nickname,
                sex = tostring(arg.sex),
                headurl = arg.headurl,
                location = '',
                spreadId = spreadId,
                device_name = UnityEngine.SystemInfo.deviceModel,
            }
        },
        callbackSuccess = function (info)
            loginSucceedInfo = info
            PlayerPrefs.SetString("phoneNumber",'')
            PlayerPrefs.SetString("pw",'')
            PlayerPrefs.Save()
            UIManager.Show('ControllerHall')
            UpdateLocation()

            -- 代理判断
            if loginSucceedInfo.user_info.proxyid == 1 then
                spreadId = loginSucceedInfo.user_info.userid
            end

            loginSucceedInfo.user_info.spreadId = spreadId

            SetWXLoginPara(arg)
        end
    })
end

function _Hall_Common(arg)
    if not arg.isHideWaitTip then
        UIManager.Show('ControllerWaitTip')
    end
    local _form = UnityEngine.WWWForm()
    _form:AddField("token", loginSucceedInfo.token)
    _form:AddField("busflag", arg.busflag)
    _form:AddField("curTime", os.time())
    _form:AddField("apitoken", getApitoken('game','InterfaceApi','gameHallInterface'))
    _form:AddField("param", json.encode(arg.info))

    local _www = WWW(Url_gameHallInterface, _form)

    coroutine.www(_www)

    if _www.error ~= nil then
        UIManager.Hide('ControllerWaitTip')
        UIManager.AddPopTip({strTit = _www.error })
        return 
    end

    local _info = json.decode(_www.text)

    UIManager.Hide('ControllerWaitTip')
    if tonumber(_info.code) == arg.succeedCode then
        if arg.callbackSuccess then
            arg.callbackSuccess(_info)
        end
    else
        if arg.callbackFailure then
            arg.callbackFailure(_info)
        end
        UIManager.AddPopTip({strTit=string.format( "%s(%s)", _info.content, _info.code)})
    end
end

--保险箱
local _safebox_apitoken = nil
function _SafeBox_GetApitoken2(operatetype)
    return F_Util.EncryptString('101'..(_safebox_apitoken or '')..operatetype)
end

function _SafeBox_Deposit_Common(arg)
    arg.busflag='101'
    _Hall_Common(arg)
end

--保险箱登录
function SafeBox_Deposit_Login(arg)
    _safebox_apitoken=nil
    local _info={
        operatetype='4',
        param={
            userid=tostring(arg.userid),
            pwd=tostring(arg.pwd),
        }
    }
    _SafeBox_Deposit_Common({
        info=_info,
        succeedCode=100305,
        callbackSuccess=function (info)
            _safebox_apitoken=info.apitoken
            if arg.callbackSuccess then
                arg.callbackSuccess(info)
            end
        end
    })
end

--存款查询/保险箱金币查询
function SafeBox_Deposit_Check(arg)
    local _info={
        operatetype='1',
        param={
            userid=tostring(arg.userid),
            apitoken=_SafeBox_GetApitoken2('1')
        }
    }
    _SafeBox_Deposit_Common({
        info=_info,
        succeedCode=100302,
        callbackSuccess=arg.callbackSuccess
    })
end

--存钱
function SafeBox_Deposit_Push(arg)
    local _info={
        operatetype='2',
        param={
            userid=tostring(arg.userid),
            gold=tostring(arg.gold),
            apitoken=_SafeBox_GetApitoken2('2')
        }
    }
    _SafeBox_Deposit_Common({
        info=_info,
        succeedCode=100311,
        callbackSuccess=arg.callbackSuccess
    })
end

--取钱
function SafeBox_Deposit_Pull(arg)
    local _info={
        operatetype='3',
        param={
            userid=tostring(arg.userid),
            gold=tostring(arg.gold),
            apitoken=_SafeBox_GetApitoken2('3')
        }
    }
    _SafeBox_Deposit_Common({
        info=_info,
        succeedCode=100308,
        callbackSuccess=arg.callbackSuccess
    })
end

--转账
function SafeBox_Deposit_Transfer(arg)
    local _info={
        operatetype='5',
        param={
            sUserid=tostring(arg.sUserid),
            dUserid=tostring(arg.dUserid),
            gold=tostring(arg.gold),
            apitoken=_SafeBox_GetApitoken2('5')
        }
    }
    _SafeBox_Deposit_Common({
        info=_info,
        succeedCode=100343,
        callbackSuccess=arg.callbackSuccess
    })
end

--转账记录（转入）
function SafeBox_Deposit_Log_In(arg)
    local _info={
        operatetype='6',
        param={
            userid=tostring(arg.userid),
            indexStart=tostring(arg.indexStart),
            indexEnd=tostring(arg.indexEnd),
            operate = 2,
            apitoken=_SafeBox_GetApitoken2('6')
        }
    }
    _SafeBox_Deposit_Common({
        info=_info,
        succeedCode=100332,
        callbackSuccess=arg.callbackSuccess
    })
end

--转账记录（转出）
function SafeBox_Deposit_Log_Out(arg)
    local _info={
        operatetype='6',
        param={
            userid=tostring(arg.userid),
            indexStart=tostring(arg.indexStart),
            indexEnd=tostring(arg.indexEnd),
            operate = 1,
            apitoken=_SafeBox_GetApitoken2('6')
        }
    }
    _SafeBox_Deposit_Common({
        info=_info,
        succeedCode=100332,
        callbackSuccess=arg.callbackSuccess
    })
end


--好友
function _Friend_Common(arg)
    arg.busflag='102'
    _Hall_Common(arg)
end

--查找好友
function Friend_Find(arg)
    local _info={
        operatetype='1',
        param={
            userid=tostring(arg.userid)
        }
    }
    _Friend_Common({
        info=_info,
        succeedCode=100406,
        callbackSuccess=arg.callbackSuccess,
        callbackFailure=arg.callbackFailure,
    })
end

--添加好友
function Friend_Add(arg)
    local _info={
        operatetype='4',
        param={
            fromuserid=tostring(arg.fromuserid),
            touserid=tostring(arg.touserid)
        }
    }
    _Friend_Common({
        info=_info,
        succeedCode=100431,
        callbackSuccess=arg.callbackSuccess
    })
end

--追求者列表
function Friend_Pursuer(arg)
    local _info={
        operatetype='5',
        param={
            userid=tostring(arg.userid)
        }
    }
    _Friend_Common({
        info=_info,
        succeedCode=100441,
        callbackSuccess=arg.callbackSuccess,
        isHideWaitTip=arg.isHideWaitTip
    })
end
--对追求者进行 添加/拒绝/屏蔽
--0  =>  请求, 1  =>  同意, 2  =>  忽略, 3  =>  拒绝
function Friend_Pursuer_OP(arg)
    local _info={
        operatetype='6',
        param={
            fromuserid=tostring(arg.fromuserid),
            touserid=tostring(arg.touserid),
            type=tostring(arg.type),
        }
    }
    _Friend_Common({
        info=_info,
        succeedCode=100451,
        callbackSuccess=arg.callbackSuccess
    })
end

--查看好友列表
function Friend_List(arg)
    local _info={
        operatetype='3',
        param={
            userid=tostring(arg.userid),
        }
    }
    _Friend_Common({
        info=_info,
        succeedCode=100421,
        callbackSuccess=arg.callbackSuccess
    })
end

-- 聊天里的好友列表
function ChatFriend_List(arg)
    local _info={
        operatetype='3',
        param={
            userid=tostring(arg.userid),
        }
    }
    _Friend_Common({
        info=_info,
        succeedCode=100421,
        callbackSuccess=arg.callbackSuccess
    })
end

--好友赠送礼物
function Friend_Gift(arg)
    local _info={
        operatetype='2',
        param={
            fromuserid=tostring(arg.fromuserid),
            touserid=tostring(arg.touserid),
            gifttype=tostring(arg.gifttype),
            number=tostring(arg.number),
        }
    }
    _Friend_Common({
        info=_info,
        succeedCode=100412,
        callbackSuccess=arg.callbackSuccess
    })
end


--转盘
function _Lucky_Common(arg)
    arg.busflag='103'
    _Hall_Common(arg)
end
--请求转盘
function Lucky_GoGoGo(arg)
    local _info={
        operatetype='1',
        param={
            userid=tostring(arg.userid),
        }
    }
    _Lucky_Common({
        info=_info,
        succeedCode=100503,
        callbackSuccess=arg.callbackSuccess
    })
end
--查询转盘剩余次数
function Lucky_Residue(arg)
    local _info={
        operatetype='2',
        param={
            userid=tostring(arg.userid),
        }
    }
    _Lucky_Common({
        info=_info,
        succeedCode=100503,
        callbackSuccess=arg.callbackSuccess
    })
end
--查询转盘记录
function Lucky_Log(arg)
    local _info={
        operatetype='3',
        param={
            userid=tostring(arg.userid),
        }
    }
    _Lucky_Common({
        info=_info,
        succeedCode=100503,
        callbackSuccess=arg.callbackSuccess
    })
end

--请求公告
function _Notice_Common(arg)
    arg.busflag='104'
    _Hall_Common(arg)
end
--获取公告信息
function Notice_Get(arg)
    local _info={
        operatetype='1',
        param={
            userid=tostring(arg.userid),
        }
    }
    _Notice_Common({
        info=_info,
        succeedCode=100552,
        callbackSuccess=arg.callbackSuccess
    })
end

--背包
function _Bag_Common(arg)
    arg.busflag='105'
    _Hall_Common(arg)
end
--获取背包信息
function Bag_Get(arg)
    local _info={
        operatetype='1',
        param={
            userid=tostring(arg.userid),
        }
    }
    _Bag_Common({
        info=_info,
        succeedCode=100601,
        callbackSuccess=arg.callbackSuccess
    })
end

--排行榜
function _Ranking_Common(arg)
    arg.busflag='106'
    _Hall_Common(arg)
end
function Ranking_Get(arg)
    local _info={
        operatetype = arg.operatetype,
        param={
            userid=tostring(arg.userid),
        }
    }
    _Ranking_Common({
        info=_info,
        succeedCode=100651,
        callbackSuccess=arg.callbackSuccess
    })
end

--邮件
function _Mail_Common(arg)
    arg.busflag='107'
    _Hall_Common(arg) 
end
--获取邮件列表
function Mail_Get(arg)
    local _info={
        operatetype='1',
        param={
            userid=tostring(arg.userid),
        }
    }
    _Mail_Common({
        info=_info,
        succeedCode=100671,
        callbackSuccess=arg.callbackSuccess,
        isHideWaitTip=arg.isHideWaitTip
    })
end

--将邮件设置已读
function Mail_Read(arg)
    local _info={
        operatetype='2',
        param={
            userid=tostring(arg.userid),
            emailid_list=arg.emailid_list,
        }
    }
    _Mail_Common({
        info=_info,
        succeedCode=100671,
        callbackSuccess=arg.callbackSuccess,
    })
end

--将邮件删除
function Mail_Del(arg)
    local _info={
        operatetype='3',
        param={
            userid=tostring(arg.userid),
            emailid_list=arg.emailid_list
        }
    }
    _Mail_Common({
        info=_info,
        succeedCode=100671,
        callbackSuccess=arg.callbackSuccess,
    })
end

--个人信息
function _Person_Common(arg)
    arg.busflag = '109'
    _Hall_Common(arg) 
end

-- 更新 faceID
function Person_Update_FaceId(arg)
    local _info = {
        operatetype = '4',
        param = {
            faceID = arg.faceID,
            userid = tostring(arg.userid),
        }
    }
    _Person_Common({
        info = _info,
        succeedCode = 100691,
        callbackSuccess = arg.callbackSuccess,
        isHideWaitTip = arg.isHideWaitTip
    })
end

--更新个人信息
function Person_Update(arg)
    local _info = {
        operatetype = '2',
        param = {
            userid = tostring(arg.userid),
            nickname = arg.nickname,
            sex = tostring(arg.sex),
            location = arg.location,
            note = arg.note
        }
    }
    _Person_Common({
        info = _info,
        succeedCode = 100691,
        callbackSuccess = arg.callbackSuccess,
        isHideWaitTip = arg.isHideWaitTip
    })
end

--查询金币
function Person_Gold(arg)
    local _info={
        operatetype='1',
        param={
            userid=tostring(arg.userid),
        }
    }
    _Person_Common({
        info=_info,
        succeedCode=100691,
        callbackSuccess=arg.callbackSuccess,
        isHideWaitTip=arg.isHideWaitTip
    })
end

--积分商城
function _Shop_Common(arg)
    arg.busflag='108'
    _Hall_Common(arg) 
end
--积分商城兑换记录
function Shop_Log(arg)
    local _info={
        operatetype='4',
        param={
            userid=tostring(arg.userid)
        }
    }
    _Shop_Common({
        info=_info,
        succeedCode=100701,
        callbackSuccess=arg.callbackSuccess,
    })
end
--积分商城获取商品
function Shop_Get(arg)
    local _info={
        operatetype='1',
        param={
            userid=tostring(arg.userid)
        }
    }
    _Shop_Common({
        info=_info,
        succeedCode=100701,
        callbackSuccess=arg.callbackSuccess,
        isHideWaitTip=arg.isHideWaitTip
    })
end
--积分商城购买商品
function Shop_GOGOGO(arg)
    local _info={
        operatetype='2',
        param={
            userid=tostring(arg.userid),
            goodsid=tostring(arg.goodsid),
            number=tostring(arg.number),
        }
    }
    
    _Shop_Common({
        info=_info,
        succeedCode=100701,
        callbackSuccess=arg.callbackSuccess,
        isHideWaitTip=arg.isHideWaitTip
    })
end

--手机验证码
function _Phone_Common(arg)
    arg.busflag='110'
    _Hall_Common(arg) 
end
--手机获取验证码
function Phone_GetCode(arg)
    --[[local _info={
        operatetype='1',
        param={
            phone=tostring(arg.phone)
        }
    }
    _Phone_Common({
        info=_info,
        succeedCode=100751,
        callbackSuccess=arg.callbackSuccess,
    })]]

    local _info={
        operatetype='40',
        param={
            param={
                phone=tostring(arg.phone),
            },
            operatetype='1',
        }
    }
    local _form =UnityEngine.WWWForm()
    _form:AddField("param", json.encode(_info))
    _form:AddField("busflag",'40')
    _form:AddField("curTime", os.time())
    _form:AddField("apitoken", getApitoken('game','InterfaceApi','gameHallMainInterface'))
    
    local _www = WWW(Url_gameHallMainInterface,_form)
    coroutine.www(_www)
    if _www.error ~= nil then
        UIManager.AddPopTip({strTit = _www.error })
        return 
    end

    local info=json.decode(_www.text)
    if tonumber(info.code)==100751 then
        if arg.callbackSuccess then
            arg.callbackSuccess(info)
        end
    else
        UIManager.AddPopTip({strTit=string.format( "%s(%s)", info.content, info.code)})
    end
end
--绑定手机
function Phone_Bind(arg)
    --[[local _info={
        operatetype='2',
        param={
            phone=tostring(arg.phone),
            userid=tostring(arg.userid),
            smscode=tostring(arg.smscode)
        }
    }
    _Phone_Common({
        info=_info,
        succeedCode=100131,
        callbackSuccess=arg.callbackSuccess,
    })]]

    local _info={
        operatetype='40',
        param={
            param={
                phone=tostring(arg.phone),
                userid=tostring(arg.userid),
                smscode=tostring(arg.smscode)
            },
            operatetype='2',
        }
    }
    local _form =UnityEngine.WWWForm()
    _form:AddField("param", json.encode(_info))
    _form:AddField("busflag",'40')
    _form:AddField("curTime", os.time())
    _form:AddField("apitoken", getApitoken('game','InterfaceApi','gameHallMainInterface'))
    
    local _www = WWW(Url_gameHallMainInterface,_form)
    coroutine.www(_www)
    if _www.error ~= nil then
        UIManager.AddPopTip({ strTit = _www.error })
        return 
    end

    local info=json.decode(_www.text)
    if tonumber(info.code)==100131 then
        if arg.callbackSuccess then
            arg.callbackSuccess(info)
        end
    else
        UIManager.AddPopTip({strTit=string.format( "%s(%s)", info.content, info.code)})
    end
end

--游戏中奖池
function _Jackpot_Common(arg)
    arg.busflag='111'
    _Hall_Common(arg) 
end
--获取奖池金额
function Jackpot_GetCount(arg)
    local _info={
        operatetype='3',
        param={
            serverid=tostring(arg.serverid),
            userid=tostring(arg.userid),
            xiaoMan=tostring(arg.xiaoMan),
            qianzhu=tostring(arg.qianzhu),
        }
    }
    _Jackpot_Common({
        info=_info,
        succeedCode=100781,
        callbackSuccess=arg.callbackSuccess,
    })
end
--中奖记录
function Jackpot_LuckyRecord(arg)
    local _info={
        operatetype='1',
        param={
            userid=tostring(arg.userid),
        }
    }
    _Jackpot_Common({
        info=_info,
        succeedCode=100781,
        callbackSuccess=arg.callbackSuccess,
    })
end
--中奖记录 自己的信息
function Jackpot_LuckyRecordFromMe(arg)
    local _info={
        operatetype='2',
        param={
            userid=tostring(arg.userid),
        }
    }
    _Jackpot_Common({
        info=_info,
        succeedCode=100781,
        callbackSuccess=arg.callbackSuccess,
    })
end
--中奖统计
function Jackpot_Statistical(arg)
    local _info={
        operatetype='4',
        param={
            userid=tostring(arg.userid),
        }
    }
    _Jackpot_Common({
        info=_info,
        succeedCode=100781,
        callbackSuccess=arg.callbackSuccess,
    })
end

--游戏任务
function _GameTask_Common(arg)
    arg.busflag='114'
    _Hall_Common(arg) 
end
--每日/破产/成就 任务
function TaskDaily_Get(arg)
    local _info={
        operatetype=arg.operatetype,
        param={
            userid=tostring(arg.userid),
        }
    }
    _GameTask_Common({
        info=_info,
        succeedCode=100841,
        callbackSuccess=arg.callbackSuccess,
        isHideWaitTip=arg.isHideWaitTip,
    })
end

--活动七星彩
function _GameActivity_Common(arg)
    arg.busflag = '119'
    _Hall_Common(arg)
end

--活动七星彩信息
function GameActivity_Info(arg)
    local _info = {
        operatetype = 1,
        param = {
            userid = tostring(arg.userid),
        }
    }
    _GameActivity_Common({
        info = _info,
        succeedCode = 100881,
        callbackSuccess = arg.callbackSuccess,
        isHideWaitTip = arg.isHideWaitTip,
    })
end

--活动七星彩选号
function GameActivity_SltNum(arg)
    local _info =
    {
        operatetype = 2,
        param =
        {
            selNum = arg.selNum,
            userid = tostring(arg.userid),
        }
    }
    _GameActivity_Common({
        info = _info,
        succeedCode = 100881,
        callbackSuccess = arg.callbackSuccess,
        isHideWaitTip = arg.isHideWaitTip,
    })
end

--提交任务
function TaskComplete(arg)
    local _info={
        operatetype=4,
        param={
            userid=tostring(arg.userid),
            raskid=tostring(arg.raskid),
        }
    }
    _GameTask_Common({
        info=_info,
        succeedCode=100841,
        callbackSuccess=arg.callbackSuccess,
    })
end

--兑换码
function _CDKEY_Common(arg)
    arg.busflag='113'
    _Hall_Common(arg) 
end
function CDKEY_Use(arg)
    local _info={
        operatetype=2,
        param={
            userid=tostring(arg.userid),
            exchangecode=tostring(arg.exchangecode),
        }
    }
    _CDKEY_Common({
        info=_info,
        succeedCode=100801,
        callbackSuccess=arg.callbackSuccess,
    })
end

--使用vip
function _Prop_Common(arg)
    arg.busflag='112'
    _Hall_Common(arg) 
end
function Prop_Use(arg)
    local _info={
        operatetype=2,
        param={
            userid=tostring(arg.userid),
            type=tostring(arg.type),
        }
    }
    _Prop_Common({
        info=_info,
        succeedCode=100821,
        callbackSuccess=arg.callbackSuccess,
    })
end

--登录忘记密码

function Login_ForgotPasswd(arg)
    local info={
        operatetype=30,
        param={
            phone=tostring(arg.phone),
            smscode=tostring(arg.smscode),
            newpwd=tostring(arg.newpwd),
        }
    }
    local _form = UnityEngine.WWWForm()
    _form:AddField("param", json.encode(info))
    _form:AddField("busflag",'30')
    _form:AddField("curTime", os.time())
    _form:AddField("apitoken", getApitoken('game','InterfaceApi','gameHallMainInterface'))
    local _www = WWW(Url_gameHallMainInterface,_form)
    coroutine.www(_www)
    if _www.error ~= nil then
        UIManager.AddPopTip({ strTit = _www.error })
        return 
    end

    local _info=json.decode(_www.text)

    if tonumber(_info.code)==100134 then
       
        if arg.callbackSuccess then
            arg.callbackSuccess(_info)
        end
    else
        UIManager.AddPopTip({strTit=string.format( "%s(%s)",_info.content,_info.code)})
    end
end


--保险箱忘记密码
function _SafeBox_ForgotPasswd_Common(arg)
    arg.busflag='101'
    _Hall_Common(arg) 
end
--使用手机验证码修改密码
function SafeBox_ForgotPasswd(arg)
    local _info={
        operatetype=7,
        param={
            phone=tostring(arg.phone),
            smscode=tostring(arg.smscode),
            newpwd=tostring(arg.newpwd),
            apitoken=_SafeBox_GetApitoken2('7')
        }
    }
    _SafeBox_ForgotPasswd_Common({
        info=_info,
        succeedCode=100134,
        callbackSuccess=arg.callbackSuccess,
    })
end
--记得密码使用新密码修改
function SafeBox_ChangePasswd(arg)
    local _info={
        operatetype=8,
        param={
            userid=tostring(arg.userid),
            oldpwd=tostring(arg.oldpwd),
            newpwd=tostring(arg.newpwd),
            apitoken=_SafeBox_GetApitoken2('8')
        }
    }
    _SafeBox_ForgotPasswd_Common({
        info=_info,
        succeedCode=100363,
        callbackSuccess=arg.callbackSuccess,
    })
end

--游戏牌局记录
function _Game_Data_Common(arg)
    arg.busflag='115'
    _Hall_Common(arg)
end

--经典数据
function Game_Data_Get(arg)
    local _info={
        operatetype=1,
        param={
            userid=tostring(arg.userid),
        }
    }
    _Game_Data_Common({
        info=_info,
        succeedCode=100861,
        callbackSuccess=arg.callbackSuccess,
    })
end

-- 猜手牌记录
function GuessCard_Data_Get(arg)
    local _info={
        operatetype=6,
        param={
            userid=tostring(arg.userid),
        }
    }
    _Game_Data_Common({
        info=_info,
        succeedCode=100861,
        callbackSuccess=arg.callbackSuccess,
    })
end

function Game_Data_Get_With_Type(arg)
    local _info={
        operatetype=arg.type,
        param={
            userid=tostring(arg.userid),
        }
    }
    _Game_Data_Common({
        info=_info,
        succeedCode=100861,
        callbackSuccess=arg.callbackSuccess,
    })
end

--详情
function Game_Data_Details_WithHall(arg)
    local _info={
        operatetype=2,
        param={
            userid=tostring(arg.userid),
            game_log_id=tostring(arg.game_log_id),
        }
    }
    _Game_Data_Common({
        info=_info,
        succeedCode=100861,
        callbackSuccess=arg.callbackSuccess,
    })
end

--游戏内查看详情
function Game_Data_Details_WithGame(arg)
    local _info={
        operatetype=3,
        param={
            userid=tostring(arg.userid),
            table_id=tostring(arg.table_id),
            server_id=tostring(arg.server_id),
        }
    }
    _Game_Data_Common({
        info=_info,
        succeedCode=100861,
        callbackSuccess=arg.callbackSuccess,
    })
end


--猜中手牌/右上角奖池
function _Save_Data_Common(arg)
    arg.busflag='116'
    _Hall_Common(arg) 
end

--1:奖池中奖 2:猜手牌
--typename 什么牌型或者什么手牌
function Save_Lucky(arg)
    local _info={
        operatetype=arg.operatetype,
        param={
            userid=tostring(arg.userid),
            roomNumber=tostring(arg.roomNumber),
            typename=tostring(arg.typename),
            gold=arg.gold
        }
    }
    
    _Save_Data_Common({
        info=_info,
        succeedCode=100671,
        callbackSuccess=arg.callbackSuccess,
    })
end

-- 比赛场
function GameCompetitionCommon(arg)
    arg.busflag='118'
    _Hall_Common(arg)
end

-- 数据处理
function GameCompetitionData(arg)
    local _info =
    {
        operatetype = arg.operatetype,
        param =
        {
            userid = tostring(loginSucceedInfo.user_info.userid),
            matchID = arg.matchID,
        }
    }

    local common_data =
    {
        info=_info,
        succeedCode = 100871,
        callbackSuccess = arg.callbackSuccess,
        isHideWaitTip = arg.isHideWaitTip,
    }

    GameCompetitionCommon(common_data)
end

--比赛场信息
function GameCompetitionInfo(arg)
    GameCompetitionData({ operatetype = 1, matchID = 1, callbackSuccess = arg.callbackSuccess })
end

-- 报名参加
function GameCompetitionSignUp(arg)
    GameCompetitionData({ operatetype = 2, matchID = arg.matchID, callbackSuccess = arg.callbackSuccess })
end

-- 取消报名
function GameCompetitionSignUpCancel(arg)
    GameCompetitionData({ operatetype = 3, matchID = arg.matchID, callbackSuccess = arg.callbackSuccess })
end

-- 获取排名
function GameCompetitionRank(arg)
    GameCompetitionData({ operatetype = 4, matchID = arg.matchID, callbackSuccess = arg.callbackSuccess })
end

--比赛结果
function GameCompetitionResult(arg)
    GameCompetitionData({ operatetype = 5, matchID = 1, callbackSuccess = arg.callbackSuccess })
end

-- 道具卡的使用 -- 其他道具
function UsePropsCard(arg)
    local _info =
    {
        operatetype = 2,
        param =
        {
            userid = tostring(loginSucceedInfo.user_info.userid),
            type = arg.type,
        }
    }
    local common_data =
    {
        info = _info,
        succeedCode = 100601,
        callbackSuccess = arg.callbackSuccess,
        busflag = '105',
    }
    _Hall_Common(common_data)
end

-- 道具卡的使用 -- 话费卡道具
function UsePropsPhoneCard(arg)
    local _info =
    {
        operatetype = 2,
        param =
        {
            userid = tostring(loginSucceedInfo.user_info.userid),
            type = arg.type,
            phoneNum = arg.phoneNum
        }
    }
    local common_data =
    {
        info = _info,
        succeedCode = 100601,
        callbackSuccess = arg.callbackSuccess,
        busflag = '105',
    }
    _Hall_Common(common_data)
end