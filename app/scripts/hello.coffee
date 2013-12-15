_live_debug_ = false
_intervall_ = 1024/25
_normalized_threshold_ = 200
_normalized_segment_offset_ = 3
_threshold_ = _non_normalized_threshold_ = 400
_segment_offset_ = _non_normalized_segment_offset_ = 0
_nr_of_players_ = 10
_is_normalized_ = false

navigator.getUserMedia = 
  navigator.getUserMedia or
  navigator.webkitGetUserMedia or
  navigator.mozGetUserMedia or
  navigator.msGetUserMedia

window.AudioContext =
  window.AudioContext or
  window.webkitAudioContext or
  window.mozAudioContext or
  window.msAudioContext

gotStream = (stream) ->
  window.setTimeout((()->
    makeBox2d()
    makeCanvas()
    context = new AudioContext()
    analyser = context.createAnalyser()
    source = context.createMediaStreamSource( stream )
    source.connect(analyser);
    c = $('#canvasarium').get(0)
    ctx = c.getContext("2d")
    watchLoop(analyser, c, ctx)
    ),750)
  #debug

  #musicAnalyzer(c, ctx, analyser)

#musicAnalyzer = (canvas, ctx, analyser) ->
#  loop_id = window.webkitRequestAnimationFrame((()->
#    musicAnalyzer(canvas, ctx, analyser)))
#
#  freqByteData = new Uint8Array(analyser.frequencyBinCount)
#  analyser.getByteFrequencyData(freqByteData)
#  
#  draw(canvas, ctx, freqByteData)
#withinOffsetPlayerRange = (i) ->
#  lowerBound = _segment_offset_
#  return ((i > _segment_offset_) and (i <= _nr_of_players_+_segment_offset_))

makeCanvas = () ->
  $('body').append($('<canvas id="canvasarium" style="display:none;"></canvas>').attr('width', $(window).width()-20)
    .attr('height', 200))
  _live_debug_ = false


watchLoop = (analyser, c, ctx) ->
  loop_id = window.requestAnimationFrame((()->
    watchLoop(analyser, c,ctx)))

  freqByteData = new Uint8Array(analyser.frequencyBinCount)
  analyser.getByteFrequencyData(freqByteData)
  actionables(freqByteData, c, ctx)

simpleIx = (i,x) -> x
noramlizedIx = (i,x) -> x*(i/1024)

#_m_o_d_ = Math.floor(1024/10)
#_mitte_ = Math.floor(canvas.height/2)
actionables = (d, canvas, ctx) ->
  if _live_debug_ is true then ctx.clearRect(0, 0, canvas.width, canvas.height)

  if _is_normalized_ is true
    calcIx = noramlizedIx
  else 
    calcIx = simpleIx

  a = (0 for n in [0 ... 30])
  for x, i in d
    do (x, i) ->
      m = Math.floor(i/_intervall_)
      ix = calcIx(i,x)
      #ix = x
      a[m] = a[m]+ix
      if _live_debug_ is true
        ctx.fillStyle = "rgba("+255+","+255+","+255+", 0.4)"
        ctx.fillRect(Math.floor(i), canvas.height, 1, Math.floor(-ix*1))

  ctx.fillStyle = "rgb("+255+","+255+","+255+")"
  highest_val = 0
  segment = 0
  for y, i in a
    do (y,i) ->
      if y > highest_val
        highest_val = y
        segment = i
      if _live_debug_ is true
        #ctx.fillStyle = "rgb("+255+","+255+","+255+")"
        ctx.fillRect(Math.floor(i*_intervall_)-1,0,1,canvas.height)
        ctx.fillText('P:'+(i-_segment_offset_), Math.floor(i*(_intervall_)+(_intervall_/2-5)), 40)
        ctx.fillText('S:'+i, Math.floor(i*(_intervall_)+(_intervall_/2-5)), 50)



  #segment = segment + 1
  #if segment is 10 then segment = 0
  #console.log(segment)
  #ctx.fillStyle = "rgb("+255+","+255+","+255+")"
  if highest_val > _threshold_ 
    if segment >= _segment_offset_ and segment < _nr_of_players_+_segment_offset_
      jumpByNr(segment-_segment_offset_, 1)
      ctx.fillStyle = "rgb("+255+","+255+","+255+")"
    else
      ctx.fillStyle = "rgb("+255+","+0+","+0+")"
      #alert('all')
      #jumpAll()

    if _live_debug_ is true
      ctx.fillRect(Math.floor(segment*_intervall_)-1,0,_intervall_,30)
    

  #debugger 
  return true





$('document').ready(
  for x in [0..._nr_of_players_]
    do(x) ->
      #if x is 10 then x = 0
      $('#bottom').append('<div class="player"
            data-box2d-passive="true"
            data-box2d-density="1"
            data-box2d-restitution="0.5" 
            data-box2d-friction="0.5"
      id="_'+x+'">'+x+'.</div>')
  
  makeBox2d = () ->
    $('.player').box2d(
      'y-velocity':10
      ).on('click', () -> $.Physics.applyImpulse($(@), {x: 0, y: -10}))
    $('.balken').box2d()
    $('#goal, .fussball').box2d().on("collisionStart", (evt, collisionNode) ->
        if (@id is 'goal' and collisionNode.id is 'ball_1') or (@id is 'goal' and collisionNode.id is 'ball_2')
          $(this).addClass('collides')
          $(collisionNode).addClass('collides')
          $('#tor').fadeIn().fadeOut()
      )
      .on("collisionEnd", (evt, collisionNode) ->
        $(this).removeClass('collides')
        $(collisionNode).removeClass('collides')
      )
    
  #$('.fussball').box2d()

   navigator.getUserMedia( {audio:true}, gotStream, (()->) )
)



#jumpAll = (ammount) ->
#  $.Physics.applyImpulse($('.player'), {x: 0, y: (amount*-1)})

ballJump = (amount = 100) ->
  $.Physics.applyForce($('#ball_1'), {x: 0, y: (amount*-1)})
  $.Physics.applyForce($('#ball_2'), {x: 0, y: (amount*-1)})

jumpById = (id, amount = 5) ->
  $.Physics.applyImpulse($('#'+id), {x: 0, y: (amount*-1)})

jumpByNr = (nr, amount) ->
    jumpById('_'+nr, amount)

toogleCanvas = () ->
  if _live_debug_ is true
    _live_debug_ = false
    $('#canvasarium').hide()
  else
    _live_debug_ = true
    $('#canvasarium').show()

_default_segment_offset_ = _segment_offset_
toogleCalcIx = () ->
  _is_normalized_ = !(_is_normalized_)

  if _is_normalized_ is false
    _segment_offset_ = _non_normalized_segment_offset_
    _threshold_ = _non_normalized_threshold_
  else
    _segment_offset_ = _normalized_segment_offset_
    _threshold_ = _normalized_threshold_
  console.log(_is_normalized_)

$(document).keypress((e) ->
    key = e.keyCode or e.charCode
    console.log(key)
    if key is 100
      toogleCanvas()
    if key is 102
      toogleCalcIx()
    if (key >= 48 && key <= 57)
      jumpByNr(key - 48, 10)
    if key is 32
      ballJump()

)