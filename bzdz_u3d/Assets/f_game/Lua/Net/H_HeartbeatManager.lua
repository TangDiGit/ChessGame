--心跳类,处理心跳逻辑
--心跳每3秒一次
local HeartbeatInterval = 4
--心跳尝试重连次数
local HeartbeatReLoginMaxCount = 3
local H_Heartbeat = class("H_Heartbeat")

function H_Heartbeat:Init(_logicID)
    self.m_IsClose = false
    self.m_logicID = _logicID
    --掉线定时器
    self.m_timerDropped = nil
    --发送心跳定时器
    self.m_timerSendHeartbeat = nil
    --重新登入定时器
    self.m_timerRelogin = nil
    --定时器是否工作中
    self.m_isWork = false

    self:InitApplicationPauseFront()
    self:InitServerPing()
end

--切后台切回来,立即发送一次心跳,并将断线计时器调整为2秒
function H_Heartbeat:InitApplicationPauseFront()
    H_EventDispatcher:addEventListener('OnApplicationPause_front',function (arg)
        if self.m_isWork then
            if self.m_timerDropped then
                self.m_timerDropped:Stop()
            end
            if self.m_timerSendHeartbeat then
                self:HandleOnec(false,2)
                self.m_timerSendHeartbeat.time = 0
            end
        end
    end)
end

--监听服务器心跳回包
function H_Heartbeat:InitServerPing()
    H_NetMsg:addEventListener('ClientPing',function (arg)
        if arg.logicID == self.m_logicID then
            local msg = Protol.GameBaseMsg_pb.ClientPing()
            msg:ParseFromString(arg.pb_data)

            if self.m_IsClose then
                return
            end

            if self.m_timerDropped then
                self.m_timerDropped:Stop()
            end

            self:HandleOnec()
        end
    end)
end

--处理一次心跳
function H_Heartbeat:HandleOnec(isStart, time)
    local _v = time or HeartbeatInterval

    if self.m_timerSendHeartbeat then
        self.m_timerSendHeartbeat:Stop()
    end

    self.m_timerSendHeartbeat = Timer.New(function ()
        --print('发送一次心跳:'..self.m_logicID..(isStart and ' isStart' or ''))
        if self.m_timerDropped then
            self.m_timerDropped:Stop()
        end

        self.m_timerDropped = Timer.New(function ()
            --print('断线重连开始:'..self.m_logicID..(isStart and ' isStart' or ''))
            self:ReLogin(0)
        end, _v, 1)

        self.m_timerDropped:Start()

        --发送网络心跳包
        NetManager.SendMessage(GameServerConfig.logic,'ClientPing')
    end, _v, 1)

    self.m_timerSendHeartbeat:Start()
end

--重新登入
function H_Heartbeat:ReLogin(count)
    if count == HeartbeatReLoginMaxCount then
        UIManager.Hide('ControllerHallConnectTips')
        UIManager.Show('ControllerMessageBox',{strTit='网络连接错误,请重新登入',callY = function ()
            UIManager.Show('ControllerLogin')
        end})
        NetManager.Close(self.m_logicID)
        self:Cancel()
        return
    else
        --3 秒连一次,总共连3次
        self.m_timerRelogin = Timer.New(function ()
            count = count + 1
            self:ReLogin(count)
        end, HeartbeatInterval, 1)

        self.m_timerRelogin:Start()
    end

    UIManager.Show('ControllerHallConnectTips')

	NetManager.ConnectServer(GameServerConfig,function ()
        UIManager.Show('ControllerHallConnectTips')
	end,function ()
        UIManager.Hide('ControllerHallConnectTips')

        UIManager.AddPopTip({ strTit = "网络连接成功" })

        H_HeartbeatManager.Restart(GameServerConfig.logic)

        if UIManager.IsShowState('ControllerTexas') then
            if roomCfg.is_competition then
                sendEnterGameCompetition(0, 0)
            else
                sendEnterGameRequst(var_tableid, var_passwd)
            end
        else
            if UIManager.IsShowState('ControllerDZNZ_Main') then
                sendEnterNiuZai()
            elseif UIManager.IsShowState('ControllerBaiRen') then
                sendEnterBaiRen()
            else
                UIManager.Show('ControllerHall')
            end
        end
	end)
end

--开始心跳
function H_Heartbeat:Restart()
    if self.m_IsClose then
        return
    end
    self:Cancel()
    self:HandleOnec(true)
    self.m_isWork=true
end

function H_Heartbeat:Cancel()
    --print('取消心跳:'..self.m_logicID)
    if self.m_timerSendHeartbeat then
        self.m_timerSendHeartbeat:Stop()
    end
    if self.m_timerDropped then
        self.m_timerDropped:Stop()
    end
    if self.m_timerRelogin then
        self.m_timerRelogin:Stop()
    end
    self.m_isWork=false
end

--心跳管理
H_HeartbeatManager = { }
local M = H_HeartbeatManager

local _HeartbeatMap = { }

_HeartbeatMap[TestServerConfig.logic] = H_Heartbeat.new()
_HeartbeatMap[TestServerConfig.logic]:Init(TestServerConfig.logic)

_HeartbeatMap[GameServerConfig.logic] = H_Heartbeat.new()
_HeartbeatMap[GameServerConfig.logic]:Init(GameServerConfig.logic)

--切换账号/踢出账号
function M.Cancel(_logicID)
    _HeartbeatMap[_logicID]:Cancel()
end

--开始心跳
function M.Restart(_logicID)
    _HeartbeatMap[_logicID]:Restart()
end
