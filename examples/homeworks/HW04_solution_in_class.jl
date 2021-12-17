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

# ╔═╡ 20bb3256-f1bb-4b3b-b410-89969443fd4d
begin
    using Pkg 
    Pkg.activate("../../")
    using Revise
	# maybe needed since we added a few dependencies
	Pkg.instantiate()
end

# ╔═╡ db61ecb1-6ed9-44d9-b8e4-b50622efbac1
using TestImages, ImgProcMic, ImageShow, Random, PlutoTest, Plots, FourierTools, Statistics, FFTW, IndexFunArrays, SpecialFunctions, PlutoUI, Noise, Optim, ForwardDiff

# ╔═╡ 82726a23-060c-4c7d-91c1-e78a22fb98d6
md"# 1 Fourier Transforms

In the last homework we learnt that FFTW calculates the Fourier transform such that the DC frequency (zero frequency) is at the first entry of the array.

To shift the frequency to the center, we normally use `fftshift`.
However, another issue is, that the FFT also interpretes the center of the array at the first index position.
So for example, we would expect that the Fourier transform of the delta peak is a constant array! 

As you can see below, the Fourier transform is only a constant array if the delta peak is at the fist entry
"

# ╔═╡ ebe90686-c72f-4a42-a644-f06babe00f41
# FFT of delta peak results in constant array
fft([1.0, 0.0, 0.0])

# ╔═╡ 5053c100-5f27-4f2f-acbe-e12c9070feac
# no constant array since delta is not at the first entry
fft([0.0, 1.0, 0.0])

# ╔═╡ 361a7a34-d70b-4597-948c-80ed913a562b
# no constant array since delta is not at the first entry
fft([0.0, 0.0, 1.0])

# ╔═╡ 653a94c9-cb89-47df-8ba5-0ce683440b78
md"
The reason for this behaviour is that the second example is a shifted array of the first one. Hence, in Fourier space this corresponds to a phase ramp!

In the last homework we programmed `ffts(x) = fftshift(fft(x))` and `iffts(x) = ifft(ifftshift(x))`.

We now also introduce `my_ft` and `my_ift`.


The qualitative meaning of the different conventions for the Fourier transform of a signal with length `N` is:
* `fft`: center in real space is at `(1,)` and in Fourier space at `(1,)`
* `ffts`: center in real space is at `(1,)` and in Fourier space at `(N ÷ 2 + 1,)`
* `ft`: center in real space is at `(N ÷ 2 + 1,)` and in Fourier space at `(N ÷ 2 + 1,)`


"

# ╔═╡ b65e0745-82c6-48e1-a956-fa71583dad15
begin
	my_ft(x) = fftshift(fft(ifftshift(x)))
	my_ift(x) = fftshift(ifft(ifftshift(x)))
end

# ╔═╡ ee44d4e9-dc06-475f-9ea8-0c63a7016298
md"
FFT output 

$[f_0, f_1, f_2, f_{-2}, f_{-1}]$"

# ╔═╡ 5b46a865-ce99-4887-bb2b-d5ede2fb0878
md"
FFTs output

$[, f_{-2}, f_{-1}, f_0, f_1, f_2]$" 

# ╔═╡ c53325bd-eeb6-4663-867d-44fd3ace273b
md"## Task 1.1
Try to change the following test below.
You are only allowed to insert `fftshift` and `ifftshift` statements.
Don't change the order of the Fourier transform calls.
"

# ╔═╡ b57917e8-3d2e-433b-84df-6129f760f954
begin
	arr_even = [1.0,2,3,4]
	arr_odd = [1.0,2,3,4,5]
end

# ╔═╡ 6e0e223d-9107-4121-880a-8ed5d7e5e9c2
md"The Test is broken but we fix it by changing the right hand side. Do that for the red tests below as well"

# ╔═╡ 5213f82b-5e06-4cee-a0d1-21f1c5cc2998
PlutoTest.@test ffts(arr_even) ≈ fftshift(fft(arr_even))

# ╔═╡ 64103e19-ce79-48b7-bac9-b429f6d423c2
# this one is fixed
PlutoTest.@test ffts(arr_even) ≈ fftshift(fft(arr_even))

# ╔═╡ f380db27-8773-413b-978f-4496fc585ae3
md"### Task 1.1
Now try to fix always the right hand side accordingly!
"

# ╔═╡ 0464d972-fcaf-4f83-be7d-073d217e8f4c
# TODO
PlutoTest.@test ift(arr_odd) ≈ fftshift(iffts(arr_odd))

# ╔═╡ c6dbecc2-a550-4d83-98b9-7d55541fbc36


# ╔═╡ 87fabbfe-e25b-467a-9fbd-ceec98ba4ed6
# TODO
PlutoTest.@test iffts(arr_odd) ≈ ifft(ifftshift(arr_odd))

# ╔═╡ c537e21b-5ed2-4cac-947a-e052474a2442
# TODO
PlutoTest.@test ffts(arr_odd) ≈ ft(fftshift(arr_odd))

# ╔═╡ 3093ae8d-27d4-4d32-8021-80fc6b0d1472
# TODO
PlutoTest.@test ifft(arr_odd) ≈ ifftshift(ift(fftshift(arr_odd)))

# ╔═╡ a43b5bb5-d56b-43c7-aa96-ed2d9f217373
md"# 2 Convolution

From calculus class we know that a convolution can be expressed via Fourier transforms like

