-- 非比赛场的道具提示
local ControllerTexasGetItem = class("ControllerTexasGetItem")

function ControllerTexasGetItem:Init()
    self.m_view = UIPackage.CreateObject('texas', 'texasGetItem').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false
    self.m_timer = nil

    self.m_view:GetChild("btn_close").onClick:Add(function ()
        UIManager.Hide('ControllerTexasGetItem')
    end)
    self.m_ani_obj = UIManager.SetDragonBonesAniObjPos('hongbaoOBJ', self.m_view:GetChild("middlePos"), Vector3.New(75,75,75)).gameObject
end

function ControllerTexasGetItem:Show(arg)
    self.m_ani_obj:SetActive(false)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true

    self:ShowHongBaoAni()

    local _config = Bag_Config[arg.goodid]
    if _config then
        self.m_view:GetChild('icon').asLoader.url = _config.url
        self.m_view:GetChild('tips1').text = string.format("恭喜获得道具：[color=#FFB400]%s%s个[/color]", _config.name, arg.goodcount)
    end
end

function ControllerTexasGetItem:ShowHongBaoAni()
    self:PlayAni(self.m_ani_obj, "start03",false)
    self.m_timer = Timer.New(function ()
        self:PlayAni(self.m_ani_obj, 'start01', false)
        self.m_timer = Timer.New(function ()
            self:PlayAni(self.m_ani_obj, 'start02', true)
        end, 1, 1)
        self.m_timer:Start()
    end, 1.3, 1)
    
    self.m_timer:Start()
end

function ControllerTexasGetItem:PlayAni(spine_anim, anim_name, is_loop)
    local skeleton_anim = spine_anim:GetComponent('Spine.Unity.SkeletonAnimation')
    skeleton_anim.skeleton:SetToSetupPose()
    skeleton_anim.state:ClearTracks()
    skeleton_anim.state:SetAnimation(0, anim_name, is_loop)
    spine_anim:SetActive(true)
end

function ControllerTexasGetItem:OnHide()
    if self.m_timer then
        self.m_timer:Stop()
    end
    self:PlayAni(self.m_ani_obj, "start03",false)
    self.m_view.visible = false
end

return ControllerTexasGetItem