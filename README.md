# Image-Processing-In-Microscopy
Course material for "Image Processing in Microscopy" at the Friedrich Schiller University in Jena in the winter term 2021/22

## Organisation

### Course Registration
Officially, over [Friedolin](https://friedolin.uni-jena.de/qisserver/rds?state=verpublish&status=init&vmfile=no&publishid=187964&moduleCall=webInfo&publishConfFile=webInfo&publishSubDir=veranstaltung).

### Seminars
* 15.10.21: Seminar 01 about the basics of Julia and how to use it
     * [examples/seminars/S01.jl](examples/seminars/S01.jl)


### Homework
* 15.10.21: Homework 01 about adding and removing Noise (more will follow later in this course)
     * [examples/homeworks/HW01.jl](examples/homeworks/HW01.jl)
     * submit `HW01.jl` on Moodle until: Wednesday 27.10.21 @ 1PM 

## Code
To download the files, we recommend `git`:
```
git clone git@github.com:bionanoimaging/Image-Processing-In-Microscopy.git
```

### Julia Installation
Download the recent version 1.6.3 on the [Julia Website](https://julialang.org/downloads/).
We recommend using [Visual Studio Code](https://www.julia-vscode.org/), especially install the Julia plugin for VSCode.
Also check out the [documentation](https://docs.julialang.org/en/v1/manual/performance-tips/). It is the best resource for julia because many other pages are outdated.

### Activate Environment
Open the downloaded source folder with VSCode.
In the top right of VSCode there should be three dots (...). Try to click `Julia: Activate Parent Environment`.
At the bottom, a Julia REPL should open.
Try to type:
```julia
julia> ] st
```
which should result in similar output:
```julia
(ImgProcMic) pkg> st
     Project ImgProcMic v0.1.0
      Status `~/Image-Processing-In-Microscopy/Project.toml`
  [3da002f7] ColorTypes v0.11.0
  [5ae59095] Colors v0.12.8
  [717857b8] DSP v0.7.3
  [6a3955dd] ImageFiltering v0.7.0
  [4e3cecfd] ImageShow v0.3.2
  [613c443e] IndexFunArrays v0.2.3
  [91a5bcdd] Plots v1.22.4
  [c3e4b0f8] Pluto v0.16.1
  [cb4044da] PlutoTest v0.1.2
  [7f904dfe] PlutoUI v0.7.15
  [e409e4f3] PoissonRandom v0.4.0
  [5e47fb64] TestImages v1.6.1
  [8dfed614] Test
```
(If not, the following steps will obviously fail).
Try to instantiate the packages with:
```julia
(ImgProcMic) pkg> instantiate
```
Once you did that, go back to the normal REPL by pressing the `backspace` key:
```julia
julia> using Pluto

julia> Pluto.run()

Opening http://localhost:1235/?secret=sdCsckRR in your default browser... ~ have fun!

Press Ctrl+C in this terminal to stop Pluto
```

A browser should open from where you can try to open a notebook.
