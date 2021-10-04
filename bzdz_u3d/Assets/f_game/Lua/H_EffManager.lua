--道具管理类 -- 声音
local _propSoundMap =
{
    [1] = "hd_bingtong01",          --冰桶
    [2] = "hd_daocha01",            --倒茶
    [3] = "hd_dapao01_end",         --大炮 -- hd_dapao01
    [4] = "hd_ganbei01",            --干杯
    [5] = "hd_gongjian01_end",      --弓箭 -- hd_gongjian01
    [6] = "hd_jidan01",             --鸡蛋
    [7] = "hd_jiguanqiang01_end",   --激光枪
    [8] = "hd_maobi01",             --毛笔
    [9] = "hd_meigui01",            --玫瑰
    [10] = "hd_woshou01",           --握手
    [11] = "hd_xianbing01",         --馅饼
    [12] = "hd_zhuaji01",           --抓鸡
}

--道具管理类
local _propSpineAniMap =
{
    [1] = "hd_bingtong01_Obj",
    [2] = "hd_daocha01_Obj",
    [3] = "hd_dapao01_end_Obj",         --hd_dapao01_Obj
    [4] = "hd_ganbei01_Obj",
    [5] = "hd_gongjian01_end_Obj",      --hd_gongjian01_Obj
    [6] = "hd_jidan01_Obj",
    [7] = "hd_jiguanqiang01_end_Obj",
    [8] = "hd_maobi01_Obj",
    [9] = "hd_meigui01_Obj",
    [10] = "hd_woshou01_Obj",
    [11] = "hd_xianbing01_Obj",
    [12] = "hd_zhuaji01_Obj",
}

--表情
FaceDic =
{
    ['lt_cs01_baobao01_Obj'] = { name = 'lt_cs01_baobao01_Obj', is_vip = false },
    ['lt_cs01_bukaixin01_Obj'] = { name = 'lt_cs01_bukaixin01_Obj', is_vip = false },
    ['lt_cs01_caishendao01_Obj'] = { name = 'lt_cs01_caishendao01_Obj', is_vip = false },
    ['lt_cs01_fahongbao01_Obj'] = { name = 'lt_cs01_fahongbao01_Obj', is_vip = false },
    ['lt_cs01_fahuo01_Obj'] = { name = 'lt_cs01_fahuo01_Obj', is_vip = false },
    ['lt_cs01_gongxifacai01_Obj'] = { name = 'lt_cs01_gongxifacai01_Obj', is_vip = false },
    ['lt_cs01_gongxifacai02_Obj'] = { name = 'lt_cs01_gongxifacai02_Obj', is_vip = false },
    ['lt_cs01_kanxi01_Obj'] = { name = 'lt_cs01_kanxi01_Obj', is_vip = false },
    ['lt_cs01_nizou01_Obj'] = { name = 'lt_cs01_nizou01_Obj', is_vip = false },
    ['lt_cs01_qiekenao01_Obj'] = { name = 'lt_cs01_qiekenao01_Obj', is_vip = false },
    ['lt_cs01_youqianrenxing01_Obj'] = { name = 'lt_cs01_youqianrenxing01_Obj', is_vip = false },
    ['lt_cs01_yun01_Obj'] = { name = 'lt_cs01_yun01_Obj', is_vip = false },
    ['qf_allmoneygomyhome01_Obj'] = { name = 'qf_allmoneygomyhome01_Obj', is_vip = false },
    ['qf_baiyibai01_Obj'] = { name = 'qf_baiyibai01_Obj', is_vip = false },
    ['qf_caishen01_Obj'] = { name = 'qf_caishen01_Obj', is_vip = false },
    ['qf_dajidali01_Obj'] = { name = 'qf_dajidali01_Obj', is_vip = false },
    -- vip
    ['ainio_Obj'] = { name = 'ainio_Obj', is_vip = true },                         -- 爱你哦
    ['anzhongguancha_Obj'] ={ name = 'anzhongguancha_Obj', is_vip = true },        -- 暗中观察
    ['biepao_Obj'] = { name = 'biepao_Obj', is_vip = true },                       -- 别跑
    ['dacuopaile_Obj'] = { name = 'dacuopaile_Obj', is_vip = true },               -- 打错牌了
    ['dalaozaici_Obj'] = { name = 'dalaozaici_Obj', is_vip = true },               -- 大佬在此
    ['haixiu_Obj'] = { name = 'haixiu_Obj', is_vip = true },                       -- 害羞
    ['kuaidianba_Obj'] = { name = 'kuaidianba_Obj', is_vip = true },               -- 快点吧
    ['shanyaodengchang_Obj'] = { name = 'shanyaodengchang_Obj', is_vip = true },   -- 闪耀登场
    ['wolaile_Obj'] = { name = 'wolaile_Obj', is_vip = true },                     -- 我来了
    ['yiqifacai_Obj'] = { name = 'yiqifacai_Obj', is_vip = true },                 -- 一起发财
    ['hd_cangyingpai01_Obj'] = { name = 'hd_cangyingpai01_Obj', is_vip = true },   -- 苍蝇拍
    ['hd_shuaibiti01_Obj'] = { name = 'hd_shuaibiti01_Obj', is_vip = true },       -- 甩鼻涕
    ['hd_xishou01_Obj'] = { name = 'hd_xishou01_Obj', is_vip = true },             -- 洗手
}

