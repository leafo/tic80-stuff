-- title:  leafo test game
-- author: leafo
-- desc:   a test game
-- script: moon
-- input:  gamepad
-- saveid: leafo_test

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

  update: =>
    @pos += Vector\from_input!

  draw: =>
    rect @pos.x, @pos.y, @w, @h, 3

class Ball
  pos: Vector 10, 10
  w: 4
  h: 4

  update: =>

  draw: =>
    hw = @w/2
    hh = @h/2
    circ @pos.x - hw, @pos.y - hh, hw, 4

entities = {Paddle!, Ball!}
     
export TIC = ->
  cls 0

  for e in *entities
    e\update!

  for e in *entities
    e\draw!
