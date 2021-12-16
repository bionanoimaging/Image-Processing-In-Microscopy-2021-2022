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

# ╔═╡ 9112b09c-5a21-11ec-0847-1971b3c9a6cd
begin
	using Pkg
	Pkg.activate("../../")
	using Revise
end

# ╔═╡ 4b66d9ba-eb36-4f53-8e87-28b6eadbd828
using FFTW, Colors, ImageShow, TestImages, Tullio, Zygote, Noise, IndexFunArrays, FourierTools, ImgProcMic, PlutoUI, DeconvOptim, PlutoTest, Optim, Statistics, Plots

# ╔═╡ 9bc5b039-5c13-46bc-8d3b-9edae93d164a
using ComponentArrays, Images, Random, MicroscopyTools

# ╔═╡ 33890cd9-4aa6-4e64-815a-f59a541ae8c6
md"# Package loading
Sorry, takes quite a while this time. We import heavy dependencies such as Zygote, Plots, DeconvOptim, Tullio, Optim, ...
"

# ╔═╡ 606ad4de-213f-4aac-a0a9-9a6827c05c29
begin
	"""
		circ(size, radius)
	
	`size` the size of the resulting array
	and `radius` the radius of the circle
	"""
	circ(size, radius) = rr2(size) .<= radius^2
end

# ╔═╡ e7a503cf-c59c-4737-95f5-b8f38548833a
"""
	calc_psf(arr_size, radius)

Calculate a simple PSF. `arr_size` is the output size and `radius` is the radius 
in Fourier space.
The output array is normalized by its sum to 1.
"""
function calc_psf(arr_size, radius)
	rr2 = circ(arr_size, radius)
	h = abs2.(ift(rr2))
	h ./= sum(h)
	return h
end

# ╔═╡ 3194824d-ed15-479a-af10-a1803f9f20bc
md"# 1 Lucy Richardson Deconvolution
In the last exercise we implemented the Wiener filter which is suited for Gaussian noise.
However, in microscopy the most dominant noise is usually Poisson noise.
The LR deconvolution algorithm is derived on a Poisson noise assumption.

Based on the lecture notes, implement the LR algorithm.
"

# ╔═╡ 7ef1aaf2-081c-4885-9ab3-4606cf0656b4
"""
	LR(measured, psf, N)

`measured` is the measured image. `psf` is the point spread function.
`N` is the number of iterations.
"""
function LR(measured, psf, N)
	# TODO

	# lucy richardson algorithm
	return similar(measured)
end

# ╔═╡ 400aeebf-21bd-4b58-9b64-ccec3071df63
# testimage
img = Float32.(testimage("resolution_test_512"));

# ╔═╡ d7741c07-0982-4e57-bf95-a3ee0bc6f0b1
# TODO: calculate the PSF with a radius of 30
psf = copy(img)

# ╔═╡ aa15a3ed-0f97-4ef9-9704-0ede98426b6c
# our measured image, degraded with poisson
measured = 0.0001f0 .+ poisson(FourierTools.conv(img, psf), 100);

# ╔═╡ f4e2cc11-e86e-4afc-a021-aed27283a5f1
gray_show(measured)

# ╔═╡ dc9fa103-6a00-4129-b5d1-c1b36216d13d
md"
After 

iterations=$(@bind iterations Slider(1:300, show_value=true))

the image should look _better_ than the original.
Take that as test!
"

# ╔═╡ 6ba1619b-036a-480d-b3bb-88ea6f5b259e
rec = LR(measured, psf, iterations);

# ╔═╡ f9bb5a74-067d-4afd-ae61-7f41f2e1dbca
gray_show(rec)

# ╔═╡ 0d7e91be-e03e-454c-9ebd-c0b68ca93848
md"# 2 (Smoothed) Total Variation Regularizer
In this part we want to implement a Total Variation Regularizer.
It's purpose is to impose a constraint of _piecewise smoothness_ to the image.
Formally, it is defined as

$\text{TV}(\text{img}) = \sum_{i,j} \sqrt{\epsilon + \left|\text{img}[i, j] - \text{img}[i+1, j]\right|^2 + \left|\text{img}[i, j] - \text{img}[i, j+1]\right|^2}$

where $\epsilon$ is a small value prevent a singularity in the derivative. 

The output of this equation is a scalar value and can be understood as a loss function.
If we add this term to our loss function of the LR algorithm, the optimizer has to minimize not only the LR loss term but also this additional regularizer.
Often this can introduce nicer results.