H_EffManager = { }
local M = H_EffManager

--飞道具动画
local _flyPopComs = {}
function M.ClearProp()
    for i, v in pairs(_flyPopComs) do
        v.visible=false
    end
end

function M.FlyProp(arg)
    local _propIndex = tonumber(arg.propIndex)
    if _propIndex > 12 or _propIndex == 0 then
        print("error：FlyProp _propIndex：".._propIndex)
        return
    end

    local comProp = H_ComPoolManager.GetComFromPool("biaoqing", "ComProp")
    comProp:GetController('c1').selectedIndex = _propIndex
    arg.effParent:AddChild(comProp)
    comProp.position = arg.fromPos

    local function DirectPlayAni(play_sound)
        comProp.visible = true
        local _t = Vector2.Distance(arg.fromPos, arg.toPos)/1500
        comProp:GetChild("n0").visible = true
        comProp:TweenMove(arg.toPos,_t):OnComplete(function ()
            comProp:GetChild("n0").visible=false
            local _gw = UIManager.SetDragonBonesAniObjPos2(_propSpineAniMap[_propIndex], comProp:GetChild("spineAni"),Vector3.New(100,100,100))
            Timer.New(function ()
                _gw:Dispose()
                H_ComPoolManager.RemoveComToPool(comProp)
            end,2,1):Start()
            --播放声音
            if play_sound then
                F_SoundManager.instance:PlayEffect(_propSoundMap[_propIndex])
            end
        end)
    end

    if _propIndex == 3 then
        local _gw = UIManager.SetDragonBonesAniObjPos2("hd_dapao01_Obj", comProp:GetChild("spineAni"),Vector3.New(100,100,100))
        F_SoundManager.instance:PlayEffect("hd_dapao01")
        Timer.New(function ()
            _gw:Dispose()
            DirectPlayAni(true)
        end,2,1):Start()
    elseif _propIndex == 5 then
        local _gw = UIManager.SetDragonBonesAniObjPos2("hd_gongjian01_Obj", comProp:GetChild("spineAni"),Vector3.New(100,100,100))
        F_SoundManager.instance:PlayEffect("hd_gongjian01")
        Timer.New(function ()
            _gw:Dispose()
            DirectPlayAni(true)
        end,2,1):Start()
    elseif _propIndex == 7 then
        local _gw = UIManager.SetDragonBonesAniObjPos2("hd_jiguanqiang01_Obj", comProp:GetChild("spineAni"),Vector3.New(100,100,100))
        F_SoundManager.instance:PlayEffect("hd_jiguanqiang01_end")
        Timer.New(function ()
            _gw:Dispose()
            DirectPlayAni(false)
        end,2,1):Start()
    else
        DirectPlayAni(true)
    end

    table.insert(_flyPopComs, comProp)
end

--打赏飞吻
local _flyKissComs = { }

function M.ClearKiss()
    if #_flyKissComs > 0 then
        for i,v in pairs(_flyKissComs) do
            v.visible=false
        end
    end
    _flyKissComs = { }
end