$U * h = \mathcal{F}^{-1}\left[\mathcal{F}[U] \cdot \mathcal{F}[h] \right] = \mathcal{F}^{-1}\left[\mathcal{F}[U] \cdot H \right]$

where $*$ is a convolution and $\cdot$ an elementwise multiplication. $H$ is the OTF of the PSF $h$.

Now implement it yourself!
"

# ╔═╡ eca132a9-70b5-491e-af72-177a2a70e563
md"
Sum based convolution $\mathcal{O}(N^2)$

FFT based convolution $\mathcal{O}(N \cdot \log N)$
"

# ╔═╡ a0362131-41ad-4151-b851-d75af22791e1
"""
	my_conv(U, h)

Calculates a FFT based convolution between U and h.
The output is a real array! 
So either use real valued transforms `rfft` or use `fft` with a final `real` conversion.

# Example
```julia-repl
julia> my_conv([1.0,0,0,0], [1.0, 0.5, 0.0, 0.5])
4-element Vector{ComplexF64}:
 1.0 + 0.0im
 0.5 + 0.0im
 0.0 + 0.0im
 0.5 + 0.0im
```
"""
function my_conv(U::AbstractArray{T, N}, h; center=ntuple(i -> 1, N)) where {T, N}
	# convolution expects the PSF kernel to be the in the corner
	# then shift the kernel to the corner 
	# center the argument indicating where the PSF is currently centered around
	return real(ifft(fft(U) .* fft(circshift(h, .- (center .- 1)))))
	# return real(irfft(rfft(U) .* rfft(h)))
end

# ╔═╡ 5c6c4d94-36b7-4531-9643-56d55f802b78
md"
5x5 array -> center ist at (3,3)

(3,3) .- (1,1) = (2,2)
"

# ╔═╡ e04f6e47-ec69-40b7-ad35-3488a6719e4a
begin
	z = zeros((5,5))
	z[3,3] = 1
	z
end

# ╔═╡ 35d85cf9-a97b-4f93-b5f4-9519d01e6109
circshift(z, (-(3-1), -(3-1)))

# ╔═╡ c72e9c1b-1030-4644-9ab4-ee020fff0823
rfft([1,2,3])

# ╔═╡ 14f68ed9-9454-47b1-948a-49c51621b472
fft([1,2,3])

# ╔═╡ 02de02e2-d489-448a-98a9-8c79c3f48e80
my_conv(randn(12,), randn(12,));

# ╔═╡ b568e681-7eaf-4c1a-9f36-f46163c35041
begin
	img = Float32.(testimage("mandril_gray"))
	Gray.(img)
end;

# ╔═╡ cdf36a7b-54ff-4ab7-9497-81d1ed684be3
# some simple kernel
kernel = IndexFunArrays.normal(img, sigma=7);

# ╔═╡ 8dfd1d4b-da79-4e0b-9575-cd58018f9640
gray_show(kernel)

# ╔═╡ 0d9e2e69-e51f-483c-aadd-6bde1ab0c28a
md"You should see the blurry monkey here. If not, it might be wrong."

# ╔═╡ 5436a802-9d78-48ff-af79-2cf8065fd514
Gray.(my_conv(img, kernel, center=(257, 257)))

# ╔═╡ 2eb0bea1-b6dc-417f-81b3-435fede2aa66
md"## 2 Test"

# ╔═╡ c7a4ce47-9bdf-46f3-88a4-888df19b9cb1
PlutoTest.@test my_conv([1.0,2,3,4], [1.0,0,0,0]) ≈ [1,2,3,4]

# ╔═╡ 3b479c44-4f6d-41ad-af70-04616a64154c
PlutoTest.@test my_conv([1.0,2,3,4], [0.0,1.0,0,0], center=2) ≈ [1,2,3,4]

# ╔═╡ 19a4fdc2-698b-4eed-845f-364134b80df9
my_conv([1.0,2,3,4], [0.0,1.0,0,0], center=2)

# ╔═╡ 39807680-27cf-444d-9d93-d845baab61a4
PlutoTest.@test my_conv([1.0,2,3,4,5], [0.0,0.0,1.0,0,0], center=3) ≈ [1,2,3,4, 5]

# ╔═╡ 51bcf5d5-0405-467e-b528-275965fa1287
PlutoTest.@test my_conv(img, IndexFunArrays.delta(img, offset=(1,1))) ≈ img

# ╔═╡ da0d4ab1-b1d6-4817-ad38-6d3213c4e075
PlutoTest.@test my_conv([1, 2, 3, 4, 5, 6], [-1, 2, 2, 1, 3, 1]) ≈ [36.0, 32.0, 28.0, 30.0, 20.0, 22.0]

# ╔═╡ 09321d84-f9a7-412d-8fe4-3ece1bd90b21
md"# 3 Incoherent Image Formation

In this part we want to simulate an incoherent imaging situation (fluorescent microscope).
We simplify it by only considering an unitless `radius`.

As reminder, the qualitative procedure is as following:

We take a point source, Fourier transform it, take only the frequency inside the radius, go back to real space, take the absolute squared.

Pay attention where the frequencies should be located when you apply the `circ`.
"

# ╔═╡ ebfe7f3a-098a-41d8-a5bd-2c1e2b374fe0
begin
	"""
		circ(size, radius)
	
	`size` the size of the resulting array
	and `radius` the radius of the circle
	"""
	circ(size, radius) = rr2(size) .<= radius^2
