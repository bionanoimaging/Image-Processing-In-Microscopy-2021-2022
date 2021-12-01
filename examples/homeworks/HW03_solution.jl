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

# ╔═╡ a6261f66-40ca-11ec-3021-ed2173550635
begin
	using Pkg
	Pkg.activate("../../")
	using Revise
end

# ╔═╡ 77e6389e-3491-45b6-9f76-459b15a8922d
using TestImages, ImgProcMic, ImageShow, Random, PlutoTest, Plots, FourierTools, Statistics

# ╔═╡ ee4b6b2d-119e-4ac3-a1f5-500ff045bfc5
using FFTW, PlutoUI

# ╔═╡ c7150c2c-afeb-4158-b381-3341bb678fd5
using Noise

# ╔═╡ 7148e705-8b90-46ea-8763-778897daf9a7
md"# Homework 03

In this homework we cover several topics like image correction, Fourier transforms, Fourier Shifting and Sampling.
"

# ╔═╡ 83d9c252-2a8d-47a3-b247-a62b6a175201
md"## 1. Flat Fielding
As discussed in the lecture, raw images might be affected by dirty optics or sensor errors.
In this exercise we want to apply such a correction to simulated images.
"

# ╔═╡ 39c623c7-6063-4360-a2b7-95ea42c5262d
begin
	img = Float32.(testimage("mandril_gray.tif"))
	gray_show(img)
end

# ╔═╡ eacd8fdf-971c-46ca-914f-f73f65e28ca8
md"### Simulate Deteriorated Image
In the first step, we degrade our image with some artifacts.
We add an offset to our image which is caused by sensor artifacts.
Second, we add some dirty spots to the image which are for example caused by dust on the sensor.
"

