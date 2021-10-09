### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ ef0ea97c-2f40-4d14-9e8d-8e70dcae16e3
begin
	using Pkg
	Pkg.activate("../../.")
	using Revise
end

# ╔═╡ ecfe7e0c-2918-11ec-3510-65601e1a6072


# ╔═╡ b88049f8-3064-4d18-b8f7-47e12a3ddc2f
md"## Julia Lang
* A relatively new dynamic programming language (≈ 3 years since 1.0)
* General purpose and high level language
* Core paradigm is *Multiple Dispatch*
* Performance comparable to C/C++/Fortran
* For example: *for loops* don't have a performance penalty
### Reasons for Speed
* JIT - Just in Time compilation
* type stable functions
* because of the type system Julia can compile efficient code
### Helpfuls resources
* However, severalc differences to other languages
* Consult [performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/)
* [Noteworthy differences to other language](https://docs.julialang.org/en/v1/manual/noteworthy-differences/)
* Ecosystem for image processing for microscopy data is small
### Some important packages
* [Bioformatsloader.jl](https://github.com/ahnlabb/BioformatsLoader.jl)
* [View5D.jl](https://github.com/RainerHeintzmann/View5D.jl)
* [DeconvOptim.jl](https://github.com/roflmaostc/DeconvOptim.jl)
* [Images.jl](https://github.com/JuliaImages/Images.jl/)
* [Napari.jl](https://github.com/mkitti/Napari.jl)
* [FourierTools.jl](https://github.com/bionanoimaging/FourierTools.jl)
* [TestImages.jl](https://github.com/JuliaImages/TestImages.jl)
"


# ╔═╡ c16d830f-5a29-46f8-b97b-e66fb60e7a99
md"### Activating our environment to get the correct versions" 

# ╔═╡ d25c41da-613b-44d4-aded-a9b254720a37
Pkg.status()

# ╔═╡ a4890dd2-5f8b-48bd-a237-4b803bdc3e2c


# ╔═╡ 97947b8a-a8e9-423c-8330-37ccf1b50a02
md"## Load TestImages"

# ╔═╡ 1d0ecaa4-2c36-4197-a527-3e1616b3d42f


# ╔═╡ 443ebbab-b5f9-4222-8590-051a2e63be50


# ╔═╡ 1c706eee-7664-43aa-9ca6-ba7ba05d3fce
md"## Modify Arrays"

# ╔═╡ b01daaa3-e9ed-4bc7-b908-c14ac5a94ad8


# ╔═╡ 5a366aef-18c6-4975-97e0-c0231f2bcffc


# ╔═╡ fa0d093d-21a5-42b5-9ea7-9bd86404c565
md"## Create Functions"

# ╔═╡ ac66a808-15a4-4ac2-b534-1a0310650577


# ╔═╡ 37ba1b25-c44c-4fd7-8903-3b926cb2b935


# ╔═╡ bdd574e9-0e43-4f75-a703-cdaa823777ab
md"## Show Images"

# ╔═╡ c7c8ad71-35f3-43e4-8cb0-cbeeba741d3b


# ╔═╡ 6e7f40ba-e3b7-482b-94f0-a3d45301f9f3


# ╔═╡ 55cd6649-1058-4d76-b88d-97bcdb230847
md"## Ploting"

# ╔═╡ c7ed12a9-83eb-4059-90cb-65734e1f0da3


# ╔═╡ cf7d48cc-7461-4afb-8895-7e197184902c


# ╔═╡ 807a0336-ecff-4b01-8fbf-a31b28a4f8fc


# ╔═╡ Cell order:
# ╠═ecfe7e0c-2918-11ec-3510-65601e1a6072
# ╟─b88049f8-3064-4d18-b8f7-47e12a3ddc2f
# ╠═c16d830f-5a29-46f8-b97b-e66fb60e7a99
# ╠═ef0ea97c-2f40-4d14-9e8d-8e70dcae16e3
# ╠═d25c41da-613b-44d4-aded-a9b254720a37
# ╠═a4890dd2-5f8b-48bd-a237-4b803bdc3e2c
# ╠═97947b8a-a8e9-423c-8330-37ccf1b50a02
# ╠═1d0ecaa4-2c36-4197-a527-3e1616b3d42f
# ╠═443ebbab-b5f9-4222-8590-051a2e63be50
# ╠═1c706eee-7664-43aa-9ca6-ba7ba05d3fce
# ╠═b01daaa3-e9ed-4bc7-b908-c14ac5a94ad8
# ╠═5a366aef-18c6-4975-97e0-c0231f2bcffc
# ╠═fa0d093d-21a5-42b5-9ea7-9bd86404c565
# ╠═ac66a808-15a4-4ac2-b534-1a0310650577
# ╠═37ba1b25-c44c-4fd7-8903-3b926cb2b935
# ╠═bdd574e9-0e43-4f75-a703-cdaa823777ab
# ╠═c7c8ad71-35f3-43e4-8cb0-cbeeba741d3b
# ╠═6e7f40ba-e3b7-482b-94f0-a3d45301f9f3
# ╠═55cd6649-1058-4d76-b88d-97bcdb230847
# ╠═c7ed12a9-83eb-4059-90cb-65734e1f0da3
# ╠═cf7d48cc-7461-4afb-8895-7e197184902c
# ╠═807a0336-ecff-4b01-8fbf-a31b28a4f8fc