end

# ╔═╡ 772fe3f9-6db8-4df4-8813-cbb334035351
"""
	calc_psf(arr_size, radius)

Calculate a simple PSF. `arr_size` is the output size and `radius` is the radius 
in Fourier space.
The output array is normalized by its sum to 1.
"""
function calc_psf(arr_size, radius)
	arr = zeros(Float64, (arr_size))
	# \div<TAB>
	# place point source in center
	#arr[(arr_size .÷ 2 .+ 1)...] = 1

	# point source placed at the center of the array
	arr[arr_size[1] ÷2 + 1, arr_size[2] ÷2 + 1] = 1

	# first fourier transform due to microscope objective
	# by using: both the data and the frequencies are centered around the center
	arr_ft = ft(arr)
	
	# low pass filter because of aperture stop
	# .*= point wise in-place operation
	arr_ft .*= circ(arr_size, radius)

	# tube lens which calculates another fourier
	arr_ft_ft = ft(arr_ft)

	# abs2 intensity measurement and sum normalized to 1
	I = abs2.(arr_ft_ft)
	I ./= sum(I)
	return I
end

# ╔═╡ f1b8ebb2-ea4b-4a9e-8e53-91a69e4c76ed
circ((10,10), 3)

# ╔═╡ 8bd74a76-823e-42c2-899b-ec5ca4e42398
collect(ft(ft([1,2,3.0]))) ./ 3

# ╔═╡ e53e4f06-c311-4731-97a7-cf893e357c0b
# size 10 -> 6 

# ╔═╡ 33b3a409-2690-4a4a-a091-cdfe6a831c59
md"r = $(@bind r PlutoUI.Slider(0.01:0.1:10.0, show_value=true))"

# ╔═╡ f209c5de-c2bd-4a0b-bbfd-6831e0254023
gray_show(calc_psf((64, 64), r))

# ╔═╡ 8b922c48-7d56-4e5b-b039-789e281c5fe1
md"r2 = $(@bind r2 PlutoUI.Slider(1:1:256, show_value=true))"

# ╔═╡ 119da3f0-0f1d-4a65-93cd-868f3c1d5f3e
h = calc_psf(size(img), r2);

# ╔═╡ 5830d782-67a3-4cae-847c-bdbdf0217aa7
# change this line such that the monkey is correctly centerd
Gray.(my_conv(img, h, center=(257, 257)))

# ╔═╡ fbdcb172-b079-46a5-b8f3-f5ece30fe25a
md"## 3 Test"

# ╔═╡ 66db7400-9791-4952-9812-39b22829b29a
# large radius is a perfect optical system -> delta peak
PlutoTest.@test calc_psf((2, 2), 1000) ≈  [0 0; 0 1]

# ╔═╡ baff7f36-d18a-4434-b979-662b6d44eb46
PlutoTest.@test sum(calc_psf((13, 12), 3)) ≈ 1

# ╔═╡ 7d92a5c5-d48d-429b-85fa-63904f21fc62
PlutoTest.@test minimum(calc_psf((13, 12), 3)) ≥ 0 

# ╔═╡ fd85fd4a-3e43-431c-aaa6-e92848c9e304
# compare to (approx) analytical solution
begin
	h2 = jinc.(7.25 / 9.219π * IndexFunArrays.rr((64, 64))).^2
	h2 ./= sum(h2)
	PlutoTest.@test ≈(1 .+ h2, 1 .+ calc_psf((64, 64), 7.25), rtol=0.001)
end

# ╔═╡ 08936039-7557-4ea3-8e26-5fbcdf12aec2
md"# 4 Generalized Wiener Filtering

A simpled deconvolution approach suited for Gaussian noise is the Wiener filter.
You can find the details in the slides.
Try to implement it here!
"

# ╔═╡ 7256f510-10ac-4fb2-99fc-0ffbcd45aae3
function wiener_filter(img, h, ϵ)
	H = fft(h)
	# basically the convolutional kernel, but already in Fourier space!
	wiener_kernel = conj.(H) ./ (abs2.(H) .+ ϵ)

	output = ifft(fft(img) .* wiener_kernel)
	return real(output)
end

# ╔═╡ 9f4d5c69-c5a8-4a34-9100-e8209ede71b4
begin
	# PSF
	h3 = ifftshift(calc_psf(size(img), 20))
	gray_show(h3)
end;

# ╔═╡ 2d5653cf-fa36-4a0e-99cd-4c9769b84705
begin
	img_b = my_conv(img, h3)
	Gray.(img_b)
end

# ╔═╡ 0f8555c7-a1c2-4643-912b-6816019a848a
img_gauss = add_gauss(img_b, 0.1);

# ╔═╡ 34ced1ed-82f4-4c32-9cec-086ff2a62bce
img_poisson = poisson(img_b, 20);

# ╔═╡ cbd3d6c4-bf40-4431-a7b9-5b26b411a9b9
Gray.([img_gauss img_poisson])

# ╔═╡ 29cc8e86-c109-411e-ba86-a8155f7c3a94
md"
pow1 = $(@bind pow1 Slider(-6:0.1:-0, show_value=true))

pow2 = $(@bind pow2 Slider(-6:0.1:-0, show_value=true))
"

# ╔═╡ 82542705-e24e-409e-a7bd-491ce750007e
img_gauss_wiener = wiener_filter(img_gauss, h3, 10^pow1);

