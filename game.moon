-- title:  leafo test game
-- author: leafo
-- desc:   a test game
-- script: moon
-- input:  gamepad
-- saveid: leafo_test

SCREEN_W = 240
SCREEN_H = 136

local Vector

round = (x) -> math.floor x + 0.5

-- moves object right up until edge
fit_move = (obj, move, world) ->
  if world\collides_with obj
    trace "Object is stuck"
    return

  start = obj.pos
  obj.pos += move

  -- was able to move
  return unless world\collides_with obj

  -- reset, move piecewise
  obj.pos = start

  hit_x, hit_y = false, false

  if move.x != 0
    obj.pos += Vector move.x, 0
    if world\collides_with obj
      hit_x = true
      nudge_x = if move.x > 0 then -1 else 1
      obj.pos.x = round obj.pos.x
      while world\collides_with obj
        obj.pos.x += nudge_x

  if move.y != 0
    obj.pos += Vector 0, move.y
    if world\collides_with obj
      hit_y = true
      nudge_y = if move.y > 0 then -1 else 1
      obj.pos.y = round obj.pos.y
      while world\collides_with obj
        obj.pos.y += nudge_y

  hit_x, hit_y

class Vector
  x: 0
  y: 0

  @from_input: =>
    y = if btn 0 then -1
    elseif btn 1 then 1
    else 0

    x = if btn 2 then -1
    elseif btn 3 then 1
    else 0

    @(x, y)\normalized!

  new: (@x, @y) =>

  unpack: => @x, @y

  len: =>
    return math.abs(@y) if @x == 0
    return math.abs(@x) if @y == 0
    math.sqrt @x*@x + @y*@y

  normalized: =>
    len = @len!
    if len == 0
      return Vector()

    Vector @x/len, @y/len

  __add: (other) =>
    Vector @x + other.x, @y + other.y

  __sub: (other) =>
    Vector @x - other.x, @y - other.y

  __mul: (left, right) ->
    if type(left) == "number"
      Vector right.x * left, right.y * left
    else
      -- dot product
      if type(right) != "number"
        left.x * right.x + left.y * right.y
      else
        Vector left.x * right, left.y * right

  __tostring: =>
    "Vec(#{@x}, #{@y})"

class Rect
  new: (x,y,@w,@h) =>
    @pos = Vector x,y

  center: =>
    Vector @pos.x + @w / 2, @pos.y + @h / 2

  touches: (obj) =>
    {x: ox, y: oy} = obj.pos
    return false if ox + obj.w <= @pos.x
    return false if ox >= @pos.x + @w

    return false if oy + obj.h <= @pos.y
    return false if oy >= @pos.y + @h

    true

  contains: (obj) =>
    {x: ox, y: oy} = obj.pos
    return false if ox < @pos.x
    return false if oy < @pos.y
    return false if ox + obj.w > @pos.x + @w
    return false if oy + obj.h > @pos.y + @h
    true

class Paddle extends Rect
  w: 40
  h: 5
  speed: 2

  update: (world) =>
    fit_move @, Vector\from_input! * @speed, world
    print "touching ball: #{@touches world.ball}"

  draw: =>
    rect @pos.x, @pos.y, @w, @h, 3

class Ball extends Rect
  vel: Vector 0, 1.5
  w: 4
  h: 4

  update: (world) =>
    hitx, hity = fit_move @, @vel, world

    if hitx
      @vel = Vector -@vel.x, @vel.y

    if hity
      @vel = Vector @vel.x, -@vel.y

    unless hitx or hity
      paddle = world.paddle
      if @touches paddle
        @vel = (@center! - paddle\center!)\normalized! * 1.5

  draw: =>
    hw = @w/2
    hh = @h/2
    circ @pos.x + hw, @pos.y + hh, hw, 4

class Block extends Rect
  w: 15
  h: 5
  @padding: 4

  update: (world) =>
    {:ball} = world

    if ball\touches @
      world\remove_entity @
      ball.vel = Vector ball.vel.x, -ball.vel.y

  draw: =>
    rect @pos.x, @pos.y, @w, @h, 5

  @generate_blocks: (x,y, w, h) =>
    out = {}
    for k=1,h
      for j=1,w
        table.insert out, Block(
          x + (@w + @padding) * (j - 1)
          y + (@h + @padding) * (k - 1)
        )

    out

class World extends Rect
  w: SCREEN_W
  h: SCREEN_H

  new: =>
    super!
    @paddle = Paddle 100, 100
    @ball = Ball 10, 10
    @entities = {@paddle, @ball}
    for block in *Block\generate_blocks 10, 10, 5, 3
      table.insert @entities, block

  remove_entity: (obj) =>
    @entities = [e for e in *@entities when e != obj]

  update: =>
    for e in *@entities
      e\update @

  draw: =>
    for e in *@entities
      e\draw!

  collides_with: (obj) =>
    not @contains obj

local world

export TIC = ->
  cls 0
  unless world
    world = World!


  world\update!
  world\draw!

