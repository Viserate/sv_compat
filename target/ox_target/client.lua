local Config = rawget(_G, 'Config') or {}
if Config.Target ~= 'ox_target' then return end
if GetResourceState('ox_target') ~= 'started' then return end

local CompatClient = _G.SV_Compat_Client
if not CompatClient then return end

local ox = exports.ox_target
if not ox then return end

CompatClient.Target = CompatClient.Target or {}
CompatClient.Target.backend = 'ox_target'

CompatClient.Target.AddModel = function(models, options)
	if not models then return false end
	if ox.addModel then ox:addModel(models, options) return true end
	if ox.addEntity then ox:addEntity(models, options) return true end
	return false
end

CompatClient.Target.RemoveModel = function(models)
	if not models then return false end
	if ox.removeModel then ox:removeModel(models) return true end
	return false
end

CompatClient.Target.AddEntity = function(entities, options)
	if not entities then return false end
	if ox.addLocalEntity then ox:addLocalEntity(entities, options) return true end
	if ox.addEntity then ox:addEntity(entities, options) return true end
	return false
end

CompatClient.Target.RemoveEntity = function(entities)
	if not entities then return false end
	if ox.removeLocalEntity then ox:removeLocalEntity(entities) return true end
	if ox.removeEntity then ox:removeEntity(entities) return true end
	return false
end

CompatClient.Target.AddSphere = function(data)
	if not data or not data.coords then return nil end
	local zoneId = ox:addSphereZone({
		coords = data.coords,
		radius = data.radius or 1.5,
		debug = data.debug or false,
		options = data.options
	})
	return zoneId
end

CompatClient.Target.AddPoly = function(data)
	if not data or not data.points or #data.points < 3 then return nil end
	local zoneId = ox:addPolyZone({
		points = data.points,
		thickness = data.thickness or 4.0,
		debug = data.debug or false,
		options = data.options
	})
	return zoneId
end

CompatClient.Target.RemoveZone = function(zoneId)
	if not zoneId then return false end
	ox:removeZone(zoneId)
	return true
end

print('[sv_compat] Target backend: ox_target')
