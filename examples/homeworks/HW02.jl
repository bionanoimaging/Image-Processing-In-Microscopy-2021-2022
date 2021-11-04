### A Pluto.jl notebook ###
# v0.17.0

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

# ╔═╡ 1f6d20c6-2a06-11ec-30b2-f5462ac0ec76
begin
	using Pkg
	Pkg.activate("../../")
	using Revise
end

# ╔═╡ 46cd6d61-7721-49be-909f-7c411a5562ff
using ImgProcMic, PlutoUI

# ╔═╡ a0b4af53-ded5-4d30-9d2b-7c5d1c2bff80
begin
	using ColorSchemes 	# for different colors maps
	using Plots 		# for heatmap
	using TestImages 	# for testimage
	using ImageShow 	# for better rendering of inline images in Pluto
	using Colors 		# for Gray
end

# ╔═╡ a7007d37-6f30-462b-8be3-70999c980c60
using PlutoTest

# ╔═╡ d9d77790-30d1-4ca2-83ca-d974b10a9431
begin
	using PoissonRandom # for poisson noise (`pois_rand`)
	using Statistics # for mean, var
end

# ╔═╡ 7a0e442c-9f32-4210-9483-63e0dc9fbe49
using FourierTools

# ╔═╡ dd4f1881-4570-4972-bd40-a4123ad4b6b1
# for fitting
using LsqFit

# ╔═╡ 85a15a0e-37d4-4b81-986c-d8a2fe4185c7
md"# Homework 02
In this homework we work on images, colormaps and sensor calibration.
"

# ╔═╡ 375801bb-7b43-4983-a0ca-211d106ab11c
begin
	# load a image and shift it to negative values as well
	img = Float64.(testimage("moonsurface")) .- 0.5;
	histogram(img[:], xlabel="intensity", ylabel="occurence", title="Histogram Plot", legend=nothing)
end

# ╔═╡ e2768bdd-3346-4f13-88a8-ab8a43094761
md"## 1. Colormaps
Very often in microscopy, we look at grayscale images.
We already learnt that we can use `Gray.(img)` for that.
However, that is only a very simple viewer.
In general, there are much more sophisticated ones like `View5D.jl` or `Napari.jl`.

As you can see below, `Gray` fails pretty quickly and also does not make use of our human color vision.
"

# ╔═╡ cea22309-272b-4696-850a-f49ad3120345
Gray.(img)

# ╔═╡ c66329a6-84f4-4e0e-87a1-8a62f97ba9f7
md" ### 1.1 Heatmap
`img` contains also negative values which `Gray` does not support by default.
A nicer tool is heatmap.
"

# ╔═╡ 450d3dea-cb97-482b-aaab-bb2919e4ee9e
heatmap(img)

# ╔═╡ 41f64a18-bd0d-49a4-8347-36818b45a576
md"## 1.2 Task - Equal Intensity Color Map
We now want to create a RGB color map which always has the same intensity.

Hence, `green_value + red_value + blue_value = const` for all different inputs.

"

# ╔═╡ f6379b6e-7030-4967-afea-13494ccad294
"""
	to_equal_intensity_tuple(value::T) where T

Returns for a given scalar input a tuple of equal intensity.
There is no unique solution, we only require that the sum is always 1.
For example, below would be a valid solution.

## Examples
```julia-repl
julia> to_equal_intensity_tuple(1.0)
(0.04465819873852073, 0.33333333333333326, 0.6220084679281465)

julia> to_equal_intensity_tuple(0.0)
(0.044658198738520505, 0.3333333333333333, 0.6220084679281462)

julia> to_equal_intensity_tuple(0.3f0)
(0.26402956f0, 0.6503522f0, 0.08561832f0)
```
"""
function to_equal_intensity_tuple(value::T) where T
	# with the function signature we can access T (which is the type of `value`)
	# 0 has type Int
	# 1.0 has type Float64
	# 1.0f0 has type Float32
	if value < 0 || value > 1
		error("value must be within [0,1]")
	end

	# fix those three functions such that the property is achieved
	# maybe think about periodic functions ;)
	red_map(x) = x # TODO
	green_map(x) = x # TODO
	blue_map(x) = x # TODO

	return (3.0, 4f0, 2) # TODO, return the correct tuple!
