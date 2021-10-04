poker={}
pokerCard={
    0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D, --方块 A - K
    0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D, --梅花 A - K
    0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D, --红桃 A - K
    0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D, --黑桃 A - K
}
PokerConversionStr={
    [0x01]='方块A',
    [0x02]='方块2',
    [0x03]='方块3',
    [0x04]='方块4',
    [0x05]='方块5',
    [0x06]='方块6',
    [0x07]='方块7',
    [0x08]='方块8',
    [0x09]='方块9',
    [0x0A]='方块10',
    [0x0B]='方块J',
    [0x0C]='方块Q',
    [0x0D]='方块K',

    [0x11]='梅花A',
    [0x12]='梅花2',
    [0x13]='梅花3',
    [0x14]='梅花4',
    [0x15]='梅花5',
    [0x16]='梅花6',
    [0x17]='梅花7',
    [0x18]='梅花8',
    [0x19]='梅花9',
    [0x1A]='梅花10',
    [0x1B]='梅花J',
    [0x1C]='梅花Q',
    [0x1D]='梅花K',

    [0x21]='红桃A',
    [0x22]='红桃2',
    [0x23]='红桃3',
    [0x24]='红桃4',
    [0x25]='红桃5',
    [0x26]='红桃6',
    [0x27]='红桃7',
    [0x28]='红桃8',
    [0x29]='红桃9',
    [0x2A]='红桃10',
    [0x2B]='红桃J',
    [0x2C]='红桃Q',
    [0x2D]='红桃K',

    [0x31]='黑桃A',
    [0x32]='黑桃2',
    [0x33]='黑桃3',
    [0x34]='黑桃4',
    [0x35]='黑桃5',
    [0x36]='黑桃6',
    [0x37]='黑桃7',
    [0x38]='黑桃8',
    [0x39]='黑桃9',
    [0x3A]='黑桃10',
    [0x3B]='黑桃J',
    [0x3C]='黑桃Q',
    [0x3D]='黑桃K',
}
PokerConversionStr2={
    [0x01]='A',
    [0x02]='2',
    [0x03]='3',
    [0x04]='4',
    [0x05]='5',
    [0x06]='6',
    [0x07]='7',
    [0x08]='8',
    [0x09]='9',
    [0x0A]='10',
    [0x0B]='J',
    [0x0C]='Q',
    [0x0D]='K',

    [0x11]='A',
    [0x12]='2',
    [0x13]='3',
    [0x14]='4',
    [0x15]='5',
    [0x16]='6',
    [0x17]='7',
    [0x18]='8',
    [0x19]='9',
    [0x1A]='10',
    [0x1B]='J',
    [0x1C]='Q',
    [0x1D]='K',

    [0x21]='A',
    [0x22]='2',
    [0x23]='3',
    [0x24]='4',
    [0x25]='5',
    [0x26]='6',
    [0x27]='7',
    [0x28]='8',
    [0x29]='9',
    [0x2A]='10',
    [0x2B]='J',
    [0x2C]='Q',
    [0x2D]='K',

    [0x31]='A',
    [0x32]='2',
    [0x33]='3',
    [0x34]='4',
    [0x35]='5',
    [0x36]='6',
    [0x37]='7',
    [0x38]='8',
    [0x39]='9',
    [0x3A]='10',
    [0x3B]='J',
    [0x3C]='Q',
    [0x3D]='K',
}
function printPoker(theData)
	print(PokerConversionStr[theData])
end


