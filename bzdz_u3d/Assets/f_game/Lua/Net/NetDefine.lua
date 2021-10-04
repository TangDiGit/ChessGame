local EventDispatcher = require "EventDispatcher"

--一个socket对应一个配置
TestServerConfig =
{
    logic=800,
    ipArr='172.0.0.1:9999',
    send_To=0,
    send_Mcmd=0,
    serverid=0
}

GameServerConfig =
{
    logic=801,
    ipArr='172.0.0.1:9999',
    send_To=0,
    send_Mcmd=0,
    serverid=0}

NetLogicMsg =
{
    [TestServerConfig.logic] = EventDispatcher(),
    [GameServerConfig.logic] = EventDispatcher(),
}

H_NetMsg=EventDispatcher()

