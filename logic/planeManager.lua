local planeCollisions = require("logic.planeCollisions")
local planePollution = require("logic.planePollution")
local planeRunway = require("logic.planeRunway")
local planeTakeoffLanding = require("logic.planeTakeoffLanding")
local planeUtility = require("logic.planeUtility")
local guiController = require("logic.guiController")

-- Creates, updates, or deletes the gauges depending on player settings
local function updateGauges(tick, player, settings, game)
    if settings.get_player_settings(player)["aircraft-realism-user-enable-gauges"].value then
        guiController.updateGaugeArrows(tick, player, settings, game)
    else
        guiController.deleteGauges(player)
    end
end

-- Checks the planes and performs all the functions a plane should do
local function checkPlanes(e, player, game, defines, settings)
    assert(player.vehicle)
    local quarterSecond = e.tick % 15 == 0 --15 ticks, 1/4 of a second

    if quarterSecond then
        CheckHelicopterMod(player)
    end

    if planeUtility.isGroundedPlane(player.vehicle.prototype.order) then
        updateGauges(e.tick, player, settings, game)

        -- These don't need to be checked as often, so they run off quarterSecond
        if quarterSecond then

            planePollution.createPollution(settings, player.surface, player.vehicle)
            --Create some smoke effects trailing behind the plane
            player.surface.create_trivial_smoke{name="train-smoke", position=player.position, force="neutral"}

            planeTakeoffLanding.planeTakeoff(player, game, defines, settings)
        end

        -- Collision gets checked every tick for accuracy
        if planeRunway.validateRunwayTile(settings, player.surface, player.vehicle) then -- Returns false if the plane did not pass and was destroyed
            -- Test for obstacle collision (water, cliff)
            planeCollisions.obstacleCollision(settings, player.surface, player, player.vehicle)
        end

    elseif quarterSecond and planeUtility.isAirbornePlane(player.vehicle.prototype.order) then
        updateGauges(e.tick, player, settings, game)

        planePollution.createPollution(settings, player.surface, player.vehicle)

        planeTakeoffLanding.planeLand(player, game, defines, settings)
    end
end


local functions = {}

functions.checkPlanes = checkPlanes

return functions