PokerUrlMap={
    [0]='ui://poker/card_bg1',

    [0x01]='ui://poker/card_fangA',
    [0x02]='ui://poker/card_fang02',
    [0x03]='ui://poker/card_fang03',
    [0x04]='ui://poker/card_fang04',
    [0x05]='ui://poker/card_fang05',
    [0x06]='ui://poker/card_fang06',
    [0x07]='ui://poker/card_fang07',
    [0x08]='ui://poker/card_fang08',
    [0x09]='ui://poker/card_fang09',
    [0x0A]='ui://poker/card_fang10',
    [0x0B]='ui://poker/card_fangJ',
    [0x0C]='ui://poker/card_fangQ',
    [0x0D]='ui://poker/card_fangK',

    [0x11]='ui://poker/card_meiA',
    [0x12]='ui://poker/card_mei02',
    [0x13]='ui://poker/card_mei03',
    [0x14]='ui://poker/card_mei04',
    [0x15]='ui://poker/card_mei05',
    [0x16]='ui://poker/card_mei06',
    [0x17]='ui://poker/card_mei07',
    [0x18]='ui://poker/card_mei08',
    [0x19]='ui://poker/card_mei09',
    [0x1A]='ui://poker/card_mei10',
    [0x1B]='ui://poker/card_meiJ',
    [0x1C]='ui://poker/card_meiQ',
    [0x1D]='ui://poker/card_meiK',

    [0x21]='ui://poker/card_hongA',
    [0x22]='ui://poker/card_hong02',
    [0x23]='ui://poker/card_hong03',
    [0x24]='ui://poker/card_hong04',
    [0x25]='ui://poker/card_hong05',
    [0x26]='ui://poker/card_hong06',
    [0x27]='ui://poker/card_hong07',
    [0x28]='ui://poker/card_hong08',
    [0x29]='ui://poker/card_hong09',
    [0x2A]='ui://poker/card_hong10',
    [0x2B]='ui://poker/card_hongJ',
    [0x2C]='ui://poker/card_hongQ',
    [0x2D]='ui://poker/card_hongK',

    [0x31]='ui://poker/card_heiA',
    [0x32]='ui://poker/card_hei02',
    [0x33]='ui://poker/card_hei03',
    [0x34]='ui://poker/card_hei04',
    [0x35]='ui://poker/card_hei05',
    [0x36]='ui://poker/card_hei06',
    [0x37]='ui://poker/card_hei07',
    [0x38]='ui://poker/card_hei08',
    [0x39]='ui://poker/card_hei09',
    [0x3A]='ui://poker/card_hei10',
    [0x3B]='ui://poker/card_heiJ',
    [0x3C]='ui://poker/card_heiQ',
    [0x3D]='ui://poker/card_heiK',
}

--扑克类型
CT_SINGLE=1 --单牌类型
CT_ONE_LONG=2 --对子类型
CT_TWO_LONG=3 --两对类型
CT_THREE_TIAO=4 --三条类型
CT_SHUN_ZI=5 --顺子类型
CT_TONG_HUA=6 --同花类型
CT_HU_LU=7 --葫芦类型
CT_TIE_ZHI=8 --铁支类型
CT_TONG_HUA_SHUN=9 --同花顺型
CT_KING_TONG_HUA_SHUN=10 --皇家同花顺

CT_Chinese_Dic={
    [0]='',
    [CT_SINGLE]='高牌',--单牌
    [CT_ONE_LONG]='一对',--对子
    [CT_TWO_LONG]='两对',--两对
    [CT_THREE_TIAO]='三条',
    [CT_SHUN_ZI]='顺子',
    [CT_TONG_HUA]='同花',
    [CT_HU_LU]='葫芦',
    [CT_TIE_ZHI]='金刚',
    [CT_TONG_HUA_SHUN]='同花顺',
    [CT_KING_TONG_HUA_SHUN]='皇家同花顺',
}

--场景恢复状态
USER_STATUS_GAME_NULL    =   0x00        --没有状态
USER_STATUS_GAME_QIPAI    =   0x01        
USER_STATUS_GAME_GENZHU    =   0x02        
USER_STATUS_GAME_GUOPAI    =   0x03        
USER_STATUS_GAME_JIAZHU    =   0x04        
USER_STATUS_GAME_ALLIN    =   0x05   

USER_STATUS_GAME_DIC={
    [USER_STATUS_GAME_NULL]='nil',
    [USER_STATUS_GAME_QIPAI]='弃牌',
    [USER_STATUS_GAME_GENZHU]='跟注',
    [USER_STATUS_GAME_GUOPAI]='过牌',
    [USER_STATUS_GAME_JIAZHU]='加注',
    [USER_STATUS_GAME_ALLIN]='allin',
}

