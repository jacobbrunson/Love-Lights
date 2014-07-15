#LOVE Lights
A LÖVE 2D lighting and shadows demo

###Controls
* Left-Click: Place light
* Right-Click: Drag block
* A/D: Cycle light hue
* W/S: Change light sizes
* Z: Remove light
* F: Spawn blocks
* R: Remove blocks
* G: Toggle gravity
* Arrow keys: Move blocks

###How it works
It's actually very simple.

    For every light
      For every block
         Iterate over edges of block, calculating the shadow for each edge
         Draw the shadows to the inverted stencil
      Turn on shader and additive blending
      Draw a fullscreen rectangle (shader renders the light with some simple math)
    Change blending mode to multiply
    Render every block with color