# ╔═╡ e50febee-5c4b-44d7-9d78-29395a8c3ab6
img_poisson_wiener = wiener_filter(img_poisson, h3, 10^pow2);

# ╔═╡ 0b46da45-b743-40a1-a1f8-0581b6fd741a
Gray.([img_gauss_wiener  img_poisson_wiener])

# ╔═╡ f85f964d-0443-4e19-b655-036f82a0ba69
md"## 4 Test"

# ╔═╡ 94f64888-b732-4367-a905-b57de684fcf7
PlutoTest.@test wiener_filter([1.0, 2.0], [1.0, 0.0], 0) ≈ [1.0, 2.0]

# ╔═╡ 3d89c0be-a888-4e2f-8820-85e07bd6be30
PlutoTest.@test  wiener_filter([1.0, 2.0], [1.0, 0.1], 0)  ≈ [0.808081, 1.91919] rtol=1e-5

# ╔═╡ c1e8419c-c748-490b-93d3-9bbcde4f4da9
md"# 5 Gradient Descent Optimization
In this part we want to implement an optimization routine with a _strange_ sensor.

The sensor has an additive Gaussian noise part but also an quadratic gain behaviour.
See the function below
"

# ╔═╡ c337e8cf-bab9-46cd-aae8-22f6265f9cb7
begin
	function strange_sensor_f(value::T) where T
		value .^2
	end

	function strange_sensor(value::T) where T
		return abs.(randn(T) * 0.10f0 + strange_sensor_f(value))
	end
end

# ╔═╡ ff2288f0-2edf-4f22-90ef-af5777676ae7
# strange output
strange_sensor.([1.0 2; 3 4])

# ╔═╡ d23fe57a-7255-4d8f-a00a-eaec953213b2
md"
First we simulate the full `img` of the mandril with that sensor.
Clearly the appearance has changed due to the quadratic behaviour but also noise is visible.
"

# ╔═╡ a0f77be2-c40c-4372-a245-45b76ddc5861
begin
	img_strange = strange_sensor.(img) # todo
	gray_show(img_strange)
end

# ╔═╡ cdc25e03-c6fd-4ee0-801e-24654a83d65d
md"## 5.1 Task
Since our sensor is quite noisy, we want to measure the image multiple times.
Try to complete `measure`.
"

# ╔═╡ 4af883c2-fdc9-458c-998b-ff0b8b5df146
"""
	measure(img, N)

Measure the `img` `N` times. Return a vector with the `N` measured images.
"""
function measure(img, N)
	# using the . to apply it elementwise
	return [strange_sensor.(img) for i in 1:N]
end

# ╔═╡ c02969bc-3b5e-4422-a3c9-3a7d00cb3ddf
imgs = measure(img, 10); # TODO: simulate 10 times

# ╔═╡ e3a8ef81-0d19-4e75-b137-6454ce262991
Gray.([reduce(hcat, imgs[1:end÷2]); reduce(hcat, imgs[end÷2+1:end])])

# ╔═╡ abcabcd5-4e64-4691-b602-2d4c0d146615
imgs[1] ≈ imgs[2]

# ╔═╡ ebd74bcb-4187-469f-a206-ecf9041918f1
md"## 5.1 Test"

# ╔═╡ 7579c331-fa53-47f4-a479-312f2f7a3931
PlutoTest.@test typeof(measure([1.0], 12)) <: Vector

# ╔═╡ 3cca079c-1245-493b-ae6c-9db18e11835c
PlutoTest.@test length(measure([1.0], 12)) == 12

# ╔═╡ 0ae38ccc-9129-4c61-9810-dbc448e8a07f
begin
	Random.seed!(42)
	a = measure([1.0 2.0; 3 4], 3)
end;

# ╔═╡ 4f5a9a27-1893-49e4-a2e9-59ba3a2340a2
begin
		Random.seed!(42)
		b = [abs.([1.0 2.0; 3 4].^2 .+ randn((2,2)) * 0.1f0) for i = 1:3]
end;

# ╔═╡ 37ce2f96-377d-48d7-bc56-f83b0cce349c
PlutoTest.@test a ≈ b

# ╔═╡ cd0829a1-cdf1-45c9-a4dd-91bb3ec5bb03
md"## 5.2 Loss Function
Having our 10 images we would like to retrieve a best guess for the underlying image.
Taking the mean does not work in this case since the input image is modified by `strange_sensor_f`.

Therefore, we interprete the reconstruction as an optimization problem.
Try to find the corresponding pages in the lecture.

Generally, we want to minimize a loss function which looks like

$\underset{\mu}{\mathrm{argmin}}\, \mathcal L = \sum_{\text{img} \, \in \, \text{imgs}} \sum_{p_i \, \in \, \text{img}} (\text{img}[i] - f(\mu[i]))^2$


So we sum over all measured images. For each image, we additionally sum each pixel and  compare it with $f(\mu[i])$.
$f$ is the same as `strange_sensor_f` and by calling $f(\mu[i])$ we apply $f$ to the reconstruction $\mu$. Via that function call, we hope that we find a $\mu$ which fits to the measurments. So $f$ is the forward model of the sensor (without the noise part).
"

