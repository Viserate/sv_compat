local Config = rawget(_G, 'Config') or {}
if Config.Target ~= 'qtarget' then return end
if GetResourceState('qtarget') ~= 'started' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

local qt = exports.qtarget
if not qt then return end

CompatClient.Target = CompatClient.Target or {}
CompatClient.Target.backend = 'qtarget'

local function convertOxOptions(options)
	if not options then return options end
	for k, v in pairs(options) do
		options[k].action = v.onSelect
		options[k].onSelect = nil
	end
	return options
end

CompatClient.Target.AddModel = function(models, options)
	qt:AddTargetModel(models, options)
	return true
end

CompatClient.Target.RemoveModel = function(models)
	if not models then return false end
	if qt and qt.RemoveTargetModel then
		qt:RemoveTargetModel(models)
		return true
	end
	return false
end

CompatClient.Target.AddEntity = function(entities, options)
	qt:AddTargetEntity(entities, options)
	return true
end

CompatClient.Target.RemoveEntity = function(entities)
	qt:RemoveTargetEntity(entities)
	return true
end

CompatClient.Target.AddSphere = function(data)
	if not data or not data.coords then return nil end
	local options = convertOxOptions(data.options)
	local zoneName = data.name or ('sphere_' .. math.random(100000, 999999))
	qt:AddCircleZone(zoneName, data.coords, data.radius or 1.5, {
		name = zoneName,
		debugPoly = data.debug or false,
		useZ = true
	}, {
		options = options,
		distance = data.radius or 1.5
	})
	return zoneName
end

CompatClient.Target.AddPoly = function(data)
	if not data or not data.points or #data.points < 3 then return nil end
	local options = convertOxOptions(data.options)
	local zoneName = data.name or ('poly_' .. math.random(100000, 999999))
	qt:AddPolyZone(zoneName, data.points, {
		name = zoneName,
		debugPoly = data.debug or false,
		minZ = data.minZ,
		maxZ = data.maxZ
	}, {
		options = options,
		distance = data.distance or 2.5
	})
	return zoneName
end

CompatClient.Target.RemoveZone = function(zoneName)
	if not zoneName then return false end
	qt:RemoveZone(zoneName)
	return true
end

print('[sv_compat] Target backend: qtarget')
