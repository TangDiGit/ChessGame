CtrlDZNZ_UIDefine = {}
local this = CtrlDZNZ_UIDefine
local NetMsg = nil
local MainUI = nil
local is_openLeftMenu = false
local betscore = 0


UI_BetAre = 
{
	red_win = nil,
	blue_win = nil,
	pingshou = nil,
	sp_tonghua = nil,
	sp_lianpai = nil,
	sp_duizi = nil,
	sp_tonghualianpai = nil,
	sp_duiA = nil,
	sp_gaopai = nil,
	sp_liangdui = nil,
	sp_santiao = nil,
	sp_hulu = nil,
	sp_jingang = nil,
}

UI_WarTip =
{
    GotoWar = nil,          -- 出战
    MakeWar = nil,          -- 开战
}

UI_downPlayers =
{
    player0 = {com = nil,isflag = false},          -- head1
    player1 = {com = nil,isflag = false},          -- head2
    player2 = {com = nil,isflag = false},          -- head3
    player3 = {com = nil,isflag = false},          -- head4
    player4 = {com = nil,isflag = false},          -- head5
    player5 = {com = nil,isflag = false},          -- head6
    player6 = {com = nil,isflag = false},          -- head7
    player7 = {com = nil,isflag = false},          -- head8
}

UI_upPlayers =
{
    seat0 = nil,          -- sit1
    seat1 = nil,          -- sit2
    seat2 = nil,          -- sit3
    seat3 = nil,          -- sit4
    seat4 = nil,          -- sit5
    seat5 = nil,          -- sit6
    seat6 = nil,          -- sit7
    seat7 = nil,          -- sit8
}

UI_CardTyoe = 
{
    Left_CardType = nil,    --左边牌型
    Right_CardType = nil,   --右边牌型
}

UI_LeftFunc = 
{
    btn_xiala = nil,        --左上角下拉按钮
    btn_huanzhuo = nil,     --左上角换桌按钮
    btn_standUp = nil,      --左上角站起按钮
    btn_tuichu = nil,       --左上角退出按钮
    left_bg = nil,          --左上角下拉菜单背景

}

UI_Tip = 
{
    tipText = nil,          --开牌/发牌提示文字内容
    tipBg = nil,            --开牌/发牌提示背景图
}

UI_Card = 
{
    left_card_1 = nil,
    left_card_2 = nil,
    middle_card_1 = nil,
    middle_card_2 = nil,
    middle_card_3 = nil,
    middle_card_4 = nil,
    middle_card_5 = nil,
    right_card_1 = nil,
    right_card_2 = nil,
}

UI_BetButton = 
{
    btn_bet1 = nil,
    btn_bet2 = nil,
    btn_bet3 = nil,
    btn_bet4 = nil,
}

UI_OtherFunc = 
{
    btn_allWanJia = nil,
    btnDZNZ_Data = nil,
    mask = nil,
    topDian = nil,
    star = nil,
    winscore = nil
}

function this:Init_UI(content,dznz_net,mainUI)
    -- body
    InitUI_BetAre(content) --初始化下注区域ui
    InitUI_War(content) --初始化开始下注，结束下注提示
    InitUI_Head(content)    --初始化上座玩家
    InitUI_CardType(content)    --初始化牌型
    InitUI_Func(content)    --初始化左上角下拉框
    InitUI_Tip(content) --初始化开牌/发牌文字提示
    InitUI_Card(content)    --初始化所有的牌型
    --InitUI_BetButton(content)   --初始化可以下注的4个按钮
    InitUI_OtherFunc(content)   --初始化玩家列表，走势图按钮
    NetMsg = dznz_net   --协议
    MainUI = mainUI --ui
end