# ╔═╡ 25dde5cb-9ed6-498e-b511-50ed0640d0c0
"""
	simulate_bad_microscope(img)

The ideal `img` is degraded by artifacts.
"""
function simulate_bad_microscope(img::AbstractArray{T}) where T
	# generate same random numbers!
	rng = MersenneTwister(2021);
	# some weird dark field slope offset
	dark = zero.(img)
	dark .+= range(0,0.3, length=size(img, 1))

	xs = 1:size(img, 1)

	ff = one.(img)
	for i = 1:20 # emulates some dust spots as modulations to the flatfield ff
		x, y = rand(rng, xs), rand(rng, xs)
		sca = abs(randn(rng) .* T(0.2))
		r = sqrt.((xs .- x).^2 .+ (xs' .- y).^2)
		ff .-= T(0.2) .* sinc.(r .* sca)
	end

	return abs.(dark .+ ff .* img)
end

# ╔═╡ a6c024a4-7cb2-4f8d-be24-8727d75679da
img_dirty = simulate_bad_microscope(img);

# ╔═╡ d5c127ee-1ecf-4ed0-9cd9-6fcdefa95847
gray_show(img_dirty)

# ╔═╡ 6e95cbcb-0d89-4eca-8599-b266076708a7
md"## 1.1 Task 
Extract both a flat field and a dark field image with `simulate_bad_microscope`.
Use the function `simulate_bad_microscope` to obtain a measured flat field and measured dark field.
"

# ╔═╡ 910cb7fa-b1fc-4106-acc4-3bf56edfb83d
flat_field = simulate_bad_microscope(ones(Float32, (512, 512))); # TODO

# ╔═╡ cbebb311-c521-4fa6-a909-1a4df8da4d2d
gray_show(flat_field)

# ╔═╡ 8bb737cb-2d59-49ba-9b89-afef6ca7bbf8
dark_field = simulate_bad_microscope(zeros(Float32, (512, 512))); # TODO

# ╔═╡ 52bc8b3d-542e-4a35-b38c-35840f4075d4
gray_show(dark_field)

# ╔═╡ e3448ffe-5fbf-4bed-bf03-6eb9031e6c12
"""
	correct_image(img_dirty, dark_field, flat_field)

Correct a dirty image `img_dirty` by providing the `dark_field` and `flat_field`.

Conceptually we divide by the `flat_field` since the measured `flat_field`
describes the deviations from an ideal white image.
The `dark_field` has to be subtracted before since that only contains sensor artifacts.
"""
function correct_image(img_dirty, dark_field, flat_field)
	# TODO
	return (img_dirty .- dark_field) ./ (flat_field .- dark_field)
end

# ╔═╡ d9308666-efaa-4fcc-a083-f3d12dbab1e2
img_fixed = correct_image(img_dirty, dark_field, flat_field); # todo

# ╔═╡ 493b6bb4-1dfc-4a82-9360-40944b29826c
gray_show(img_fixed)

# ╔═╡ c80a2ce8-6620-4de1-bb78-5af97caf466d
md"### 1.1 Test"

# ╔═╡ e2e470e4-ff73-4dd5-973c-14e1535b01ea
PlutoTest.@test img_fixed ≈ img

# ╔═╡ 0a957f4a-a975-4087-b458-3236940eda43
PlutoTest.@test img ≈ correct_image(img, zero.(img), one.(img))

# ╔═╡ af9866f4-2b03-4dc4-9f8a-e02ae46e2f9c
md"# 2 Sampling
If a signal is not properly sampled, we can see a lot of artifacts which are called aliasing.
Try to determine experimentally (via the slider) which is the correct value for Nyquist sampling.

Afterwards, calculate the correct sampling in the variable $N$!

Don't state the pure number but rather a short equation which Julia calculates.
Do you see a difference between your expected and your calculated value?
"

# ╔═╡ 7a481af3-4ec8-4a58-bb84-e9d3d5381570
md"N=$(@bind N Slider(2:300, show_value=true))"

# ╔═╡ 4006ccf7-df8e-440c-8b3c-af525bb50ed4
begin
	xs = range(0, 8, length=N+1)[begin:end-1]
	f(x) =  sin(x * 2π * 5)
end

# ╔═╡ c871cdbd-b560-46f2-918c-45d24d2f9b75
plot(xs, f.(xs))

# ╔═╡ f6b8cd92-c1ab-445b-8b4f-04f521b72cad
N_correct = 2 * 8 * 5 + 1 # todo

# ╔═╡ 51b2d7be-fe94-44e9-8e67-73aafb636ef1
begin
	xs_correct = range(0, 8, length=round(Int, N_correct + 1))[begin:end-1]
	plot(xs_correct, f.(xs_correct))
end

# ╔═╡ a19c8850-9a7d-4e26-908b-a067a9006e84
md"No tests, since they would reveal the answer." 

# ╔═╡ b0c67bd6-b5ef-4359-8727-1a3bfefcf759
md"# 3 FFTs

Another very important topics are FFTs!
The standard library in many languages is based on FFTW.
In Julia FFTW.jl is the recommended library. 

The discrete Fourier transform is given by

$$X_k = \sum_{n=0}^{N-1} x_n \exp\left(-i2 \pi \frac{kn}{N} \right)$$
and the inverse by

$$x_n = \frac1{N}\sum_{k=0}^{N-1} X_k \exp\left(i2 \pi \frac{kn}{N} \right)$$.

The FFT algorithm evaluates those equations very efficiently ($\mathcal O(N \cdot \log N)$) by avoiding the explicit sum ($\mathcal O(N^2)$).

Further, the FFT calculates the frequencies in an (maybe) unexpected format
* Data: $[x_1, x_2, ..., x_N]$
* FFT of Data: $[f_0, f_1, ..., f_{N/2}, f_{-N/2}, f_{-N/2+1}, ...,f_{-1}]$
* (for real data negative and positive frequencies are the complex conjugate)

Sometimes we want to have the frequencies centered, which means a `fftshift` operations is needed
* FFT of Data followed by fftshift: $[f_{-N/2}, f_{-N/2+1},..., f_{-1}, f_0, f_1,..., f_{N/2-1}, f_{N/2}]$
"

# ╔═╡ 7276f9e0-80b8-4794-9125-fca43246f818
"""
    my_fft(data::Vector{T})::Vector{Complex{T}}

Calculate the FFT of `data` according to the equation given above.
Note, the output should be a complex Vector!
"""
function my_fft(data::Vector{T})::Vector{Complex{T}} where T
	out = zeros(Complex{T}, size(data))

	N = size(out, 1)
	for k = 0:N-1
		z = zero(Complex{T})
		for n = 0:N - 1
			z += data[n+1] * exp(-2π * im * k * n / N)
		end
		out[k + 1] = z
	end
	return out::Vector{Complex{T}}
end

# ╔═╡ e895cff6-4018-495f-9a0e-1e56ddcfd17d
arr = [1f0,2,3,4]

# ╔═╡ 14d68904-4de5-4f1d-81f6-dae8bf50b749
my_fft(arr)

# ╔═╡ 7307dd33-cb79-48c0-9e73-78ed70e9c628
fft(arr)

# ╔═╡ 393d03e2-461d-480a-9719-f33a4eef3a6f
md"### 3.1 Test"

# ╔═╡ df12fd86-f29d-4926-b360-daf4cb40af86
begin
	arr_r = randn((13,))
	PlutoTest.@test fft(arr_r) ≈ my_fft(arr_r)
end

# ╔═╡ 37eedc2e-27bd-4d1c-a83b-6ec14aba55ab
begin
	arr_r2 = randn((14,))
	PlutoTest.@test fft(arr_r2) ≈ my_fft(arr_r2)
end

# ╔═╡ 5313dbed-bfd7-4bb8-b39c-89c55e50d1bb
md"## 3.2 Task
Calculate the FFT of the following dataset, such that center frequency is in the center!

Use `fft` and `fftshift`.
"

# ╔═╡ e1eac3cd-e6ce-4743-9119-5ee0c69b8e00
begin
	data_odd = [1.7142857142857142, 1.643544850921574, 1.0471849694228637, 1.383330948397344, 1.8300917955219322, 1.2951185346328968, 1.086443186817675]
	data_even = [-2.5, 1.5, -2.5, 3.5]
end

# ╔═╡ 481961ac-ad7c-4768-a7aa-eed34143226b
ffts(x) = fftshift(fft(x)) # TODO

# ╔═╡ fc3bb52b-f9a2-42c0-b34b-347d0a137e2d
ffts(data_even)

# ╔═╡ a55851b6-3f8d-4af3-8f09-a3777c56df1b
ffts(data_odd)

# ╔═╡ e46d67be-d974-4f07-8b3e-02fff3e749d0
md"## 3.3 Task

Now do the inverse operation such that `data ≈ iffts(ffts(x))`

Check out `ifftshift`.
"

# ╔═╡ deb9eaf0-ee89-49c5-90b8-570d1a88f8fc
iffts(x) = ifft(ifftshift(x)) # TODO

# ╔═╡ 2875999a-a61d-491a-8a42-0552a87d3c6a
md"""
### 3.2 and 3.3 Test
"""

# ╔═╡ 333a253e-ce8b-477a-9db2-f99c034ae048
PlutoTest.@test real(ffts(iffts(data_even))) ≈ data_even

# ╔═╡ e81990c8-2194-472c-a102-b0d010f3a266
 PlutoTest.@test real(ffts(iffts(data_odd))) ≈ data_odd

# ╔═╡ f3fc2ea5-033c-4789-8ce6-0c6b15b607b7
 PlutoTest.@test real(iffts(ffts(data_odd))) ≈ data_odd

# ╔═╡ 90596b8a-53d4-457f-9e93-522e6c5dc35d
 PlutoTest.@test real(iffts(ffts(data_even))) ≈ data_even

# ╔═╡ 60fd0d40-5b1d-4a68-afab-802c08b838ea


# ╔═╡ 4e54ddc6-b9cd-472f-b496-18055ee5b667
md"## 3.4 Task
Try to reproduce this $\cos$ curve. 
The reason it looks so _sharp_ is that we only sample slightly above the Nyquist limit.

However, you are only allowed to use `fft`, `fftshift`, `ifftshift`, `ifft` and array manipulation (like `x[34] = 1723.12`).
And you can also take the `real` part at the end.

Please explain with some #comments what you did. 
"

# ╔═╡ 9844ec03-b169-40a0-ad56-1c07b11bb886
begin
	x = range(0, 4, length=21)[begin:end-1]
	y = cos.(x .* 2π)
	plot(x, y, mark="-*")
end

# ╔═╡ 49c39cea-895e-429a-909c-d1438d0dfd00
function reproduce_cos()
	# TODO
	y_ft = fftshift(fft(zeros(size(x))))
	mid = size(y_ft, 1) ÷ 2 + 1
	y_ft[mid + 4] = 1
	y_ft[mid - 4] = 1
	return real(ifft(ifftshift(y_ft))) * 10
end

# ╔═╡ 5c4f40df-cde3-4140-ace2-6c0e1b60ebcf
begin
	plot(x, y, mark="-*")
	plot!(x, reproduce_cos(), mark="-*")
end

# ╔═╡ 79578e4d-7527-459b-8915-ee5cb9ccad24
md"### 3.4 Test"

# ╔═╡ a74c4034-fa19-4360-9f5e-191d5ba4001a
PlutoTest.@test real(reproduce_cos()) ≈ y

# ╔═╡ 8ce249a3-0881-49e5-8ffd-5df21bda50f4
md"## 3.5 Fourier Shift Theorem

The discrete Fourier transform is given by

$$X_k = \sum_{n=0}^{N-1} x_n \exp\left(-i2 \pi \frac{kn}{N} \right)$$
and the inverse by

$$x_n = \frac1{N}\sum_{k=0}^{N-1} X_k \exp\left(i2 \pi \frac{kn}{N} \right)$$.
"

# ╔═╡ 13131381-11b3-4db4-9351-fb7264c94ea4
md"## 3.4 Task
Proof the Fourier shift theorem (with LaTeX) which states

$x_{n+\Delta n} = \mathcal{F}^{-1}\left[ X_{k} \cdot f(k, \Delta n)\right]$

Derive how the function $f(k, \Delta n)$ looks like!

hint: by clicking on the eye symbol next to this task, you can see how to embed LaTeX code in markdown comments.
"

# ╔═╡ bc3ae07f-3877-480f-bd0b-633ce21172e3
md"### Derivation


# TODO
$$x_{n+\Delta n} = \frac1{N}\sum_{k=0}^{N-1} X_k \exp\left(i2 \pi \frac{k(n+\Delta n)}{N} \right)= $$

$$ =\frac1{N}\sum_{k=0}^{N-1} X_k \exp\left(i2 \pi \frac{k(\Delta n)}{N} \right) \cdot \exp\left(i2 \pi \frac{kn}{N} \right)$$


Hence 
$f(k, \Delta n) = \exp\left(i2 \pi \frac{k\Delta n}{N} \right)$
"

# ╔═╡ 8bf6ba5b-1d06-41de-b22a-b58c1eaf2c83
"""
	shift(x::AbstractArray{T, N}, Δn::Number) 

Shifts a (real) array via the Fourier shift theorem by the amount of
`Δn`.

If `Δn ∈ ℕ` then `circshift(x, -Δn) ≈ shift(x, Δn).`
Otherwise a sub-pixel shift is obtained which is equivalent
to a sinc interpolation.

## Examples
```julia
julia> shift([1.0, 2.0, 3.0, 4.0], 1)
4-element Vector{Float64}:
 2.0
 3.0
 4.0
 1.0

julia> shift([1.0, 2.0, 3.0, 4.0], -1)
4-element Vector{Float64}:
 4.0
 1.0
 2.0
 3.0

julia> shift([1.0, 2.0, 3.0, 4.0], -0.5)
4-element Vector{Float64}:
 2.5
 1.085786437626905
 2.5
 3.914213562373095
```
"""
function shift(x::AbstractArray{T, N}, Δn::Number) where {T, N}
	# TODO
	x_ft = fft(x)

	f = fftfreq(size(x, 1))
	phase = exp.(1im * T(2π) .* f .* Δn)

	return real(ifft(x_ft .* phase))
end

# ╔═╡ a21d8b13-20db-4df1-a2c7-451f8942466b
begin
	x2 = 0:0.1:3
	y2 = sin.(x2.*3) .+ cos.(x2 .* 4).^2
end;

# ╔═╡ 420d1b15-8dc9-4c9a-b91f-9cc4b8101b92
md"
 $\Delta n$=$(@bind Δn Slider(0:0.01:100, show_value=true))"

# ╔═╡ 54ebf4c4-6692-4a40-a83e-c548440b3b85
begin
	plot(shift(y2, Δn), label="FFT based shift", mark="-*")
	plot!(circshift(y2, round(Int, .-Δn)), label="rounded to integer with circshift", mark="-*")
end

# ╔═╡ bbe52a98-9811-4c3a-9b4e-b90a1f5c163f
md"### 3.5 Test"

# ╔═╡ 73fd7360-ffdf-4870-a301-e39a982e0517
arr4 = randn((37,));

# ╔═╡ 37a815a0-c6cd-4ee8-9f46-ee4aa5259690
PlutoTest.@test circshift(arr4, -12) ≈ shift(arr4, 12)

# ╔═╡ 3c09615a-e9c4-462b-9f23-5d5676aa29b7
PlutoTest.@test FourierTools.shift(arr4, -13.1) ≈ shift(arr4, 13.1)

# ╔═╡ d3f2648a-a736-4812-b721-70298151a1a7
md"# 4 Noise Beyond Bandlimit

As seen in the lecture, noise can move information even beyond
the bandlimit of the optical system.
In this task, we want to demonstrate this behaviour with a simulation.
For that we need a few helper functions, try to fill the missing lines.


## 4.1 rr2 Function 
In the first step, we create a rr2 function.
"

# ╔═╡ 9ef7592b-92f9-48bb-aa3e-9710bf251379
begin
	"""
		rr2(T, s, center=s .÷ 2 + 1)
	
	Returns a 2D array which stores the squared distance to the center.

	## Examples
	```julia
	julia> rr2(Float32, (5,5))
	5×5 Matrix{Float32}:
	 8.0  5.0  4.0  5.0  8.0
	 5.0  2.0  1.0  2.0  5.0
	 4.0  1.0  0.0  1.0  4.0
	 5.0  2.0  1.0  2.0  5.0
	 8.0  5.0  4.0  5.0  8.0
	
	julia> rr2((4,4))
	4×4 Matrix{Float64}:
	 8.0  5.0  4.0  5.0
	 5.0  2.0  1.0  2.0
	 4.0  1.0  0.0  1.0
	 5.0  2.0  1.0  2.0
	
	julia> rr2((3,3), (3,3))
	3×3 Matrix{Float64}:
	 8.0  5.0  4.0
	 5.0  2.0  1.0
	 4.0  1.0  0.0
	```
	"""
	function rr2(T::DataType, s, center=s .÷ 2 .+ 1)
		# TODO
		x = T.((1:s[1]) .- center[1])
		y = T.(((1:s[2]) .- center[2])')
	
		return x.^2 .+ y.^2
	end
	
	function rr2(s, center=s .÷ 2 .+ 1)
		rr2(Float64, s, center)
	end
end

# ╔═╡ b62519f5-26dd-49ca-afa4-2c72de7ef8a6
rr2((4,4))

# ╔═╡ bd45654d-15e0-4717-962b-d5a302de4a9b
PlutoTest.@test rr2(Float32, (4, 3), (2.5, 3)) == Float32[6.25 3.25 2.25; 4.25 1.25 0.25; 4.25 1.25 0.25; 6.25 3.25 2.25]

# ╔═╡ c6ed3889-0d44-4180-9f81-3095055c6e54
PlutoTest.@test rr2((3, 3), (3, 3)) == [8.0 5.0 4.0; 5.0 2.0 1.0; 4.0 1.0 0.0]

# ╔═╡ 5a16e94e-b01b-4897-9631-41d345229be2
md"## 4.2 circ Function
Having a function which creates the radial distance, we now create a function which returns an array which is 1 inside an circle of radius `r` and 0 outside of it.
"

# ╔═╡ 06a666f9-c99e-41e5-b703-a5e826721d04
begin
	"""
		circ(size, radius)
	
	`size` the size of the resulting array
	and `radius` the radius of the circle
	"""
	# TODO
	circ(size, radius) = rr2(size) .<= radius^2
end

# ╔═╡ 592e0ed4-bd97-4bb6-a826-b1e2f5ddbd59
circ((5,5), 2)

# ╔═╡ 205a744b-e8a1-4acc-ba6b-7a7307f9a028
md"## 4.2 Test"

# ╔═╡ daf4e474-0db4-4865-859d-96c31e7947f0
PlutoTest.@test circ((10, 2), 2.76) ≈ Bool[0 0; 0 0; 0 0; 1 1; 1 1; 1 1; 1 1; 1 1; 0 0; 0 0]

# ╔═╡ 7fb8fedf-5684-4874-8f17-d01debaff477
PlutoTest.@test circ((4, 5), 2.1) ≈ Bool[0 0 1 0 0; 0 1 1 1 0; 1 1 1 1 1; 0 1 1 1 0]

# ╔═╡ 9b9fb85b-13d0-43a2-ac5f-713593117b96
md" ## 4.3 Frequency Filter
Now we combine all methods together such that we frequency filter
our image.

Procedure:
* Transform image to Fourier space
* take only the inner part of a circle a `radius` of the Fourier space 
* go to real space and take real part
"

# ╔═╡ 2a48072b-fc5a-4044-9aa9-5661483ffbfc
function frequency_filter(img, radius)
	# TODO
	img_ft = fftshift(fft(img))
	img_ft .*= circ(size(img_ft), radius)
	return real(ifft(ifftshift(img_ft)))
end

# ╔═╡ 643bf329-cce9-4c61-931d-65455b59357d
md"r=$(@bind r Slider(1:512, show_value=true))"

# ╔═╡ 2cafea2d-b4b6-4ede-b899-720a71034fda
gray_show(frequency_filter(img, r))

# ╔═╡ 7467608a-ce6d-4f29-8cd8-d766395f7129
md"## 4.4 Noise Breaks Resolution Limit?
We demonstrate now, that noise beyond the frequency limit still contains information

### Procedure
* First frequency filter our image such that it definetely bandlimited
* Apply Poissonian and Gaussian noise
* Now do the exact opposite of the above low-pass filter and take only the high frequency content!
"

# ╔═╡ 6d7fd369-1f6c-487d-b399-c8cbbfede916
function simulate(img, noise_function, radius)
	# TODO
	img_f = frequency_filter(img, radius)
	img_fn = noise_function(img_f)

	img_fn_fft = fftshift(fft(img_fn))
	img_fn_fft .*= (1 .- circ(size(img), radius))
	return real(ifft(ifftshift(img_fn_fft)))
end

# ╔═╡ e8bd9cb9-bd20-4619-93da-20e7829a61b4
# anonymous noise function we are going to pass to `simulate`
begin
	p(x) = poisson(x, 100000)
	g(x) = add_gauss(x, 0.1)
end

# ╔═╡ 8a479712-7290-4c00-af7c-44e11ec81d0d
md"r=$(@bind r2 Slider(1:300, show_value=true))"

# ╔═╡ 372e190b-0344-4001-9c72-171610b41e9c
img_noisy = abs.(simulate(img, p, r2));

# ╔═╡ b17cd903-bce6-4291-9d71-ea8a8422295a
gray_show(img_noisy, set_one=true)

# ╔═╡ fc91074a-99fc-4a13-802c-740872bf7502
md"
Mean is $(round(mean(img_noisy), sigdigits=3))

Maximum is $(round(maximum(img_noisy), sigdigits=3))

Minimum is $(round(minimum(img_noisy), sigdigits=3))
"

# ╔═╡ fac6c740-93c1-4e12-9610-f3c621f84043
md"## 5.1 Undersampling
Demonstration of aliasing.

Write a function `undersample` which only takes every `n-th` point of an array, keeping the first pixel of the array.
"

# ╔═╡ 15aa846c-7b81-4094-8b5b-dd6575e82afe
img3 = Float32.(testimage("resolution_test_512"));

# ╔═╡ be3b0811-c05a-4e78-9d34-8c52195dd7d0
"""
	undersample(x, factor)

```julia-repl
julia> undersample([1,2,3,4,5,6,7,8,9,10], 2)
5-element Vector{Int64}:
 1
 3
 5
 7
 9

julia> undersample([1,2,3,4,5,6,7,8,9,10], 3)
4-element Vector{Int64}:
  1
  4
  7
 10

julia> undersample([1,2,3,4,5,6,7,8,9,10], 4)
3-element Vector{Int64}:
 1
 5
 9
```
"""
function undersample(x, factor)
	return x[1:factor:end]
end

# ╔═╡ e5188537-b955-4637-bab5-a76b6d74c189
PlutoTest.@test undersample([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 2) == [1, 3, 5, 7, 9]


# ╔═╡ c2b3cdc7-60b5-4287-8268-f95184d452b7
PlutoTest.@test undersample([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 3) == [1, 4, 7, 10]

# ╔═╡ 4e3a272e-0280-4e27-b014-3f9da5ac8039
PlutoTest.@test undersample([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 4) == [1, 5, 9]

# ╔═╡ a76e4081-7c52-4548-b513-ba03954378db


# ╔═╡ f5fbd0da-fe4c-4162-be5e-f9d9d5b27d87
md"## 5.1 Undersampling Visualization

In this plot you can see a nicely oversampled $\sin$ curve.
"

# ╔═╡ a07cb23e-6fca-4c42-a6b6-a525b2b5e232
xs2 = range(0, 10π, length=500)

# ╔═╡ c373046e-04b3-4159-80c0-8fbec141833f
f2(x) = sin(5 * x)

# ╔═╡ 9c1ed9aa-9d52-425d-892d-af3b8a981663
ys2 = f2.(xs2);

# ╔═╡ 75006409-0338-470d-a41d-fa1aba5c4fca
plot(xs2, ys2, xlabel="x pos", ylabel="amplitude")

# ╔═╡ f2b3d8a0-4bea-4443-9bc3-37258106c3d3
md"
Now we only take each `undersample_factor` data point of the series.

`undersample_factor` = $(@bind undersample_factor Slider(1:40, show_value=true))


Analyze what happens once you're below the Nyquist frequency.
See further what happens if you undersample then even more.
"

# ╔═╡ f6b06d6e-b268-45d6-a7e4-d8614cd0884d
y2_undersampled = undersample(ys2, undersample_factor);

# ╔═╡ eab1fe28-f336-4b33-89a3-4c65ed2a818f
plot(fftfreq(length(y2_undersampled))[1:length(y2_undersampled)÷2],abs.(rfft(y2_undersampled))[1:end-1], xlabel="Positive Frequencies", ylabel="Absolute Value of Frequency amplitude", mark="-*")

# ╔═╡ Cell order:
# ╠═a6261f66-40ca-11ec-3021-ed2173550635
# ╠═77e6389e-3491-45b6-9f76-459b15a8922d
# ╟─7148e705-8b90-46ea-8763-778897daf9a7
# ╟─83d9c252-2a8d-47a3-b247-a62b6a175201
# ╠═39c623c7-6063-4360-a2b7-95ea42c5262d
# ╟─eacd8fdf-971c-46ca-914f-f73f65e28ca8
# ╠═25dde5cb-9ed6-498e-b511-50ed0640d0c0
# ╠═a6c024a4-7cb2-4f8d-be24-8727d75679da
# ╠═d5c127ee-1ecf-4ed0-9cd9-6fcdefa95847
# ╟─6e95cbcb-0d89-4eca-8599-b266076708a7
# ╠═910cb7fa-b1fc-4106-acc4-3bf56edfb83d
# ╠═cbebb311-c521-4fa6-a909-1a4df8da4d2d
# ╠═8bb737cb-2d59-49ba-9b89-afef6ca7bbf8
# ╠═52bc8b3d-542e-4a35-b38c-35840f4075d4
# ╠═e3448ffe-5fbf-4bed-bf03-6eb9031e6c12
# ╠═d9308666-efaa-4fcc-a083-f3d12dbab1e2
# ╠═493b6bb4-1dfc-4a82-9360-40944b29826c
# ╟─c80a2ce8-6620-4de1-bb78-5af97caf466d
# ╠═e2e470e4-ff73-4dd5-973c-14e1535b01ea
# ╠═0a957f4a-a975-4087-b458-3236940eda43
# ╟─af9866f4-2b03-4dc4-9f8a-e02ae46e2f9c
# ╠═ee4b6b2d-119e-4ac3-a1f5-500ff045bfc5
# ╠═7a481af3-4ec8-4a58-bb84-e9d3d5381570
# ╠═4006ccf7-df8e-440c-8b3c-af525bb50ed4
# ╠═c871cdbd-b560-46f2-918c-45d24d2f9b75
# ╠═f6b8cd92-c1ab-445b-8b4f-04f521b72cad
# ╠═51b2d7be-fe94-44e9-8e67-73aafb636ef1
# ╟─a19c8850-9a7d-4e26-908b-a067a9006e84
# ╟─b0c67bd6-b5ef-4359-8727-1a3bfefcf759
# ╠═7276f9e0-80b8-4794-9125-fca43246f818
# ╠═e895cff6-4018-495f-9a0e-1e56ddcfd17d
# ╠═14d68904-4de5-4f1d-81f6-dae8bf50b749
# ╠═7307dd33-cb79-48c0-9e73-78ed70e9c628
# ╟─393d03e2-461d-480a-9719-f33a4eef3a6f
# ╠═df12fd86-f29d-4926-b360-daf4cb40af86
# ╠═37eedc2e-27bd-4d1c-a83b-6ec14aba55ab
# ╟─5313dbed-bfd7-4bb8-b39c-89c55e50d1bb
# ╠═e1eac3cd-e6ce-4743-9119-5ee0c69b8e00
# ╠═481961ac-ad7c-4768-a7aa-eed34143226b
# ╠═fc3bb52b-f9a2-42c0-b34b-347d0a137e2d
# ╠═a55851b6-3f8d-4af3-8f09-a3777c56df1b
# ╟─e46d67be-d974-4f07-8b3e-02fff3e749d0
# ╠═deb9eaf0-ee89-49c5-90b8-570d1a88f8fc
# ╟─2875999a-a61d-491a-8a42-0552a87d3c6a
# ╠═333a253e-ce8b-477a-9db2-f99c034ae048
# ╠═e81990c8-2194-472c-a102-b0d010f3a266
# ╠═f3fc2ea5-033c-4789-8ce6-0c6b15b607b7
# ╠═90596b8a-53d4-457f-9e93-522e6c5dc35d
# ╠═60fd0d40-5b1d-4a68-afab-802c08b838ea
# ╟─4e54ddc6-b9cd-472f-b496-18055ee5b667
# ╠═9844ec03-b169-40a0-ad56-1c07b11bb886
# ╠═49c39cea-895e-429a-909c-d1438d0dfd00
# ╠═5c4f40df-cde3-4140-ace2-6c0e1b60ebcf
# ╟─79578e4d-7527-459b-8915-ee5cb9ccad24
# ╠═a74c4034-fa19-4360-9f5e-191d5ba4001a
# ╟─8ce249a3-0881-49e5-8ffd-5df21bda50f4
# ╟─13131381-11b3-4db4-9351-fb7264c94ea4
# ╠═bc3ae07f-3877-480f-bd0b-633ce21172e3
# ╠═8bf6ba5b-1d06-41de-b22a-b58c1eaf2c83
# ╠═a21d8b13-20db-4df1-a2c7-451f8942466b
# ╠═420d1b15-8dc9-4c9a-b91f-9cc4b8101b92
# ╠═54ebf4c4-6692-4a40-a83e-c548440b3b85
# ╟─bbe52a98-9811-4c3a-9b4e-b90a1f5c163f
# ╠═73fd7360-ffdf-4870-a301-e39a982e0517
# ╠═37a815a0-c6cd-4ee8-9f46-ee4aa5259690
# ╠═3c09615a-e9c4-462b-9f23-5d5676aa29b7
# ╟─d3f2648a-a736-4812-b721-70298151a1a7
# ╠═9ef7592b-92f9-48bb-aa3e-9710bf251379
# ╠═b62519f5-26dd-49ca-afa4-2c72de7ef8a6
# ╠═bd45654d-15e0-4717-962b-d5a302de4a9b
# ╠═c6ed3889-0d44-4180-9f81-3095055c6e54
# ╟─5a16e94e-b01b-4897-9631-41d345229be2
# ╠═06a666f9-c99e-41e5-b703-a5e826721d04
# ╠═592e0ed4-bd97-4bb6-a826-b1e2f5ddbd59
# ╟─205a744b-e8a1-4acc-ba6b-7a7307f9a028
# ╠═daf4e474-0db4-4865-859d-96c31e7947f0
# ╠═7fb8fedf-5684-4874-8f17-d01debaff477
# ╟─9b9fb85b-13d0-43a2-ac5f-713593117b96
# ╠═2a48072b-fc5a-4044-9aa9-5661483ffbfc
# ╠═2cafea2d-b4b6-4ede-b899-720a71034fda
# ╠═643bf329-cce9-4c61-931d-65455b59357d
# ╟─7467608a-ce6d-4f29-8cd8-d766395f7129
# ╠═c7150c2c-afeb-4158-b381-3341bb678fd5
# ╠═6d7fd369-1f6c-487d-b399-c8cbbfede916
# ╠═e8bd9cb9-bd20-4619-93da-20e7829a61b4
# ╠═8a479712-7290-4c00-af7c-44e11ec81d0d
# ╠═372e190b-0344-4001-9c72-171610b41e9c
# ╠═b17cd903-bce6-4291-9d71-ea8a8422295a
# ╟─fc91074a-99fc-4a13-802c-740872bf7502
# ╟─fac6c740-93c1-4e12-9610-f3c621f84043
# ╠═15aa846c-7b81-4094-8b5b-dd6575e82afe
# ╠═be3b0811-c05a-4e78-9d34-8c52195dd7d0
# ╠═e5188537-b955-4637-bab5-a76b6d74c189
# ╠═c2b3cdc7-60b5-4287-8268-f95184d452b7
# ╠═4e3a272e-0280-4e27-b014-3f9da5ac8039
# ╠═a76e4081-7c52-4548-b513-ba03954378db
# ╠═f5fbd0da-fe4c-4162-be5e-f9d9d5b27d87
# ╠═a07cb23e-6fca-4c42-a6b6-a525b2b5e232
# ╠═c373046e-04b3-4159-80c0-8fbec141833f
# ╠═9c1ed9aa-9d52-425d-892d-af3b8a981663
# ╠═75006409-0338-470d-a41d-fa1aba5c4fca
# ╠═f2b3d8a0-4bea-4443-9bc3-37258106c3d3
# ╠═f6b06d6e-b268-45d6-a7e4-d8614cd0884d
# ╠═eab1fe28-f336-4b33-89a3-4c65ed2a818f
