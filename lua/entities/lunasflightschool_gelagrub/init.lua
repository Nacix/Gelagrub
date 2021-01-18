AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent.dOwnerEntLFS = ply
	ent:SetPos( tr.HitPos + tr.HitNormal )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:RunOnSpawn()
	self:GetChildren()[1]:SetVehicleClass("phx_seat1")
	self:SetAutomaticFrameAdvance(true)
	self.c = false
	self.j = CurTime()
	self.jum = false
end

function ENT:OnTick()
	local Pod = self:GetDriverSeat()
	if not IsValid( Pod ) then return end

	local Driver = Pod:GetDriver()

	local FT = FrameTime()

	local PObj = self:GetPhysicsObject()
	local MassCenterL = PObj:GetMassCenter()
	local MassCenter = self:LocalToWorld( MassCenterL )
	self:SetMassCenter( MassCenter )

	local Forward = self:GetForward()
	local Right = self:GetRight()
	local Up = self:GetUp()

	self:DoTrace()

	local Trace = self.GroundTrace
	if self.WaterTrace.Fraction <= Trace.Fraction and not self.IgnoreWater and self:GetEngineActive() then
		Trace = self.WaterTrace
	end

	local EyeAngles = Angle(0,0,0)
	local KeyForward = false
	local KeyBack = false
	local KeyLeft = false
	local KeyRight = false
	local Sprint = false

	if IsValid( Driver ) then
		if Driver:LookupBone("ValveBiped.Bip01_R_Thigh") then
			Driver:ManipulateBoneAngles(Driver:LookupBone("ValveBiped.Bip01_R_Thigh"), Angle(40,0,-20))
			Driver:ManipulateBoneAngles(Driver:LookupBone("ValveBiped.Bip01_L_Thigh"), Angle(-40,0,20))
		end
		cachedDriver = Driver
		EyeAngles = Driver:EyeAngles()
		KeyForward = Driver:lfsGetInput( "+THROTTLE" ) or self.IsTurnMove
		KeyBack = Driver:lfsGetInput( "-THROTTLE" )
		if self.CanMoveSideways then
			KeyLeft = Driver:lfsGetInput( "+ROLL" )
			KeyRight = Driver:lfsGetInput( "-ROLL" )
		end
		if KeyBack then
			KeyForward = false
		end
		if KeyLeft then
			KeyRight = false
		end
		Sprint = Driver:lfsGetInput( "VSPEC" ) or Driver:lfsGetInput( "+PITCH" ) or Driver:lfsGetInput( "-PITCH" )
		self:MainGunPoser( Pod:WorldToLocalAngles( EyeAngles ) )
	else
		if IsValid (cachedDriver) and cachedDriver != nil then
			if cachedDriver:LookupBone("ValveBiped.Bip01_R_Thigh") then
				cachedDriver:ManipulateBoneAngles(cachedDriver:LookupBone("ValveBiped.Bip01_R_Thigh"), Angle(0,0,0))
				cachedDriver:ManipulateBoneAngles(cachedDriver:LookupBone("ValveBiped.Bip01_L_Thigh"), Angle(0,0,0))
			end
			cachedDriver = nil
		end
	end
	local MoveSpeed = Sprint and self.BoostSpeed or self.MoveSpeed

	local IsOnGround

	if IsValid( Driver ) then
		if self.jum and self.j > CurTime() then
			IsOnGround = false
		elseif Driver:KeyDown( IN_JUMP ) and self.j < CurTime() and self.onG then
			sound.Play( "tauntaun/tauntaunjump.wav", self:LocalToWorld( Vector( 20, 0, 50) ), 75)
			sound.Play( "tauntaun/tauntaunjumptroop.wav", self:LocalToWorld( Vector( 20, 0, 50) ), 75)
			self.jum = true
			self.j = CurTime() + 0.5
			IsOnGround = false
			self:GetPhysicsObject():ApplyForceCenter( self:GetUp() * 400000)
		else
			IsOnGround = Trace.Hit and math.deg( math.acos( math.Clamp( Trace.HitNormal:Dot( Vector(0,0,1) ) ,-1,1) ) ) < 70
			self.jum = false
		end
	else
		IsOnGround = Trace.Hit and math.deg( math.acos( math.Clamp( Trace.HitNormal:Dot( Vector(0,0,1) ) ,-1,1) ) ) < 70
		self.jum = false
	end

	PObj:EnableGravity( not IsOnGround )
	self.onG = IsOnGround

	if (IsOnGround) then
		local pos = Vector( self:GetPos().x, self:GetPos().y, Trace.HitPos.z)
		local speedVector = Vector(0,0,0)

		if IsValid( Driver ) and not Driver:lfsGetInput( "FREELOOK" ) and self:GetEngineActive() then
			local lookAt = Vector(0,-1,0)
			lookAt:Rotate(Angle(0,Pod:WorldToLocalAngles( EyeAngles ).y,0))
			self.StoredForwardVector = lookAt
		else
			local lookAt = Vector(0,-1,0)
			lookAt:Rotate(Angle(0,self:GetAngles().y,0))
			self.StoredForwardVector = lookAt
		end

		local ang = self:LookRotation( self.StoredForwardVector, Trace.HitNormal ) - Angle(0,0,90)
		if self:GetEngineActive() then
			speedVector = Forward * ((KeyForward and MoveSpeed or 0) - (KeyBack and MoveSpeed or 0)) + Right * ((KeyLeft and MoveSpeed or 0) - (KeyRight and MoveSpeed or 0))
		end

		self.deltaV = LerpVector( self.LerpMultiplier * FT, self.deltaV, speedVector )
		self:SetDeltaV( self.deltaV )
		pos = pos + self.deltaV
		self:SetIsMoving(pos != self:GetPos())

		self.ShadowParams.pos = pos
		self.ShadowParams.angle = ang
		PObj:ComputeShadowControl( self.ShadowParams )
	end

	local GunnerPod = self:GetGunnerSeat()
	if IsValid( GunnerPod ) then
		local Gunner = GunnerPod:GetDriver()
		if Gunner != self:GetGunner() then
			self:SetTurretDriver( Gunner )
		end
	end

	local TurretPod = self:GetTurretSeat()
	if IsValid( TurretPod ) then
		local TurretDriver = TurretPod:GetDriver()
		if TurretDriver != self:GetTurretDriver() then
			self:SetTurretDriver( TurretDriver )
		end
	end
	self:Gunner( self:GetGunner(), GunnerPod )
	self:Turret( self:GetTurretDriver(), TurretPod )

	if self.LastSkin != self:GetSkin() then
		self.LastSkin = self:GetSkin()
	end

	if self.LastColor != self:GetColor() then
		self.LastColor = self:GetColor()
	end
	--[[
	if self:GetForwardVelocity() <= 5 then
		self:SetSequence(self:LookupSequence( "idleaction" ))
		self:SetPlaybackRate(1)
	end
	if  self:GetForwardVelocity() > 5 then --self:GetForwardVelocity() <= 500  and
		self:ResetSequence(self:LookupSequence( "idleaction" ))
		self:SetPlaybackRate(self:GetForwardVelocity()/60)
	end
	--]]
	-- if self:GetForwardVelocity() > 500 then
		-- self:ResetSequence(self:LookupSequence("running"))
		-- self:SetPlaybackRate(self:GetForwardVelocity()/333)
	-- end
	if not IsValid( Driver ) then return end

	if Driver:KeyDown( IN_SPEED ) and self:GetForwardVelocity() > 10 then
		self.MoveSpeed = 200
	else
		self.MoveSpeed = 120
	end
	self.BoostSpeed = self.MoveSpeed
end

function ENT:PrimaryAttack()
end

function ENT:OnLandingGearToggled( bOn )
	if not self:GetEngineActive() then return end
end

function ENT:OnEngineStarted()
	self:EmitSound( "tauntaun/tauntaun9.wav" )
end

function ENT:OnEngineStopped()
	self:EmitSound( "tauntaun/tauntaun9.wav" )
end

function ENT:OnRemove()
end