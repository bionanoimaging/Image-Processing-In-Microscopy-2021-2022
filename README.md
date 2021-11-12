* **`git pull` always the repository**
* **We had to update the dependencies, therefore activate the main environment and call `julia> ] instantiate`**

# Image-Processing-In-Microscopy
Course material for "Image Processing in Microscopy" at the Friedrich Schiller University in Jena in the winter term 2021/22

## Organisation
See [Moodle](https://moodle.uni-jena.de/course/view.php?id=19441) for more details about the course itself.

### Course Registration
Officially, over [Friedolin](https://friedolin.uni-jena.de/qisserver/rds?state=verpublish&status=init&vmfile=no&publishid=187964&moduleCall=webInfo&publishConfFile=webInfo&publishSubDir=veranstaltung).

### Seminars
* 22.10.21: Seminar 01 about the basics of Julia and how to use it
     * [examples/seminars/S01_part1.jl](examples/seminars/S01_part1.jl)
* 29.10.21: Q&A
     * [examples/seminars/S01_part2.jl](examples/seminars/S01_part2.jl)
* 12.11.21: Q&A
     * [examples/seminars/S02.jl](examples/seminars/S02.jl)

### Homework
* 22.10.21: Homework 01 about adding and removing Noise (more will follow later in this course)
     * [examples/homeworks/HW01.jl](examples/homeworks/HW01.jl)
     * Solution [examples/homeworks/HW01_solution.jl](examples/homeworks/HW01_solution.jl)
     * submit `HW01.jl` on Moodle until: Wednesday 3.11.21 @ 1PM
     * See [here](https://github.com/bionanoimaging/Image-Processing-In-Microscopy/issues/1) for clarification of `add_poisson!
  
* 5.11.21: Homework 02 about color maps and sensor calibration
     * [examples/homeworks/HW02.jl](examples/homeworks/HW02.jl) 
     * submit `HW02.jl` on Moodle until: Wednesday 19.11.21 @ 1PM 


## Code
To download the files, we recommend `git`:
```
git clone git@github.com:bionanoimaging/Image-Processing-In-Microscopy.git
```
Usually via a _git pull_ you can update the code. If anything goes wrong which you can't fix, clone it again to a new folder.


### Julia Installation
Download the recent version 1.6.3 on the [Julia Website](https://julialang.org/downloads/).

#### Editor
We recommend using [Visual Studio Code](https://www.julia-vscode.org/), especially install the Julia and git plugin for VSCode.

#### Documentation 
Also check out the [documentation](https://docs.julialang.org/en/v1/manual/performance-tips/). It is the best resource for julia because many other pages are outdated.

##### Cheatsheet
There is a [Cheatsheet](https://juliadocs.github.io/Julia-Cheat-Sheet/) available.

### Activate Environment
Open the downloaded source folder with VSCode. Open the file `src/ImgProcMic.jl`.
In the top right of VSCode there should be now three dots (...). Try to click `Julia: Activate Parent Environment`.
At the bottom, a Julia REPL should open.
Try to type:
```julia
julia> ] st
```
which should result in similar output. (The `]` switches Julia to the package manager mode. By deleting you go back to normal terminal).
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
(ImgProcMic) julia> ] add PlutoTest # caused some issues some time ago

(ImgProcMic) julia> ] instantiate
```
Once you did that, go back to the normal REPL by pressing the `backspace` key:
```julia
julia> using Pluto

julia> Pluto.run()

Opening http://localhost:1235/?secret=sdCsckRR in your default browser... ~ have fun!

Press Ctrl+C in this terminal to stop Pluto
```

A browser should open from where you can try to open a notebook.
