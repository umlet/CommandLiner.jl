# CommandLiner.jl -- Julia Command Line UX

Julia is well-suited for interactive, REPL-like applications, as well as a viable replacement for many `bash` scripting workflows. This package aims to streamline and help customize the end user experience (UX) of such Julia command line applications.

*Scripting UX:*

* Maximally-local and flexible **option parsing**.

* Custom file extension groups like (as in `:jpeg` == "jpg" or "JPG" or "Jpeg")

* Terse and **deferred color output**

* **Interrupt** and **SIGPIPE** handling.

* Tweaks to specific **error message formats** aimed not at developers but at application end users.

*REPL UX:*

* Aliases for commonly used REPL **pipe workflows**.

* **Reverse assignment** in pipes (experimental).

* **Shortcut shell commands** in the Julia REPL mode (in progress).

<br>
<br>



### "Local" Option Parsing

Good option parsers for Julia exist, see [ArgParse.jl](https://github.com/carlobaldassi/ArgParse.jl) or [ArgMacros.jl](https://github.com/zachmatson/ArgMacros.jl) or [Getopt.jl](https://github.com/attractivechaos/Getopt.jl). CommandLiner's `getopt`/`getargs` use a C/GNU/[getopt](https://www.gnu.org/software/libc/manual/html_node/Getopt.html)-inspired approach. It
- supports **in-order** processing/parsing -- one can always randomly permute the option input later after all;
- is maximally **local** -- options are defined where the are being `if`-ed upon;
- checks and **converts** int/float types, and a string like `-8` is treated as an *argument* instead of an *option*.

In a script, you alternately call `getopt` to get an option like `-x`, and `getargs` to get its arguments:
```julia
function main()  # your main function
    while length(ARGS) > 0
        opt = getopt()
        if opt == "-x"
            args = getargs()
            ..
        elseif opt === nothing  # "naked" arguments without preceding option
            args = getargs()
            ..
        else
            error("unknown option")
        end
    end
end
```

- `getopt()` pops and returns the next option from ARGS; if no option is found (i.e., string not starting with "--" or "-"), returns `nothing` (the arguments that would possibly follow are "naked").
- `getargs()` returns all arguments up to the next option; must find at least 1.
- `getargs0()` returns all arguments up to the next option (0 or more).
- `getarg()` returns one argument (not as vector).
- `getargs("sfii")` returns a vector of 4 arguments, a string, a float and two integers. Fails if more or fewer arguments are encountered, or if types do not match.
- `getargs("si*")` return a vector with a string argument and 0+ ints.

if `stopatopt` is `false`, all command line strings are treated as arguments (default distinguishes between options and arguments).

if `mustexhaust` is `false`, you can read n arguments, and leave additional, "naked arguments" for later parsing (default fails if there are valid arguments left, i.e., if the next string in `ARGS` is not an option).

<br>
<br>



### File Extension Groups

`hasext(path, "jpeg")` and `hasext(path, :jpeg)` check for file extensions. The first (with a string) checks for identity; the latter checks whether a file extension belongs to a group like {"jpg", "jpeg", "jpe"}. You can define your own groups.

It supports piping (and thus `filter(hasext(..))`):

```julia
julia> "mypic.jpg" |> hasext(:jpeg)
true
```

[in progress]

<br>
<br>



### Terse and Deferred Color Output

Wrapper type with custom `print` (calling `printstyled`) that lets you defer coloring outputs. Terse syntax to make coloring less intrusive.

```julia
julia> x = Cbx("Hello", "r!")
Cbx("Hello", Base.Pairs{Symbol, Any, Tuple{Symbol, Symbol}, NamedTuple{(:color, :reverse), Tuple{Symbol, Bool}}}(:color => :light_red, :reverse => true))

julia> print(x)  # no printstyled needed!
```
..will output in red & inverted.

<br>
<br>



### Erroruser and @main Guard

`EnduserError` is an exception type meant to signal that the end user would not benefit from a full backtrace, e.g., with errors such as "file not found". Thrown with `erroruser(msg)`.

The function `hushexit(f::Function)` calls `f`, and suppresses SIGPIPE exceptions gracefully, handles <Ctrl+C>..

The macro `@main` is a shortcut for the file guard in a script; it calls **your** `main` function via `hushexit(main)`.

<br>
<br>



### Curry Hack

```julia
julia> import CommandLiner.Iter.Hack: map, filter

julia> [1,2,3] |> map(sqrt)
...
julia> [1,2,3] |> filter(isodd)
...
```

[Thanks to @mkitti on [Discourse](https://discourse.julialang.org/t/enlistment-for-corsairing-the-map-function-in-repl-main-only/96768) for this idea!]

CommandLiner also exports the names `filter_`, `map_` etc. as synonyms for the `Base.Iterators` variants; the underscore should resemble to-be-continued dots `...` 

<br>
<br>



### Reverse-Assign Hack

```julia
julia> x
ERROR: UndefVarError: `x` not defined

julia> ReverseAssign.enable()

julia> 1.0 |> sin |> cos |> sin |> :x
0.6181340709529279

julia> x
0.6181340709529279
```
It works by overwriting the function call operator for `Symbol`. We put our worries if this is safe into the laps of the gods.




<br>
<br>
<br>
<br>

#### Version History
* 0.3 Colors; extensions
* 0.2 Initial version: command line options; enduser error; curry and reverse-assign hacks; tests