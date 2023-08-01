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

if CLIENT then
	---@class XRays
	---@field path string
	---@field next string?
	local XRays = {}
	XRays.path = "xray_camera/"
	XRays.next = nil

	concommand.Add("png_xray", function(_, _, _, argStr)
		XRays.next = #argStr > 0 and argStr or util.DateStamp()
	end)

	hook.Add("PreDrawOpaqueRenderables", "XRayCamera.Capture.PreDraw", function()
		if XRays.next then
			render.ClearDepth()
			render.Clear(0, 0, 0, 0)
		end
	end)

	hook.Add("PostRender", "XRayCamera.Capture.PostRender", function()
		if XRays.next then
			file.Write(XRays.path .. XRays.next .. ".png", render.Capture({
				format = "png",
				x = 0,
				y = 0,
				w = ScrW(),
				h = ScrH()
			}))
			XRays.next = nil
		end
	end)
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