--初始化下注区域
function InitUI_BetAre(content)
    -- local group = content:GetChild('BetAreaGroup')

    UI_BetAre['red_win'] = content:GetChild('betArea_RedWin')
    UI_BetAre['blue_win'] = content:GetChild('betArea_BlueWin')
    UI_BetAre['pingshou'] = content:GetChild('betArea_Draw')

    UI_BetAre['sp_tonghua'] = content:GetChild('betArea_TongHua')
    UI_BetAre['sp_lianpai'] = content:GetChild('betArea_LianPai')
    UI_BetAre['sp_duizi'] = content:GetChild('betArea_DuiZi')
    UI_BetAre['sp_tonghualianpai'] = content:GetChild('betArea_THLP') 
    UI_BetAre['sp_duiA'] = content:GetChild('betArea_DuiA') 

    UI_BetAre['sp_gaopai'] = content:GetChild('betArea_GaoPai')
    UI_BetAre['sp_liangdui'] = content:GetChild('betArea_LiangDui')
    UI_BetAre['sp_santiao'] = content:GetChild('betArea_SanTiao')
    UI_BetAre['sp_hulu'] = content:GetChild('betArea_HuLu')
    UI_BetAre['sp_jingang'] = content:GetChild('betArea_JinGang')

    for k,v in pairs(UI_BetAre) do
        local key_name = k
        v:GetChild('txtOtherScore').visible = false
        v:GetChild('txtSelfScore').visible = false
        v:GetChild('txtAreaInfo').visible = false
        v:GetChild('imgSelfScorebg').visible = false
        v:GetChild('imgOtherScorebg').visible = false
        v:GetChild('tend1').visible = false
        v:GetChild('tend2').visible = false
        v:GetChild('tend3').visible = false
        v:GetChild('tend4').visible = false
        v:GetChild('tend5').visible = false
        v:GetChild('n91').onClick:Add(function ()
            click_BetArea(key_name)
        end)
    end
    --print('-------------- 初始化下注区域完成 --------------')
end

--初始化出战/开战提示
function InitUI_War(content)
    UI_WarTip['GotoWar'] = content:GetChild('imgGotowar')
    UI_WarTip['MakeWar'] = content:GetChild('imgMakewar')
    UI_WarTip['GotoWar'].visible = false
    UI_WarTip['MakeWar'].visible = false
    --print('-------------- 初始化出战/开战提示完成 --------------')
end

--初始化头像
function InitUI_Head(content)
    for i=0,7 do
        UI_downPlayers['player'..i].com = content:GetChild('head'..i)
        UI_downPlayers['player'..i].isflag = false
        UI_downPlayers['player'..i].com.visible = false
        UI_upPlayers['seat'..i] = content:GetChild('sit'..i)
        UI_upPlayers['seat'..i].visible = false
        UI_upPlayers['seat'..i].onClick:Add(function ()
            click_btnSit(i)
        end)
    end
    -- for i=1,8 do
    --     content:GetChild('head'..i).visible = false
    --     content:GetChild('sit'..i).visible = false
    -- end

    --print('-------------- 初始化头像完成 --------------')
end

--初始化牌型
function InitUI_CardType(content)
    -- body
    UI_CardTyoe['Left_CardType'] = content:GetChild('leftCardType')
    UI_CardTyoe['Right_CardType'] = content:GetChild('rightCardType')

    UI_CardTyoe['Left_CardType'].visible = false
    UI_CardTyoe['Right_CardType'].visible = false
    --print('-------------- 初始化牌型完成 --------------')   
end

--初始化左上角
function InitUI_Func(content)
    UI_LeftFunc['btn_xiala'] = content:GetChild('btnXiaLa') 
    UI_LeftFunc['btn_huanzhuo'] = content:GetChild('btnHuan')
    UI_LeftFunc['btn_standUp'] = content:GetChild('btnUp')
    UI_LeftFunc['btn_tuichu'] = content:GetChild('btnTuiChu')
    UI_LeftFunc['left_bg'] = content:GetChild('n42')

----------------------------------------------------------------------------

    UI_LeftFunc['btn_xiala'].visible = true
    UI_LeftFunc['btn_huanzhuo'].visible = false
    UI_LeftFunc['btn_standUp'].visible = false
    UI_LeftFunc['btn_tuichu'].visible = false
    UI_LeftFunc['left_bg'].visible = false

    is_openLeftMenu = false
    UI_LeftFunc['btn_xiala'].onClick:Add(function ()
        click_LeftMenu()
    end)

    UI_LeftFunc['btn_huanzhuo'].onClick:Add(function ()
        -- body
    end)

    UI_LeftFunc['btn_standUp'].onClick:Add(function ()
        -- body
        click_StandUp()
    end)

    UI_LeftFunc['btn_tuichu'].onClick:Add(function ()
        click_ExitRoom()
    end)
    --print('-------------- 初始化左上角下拉菜单完成 --------------')
end

--初始化开牌/发牌提示
function InitUI_Tip(content)
    UI_Tip['tipText'] = content:GetChild('txtOpenCard')
    UI_Tip['tipBg'] = content:GetChild('openCard_BG')

    ----------------------------------------------------------------------------

    UI_Tip['tipText'].visible = false
    UI_Tip['tipBg'].visible = false
    --print('-------------- 初始化开牌/发牌提示完成 --------------')