USER_STATUS_GAME__SOUND_DIC={
    [USER_STATUS_GAME_NULL]='nil',
    [USER_STATUS_GAME_QIPAI]='peopleTalk_cancle',
    [USER_STATUS_GAME_GENZHU]='peopleTalk_follow',
    [USER_STATUS_GAME_GUOPAI]='peopleTalk_Pass',
    [USER_STATUS_GAME_JIAZHU]='peopleTalk_addChip',
    [USER_STATUS_GAME_ALLIN]='peopleTalk_allin',
}

DuanYuMap={
	[1]={1,'快点啊，我等的花儿都谢啦','ptm_yy4_0','ptw_yy4_0'},
	[2]={2,'一点小钱~拿去喝茶吧~','ptm_yy11_0','ptw_yy11_0'},
	[3]={3,'大家好，很高兴见到各位！','ptm_yy13_0','ptw_yy13_0'},
	[4]={4,'风水轮流转，底裤都输光啦！','ptm_yy16_0','ptw_yy16_0'},
	[5]={5,'一点小钱，那都不是事儿','ptm_yy18_0','ptw_yy18_0'},
	[6]={6,'大家一起浪起来','ptm_yy19_0','ptw_yy19_0'},
	[7]={7,'哇！你真是个天生的演员','ptm_yy21_0','ptw_yy21_0'},
	[8]={8,'有没有天理？有没有王法？！','ptm_yy10_0','ptw_yy10_0'},
    [9]={9,'不要走，决战到天亮！','ptm_yy22_0','ptw_yy22_0'},
    [10]={10,'搏一搏，单车变摩托！','ptm_yy3_0','ptw_yy3_0'},
    [11]={11,'时间就是金钱，我的朋友','ptm_yy5_0','ptw_yy5_0'},
    [12]={12,'别看牌，我们闷到底','ptw_yy120_0','ptw_yy120_0'},
    [13]={13,'不要偷鸡，我的牌很大','ptw_yy130_0','ptw_yy130_0'},
    [14]={14,'你的牌打得也忒好了','ptw_yy140_0','ptw_yy140_0'},
    [15]={15,'输光啦，洗洗睡了','ptw_yy150_0','ptw_yy150_0'},
    [16]={16,'天灵灵地灵灵太上老君快显灵','ptw_yy160_0','ptw_yy160_0'},
    [17]={17,'我就喜欢和你们反着压！','ptw_yy170_0','ptw_yy170_0'},
    [18]={18,'我弃牌了','ptw_yy180_0','ptw_yy180_0'},
    [19]={19,'这把我有信心，跟我一起下','ptw_yy190_0','ptw_yy190_0'},
}

DefaultIcon = 'ui://hall/defaultIcon'

HeadIconConfig =
{
    { id = 1, name = "头像1", url = 'ui://hall/head_01' },
    { id = 2, name = "头像2", url = 'ui://hall/head_02' },
    { id = 3, name = "头像3", url = 'ui://hall/head_03' },
    { id = 4, name = "头像4", url = 'ui://hall/head_04' },
    { id = 5, name = "头像5", url = 'ui://hall/head_05' },
    { id = 6, name = "头像6", url = 'ui://hall/head_06' },
    { id = 7, name = "头像7", url = 'ui://hall/head_07' },
    { id = 8, name = "头像8", url = 'ui://hall/head_08' },
    { id = 9, name = "头像9", url = 'ui://hall/head_09' },
    { id = 10, name = "头像10", url = 'ui://hall/head_10' },
}

