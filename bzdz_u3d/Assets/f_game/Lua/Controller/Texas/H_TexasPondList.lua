--控制游戏中的奖池

local H_TexasPondList=class("H_TexasPondList")

function H_TexasPondList:Init(controller)
    self.m_controllerTexas=controller
    self.m_pondList=controller.m_content:GetChild("pondList").asList
    --效果定时器
    self.m_timers={}

    --边池总筹码
    self.cmList={}
end

function H_TexasPondList:ClearTimer()
    for i,v in ipairs(self.m_timers) do
        v:Stop()
    end
    self.m_timers={}
end

--游戏开始时设置一个奖池
function H_TexasPondList:SetWithStart(val)
    self.m_pondList.visible=true
    local _gcomPond=self.m_pondList:AddItemFromPool()
    self.m_pondList:EnsureBoundsCorrect()

    local _data={}
    _data.val=tonumber(val)
    _gcomPond.data=_data

    self:_generateCMList(_gcomPond)
end
--场景恢复时的设置
function H_TexasPondList:SetWithRecoverScene(arg)
    local _arg={}
    for i,v in ipairs(arg) do
        table.insert(_arg,v)
    end
    local _reverseArg=reverseTable(_arg)


    self.m_pondList.visible=true
    for i,v in ipairs(_reverseArg) do
        local _gcomPond=self.m_pondList:AddItemFromPool()

        local _data={}
        _data.val=tonumber(v)
        _gcomPond.data=_data
    end
    self.m_pondList:EnsureBoundsCorrect()

    for i=1,self.m_pondList:GetChildren().Length do
        local _gcomPond=self.m_pondList:GetChildAt(i-1)
        self:_generateCMList(_gcomPond)
    end
end

function H_TexasPondList:_generateCMList(com)
    local _comMove=com:GetChild("move")
    _comMove:GetChild("betText").text=formatVal(com.data.val)
    local cmLs=CalcFlyCM(com.data.val,gameData.xmgold)
    --todo 手动加下偏移。原因不明
    local toPos = _comMove:GlobalToLocal(_comMove:GetChild('betBg'):LocalToGlobal(Vector2.zero))
    --local toPos = _comMove:GlobalToLocal(_comMove:GetChild('cmPos'):LocalToGlobal(Vector2.zero))
    H_EffManager.FlyBetChip2WithBianChi({
        flyCMLs=self.cmList,
        cmLs=cmLs,
        effParent=_comMove,
        toPos=Vector2(toPos.x + 130, toPos.y + 30),
        --scale=Vector2(0.75,0.75),
        --toPos=toPos,
        scale=Vector2(0.85,0.85),
        maxCount=10
    })
    com.visible=true
end

--更新消息时的处理
function H_TexasPondList:SetWithMsg(msg)
    local _arg={}
    for i,v in ipairs(msg.bianchibet) do
        table.insert(_arg,v)
    end
    local _reverseArg=reverseTable(_arg)

    --每一轮结束的时候
    --设置边池

    --判断是否和旧数据相同
    if self.m_pondList:GetChildren().Length>0 then
        local _valMsgList={}
        for i,v in ipairs(_reverseArg) do
            table.insert(_valMsgList,v)
        end

        local _valLocalList={}
        for i=1,self.m_pondList:GetChildren().Length do
            local _gcomPond=self.m_pondList:GetChildAt(i-1)
            if _gcomPond.data  then
                table.insert(_valLocalList,_gcomPond.data.val)
            end
        end

        for i=#_valMsgList,1,-1 do
            for i2=#_valLocalList,1,-1 do
                if _valMsgList[i]==_valLocalList[i2] then
                    table.remove( _valMsgList)
                    table.remove( _valLocalList)
                end
            end
        end

        if #_valMsgList==0 and #_valLocalList==0  then
            --print('结算时奖池没刷新')
            return 
        end
    end

    if self.m_controllerTexas:GetAllBetVal()<=0 then
        --print('场上玩家下注总值为0,不应该刷新奖池')
        return 
    end

    --非必下这里默认显示一个
    if self.m_pondList:GetChildren().Length<=0 then
        local _sum=0
        for i,v in ipairs(_reverseArg) do
            _sum=_sum+v
        end
        self:SetWithStart(_sum)  
    end

    self:ClearTimer()

    --当前已经有x个奖池回归到一个
    local _t_XTo1=0
    if self.m_pondList:GetChildren().Length>1 then
        for i=1,self.m_pondList:GetChildren().Length do
            local _t=self:XTo1(i-1)
            _t_XTo1=math.max(_t,_t_XTo1)
        end
    end
    
    local _timer=Timer.New(function ()
        --x个奖池归到一个结束,开始飞金币
        local t=self.m_controllerTexas:ClearBetAllAndFly(self.m_controllerTexas.m_propLayer:GlobalToLocal(self.m_pondList:LocalToGlobal(Vector2.zero)))
        --所有玩家的筹码集中到中心 播放动画
        local _timer2=Timer.New(function ()
            --飞金币结束,散开奖池
            for i,v in ipairs(self.cmList) do
                H_ComPoolManager.RemoveComToPool(v)
            end
            self.cmList={}
            self.m_pondList:RemoveChildrenToPool()

            for i,v in ipairs(_reverseArg) do
                local _gcomPond=self.m_pondList:AddItemFromPool()
                local _data={}
                _data.val=tonumber(v)
                _gcomPond.data=_data
            end
            self.m_pondList:EnsureBoundsCorrect()

            for i=1,self.m_pondList:GetChildren().Length do
                local _gcomPond=self.m_pondList:GetChildAt(i-1)
                self:_generateCMList(_gcomPond)
            end

            local _t_1ToX=0
            
            for i=1,self.m_pondList:GetChildren().Length do
                local _t=self:oneToX(i-1)
                _t_1ToX=math.max(_t,_t_XTo1)
            end

            local _timer3=Timer.New(function ()
                --print('奖池移动结束')
            end,_t_1ToX,1)
            _timer3:Start()
            table.insert(self.m_timers,_timer3)

        end,t,1)
        _timer2:Start()
        table.insert(self.m_timers,_timer2)

    end,_t_XTo1,1)

    _timer:Start()
    table.insert(self.m_timers,_timer)
    