# ╔═╡ 328b5994-b1c4-4850-b8d3-2f3781bed99f
"""
	loss(imgs, μ)

Calculate the loss between the `ìmgs` and `μ`.
Basically implement the sum of the square difference value.
Don't forget to apply `strange_sensor_f` to `μ` before!

Using two for loops is perfectly fine!
"""
function loss(imgs::Vector{<:AbstractArray{T, N}}, μ::AbstractArray{T, N}) where {T, N}
	# bad style, because is an integer value
	# loss = 0
	# better use this!
	loss = zero(T) # 0
	for img in imgs
		#for (i, pixel) in enumerate(img)
		for i in eachindex(img)
			loss += abs2(img[i] - strange_sensor_f(μ[i]))
		end
	end

	# solution in a single line but slower because of the need to allocate
	# temporary array
	#return sum(sum(abs2.(img .- strange_sensor_f.(μ))) for img in imgs)
	
	return loss
end

# ╔═╡ 78da1c47-1de7-4d95-a1e1-cd60e912a0fc
# comparison with ground truth image
loss(imgs, img) 

# ╔═╡ 3d182fa9-84bb-4504-8945-bf653ce1f99d
# the ground truth is not the minimum...
# why not?
loss(imgs, img .+0.0001f0) 

# ╔═╡ b56a311e-912a-4e7c-b821-4124b847194a
md"## 5.2 Test"

# ╔═╡ 840ddb7e-56ba-4d7a-8f08-cee67128315f
PlutoTest.@test loss([[1]], [2]) isa Number

# ╔═╡ 528194f2-9f74-4dda-94f8-3e4f0e515bc9
PlutoTest.@test loss([[1]], [2])  ≈ 9

# ╔═╡ a203fb4f-c3d6-4d46-9c58-2454b71b0e1b
PlutoTest.@test loss([[1], [2], [4.0]], sqrt.([2]))  ≈ 5

# ╔═╡ 063ef53f-d152-4282-af5f-7f2addce3ab0
md"## 5.3 Gradient of `strange_sensor_f`
For the optimization we later want to apply a gradient descent optimization scheme.
Hence, we need a few gradients!
"

# ╔═╡ 95392d70-07cf-47a7-8707-f1dab177e7a5
"""
	 grad_strange_sensor_f(value::T)

Calculate the gradient of `strange_sensor_f`.
Use the rules you know already from school!
"""
function grad_strange_sensor_f(value::T) where T
	2 .* value
end

# ╔═╡ 01de98fe-5537-4745-acf8-99daa0b8aa6f
grad_strange_sensor_f(1)

# ╔═╡ 75549871-14a3-4b9f-9b98-cccc34ed315d
md"## 5.3 Test"

# ╔═╡ 867b3bf0-1208-48a1-b1ee-904d11b28e1f
PlutoTest.@test grad_strange_sensor_f(0) ≈ 0

# ╔═╡ 7c2d2d6d-f933-452e-9870-7dce7ad4bf1d
# comparison with automatic differentation package!
PlutoTest.@test ForwardDiff.derivative(strange_sensor_f, 42) ≈ grad_strange_sensor_f(42)

# ╔═╡ cd363a92-a473-47f8-b41b-c5d5249fec90
md"## 5.4 Gradient of Loss
Now we come to the last part of the gradient.
We need the full gradient of the loss function.

The gradient of the loss function with respect to `μ` will be an array again.
That is plausible since the loss function accounts for all pixels. By changing a single pixel we also change the value of the loss function. Therefore, for each pixel a gradient exists describing the influence to the loss value.

You need to derive the loss with respect to $\mu$. But don't forget about the chain rule for `strange_sensor_f`!

Again, two for loops are perfectly fine!
"

# ╔═╡ d3b3d839-4eee-41d1-ad85-897168e37fd7
md"
$L$

$\frac{d L}{d \mu} = \nabla L$
"

# ╔═╡ 1ad4cf95-a3fb-4e45-b7bd-80ab724c158e
function gradient(imgs::Vector{<:AbstractArray{T, N}}, μ::AbstractArray{T, N}) where {T, N}

	# output array of zzeros
	grad = zeros(T, size(imgs[1]))
	for img in imgs
		# loss += abs2(img[i] - strange_sensor_f(μ[i]))
		grad .+= 2 .* (img .- strange_sensor_f.(μ)) .* (.- grad_strange_sensor_f.(μ))
	end

	return grad
end

# ╔═╡ cb41a2f9-a0c5-4eeb-af51-9bf40a5d7fd6
gradient(imgs, img)

# ╔═╡ f72450cb-a54e-4827-9c33-7a44f561bd43
md"## 5.4 Test"

# ╔═╡ 7e6eb33d-0721-4bb6-a9ee-1cfb07a17e46
PlutoTest.@test gradient([[1.0], [2.0]], [2.5]) ≈ [95]

# ╔═╡ cf550002-13ce-4788-8206-790fb355a91b
PlutoTest.@test gradient([[3.5, 2.1], [2.0, 0.0]], [3.23, 23.2]) isa Vector

# ╔═╡ bfd35c9f-1449-4d86-bb50-9bbbd6ea2c30
PlutoTest.@test size(gradient([[3.5, 2.1], [2.0, 0.0]], [3.23, 23.2])) == (2,)

# ╔═╡ c1795dd9-f8a5-472d-bd82-7871e8603534
PlutoTest.@test  gradient([[3.5, 2.1], [2.0, 0.0]], [3.23, 23.2]) ≈ [198.526136, 99702.46399999999]

# ╔═╡ c5436e99-513b-4c51-b3ad-f82318304a3e
md"## 5.5 Gradient Descent"

