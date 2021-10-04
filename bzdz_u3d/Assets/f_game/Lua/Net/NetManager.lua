NetManager={}
local M=NetManager
local map={}
local _session=-1
function M.OnHandleMsg(f_Msg)
    local _protocal = f_Msg.f_Protocal
    local logicID = f_Msg.logicID
    --print('OnHandleMsg:'..f_Msg.Mcmd..' '..f_Msg.Scmd)
    --print('lua层处理消息:'..logicID..'/'.._protocal)
    if _protocal~=905 then
        --判断socket有没有连接上 连接服务器成功/异常掉线/正常断线/连接服务器失败/正常数据
        NetLogicMsg[logicID]:dispatchEvent({name=tostring(_protocal)})
    else
        --正常数据
        --print('Scmd:'..string.format( "0x%X",f_Msg.Scmd))
        local _mark=true
        for i,v in pairs(CMD_Receive_Map) do
            if f_Msg.Mcmd == 100 or f_Msg.Mcmd == 200 or f_Msg.Mcmd == 400 then
                if f_Msg.Mcmd == v.Mcmd and f_Msg.Scmd == v.Scmd then
                    _mark = false
                    H_NetMsg:dispatchEvent({name=i,pb_data=f_Msg.luaByteBuffer,logicID=logicID})
                end
            elseif f_Msg.Scmd == v.Scmd then
                if v.Mcmd == 32 then
                    _mark = false
                    H_NetMsg:dispatchEvent({name=i,pb_data=f_Msg.luaByteBuffer,logicID=logicID})
                end
            end
        end
        --服务器主动踢人协议
        if f_Msg.Scmd==0X18 then
            H_NetMsg:dispatchEvent({name='0X18'})
            _mark=false
        end
        if _mark then
            print('未处理Scmd:'..string.format( "0x%d",f_Msg.Scmd)..' 主命令: '..f_Msg.Mcmd..' '..f_Msg.Scmd)
        end
    end
end
function M.CreateSocketClient(serverConfig)
    print('CreateSocketClient '..serverConfig.send_Mcmd)
    local sc=F_NetManager.instance:CreateSocketClient(serverConfig.logic,
        loginSucceedInfo.user_info.userid,serverConfig.send_To,serverConfig.send_Mcmd)
    map[serverConfig.logic] = sc
end

--主动关闭socket
function M.Close(logicID)
    if map[logicID] then
        --map[logicID]:Close()
        map[logicID]:OnRemove()
        
    end
end
function M.GetSocketClient(logicID)
    if not map[logicID] then
        print('sc err')
        return nil
    end
    return map[logicID]
end
function M.SendMessage(logicID,protoName,pb_data)
    if not map[logicID] then
        print('sc err')
        return nil
    end
    if not CMD_Send_Map[protoName] then
        print('proto send err')
        return nil
    end
    if pb_data==nil then
        map[logicID]:SendMessageWithNotPB(CMD_Send_Map[protoName].Scmd)
    else
        map[logicID]:SendMessageWithPB(CMD_Send_Map[protoName].Scmd,pb_data)
    end
end


function M.ConnectServer(serverConfig,callErr,callOK)
    M.Close(serverConfig.logic)

    NetLogicMsg[serverConfig.logic]:removeAllListeners(tostring(F_Protocal.ConnectErr))
    NetLogicMsg[serverConfig.logic]:removeAllListeners(tostring(F_Protocal.Connect))

	NetLogicMsg[serverConfig.logic]:addEventListener(tostring(F_Protocal.ConnectErr),callErr)
	NetLogicMsg[serverConfig.logic]:addEventListener(tostring(F_Protocal.Connect),callOK)
    M.CreateSocketClient(serverConfig)
    local t=lua_string_split(serverConfig.ipArr,":")
	M.GetSocketClient(serverConfig.logic):ConnectServer(t[1],tonumber(t[2]))
end

    --------- JOKER CODE ------------------------------------

function M.SendNetMsg(logicID,protoName,pb_data)
    if not map[logicID] then
        print('sc err')
        return nil
    end
    if not CMD_Send_Map[protoName] then
        print('proto send err')
        return nil
    end
    if pb_data == nil then
        map[logicID]:SendMessageWithNotPB(CMD_Send_Map[protoName].Mcmd,CMD_Send_Map[protoName].Scmd)
    else
        --主命令 子命令
        map[logicID]:SendMessageWithPB(CMD_Send_Map[protoName].Mcmd,CMD_Send_Map[protoName].Scmd,pb_data)
    end
end