if !exports
  exports = {}
_globals.draw = exports

num = _globals.num

Object.defineProperty createjs.DisplayObject.prototype, 'scale',
  get: -> return new num.Num2(@scaleX, @scaleY)
  set: (scale) ->
    scale = new num.Num2(scale)
    @scaleX = scale.x
    @scaleY = scale.y

positionOffset =
  get: -> return new num.Num2(@x, @y)
  set: (position) ->
    position = new num.Num2(position)
    @x = position.x
    @y = position.y


Object.defineProperty createjs.DisplayObject.prototype, 'position', positionOffset
Object.defineProperty createjs.DisplayObject.prototype, 'offset', positionOffset

class exports.Image extends createjs.Bitmap
  constructor: (image) ->
    super(image)
    @image.onload = () =>
      @dispatchEvent 'changedAsync'


class exports.Rectangle extends createjs.Shape
  constructor: (@width, @height) ->


class exports.MyStage extends createjs.Stage
  constructor: (@elementId) ->
    super(@elementId)

    @_updateSelf = () =>
      @update()

    @scale = 2

    $("#" + @elementId).on 'mousewheel', (event) =>
      event.preventDefault()
      oldZoom = @scaleX
      if (event.deltaY > 0)
        newZoom = oldZoom * 1.1
      else
        newZoom = oldZoom / 1.1

      point = new num.Num2(@mouseX, @mouseY)
      zoomRatio = newZoom/oldZoom
      @scale = newZoom
      @offset = @offset.multiply(zoomRatio).subtract(point.multiply(zoomRatio)).add(point)

      @update()

    @on 'stagemouseup', (e) => @onMouseUp(e)
    @on 'stagemousedown', (e) => @onMouseDown(e)
    @on 'stagemousemove', (e) => @onMouseMove(e)

  onMouseDown: (event) ->
    @_dragStartPosition = {x: event.stageX, y: event.stageY}
    @_dragStartOffset = @offset.clone()

  onMouseUp: (event) ->

  onMouseMove: (event) ->
    mouse = new num.Num2(event.stageX, event.stageY)
    if @_dragStartPosition
      delta = num.Num2.subtract(mouse, @_dragStartPosition)

    if event.nativeEvent.which == 2
      @offset = @_dragStartOffset.add(delta)

    @update()

  addChild: (child) ->
    super(child)
    child.on 'changedAsync', @_updateSelf

  removeChild: (child) ->
    super(child)
    child.off 'changedAsync', @_updateSelf