--背包道具表 serverID服务器控制
Bag_Config =
{
    [0] = {serverID=1001,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url=''},
    [1]={serverID=1001,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame01'},
    [2]={serverID=1002,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame02'},
    [3]={serverID=1003,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame03'},
    [4]={serverID=1004,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame04'},
    [5]={serverID=1005,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame05'},
    [6]={serverID=1006,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame06'},
    [7]={serverID=1007,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame07'},
    [8]={serverID=1008,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame08'},
    [9]={serverID=1009,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame09'},
    [10]={serverID=1010,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame10'},
    [11]={serverID=1011,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame11'},
    [12]={serverID=1012,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame12'},
    [13]={serverID=1013,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame13'},
    [14]={serverID=1014,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame14'},
    [15]={serverID=1015,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame15'},
    [16]={serverID=1016,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame16'},
    [17]={serverID=1017,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame17'},
    [18]={serverID=1018,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame18'},
    [19]={serverID=1019,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame19'},
    [20]={serverID=1020,name="头像框",is_frame=true,des="1.此头像相框，vip用户可以使用。\r\n2.点击相框，直接佩戴。\r\n3.vip到期后，将无法使用相框功能。",url='ui://hall/headFrame20'},

    [10001]={serverID=10001,name="喇叭",is_send=true,sort=0,des="在游戏房间牌桌上使用,点击聊天框,发送内容,全服都可以看到。",url='ui://hall/item2'},
    [10002]={serverID=10002,name="踢人卡",is_send=true,sort=0,des="1.VIP用户才能使用。\r\n2.玩家在游戏中,如对其他玩家不满意,可使用踢人卡,将其踢出房间。\r\n3.必须牌桌中玩家一半以上同意,才能将其踢出房间。",url='ui://hall/item0'},
    [10003]={serverID=10003,name="VIP周卡",is_send=true,sort=3,des="1.修改昵称权限。\r\n2.使用后获得20万金币奖励。\r\n3.每个ID只能使用一次。\r\n4.拥有专属聊天表情，进场特效。\r\n5.拥有开设私人房权限。\r\n6.使用踢人卡权限。",url='ui://hall/item3'},
    [10004]={serverID=10004,name="VIP月卡",is_send=true,sort=2,des="1.修改昵称权限。\r\n2.拥有专属聊天表情包。\r\n3.拥有专属进场特效以及头像框。\r\n4.拥有开始私人房权限。\r\n5.每月赠送踢人卡3张及全服喇叭3个。\r\n6.使用踢人卡权限。",url='ui://hall/item1'},
    -- 护身，查看，牛逼卡等
    [10005] = {serverID=10005,is_card=true,name="查看卡",des="1.在（自己和玩家）弃牌的情况下。\r\n2.针对某个玩家使用查看卡，查看对方手牌。\r\n3.手牌只能提供给使用者查看。\r\n4.拥有VIP月卡等级才能使用。\r\n5.一次牌局中最多使用2次。",url='ui://hall/item_chakan'},
    [10006] = {serverID=10006,is_card=true,name="刷新卡",des="1.在玩家拿到手牌后，未进入到转牌前。\r\n2.可以使用刷新卡+牛逼卡，重发手牌。\r\n3.一牌局中只能使用一次。\r\n4.VIP月卡用户才能使用。",url='ui://hall/item_shuaxin'},
    [10007] = {serverID=10007,is_card=true,name="牛逼卡",des="1.在玩家拿到手牌后，未进入到转牌前。\r\n2.可以使用刷新卡+牛逼卡，重发手牌。\r\n3.一牌局中只能使用一次。\r\n4.VIP月卡用户才能使用。",url='ui://hall/item_niubi'},
    [10008] = {serverID=10008,is_card=true,is_rebirth=true,name="重生卡",des="1.拥有VIP周卡/月卡用户，直接点击使用。\r\n2.每次使用后可以清除4个数据。\r\n3.最大赢取，牌局数，弃牌率，胜率将为0。",url='ui://hall/item_chongsheng'},
    [10009] = {serverID=10009,is_card=true,is_protect=true,name="护身卡",des="1.拥有VIP周卡或月卡用户。\r\n2.弃牌后禁止查看我的手牌。\r\n3.点击使用，在24小时内有效。\r\n4.德州牌局对战中获得。",url='ui://hall/item_husheng'},
    [10010] = {serverID=10010,is_card=true,name="抽奖卡",des="1.拥有VIP周卡/月卡用户。\r\n2.在抽奖转盘里面使用。\r\n3.每日最多使用10张。\r\n4.此卡不能转让，仅限自己使用。",url='ui://hall/item_choujiang'},
    [10011] = {serverID=10011,is_card=true,is_send=true,sort=1,name="比赛卡",des="1.300万奖金比赛卡。\r\n2.比赛卡可以抵扣参赛费+服务费。\r\n3.比赛场里使用。\r\n4.使用后不参与比赛，不退卡。",url='ui://hall/item_bisai'},
    [10012] = {serverID=10012,is_card=true,is_phone_bill=true,name="话费卡1元卡",des="1.话费卡面额为1元。\r\n2.凑够50元话费。\r\n3.可以点击兑换充值。\r\n4.德州对战牌局中随机获得不同面值话费卡。",url='ui://hall/item_huafei_01'},
    [10013] = {serverID=10013,is_card=true,is_phone_bill=true,name="话费卡2元卡",des="1.话费卡面额为2元。\r\n2.凑够50元话费。\r\n3.可以点击兑换充值。\r\n4.德州对战牌局中随机获得不同面值话费卡。",url='ui://hall/item_huafei_02'},
    [10014] = {serverID=10014,is_card=true,is_phone_bill=true,name="话费卡5元卡",des="1.话费卡面额为5元。\r\n2.凑够50元话费。\r\n3.可以点击兑换充值。\r\n4.德州对战牌局中随机获得不同面值话费卡。",url='ui://hall/item_huafei_05'},
    [10015] = {serverID=10015,is_card=true,is_phone_bill=true,name="话费卡10元卡",des="1.话费卡面额为10元。\r\n2.凑够50元话费。\r\n3.可以点击兑换充值。\r\n4.德州对战牌局中随机获得不同面值话费卡。",url='ui://hall/item_huafei_10'},
    [10016] = {serverID=10016,is_card=true,name="电影票比赛卡",des="1.电影票专属比赛卡。\r\n2.比赛卡可以抵扣参赛费+服务费。\r\n3.比赛场里使用。\r\n4.使用后不参与比赛，不退卡。",url='ui://hall/item_bisai'},
    [10017] = {serverID=10017,is_card=true,name="电影票",des="1.电影票为全国各大影院通用。\r\n2.电影票获取：凭专属参赛卡报名参赛。\r\n3.获得比赛名次就可以获得对应电影票。\r\n4.使用电影票联系客服兑换。",url='ui://hall/item_dianying'},
    [10018] = {serverID=10018,is_card=true,name="手机参赛卡",des="1.拥有此卡免费参加手机奖励比赛。\r\n2.获得比赛名次就可以获得对应的奖励。\r\n3.获得第一名手机奖励，联系客服人员进行兑换。",url='ui://hall/item_bisai'},
}

--game_type 0 金币 1 免费 2 实物
Match_Type =
{
    [1] = { name = "100万极速免费赛", name_index = 0, type_index = 1 },
    [2] = { name = "300万荣耀娱乐赛", name_index = 1, type_index = 0 },
    [3] = { name = "5000万精英大奖赛", name_index = 2, type_index = 0 },
    [4] = { name = "苹果11王者赛", name_index = 6, type_index = 2 },
    [5] = { name = "华为NOVA8王者赛", name_index = 5, type_index = 2 },
    [6] = { name = "小米11王者赛", name_index = 7, type_index = 2 },
    [7] = { name = "Oppo ACE2王者赛", name_index = 3, type_index = 2 },
    [8] = { name = "Vivo iQoo5王者赛", name_index = 4, type_index = 2 },
    [9] = { name = "电影票通用专场赛", name_index = 8, type_index = 2 },
    [10] = { name = "苹果11王者邀请赛", name_index = 9, type_index = 2 },
}

-- 苹果11 华为NOVA8 小米11 OppoACE2 VivoiQoo5
Match_Good =
{
     [1] = "苹果11",
     [2] = "华为NOVA8",
     [3] = "小米11",
     [4] = "OppoACE2",
     [5] = "VivoiQoo5",
     [6] = "电影票"
}

Match_Good_Unit =
{
    [1] = "部",
    [2] = "部",
    [3] = "部",
    [4] = "部",
    [5] = "部",
    [6] = "张",
}

Chinese_Num = { "一", "二", "三", "四", "五", "六", "七", "八", "九", "十" }

ChaseCount = { "10", "50", "100", "300", }

ChaseMoneyName = { "1000", "1万", "10万", "100万", }

ChaseMoneyValue = { "1000", "10000", "100000", "1000000", }

ChaseName = { [0] = "同花连牌", [1] = "葫芦", [2] = "对A", [3] = "金刚/同花顺/皇家", }

ChaseSend = { [0] = 6, [1] = 11, [2] = 7, [3] = 12, }

ChaseReceive = { [6] = 0, [11] = 1, [7] = 2 , [12] = 3, }

--商城道具表 serverID服务器控制
Shop_Config={
    [10002]={sort=1,serverID=10002,name="踢人卡",des="游戏内使用",url='ui://shop/jiaoyin'},
    [10001]={sort=2,serverID=10001,name="喇叭",des="喇叭",url='ui://shop/喇叭'},

    [10003]={sort=3,serverID=10003,name="VIP 周卡",des="添加VIP时长1周",url='ui://shop/周卡VIP'},
    [10004]={sort=4,serverID=10004,name="VIP 月卡",des="添加VIP时长1月",url='ui://shop/月卡vip'},

    [10005]={sort=5,serverID=10005,name="金币1万",des="金币1万",url='ui://shop/jb'},
    [10006]={sort=6,serverID=10006,name="金币5万",des="金币5万",url='ui://shop/jb'},
    [10007]={sort=7,serverID=10007,name="金币10万",des="金币10万",url='ui://shop/jb'},
    [10008]={sort=8,serverID=10008,name="金币50万",des="金币50万",url='ui://shop/jb'},
    [10009]={sort=9,serverID=10009,name="金币100万",des="金币100万",url='ui://shop/jb'},
}


--飞筹码
CM_Level={
    [1]={index=0,baseVal=5},--绿
    [2]={index=1,baseVal=10},--紫
    [3]={index=2,baseVal=20},--蓝
    [4]={index=3,baseVal=50},--黄
    [5]={index=4,baseVal=100},--红
}

--val 筹码数
--xiaoMang --小盲
function CalcFlyCM(val,xiaoMang)
    local _x=math.max(1,xiaoMang/CM_Level[1].baseVal)
    local _calcVal=val/_x
    local _cm_level=clone(CM_Level)

    
    local _cms={}
    while #_cm_level>0 and  _calcVal>0 do
        if _calcVal-_cm_level[#_cm_level].baseVal>=0 then
            _calcVal=_calcVal-_cm_level[#_cm_level].baseVal
            table.insert(_cms,_cm_level[#_cm_level].index)
        else
            table.remove(_cm_level)
        end
    end
    if #_cms<1 then
        table.insert(_cms,CM_Level[1].index)
    end
    
    --返回的数量9
    local _t={}
    for i,v in ipairs(_cms) do
        table.insert(_t,v)
        if #_t>=9 then
            return _t
        end
    end
    return _t
end

--猜手牌相关
DZ_Guess_GC_DUIZI=101 --对子
DZ_Guess_GC_TONGHUA=102 --同花
DZ_Guess_GC_AA=103 --AA
DZ_Guess_GC_KKQQ=104 --KKQQ
DZ_Guess_GC_A=105 --A
DZ_Guess_GC_A_K=106 --A_K

DZ_Guess_Dic={
    [DZ_Guess_GC_DUIZI]={'对子',15},
    [DZ_Guess_GC_TONGHUA]={'同花',2},
    [DZ_Guess_GC_AA]={'AA',200},
    [DZ_Guess_GC_KKQQ]={'KK或QQ',100},
    [DZ_Guess_GC_A]={'A',6},
    [DZ_Guess_GC_A_K]={'AK',18},
}

--百人场牌值转换器
--牌值说明
--2,   3,   4,   5,   6,   7,   8,   9,   10,  J,   Q,   K,   A
--0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D, 方块 2 - A
--0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D, 红桃 2 - A
--0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D, 梅花 2 - A
--0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D, 黑桃 2 - A

BaiRenPokerCardConversionMap={
    [0x01]=0x01,--1
    [0x02]=0x02,--2
    [0x03]=0x03,--3
    [0x04]=0x04,--4
    [0x05]=0x05,--5
    [0x06]=0x06,--6
    [0x07]=0x07,--7
    [0x08]=0x08,--8
    [0x09]=0x09,--9
    [0x0A]=0x0A,--10
    [0x0B]=0x0B,--J
    [0x0C]=0x0C,--Q
    [0x0D]=0x0D,--K

    [0x11]=0x11,--1
    [0x12]=0x12,--2
    [0x13]=0x13,--3
    [0x14]=0x14,--4
    [0x15]=0x15,--5
    [0x16]=0x16,--6
    [0x17]=0x17,--7
    [0x18]=0x18,--8
    [0x19]=0x19,--9
    [0x1A]=0x1A,--10
    [0x1B]=0x1B,--J
    [0x1C]=0x1C,--Q
    [0x1D]=0x1D,--K

    [0x21]=0x21,--1
    [0x22]=0x22,--2
    [0x23]=0x23,--3
    [0x24]=0x24,--4
    [0x25]=0x25,--5
    [0x26]=0x26,--6
    [0x27]=0x27,--7
    [0x28]=0x28,--8
    [0x29]=0x29,--9
    [0x2A]=0x2A,--10
    [0x2B]=0x2B,--J
    [0x2C]=0x2C,--Q
    [0x2D]=0x2D,--K

    [0x31]=0x31,--1
    [0x32]=0x32,--2
    [0x33]=0x33,--3
    [0x34]=0x34,--4
    [0x35]=0x35,--5
    [0x36]=0x36,--6
    [0x37]=0x37,--7
    [0x38]=0x38,--8
    [0x39]=0x39,--9
    [0x3A]=0x3A,--10
    [0x3B]=0x3B,--J
    [0x3C]=0x3C,--Q
    [0x3D]=0x3D,--K
    [0]=0,
}

CM_Level_BaiRen={
    [1]={val=1,resName='cm_1', url='ui://bairen/bi_hong'},
    [2]={val=5,resName='cm_5'},
    [3]={val=10,resName='cm_10'},
    [4]={val=50,resName='cm_50'},
    [5]={val=100,resName='cm_100'},
    [6]={val=500,resName='cm_500'},
    [7]={val=5000,resName='cm_5000'},
    [8]={val=10000,resName='cm_1w'},
    [9]={val=50000,resName='cm_5w'},
    [10]={val=100000,resName='cm_10w'},
    [11]={val=500000,resName='cm_50w'},
    [12]={val=1000000,resName='cm_100w'},
    [13]={val=5000000,resName='cm_500w'},
    [14]={val=10000000,resName='cm_1000w'},
    [15]={val=50000000,resName='cm_5000w'},
}

--根据一个数值计算出需要飞的筹码列表
function CalcFlyCMWithBaiRen(val, maxCount)
    local _t = { }
    local _calcVal = val
    maxCount = maxCount or 10
    --最多六个
    for i = 1, maxCount do
        local _isCalc = false
        for j = 15, 1, -1 do
            if not _isCalc and _calcVal >= CM_Level_BaiRen[j].val then
                _isCalc = true
                table.insert(_t, CM_Level_BaiRen[j])
                _calcVal = _calcVal - CM_Level_BaiRen[j].val
            end
        end
    end
    return _t
end       

--根据玩家的钱确定下注的档位
function CalcXiaZhuLevel(val)
    for i=#CM_Level_BaiRen,1,-1 do
        if val>=CM_Level_BaiRen[i].val then
            return i
        end
    end
end
