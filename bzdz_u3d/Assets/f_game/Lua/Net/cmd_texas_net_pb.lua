--Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
module('Protol.cmd_texas_net_pb')

CMD_GAME_SUB = protobuf.EnumDescriptor();
CMD_GAME_SUB_CMD_GAME_ENTER_GAME_REQ_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_ENTER_GAME_FAILD_RSP_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_UPDATE_GAME_SCENE_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_LEAVE_REQ_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_LEAVE_RSP_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_SITDOWN_REQ_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_SITDOWN_RSP_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_STANDUP_REQ_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_STANDUP_RSP_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_PLAYER_STATUS_CHG_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_GAME_STATUS_CHG_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_BET_REQ_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_BET_RESP_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_UPDATE_BET_INFO_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_APPLY_BANKER_REQ_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_APPLY_BANKER_RESP_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_GET_APPLY_BANKER_LIST_REQ_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_GET_APPLY_BANKER_LIST_RESP_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_EXIT_BANKER_REQ_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_EXIT_BANKER_RESP_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_BANKER_CHG_RESP_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_BET_SETTLE_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_GET_USER_LIST_REQ_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_GET_USER_LIST_RSP_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_USER_OFFLINE_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_USER_RECONN_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_BALANCE_TREND_REQ_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_BALANCE_TREND_RSP_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_ROUND_LOOKBACK_REQ_ENUM = protobuf.EnumValueDescriptor();
CMD_GAME_SUB_CMD_GAME_ROUND_LOOKBACK_RSP_ENUM = protobuf.EnumValueDescriptor();

