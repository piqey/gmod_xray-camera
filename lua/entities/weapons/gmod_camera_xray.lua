AddCSLuaFile()

DEFINE_BASECLASS("gmod_camera")

-----------------
-- SWEP FIELDS --
-----------------

SWEP.PrintName = "X-ray Camera"
SWEP.Description = "Captures images of everything MINUS the map geometry, with transparency."

--------------------
-- SPECIAL CAMERA --
--     HOOKS      --
--------------------

---@class XRays
---@field private _list { string : GIMaterial }
local XRays = {}
XRays._list = {}

local function GetXRays()

end

function SWEP:MakeXRay()

end

----------------
-- SWEP HOOKS --
----------------

function SWEP:PrimaryAttack()
	-- Say cheese! Your vision will return shortly.
	self:DoShootEffects()

	if not game.SinglePlayer() and SERVER then return end
	if CLIENT and not IsFirstTimePredicted() then return end

	-- Send electromagnetic waves straight through their soft tissues
	self:GetOwner():ConCommand("png_xray")
end
