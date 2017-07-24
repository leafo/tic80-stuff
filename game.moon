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

  -- move piecewise
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



class Paddle
  w: 10
  h: 4

  pos: Vector 100, 100

  update: (world) =>
    fit_move @, Vector\from_input!, world

  draw: =>
    rect @pos.x, @pos.y, @w, @h, 3

class Ball
  pos: Vector 10, 10
  vel: Vector 0, 1.5
  w: 4
  h: 4

  update: (world) =>
    fit_move @, @vel, world

  draw: =>
    hw = @w/2
    hh = @h/2
    circ @pos.x - hw, @pos.y - hh, hw, 4

class World
  x: 0
  y: 0
  w: SCREEN_W
  h: SCREEN_H

  contains: (obj) =>
    {x: ox, y: oy} = obj.pos
    return false if ox < @x
    return false if oy < @y
    return false if ox + obj.w > @x + @w
    return false if oy + obj.h > @y + @h
    true
   
  collides_with: (obj) =>
    not @contains obj

entities = {Paddle!, Ball!}
     
export TIC = ->
  cls 0

  world = World!

  for e in *entities
    e\update world

  for e in *entities
    e\draw!
