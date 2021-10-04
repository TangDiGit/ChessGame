NiuNiuCard = {}

-- 牛牛牌型赢的牌(url)
NN_CardUrlMap_Win = 
{
	[1] = 'ui://niuzai/7_1',		--单牌类型
	[2] = 'ui://niuzai/9_1',		--对子类型
	[3] = 'ui://niuzai/5_1',		--两对类型
	[4] = 'ui://niuzai/4_1',		--三条类型
	[5] = 'ui://niuzai/8_1',		--顺子类型
	[6] = 'ui://niuzai/2_1',		--同花类型
	[7] = 'ui://niuzai/3_1',		--葫芦类型
	[8] = 'ui://niuzai/1_1',		--铁支类型
	[9] = 'ui://niuzai/10_1',		--同花顺型
	[10] = 'ui://niuzai/6_1',		--皇家同花顺
}

-- 牛牛牌型输的牌(url)
NN_CardUrlMap_Lose = 
{
	[1] = 'ui://niuzai/7',		--单牌类型
	[2] = 'ui://niuzai/9',		--对子类型
	[3] = 'ui://niuzai/5',		--两对类型
	[4] = 'ui://niuzai/4',		--三条类型
	[5]=  'ui://niuzai/8',		--顺子类型
	[6] = 'ui://niuzai/2',		--同花类型
	[7] = 'ui://niuzai/3',		--葫芦类型
	[8] = 'ui://niuzai/1',		--铁支类型
	[9] = 'ui://niuzai/10',		--同花顺型
	[10] = 'ui://niuzai/6',		--皇家同花顺
}

return NiuNiuCard


-- #define CT_SINGLE					1									//单牌类型
-- #define CT_ONE_DOUBLE				2									//对子类型
-- #define CT_TWO_DOUBLE				3									//两对类型
-- #define CT_THREE_TIAO				4									//三条类型
-- #define	CT_SHUN_ZI					5									//顺子类型
-- #define CT_TONG_HUA					6									//同花类型
-- #define CT_HU_LU						7									//葫芦类型
-- #define CT_TIE_ZHI					8									//铁支类型
-- #define CT_TONG_HUA_SHUN				9									//同花顺型
-- #define CT_KING_TONG_HUA_SHUN		10									//皇家同花顺