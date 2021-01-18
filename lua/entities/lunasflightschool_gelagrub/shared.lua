ENT.Type = "anim"
DEFINE_BASECLASS( "heracles421_lfs_base" )

ENT.PrintName = "Gelagrub"
ENT.Author = "Tasty"
ENT.Category = "[LFS] Tasty's Experiments"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true

ENT.MDL = "models/thebug.mdl"

ENT.AITEAM = 1
-- ENT.MaxPrimaryAmmo = 1111
-- ENT.MaxSecondaryAmmo = 31

ENT.RotorPos = Vector(50,0,30)
ENT.MassCenterOffset = Vector(20,0,-50)

ENT.Mass = 1000

ENT.HideDriver = false

ENT.SeatPos = Vector(0,0,85)
ENT.SeatAng = Angle(0,-90,-8)

--[[
ENT.SeatPos = Vector(60,0,105)
ENT.SeatAng = Angle(0,-90,-8)
--]]

--[[
ENT.SeatPos = Vector(10,0,85)
ENT.SeatAng = Angle(0,-90,-8)
--]]

ENT.MaxHealth = 3500
ENT.LevelForceMultiplier = 1000
ENT.LevelRotationMultiplier = 1
ENT.MoveSpeed = 200
ENT.BoostSpeed = 350
ENT.LerpMultiplier = 3
ENT.TraceDistance = 150
ENT.HeightOffset = 0
ENT.CanMoveSideways = true
ENT.IgnoreWater = true