As you learnt in the last homework, we also need the gradient of the `TV` function.
Fortunately, for that purpose we can use the automatic differentiation package [Zygote.jl](https://github.com/FluxML/Zygote.jl).
"

# ╔═╡ 72cdab83-0162-4951-8751-b91cb6fd0e49
md"For the implementation of the regularizer itself, we use the package [Tullio.jl](https://github.com/mcabbott/Tullio.jl). _Tullio.jl_ speeds up the calculation and is conventient to use.
For simple usage, see below:"

# ╔═╡ f8c665e4-e07f-4995-ad84-5a31658be5f4
begin
	# example how @tullio works
	arr = [1.0, 2.0, 3.0]
	@tullio arr_ex = abs2(arr[i] - arr[i-1])
end

# ╔═╡ bfb88c5e-0e45-428b-a66c-b9c37f633c6b
"""
	TV(img::AbstractArray{T, N}, ϵ=T(1e-6)) where {T, N}

Calculates the TV regularizer. `ϵ` is a small positive value to make it differentiable.
"""
function TV(img::AbstractArray{T, N}, ϵ=T(1e-6)) where {T, N}
	# insert tullio expression here!
	# TODO

	# that line is wrong, of course
	return zero(T) .* sum(img)
end

# ╔═╡ 49143f59-2f8f-46e9-ac32-c4681164ef82
TV(img)

# ╔═╡ e33d9b1f-dc9b-49c0-a6e3-b1e2266df999
# the gradient can be calculated likes this!
# it describes how the value of the TV change for each pixel value
gradient(TV, img)[1]

# ╔═╡ 8a9da6e2-528a-41e5-9bc5-750885d94ca0
md"## 2 Test"

# ╔═╡ 53364e6f-b672-4c60-8fe1-845ba85399ba
PlutoTest.@test typeof(TV([1.0 2; 3 4])) <: Number

# ╔═╡ 30e313ee-aca2-4469-97cf-08acd489aaef
PlutoTest.@test TV([1.0 2; 3 4]) ≈ 2.2360682011065762

# ╔═╡ 4c91d0da-201a-4281-91a2-2de626ab4a30
PlutoTest.@test Zygote.gradient(TV, [1.0 2; 3 4])[1] ≈ [-1.34164   0.447214; 0.894427  0.0] rtol=1e-5

# ╔═╡ 340851e8-a66d-4643-83d1-48fb775dde8e
md"# 3 Lucy Richardson with TV
Additionally to the plain LR we want to incorporate the TV regularizer in this task.

The gradient of `TV` can be calculated with `gradient(TV, arr)[1]`.

In the lectures it is sketched how to add the regularizer loss to the normal loss function.
Copy your `LR` from above and try to incorporate the gradient of the `TV` loss value.
The `TV` gradient value is weighted with `λ`.
"

# ╔═╡ cfc01fbb-5ee4-4909-ba67-2034506e55e8
function LR_TV(measured, psf, λ, N)
	# TODO
	# LR with TV
	similar(measured)
end

# ╔═╡ ae7c45b6-c8a7-4fe0-b922-9ab40fcce372
# that can easily take a minute. Zygote is very sloooooooow on the first call
rec2 = LR_TV(measured, psf, 0.02, 400)

# ╔═╡ 8c91142a-5b2d-4dfc-9764-87a66f90f0cb
gray_show(rec2)

# ╔═╡ dcba043b-db09-4adc-8239-a6439a9c074e
md" ## 4 Bonus
Anyone who can beat [DeconvOptim.jl](https://github.com/roflmaostc/DeconvOptim.jl) in terms of speed (with equal reconstruction quality), immediatly gets the bonus for the exam.
"

# ╔═╡ bbb7dda6-84c2-4172-a888-85a3658c1556
reg = DeconvOptim.TV(num_dims=2);

# ╔═╡ 231698fd-bb16-4895-9278-0d41dfafdb7e
rec_DO,r = deconvolution(measured, psf, regularizer=reg, iterations=20, λ=0.02);

# ╔═╡ 45f089ec-a7cb-4941-ad04-7a6c6c55dbef
r

# ╔═╡ d725c173-0123-40ed-aaa0-feec1dcd7a25
gray_show(rec_DO)

# ╔═╡ dfc9d8f3-6b16-476a-bba9-1c7f55229f57
md"# 5 Single Molecule Localization

In this part we fit the position, intensity and the standard deviation of a point source emitter to a measured image.
"

# ╔═╡ 954f06a6-ac27-4596-a978-e1274b2532d8
md"### Hint
Use the following pattern and the broadcast mechanism!
"

# ╔═╡ 46185370-aaf3-48c3-b297-b3a2843a0435
1:100

# ╔═╡ 7c51a261-a188-469d-8020-876b1b1dcbf0
(1:100)'

# ╔═╡ fae6889b-65f5-4b90-972f-56187b69fee5
"""
	gauss(I, σ, x_offset, y_offset)

Returns an image of size `(256, 256)` with a Gauss peak
centered at `(x_offset, y_offset)` with standard deviation `σ` and intensity
`I` (which is multiplied to the ideal Gauss)
"""
function gauss(I, σ::T, x_offset::T, y_offset::T) where T
	# TODO
	# complete the Gauss function


	# obviously non sense what we return here.
	# We just put this to get the notebook running
	return 0.1 .* ones(T, (256, 256)) .* sum(σ) .* sum(x_offset)
end

# ╔═╡ 23b9ea69-99d5-4a49-8e36-cd25323c8858
md"## 5.1 Test Gauss"

# ╔═╡ e9c17987-029e-4bd9-824e-47175f4d6924
z = zeros((256, 256));

# ╔═╡ 046ec177-9394-4b7d-bead-68590e169f1b
z[10, 10] = 42.0;

# ╔═╡ eb9b2246-c9d9-442e-bde4-48ed14bb3fa6
PlutoTest.@test gauss(42.0, 0.000001, 10.0, 10.0) ≈ z

# ╔═╡ 9cdf2e65-af36-4421-a15b-fdc4c87569b4
PlutoTest.@test gauss(11.0, 100000000000000000000.0, 0.0, 0.0) ≈ 11.0 .* ones((256, 256))

# ╔═╡ 7ecb1d8d-334c-4043-9378-adcbe0b0bf35
PlutoTest.@test (gauss(10.0, 2.0, 3.0, 3.0))[1:5, 1:5] ≈ [3.6787944117144233 5.352614285189903 6.065306597126334 5.352614285189903 3.6787944117144233; 5.352614285189903 7.788007830714049 8.824969025845954 7.788007830714049 5.352614285189903; 6.065306597126334 8.824969025845954 10.0 8.824969025845954 6.065306597126334; 5.352614285189903 7.788007830714049 8.824969025845954 7.788007830714049 5.352614285189903; 3.6787944117144233 5.352614285189903 6.065306597126334 5.352614285189903 3.6787944117144233]

# ╔═╡ 9b5b3495-0d3b-4f7c-9f51-04245ebd59c2
md"## 5.2 Forward Model
In the next part, we assemble a forward model mapping a set of parameters to an image.
"

# ╔═╡ 26950064-0127-41fd-9973-6c170bd6b8fe
"""
	draw_parameters(N)

Randomly draws `N` parameters for the Gauss peak.
"""
function draw_parameters(N)
	# make the random numbers reproducible
	Random.seed!(40)
	σ = [rand(1:0.01:5.0) for i = 1:N]
	x_offset = [rand(10:0.1:240) for i = 1:N]
	y_offset = [rand(10:0.1:240) for i = 1:N]
	I = [rand(0.5:0.1:1.0) for i = 1:N]
	return ComponentVector(σ=σ, x_offset=x_offset, y_offset=y_offset, I=I)
end

# ╔═╡ ef9c0737-ffbc-498b-80d2-2e93558c508f
# draws randomly a few parameters
# the output is a ComponentVector which is needed for Optim
params = draw_parameters(5);

# ╔═╡ 70a9e03f-d44f-4cce-a82d-898e63f789fd
# all fields can be access with params.FIELD, see below

# ╔═╡ 70453553-7dbc-46f1-a141-f4d19f2ae3d4
params.σ

# ╔═╡ 6ac55320-b94f-44c2-9669-1d4e7eb3ddee
params.x_offset

# ╔═╡ 73416e0d-ed2b-4b95-aa43-ce58de7f29aa
"""
	forward(params)

Maps the `params` to an output image.
"""
function forward(params)
	sum(gauss.(params.I, params.σ, params.x_offset, params.y_offset))
end

# ╔═╡ 42f34ed6-2548-4b53-b714-2128f21ca780
forward(params)

# ╔═╡ 56d566e3-632c-4852-839b-adf505122ad2
measurement = randn() * 0.3 .+ poisson(forward(params), 50);

# ╔═╡ 26f1a0c2-3787-4335-958b-12719e2901bf
# noisy measurement of the point sources
gray_show(measurement)

# ╔═╡ 2b3c151a-d7bd-40e4-97d7-f121c9da23a6
md"## 5.3 Loss Function"

# ╔═╡ 32bd26f1-0d04-4589-a2d5-1e01abce4a7d
"""
	loss(measurement, pred)

Compares the prediction `pred` and the `measurement` under the L2 norm.
"""
function loss(measurement, pred)
	# TODO to calculate L2 loss

	
	# line needed to get notebook running
	return 0 .* sum(pred) .* sum(measurement)
end

# ╔═╡ 726d6133-b7a2-4ff2-a844-e93eee1b7088
md"## 5.3 Test"

# ╔═╡ 22e9ac0f-0685-4a9d-b144-10217290c18e
PlutoTest.@test loss([1,2,3], [1,2,3]) ≈ 0

# ╔═╡ 0447b66d-b6ff-470c-a0b9-41c754252474
PlutoTest.@test loss([1,20,1], [1,2,3]) ≈ 328

# ╔═╡ dc66401d-2581-4d6f-8b36-d15a2d21391a
md"## 5.4 Reconstruction"

# ╔═╡ daa77619-e7a8-4c6a-9854-d8ef21042277
"""
	find_peaks(arr, bin_factor)

Finds the peaks in the measurement `arr`. 
To get a better SND we bin the measurement by a binning factor `bin_factor`.
"""
function find_peaks(arr, bin_factor)
	arr_s = bin(arr, (bin_factor,bin_factor))
	map(x -> x .* bin_factor, Tuple.(findlocalmaxima(arr_s)))
end

# ╔═╡ 1a505ff5-4745-42c5-bc40-bc1075fcd4d6
"""
	init_parameters(N, measurement)

Initializes a good set of parameters for the reconstruction.
`N` is the number of PSFs and `measurement` the measured image.

The critical part is to find good initial positions for the peaks.
For that we use `find_peaks`. 

"""
function init_params(N, measurement, bin_factor, σ_guess)
	# find a σ_guess which results in a good estimate
	σ = [σ_guess for i = 1:N]


	peaks = find_peaks(measurement, bin_factor)
	x_offset = [peaks[i][1] for i =1:N]
	y_offset = [peaks[i][2] for i =1:N]

	# you can change that as well! Is it critical?
	I = [1.0 for i = 1:N]
	
	return ComponentVector(σ=σ, x_offset=x_offset, y_offset=y_offset, I=I)
end

# ╔═╡ 74f8a126-7e5c-4e1d-90bd-fe66065d5faf
begin
	# initial guess
	# try to find an binning factor which results in good peaks
	bin_factor = 1 # TODO an integer number which produces a good guess
	σ_guess = 1.0 # TODO a float number which produces a good guess
	params_guess = init_params(5, measurement, bin_factor, σ_guess);
end

# ╔═╡ 2b991e90-5091-4b15-93ef-489617f1534f
params_guess.σ

# ╔═╡ 3c38cdec-99d8-4c11-bedb-87137ea119ba
md"
The left image is the measured image.
The center image the initial guess.
The right image is the difference map suited to judge the position of the peaks.
"

# ╔═╡ 0a3cfe9b-888c-420a-9465-bef61d058c17
gray_show([measurement forward(params_guess) abs.(measurement .- forward(params_guess))])

# ╔═╡ 22d4842a-908f-485d-9bf4-96c053b106c6
md"### 5.5 Optim Specific Parts for the Reconstruction"

# ╔═╡ c3996433-e27d-4227-8e18-9531a30ea389
begin
	# the function maps the params to a single scalar value
	function f(params)
		loss(measurement, forward(params))
	end
	# this function calculates the 
	g!(G, params) = isnothing(G) ? G : G .= gradient(f, params)[1]
end

# ╔═╡ 4f55b1ea-8283-4884-9a24-5384b2b975c9
PlutoTest.@test !isnothing(gradient(f, params)[1])

# ╔═╡ fb0a02f0-258b-44cc-ad69-0dca3f3ec969
md"# 5.6 Optimization"

# ╔═╡ a2311895-c819-4a92-ae08-3ba746997a4e
# TODO
# change the number of iterations here
# Which number provides good results?
# Does it converge at some point?

iterations2 = 10

# ╔═╡ d30c5e75-8a58-4231-8164-c7d783b9bc02
res = optimize(f, g!, params_guess, LBFGS(), Optim.Options(iterations=30))

# ╔═╡ 90b98a76-1bc7-43e0-927c-1cf94d35ffd0
output_optim = forward(res.minimizer);

# ╔═╡ b5880735-c615-440c-a0a0-56a6a024494a
gray_show([measurement output_optim measurement .- output_optim])

# ╔═╡ efaf6cfb-bf37-4cc2-be30-abbc6706e905
heatmap(measurement .- output_optim, title="Difference map")

# ╔═╡ 19a1ff11-1276-46ab-b84b-a66898522068
md"## Check if the values look plausible"

# ╔═╡ 060ef38d-312b-4487-b59d-0ba288b16daf
md"The operator `|>` in an expression like `f(x) |> g` is the same as `g(f(x))`. It's only a convenvient wrapper"

# ╔═╡ e60c3150-7658-4a3d-819f-b1e6293a27fb
params.σ |> sort

# ╔═╡ 17ed7c8d-4d12-4008-8745-e96f36ce85b1
res.minimizer.σ |> sort

# ╔═╡ e677b9f8-38ee-41cd-b319-ef1cc48b17e2
params.I |> sort

# ╔═╡ 854f732f-441b-45b1-9a00-2b7ae854dc47
res.minimizer.I |> sort

# ╔═╡ 45abec82-b841-4d8a-b2ae-bba738352da3
res.minimizer.y_offset |> sort

# ╔═╡ ff1c6ed2-e4b1-4f6a-87df-44f350bb50f7
params.y_offset |> sort

# ╔═╡ 8ffb693f-f5ca-45a5-8d1b-5c96885118d0
PlutoTest.@test (res.minimizer.x_offset |> sort) ≈ (params.x_offset |> sort) rtol=0.01

# ╔═╡ 67db2159-c2f0-4130-8e82-6b75907db82f
PlutoTest.@test (res.minimizer.y_offset |> sort) ≈ (params.y_offset |> sort) rtol=0.01

# ╔═╡ Cell order:
# ╠═9112b09c-5a21-11ec-0847-1971b3c9a6cd
# ╟─33890cd9-4aa6-4e64-815a-f59a541ae8c6
# ╠═4b66d9ba-eb36-4f53-8e87-28b6eadbd828
# ╟─606ad4de-213f-4aac-a0a9-9a6827c05c29
# ╠═e7a503cf-c59c-4737-95f5-b8f38548833a
# ╟─3194824d-ed15-479a-af10-a1803f9f20bc
# ╠═7ef1aaf2-081c-4885-9ab3-4606cf0656b4
# ╠═400aeebf-21bd-4b58-9b64-ccec3071df63
# ╠═d7741c07-0982-4e57-bf95-a3ee0bc6f0b1
# ╠═aa15a3ed-0f97-4ef9-9704-0ede98426b6c
# ╠═f4e2cc11-e86e-4afc-a021-aed27283a5f1
# ╟─dc9fa103-6a00-4129-b5d1-c1b36216d13d
# ╠═6ba1619b-036a-480d-b3bb-88ea6f5b259e
# ╠═f9bb5a74-067d-4afd-ae61-7f41f2e1dbca
# ╟─0d7e91be-e03e-454c-9ebd-c0b68ca93848
# ╟─72cdab83-0162-4951-8751-b91cb6fd0e49
# ╠═f8c665e4-e07f-4995-ad84-5a31658be5f4
# ╠═bfb88c5e-0e45-428b-a66c-b9c37f633c6b
# ╠═49143f59-2f8f-46e9-ac32-c4681164ef82
# ╠═e33d9b1f-dc9b-49c0-a6e3-b1e2266df999
# ╟─8a9da6e2-528a-41e5-9bc5-750885d94ca0
# ╠═53364e6f-b672-4c60-8fe1-845ba85399ba
# ╠═30e313ee-aca2-4469-97cf-08acd489aaef
# ╠═4c91d0da-201a-4281-91a2-2de626ab4a30
# ╟─340851e8-a66d-4643-83d1-48fb775dde8e
# ╠═cfc01fbb-5ee4-4909-ba67-2034506e55e8
# ╠═ae7c45b6-c8a7-4fe0-b922-9ab40fcce372
# ╠═8c91142a-5b2d-4dfc-9764-87a66f90f0cb
# ╟─dcba043b-db09-4adc-8239-a6439a9c074e
# ╠═bbb7dda6-84c2-4172-a888-85a3658c1556
# ╠═231698fd-bb16-4895-9278-0d41dfafdb7e
# ╠═45f089ec-a7cb-4941-ad04-7a6c6c55dbef
# ╠═d725c173-0123-40ed-aaa0-feec1dcd7a25
# ╟─dfc9d8f3-6b16-476a-bba9-1c7f55229f57
# ╠═9bc5b039-5c13-46bc-8d3b-9edae93d164a
# ╟─954f06a6-ac27-4596-a978-e1274b2532d8
# ╠═46185370-aaf3-48c3-b297-b3a2843a0435
# ╠═7c51a261-a188-469d-8020-876b1b1dcbf0
# ╠═fae6889b-65f5-4b90-972f-56187b69fee5
# ╟─23b9ea69-99d5-4a49-8e36-cd25323c8858
# ╠═e9c17987-029e-4bd9-824e-47175f4d6924
# ╠═046ec177-9394-4b7d-bead-68590e169f1b
# ╠═eb9b2246-c9d9-442e-bde4-48ed14bb3fa6
# ╠═9cdf2e65-af36-4421-a15b-fdc4c87569b4
# ╠═7ecb1d8d-334c-4043-9378-adcbe0b0bf35
# ╟─9b5b3495-0d3b-4f7c-9f51-04245ebd59c2
# ╠═26950064-0127-41fd-9973-6c170bd6b8fe
# ╠═ef9c0737-ffbc-498b-80d2-2e93558c508f
# ╠═70a9e03f-d44f-4cce-a82d-898e63f789fd
# ╠═70453553-7dbc-46f1-a141-f4d19f2ae3d4
# ╠═6ac55320-b94f-44c2-9669-1d4e7eb3ddee
# ╠═73416e0d-ed2b-4b95-aa43-ce58de7f29aa
# ╠═42f34ed6-2548-4b53-b714-2128f21ca780
# ╠═56d566e3-632c-4852-839b-adf505122ad2
# ╠═26f1a0c2-3787-4335-958b-12719e2901bf
# ╟─2b3c151a-d7bd-40e4-97d7-f121c9da23a6
# ╠═32bd26f1-0d04-4589-a2d5-1e01abce4a7d
# ╟─726d6133-b7a2-4ff2-a844-e93eee1b7088
# ╠═22e9ac0f-0685-4a9d-b144-10217290c18e
# ╠═0447b66d-b6ff-470c-a0b9-41c754252474
# ╟─dc66401d-2581-4d6f-8b36-d15a2d21391a
# ╠═daa77619-e7a8-4c6a-9854-d8ef21042277
# ╠═1a505ff5-4745-42c5-bc40-bc1075fcd4d6
# ╠═74f8a126-7e5c-4e1d-90bd-fe66065d5faf
# ╠═2b991e90-5091-4b15-93ef-489617f1534f
# ╟─3c38cdec-99d8-4c11-bedb-87137ea119ba
# ╠═0a3cfe9b-888c-420a-9465-bef61d058c17
# ╟─22d4842a-908f-485d-9bf4-96c053b106c6
# ╠═c3996433-e27d-4227-8e18-9531a30ea389
# ╠═4f55b1ea-8283-4884-9a24-5384b2b975c9
# ╟─fb0a02f0-258b-44cc-ad69-0dca3f3ec969
# ╠═a2311895-c819-4a92-ae08-3ba746997a4e
# ╠═d30c5e75-8a58-4231-8164-c7d783b9bc02
# ╠═90b98a76-1bc7-43e0-927c-1cf94d35ffd0
# ╠═b5880735-c615-440c-a0a0-56a6a024494a
# ╠═efaf6cfb-bf37-4cc2-be30-abbc6706e905
# ╟─19a1ff11-1276-46ab-b84b-a66898522068
# ╟─060ef38d-312b-4487-b59d-0ba288b16daf
# ╠═e60c3150-7658-4a3d-819f-b1e6293a27fb
# ╠═17ed7c8d-4d12-4008-8745-e96f36ce85b1
# ╠═e677b9f8-38ee-41cd-b319-ef1cc48b17e2
# ╠═854f732f-441b-45b1-9a00-2b7ae854dc47
# ╠═45abec82-b841-4d8a-b2ae-bba738352da3
# ╠═ff1c6ed2-e4b1-4f6a-87df-44f350bb50f7
# ╠═8ffb693f-f5ca-45a5-8d1b-5c96885118d0
# ╠═67db2159-c2f0-4130-8e82-6b75907db82f
