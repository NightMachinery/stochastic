ϵ0 = 8.85 * 10 * -12
e_k = 8.99 * 10^9
FE(q1, q2, r)::Number = e_k * (abs(q1) * abs(q2) / abs2(r))
q_e = 1.6 * 10^-19
#
g_k = 6.67 * 10^-11
FG(m1, m2, r) = g_k * (m1 * m2 / abs2(r))
m_e = 1.67 * 10^-27
#
function FV(forceFn, p1, p2)
    r = mag2(p2 - p1)
    m1 = p1[3]
    m2 = p2[3]
    force = forceFn(m1, m2, r)
    angle = atan(p2[2] - p1[2], p2[1] - p1[1]) # so this force is from p1 towards p2
    # angle = atan(p1[2] - p2[2], p1[1] - p2[1]) # so this force is from p2 towards p1
    @labeled (angle |> rad2deg) 
    @labeled force * cos(angle)
    @labeled force * sin(angle)
    return [force * cos(angle), force * sin(angle)] * sign(m1) * sign(m2)
end
function fnMul(f, v)
    function f2(args... ; kargs...)
        return v * f(args... ; kargs...)
    end
    return f2
end
FVE(args...) = FV(fnMul(FE, -1), args...)
## 
# c21.p11:
a = 0.05
q1 = [0, a, 100 * 10^-9]
q2 = [a, a, -100 * 10^-9]
q3 = [0, 0, 200 * 10^-9]
q4 = [a, 0, -200 * 10^-9]
f31 = FVE(q3, q1)
f32 = FVE(q3, q2)
f34 = FVE(q3, q4)
f3net = f31 + f32 + f34
##
r_core = 4 * 10^-15
fee = FE(q_e, q_e, r_core) 
fee_g = FG(m_e, m_e, r_core)