end

--初始化 左 - 中 - 右牌
function InitUI_Card(content)
    UI_Card['left_card_1'] = content:GetChild('left_card1')
    UI_Card['left_card_2'] = content:GetChild('left_card2')
    UI_Card['middle_card_1'] = content:GetChild('middle_card1')
    UI_Card['middle_card_2'] = content:GetChild('middle_card2')
    UI_Card['middle_card_3'] = content:GetChild('middle_card3')
    UI_Card['middle_card_4'] = content:GetChild('middle_card4')
    UI_Card['middle_card_5'] = content:GetChild('middle_card5')
    UI_Card['right_card_1'] = content:GetChild('right_card1')
    UI_Card['right_card_2'] = content:GetChild('right_card2')

    ----------------------------------------------------------------------------
    UI_Card['left_card_1'].visible = false
    UI_Card['left_card_2'].visible = false
    UI_Card['middle_card_1'].visible = false
    UI_Card['middle_card_2'].visible = false
    UI_Card['middle_card_3'].visible = false
    UI_Card['middle_card_4'].visible = false
    UI_Card['middle_card_5'].visible = false
    UI_Card['right_card_1'].visible = false
    UI_Card['right_card_2'].visible = false
    for k,v in pairs(UI_Card) do
        v:GetChild('mask').visible = false
    end
    --print('-------------- 初始化 左 - 中 - 右牌完成 --------------')
end

--初始化选择下注按钮完成
function this:InitUI_BetButton(content)
    UI_BetButton['btn_bet1']  = content:GetChild('btnXiaZhu1')
    UI_BetButton['btn_bet2']  = content:GetChild('btnXiaZhu2')
    UI_BetButton['btn_bet3']  = content:GetChild('btnXiaZhu3')
    UI_BetButton['btn_bet4']  = content:GetChild('btnXiaZhu4')
    --betscore
    --local index = 1
    -- for k,v in pairs(UI_BetButton) do
    --     v:GetChild('title').text = tab_betScore[index]
    --     v.onClick:Add(function ()
    --         click_BetScore(10)
    --     end)
    --     index = index + 1
    -- end
    for i, v in ipairs(tab_betScore) do
        UI_BetButton['btn_bet'..i]:GetChild('title').text = formatVal(tonumber(v))
        UI_BetButton['btn_bet'..i].onClick:Add(function ()
            click_BetScore(v)
        end)
    end
    UI_BetButton['btn_bet1'].selected = true -- 默认选中第一个
    click_BetScore(tab_betScore[1])
    --print('-------------- 初始化选择下注按钮完成 --------------')
end

--初始化其他功能
function InitUI_OtherFunc(content)
    UI_OtherFunc['btn_allWanJia']  = content:GetChild('btnWanJia')
    UI_OtherFunc['btnDZNZ_Data']  = content:GetChild('btnDZNZ_Data')
    UI_OtherFunc['mask']  = content:GetChild('mask')
    UI_OtherFunc['topDian']  = content:GetChild('topDian')
    UI_OtherFunc['star']  = content:GetChild('star')
    UI_OtherFunc['winscore']  = content:GetChild('winscore')
    ----------------------------------------------------------------------------
    UI_OtherFunc['btn_allWanJia'].onClick:Add(function ()
        -- body
        click_AllPlayer()
    end)
    UI_OtherFunc['btnDZNZ_Data'].onClick:Add(function ()
        click_DZNZ_Data()
    end)
    UI_OtherFunc['mask'].visible = false
    UI_OtherFunc['winscore'].visible = false
    --print('-------------- 初始化其他功能完成 --------------')
end

--获取UI 下注区域
function this:Get_UIBetArea(area_index)
    if area_index == 0 then
        return UI_BetAre['red_win']             --红色区域
    elseif area_index == 1 then
        return UI_BetAre['blue_win']            --蓝色区域
    elseif area_index == 2 then            
        return UI_BetAre['pingshou']            --平手区域
    elseif area_index == 3 then
        return UI_BetAre['sp_tonghua']          --同花区域
    elseif area_index == 4 then
        return UI_BetAre['sp_lianpai']          --连牌区域
    elseif area_index == 5 then
        return UI_BetAre['sp_duizi']            --对子区域
    elseif area_index == 6 then
        return UI_BetAre['sp_tonghualianpai']   --同花连牌区域
    elseif area_index == 7 then
        return UI_BetAre['sp_duiA']             --对A区域
    elseif area_index == 8 then
        return UI_BetAre['sp_gaopai']           --高牌区域
    elseif area_index == 9 then
        return UI_BetAre['sp_liangdui']         --连对区域
    elseif area_index == 10 then
        return UI_BetAre['sp_santiao']          --三条区域
    elseif area_index == 11 then
        return UI_BetAre['sp_hulu']             --葫芦区域
    elseif area_index == 12 then
        return UI_BetAre['sp_jingang']          --金刚区域
    end
