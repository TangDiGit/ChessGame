--游戏内查看奖池信息
local ControllerBaiRenPrizePool = class("ControllerBaiRenPrizePool")
-- ControllerBaiRenPrizePool  -- ControllerPrizePool
--数字变化次数
local ChangeCount=15
--spine 动画
local tab_spineAnim =
{
    gamestart = nil,
}

function ControllerBaiRenPrizePool:Init()
    self.m_view=UIPackage.CreateObject('bairen','bairenPrizePoolView').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerBaiRenPrizePool')
    end)

    self.m_view:GetChild("btnStatistical").visible = false      --中奖统计
    self.m_view:GetChild("btnRules").visible = false            --规则

    --中奖记录
    self.m_view:GetChild("btnRecord"):GetChild('icon').url = 'ui://texas/viewbtnBg'
    self.m_view:GetChild("btnRecord").onClick:Add(function ()
        CtrlBaiRenNet.ShowJackPotContent()
    end)
    --数字滚动
    self.m_txtValue = self.m_view:GetChild('txtValue')
end

function ControllerBaiRenPrizePool:Show(arg)
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible=true
    --self.m_view:GetChild('bg').visible = true
    self:SetRolling(arg)
    self:InitSpineAnim()

    -- 这里请求玩家列表
    CtrlBaiRenNet.Req_GetBigWinPoolUser()
end

function ControllerBaiRenPrizePool:OnHide()
    self.m_view.visible=false
end

function ControllerBaiRenPrizePool:SetRolling(val)
    if self.m_timerRolling then
        self.m_timerRolling:Stop()
    end

    local v=val/ChangeCount
    local curr=0
    local showCurr=0
    local _c=0
    self.m_timerRolling=Timer.New(function ()
        curr=curr+v
        curr=math.min(curr,val)
        showCurr=math.floor(curr)
        self.m_txtValue.text=showCurr

        _c=_c+1
        if _c==ChangeCount then
            self.m_txtValue.text=val
        end
    end,0.01,ChangeCount)
    self.m_timerRolling:Start()
end

function ControllerBaiRenPrizePool:InitSpineAnim()
    local anim_gamestart = UIManager.SetDragonBonesAniObjPos3('jinbiObj',
            self.m_view:GetChild('aniPos'),Vector3.New(150,150,150),Vector3.New(0,340,0)).gameObject.transform:GetChild(0)
    anim_gamestart.gameObject:SetActive(false)
    tab_spineAnim['gamestart'] = anim_gamestart
    self:PlaySpine(tab_spineAnim['gamestart'],'shine_gold2',true)
end

-- 播放spine动画
function ControllerBaiRenPrizePool:PlaySpine(spine_anim,anim_name,is_loop)

    local skeleton_anim = spine_anim:GetComponent('Spine.Unity.SkeletonAnimation')
    skeleton_anim.skeleton:SetToSetupPose()
    skeleton_anim.state:ClearTracks()
    skeleton_anim.state:SetAnimation(0,anim_name,is_loop)
    spine_anim.gameObject:SetActive(true)

    -- if anim_name == 'kaishi' then
    --     UI_OtherFunc['mask'].visible = true
    --     skeleton_anim.state.Complete = skeleton_anim.state.Complete - self.anim_GameStartEnd
    --     skeleton_anim.state.Complete = skeleton_anim.state.Complete + self.anim_GameStartEnd
    --     F_SoundManager.instance:PlayEffect('duizhan')
    -- end
end

return ControllerBaiRenPrizePool