# ╔═╡ b393a0f5-af03-4ded-8e22-886022f5da30
"""
	gradient_descent(imgs, μ, N_iter, step_size)

Runs a gradient descent using `gradient` and the experimental images `imgs`.
`N_iter` is the number of iterations, `step_size` is the step size of the gradient step.

The optimized output is `μ_optimized`.
"""
function gradient_descent(imgs, μ, N_iter, step_size)
	# TODO
	μ_optimized = copy(μ)
	for i = 1:N_iter
		μ_optimized .= μ_optimized .- step_size .* gradient(imgs, μ_optimized)
	end
	return μ_optimized
end

# ╔═╡ c81c5eaa-0e0f-4730-9148-ec0e7b63cdd4
μ_init = ones(Float32, size(imgs[1])) # TODO, what could be a good initilization?

# ╔═╡ 32f6d83a-d5db-4a21-b2c4-d8876de38c46
md"
Try to change the gradient step and the number of iterations.

Number of iterations $(@bind N_iter Slider(1:100, show_value=true))

step size $(@bind step_size Slider(1f-5:1f-5:1f-1, show_value=true))
"

# ╔═╡ f7d7cf86-ece9-406b-af78-f86177a767c4
μ_optimized = gradient_descent(imgs, μ_init, N_iter, step_size);

# ╔═╡ 2110469f-16f9-4454-996a-a949a94fffa3
# that value should get smaller with more iterations
# smaller is better
loss(imgs, μ_optimized)

# ╔═╡ 3643e55e-3205-4561-b271-058d59f46685
# this value should be larger than ↑
loss(imgs, μ_init)

# ╔═╡ 85c81f80-c959-4682-932b-26fe7f415f4d
Gray.(μ_optimized)

# ╔═╡ 6bf0c8cc-db74-4cb7-bd91-579f5b35d25a
Gray.(imgs[1])

# ╔═╡ 09313c1d-102f-4e0b-b9c8-7d2e904a1dd6
md"## 5.5 Test"

# ╔═╡ b2e7aae8-2777-4657-ba3d-f0dfcb581ede
PlutoTest.@test gradient_descent([[1.0], [2.0]], [3.0], 3, 0.01) ≈ [1.21021] rtol=1f-4

# ╔═╡ ae027113-998b-467e-8967-cc416d480377
PlutoTest.@test loss(imgs, μ_init) > loss(imgs, μ_optimized)

# ╔═╡ 4ff0afae-af4c-45d0-83b2-4fb5eead2fa1
PlutoTest.@test loss(imgs, gradient_descent(imgs, (imgs[1] .+ imgs[2]) / 2, 15, 0.000001);) < loss(imgs, imgs[1])

# ╔═╡ 2374bfc1-cd14-4bee-b5e5-bb15e0e6e253
begin
	μ_mean = sqrt.(reduce((a,b) -> a .+ b, imgs) ./ 10)
	Gray.(μ_mean)
end;

# ╔═╡ 9360c9a0-6a0f-4ff6-a215-23ce5c3c8099
md"#### Can you beat the _mean_?"

# ╔═╡ a837b22c-61f1-4a98-a362-c08b405c4dca
PlutoTest.@test loss(imgs, μ_optimized) < loss(imgs, μ_mean)

# ╔═╡ e2aec734-ce2b-4761-b3d0-b559df8b17da
md"Note that in this particular example the mean can be proven to be the best estimator, so it is not surprising to not be able to beat the mean. Yet, if the model cannot be inverted, we still may want to use a gradient-based optimization to solve the problem."

# ╔═╡ 959b4745-7742-459a-bef0-e374ec4aec17
[Gray.(img) Gray.(μ_mean) Gray.(μ_optimized)]

# ╔═╡ b3d54170-466c-4b0d-a337-280ef4ea87f3
md"## 5.6 Test
To check wether your gradient and your loss is correct, see also the following output of Optim (a sophisticated package for optimization).
If the output is not a nice Mandrill, there is most likely something wrong with your loss/gradients.
"

# ╔═╡ eafe5f6e-18ab-4341-8435-a3c0b9423b35
begin
	g_optim!(G, x) = isnothing(G) ? nothing : G .= gradient(imgs, x)
	f_optim(x) = loss(imgs, x)
end

# ╔═╡ 13304ea6-0639-4863-827e-d66a8630bc63
begin
	μ_optim_init = copy(μ_init)
	res = optimize(f_optim, g_optim!, μ_optim_init, ConjugateGradient(), Optim.Options(iterations=50))
	μ_optim = Optim.minimizer(res)
	res
end

# ╔═╡ c685ac28-79e8-4eda-8c0f-0944a1276691
Gray.(Optim.minimizer(res))

# ╔═╡ 7a691c80-e08d-423a-a69a-572f02fdddda
loss(imgs, μ_optim)

# ╔═╡ 19a0e512-46d6-429e-93f0-05e2faf95218
md"## Can you beat Optim?"

# ╔═╡ abe5aca2-61ce-4f99-ad75-0c84293cd7b3
PlutoTest.@test loss(imgs, μ_optimized) < loss(imgs, μ_optim)

# ╔═╡ 1171004b-96a1-4ee4-bbd5-2b7f2b1d582a
# yes, but hard with an hand optimized iterations/value pair

