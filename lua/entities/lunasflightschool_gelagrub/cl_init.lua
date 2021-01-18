include("shared.lua")
				-- local Pos = self:LocalToWorld( Vector(10,0,10) )
				-- timer.Create( "tauntaunsound", 2, 0, function() sound.Play( "tauntaun/tauntaun"..math.random(1,9)..".wav", Pos, 75 ) end )
function ENT:Think()
	self:EmitSound("tauntaun/tauntaun" .. math.random(1,9) .. ".wav")
	self:SetNextClientThink( CurTime() + math.random(4,10) )
	return true
end

function ENT:DamageFX()
	local HP = self:GetHP()
	if HP == 0 then return end
	if HP > self:GetMaxHP() * 0.5 then return end
	self.nextDFX = self.nextDFX or 0
	if self.nextDFX < CurTime() then
		self.nextDFX = CurTime() + 0.05
		if HP <= self:GetMaxHP() * 0.5 and math.random(0,45) < 3 and math.random(1,2) == 1 then
					local Pos = self:LocalToWorld( Vector(25,0,50) + VectorRand() * 3 )
					local effectdata = EffectData()
					effectdata:SetOrigin( Pos )
					util.Effect( "BloodImpact", effectdata, true, true )
					sound.Play( "tauntaun/tauntaunpain.wav", Pos, 75 )
		end
	end
end

function ENT:EngineActiveChanged( bActive )
	-- if bActive then
		-- self.ENG = CreateSound( self, "ambient/machines/train_idle.wav" )
		-- self.ENG:PlayEx(0,0)

		-- self.DIST = CreateSound( self, "ambient/machines/train_idle.wav" )
		-- self.DIST:PlayEx(0, 0)
	-- else
		-- self:SoundStop()
	-- end
end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	if self.ENG then
		self.ENG:ChangePitch(  math.Clamp(math.Clamp(  70 + 45, 50,255) + Doppler,0,255) )
		self.ENG:ChangeVolume( math.Clamp( -1 + 1, 0.5,1) )
	end

	if self.DIST then
		self.DIST:ChangePitch(  math.Clamp(math.Clamp( 150, 50,255) + Doppler,0,255) )
		self.DIST:ChangeVolume( math.Clamp( -1 + 1, 0.5,1) )
	end
end

function ENT:SoundStop()
	if self.DIST then
		self.DIST:Stop()
	end

	if self.ENG then
		self.ENG:Stop()
	end
end