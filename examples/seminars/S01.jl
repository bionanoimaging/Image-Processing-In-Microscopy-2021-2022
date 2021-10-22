### A Pluto.jl notebook ###
# v0.16.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ ecfe7e0c-2918-11ec-3510-65601e1a6072
begin
	using Pkg
	Pkg.activate("../../")
	using Revise
end

# ╔═╡ 110ceade-2a17-4e2f-a156-063fcbdf214f
using TestImages, ImageShow

# ╔═╡ c5851e01-65ce-4d34-9a3d-2e99d2a9bc8a
using Colors

# ╔═╡ c7ed12a9-83eb-4059-90cb-65734e1f0da3
using Plots

# ╔═╡ 4c848822-0937-49de-9317-d8ad59b232c0
using PlutoUI

# ╔═╡ 77cf9d3e-b113-413a-ace1-acde66e580e2
md"# Image Processing in Microscopy

* Lecturer: Rainer Heintzmann
* Teaching assistant: Felix Wechsler (felix.wechsler@uni-jena.de)
* Forum on moddle
* Code on GitHub (https://github.com/bionanoimaging/Image-Processing-In-Microscopy, also on Moodle)
"

# ╔═╡ d45db367-4e34-4c47-adc6-a027b4cd3326


# ╔═╡ 2c3a637e-8149-4839-a79a-bc765da81972


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
* However, several differences to other languages
* There is not a `numpy` package since many parts in the language are fast by itself (arrays, Linear Algebra, ...)
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
img = testimage("resolution_test_512")

# ╔═╡ 4b4008ab-6c4f-4766-9cc9-9b730a3c66d3
testimage

# ╔═╡ 443ebbab-b5f9-4222-8590-051a2e63be50
typeof(img)

# ╔═╡ 85ef3691-e89e-4323-8914-b123006dca69
Matrix{Float64} === Array{Float64, 2} # matrix is 2 dimensional array

# ╔═╡ 1c706eee-7664-43aa-9ca6-ba7ba05d3fce
md"## Modify Arrays"

# ╔═╡ 2c5b549e-d217-494f-88d0-587b3282e1c7
x = 0

# ╔═╡ a3511f2c-31bd-4e42-b1a4-5113aaa50e2c
sin(x)

# ╔═╡ 3da31838-ec8e-4f91-9bcf-7d0c5d761a1f
xs = [0, pi / 2, pi, 3/2 * pi]

# ╔═╡ 597ebb46-6ba6-48a2-846b-61185ed24f97
sin.(xs)

# ╔═╡ 3394ee97-fdef-4713-b132-338a991646e5
Float32(1)

# ╔═╡ a31eaa22-0baf-40a1-9417-981d2384b01c
1e-1 # 1 * 10^(-1) but as a Float64

# ╔═╡ baff6b11-f1d5-40fc-ac10-05af6ba0c178
1f-1 # 1 * 10^(-1) but as a Float32

# ╔═╡ 06147f5c-c8c0-49e3-861c-30bd345cf389
arr = Float32.(img)

# ╔═╡ 0c545a78-7eea-4470-a529-5cf2c4e27f84
arr[200, 100] 

# ╔═╡ b01daaa3-e9ed-4bc7-b908-c14ac5a94ad8
sub_image = arr[100:200, 100:200]

# ╔═╡ 5a366aef-18c6-4975-97e0-c0231f2bcffc
Gray.(sub_image)

# ╔═╡ fa0d093d-21a5-42b5-9ea7-9bd86404c565
md"## Create Functions"

# ╔═╡ ac66a808-15a4-4ac2-b534-1a0310650577
function foo(x)
	return x + 1.0
end

# ╔═╡ 0e9e362a-7e86-4d78-b33b-ecb975a4314d
function foo_better(x)
	return x + one(x)
	# hello for comments
end

# ╔═╡ 37ba1b25-c44c-4fd7-8903-3b926cb2b935
foo(100)

# ╔═╡ 1e7de4e0-2adb-4aa1-9b53-9236b28a992e
foo(100.0)

# ╔═╡ 0e0fff8b-106d-4a5c-8111-0f3f07ab788c
typeof(1)

# ╔═╡ 2da94408-2168-467c-b12d-d8bb311c2dbe
typeof(foo(1))

# ╔═╡ 031d02b1-4a40-44ce-925e-aadc5c3807e0
typeof(foo_better(1))

# ╔═╡ 4db99cc6-c6f8-4c78-b219-31dcf05751ef
foo.(ones(Float32, (10,10)));

# ╔═╡ 2f22eab7-8032-4cfa-9889-a91b73c8992b
foo(100.0f0)

# ╔═╡ c7c8ad71-35f3-43e4-8cb0-cbeeba741d3b


# ╔═╡ 6e7f40ba-e3b7-482b-94f0-a3d45301f9f3
md"## Why we use Pluto"

# ╔═╡ c91d6219-25d9-4658-8a96-01fe0acdaf99
a = 100_000_000_000

# ╔═╡ 9b7c2a27-f85d-4dcd-98f9-35a076f4fe45
b = -10000000000

# ╔═╡ 536245a4-6c85-4999-bcff-82053b5e1a24
c = a + b

# ╔═╡ 55cd6649-1058-4d76-b88d-97bcdb230847
md"## Ploting"

# ╔═╡ cf7d48cc-7461-4afb-8895-7e197184902c
x2s = 0:0.01:10

# ╔═╡ ab502d9d-4823-471b-b70d-402192714721
(0:10000000000000000000000000000000)[1000]

# ╔═╡ 8c53a3f9-dd6a-4874-b592-f8452ad03a4b
typeof(x2s)

# ╔═╡ 9f4dbf6e-4b8b-4255-a854-6f92cf1e5271
typeof(collect(x2s))

# ╔═╡ 964efb64-b61c-407f-8096-136cd9b0d27c
@bind offset Slider(0:0.1:5, show_value=true)

# ╔═╡ 125facd6-0ad2-4d9a-9056-c0d697bc5396
@bind scaling Slider(0.1:0.1:5, show_value=true)

# ╔═╡ 807a0336-ecff-4b01-8fbf-a31b28a4f8fc
begin
	plot(x2s, sin.(scaling .* x2s .+ offset))
	plot!(x2s, 0.01 .* x2s .^2 )
end

# ╔═╡ 675d49fd-d88f-4933-a27e-db294b3f3130
md"## FFTs"

# ╔═╡ 47d83dca-043b-4099-b4ef-672835412256


# ╔═╡ 88d9de0f-faf6-4d75-84ae-25f79ced49e5


# ╔═╡ 26c178d8-fd80-4a57-9f3f-d7fb170daf86
md"## Interactivity with Pluto"

# ╔═╡ 387bba27-f791-4f2b-814b-2c42c19b3523
# live docs

# ╔═╡ f6b8f22b-1ee7-4332-8bbf-55fc9afb0af4


# ╔═╡ 4b49e628-96b7-454b-bed5-ac66eef97a56


# ╔═╡ 48658d4d-1bc3-4fd1-ba4d-508174c03442


# ╔═╡ 204ac4ea-9359-42ff-ae9a-712a151391b0


# ╔═╡ Cell order:
# ╠═ecfe7e0c-2918-11ec-3510-65601e1a6072
# ╠═77cf9d3e-b113-413a-ace1-acde66e580e2
# ╠═d45db367-4e34-4c47-adc6-a027b4cd3326
# ╠═2c3a637e-8149-4839-a79a-bc765da81972
# ╟─b88049f8-3064-4d18-b8f7-47e12a3ddc2f
# ╠═c16d830f-5a29-46f8-b97b-e66fb60e7a99
# ╠═d25c41da-613b-44d4-aded-a9b254720a37
# ╠═a4890dd2-5f8b-48bd-a237-4b803bdc3e2c
# ╟─97947b8a-a8e9-423c-8330-37ccf1b50a02
# ╠═110ceade-2a17-4e2f-a156-063fcbdf214f
# ╠═1d0ecaa4-2c36-4197-a527-3e1616b3d42f
# ╠═4b4008ab-6c4f-4766-9cc9-9b730a3c66d3
# ╠═443ebbab-b5f9-4222-8590-051a2e63be50
# ╠═85ef3691-e89e-4323-8914-b123006dca69
# ╠═1c706eee-7664-43aa-9ca6-ba7ba05d3fce
# ╠═2c5b549e-d217-494f-88d0-587b3282e1c7
# ╠═a3511f2c-31bd-4e42-b1a4-5113aaa50e2c
# ╠═3da31838-ec8e-4f91-9bcf-7d0c5d761a1f
# ╠═597ebb46-6ba6-48a2-846b-61185ed24f97
# ╠═3394ee97-fdef-4713-b132-338a991646e5
# ╠═a31eaa22-0baf-40a1-9417-981d2384b01c
# ╠═baff6b11-f1d5-40fc-ac10-05af6ba0c178
# ╠═06147f5c-c8c0-49e3-861c-30bd345cf389
# ╠═0c545a78-7eea-4470-a529-5cf2c4e27f84
# ╠═b01daaa3-e9ed-4bc7-b908-c14ac5a94ad8
# ╠═c5851e01-65ce-4d34-9a3d-2e99d2a9bc8a
# ╠═5a366aef-18c6-4975-97e0-c0231f2bcffc
# ╠═fa0d093d-21a5-42b5-9ea7-9bd86404c565
# ╠═ac66a808-15a4-4ac2-b534-1a0310650577
# ╠═0e9e362a-7e86-4d78-b33b-ecb975a4314d
# ╠═37ba1b25-c44c-4fd7-8903-3b926cb2b935
# ╠═1e7de4e0-2adb-4aa1-9b53-9236b28a992e
# ╠═0e0fff8b-106d-4a5c-8111-0f3f07ab788c
# ╠═2da94408-2168-467c-b12d-d8bb311c2dbe
# ╠═031d02b1-4a40-44ce-925e-aadc5c3807e0
# ╠═4db99cc6-c6f8-4c78-b219-31dcf05751ef
# ╠═2f22eab7-8032-4cfa-9889-a91b73c8992b
# ╠═c7c8ad71-35f3-43e4-8cb0-cbeeba741d3b
# ╠═6e7f40ba-e3b7-482b-94f0-a3d45301f9f3
# ╠═c91d6219-25d9-4658-8a96-01fe0acdaf99
# ╠═9b7c2a27-f85d-4dcd-98f9-35a076f4fe45
# ╠═536245a4-6c85-4999-bcff-82053b5e1a24
# ╠═55cd6649-1058-4d76-b88d-97bcdb230847
# ╠═c7ed12a9-83eb-4059-90cb-65734e1f0da3
# ╠═cf7d48cc-7461-4afb-8895-7e197184902c
# ╠═ab502d9d-4823-471b-b70d-402192714721
# ╠═8c53a3f9-dd6a-4874-b592-f8452ad03a4b
# ╠═9f4dbf6e-4b8b-4255-a854-6f92cf1e5271
# ╠═4c848822-0937-49de-9317-d8ad59b232c0
# ╠═964efb64-b61c-407f-8096-136cd9b0d27c
# ╠═125facd6-0ad2-4d9a-9056-c0d697bc5396
# ╠═807a0336-ecff-4b01-8fbf-a31b28a4f8fc
# ╠═675d49fd-d88f-4933-a27e-db294b3f3130
# ╠═47d83dca-043b-4099-b4ef-672835412256
# ╠═88d9de0f-faf6-4d75-84ae-25f79ced49e5
# ╠═26c178d8-fd80-4a57-9f3f-d7fb170daf86
# ╠═387bba27-f791-4f2b-814b-2c42c19b3523
# ╠═f6b8f22b-1ee7-4332-8bbf-55fc9afb0af4
# ╠═4b49e628-96b7-454b-bed5-ac66eef97a56
# ╠═48658d4d-1bc3-4fd1-ba4d-508174c03442
# ╠═204ac4ea-9359-42ff-ae9a-712a151391b0
