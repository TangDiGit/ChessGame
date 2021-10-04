-- 比赛场的提示
local ControllerCompetitionEnd = class("ControllerCompetitionEnd")

function ControllerCompetitionEnd:Init()
    self.m_view = UIPackage.CreateObject('competition', 'hotGameEndView').asCom
    UIManager.top:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    self.m_rank_ctrl = self.m_view:GetController('rank')
    self.m_rank_num = self.m_view:GetChild("rank_num")
    self.m_desc = self.m_view:GetChild("desc")
    self.m_reward = self.m_view:GetChild("reward")

    self.m_btn_exit = self.m_view:GetChild("btn_exit")
    self.m_btn_close = self.m_view:GetChild("btn_close")

    self.m_btn_exit.onClick:Add(function ()
        UIManager.Hide('ControllerCompetitionEnd')
        UIManager.GetController('ControllerTexas'):ExitMatchGame()
    end)

    self.m_btn_close.onClick:Add(function ()
        UIManager.Hide('ControllerCompetitionEnd')
    end)

    self.jiangbeiObj = UIManager.SetDragonBonesAniObjPos('jiangbeiOBJ', self.m_view:GetChild("jiangbeiPos"), Vector3.New(80,80,80)).gameObject
end

--required int32 userid = 1; //
--required string nickname = 2; //
--required int32 paiming = 3; //
--required int32 rewardscore = 4; //
--required int32 goodsid = 5; //
--required int32 goodscount = 6; //
function ControllerCompetitionEnd:Show(arg)
    --保持在前面
    UIManager.top:AddChild(self.m_view)
    self.m_view.visible = true

    if arg.paiming <= 3 then
        self.m_rank_num.text = ""
        self.m_rank_ctrl.selectedIndex = arg.paiming - 1
    else
        self.m_rank_num.text = arg.paiming
        self.m_rank_ctrl.selectedIndex = 3
    end

    self.m_desc.text = string.format("恭喜你获得本场比赛第%s名，您的名字将会载入史册！", arg.paiming)
    self.m_reward.text = string.format("奖励金币：%s", formatVal(arg.rewardscore))

    local is_first_rank = arg.paiming == 1 or arg.paiming == 2
    self.m_btn_exit.visible = is_first_rank
    self.m_btn_close.visible = not is_first_rank

    --string.format("玩家:[color=#E6BC57]%s[/color]已被淘汰", msg.nickname)
    --self.m_view:GetController('rank')

    self:ShowJiangBeiAni()
end

function ControllerCompetitionEnd:ShowJiangBeiAni()
    self:PlayAni(self.jiangbeiObj, "start", false)
    Timer.New(function ()
        self:PlayAni(self.jiangbeiObj, "idle",true)
    end, 3, 1):Start()
end

function ControllerCompetitionEnd:PlayAni(spine_anim, anim_name, is_loop)
    spine_anim:SetActive(true)
    local skeleton_anim = spine_anim:GetComponent('Spine.Unity.SkeletonAnimation')
    skeleton_anim.skeleton:SetToSetupPose()
    skeleton_anim.state:ClearTracks()
    skeleton_anim.state:SetAnimation(0, anim_name, is_loop)
end

function ControllerCompetitionEnd:OnHide()
    self.m_view.visible = false
end

return ControllerCompetitionEnd

