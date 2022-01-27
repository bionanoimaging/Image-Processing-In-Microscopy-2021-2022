### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 250252f0-6e61-11ec-2ffe-ebddaa9f0fb3
begin
	using Pkg 
	Pkg.activate("../../")
	using Revise
end

# ╔═╡ 0eeb5bb1-bb41-43cc-8c14-eb9c1ebf6fad
using ImgProcMic, FourierTools, IndexFunArrays, ImageShow, FFTW, TestImages, Colors

# ╔═╡ 1b2ebe1a-f3a7-494c-bcca-18df5403ee65
using PlutoTest, Noise, Tullio, PlutoUI, Images, Plots

# ╔═╡ 4aeceb65-f226-41cf-988b-273f42c75059
using SpecialFunctions

# ╔═╡ c11d25d8-8fe9-476e-9a6d-66f625f29348
md"# 1 Convolution with Small Kernels

When the kernel (e.g. the PSF) of a convolution is spatially very small (e.g. $3 \times 3$), it is more efficient to perform the convolution with a sum approach (_for loops_) in real space.

In this part, you implement the convolution via the sum approach.

You will notice that the question arises, how to treat the boundary pixels. We follow the approach, that the output image is smaller than the input image. This is due to the reason that we only convolve inside the image where the kernel fits completely in.

