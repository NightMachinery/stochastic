function tsendall() {
    dirs=( "$@" )
    (( $#dirs == 0 )) && return 1
    tlg-file-captioned ${^dirs}/**/(all|timeseries).(mp4|png)(N)
}
function ani() {
    imgdirs2vid "${^@}"/all
}
function ani-ts() {
    ani "$@"
    tsendall "$@"
    bello
}
