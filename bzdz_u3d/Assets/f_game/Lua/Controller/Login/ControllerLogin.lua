--登录界面
local ControllerLogin = class("ControllerLogin")

function ControllerLogin:Init()
	self.m_view=UIPackage.CreateObject('main','LoginView').asCom
	--local _btnwx=self.m_view:GetChild("btn_wechatLogin")
	--if F_Util.isAndroid() or F_Util.isIOS() then
	--	_btnwx.x = 697
	--end
	--print("_btnwx.x:".._btnwx.x)

	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetController("c1").selectedIndex=1
	self.m_view:GetChild("btn_wjmm").onClick:Add(function ()
		--print('忘记密码')
		UIManager.Show('ControllerForgotPasswd',{m_type='Login'})
	end)

	self.m_view:GetChild("btn_reg").onClick:Add(function ()
		--print('注册账号')
		UIManager.Show('ControllerReg')
	end)

	self.m_view:GetChild("btn_wechatLogin").onClick:Add(function ()
		if F_Util.isIOS() then
			if F_MobManager then
				F_MobManager.instance:AuthorizeWX()
			end
		else
			if F_UnityAndroidMsg then
				F_UnityAndroidMsg.instance:OnRequestWxLogin()
			end
		end
	end)

	self.m_view:GetChild("btn_accountLogin").onClick:Add(function ()
		--print('账号登录')
		UIManager.Show('ControllerAccountLogin')
	end)

	-- --只保留微信登录
	-- if F_Util.isAndroid() or F_Util.isIOS() then
	-- 	self.m_view:GetChild("btn_wjmm").visible=false
	-- 	self.m_view:GetChild("btn_reg").visible=false
	-- 	self.m_view:GetChild("btn_accountLogin").visible=false
	-- end

	UIManager.SetDragonBonesAniObjPos2('jueseOBJ',self.m_view:GetChild("n41"):GetChild("sp"),Vector3.New(100,100,100))

	--spine大厅背景
    local _u3dOBJ=UnityEngine.GameObject.Instantiate(UIManager.GetPrefab('puke_obj'))
    
    local _gw=FairyGUI.GoWrapper(_u3dOBJ)
    self.m_view:GetChild('spineBG').asGraph:SetNativeObject(_gw)
    
    local designWidth = 1920
    local designHeight = 1080
    local designScale  = designWidth/designHeight
    local scaleRate  = UnityEngine.Screen.width/UnityEngine.Screen.height
	local  scaleFactor=1
    if scaleRate<designScale then
        scaleFactor = designScale/scaleRate 
    else
		scaleFactor =scaleRate/designScale
    end
	_u3dOBJ.transform.localScale =Vector3.New(100*scaleFactor,100*scaleFactor,100*scaleFactor)
end

function ControllerLogin:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible = true
	local desc1 = "本网络游戏适合全年龄的用户使用, 为了您的健康, 请合理控制游戏时间。粤网文[2019]6138-1456号 文网游戏备字[2019]M-CSG 0080号"
	local desc2 = "抵制不良游戏, 拒绝盗版游戏, 注意自我保护, 谨防受骗上当, 适当游戏益脑，沉迷游戏伤身, 合理安排时间, 享受健康生活。"
	local desc3 = "新出网证（粤）字010号 著作权人:  潮人8090网络有限公司    出版单位:  潮人8090网络有限公司 批准文号:  新广出审[2019]5377号  出版物号:  ISBN978-7-7979-888-9"
	self.m_view:GetChild("n35").text = string.format("%s\n%s\n%s", desc1, desc2, desc3)
end

function ControllerLogin:OnHide()
	self.m_view.visible=false
end
return ControllerLogin