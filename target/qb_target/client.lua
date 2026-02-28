local Config = rawget(_G, 'Config') or {}
if Config.Target ~= 'qb-target' then return end
if GetResourceState('qb-target') ~= 'started' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

local qb = exports['qb-target']
if not qb then return end

CompatClient.Target = CompatClient.Target or {}
CompatClient.Target.backend = 'qb-target'

local function convertOxOptions(options)
	if not options then return options end
	for k, v in pairs(options) do
		options[k].action = v.onSelect
		options[k].onSelect = nil
	end
	return options
end

CompatClient.Target.AddModel = function(models, options)
	options = convertOxOptions(options)
	qb:AddTargetModel(models, { options = options, distance = (options and options.distance) or 2.0 })
	return true
end

CompatClient.Target.RemoveModel = function(models)
	if not models then return false end
	if qb and qb.RemoveTargetModel then
		qb:RemoveTargetModel(models)
		return true
	end
	return false
end

CompatClient.Target.AddEntity = function(entities, options)
	options = convertOxOptions(options)
	qb:AddTargetEntity(entities, { options = options, distance = (options and options.distance) or 2.0 })
	return true
end

CompatClient.Target.RemoveEntity = function(entities)
	qb:RemoveTargetEntity(entities)
	return true
end

CompatClient.Target.AddSphere = function(data)
	if not data or not data.coords then return nil end
	local options = convertOxOptions(data.options)
	local zoneName = data.name or ('sphere_' .. math.random(100000, 999999))
	qb:AddCircleZone(zoneName, data.coords, data.radius or 1.5, {
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
	qb:AddPolyZone(zoneName, data.points, {
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
	qb:RemoveZone(zoneName)
	return true
end

print('[sv_compat] Target backend: qb-target')
