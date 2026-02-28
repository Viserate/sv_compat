local Config = rawget(_G, 'Config') or {}
if Config.ProgressBackend ~= 'none' then return end

local Compat = _G.SV_Compat
if not Compat then return end

Compat.Progress = Compat.Progress or {}

Compat.Progress.Show = function(src, data)
	return true -- intentionally no-op
end

Compat.Progress.Cancel = function(src)
	return true -- intentionally no-op
end

print('[sv_compat] progress backend: none (no-op)')