# ╔═╡ Cell order:
# ╠═20bb3256-f1bb-4b3b-b410-89969443fd4d
# ╠═db61ecb1-6ed9-44d9-b8e4-b50622efbac1
# ╟─82726a23-060c-4c7d-91c1-e78a22fb98d6
# ╠═ebe90686-c72f-4a42-a644-f06babe00f41
# ╠═5053c100-5f27-4f2f-acbe-e12c9070feac
# ╠═361a7a34-d70b-4597-948c-80ed913a562b
# ╟─653a94c9-cb89-47df-8ba5-0ce683440b78
# ╠═b65e0745-82c6-48e1-a956-fa71583dad15
# ╟─ee44d4e9-dc06-475f-9ea8-0c63a7016298
# ╟─5b46a865-ce99-4887-bb2b-d5ede2fb0878
# ╟─c53325bd-eeb6-4663-867d-44fd3ace273b
# ╠═b57917e8-3d2e-433b-84df-6129f760f954
# ╟─6e0e223d-9107-4121-880a-8ed5d7e5e9c2
# ╠═5213f82b-5e06-4cee-a0d1-21f1c5cc2998
# ╠═64103e19-ce79-48b7-bac9-b429f6d423c2
# ╟─f380db27-8773-413b-978f-4496fc585ae3
# ╠═0464d972-fcaf-4f83-be7d-073d217e8f4c
# ╠═c6dbecc2-a550-4d83-98b9-7d55541fbc36
# ╠═87fabbfe-e25b-467a-9fbd-ceec98ba4ed6
# ╠═c537e21b-5ed2-4cac-947a-e052474a2442
# ╠═3093ae8d-27d4-4d32-8021-80fc6b0d1472
# ╟─a43b5bb5-d56b-43c7-aa96-ed2d9f217373
# ╟─eca132a9-70b5-491e-af72-177a2a70e563
# ╠═a0362131-41ad-4151-b851-d75af22791e1
# ╠═5c6c4d94-36b7-4531-9643-56d55f802b78
# ╠═e04f6e47-ec69-40b7-ad35-3488a6719e4a
# ╠═35d85cf9-a97b-4f93-b5f4-9519d01e6109
# ╠═c72e9c1b-1030-4644-9ab4-ee020fff0823
# ╠═14f68ed9-9454-47b1-948a-49c51621b472
# ╠═02de02e2-d489-448a-98a9-8c79c3f48e80
# ╠═b568e681-7eaf-4c1a-9f36-f46163c35041
# ╠═cdf36a7b-54ff-4ab7-9497-81d1ed684be3
# ╠═8dfd1d4b-da79-4e0b-9575-cd58018f9640
# ╟─0d9e2e69-e51f-483c-aadd-6bde1ab0c28a
# ╠═5436a802-9d78-48ff-af79-2cf8065fd514
# ╟─2eb0bea1-b6dc-417f-81b3-435fede2aa66
# ╠═c7a4ce47-9bdf-46f3-88a4-888df19b9cb1
# ╠═3b479c44-4f6d-41ad-af70-04616a64154c
# ╠═19a4fdc2-698b-4eed-845f-364134b80df9
# ╠═39807680-27cf-444d-9d93-d845baab61a4
# ╠═51bcf5d5-0405-467e-b528-275965fa1287
# ╠═da0d4ab1-b1d6-4817-ad38-6d3213c4e075
# ╟─09321d84-f9a7-412d-8fe4-3ece1bd90b21
# ╠═ebfe7f3a-098a-41d8-a5bd-2c1e2b374fe0
# ╠═772fe3f9-6db8-4df4-8813-cbb334035351
# ╠═f1b8ebb2-ea4b-4a9e-8e53-91a69e4c76ed
# ╠═8bd74a76-823e-42c2-899b-ec5ca4e42398
# ╠═e53e4f06-c311-4731-97a7-cf893e357c0b
# ╟─33b3a409-2690-4a4a-a091-cdfe6a831c59
# ╠═f209c5de-c2bd-4a0b-bbfd-6831e0254023
# ╟─8b922c48-7d56-4e5b-b039-789e281c5fe1
# ╠═119da3f0-0f1d-4a65-93cd-868f3c1d5f3e
# ╠═5830d782-67a3-4cae-847c-bdbdf0217aa7
# ╟─fbdcb172-b079-46a5-b8f3-f5ece30fe25a
# ╠═66db7400-9791-4952-9812-39b22829b29a
# ╠═baff7f36-d18a-4434-b979-662b6d44eb46
# ╠═7d92a5c5-d48d-429b-85fa-63904f21fc62
# ╠═fd85fd4a-3e43-431c-aaa6-e92848c9e304
# ╟─08936039-7557-4ea3-8e26-5fbcdf12aec2
# ╠═7256f510-10ac-4fb2-99fc-0ffbcd45aae3
# ╠═9f4d5c69-c5a8-4a34-9100-e8209ede71b4
# ╠═2d5653cf-fa36-4a0e-99cd-4c9769b84705
# ╠═0f8555c7-a1c2-4643-912b-6816019a848a
# ╠═34ced1ed-82f4-4c32-9cec-086ff2a62bce
# ╠═82542705-e24e-409e-a7bd-491ce750007e
# ╠═e50febee-5c4b-44d7-9d78-29395a8c3ab6
# ╠═cbd3d6c4-bf40-4431-a7b9-5b26b411a9b9
# ╠═0b46da45-b743-40a1-a1f8-0581b6fd741a
# ╠═29cc8e86-c109-411e-ba86-a8155f7c3a94
# ╟─f85f964d-0443-4e19-b655-036f82a0ba69
# ╠═94f64888-b732-4367-a905-b57de684fcf7
# ╠═3d89c0be-a888-4e2f-8820-85e07bd6be30
# ╟─c1e8419c-c748-490b-93d3-9bbcde4f4da9
# ╠═c337e8cf-bab9-46cd-aae8-22f6265f9cb7
# ╠═ff2288f0-2edf-4f22-90ef-af5777676ae7
# ╟─d23fe57a-7255-4d8f-a00a-eaec953213b2
# ╠═a0f77be2-c40c-4372-a245-45b76ddc5861
# ╟─cdc25e03-c6fd-4ee0-801e-24654a83d65d
# ╠═4af883c2-fdc9-458c-998b-ff0b8b5df146
# ╠═c02969bc-3b5e-4422-a3c9-3a7d00cb3ddf
# ╠═e3a8ef81-0d19-4e75-b137-6454ce262991
# ╠═abcabcd5-4e64-4691-b602-2d4c0d146615
# ╟─ebd74bcb-4187-469f-a206-ecf9041918f1
# ╠═7579c331-fa53-47f4-a479-312f2f7a3931
# ╠═3cca079c-1245-493b-ae6c-9db18e11835c
# ╟─0ae38ccc-9129-4c61-9810-dbc448e8a07f
# ╟─4f5a9a27-1893-49e4-a2e9-59ba3a2340a2
# ╠═37ce2f96-377d-48d7-bc56-f83b0cce349c
# ╟─cd0829a1-cdf1-45c9-a4dd-91bb3ec5bb03
# ╠═328b5994-b1c4-4850-b8d3-2f3781bed99f
# ╠═78da1c47-1de7-4d95-a1e1-cd60e912a0fc
# ╠═3d182fa9-84bb-4504-8945-bf653ce1f99d
# ╟─b56a311e-912a-4e7c-b821-4124b847194a
# ╠═840ddb7e-56ba-4d7a-8f08-cee67128315f
# ╠═528194f2-9f74-4dda-94f8-3e4f0e515bc9
# ╠═a203fb4f-c3d6-4d46-9c58-2454b71b0e1b
# ╟─063ef53f-d152-4282-af5f-7f2addce3ab0
# ╠═95392d70-07cf-47a7-8707-f1dab177e7a5
# ╠═01de98fe-5537-4745-acf8-99daa0b8aa6f
# ╟─75549871-14a3-4b9f-9b98-cccc34ed315d
# ╠═867b3bf0-1208-48a1-b1ee-904d11b28e1f
# ╠═7c2d2d6d-f933-452e-9870-7dce7ad4bf1d
# ╟─cd363a92-a473-47f8-b41b-c5d5249fec90
# ╠═d3b3d839-4eee-41d1-ad85-897168e37fd7
# ╠═1ad4cf95-a3fb-4e45-b7bd-80ab724c158e
# ╠═cb41a2f9-a0c5-4eeb-af51-9bf40a5d7fd6
# ╟─f72450cb-a54e-4827-9c33-7a44f561bd43
# ╠═7e6eb33d-0721-4bb6-a9ee-1cfb07a17e46
# ╠═cf550002-13ce-4788-8206-790fb355a91b
# ╠═bfd35c9f-1449-4d86-bb50-9bbbd6ea2c30
# ╠═c1795dd9-f8a5-472d-bd82-7871e8603534
# ╟─c5436e99-513b-4c51-b3ad-f82318304a3e
# ╠═b393a0f5-af03-4ded-8e22-886022f5da30
# ╠═c81c5eaa-0e0f-4730-9148-ec0e7b63cdd4
# ╟─32f6d83a-d5db-4a21-b2c4-d8876de38c46
# ╠═f7d7cf86-ece9-406b-af78-f86177a767c4
# ╠═2110469f-16f9-4454-996a-a949a94fffa3
# ╠═3643e55e-3205-4561-b271-058d59f46685
# ╠═85c81f80-c959-4682-932b-26fe7f415f4d
# ╠═6bf0c8cc-db74-4cb7-bd91-579f5b35d25a
# ╟─09313c1d-102f-4e0b-b9c8-7d2e904a1dd6
# ╠═b2e7aae8-2777-4657-ba3d-f0dfcb581ede
# ╠═ae027113-998b-467e-8967-cc416d480377
# ╠═4ff0afae-af4c-45d0-83b2-4fb5eead2fa1
# ╠═2374bfc1-cd14-4bee-b5e5-bb15e0e6e253
# ╟─9360c9a0-6a0f-4ff6-a215-23ce5c3c8099
# ╠═a837b22c-61f1-4a98-a362-c08b405c4dca
# ╟─e2aec734-ce2b-4761-b3d0-b559df8b17da
# ╠═959b4745-7742-459a-bef0-e374ec4aec17
# ╟─b3d54170-466c-4b0d-a337-280ef4ea87f3
# ╠═eafe5f6e-18ab-4341-8435-a3c0b9423b35
# ╠═13304ea6-0639-4863-827e-d66a8630bc63
# ╠═c685ac28-79e8-4eda-8c0f-0944a1276691
# ╠═7a691c80-e08d-423a-a69a-572f02fdddda
# ╟─19a0e512-46d6-429e-93f0-05e2faf95218
# ╠═abe5aca2-61ce-4f99-ad75-0c84293cd7b3
# ╟─1171004b-96a1-4ee4-bbd5-2b7f2b1d582a
