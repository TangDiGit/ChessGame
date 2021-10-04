--数据走势图数据结构
CtrlDZNZ_Data = {}

--数据 连续未出局数记录
Data_ContinuityNotOut = 
{
	duiA = 0,				--对A连续未出
	hulu = 0,				--葫芦连续未出
	tonghuasitiao = 0,		--(同花顺四条皇家)连续未出次数
}

--胜负统计次数
Data_WinOrLoser = 
{
	red_win = 0,			--红方赢的次数
	pingshou = 0,			--平手赢的次数
	blue_win = 0,			--蓝方赢的次数
	tonghualianpai_win = 0,	--同花连牌赢的次数
	duiA_win = 0,			--对A赢的次数
	hulu_win = 0,			--葫芦赢的次数
	jingang_win = 0,		--金刚赢的次数
}

--手牌记录
Data_HandCards = 
{

	lastcards = nil,		--最后手牌
	lasttimer = nil,		--最后时间
	totalscore = nil,		--最后总分数
	userinfos = nil,		--玩家列表
}

--游戏牌型记录
Data_GameCardRecord =
{
	lastcards = nil,		--最后手牌
	lasttimer = nil,		--最后时间
	totalscore = nil,		--最后总分数
	userinfos = nil,		--玩家列表
}

-- 金刚记录
Data_JinGangRecord = {}

-- 桌面牌局走势
Data_GameTrend = {}

-- 弹窗牌局走势
Data_CardGaneTrend = {}

-- (同花)前几局输赢
Data_sptonghuarecords = {count= nil,data={}}
-- (连牌)前几局输赢
Data_splianpairecords = {count= nil,data={}}
-- (对子)前几局输赢
Data_spduizirecords = {count= nil,data={}}
-- (同花连牌)前几局输赢
Data_spthlianpairecords = {count= nil,data={}}
-- (对A)前几局输赢
Data_spduiarecords = {count= nil,data={}}
-- (高牌一对)前几局输赢
Data_gaopaiyiduirecords = {count= nil,data={}}
-- (两对)前几局输赢
Data_lianduirecords = {count= nil,data={}}
-- (三条顺子同花)前几局输赢
Data_st_sz_threcords = {count= nil,data={}}
-- (葫芦)前几局输赢
Data_hulurecords = {count= nil,data={}}
-- (同花顺四条皇家)前几局输赢
Data_four_ths_hjrecords = {count= nil,data={}}

return CtrlDZNZ_Data