CMD_GAME_SUB_CMD_GAME_ENTER_GAME_REQ_ENUM.name = "CMD_GAME_ENTER_GAME_REQ"
CMD_GAME_SUB_CMD_GAME_ENTER_GAME_REQ_ENUM.index = 0
CMD_GAME_SUB_CMD_GAME_ENTER_GAME_REQ_ENUM.number = 4224
CMD_GAME_SUB_CMD_GAME_ENTER_GAME_FAILD_RSP_ENUM.name = "CMD_GAME_ENTER_GAME_FAILD_RSP"
CMD_GAME_SUB_CMD_GAME_ENTER_GAME_FAILD_RSP_ENUM.index = 1
CMD_GAME_SUB_CMD_GAME_ENTER_GAME_FAILD_RSP_ENUM.number = 4225
CMD_GAME_SUB_CMD_GAME_UPDATE_GAME_SCENE_ENUM.name = "CMD_GAME_UPDATE_GAME_SCENE"
CMD_GAME_SUB_CMD_GAME_UPDATE_GAME_SCENE_ENUM.index = 2
CMD_GAME_SUB_CMD_GAME_UPDATE_GAME_SCENE_ENUM.number = 4226
CMD_GAME_SUB_CMD_GAME_LEAVE_REQ_ENUM.name = "CMD_GAME_LEAVE_REQ"
CMD_GAME_SUB_CMD_GAME_LEAVE_REQ_ENUM.index = 3
CMD_GAME_SUB_CMD_GAME_LEAVE_REQ_ENUM.number = 4227
CMD_GAME_SUB_CMD_GAME_LEAVE_RSP_ENUM.name = "CMD_GAME_LEAVE_RSP"
CMD_GAME_SUB_CMD_GAME_LEAVE_RSP_ENUM.index = 4
CMD_GAME_SUB_CMD_GAME_LEAVE_RSP_ENUM.number = 4228
CMD_GAME_SUB_CMD_GAME_SITDOWN_REQ_ENUM.name = "CMD_GAME_SITDOWN_REQ"
CMD_GAME_SUB_CMD_GAME_SITDOWN_REQ_ENUM.index = 5
CMD_GAME_SUB_CMD_GAME_SITDOWN_REQ_ENUM.number = 4229
CMD_GAME_SUB_CMD_GAME_SITDOWN_RSP_ENUM.name = "CMD_GAME_SITDOWN_RSP"
CMD_GAME_SUB_CMD_GAME_SITDOWN_RSP_ENUM.index = 6
CMD_GAME_SUB_CMD_GAME_SITDOWN_RSP_ENUM.number = 4230
CMD_GAME_SUB_CMD_GAME_STANDUP_REQ_ENUM.name = "CMD_GAME_STANDUP_REQ"
CMD_GAME_SUB_CMD_GAME_STANDUP_REQ_ENUM.index = 7
CMD_GAME_SUB_CMD_GAME_STANDUP_REQ_ENUM.number = 4231
CMD_GAME_SUB_CMD_GAME_STANDUP_RSP_ENUM.name = "CMD_GAME_STANDUP_RSP"
CMD_GAME_SUB_CMD_GAME_STANDUP_RSP_ENUM.index = 8
CMD_GAME_SUB_CMD_GAME_STANDUP_RSP_ENUM.number = 4232
CMD_GAME_SUB_CMD_GAME_PLAYER_STATUS_CHG_ENUM.name = "CMD_GAME_PLAYER_STATUS_CHG"
CMD_GAME_SUB_CMD_GAME_PLAYER_STATUS_CHG_ENUM.index = 9
CMD_GAME_SUB_CMD_GAME_PLAYER_STATUS_CHG_ENUM.number = 4233
CMD_GAME_SUB_CMD_GAME_GAME_STATUS_CHG_ENUM.name = "CMD_GAME_GAME_STATUS_CHG"
CMD_GAME_SUB_CMD_GAME_GAME_STATUS_CHG_ENUM.index = 10
CMD_GAME_SUB_CMD_GAME_GAME_STATUS_CHG_ENUM.number = 4240
CMD_GAME_SUB_CMD_GAME_BET_REQ_ENUM.name = "CMD_GAME_BET_REQ"
CMD_GAME_SUB_CMD_GAME_BET_REQ_ENUM.index = 11
CMD_GAME_SUB_CMD_GAME_BET_REQ_ENUM.number = 4241
CMD_GAME_SUB_CMD_GAME_BET_RESP_ENUM.name = "CMD_GAME_BET_RESP"
CMD_GAME_SUB_CMD_GAME_BET_RESP_ENUM.index = 12
CMD_GAME_SUB_CMD_GAME_BET_RESP_ENUM.number = 4242
CMD_GAME_SUB_CMD_GAME_UPDATE_BET_INFO_ENUM.name = "CMD_GAME_UPDATE_BET_INFO"
CMD_GAME_SUB_CMD_GAME_UPDATE_BET_INFO_ENUM.index = 13
CMD_GAME_SUB_CMD_GAME_UPDATE_BET_INFO_ENUM.number = 4243
CMD_GAME_SUB_CMD_GAME_APPLY_BANKER_REQ_ENUM.name = "CMD_GAME_APPLY_BANKER_REQ"
CMD_GAME_SUB_CMD_GAME_APPLY_BANKER_REQ_ENUM.index = 14
CMD_GAME_SUB_CMD_GAME_APPLY_BANKER_REQ_ENUM.number = 4244
CMD_GAME_SUB_CMD_GAME_APPLY_BANKER_RESP_ENUM.name = "CMD_GAME_APPLY_BANKER_RESP"
CMD_GAME_SUB_CMD_GAME_APPLY_BANKER_RESP_ENUM.index = 15
CMD_GAME_SUB_CMD_GAME_APPLY_BANKER_RESP_ENUM.number = 4245
CMD_GAME_SUB_CMD_GAME_GET_APPLY_BANKER_LIST_REQ_ENUM.name = "CMD_GAME_GET_APPLY_BANKER_LIST_REQ"
CMD_GAME_SUB_CMD_GAME_GET_APPLY_BANKER_LIST_REQ_ENUM.index = 16
CMD_GAME_SUB_CMD_GAME_GET_APPLY_BANKER_LIST_REQ_ENUM.number = 4246
CMD_GAME_SUB_CMD_GAME_GET_APPLY_BANKER_LIST_RESP_ENUM.name = "CMD_GAME_GET_APPLY_BANKER_LIST_RESP"
CMD_GAME_SUB_CMD_GAME_GET_APPLY_BANKER_LIST_RESP_ENUM.index = 17
CMD_GAME_SUB_CMD_GAME_GET_APPLY_BANKER_LIST_RESP_ENUM.number = 4247
CMD_GAME_SUB_CMD_GAME_EXIT_BANKER_REQ_ENUM.name = "CMD_GAME_EXIT_BANKER_REQ"
CMD_GAME_SUB_CMD_GAME_EXIT_BANKER_REQ_ENUM.index = 18
CMD_GAME_SUB_CMD_GAME_EXIT_BANKER_REQ_ENUM.number = 4248
CMD_GAME_SUB_CMD_GAME_EXIT_BANKER_RESP_ENUM.name = "CMD_GAME_EXIT_BANKER_RESP"
CMD_GAME_SUB_CMD_GAME_EXIT_BANKER_RESP_ENUM.index = 19
CMD_GAME_SUB_CMD_GAME_EXIT_BANKER_RESP_ENUM.number = 4249
CMD_GAME_SUB_CMD_GAME_BANKER_CHG_RESP_ENUM.name = "CMD_GAME_BANKER_CHG_RESP"
CMD_GAME_SUB_CMD_GAME_BANKER_CHG_RESP_ENUM.index = 20
CMD_GAME_SUB_CMD_GAME_BANKER_CHG_RESP_ENUM.number = 4352
CMD_GAME_SUB_CMD_GAME_BET_SETTLE_ENUM.name = "CMD_GAME_BET_SETTLE"
CMD_GAME_SUB_CMD_GAME_BET_SETTLE_ENUM.index = 21
CMD_GAME_SUB_CMD_GAME_BET_SETTLE_ENUM.number = 4353
CMD_GAME_SUB_CMD_GAME_GET_USER_LIST_REQ_ENUM.name = "CMD_GAME_GET_USER_LIST_REQ"
CMD_GAME_SUB_CMD_GAME_GET_USER_LIST_REQ_ENUM.index = 22
CMD_GAME_SUB_CMD_GAME_GET_USER_LIST_REQ_ENUM.number = 4354
CMD_GAME_SUB_CMD_GAME_GET_USER_LIST_RSP_ENUM.name = "CMD_GAME_GET_USER_LIST_RSP"
CMD_GAME_SUB_CMD_GAME_GET_USER_LIST_RSP_ENUM.index = 23
CMD_GAME_SUB_CMD_GAME_GET_USER_LIST_RSP_ENUM.number = 4355
CMD_GAME_SUB_CMD_GAME_USER_OFFLINE_ENUM.name = "CMD_GAME_USER_OFFLINE"
CMD_GAME_SUB_CMD_GAME_USER_OFFLINE_ENUM.index = 24
CMD_GAME_SUB_CMD_GAME_USER_OFFLINE_ENUM.number = 4356
CMD_GAME_SUB_CMD_GAME_USER_RECONN_ENUM.name = "CMD_GAME_USER_RECONN"
CMD_GAME_SUB_CMD_GAME_USER_RECONN_ENUM.index = 25
CMD_GAME_SUB_CMD_GAME_USER_RECONN_ENUM.number = 4357
CMD_GAME_SUB_CMD_GAME_BALANCE_TREND_REQ_ENUM.name = "CMD_GAME_BALANCE_TREND_REQ"
CMD_GAME_SUB_CMD_GAME_BALANCE_TREND_REQ_ENUM.index = 26
CMD_GAME_SUB_CMD_GAME_BALANCE_TREND_REQ_ENUM.number = 4358
CMD_GAME_SUB_CMD_GAME_BALANCE_TREND_RSP_ENUM.name = "CMD_GAME_BALANCE_TREND_RSP"
CMD_GAME_SUB_CMD_GAME_BALANCE_TREND_RSP_ENUM.index = 27
CMD_GAME_SUB_CMD_GAME_BALANCE_TREND_RSP_ENUM.number = 4359
CMD_GAME_SUB_CMD_GAME_ROUND_LOOKBACK_REQ_ENUM.name = "CMD_GAME_ROUND_LOOKBACK_REQ"
CMD_GAME_SUB_CMD_GAME_ROUND_LOOKBACK_REQ_ENUM.index = 28
CMD_GAME_SUB_CMD_GAME_ROUND_LOOKBACK_REQ_ENUM.number = 4360
CMD_GAME_SUB_CMD_GAME_ROUND_LOOKBACK_RSP_ENUM.name = "CMD_GAME_ROUND_LOOKBACK_RSP"
CMD_GAME_SUB_CMD_GAME_ROUND_LOOKBACK_RSP_ENUM.index = 29
CMD_GAME_SUB_CMD_GAME_ROUND_LOOKBACK_RSP_ENUM.number = 4361
CMD_GAME_SUB.name = "CMD_GAME_SUB"
CMD_GAME_SUB.full_name = ".proto.cmd_texas_net.CMD_GAME_SUB"
CMD_GAME_SUB.values = {CMD_GAME_SUB_CMD_GAME_ENTER_GAME_REQ_ENUM,CMD_GAME_SUB_CMD_GAME_ENTER_GAME_FAILD_RSP_ENUM,CMD_GAME_SUB_CMD_GAME_UPDATE_GAME_SCENE_ENUM,CMD_GAME_SUB_CMD_GAME_LEAVE_REQ_ENUM,CMD_GAME_SUB_CMD_GAME_LEAVE_RSP_ENUM,CMD_GAME_SUB_CMD_GAME_SITDOWN_REQ_ENUM,CMD_GAME_SUB_CMD_GAME_SITDOWN_RSP_ENUM,CMD_GAME_SUB_CMD_GAME_STANDUP_REQ_ENUM,CMD_GAME_SUB_CMD_GAME_STANDUP_RSP_ENUM,CMD_GAME_SUB_CMD_GAME_PLAYER_STATUS_CHG_ENUM,CMD_GAME_SUB_CMD_GAME_GAME_STATUS_CHG_ENUM,CMD_GAME_SUB_CMD_GAME_BET_REQ_ENUM,CMD_GAME_SUB_CMD_GAME_BET_RESP_ENUM,CMD_GAME_SUB_CMD_GAME_UPDATE_BET_INFO_ENUM,CMD_GAME_SUB_CMD_GAME_APPLY_BANKER_REQ_ENUM,CMD_GAME_SUB_CMD_GAME_APPLY_BANKER_RESP_ENUM,CMD_GAME_SUB_CMD_GAME_GET_APPLY_BANKER_LIST_REQ_ENUM,CMD_GAME_SUB_CMD_GAME_GET_APPLY_BANKER_LIST_RESP_ENUM,CMD_GAME_SUB_CMD_GAME_EXIT_BANKER_REQ_ENUM,CMD_GAME_SUB_CMD_GAME_EXIT_BANKER_RESP_ENUM,CMD_GAME_SUB_CMD_GAME_BANKER_CHG_RESP_ENUM,CMD_GAME_SUB_CMD_GAME_BET_SETTLE_ENUM,CMD_GAME_SUB_CMD_GAME_GET_USER_LIST_REQ_ENUM,CMD_GAME_SUB_CMD_GAME_GET_USER_LIST_RSP_ENUM,CMD_GAME_SUB_CMD_GAME_USER_OFFLINE_ENUM,CMD_GAME_SUB_CMD_GAME_USER_RECONN_ENUM,CMD_GAME_SUB_CMD_GAME_BALANCE_TREND_REQ_ENUM,CMD_GAME_SUB_CMD_GAME_BALANCE_TREND_RSP_ENUM,CMD_GAME_SUB_CMD_GAME_ROUND_LOOKBACK_REQ_ENUM,CMD_GAME_SUB_CMD_GAME_ROUND_LOOKBACK_RSP_ENUM}

