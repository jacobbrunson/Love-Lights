local vector = require("vector")
local util = require("util")

local shader = nil
local world = nil

local lights = {
  {
    position = vector(200, 300),
    color = {255, 0, 0},
    size = 100
  }
}

local blocks = {}

do
  local light
  function shadows(newLight)
    if newLight then
      light = newLight
    elseif not light then
      return
    end
    for _, block in pairs(blocks) do
      local vertices = {block.body:getWorldPoints(block.shape:getPoints())}
      for i = 1, 8, 2 do
        local vertex = vector(vertices[i], vertices[i + 1])
        local nextVertex = vector(vertices[(i + 2) % 8], vertices[(i + 2) % 8 + 1])
        local startToEnd = nextVertex - vertex
        local normal = vector(startToEnd.y, -startToEnd.x)
        local lightToStart = vertex - light.position
        if normal * lightToStart > 0 then
          local point1 = vertex + ((vertex - light.position) * 800)
          local point2 = nextVertex + ((nextVertex - light.position) * 800)
          love.graphics.polygon("fill", vertex.x, vertex.y, point1.x, point1.y, point2.x, point2.y, nextVertex.x, nextVertex.y)
        end
      end
    end
  end
end

function love.draw()
  love.graphics.setColor(0, 0, 0)
  love.graphics.setBlendMode("additive")
  for _, light in pairs(lights) do
    shadows(light)
    love.graphics.setInvertedStencil(shadows)
    love.graphics.setShader(shader)
    shader:send("light_position", {light.position.x, love.graphics.getHeight() - light.position.y})
    shader:send("light_color", light.color)
    shader:send("light_size", light.size)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setInvertedStencil()
    love.graphics.setShader()
  end
  love.graphics.setBlendMode("multiplicative")
  for _, block in pairs(blocks) do
    love.graphics.setColor(block.color)
    love.graphics.polygon("fill", block.body:getWorldPoints(block.shape:getPoints()))
  end
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
  love.graphics.print("Lights: " .. #lights, 10, 30)
  love.graphics.print("Blocks: " .. #blocks, 10, 50)
end

function love.load()
  shader = love.graphics.newShader("shader.frag", "shader.vert");
  love.physics.setMeter(50)
  world = love.physics.newWorld(0, 9.81 * 50, true)
  floor = {}
  floor.body = love.physics.newBody(world, 400, 625)
  floor.shape = love.physics.newRectangleShape(800, 50)
  floor.fixture = love.physics.newFixture(floor.body, floor.shape)
  floor.color = {0, 0, 0}
  table.insert(blocks, floor)

  ceiling = {}
  ceiling.body = love.physics.newBody(world, 400, -25)
  ceiling.shape = love.physics.newRectangleShape(800, 50)
  ceiling.fixture = love.physics.newFixture(ceiling.body, ceiling.shape)
  ceiling.color = {0, 0, 0}
  table.insert(blocks, ceiling)

  leftWall = {}
  leftWall.body = love.physics.newBody(world, -25, 300)
  leftWall.shape = love.physics.newRectangleShape(50, 600)
  leftWall.fixture = love.physics.newFixture(leftWall.body, leftWall.shape)
  leftWall.color = {0, 0, 0}
  table.insert(blocks, leftWall)

  rightWall = {}
  rightWall.body = love.physics.newBody(world, 825, 300)
  rightWall.shape = love.physics.newRectangleShape(50, 600)
  rightWall.fixture = love.physics.newFixture(rightWall.body, rightWall.shape)
  rightWall.color = {0, 0, 0}
  table.insert(blocks, rightWall)

  starter = {}
  starter.body = love.physics.newBody(world, 400, 100, "dynamic")
  starter.shape = love.physics.newRectangleShape(50, 50)
  starter.fixture = love.physics.newFixture(starter.body, starter.shape)
  starter.color = {0, 0, 0}
  table.insert(blocks, starter)
end

function love.update(delta)
  print(mouseJoint)
  if mouseJoint ~= nil then
    mouseJoint:setTarget(love.mouse.getPosition())
  end
  world:update(delta)
  local light = lights[#lights]
  light.position = vector(love.mouse.getX(), love.mouse.getY())
  if love.keyboard.isDown("w") then
    light.size = light.size + 100 * delta
  end
  if love.keyboard.isDown("s") then
    light.size = light.size - 100 * delta
  end
  light.size = math.max(0, light.size)
  if love.keyboard.isDown("a") then
    local h, s, l = util.rgbToHsl(unpack(light.color))
    light.color = {util.hslToRgb((h - 100 * delta) % 360, s, l)}
  end
  if love.keyboard.isDown("d") then
    local h, s, l = util.rgbToHsl(unpack(light.color))
    light.color = {util.hslToRgb((h + 100 * delta) % 360, s, l)}
  end
end

mouseJoint = nil

function love.mousepressed(x, y, button)
  if button == "l" then
    local light = lights[#lights]
    local newLight = {
      position = light.position,
      size = light.size,
      color = light.color
    }
    lights[#lights + 1] = newLight
  elseif button == "r" then
    for _, block in pairs(blocks) do
      if block.fixture:testPoint(x, y) then
        mouseJoint = love.physics.newMouseJoint(block.body, x, y)
        break
      end
    end
  end
end

function love.mousereleased(x, y, button)
  if button == "r" then
    if mouseJoint then
      mouseJoint:destroy()
      mouseJoint = nil
    end
  end
end

function love.keypressed(key)
  if key == "up" then
    impulse(0, -500)
  elseif key == "down" then
    impulse(0, 500)
  elseif key == "left" then
    impulse(-500, 0)
  elseif key == "right" then
    impulse(500, 0)
  elseif key == "f" then
    for i = 1, math.random(1, 5) do
      block = {}
      block.body = love.physics.newBody(world, love.mouse.getX(), love.mouse.getY(), "dynamic")
      block.shape = love.physics.newRectangleShape(math.random() * 50 + 20, math.random() * 50 + 20)
      block.fixture = love.physics.newFixture(block.body, block.shape)
      block.color = {math.random() * 255, math.random() * 255, math.random() * 255}
      table.insert(blocks, block)
    end
  elseif key == "r" then
    for i = 1, math.min(5, #blocks - 4) do
      blocks[#blocks].fixture:destroy()
      blocks[#blocks].body:destroy()
      table.remove(blocks, #blocks)
    end
  elseif key == "g" then
    local x, y = world:getGravity()
    if y == 0 then
      world:setGravity(0, 9.81 * 50)
    else
      world:setGravity(0, 0)
    end
  elseif key == "z" then
    if #lights > 1 then
      table.remove(lights, #lights)
    end
  end
end

function impulse(x, y)
  if #blocks == 4 then
    return
  end
  for i = 5, #blocks do
    blocks[i].body:applyLinearImpulse(x, y)
  end
end
