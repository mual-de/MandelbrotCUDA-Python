import MandelbrotCUDA
import numpy as np
from PIL import Image, ImageDraw
from timeit import default_timer as timer

config = MandelbrotCUDA.MandelbrotConfig()
config.height = 16384
config.width = 16384
config.reMin = -1.0
config.reMax = 0.6
config.imMin = -0.4
config.imMax = 1.4
config.maxIter = 200
config.maxSqr = 2.0


start = timer()
# Create via CPU based function
#res = MandelbrotCUDA.createMandelbrotCPU(config)

# Create via GPU based function
#res = MandelbrotCUDA.createMandelbrotCUDA(config)

#colorize the output from cpu or gpu
#resColor = MandelbrotCUDA.colorizeMandelbrotThrust(res, config.maxIter)

# A complete implementation in CUDA doint createMandelbrotCUDA and colorizeMandelbrotThrust
# in one step with optimized memory transfer
colors = MandelbrotCUDA.createMandelbrotCUDAColorized(config)
end = timer()

print("Runtime is: %s" %(end - start))

im = Image.new('RGB', (config.width, config.height), (0, 0, 0))
draw = ImageDraw.Draw(im)

for y in range(config.height):
    ypos = y * config.width
    for x in range(config.width):
        r = colors[0][x + ypos]
        g = colors[1][x + ypos]
        b = colors[2][x + ypos]
        draw.point([x,y], (r, g, b))

im.save("temp.png", 'PNG')