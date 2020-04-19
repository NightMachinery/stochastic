p = [[6 5 3 1]
    [3 6 2 2]
    [3 4 3 1]]

s = [[1.5 1]
    [2 2.5]
    [5 4.5]
    [16 17]]

r = p*s
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
