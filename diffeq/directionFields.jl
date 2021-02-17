# 3D example: http://juliaplots.org/MakieReferenceImages/gallery//streamplot_3d/index.html
# bigger gridsize increases the "resolution" of direction arrows
##
using Makie 
using AbstractPlotting
using AbstractPlotting.MakieLayout
AbstractPlotting.inline!(true)
odeSol(x,y) = Point(-x, 2y) # x'(t) = -x, y'(t) = 2y
scene = Scene(resolution=(400, 400))
streamplot!(scene, odeSol, -2..2, -2..2, colormap=:plasma, 
    gridsize=(32, 32), arrow_size=0.07)
save("tmp/plots/diffeqs/odeField.png", scene)
##
using Makie 
using AbstractPlotting
using AbstractPlotting.MakieLayout
AbstractPlotting.inline!(true)
odeSol(x,y) = Point(1, x + y) # x'(t) = -x, y'(t) = 2y
scene = Scene(resolution=(900, 900))
streamplot!(scene, odeSol, -2..2, -2..2, 
    colormap=:plasma, 
    gridsize=(45, 45), arrow_size=0.05)
save("tmp/plots/diffeqs/odeField.png", scene)