If you need a graphical visualization, see [here](https://kharshit.github.io/img/edge_detection.png).
"

# ╔═╡ 6f87bb34-ae2b-4c8e-9c21-621644445df3
"""
	conv_s(img, kernel)

Convolution of `img` with `kernel`.


## Procedure
* Determine the correct output size
* Move the kernel over the image like [here](https://kharshit.github.io/img/edge_detection.png).
"""
function conv_s(img, kernel)
	# TODO, what is the correct output size?
	# use `similar` for output image
	out = similar(img, (2,2))

	# TODO for loops (4 nested for loops)
	# TODO

	out
end

# ╔═╡ a879425f-a152-4d4d-b6b8-f2a03b7a452f
img = Float32.(testimage("mandril_gray"));

# ╔═╡ 61ccfb00-513e-4bca-80eb-133aa58a1def
begin
	# todo create a kernel of size (5,5) filled with 1s
	# but afterwards normalize the sum to 1
	kernel = ones(Float32, (5,5))
	kernel ./= sum(kernel)
end

# ╔═╡ d51fadc0-3227-4e80-96f2-269a8fd2bac2
img_b = conv_s(img, kernel);

# ╔═╡ caab13b5-12a6-4058-8931-1f8a9abe57e8
[gray_show(FourierTools.select_region(img, new_size=size(img_b))) gray_show(img_b)]

# ╔═╡ cc090365-274f-4e56-9be5-cbc1a32295ad
kernel_h_filter = repeat([1 0 -1], inner=(3, 1))

# ╔═╡ b63022e3-3197-4dfe-9b7f-3ee8babce73a
md"
Those examples show the vertical and horizontal edges of the mandril
"

# ╔═╡ 7ec68244-fe43-4418-b9ee-0cb7e67572c9
[gray_show(conv_s(img, kernel_h_filter)) gray_show(conv_s(img, kernel_h_filter'))]

# ╔═╡ 2bd635be-6f07-40df-a25e-cfdf2dd22d6f
md"## Benchmark with FFT based
Is your method faster than FFT based conv?
Rerun below cell more often!

I guess, you won't beat Tullio!
"

# ╔═╡ 3765b001-deb1-49b2-87a1-0100d36d3087
function conv_tullio(img, k) 
	@tullio out_t[i, j] := (img[i + jk - 1, j + jk - 1] * 
							kernel[ik, jk]) (i in 1:508) (j in 1:508)
end

# ╔═╡ 57427d81-961c-488e-9a9d-e625a2e536c3
# run me multiple times!
with_terminal() do
	print("Real space conv\t\t")
	@time conv_s(img, kernel)
	print("FFT based conv\t\t")
	kernel_big = ifftshift(FourierTools.select_region(kernel, new_size=size(img)))
	@time conv(img, kernel_big)
	print("Tullio based conv\t")
	@time conv_tullio(img, kernel)
end

# ╔═╡ 6b4028de-e605-455f-947d-62649f2e26fa
md"## 1 Test"

# ╔═╡ 53ae1016-55d7-4545-a29d-b9a4fc90b854
PlutoTest.@test size(conv_s(ones((3,3)), ones((2,2)))) == ((2,2))

# ╔═╡ 01428578-4258-413d-8b8b-27203527fd2b
img_tt = zeros((6,6));

# ╔═╡ 81605617-d091-47b2-bd85-1cd8ae0fef18
img_tt[:, 1:3] .= 10;

# ╔═╡ f3fb21e1-990a-42ac-8a5d-52154be23cfb
# error disappears if size is correct
PlutoTest.@test conv_s(img_tt, kernel_h_filter) ≈ [0.0 30.0 30.0 0.0; 0.0 30.0 30.0 0.0; 0.0 30.0 30.0 0.0; 0.0 30.0 30.0 0.0]

# ╔═╡ 94694b2a-715a-450b-a024-fc474ce19975
md"# 2 Cell Detection

Based on correlation, we can come up with a simple cell detection algorithm. For the detection we need a template cell.

However, such correlation based methods are not very robust with respect to noise and distortions.

Btw, what you implemented above is mathematically not a convolution but a correlation (we didn't reverse the kernel).

The equation we want to implement in this part, is called _normalized cross-correlation_ since it divides by the local standard deviation of intensities:

$\text{NCC}\{I, K\}[i, j] = \frac{\sum_{m, n} I[i + m - 1, j + n - 1] \cdot K[m, n]}{\sqrt{\sum_{m, n} I[i + m - 1, j + n - 1]^2} \cdot \sqrt{\sum_{m, n} K[m, n]^2}}$
" 

# ╔═╡ f43bd606-d202-4f74-8e46-28bab5af6d45
# load cells
cells = 1 .- Float32.(Gray.(testimage("blobs")));

# ╔═╡ 4ed29eeb-0cbc-4810-8a6c-1b7aaa0014be
gray_show(cells)

# ╔═╡ 1664be9b-08bc-4144-b191-b82bc9e2cee2
"""
	get_template(cells[, t_size=(20, 20)])

Extracts a template cell at position `pos` with template size `t_size`.

# Procedure
* Start the extract at `pos`.
* End the extraction at `pos .+ t_size`.
* Return the extracted part
"""
function get_template(cells, pos, t_size=(20, 20))
	# todo
	return cells[1:3, 1:3]
end

# ╔═╡ d27183d2-0d2b-4868-b34b-a90b2b5a0636
# you can change to different cells as well
cell_pos = (74, 53)

# ╔═╡ 0be4d313-6a6e-4eb6-bdc9-006ef6a726e6
# you can also change size
cell_size = (23, 23)

# ╔═╡ fe0632ef-e1b2-4a6f-ba53-44865b7971d8
cell = get_template(cells, cell_pos, cell_size);

# ╔═╡ 5f9744fa-a818-46bf-b83e-942ad1baac12
gray_show(cell)

# ╔═╡ cd861f28-8923-4ff7-ba24-6875cfa99f39
"""
	NCC(img, kernel)

Normalized cross-correlation of `img` with `kernel`.


## Procedure
* Determine the correct output size
* Move the kernel over the image like [here](https://kharshit.github.io/img/edge_detection.png).
* Calculate the local standard deivations and divide by them
"""
function NCC(img, kernel)
	# TODO, what is the correct output size?
	# use `similar`
	out = similar(img, (3,3))

	# TODO for loops
	# for loops

	out
end

# ╔═╡ 3fa412f2-d107-4caa-abf6-bf47c8333027
corr = NCC(cells, cell);

# ╔═╡ ff16b0cb-b8ba-4d3a-bcc8-da5c120ea898
gray_show(corr)

# ╔═╡ 0c108a6b-599a-4581-8d8d-68b9ae5865df
"""
	find_max(arr)

Returns the value and the index of the maximum intensity.

### Procedure
* Iterate over the array
* Update the current value if you find a larger one

### Examples
```julia-repl
julia> find_max([1 2 3; 4 5 6; 100 8 9])
(100, (3, 1))
```
"""
function find_max(arr)
	# TODO: initate inds and value meaningfully
	inds = (100, 100)
	value = 12345

	#TODO: loop over array
	

	# TODO: return value and inds
	return value, inds
end

# ╔═╡ 49a583a5-ef6b-4e5b-8ea2-0e9a5088b3cc
md"Now check whether `find_max` finds your template in the image again"

# ╔═╡ 64af243c-77f9-4c87-8f59-a4e506e3cb46
find_max(corr)

# ╔═╡ 5610563c-ea7f-40c6-ba8c-5a816bc71a2e
PlutoTest.@test find_max(corr)[2] == cell_pos

# ╔═╡ 37f43e35-015a-4596-96b0-13ccb720c767
md"## 2 Test"

# ╔═╡ bef2f5e8-e6ef-49df-9125-1d814feb31d7
kernel_ncc = [9 10; 13 14];

# ╔═╡ cf18b86d-6c82-4335-b46c-60cd161504b5
img_ncc = [Float64((i - 1) * 4 + j) for i = 1:4, j = 1:4];

# ╔═╡ 2cdd244d-33cb-487e-9fa2-069f8a845ef9
arr_rand = randn((32,32));

# ╔═╡ 8e5f5bf2-5b93-4c52-9960-ea1fb60888ce
PlutoTest.@test size(get_template(cells, (10, 10), (3, 7))) == (3,7)

# ╔═╡ 15626656-af92-44d3-83dd-9775172caed8
PlutoTest.@test get_template(cells, (10, 10), (3, 3)) ≈ Float32[0.15686274 0.18823528 0.31372547; 0.18823528 0.25098038 0.4078431; 0.25098038 0.34509802 0.43921566]

# ╔═╡ a9db1ffb-cc86-4d78-8f24-8b847443aae8
PlutoTest.@test Tuple.(find_max(arr_rand)) == Tuple.(findmax(arr_rand))

# ╔═╡ e144fe4f-cb8e-4158-a59a-8a93faca1f0c
PlutoTest.@test NCC(img_ncc, kernel_ncc) ≈ [0.9376736528408373 0.9683640522700839 0.9836212432229419; 0.9958743946641203 0.9981668178901743 0.9993408297073572; 0.9999999999999999 0.9999029998713893 0.9996660511437935]

# ╔═╡ b34bb590-0fd4-491f-a392-a538d16a86b6


# ╔═╡ 1fc3e23d-e283-43a1-a645-cfbaa3821870
md"# 3 Watershed
Based on the correlation map, we can use that as seed for a watershed algorithm.

What we need is an image with _seeds_. By that we mean an image full of 0s.
At the rough positions of the cells we put a 1.
"

# ╔═╡ 2fc20959-426a-410f-900b-bdde889426fd
"""
	get_seeds(cells, cell)

The `cells` you want to segment with the template `cell`.

# Procedure
* calculate the `NCC` arr (called `corr`)
* use `findlocalmaxima(corr)` to get the local peaks
* return an array which is 0 everywhere, except at the local peaks, where it is 1
"""
function get_seeds(cells, cell)
	# TODO: calc corr (call method from above)
	corr = similar(cells)[1:3, 1:3]   # todo

	# TODO: create an arr_n filled with zeros
	arr_n = similar(corr) # todo
	# TODO: use findlocalmaxima
	maxs = [(1,1)] # todo

	# TODO: iterate over local maxima and set the corresponding
	# values of the arr_n to 1
	# for loopp
	
	return arr_n
end

# ╔═╡ 7d95732e-94f4-448c-8e19-7969271059a9
gray_show(get_seeds(cells, cell))

# ╔═╡ 86a8bf70-3c82-4100-8b63-5d010523a196
# we call watershed algorithm
segments = watershed(.- corr, label_components(get_seeds(cells, cell)));

# ╔═╡ 3641d445-1fff-416d-849b-f9d5715fef0f
heatmap(segments.image_indexmap .* (FourierTools.select_region(cells, new_size=size(segments.image_indexmap)) .> 0.3), c=:glasbey_hv_n256)

# ╔═╡ e559b4b6-e26c-446e-b67e-b196e8ac3021
md"# 3 Test"

# ╔═╡ 6b966b4c-4b5c-4d62-a842-efe204b1c0fb
PlutoTest.@test get_seeds(Float32[1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16], [3 4; 5 6]) ≈ Float32[0.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 0.0]

# ╔═╡ 37c5f515-74a3-4bd0-b7e6-6e498b375e23


# ╔═╡ cfe15c1b-7b29-4514-82c4-e6ffe86456b0
md"# 4 NCC starts to fail
For which values does the NCC start to fail?
"

# ╔═╡ 814d4261-c433-47a9-a35a-16d83be3d4f4
"""
	draw(img, template, pos)

Draw the `template` into the `img`.
The top left corner aligns each with `pos`.

So we basically set the `template` into the `img`.
"""
function draw(img, template, pos)
	# todo 
	# copy the input image to prevent overwriting!
	
	return similar(img)
end

# ╔═╡ 3e30b081-e4df-4518-98aa-96e6e0880a4a
md"σ = $(@bind σ Slider(0:0.01:0.4, show_value=true))"

# ╔═╡ d45bcd94-6adf-40eb-baee-e8edab966f07
md"N = $(@bind N Slider(1:300, show_value=true))"

# ╔═╡ eb005f06-1b2f-45fe-b6b2-abfc6b4dbb1b
md"
First, we shear the image, then we add Poisson noise and finally Gauss noise.
"

# ╔═╡ a01fab74-b77b-4b6f-8415-b0f60530593b
cells_n = add_gauss(poisson(shear(cells, 20), N), σ);

# ╔═╡ de0edf52-cf26-4265-8f10-d8720dfee53f
corr_n = NCC(cells_n, cell);

# ╔═╡ 15dc3591-8141-4e8d-9778-8290de7627ad
[ gray_show(cells_n) gray_show(draw(cells_n, cell .* 3, find_max(corr_n)[2]))]

# ╔═╡ 5e32a3b3-30a9-4cfe-8005-b2eebfd5a4b4
md"Those values should roughly agree. Remember we sheared the array, so they won't exactly be the same"

# ╔═╡ b94655ba-382e-402e-a0c0-89d9d4d91bb6
find_max(corr_n)

# ╔═╡ 3ee0c65f-02b2-41b9-a95b-9932203223c8
find_max(corr)

# ╔═╡ 84a06e2e-13b9-44ea-a1e3-809791017656
md"## 4 Test"

# ╔═╡ 0d4763cc-f47a-4de0-9cde-12a73556b5e3
PlutoTest.@test draw(zeros((5, 5)), ones((2, 2)), (2, 2)) ≈ [0.0 0.0 0.0 0.0 0.0; 0.0 1.0 1.0 0.0 0.0; 0.0 1.0 1.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0]

# ╔═╡ 15b6196d-0b87-45fd-8303-770969386d10
md"# 5 Simulating a Scalar High NA PSF
We often discussed how you can simulate a simple PSF:
* start with an array full of 1s in Fourier space
* low pass filter it
* take the Fourier transform
* take `abs2`


However, that procedure suffers from hard edge artifacts in Fourier space.
Fortunately, in 2D we know that the solution of a perfect PSF is a 

$\text{jinc}^2(x) = \left(\frac{J_1(x)}{x}\right)^2$

where $J_1$ is the Bessel function of the first kind.

We now want to simulate PSF but with an apodization function multiplied in Fourier space (e.g. the aplantic factor).


"

# ╔═╡ 75852dd4-6cc9-4040-84e2-cdb0ce812ec4
"""
	simulate_PSF(s, r, θ, [T=Float64])

Simulate the incoherent 2D PSF with radius `r` and total output size `s`.
This functions returns the PSF centered around the center pixel.
`θ` is the angle over the field size needed for the aplanatic factor.


The procedure is as following:
* create a disc with values of 1 and radius `r` (use `rr2`)
* multiply `cos.(θ)`
* take the `ift` of it.
* normalize the sum to 1
* center pixcel should be located in the center
"""
function simulate_PSF(s, r, θ, T=Float64)
	# TODO

    return abs2.(randn((s)))
end

# ╔═╡ bfa26eb6-d9ea-4a5d-80a5-84f048ed3ea0
"""
	simulate_PSF_jinc(s, scale, θ, [T=Float64])

`s` is the size. `scale` is the argument passed to `rr`.
`θ` is the angle over the field size needed for the aplanatic factor.
This functions returns the PSF centered around the center pixel.

## Procedure
* Call `jinc.` of the `rr` function which is scaled by `scale`
* Take `ft`.
* multiply aplanatic factor
* take `ift`.
* take `abs2.` and normalize sum
"""
function simulate_PSF_jinc(s, scale, θ, T=Float64)
	# TODO, use jinc function
	return abs2.(randn(s))
end

# ╔═╡ 23cc65b9-76d8-43c9-a398-22212b00c76a
θ = abs.(asin.(min.(1, rr(Float32, (100, 100), scale=0.05))));

# ╔═╡ 88b9c633-01ef-4bf2-9180-0bb2b59f4766
# todo
# What is the correct scaling such that both methods return a same scaled PSF
# as a hint, look at the cell below
scale = 1 # fix value

# ╔═╡ 170b5e91-dfaa-4f13-ac45-01b875ba02d8
# hint, look at this output
gray_show(abs.(ft(jinc.(rr((30, 30))))))

# ╔═╡ 497f6e35-4b9a-4349-8366-9f54aa1476c5
md"### Can you spot differences?"

# ╔═╡ 71510434-8685-49ee-b514-31d1c7c411d8
psf_rr = simulate_PSF((100, 100), 10, θ);

# ╔═╡ 195bb3ce-5ade-4c31-9385-12cc4c119762
psf_jinc = simulate_PSF_jinc((100, 100), scale, θ);

# ╔═╡ 8d2c5280-d9c1-414d-a64c-8d8ef5a88b10
gray_show(log.(psf_rr), set_zero=true)

# ╔═╡ abf9ed24-ea46-4067-b786-3a6b23be4c80
gray_show(log.(psf_jinc), set_zero=true)

# ╔═╡ e3d0bb6e-e9c9-4a2d-97bf-73041958771b
md"## 5 Test"

# ╔═╡ f4b0f15f-016e-41ba-a999-e9f792a534fc
PlutoTest.@test simulate_PSF((3, 3), 10, 1) ≈ [0.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 0.0]

# ╔═╡ db517950-7031-4495-8198-f054eb833e16
PlutoTest.@test simulate_PSF_jinc((3, 3), 1000000, 1) ≈ [0.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 0.0]

# ╔═╡ 9a09fa1a-8045-4e93-9140-7f57915146ac
PlutoTest.@test simulate_PSF((10, 10), 3, 0.3) ≈ Float32[0.00040000005 0.0 0.0006111457 0.0 0.0041888547 0.01 0.0041888547 0.0 0.0006111457 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0006111457 0.0 0.0009337476 0.0 0.006400001 0.015278643 0.006400001 0.0 0.0009337476 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0041888547 0.0 0.006400001 0.0 0.043866254 0.10472137 0.043866254 0.0 0.006400001 0.0; 0.01 0.0 0.015278643 0.0 0.10472137 0.25 0.10472137 0.0 0.015278643 0.0; 0.0041888547 0.0 0.006400001 0.0 0.043866254 0.10472137 0.043866254 0.0 0.006400001 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0006111457 0.0 0.0009337476 0.0 0.006400001 0.015278643 0.006400001 0.0 0.0009337476 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]

# ╔═╡ ea3b65bb-2e41-4c17-9df8-35eaf69975f6
PlutoTest.@test simulate_PSF_jinc((4, 4), 0.1, 0.3, Float64) ≈ [0.05502252115995306 0.059372295904787806 0.060884063254034754 0.059372295904787806; 0.059372295904787806 0.0640036567471649 0.0656126102678531 0.0640036567471649; 0.06088406325403477 0.06561261026785312 0.06725510065275418 0.06561261026785312; 0.059372295904787806 0.0640036567471649 0.0656126102678531 0.0640036567471649]

# ╔═╡ Cell order:
# ╠═250252f0-6e61-11ec-2ffe-ebddaa9f0fb3
# ╠═0eeb5bb1-bb41-43cc-8c14-eb9c1ebf6fad
# ╠═1b2ebe1a-f3a7-494c-bcca-18df5403ee65
# ╟─c11d25d8-8fe9-476e-9a6d-66f625f29348
# ╠═6f87bb34-ae2b-4c8e-9c21-621644445df3
# ╠═a879425f-a152-4d4d-b6b8-f2a03b7a452f
# ╠═61ccfb00-513e-4bca-80eb-133aa58a1def
# ╠═d51fadc0-3227-4e80-96f2-269a8fd2bac2
# ╠═caab13b5-12a6-4058-8931-1f8a9abe57e8
# ╠═cc090365-274f-4e56-9be5-cbc1a32295ad
# ╟─b63022e3-3197-4dfe-9b7f-3ee8babce73a
# ╠═7ec68244-fe43-4418-b9ee-0cb7e67572c9
# ╟─2bd635be-6f07-40df-a25e-cfdf2dd22d6f
# ╟─3765b001-deb1-49b2-87a1-0100d36d3087
# ╠═57427d81-961c-488e-9a9d-e625a2e536c3
# ╟─6b4028de-e605-455f-947d-62649f2e26fa
# ╠═53ae1016-55d7-4545-a29d-b9a4fc90b854
# ╠═01428578-4258-413d-8b8b-27203527fd2b
# ╠═81605617-d091-47b2-bd85-1cd8ae0fef18
# ╠═f3fb21e1-990a-42ac-8a5d-52154be23cfb
# ╟─94694b2a-715a-450b-a024-fc474ce19975
# ╠═f43bd606-d202-4f74-8e46-28bab5af6d45
# ╠═4ed29eeb-0cbc-4810-8a6c-1b7aaa0014be
# ╠═1664be9b-08bc-4144-b191-b82bc9e2cee2
# ╠═d27183d2-0d2b-4868-b34b-a90b2b5a0636
# ╠═0be4d313-6a6e-4eb6-bdc9-006ef6a726e6
# ╠═fe0632ef-e1b2-4a6f-ba53-44865b7971d8
# ╠═5f9744fa-a818-46bf-b83e-942ad1baac12
# ╠═cd861f28-8923-4ff7-ba24-6875cfa99f39
# ╠═3fa412f2-d107-4caa-abf6-bf47c8333027
# ╠═ff16b0cb-b8ba-4d3a-bcc8-da5c120ea898
# ╠═0c108a6b-599a-4581-8d8d-68b9ae5865df
# ╟─49a583a5-ef6b-4e5b-8ea2-0e9a5088b3cc
# ╠═64af243c-77f9-4c87-8f59-a4e506e3cb46
# ╠═5610563c-ea7f-40c6-ba8c-5a816bc71a2e
# ╟─37f43e35-015a-4596-96b0-13ccb720c767
# ╠═bef2f5e8-e6ef-49df-9125-1d814feb31d7
# ╠═cf18b86d-6c82-4335-b46c-60cd161504b5
# ╠═2cdd244d-33cb-487e-9fa2-069f8a845ef9
# ╠═8e5f5bf2-5b93-4c52-9960-ea1fb60888ce
# ╠═15626656-af92-44d3-83dd-9775172caed8
# ╠═a9db1ffb-cc86-4d78-8f24-8b847443aae8
# ╠═e144fe4f-cb8e-4158-a59a-8a93faca1f0c
# ╠═b34bb590-0fd4-491f-a392-a538d16a86b6
# ╟─1fc3e23d-e283-43a1-a645-cfbaa3821870
# ╠═2fc20959-426a-410f-900b-bdde889426fd
# ╠═7d95732e-94f4-448c-8e19-7969271059a9
# ╠═86a8bf70-3c82-4100-8b63-5d010523a196
# ╠═3641d445-1fff-416d-849b-f9d5715fef0f
# ╟─e559b4b6-e26c-446e-b67e-b196e8ac3021
# ╠═6b966b4c-4b5c-4d62-a842-efe204b1c0fb
# ╠═37c5f515-74a3-4bd0-b7e6-6e498b375e23
# ╟─cfe15c1b-7b29-4514-82c4-e6ffe86456b0
# ╠═814d4261-c433-47a9-a35a-16d83be3d4f4
# ╠═3e30b081-e4df-4518-98aa-96e6e0880a4a
# ╠═d45bcd94-6adf-40eb-baee-e8edab966f07
# ╟─eb005f06-1b2f-45fe-b6b2-abfc6b4dbb1b
# ╠═a01fab74-b77b-4b6f-8415-b0f60530593b
# ╠═15dc3591-8141-4e8d-9778-8290de7627ad
# ╠═de0edf52-cf26-4265-8f10-d8720dfee53f
# ╟─5e32a3b3-30a9-4cfe-8005-b2eebfd5a4b4
# ╠═b94655ba-382e-402e-a0c0-89d9d4d91bb6
# ╠═3ee0c65f-02b2-41b9-a95b-9932203223c8
# ╟─84a06e2e-13b9-44ea-a1e3-809791017656
# ╠═0d4763cc-f47a-4de0-9cde-12a73556b5e3
# ╟─15b6196d-0b87-45fd-8303-770969386d10
# ╠═4aeceb65-f226-41cf-988b-273f42c75059
# ╠═75852dd4-6cc9-4040-84e2-cdb0ce812ec4
# ╠═bfa26eb6-d9ea-4a5d-80a5-84f048ed3ea0
# ╠═23cc65b9-76d8-43c9-a398-22212b00c76a
# ╠═88b9c633-01ef-4bf2-9180-0bb2b59f4766
# ╠═170b5e91-dfaa-4f13-ac45-01b875ba02d8
# ╟─497f6e35-4b9a-4349-8366-9f54aa1476c5
# ╠═71510434-8685-49ee-b514-31d1c7c411d8
# ╠═195bb3ce-5ade-4c31-9385-12cc4c119762
# ╠═8d2c5280-d9c1-414d-a64c-8d8ef5a88b10
# ╠═abf9ed24-ea46-4067-b786-3a6b23be4c80
# ╟─e3d0bb6e-e9c9-4a2d-97bf-73041958771b
# ╠═f4b0f15f-016e-41ba-a999-e9f792a534fc
# ╠═db517950-7031-4495-8198-f054eb833e16
# ╠═9a09fa1a-8045-4e93-9140-7f57915146ac
# ╠═ea3b65bb-2e41-4c17-9df8-35eaf69975f6
