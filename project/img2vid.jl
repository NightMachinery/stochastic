# alt: https://juliaio.github.io/VideoIO.jl/latest/writing/

using Images

function writevideo(fname, imgstack::Array{<:Color,3};
                    overwrite=true, fps=30::UInt, options=``)
    ow = overwrite ? `-y` : `-n`
    h, w, nframes = size(imgstack)

    open(`ffmpeg
            -loglevel warning
            $ow
            -f rawvideo
            -pix_fmt rgb24
            -s:v $(h)x$(w)
            -r $fps
            -i pipe:0
            $options
            -vf "transpose=0"
            -pix_fmt yuv420p
            $fname`, "w") do out
        for i = 1:nframes
            write(out, convert.(RGB{N0f8}, clamp01.(imgstack[:,:,i])))
        end
    end
end