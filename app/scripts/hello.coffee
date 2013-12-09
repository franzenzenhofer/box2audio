console.log "'Allo from CoffeeScript!"

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
  context = new AudioContext()
  analyser = context.createAnalyser()
  source = context.createMediaStreamSource( stream )
  source.connect(analyser);
  watchLoop(analyser)

watchLoop = (analyser) ->
  loop_id = window.requestAnimationFrame((()->
    watchLoop(analyser)))

  freqByteData = new Uint8Array(analyser.frequencyBinCount)
  analyser.getByteFrequencyData(freqByteData)
  actionables(freqByteData )

#_m_o_d_ = Math.floor(1024/10)
actionables = (d) ->
  #console.log(d.length)
  #console.log(d)
  a = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  for x, i in d
    do (x, i) ->
      m = Math.floor(i/20.48)
      a[m] = a[m]+x

  #console.log(a)
  highest_val = 0
  segment = 0
  for y,j in a
    if y > highest_val
      highest_val = y
      segment = j

  #segment = segment + 1
  if segment is 10 then segment = 0
  #console.log(segment)
  if highest_val > 1000
    jumpByNr(segment)

  #debugger 
  return true





$('document').ready(
  for x in [1...11]
    do(x) ->
      if x is 10 then x = 0
      $('#bottom').append('<div class="sound"
            data-box2d-passive="true"
            data-box2d-density="1"
            data-box2d-restitution="0.1" 
            data-box2d-friction="0.3"
      id="_'+x+'">'+x+'.</div>')
  
  $('.sound').box2d(
    'y-velocity':10
    ).on('click', () -> $.Physics.applyImpulse($(@), {x: 0, y: -10}))
   $('.circle').box2d()

   navigator.getUserMedia( {audio:true}, gotStream, (()->) )
)

jumpById = (id, amount = 1) ->
  $.Physics.applyImpulse($('#'+id), {x: 0, y: (amount*-1)})

jumpByNr = (nr, amount) ->
  jumpById('_'+nr, amount)


$(document).keypress((e) ->
    key = e.keyCode or e.charCode;
    if (key >= 48 && key <= 57)
      jumpByNr(key - 48, 10)
)