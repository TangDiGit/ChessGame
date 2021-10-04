--红包
local H_TexasHongBao = class("H_TexasHongBao")
function H_TexasHongBao:Init(arg)
    local m_view = arg.view
    self.controllerHongBao = arg.controllerHongBao

    m_view:GetChild("btnBg").onClick:Add(function ()
        self.controllerHongBao.selectedIndex = 0
    end)

    self.m_tips1 = m_view:GetChild("tips1")
    self.m_tips2 = m_view:GetChild("tips2")
    self.m_end = m_view:GetChild("end")
    self.m_ani_obj = UIManager.SetDragonBonesAniObjPos('hongbaoOBJ', m_view:GetChild("middlePos"), Vector3.New(75,75,75)).gameObject

    --required int32 playcount = 1;               //已打多少局
    --required int32 totalcount = 2;              //活动要求总局数
    --required int64 awardscore = 3;              //奖励多少金币
    H_NetMsg:addEventListener('DZPK_ReceiveHongBao',function (arg1)
        local msg = Protol.Poker_pb.GetUserHuoDongInfo()
        msg:ParseFromString(arg1.pb_data)
        self.controllerHongBao.selectedIndex = 1
        local is_complete = tonumber(msg.playcount) >= tonumber(msg.totalcount)
        if is_complete then
            self.m_tips1.text = ""
            self.m_tips2.text = ""
            self.m_end.text = "恭喜你，完成了红包奖励任务，明天继续加油哦!"
        else
            self.m_tips1.text = string.format("满 [color=#FFB400]%s[/color] 局，获得  [color=#FFB400]%s[/color]  金币奖励", msg.totalcount, formatVal(msg.awardscore))
            self.m_tips2.text = string.format("你已完成 [color=#FFB400]%s[/color] 局", msg.playcount)
            self.m_end.text = ""
        end
        self:ShowHongBaoAni()
    end)
end

function H_TexasHongBao:ShowHongBaoAni()
    self:PlayAni(self.m_ani_obj, "start01",true)
    Timer.New(function ()
        self:PlayAni(self.m_ani_obj, 'start02', false)
    end, 1, 1):Start()
end

function H_TexasHongBao:PlayAni(spine_anim, anim_name, is_loop)
    spine_anim:SetActive(true)
    local skeleton_anim = spine_anim:GetComponent('Spine.Unity.SkeletonAnimation')
    skeleton_anim.skeleton:SetToSetupPose()
    skeleton_anim.state:ClearTracks()
    skeleton_anim.state:SetAnimation(0, anim_name, is_loop)
end

function H_TexasHongBao:ShowHongBaoPanel()
    NetManager.SendNetMsg(GameServerConfig.logic,'DZPK_RequestHongBao')
end

return H_TexasHongBao