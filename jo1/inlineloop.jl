using InteractiveUtils

function genF(x, y)
    @inline function f()
        if rand() <= 0.5
            return x
        else
            return y
        end
    end
    return f
end

const fOK = genF(1111111111, 222222222)
function r2()
    fOK()
end

let
    f = genF(333333, 7777777)
    function r()
        f()
    end
    function r3()
        const global f2 = genF(0, 5555555)
        return f2()
    end


    println(@code_lowered r())
    println("----------")
    println(@code_typed optimize = false r())
    println("----------")
    println(@code_typed r())
    println("----------")
    println(@code_llvm r())

    println("**********************")

    println(@code_lowered r2())
    println("----------")
    println(@code_typed r2())
    println("----------")
    println(@code_llvm r2())

    println("^^^^^^^^^^^^^^^^^^^^^^^^")

    println(@code_lowered r3())
    println("----------")
    println(@code_typed r3())
    println("----------")
    println(@code_llvm r3())
end