function M.FlyKiss(arg)
    M:ClearKiss()
    local _t = Vector2.Distance(arg.fromPos, arg.toPos)/1600
    local feiChouMa = H_ComPoolManager.GetComFromPool("texas", 'flyChip2')
    --H_ComPoolManager.GetComFromPool("texas", "flyChip2")  -- flyChip2 ComChouMa
    arg.effParent:AddChild(feiChouMa)
    feiChouMa.position = arg.toPos
    feiChouMa:GetController('c1').selectedIndex=0
    feiChouMa.scale =Vector2.New(1.15, 1.15)
    feiChouMa.visible = true
    feiChouMa:TweenMove(arg.chouMaEndPos, _t):SetEase(EaseType.CubicOut):OnComplete(function ()
        H_ComPoolManager.RemoveComToPool(feiChouMa)
        local comProp = H_ComPoolManager.GetComFromPool("biaoqing", "feiwen")
        if comProp.data==nil then
            comProp.data=UIManager.SetDragonBonesAniObjPos('armatureName_feiwen',comProp,Vector3.New(100,100,100))
        end
        local _UnityArmatureComponent=comProp.data:GetComponent('DragonBones.UnityArmatureComponent')
        _UnityArmatureComponent.animationPlayer:Play('fly')

        arg.effParent:AddChild(comProp)
        comProp.position = arg.fromPos
        comProp.visible = true

        comProp:TweenMove(arg.toPos,_t):SetDelay(0.5):OnComplete(function ()
            --播放飞吻
            _UnityArmatureComponent.animationPlayer:Play('animation',1)
            H_EventDispatcher:dispatchEvent({name='playWen',isMark=true})
            local _timer=Timer.New(function ()
                H_ComPoolManager.RemoveComToPool(comProp)
                H_EventDispatcher:dispatchEvent({name='playWen',isMark=false})
            end,3,1)
            _timer:Start()
        end)
        table.insert(_flyKissComs,comProp)
    end)

    table.insert(_flyKissComs,arg.feiChouMa)
    F_SoundManager.instance:PlayEffect('daShangFeiWenChaoPiao')
end