end

# ╔═╡ 2b3c2ab1-9bec-43f5-a008-795ac354e080
md"#### Maybe a visualization helps
"

# ╔═╡ df017bc1-a29c-4bbc-80c3-bc2466cd95f5
begin
	unzip(a) = map(x->getfield.(a, x), fieldnames(eltype(a)))
	x = 0:0.01:1
	r,g,b = unzip(to_equal_intensity_tuple.(x))
	plot(x, r, color=:red, label="red")
	plot!(x, g, color=:green, label="green")
	plot!(x, b, color=:blue, label="blue")
end

# ╔═╡ f05ca6de-b46c-4400-a141-c662a1a16d7c
md"## 1.2 Test"

# ╔═╡ f1d7bf0a-6806-45fb-8213-313416017c18
# cyclic
PlutoTest.@test all(to_equal_intensity_tuple(0f0) .≈ to_equal_intensity_tuple(1f0))

# ╔═╡ 18bb1f0f-5b80-43d5-bc8a-526947a70f2c
PlutoTest.@test to_equal_intensity_tuple(0.1) != to_equal_intensity_tuple(0.2)

# ╔═╡ 76e2f439-1dff-4f2a-9c05-14e10a13fda6
# intensity is 1
PlutoTest.@test 1 ≈ sum(to_equal_intensity_tuple(rand(0f0:1f0)))

# ╔═╡ 5315fbfd-8ade-46d5-9851-f3ee98c349f7
# test for many values
PlutoTest.@test all(1 .≈ sum.(to_equal_intensity_tuple.(rand(0.0:1.0, 100))))

# ╔═╡ 9d4337c8-6cd1-4112-9477-4a40d13fe7e3
md"##### Check if the output is always 0<=output<=1

_Side Note: it took quite a while to engineer this line :D_
"

# ╔═╡ c0debce4-d81b-4d5d-8907-53d567cf664a
PlutoTest.@test foldl(&, foldl.(Ref((acc, x) -> acc || 0<=x<=1), to_equal_intensity_tuple.(rand(0.0:1.0, 100)), init=false))

# ╔═╡ 4456a207-7f56-4900-95dc-77fe7de31c5d
md"#### Type Stability

The test might be wrong. 
Check what happens with expresions like `2π / 3`. Which type do they have?
How can we convert them to different types?
"

# ╔═╡ a6fbfa34-33c6-4f09-9dcd-773d92a4db0d
PlutoTest.@test NTuple{3, Float32} == typeof(to_equal_intensity_tuple(rand(Float32.(0.0:1.0))))

# ╔═╡ b70be939-7f1d-4e80-9d7f-cc2947d57280
PlutoTest.@test NTuple{3, Float64} == typeof(to_equal_intensity_tuple(rand(Float64.(0.0:1.0))))

# ╔═╡ e9cc6238-5ad9-4a50-93a7-f7065648574a
md"## 1.3 Register Color Map
We are able to create valid outputs, but we still need to pass that to the colormap mechanism.
We need to register the colormap so that we can load it with `heatmap`.