end

--清空桌面的奖池数据
function H_TexasPondList:ClearTexasPondList()
    self.m_pondList.visible=false

    for i,v in ipairs(self.cmList) do
        H_ComPoolManager.RemoveComToPool(v)
    end
    self.cmList={}

    self.m_pondList:RemoveChildrenToPool()

    self:ClearTimer()

    if self.pondListToPlayerCMList then
        for i,v in ipairs(self.pondListToPlayerCMList) do
            H_ComPoolManager.RemoveComToPool(v)
        end
    end
    self.pondListToPlayerCMList={}
end

--结算时飞筹码 临时处理
function H_TexasPondList:GetTempPos()
    return self.m_pondList:LocalToGlobal(Vector2.zero)
end

--奖池位置到中心点
function H_TexasPondList:XTo1(index)
    local _com=self.m_pondList:GetChildAt(index)
    local _comMove=_com:GetChild('move')
    _comMove.x=_com:GetChild('originalPos').x
    local _to=_com:GlobalToLocal(self.m_pondList:LocalToGlobal(Vector2.zero))
    local _t = Vector2.Distance(_com.xy, _to)/600
    _comMove:TweenMoveX(_to.x,_t):SetEase(EaseType.CubicOut)
    return _t
end

--中心点到奖池位置
function H_TexasPondList:oneToX(index)
    local _com=self.m_pondList:GetChildAt(index)
    local _comMove=_com:GetChild('move')
    _comMove.x=_com:GlobalToLocal(self.m_pondList:LocalToGlobal(Vector2.zero)).x
    local _to=_com:GetChild('originalPos')
    local _t = Vector2.Distance(_com.xy, _to)/600
    _com:GetChild('move'):TweenMoveX(_to.x,_t):SetEase(EaseType.CubicOut)
    return _t
end

--从底池x飞筹码给玩家x
function H_TexasPondList:PondListFlyCMToPlayer(_delay, bianchilot, toPos)
    local maxTime=0
    local _arg={}
    for i,v in ipairs(bianchilot) do
        table.insert(_arg,v)
    end
    local _reverseArg=reverseTable(_arg)
    for i,v in ipairs(_reverseArg) do
        if self.m_pondList:GetChildren().Length >=i then
            local _gcomPond = self.m_pondList:GetChildAt(i - 1)
            if _gcomPond and _gcomPond.data and _gcomPond.data.sum and _gcomPond.data.sum >= v and v > 0 then
                --一个池能飞好几个玩家
                local _cmls = CalcFlyCM(_gcomPond.data.sum,gameData.xmgold)
                for i2=1,#_cmls do
                    local comChip = H_ComPoolManager.GetComFromPool("texas", "flyChip2")
                    comChip:GetController('c1').selectedIndex=_cmls[i2]
                    comChip.position = self.m_controllerTexas.m_propLayer:GlobalToLocal(_gcomPond:GetChild("move"):GetChild('betBg'):LocalToGlobal(Vector2.zero))
                    local _t = Vector2.Distance(comChip.position, toPos)/2000
                    self.m_controllerTexas.m_propLayer:AddChild(comChip)
                    comChip.visible = false
                    comChip:TweenMove(toPos,_t):SetEase(EaseType.CubicOut):OnComplete(function ()
                        comChip.visible = false
                        self:HidePondListWith0()
                    end):SetDelay(0.05*(i2-1)+_delay):OnStart(function ()
                        comChip.visible = true
                        if _gcomPond.data and _gcomPond.data.sum then
                            _gcomPond.data.sum=_gcomPond.data.sum-v
                        end
                    end)

                    table.insert(self.pondListToPlayerCMList,comChip)
                    maxTime=_t+0.05*(i2-1)
                end
            end
        end
    end
    return maxTime
end
function H_TexasPondList:PondListFinallyVal()
    for i=1,self.m_pondList:GetChildren().Length do
        local _gcomPond=self.m_pondList:GetChildAt(i-1)
        _gcomPond.data.sum=_gcomPond.data.val
        --print(_gcomPond.data.sum)
    end
    
end
function H_TexasPondList:HidePondListWith0()
    for i=1,self.m_pondList:GetChildren().Length do
        local _gcomPond=self.m_pondList:GetChildAt(i-1)
        
        if _gcomPond.data and _gcomPond.data.sum and _gcomPond.data.sum<=0 then
            _gcomPond.visible=false
        
        end
    end
end
return H_TexasPondList