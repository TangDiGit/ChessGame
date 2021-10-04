require("init")
local load_index = 1
local load_list =
{
	'spine.unity3d',
	'spine_longhudou.unity3d',
	'spine_caishen.unity3d',
	'dragonbones.unity3d',
	'spine_dzniuzai.unity3d',
	'spine_duobao.unity3d',
	'spine_huodong.unity3d',
	'spine_biankuang.unity3d',
	'spine_bq_vip.unity3d',
	'spine_daoju.unity3d',
	'spine_nvheguan.unity3d',
}

main_can_click = false

--主入口函数。从这里开始lua逻辑
function Main()
	print("lua logic start")
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
	UIManager.Init()

	-- 把需要预加载的都放在了 spine_jinbi 里面
	F_ResourceManager.instance:LoadPrefab("spine_jinbi.unity3d", nil, function (arr)
		for i = 0, arr.Length - 1 do
			UIManager.AddPrefab(arr[i])
			if i == arr.Length - 1 then
				F_ResourceManager.instance:AddPackage("newgamebg", function ()
					F_ResourceManager.instance:AddPackage("hall", function ()
						UIManager.Show('ControllerLogin')
						F_MessageView.instance:Hide()
						F_WaitTipView.instance:Hide()
						F_LogoView.instance:Hide()
						OnWXDirectLogin()
					end)
				end)
			end
		end
	end)
end

-- 加载背景音乐
function LoadBgm()
	F_ResourceManager.instance:LoadAudioClip("sound_bgm.unity3d", nil, function (arr)
		for i = 0, arr.Length - 1 do
			F_SoundManager.instance:Add(arr[i].name,arr[i])
			if i == arr.Length - 1 then
				F_SoundManager.instance:SetBackSoundTrack({'bgm2','bgm3','bgm4'})
				OnLoadPrefab(load_list[load_index])
			end
		end
	end)
end

-- 加载预制
function OnLoadPrefab(name)
	F_ResourceManager.instance:LoadPrefab(name, nil, function (arr)
		for i = 0, arr.Length - 1 do
			UIManager.AddPrefab(arr[i])
			if i == arr.Length - 1 then
				load_index = load_index + 1
				if load_list[load_index] then
					OnLoadPrefab(load_list[load_index])
				else
					OnLoadSound()
				end
			end
		end
	end)
end

-- 加载音效
function OnLoadSound()
	F_ResourceManager.instance:LoadAudioClip("sound_jiaohu.unity3d", nil, function (arr1)
		for i = 0, arr1.Length - 1 do
			F_SoundManager.instance:Add(arr1[i].name, arr1[i])
			if i == arr1.Length - 1 then
				F_ResourceManager.instance:LoadAudioClip("sound_daoju.unity3d", nil, function (arr2)
					for k = 0, arr2.Length - 1 do
						F_SoundManager.instance:Add(arr2[k].name, arr2[k])
						if k == arr2.Length - 1 then
							OnLoadPoker()
						end
					end
				end)
			end
		end

	end)
end

-- 加载poker
function OnLoadPoker()
	F_ResourceManager.instance:AddPackage("poker", function ()
		if not isExtensionCard then
			isExtensionCard = true
			F_ExtensionCardHelp.Extension('ui://poker/card')
		end
		main_can_click = true
	end)
end

--场景切换通知
function OnLevelWasLoaded(level)
	collectgarbage("collect")
	Time.timeSinceLevelLoad = 0
end

function OnApplicationQuit()

end

function OnApplicationPause(focus)
	if focus then
		logd('进入后台')
	else
		logd('进入前台')
		H_EventDispatcher:dispatchEvent({name='OnApplicationPause_front'})
	end
end

--Socket消息--
function OnSocket(f_Msg)
    NetManager.OnHandleMsg(f_Msg)
end

--/*
--* 这里可以返回如下数据
--* openid	普通用户的标识，对当前开发者帐号唯一
--* nickname	普通用户昵称
--* sex	普通用户性别，1为男性，2为女性，0为没有设置性别
--* province	普通用户个人资料填写的省份
--* city	普通用户个人资料填写的城市
--* country	国家，如中国为CN
--* headimgurl	用户头像，最后一个数值代表正方形头像大小（有0、46、64、96、132数值可选，0代表640*640正方形头像），用户没有头像时该项为空
--* privilege	用户特权信息，json数组，如微信沃卡用户为（chinaunicom）
--* unionid	用户统一标识。针对一个微信开放平台帐号下的应用，同一用户的unionid是唯一的。
--*/
--微信授权登入
function OnWXLogin(result)
	--print('OnWXLogin:'..result)
	local _info = json.decode(result)
	login_sendWX({ unionid = _info.unionid, nickname = _info.nickname, sex = tostring(_info.sex-1), headurl = _info.headimgurl, })
end

--直接登录，本地保存微信的信息
function OnWXDirectLogin()
	--微信登录超时天数
	F_Tool.instance:GetWxLoginIsOutTime(ServerInfo.wxLoginOutDay)
	if not F_Tool.isWxLoginOutTime and (F_Util.isAndroid() or F_Util.isIOS()) then
		local res = { }
		res.unionid = PlayerPrefs.GetString("wx_unionid")
		res.nickname = PlayerPrefs.GetString("wx_nickname")
		res.sex = tonumber(PlayerPrefs.GetString("wx_sex"))
		res.headurl = PlayerPrefs.GetString("wx_headurl")

		if res.sex then
			login_sendWX(res)
		end
	end
end

function SetWXLoginPara(res)
	PlayerPrefs.SetString("wx_unionid", res.unionid)
	PlayerPrefs.SetString("wx_nickname", res.nickname)
	PlayerPrefs.SetString("wx_sex", res.sex)
	PlayerPrefs.SetString("wx_headurl", res.headurl)

	-- 过期才会重新赋值
	if F_Tool.isWxLoginOutTime then
		F_Tool.instance:SetWxLoginTimeNow()
	end
end

function FloatMsg(msg)
	if type(msg) == "string" then
		UIManager.AddPopTip({ strTit='msg'} )
	end
end

function logd(msg)
	if F_Log and not F_Util.isIOS() and type(msg) ~= "table" then
		F_Log.Logd(msg)
	end
end