You don't need to know the details, but if you'd like understand, you find those in [ColorSchemes.jl](https://juliagraphics.github.io/ColorSchemes.jl/stable/basics/#Make-your-own-colorscheme).
"

# ╔═╡ 633d295e-cc1f-4864-a36b-11905bc47a50
begin
	# register that with the color map mechanism
	function create_equal_intensity_colormap()
		values = range(0, 1, length=128)
		return map(x -> RGB(x...), to_equal_intensity_tuple.(values))
	end
	
	begin
		my_equal_intensity_colormap = create_equal_intensity_colormap()
		loadcolorscheme(:my_equal_intensity_colormap, my_equal_intensity_colormap)
	end
end

# ╔═╡ 6b65dc02-9a84-43c2-9bb5-32104d23f580
heatmap(img, c=:my_equal_intensity_colormap)

# ╔═╡ 160051e5-56b9-413a-a78d-b371a85ff18c
md" ## 1.4 Task
Now we want to create a colormap, which maps values between 0 and 0.5
to blue values and all values above 0.5  to red.
Don't let you confuse by negativ and positive intensities.
`loadcolorschemes` needs the values within the interval [0, 1] and will automatically scale it to the image.

"

# ╔═╡ 1483db2c-6374-4c93-ade4-db8894071ce7
"""
	to_negativ_positive_tuple(value::T) where T


## Examples
```
julia> to_negative_positive_tuple(0.0)
(0.0, 0.0, 1.0)

julia> to_negative_positive_tuple(0.25)
(0.5, 0.5, 1.0)

julia> to_negative_positive_tuple(0.5)
(1.0, 1.0, 1.0)

julia> to_negative_positive_tuple(0.75)
(1.0, 0.5, 0.5)

julia> to_negative_positive_tuple(1.0)
(1.0, 0.0, 0.0)
```
"""
function to_negative_positive_tuple(value::T) where T
	# TODO build the function in analogy to to_equal_intensity_tuple

	# TODO
	# TODO
	
	# TODO
	# TODO
	
	# TODO
	# TODO
	
	# TODO
	# TODO

	return (0, 0, 0) # TODO
end

# ╔═╡ 0afb1220-1fdf-447d-8e79-b1ad7c274dd3
md"
Try to show again a heatmap image. The procedure is exactly the same above, except that you need to exchange the core part of the color generation."

# ╔═╡ f6e5d3c8-172e-4fb6-89ce-a1827a6ddd6c
begin
	# try to get :my_negative_positive_colormap working
	# see above what to do!

	# TODO
	# TODO
	# TODO
end

# ╔═╡ bd71f8c1-e1e8-4f72-9ad8-8714e9e215f0
heatmap(img, c=:my_negative_positive_colormap)

# ╔═╡ 45d098a5-86e1-45ed-9e27-d59dbc7cfc42
md"## 1.4 Test"

# ╔═╡ a389a422-3946-49ba-ac2a-44ba0ebbb7fe
PlutoTest.@test to_negative_positive_tuple(0.0) == (0.0, 0.0, 1)

# ╔═╡ cf832e74-1029-4554-94ff-876e7ce622ab
PlutoTest.@test to_negative_positive_tuple(1.0) == (1.0, 0.0, 0.0)

# ╔═╡ 968529e7-c30c-4ba9-96cc-c3468bbbf7e3
PlutoTest.@test to_negative_positive_tuple(0.5) == (1.0, 1.0, 1.0)

# ╔═╡ 65aab672-9fc2-48f9-b669-e6f5299b1e99
PlutoTest.@test to_negative_positive_tuple(0.75) == (1.0, 0.5, 0.5)

# ╔═╡ 00ee1b88-41fc-41d6-b6a5-91a68560384d
PlutoTest.@test to_negative_positive_tuple(0.25) == (0.5, 0.5, 1)

# ╔═╡ b7e01e25-4b4c-4021-ac52-b5fa4d54c1fa
PlutoTest.@test typeof(to_negative_positive_tuple(0.25f0)) == Tuple{Float32, Float32, Float32}

# ╔═╡ ac0c999b-afb3-4b0c-b981-1bde3275e182
PlutoTest.@test typeof(to_negative_positive_tuple(0.0)) == Tuple{Float64, Float64, Float64}

# ╔═╡ 279cd4f9-9d0e-4bef-80c9-907652371f12
md"## 2 Sensor Simulation

In this part, we want to simulate a sensor. Later, we try to calibrate our artifical sensor.

In short: Each pixel in the sensor measures a number of photons (`n_photons`) which is affected by Poisson noise.
Afterwards, the measured value is altered by additive Gauss noise with a certain
standard deviation `σ`.
This value is then converted to ADU units (analog to digital units) with a certain `gain` (linear conversion factor).
Additionally, each sensor has an `offset` which is finally added.
"

# ╔═╡ ffbc76ee-5c5b-460f-a7dc-ac50500dede9
md"## 2.1 Task
Fill in the missing parts.
"

# ╔═╡ 0b6561db-6286-49b6-bbfb-98f56cbafd1b
"""
      simulate_pixel(n_photons; read_σ=5, offset=0.5, gain=0.1)

In this function we simulate a single pixel.
It transforms a photon number to a digital unit (ADU).

The input is a integer number of photons which is then altered with poisson noise (use `pois_rand` for that).
This number is changed with additive Gauss noise (see HW01).
Finally, the result of this operation is multiplied by the linear `gain`.
At the end, we add `offset`.



* `n_photons`: number of photons
* `read_σ`: additive read noise of the sensor (applied before `gain`)
* `gain`: how much digital output per photon
* `offset`: how much digital offset


## Example Outputs - can vary in your case!
```julia
julia> simulate_pixel(10)
0.8570431305838304

julia> simulate_pixel(10)
2.060753446522642

julia> simulate_pixel(10)
1.020461460534897

julia> simulate_pixel(100)
8.96276245560446

julia> simulate_pixel.(ones((3,3)))
3×3 Matrix{Float64}:
 0.396078  0.96849   -0.0387851
 1.09982   0.210089   0.685605
 0.606973  1.42573   -0.675297
```
"""
function simulate_pixel(n_photons; read_σ=5, offset=0.5, gain=0.1)
	# try to compose the different operations
	# TODO
	# TODO
	return 0 # TODO
end

# ╔═╡ 3b1bbda7-dfa0-4181-b0f7-fc920f166a4b
single_output = simulate_pixel(100) 

# ╔═╡ 5df0c449-c46e-4719-bff5-d42220991e8f
md"## 2.1 Test"

# ╔═╡ 02b3bafb-fc03-42ff-a281-47216a04f6ce
# check offset
PlutoTest.@test 0.0123 ≈ simulate_pixel(0, read_σ=0, offset=0.0123, gain=1)

# ╔═╡ 1d3e3c6f-7920-4b2c-a432-105fa1f131f7
# check mean poisson
PlutoTest.@test 123 ≈ mean(simulate_pixel.(ones((1000,)) * 123, read_σ=0, offset=0.0123, gain=1)) rtol=0.1

# ╔═╡ b01359d9-c1b2-455f-897c-8ab6bed4f20f
# check variance poisson
PlutoTest.@test 123 ≈ var(simulate_pixel.(ones((1000,)) * 123, read_σ=0, offset=0.0123, gain=1)) rtol=0.1

# ╔═╡ a598763f-63f9-48c9-9e5b-ba6256775221
# check readnoise
PlutoTest.@test 12.3 ≈ std(simulate_pixel.(zeros((1000,)) * 123, read_σ=12.3, offset=0, gain=1)) rtol=0.1

# ╔═╡ 93567e80-181f-4629-8a27-2f37e5e20b62
# check gain
PlutoTest.@test 42 * 12.3 ≈ std(simulate_pixel.(zeros((1000,)) * 123, read_σ=12.3, offset=0, gain=42)) rtol=0.1

# ╔═╡ 9ad71b79-872d-4c96-b4eb-3c2e841f295d
md"## 2.2 Variance Mean Projection
Now we want to do a Variance Mean Projection to fit the values of `offset` and `gain` since we often don't know them for real sensors.

For this test, you take a sample and in practice you defocus your microscope heavily.
Via that trick, you have an image which covers all values between very dark and very bright.
Hence, we expect that our image sensors both measures a large dynamic range.
"

# ╔═╡ 70fa1c62-b5df-49dd-ae66-b49cb9bf6c0a
# that's already done for you
begin
	ideal = resample(Float32.(testimage("resolution_test_512"))[50:450, 50:450], (150, 150)) # random amount of photons in the interval 0:500
	x_cords = range(-10, 10, length=size(ideal, 1))
	gauss = Float32.(exp.(-(x_cords.^2 .+ x_cords'.^2)))
	gauss ./= sum(gauss)
	img_blurry = conv_psf(ideal, gauss)
	img_blurry .-= minimum(img_blurry)
	img_blurry ./= maximum(img_blurry) 
	img_blurry = round.(Ref(Int), img_blurry .* 1000) # round to integers
	Gray.(img_blurry ./ 500)
end;

# ╔═╡ 1e3f86d7-a952-41fc-9f67-c8ce87d14315
md"###### That's an ideal image, where we have both very bright and very dark regions"

# ╔═╡ 120846a5-7892-4f79-8e95-bde9bf06df25
# our blurry sample which emits 1000 photons in maximum
gray_show(img_blurry)

# ╔═╡ 3a6757db-050c-4923-a6bd-5c7c33581a93
histogram(img_blurry[:], xlabel="intensity", ylabel="occurence", title="Histogram Plot", legend=nothing)

# ╔═╡ ee7b9e26-c81d-4e09-9553-e9cded4db31d
md"## 2.2 Task - Apply to image
Now apply the function `simulate_pixel` to `img_blurry`.
Use the automatic broadcasting of Julia for that.
"

# ╔═╡ 6fddf2a4-45f0-4243-aa0c-df5ce2c354a9
simulated_img = similar(img) # TODO, fix that line such that it uses `simulate_pixel`. Use broadcasting mechanism

# ╔═╡ 48fb4f01-a3fa-4c7b-abb0-6e6f2b63dac7
md"Apply the same trick (broadcasting) for a 2D image to this 3D image"

# ╔═╡ f9b327ef-e184-4e1f-af3c-184f408f04bd
md"## 2.3 Task - Calculate mean and variance
Calculate the mean and variance of those images, but only along the third dimension!
Either use a library (Statistics) or write it yourself :)
"

# ╔═╡ ec0289d5-427c-4e19-b63a-361ed7165d42
md"#### Finally, we produce a scatter plot"

# ╔═╡ 1df9763e-81be-4f24-b439-e01559d78a9b
md" ## 2.4 Fitting
Having our noisy dataset, we want to extract the `gain` of the detector since the gain translate from a photon count to an eletrical signal (ADU).

Why does plotting the variance $\sigma^2$ over the mean $\mu$ allows to fit the gain?
We know, that in a Poisson distribution the expected mean $\mu$ is always equal to the variance $\sigma^2$.

If we now take 10 captures of the same image, we always expect the same mean $\mu$ for a certain pixel. Of course, those are 10 evaluation of a random measurement process, therefore we observe fluctuations. Hence, for each pixel we can calculate the mean and the variance. 

Since the detector multiplies the measured photons with a certain gain, we do not measure the photons but the digital value.
Hence the measured mean is

$\hat \mu = \text{gain} \cdot \mu$

where $\mu$ would be the expected photon number.

However, the measured variance is 

$$\hat \sigma^2 = \sum_{i} (\hat \mu - \text{gain} \cdot x_i)^2 = \text{gain}^2 \sigma^2$$
where $\sigma^2$ would be the variance of the photon number.

The slope of our variance over mean is then 

$$\frac{\Delta \hat \sigma^2}{\Delta \hat \mu} = \text{gain}$$

Dividing $\hat \mu$ by $\text{gain}$ returns the measured photon number.

"

# ╔═╡ d6ea97c0-42a2-4119-94cb-c59d07c84992
md" ## 2.5 LsqFit.jl
We now want to fit a linear function with a slope and a offset on our data.
Try to find out [here](https://github.com/JuliaNLSolvers/LsqFit.jl) how that works
"

# ╔═╡ 529cf3ab-090d-4ed3-b236-eed577554bbb
@. model(x, p) = nothing # TODO

# ╔═╡ ca78fb0c-3cd6-461e-a4c7-5bbd61589001
p0 = nothing # TODO (maybe you need to convert it to Float32, maybe not)

# ╔═╡ 709c3594-d979-4a09-876f-7bbf4ad4aa18
fit = nothing # TODO

# ╔═╡ b2b821b3-e95b-48ec-aee0-acea4e6b01dc
md"##  Final Check
If you slide those parameters, you change the simulated values.
"

# ╔═╡ e68aa618-f5b0-4834-b492-268962b4c5be
md"
`offset`=$(@bind offset Slider(0.5:1:100, show_value=true))

`read_σ`=$(@bind read_σ Slider(2:1:20, show_value=true))

`gain`=$(@bind gain Slider(0.01:0.01:1, show_value=true))
"

# ╔═╡ 1140ab5b-6e3a-4fac-baf0-a150a07d7293
begin
	imgs = repeat(img_blurry, outer=(1, 1, 10));
	images = simulate_pixel.(imgs; offset, read_σ, gain);
end;

# ╔═╡ 1e97f466-796e-4837-b0bf-2a3c4edd89c0
md" In practice we would need to take a few images (like 10)

Hence we repeat the image 10 times digitally
 
The output is an array with `size(imgs) ==` $(size(imgs))
"

# ╔═╡ 3a7737ac-7884-41ba-863c-b352dceb73c9
begin
	# mean
	μ_arr = randn(size(imgs)[1:2]) # calculate the mean of `images` along dim 3
	μ = μ_arr[:]
end

# ╔═╡ 501a5a71-9cff-4338-b575-0f0be06d064f
begin
	# variance
	variance_arr = randn(size(imgs)[1:2])# calculate the variance of `images` along dim 3
	variance = variance_arr[:]
end

# ╔═╡ 41bdbfb9-06b9-4f4b-bc97-31ed2e6ae695
scatter(μ, variance, xlabel="mean", ylabel="variance")

# ╔═╡ 3ffb57c7-825b-4213-a847-7cc4e9466875
begin
	scatter(μ, variance, label="data")
	plot!(μ, model(μ, fit.param), linewidth=5, label="fit")
end

# ╔═╡ 0adf654e-f238-432c-ace4-50ad5d896870
md"The final solution is σ = $(round(fit.param[1], sigdigits=4)) ± $(round(stderror(fit)[1], sigdigits=2))"

# ╔═╡ Cell order:
# ╠═1f6d20c6-2a06-11ec-30b2-f5462ac0ec76
# ╠═46cd6d61-7721-49be-909f-7c411a5562ff
# ╠═85a15a0e-37d4-4b81-986c-d8a2fe4185c7
# ╠═a0b4af53-ded5-4d30-9d2b-7c5d1c2bff80
# ╠═375801bb-7b43-4983-a0ca-211d106ab11c
# ╟─e2768bdd-3346-4f13-88a8-ab8a43094761
# ╠═cea22309-272b-4696-850a-f49ad3120345
# ╠═c66329a6-84f4-4e0e-87a1-8a62f97ba9f7
# ╠═450d3dea-cb97-482b-aaab-bb2919e4ee9e
# ╠═41f64a18-bd0d-49a4-8347-36818b45a576
# ╠═f6379b6e-7030-4967-afea-13494ccad294
# ╟─2b3c2ab1-9bec-43f5-a008-795ac354e080
# ╠═df017bc1-a29c-4bbc-80c3-bc2466cd95f5
# ╠═f05ca6de-b46c-4400-a141-c662a1a16d7c
# ╠═a7007d37-6f30-462b-8be3-70999c980c60
# ╠═f1d7bf0a-6806-45fb-8213-313416017c18
# ╠═18bb1f0f-5b80-43d5-bc8a-526947a70f2c
# ╠═76e2f439-1dff-4f2a-9c05-14e10a13fda6
# ╠═5315fbfd-8ade-46d5-9851-f3ee98c349f7
# ╟─9d4337c8-6cd1-4112-9477-4a40d13fe7e3
# ╠═c0debce4-d81b-4d5d-8907-53d567cf664a
# ╟─4456a207-7f56-4900-95dc-77fe7de31c5d
# ╠═a6fbfa34-33c6-4f09-9dcd-773d92a4db0d
# ╠═b70be939-7f1d-4e80-9d7f-cc2947d57280
# ╠═e9cc6238-5ad9-4a50-93a7-f7065648574a
# ╠═633d295e-cc1f-4864-a36b-11905bc47a50
# ╠═6b65dc02-9a84-43c2-9bb5-32104d23f580
# ╠═160051e5-56b9-413a-a78d-b371a85ff18c
# ╠═1483db2c-6374-4c93-ade4-db8894071ce7
# ╠═0afb1220-1fdf-447d-8e79-b1ad7c274dd3
# ╠═f6e5d3c8-172e-4fb6-89ce-a1827a6ddd6c
# ╠═bd71f8c1-e1e8-4f72-9ad8-8714e9e215f0
# ╠═45d098a5-86e1-45ed-9e27-d59dbc7cfc42
# ╠═a389a422-3946-49ba-ac2a-44ba0ebbb7fe
# ╠═cf832e74-1029-4554-94ff-876e7ce622ab
# ╠═968529e7-c30c-4ba9-96cc-c3468bbbf7e3
# ╠═65aab672-9fc2-48f9-b669-e6f5299b1e99
# ╠═00ee1b88-41fc-41d6-b6a5-91a68560384d
# ╠═b7e01e25-4b4c-4021-ac52-b5fa4d54c1fa
# ╠═ac0c999b-afb3-4b0c-b981-1bde3275e182
# ╠═279cd4f9-9d0e-4bef-80c9-907652371f12
# ╠═d9d77790-30d1-4ca2-83ca-d974b10a9431
# ╠═ffbc76ee-5c5b-460f-a7dc-ac50500dede9
# ╠═0b6561db-6286-49b6-bbfb-98f56cbafd1b
# ╠═3b1bbda7-dfa0-4181-b0f7-fc920f166a4b
# ╠═5df0c449-c46e-4719-bff5-d42220991e8f
# ╠═02b3bafb-fc03-42ff-a281-47216a04f6ce
# ╠═1d3e3c6f-7920-4b2c-a432-105fa1f131f7
# ╠═b01359d9-c1b2-455f-897c-8ab6bed4f20f
# ╠═a598763f-63f9-48c9-9e5b-ba6256775221
# ╠═93567e80-181f-4629-8a27-2f37e5e20b62
# ╠═9ad71b79-872d-4c96-b4eb-3c2e841f295d
# ╠═7a0e442c-9f32-4210-9483-63e0dc9fbe49
# ╠═70fa1c62-b5df-49dd-ae66-b49cb9bf6c0a
# ╠═1e3f86d7-a952-41fc-9f67-c8ce87d14315
# ╠═120846a5-7892-4f79-8e95-bde9bf06df25
# ╠═3a6757db-050c-4923-a6bd-5c7c33581a93
# ╠═ee7b9e26-c81d-4e09-9553-e9cded4db31d
# ╠═6fddf2a4-45f0-4243-aa0c-df5ce2c354a9
# ╠═1e97f466-796e-4837-b0bf-2a3c4edd89c0
# ╠═48fb4f01-a3fa-4c7b-abb0-6e6f2b63dac7
# ╠═1140ab5b-6e3a-4fac-baf0-a150a07d7293
# ╠═f9b327ef-e184-4e1f-af3c-184f408f04bd
# ╠═3a7737ac-7884-41ba-863c-b352dceb73c9
# ╠═501a5a71-9cff-4338-b575-0f0be06d064f
# ╠═ec0289d5-427c-4e19-b63a-361ed7165d42
# ╠═41bdbfb9-06b9-4f4b-bc97-31ed2e6ae695
# ╠═1df9763e-81be-4f24-b439-e01559d78a9b
# ╠═dd4f1881-4570-4972-bd40-a4123ad4b6b1
# ╠═d6ea97c0-42a2-4119-94cb-c59d07c84992
# ╠═529cf3ab-090d-4ed3-b236-eed577554bbb
# ╠═ca78fb0c-3cd6-461e-a4c7-5bbd61589001
# ╠═709c3594-d979-4a09-876f-7bbf4ad4aa18
# ╠═3ffb57c7-825b-4213-a847-7cc4e9466875
# ╠═b2b821b3-e95b-48ec-aee0-acea4e6b01dc
# ╠═e68aa618-f5b0-4834-b492-268962b4c5be
# ╠═0adf654e-f238-432c-ace4-50ad5d896870
