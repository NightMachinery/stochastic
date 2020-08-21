using  Distributions
##
p = [[6 5 3 1]
    [3 6 2 2]
    [3 4 3 1]]
##
s = [[1.5 1]
    [2 2.5]
    [5 4.5]
    [16 17]]

r = p * s
rb = mapslices(r, dims=[2]) do x
    s1, s2 = x
    s1 >= s2
end
# good macros here https://gist.github.com/MikeInnes/8299575
more(content) = more(repr("text/plain", content))
# using Markdown
# more(content::Markdown.MD) = more(Markdown.term(Core.CoreSTDOUT(), content))
function more(content::AbstractString)
    run(pipeline(`echo $(content)`, `less`))
    nothing
end
macro d(body)
    :(more(Core.@doc($(esc(body)))))
end
##
module tmp
begin
    println(55)
    @error "hi"
    println(56)
end
end
##
using ForceImport
@force using Luxor
mkpath("luxor/tmp/")
Drawing(600, 400, "luxor/tmp/julia-logos.png")
origin()
background("white")
for θ in range(0, step=π / 8, length=16)
    gsave()
    scale(0.25)
    rotate(θ)
    translate(250, 0)
    randomhue()
    julialogo(action=:fill, color=false)
    grestore()
end

gsave()
scale(0.3)
juliacircles()
grestore()

translate(200, -150)
scale(0.3)
julialogo()
finish()
preview()
##
using Base.Iterators, ColorSchemes
r = 500
Drawing(r * 2,r * 2)
background("white")
origin()
function triangle(points, degree)
    sethue(cols[degree])
    poly(points, :fill)
end

function sierpinski(points, degree)
    triangle(points, degree)
    if degree > 1
        p1, p2, p3 = points
        sierpinski([p1, midpoint(p1, p2),
                        midpoint(p1, p3)], degree - 1)
        sierpinski([p2, midpoint(p1, p2),
                        midpoint(p2, p3)], degree - 1)
        sierpinski([p3, midpoint(p3, p2),
                        midpoint(p1, p3)], degree - 1)
    end
end

depth = 13 # 12 is ok, 20 is right out (on my computer, at least)
cols = [get(ColorSchemes.diverging_bky_60_10_c30_n256, i) for i in range(0, stop=1, length=depth + 1) ] # distinguishable_colors(depth+2) # from Colors.jl
function draw(n)
    sethue(cols[end])
    circle(O, r, :fill)
    circle(O, r, :clip)
    points = ngon(O, r * 2, 3, -π / 2, vertices=true)
    sierpinski(points, n)
end

draw(depth)

finish()
preview()
##
mw = 600
mh = 600
ms = 2
Drawing(mw,mw)
scale(ms)
# origin()
background("white")
sethue("blue")
text("hello world", 10,50)
textcentered("I am CENTER!", mw / 2 / ms,10)
settext("<span font='19' background ='green' foreground='white'><b>#456</b></span>", Point(200,200) ; markup=true, halign="center", valign="center")
translate(100,100)
circle(0,0,60, :fillstroke)
sethue("purple")
setline(70)
circle(0,0,60, :stroke)
finish()
preview()
