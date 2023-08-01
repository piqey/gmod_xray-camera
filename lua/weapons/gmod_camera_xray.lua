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

	file.CreateDir(XRays.path)

	concommand.Add("png_xray", function(_, _, _, argStr)
		XRays.next = #argStr > 0 and argStr or util.DateStamp()
	end)

	local msg_orange = Color(255, 100, 0)
	local msg_yellow = Color(255, 255, 0)

	--- Alias for capturing an image, writing it and logging it
	--- in the console.
	---@param name string? The file name the capture will be saved to
	local function CaptureImage(name)
		local path = XRays.path .. name .. ".png"
		local cap = render.Capture({
			format = "png",
			x = 0,
			y = 0,
			w = ScrW(),
			h = ScrH()
		})

		file.Write(path, cap)
		MsgC(msg_orange, "[X-ray Camera] ", color_white, "Image captured and saved to ", msg_yellow, "\"" .. path .. "\" (" .. string.NiceSize(file.Size(path, "DATA")) .. ")")
	end

	local lastrun

	hook.Add("PreDrawOpaqueRenderables", "XRayCamera.Capture.PreDraw", function(isDrawingDepth, _, isDraw3DSkybox)
		if isDrawingDepth or isDraw3DSkybox then
			return true
		elseif XRays.next and lastrun ~= CurTime() then
			render.SetWriteDepthToDestAlpha(false)
			render.Clear(0, 0, 0, 0)
			lastrun = CurTime()
		end
	end)

	hook.Add("PostDrawOpaqueRenderables", "XRayCamera.Capture.PostDraw", function(_, _, _)
		if XRays.next then
			render.SetWriteDepthToDestAlpha(true)
			CaptureImage(XRays.next)
			XRays.next = nil
		end
	end)

	hook.Add("PreDrawSkyBox", "XRayCamera.Capture.DisableSkybox", function()
		if XRays.next then return true end
	end)
end

----------------
-- SWEP HOOKS --
----------------

function SWEP:PrimaryAttack()
	-- Say cheese! Your vision will return shortly.
	self:DoShootEffect()

	if not game.SinglePlayer() and SERVER then return end
	if CLIENT and not IsFirstTimePredicted() then return end

	-- Send electromagnetic waves straight through their soft tissues
	self:GetOwner():ConCommand("png_xray")
end