end

-------------------------------- button click ------------------------------

-- 点击左上角菜单按钮
function click_LeftMenu()
    if is_openLeftMenu == false then
        is_openLeftMenu = true
    elseif is_openLeftMenu ==  true then
        is_openLeftMenu = false
    end
    UI_LeftFunc['btn_huanzhuo'].visible = is_openLeftMenu
    UI_LeftFunc['btn_standUp'].visible = is_openLeftMenu
    UI_LeftFunc['btn_tuichu'].visible = is_openLeftMenu
    UI_LeftFunc['left_bg'].visible = is_openLeftMenu
end

-- 点击上座按钮
function click_btnSit(index)   

    NetMsg.req_ClientSitChair(index)
end

-- 点击换桌
function click_HuanZhuo()
    -- body
end

-- 点击下注区域
function click_BetArea(betarea_name)
    if NetMsg.GetCanPlaceJetton() then
        if betscore == 0 then
            --请选择下注区域
            UIManager.AddPopTip({strTit='请选择下注的筹码'})
            return
        end
        NetMsg.req_PlaceJetton(tab_betArea[betarea_name], betscore)
    else
        UIManager.AddPopTip({strTit='暂时不能下注'})
    end
end

-- 点击选择下注分数
function click_BetScore(bet_score)
    betscore = bet_score
end

--请求离开座位
function click_StandUp()
    NetMsg.req_StandUp()
end

--请求退出房间
function click_ExitRoom()
    click_LeftMenu()
    F_SoundManager.instance:StopPlayEffect()
    NetMsg.req_ExitRoom()
end


--点击查询所有玩家
function click_AllPlayer()
    NetMsg.req_GetUserList()
end

--点击查询德州牛仔走势数据
function click_DZNZ_Data()
    NetMsg.req_ClientHistoryRecords()
    NetMsg.req_GetBigAreaWinInfo(0)     --手牌记录
    NetMsg.req_GetBigAreaWinInfo(1)     --牌型记录
    NetMsg.req_GetJinGangInfo()         --金刚记录
    -- UIManager.Show('CtrlDZNZ_DataView')
end

--上座玩家 根据作为index设置头像信息和空位按钮的显隐 
--是否显示上座玩家
function this:showHead(index,isflag)
    UI_downPlayers['player'..index].com.visible = isflag
    UI_downPlayers['player'..index].isflag = isflag
    UI_upPlayers['seat'..index].visible = not isflag
end

--设置上座玩家信息
function this:setDownPlayers(msg)
    UI_downPlayers['player'..msg.sitindex].com:GetChild('icon').asLoader.url = msg.headurl or ""
    UI_downPlayers['player'..msg.sitindex].com:GetChild('gold').text = formatVal(tonumber(msg.score)) or ""
end

--更新玩家的金币数目
function this:UpdatePlayersCoin(sit_index, sit_score)
    UI_downPlayers['player'..sit_index].com:GetChild('gold').text = formatVal(tonumber(sit_score))
end

--清除整个玩家信息表
function this:ClearDownPlayers(msg)
    for  i=0,7 do 
        UI_downPlayers['player'..i].com:GetChild('icon').asLoader.url = "" 
        UI_downPlayers['player'..i].com:GetChild('gold').text = "" 
        this:showHead(i,false)
    end
end

--设置单个上座玩家的信息
function this:UpdataDownPlayers(msg)
    --设置上座玩家显示
    for i,v in ipairs(msg) do  
        if v.sitindex ~= nil then 
            this:setDownPlayers(v)     
            this:showHead(v.sitindex,true)
        end    
    end
    --设置其余座位为空座
    for  i=0,7 do 
        if not UI_downPlayers['player'..i].isflag then 
            this:showHead(i,false)           
        end
    end
end

--数字类型单位转换
function changeValue(value)
    if value<10000 then 
        return value
    end
    local m = value/10000
    return m.."万"
end

return CtrlDZNZ_UIDefine