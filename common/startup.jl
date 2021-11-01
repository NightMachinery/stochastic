reloadStartup() = include(ENV["HOME"] * "/.julia/config/startup.jl")
##
# using TerminalExtensions
##
using Pkg
##
const LOCAL_PACKAGES = expanduser("~/code/julia/")
push!(LOAD_PATH, LOCAL_PACKAGES)

try
    using Revise # needs to be before the packages it tracks
catch e
    @warn "Error initializing Revise" exception=(e, catch_backtrace())
end

using NightCommon
##
# Pkg.add("OhMyREPL")
# using OhMyREPL
##
using InteractiveUtils
InteractiveUtils.define_editor("editor-open", wait=false) do cmd, path, line
    `brishzq.zsh @opts f \[ $path \] l \[ $line \] no_wait y @ editor-open`
end
##
using BenchmarkTools, Infiltrator, FreqTables, RDatasets, Lazy, UUIDs, Printf, Distributions
##
using InteractiveCodeSearch
## Usage: https://github.com/tkf/InteractiveCodeSearch.jl#reference
# @search show             # # search method definitions
# @searchmethods 1         # search methods defined for integer
# @searchhistory           # search history (Julia ≥ 0.7)
# @searchreturn String Pkg # search methods returning a given type (Julia ≥ 0.7)

InteractiveCodeSearch.CONFIG.interactive_matcher = `fzf --bind 'shift-up:toggle+up,shift-down:toggle+down,tab:toggle,shift-tab:toggle+beginning-of-line+kill-line,alt-/:toggle-preview,ctrl-j:toggle+beginning-of-line+kill-line,ctrl-t:top,ctrl-a:select-all' --color=light --multi --hscroll-off 99999  --preview 'printf -- "%s " {} | command fold -s -w $FZF_PREVIEW_COLUMNS' --preview-window down:7:hidden`

# InteractiveCodeSearch.CONFIG.trigger_key = ')'      # insert "@search" on ')' (default)
# InteractiveCodeSearch.CONFIG.trigger_key = nothing  # disable shortcut
##
##
ENV["SHELL"] = outrs(`which dash`) # necessary for fzf's preview, and nice anyhow
##
vscI() = pushdisplay(VSCodeServer.InlineDisplay())
# Gadfly.GadflyDisplay() # zooming qtconsole does not effect this
# IJulia.InlineDisplay()
vscINo() = popdisplay()
##
more(content) = more(repr("text/plain", content))
# using Markdown
# more(content::Markdown.MD) = more(Markdown.term(Core.CoreSTDOUT(), content))
function more(content::AbstractString)
    runi(pipeline(`echo $(content)`, `less`))
    nothing
end
macro h(body)
    :(more(Core.@doc($(esc(body)))))
end
## Configuring REPL keybindings:
import REPL
import REPL.LineEdit

const mykeys = Dict{Any,Any}(
    # See [[/Applications/Julia-1.6.app/Contents/Resources/julia/share/julia/stdlib/v1.6/REPL/src/LineEdit.jl]]
    ##
    # [[kbd:M-<left>]]
    "\e[1;3D" => (s,o...)->(LineEdit.edit_move_word_left(s)),

    # [[kbd:M-<right>]]
    "\e[1;3C" => (s,o...)->(LineEdit.edit_move_word_right(s)),
)

function customize_keys(repl)
    repl.interface = REPL.setup_interface(repl; extra_repl_keymap = mykeys)
end

atreplinit(customize_keys)
###
# if ! @isdefined SunHasSet
#     bello() # Julia's first startup takes forever
# end
const SunHasSet = true ;
