--任务界面
local ControllerTask = class("ControllerTask")

function ControllerTask:Init()
	self.m_view=UIPackage.CreateObject('task','taskView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
		UIManager.Hide('ControllerTask')
		RefreshTipTask()
    end)

	--每日
	self.m_view:GetChild('btn0').onClick:Add(function ()
		self:TaskDaily_Get(1)
	end)
	--破产
	self.m_view:GetChild('btn1').onClick:Add(function ()
		self:TaskDaily_Get(2)
	end)
	--成就
	self.m_view:GetChild('btn2').onClick:Add(function ()
		self:TaskDaily_Get(3)
	end)

	self.m_list=self.m_view:GetChild('list').asList
	self.m_list:SetVirtual()
	self.m_list.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_listData[theIndex+1]
		_com.data=_t

		if _t.mtype==1 then
			_com:GetController('c1').selectedIndex=0
		elseif _t.mtype==2 then
			_com:GetController('c1').selectedIndex=1
		elseif _t.mtype==3 then
			_com:GetController('c1').selectedIndex=3	
		end
		_com:GetController('c2').selectedIndex=tonumber(_t.val.status)
		_com:GetChild('txtTitle').text=_t.val.title
		_com:GetChild('txtContent').text=_t.val.content
		_com:GetChild('txtVal').text=_t.val.gold

		_com:GetChild('txtProgress').text=''
		if _t.val.rate then
			_com:GetChild('txtProgress').text=string.format( "进度[color=#F7B500]%s[/color]/%s",_t.val.rate,_t.val.condition)
		end
	end
	self.m_list.onClickItem:Add(function (context)
		local _gcom=context.data
		--print(_gcom.data.status)
		if _gcom:GetController('c2').selectedIndex==1 then
			print('请求完成任务'.._gcom.data.key)
			_gcom:GetController('c2').selectedIndex=2
			_gcom.data.val.status=2
			coroutine.start(TaskComplete,{
				userid=loginSucceedInfo.user_info.userid,
				raskid=_gcom.data.key,
				callbackSuccess=function (info)
					setSelfMoney(tonumber(info.gold))
					self:PlayCoinAni()
				end
			})
		end
	end)
	--接受服务器数据后设置
	self.m_list.numItems = 0
	self.m_listData=nil

	--完成任务特效
	self.m_comOver=self.m_view:GetChild('comOver')
	self.m_comOver.visible=false

	self.m_jinbiPos = self.m_view:GetChild('jinbiPos')

	self.m_comOverBG=self.m_view:GetChild('n11')
	self.m_comOverBG.visible=false
end

function ControllerTask:PlayCoinAni()
	self.m_jinbiPos.visible = true
	self.m_comOver.visible=true
	self.m_comOverBG.visible=true
	if not self.m_comOver_gw then
		self.m_comOver_gw = UIManager.SetDragonBonesAniObjPos('jinbi2OBJ', self.m_jinbiPos, Vector3.New(120,120,120))
	else
		self:PlayAni(self.m_comOver_gw.gameObject, 'animation3')
	end
	self.m_timerEff=Timer.New(function ()
		self.m_comOver.visible=false
		self.m_comOverBG.visible=false
		self.m_jinbiPos.visible = false
	end,2,1)
	self.m_timerEff:Start()
	F_SoundManager.instance:PlayEffect("jinbi2")
end

function ControllerTask:PlayAni(spine_anim,anim_name)
	spine_anim:SetActive(true)
	local skeleton_anim = spine_anim:GetComponent('Spine.Unity.SkeletonAnimation')
	skeleton_anim.skeleton:SetToSetupPose()
	skeleton_anim.state:ClearTracks()
	skeleton_anim.state:SetAnimation(0,anim_name,false)
	spine_anim.gameObject:SetActive(true)
end

function ControllerTask:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.m_view:GetController('c1').selectedIndex=0
	self:TaskDaily_Get(1)

	
end
function ControllerTask:TaskDaily_Get(operatetype)
	--接受服务器数据后设置
	self.m_list.numItems = 0
	self.m_listData=nil
	coroutine.start(TaskDaily_Get,{
		operatetype=operatetype,
        userid=loginSucceedInfo.user_info.userid,
		callbackSuccess=function (info)
			local _arry={}
			for i,v in ipairs(info.resultArr) do
				table.insert(_arry,{key=v.key,val=json.decode(v.val),mtype=tonumber(info.type)})
			end
			local _ary2={}
			for i,v in ipairs(_arry) do
				if tonumber(v.val.status)==1 then
					table.insert(_ary2,v)
				end
			end
			for i,v in ipairs(_arry) do
				if tonumber(v.val.status)~=1 then
					table.insert(_ary2,v)
				end
			end
			
			self.m_listData=_ary2
			self.m_list.numItems = #_ary2
        end
    })
end

function ControllerTask:OnHide()
	self.m_view.visible=false
end

return ControllerTask