CMD_GAME_APPLY_BANKER_REQ = 4244
CMD_GAME_APPLY_BANKER_RESP = 4245
CMD_GAME_BALANCE_TREND_REQ = 4358
CMD_GAME_BALANCE_TREND_RSP = 4359
CMD_GAME_BANKER_CHG_RESP = 4352
CMD_GAME_BET_REQ = 4241
CMD_GAME_BET_RESP = 4242
CMD_GAME_BET_SETTLE = 4353
CMD_GAME_ENTER_GAME_FAILD_RSP = 4225
CMD_GAME_ENTER_GAME_REQ = 4224
CMD_GAME_EXIT_BANKER_REQ = 4248
CMD_GAME_EXIT_BANKER_RESP = 4249
CMD_GAME_GAME_STATUS_CHG = 4240
CMD_GAME_GET_APPLY_BANKER_LIST_REQ = 4246
CMD_GAME_GET_APPLY_BANKER_LIST_RESP = 4247
CMD_GAME_GET_USER_LIST_REQ = 4354
CMD_GAME_GET_USER_LIST_RSP = 4355
CMD_GAME_LEAVE_REQ = 4227
CMD_GAME_LEAVE_RSP = 4228
CMD_GAME_PLAYER_STATUS_CHG = 4233
CMD_GAME_ROUND_LOOKBACK_REQ = 4360
CMD_GAME_ROUND_LOOKBACK_RSP = 4361
CMD_GAME_SITDOWN_REQ = 4229
CMD_GAME_SITDOWN_RSP = 4230
CMD_GAME_STANDUP_REQ = 4231
CMD_GAME_STANDUP_RSP = 4232
CMD_GAME_UPDATE_BET_INFO = 4243
CMD_GAME_UPDATE_GAME_SCENE = 4226
CMD_GAME_USER_OFFLINE = 4356
CMD_GAME_USER_RECONN = 4357

