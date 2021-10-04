require("Net/NetDefine")
require("Net/NetManager")
require("Net/H_Proto")
require("Net/H_Logic")
require("Net/H_HeartbeatManager")
require("Net/Poker_pb")
require("Net/GameBaseMsg_pb")

--require("Net/cmd_texas_net_pb")
require("Net/cmd_texas100_game_pb")
require("Net/DZNZ_GamePb_pb")
require("Net/BaiRenChang_GamePB_pb")
require("Net/BRNN_GamePb_pb")

require("Net/DzMatchPb_pb")

--[[
--test 序列化
require("Net/Login_pb")
local msg = Protol.Login_pb.C2SLogin()
msg.account = 'zzzz'
msg.pw = 'mmmm'
local item=Protol.Login_pb.Item()
item.key=1
item.val='1a'
table.insert(msg.items,item)

local item2=Protol.Login_pb.Item()
item2.key=2
item2.val='2b'
table.insert(msg.items,item2)

local pb_data = msg:SerializeToString()

F_Util.luaByteBuffer = pb_data

--反序列化
local msg2 = Protol.Login_pb.C2SLogin()
msg2:ParseFromString(F_Util.luaByteBuffer)
print('person_pb decoder: '..tostring(msg2))

--带i 不会解析出nil
for i,v in ipairs(msg2.items) do
    print(v.key,v.val)
end

--发消息的格式
NetManager.SendMessage(NetLoginLogic,'C2SLogin',pb_data)

--收消息的格式
NetLogicMsg[NetLoginLogic]:addEventListener('S2CLogin',function (arg)
    print('收到消息 S2CLogin')
    local msg = Protol.Login_pb.S2CLogin()
    msg:ParseFromString(arg.pb_data)
    print(tostring(msg))
end)]]