--玩家下注筹码飞
function M.FlyBetChip2(arg)
    for i=1,#arg.cmLs do
        local comChip = H_ComPoolManager.GetComFromPool("texas", "flyChip2")
        arg.effParent:AddChild(comChip)
        comChip.position = arg.fromPos
        comChip.visible = false
        comChip.scale=arg.scale
        comChip:GetController('c1').selectedIndex=arg.cmLs[i]

        --下注的筹码最大高度
        local _to=Vector2(arg.toPos.x,arg.toPos.y-(math.min(4,#arg.flyCMLs))*6)
        local _t = Vector2.Distance(arg.fromPos, arg.toPos)/arg.speed
        comChip:TweenMove(_to,_t):SetEase(EaseType.CubicOut):SetDelay(0.05*(i-1)):OnStart(function ()
            comChip.visible = true
        end)

        table.insert(arg.flyCMLs,comChip)
    end
end

--玩家下注的筹码显示 用在场景恢复  显示桌面奖池筹码数
function M.FlyBetChip2WithRecoverScene(arg)
    for i=1,#arg.cmLs do
        local comChip = H_ComPoolManager.GetComFromPool("texas", "flyChip2")
        arg.effParent:AddChild(comChip)
        comChip.visible = true
        comChip.scale=arg.scale
        comChip:GetController('c1').selectedIndex=arg.cmLs[i]
        --下注的筹码最大高度
        local _to=Vector2(arg.toPos.x,arg.toPos.y-(math.min(arg.maxCount-1,#arg.flyCMLs))*6)
        comChip.position = _to
        table.insert(arg.flyCMLs, comChip)
    end
end
function M.FlyBetChip2WithBianChi(arg)
    for i=1,#arg.cmLs do
        local comChip = H_ComPoolManager.GetComFromPool("texas", "flyChip2")
        arg.effParent:AddChild(comChip)
        comChip.visible = true
        comChip.scale=arg.scale
        comChip:GetController('c1').selectedIndex=arg.cmLs[i]
        --下注的筹码最大高度 这里和上面不同
        local _to=Vector2(arg.toPos.x,arg.toPos.y-(math.min(arg.maxCount-1,i))*6)
        comChip.position = _to
        table.insert(arg.flyCMLs, comChip)
    end
end


--将下注筹码飞到奖池
function M.FlyBetChip2ToPondList(arg)
    local t=0
    for i=1,#arg.flyCMLs do
        local comChip=arg.flyCMLs[i]
        comChip.visible=false
        GTween.Kill(comChip)
    end
    --todo只飞1个去边池
    for i=1,#arg.flyCMLs do
        local comChip=arg.flyCMLs[i]
        comChip.position=arg.fromPos
        local _t = Vector2.Distance(comChip.position, arg.toPos)/arg.speed + (0.05 * (i - 1))
        t = math.max(_t, t)
        comChip.visible = false
        comChip:TweenMove(arg.toPos,_t):SetEase(EaseType.QuadOut):OnComplete(function ()
            comChip.visible = false
        end):OnStart(function ()
            comChip.visible = true
        end)
    end
    --return 1
    return t
end


--开始游戏发牌动画
local _flyCardTimers = {}
local _flyCardComs = {}

function M.ClearFlyCardWithStartGame()
    for i,v in pairs(_flyCardTimers) do
        v:Stop()
    end
    _flyCardTimers={}

    for i,v in pairs(_flyCardComs) do
        H_ComPoolManager.RemoveComToPool(v)
    end
    _flyCardComs={}
end

function M.FlyCardWithStartGame(arg)
        --飞牌2级
        local _delayed=0
        for i,v in pairs(arg.toPosList1) do
            _delayed=M._FlyOnecWithStartGame(i,v,arg)
        end

        local _timer2=Timer.New(function ()
            for i,v in pairs(arg.toPosList2) do
                _delayed=M._FlyOnecWithStartGame(i,v,arg)
            end

            local _timer3=Timer.New(function ()
                if arg.callback then
                    arg.callback()
                end
            end,_delayed+0.05,1)
            _timer3:Start()
            table.insert(_flyCardTimers,_timer3)

        end,_delayed+0.05,1)
        _timer2:Start()
        table.insert(_flyCardTimers,_timer2)
end

--以下参数和弃牌相关
function M._GetFromComWithStartGame(arg)
    local com=H_ComPoolManager.GetComFromPool("texas", "ComStartFlyCard")
    --从牌桌中间开始飞,起始缩放为0.5
    com:SetScale(0.5,0.5)
    com.alpha=1
    com.rotation=0
    arg.effParent:AddChild(com)
    com.position=arg.fromPos
    return com
end

function M._FlyOnecWithStartGame(i,v,arg)
    local _delayed=(i-1)*0.1
    local toPos=v.toPos
    local callback=v.callback
    local gobj=v.gobj
    local _t = Vector2.Distance(arg.fromPos, toPos)/720
    local com=M._GetFromComWithStartGame(arg)
    table.insert(_flyCardComs,com)
    com:TweenMove(toPos,_t):SetEase(EaseType.CubicOut):SetDelay(_delayed)
    com:TweenRotate(gobj.rotation+360,_t):SetEase(EaseType.CubicOut):SetDelay(_delayed)
    --0.85是单个玩家组件的缩放
    com:TweenScale(Vector2(0.85,0.85),_t):SetEase(EaseType.CubicOut):SetDelay(_delayed)

    local _timer=Timer.New(function ()
        H_ComPoolManager.RemoveComToPool(com)
        if callback then
            callback()
        end
    end,_delayed+_t)
    _timer:Start()
    table.insert(_flyCardTimers,_timer)
    return _delayed
end

--弃牌动画
local _qiCardTimers = {}
local _qiCardComs = {}

function M.ClearQiCardWithStartGame()
    for i,v in pairs(_qiCardTimers) do
        v:Stop()
    end
    _qiCardTimers={}

    for i,v in pairs(_qiCardComs) do
        H_ComPoolManager.RemoveComToPool(v)
    end
    _qiCardComs={}
end

--怎么发的牌就怎么退回去.
function M.QiCardWithStartGame(arg)
    local com=H_ComPoolManager.GetComFromPool("texas", "ComStartFlyCard")
    --0.85是单个玩家组件的缩放
    com:SetScale(0.85,0.85)
    com.alpha=1
    com.rotation=arg.rotation
    arg.effParent:AddChild(com)
    com.position=arg.fromPos
    table.insert(_qiCardComs,com)

    local _t = Vector2.Distance(arg.fromPos, arg.toPos)/720
    com:TweenMove(arg.toPos,_t):SetEase(EaseType.CubicOut):OnComplete(function ()
        H_ComPoolManager.RemoveComToPool(com)
    end)
    com:TweenRotate(0+360,_t):SetEase(EaseType.CubicOut)
    com:TweenScale(Vector2(0.5,0.5),_t):SetEase(EaseType.CubicOut)
    com:TweenFade(0,_t):SetEase(EaseType.CubicOut)
end