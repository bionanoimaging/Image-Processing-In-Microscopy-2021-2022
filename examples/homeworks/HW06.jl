### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 250252f0-6e61-11ec-2ffe-ebddaa9f0fb3
begin
	using Pkg 
	Pkg.activate("../../")
	using Revise
end

# ╔═╡ 0eeb5bb1-bb41-43cc-8c14-eb9c1ebf6fad
using ImgProcMic, FourierTools, IndexFunArrays, ImageShow, FFTW, TestImages, Colors

# ╔═╡ 1b2ebe1a-f3a7-494c-bcca-18df5403ee65
using PlutoTest, Noise

# ╔═╡ 4b46e310-cc26-4a96-8c2e-0c89307d4e34
md"# Structured Illumination Microscopy

In this homework we are going to work through the full pipeline from capturing a dataset of a SIM to reconstructing the data.

For the demonstration we focus on the 2D case and consider the resolution enhancement only along one direction. That allows us to observe the effect clearly.
"

# ╔═╡ 7054db2c-606e-48eb-ab93-8c0260cb7a81
md"## 1 Simulate PSF"

# ╔═╡ edaacc75-fd91-4d46-a31f-21e738253708
"""
	simulate_PSF(s, r, [T=Float32])

Simulate the incoherent 2D PSF with radius `r` and total output size `s`.
This functions returns the PSF centered around the first entry (top left corner).
Furthermore, it returns the `freq_limit` of the PSF.
The `freq_limit` is the frequency at which the OTF becomes 0.

The procedure is as following:
* create a disc with values of 1 and radius `r` (use `rr2`)
* take the `ift` of it.
* abs2.
* normalize the sum to 1
* center pixcel should be located in the top left
"""
function simulate_PSF(s, r, T=Float32)
	# TODO calculate real PSF
	psf = zeros(T, s)
	psf[12] = 1

	
	# don't change freq_limit, is already correct
	freq_limit = r / (s[1] / 2)
	return psf, freq_limit
end

# ╔═╡ cd5bef41-6246-4d88-91d9-c83b7a47e110
# leave this value equal to 40!
radius = 40

# ╔═╡ 29e6311e-eb5b-4073-81dd-7372ac06498e
psf, freq_limit = simulate_PSF((512,512), radius);

# ╔═╡ c4c8b57b-e09a-43f8-b371-bb1f0761215d
gray_show(psf)

# ╔═╡ 599aabf7-6333-4272-ae07-fec07bdb02aa
img = Float32.(testimage("resolution_test_512"));

# ╔═╡ 920c26f4-5750-4c83-871d-9622b3dca134
gray_show(img);

# ╔═╡ a550fc7f-ff7c-4fd5-9e40-d8ed00da200f
md"### 1 Test"

# ╔═╡ 7cba5a99-21a7-45d6-a92a-7eb1e75e39d3
PlutoTest.@test simulate_PSF((5, 5), 2)[1] ≈ (Float32[0.36 0.10472136 0.01527864 0.01527864 0.10472136; 0.10472136 0.030462677 0.0044444446 0.0044444446 0.030462677; 0.01527864 0.0044444446 0.00064843567 0.00064843567 0.0044444446; 0.01527864 0.0044444446 0.00064843567 0.00064843567 0.0044444446; 0.10472136 0.030462677 0.0044444446 0.0044444446 0.030462677], 0.8)[1]

# ╔═╡ eafd2e8a-6bbd-4fe4-a5fd-d721b78604e1
PlutoTest.@test simulate_PSF((5, 5), 2)[2] == 0.8

# ╔═╡ 75f2ea94-ba30-48d3-b676-8423f14c453c
delta = zeros((5,5));

# ╔═╡ 9b856e9c-b818-4e49-a27d-0c0db623698e
delta[1] = 1;

# ╔═╡ 11009f9c-de4c-4ade-ad30-375ed47c3901
PlutoTest.@test simulate_PSF((5, 5), 3)[1] ≈ delta

# ╔═╡ 4ff25625-e450-47e4-97ae-bb24b903ed98
md"## 2 Structured Illumination

The key idea behind SIM is to illuminate the sample with an illumination pattern of the form

$I_n = 1 + \cos(k_g \cdot x + \theta_n)$

where $k_g$ is the frequency of the illumination pattern (twice the grating constant). $\theta$ is a illumination pattern shift which is different for each image. Such an illumination allows to increase the resolution along the first dimension.

We capture three images ($n=\{1,2,3\}$) of the sample which can be expressed as

$Y_n = (I_n \cdot S) * h$
where $h$ is the PSF, $S$ the ideal sample and $Y$ the measurement.

In our example we choose the following 3 different illuminations

$I_{1} = 1 + \cos\left(k_g \cdot x \cdot 2 \pi + 1\cdot \frac{2 \pi}{3} \right)$

$I_2 = 1 + \cos\left(k_g \cdot x  \cdot 2 \pi+ 2 \cdot \frac{2 \pi}{3}\right)$

$I_3 = 1 + \cos\left(k_g \cdot x  \cdot 2 \pi+ 3 \cdot \frac{2 \pi}{3}\right)$


"

# ╔═╡ ca8618e8-8389-4d30-8112-af0e987de417
"""
	illuminate(arr, kg)

Returns a vector of `arr` illuminated three times according to the SIM principle.
Implement the equations from above. Only illumination, no convolution with PSF.

You should return a vector of the three illumination arrays.
`[I_1, I_2, I_3]`.
"""
function illuminate(arr, kg)
	# x coordinates
	x = 1:size(arr, 1)

	# todo fix illumination
	I₁ = x * x'
	I₂ = x * x'
	I₃ = x * x'

	# todo return correct results
	[zeros(size(arr)), zeros(size(arr)), zeros(size(arr))]
end

# ╔═╡ 20aaf9b2-2660-413f-90a8-1f4fdc91d8c7
# toy example
illuminate(ones((4,4)), 0.5)

# ╔═╡ 4898da63-4da0-4538-b08d-cd4fe419584b
Illus = illuminate(ones((512, 512)), freq_limit * 0.8);

# ╔═╡ 8457cfeb-705f-41e8-a203-298c8ee4a7ab
# display the three illuminations
gray_show(hcat(Illus...))

# ╔═╡ 28784e50-285f-47a8-a311-4122ec8f47ce
# check whether illumination still pass through the system.
# if you see the same stripes but with lower contrast, then everything
# is perfect
gray_show(conv(Illus[1], psf))

# ╔═╡ 6e2814c9-5644-47b6-8a6e-3308e1623d5e
md"### 2 Test"

# ╔═╡ ca0e55ca-ec4f-4cd8-a1f7-a2a63ba9782d
PlutoTest.@test illuminate(ones((4, 4)), 0.5) ≈ [[1.4999999999999993 1.4999999999999993 1.4999999999999993 1.4999999999999993; 0.5000000000000008 0.5000000000000008 0.5000000000000008 0.5000000000000008; 1.4999999999999991 1.4999999999999991 1.4999999999999991 1.4999999999999991; 0.500000000000001 0.500000000000001 0.500000000000001 0.500000000000001], [1.5000000000000004 1.5000000000000004 1.5000000000000004 1.5000000000000004; 0.49999999999999867 0.49999999999999867 0.49999999999999867 0.49999999999999867; 1.5000000000000013 1.5000000000000013 1.5000000000000013 1.5000000000000013; 0.49999999999999845 0.49999999999999845 0.49999999999999845 0.49999999999999845], [0.0 0.0 0.0 0.0; 2.0 2.0 2.0 2.0; 0.0 0.0 0.0 0.0; 2.0 2.0 2.0 2.0]]

# ╔═╡ fa957648-0b4a-48eb-96d5-bb731966693c
Ittt = illuminate(ones((10, 10)), 1/3);

# ╔═╡ 287d85ae-efba-4095-b7ce-58d90bd22492
PlutoTest.@test Ittt[1] .+ Ittt[2] .+ Ittt[3] ≈ 3 .* ones((10, 10))

# ╔═╡ fce697cc-67d1-4373-b2b0-a6a60b8a5893
PlutoTest.@test all(illuminate([1 1; 0 0], 0) .≈ [[0.49999999999999956 0.49999999999999956; 0.0 0.0], [0.5000000000000002 0.5000000000000002; 0.0 0.0],  [2.0 2.0; 0.0 0.0],])

# ╔═╡ b961b3e0-6935-4f29-9f94-be6e21f302e3
PlutoTest.@test  illuminate([1 1; 0 0], 0.2) ≈ [[0.02185239926619431 0.02185239926619431; 0.0 0.0], [1.6691306063588578 1.6691306063588578; 0.0 0.0], [1.3090169943749477 1.3090169943749477; 0.0 0.0]]


# ╔═╡ 6e904b1d-2071-4d48-ad21-ab180e333474
md"## 3 Forward Imaging Process
Now we complete the forward modelling part from the image to the three measurements.

The grating constant should be small enough such that illumination 
passes through the system.
Since the optical system has a bandlimit, not abritrary small illumination patterns pass through the system.
The larger you choose it, the more of the reconstruction is affected by noise.
By  selecting `0.8 * freq_limit` we are definitely below the frequency threshold (e.g. 1.1 would be above)
"

# ╔═╡ e3994f91-a7bc-4811-b6e6-1f67692ff554
# don't change!
kg = 0.8 * freq_limit

# ╔═╡ 71af2b63-475c-429f-a15e-9a212f724a69
# the amount the three OTFs are displaced with respect to each other in Fourier space
# we need the value later for the reconstruction
# this value should stay at 64!
fourier_space_shift = radius * 2 * 0.8

# ╔═╡ 2a78c81d-f8f9-4d99-9c24-1aefb9941294
"""
	forward(img, psf, kg)

From the input `img` create three output images.
The output images are produced by multiplying the three different illumination
to the input image and convolving the three resulting `img`s with the `psf`.
Apply `poisson` to each of the image with a photon number of 1000 (use `N_phot`).
Use the function `poisson` for that.

## Procedure
* Multiplication with illumination
* convolution (use `FourierTools.conv`) with `psf`.
* Add noise with `poisson(img_without_noise, N_phot)`
* Return vectors of the three measuremens,e g. `[meas_1, meas_2, meas_3]`

"""
function forward(img, psf, kg, N_phot=1000)
	# todo illuminate img and convolve with PSF

	# return correct result
	return [zeros(size(img)), zeros(size(img)), zeros(size(img))]
end

# ╔═╡ d68d9f24-bcea-4bcc-b597-3c051e77d99c
Is = forward(img, psf, kg);

# ╔═╡ 23c98291-4c72-4a60-b722-910eadaf7e77
md"Three images which look all slightly different because"

# ╔═╡ 9a75e192-9605-4787-acee-706ee7c90549
gray_show(hcat(Is...))

# ╔═╡ 524b208d-7fc3-4d96-bdc1-2bed72f2a9ee
md"In comparison without any structured illumination"

# ╔═╡ 2c1a5b9e-8b1c-4619-b303-69d29181a5c4
[gray_show(conv(img, psf)) gray_show(Is[1])]

# ╔═╡ 09593275-85bf-42ee-860e-ebbb74866a40
md"## 3 Test"

# ╔═╡ 1103b35d-cb86-4970-beb7-c8463e374f78
# test random example
PlutoTest.@test all(.≈(forward([1 2; 3 4], [0.55 0.15; 0.15 0.15], 0.1, 100_000_000),  [[0.09645833671795113 0.13103484317669054; 0.08808351198799098 0.09683198111576993], [2.6912285614539946 3.133633214436668; 4.25256575017253 4.919802755223418], [2.9120113512125654 3.6367083598655254; 3.7589874298841632 4.283291164312841]], rtol=0.01))

# ╔═╡ ba74ec4a-b38f-4fcb-9b43-2448976153eb
PlutoTest.@test radius == 40

# ╔═╡ ab56310f-671d-4b54-b9c2-9be102c826e3
PlutoTest.@test kg == 1/8

# ╔═╡ db20d906-b22f-4f16-b355-eba9c82809d7
PlutoTest.@test fourier_space_shift == 64

# ╔═╡ b7f11d85-6859-4b5a-814e-003946fbd894
md"# 4 Unmixing
The three measurements are not the different parts of the Fourier spectrum yet.
But they contain the information to high frequencies!
Therefore, we want to unmix the three parts of the Fourier space.
"

# ╔═╡ 96b8f1e6-9159-4616-be08-c88f17e9829e
"""
	extract_components(Is)

Extract the different Fourier components from the 3 measurements (the vector `Is`).
This is achieved by inverting the mixing matrix (`inv(M)`) and multiplying (use a `*` for matrix multiplication, not a pointwise `.*`) it from the left to
`[fft(Is[1]), fft(Is[2]), fft(Is[3])]`.

See the lecture slides for more information.
"""
function extract_components(Is)
	# TODO add correct angles
	
	# TODO create correct matrix
	M = randn((3,3))

	# TODO return correct result
	return [Is[i] for i in 1:3]
end

# ╔═╡ 53af3f77-cbc2-4809-8dda-743e096df10c
Cₙ = extract_components(Is);

# ╔═╡ 4c136f35-e489-4d6e-83e0-e153bfc7040d
md"Here you can see the three different components still. They are not shifted to the correct position, yet.
"

# ╔═╡ bf97497a-e149-4552-9bdd-9fbeb5c24987
gray_show(log1p.(abs.(hcat(fftshift.(Cₙ)...))))

# ╔═╡ c922f283-3b31-43bd-9855-933be8a9e095
md"### 4 Test"

# ╔═╡ 460a8ea2-d077-48fc-804e-7367ac16eff8
# check if three output array
PlutoTest.@test size(extract_components([randn((2,2)) for i = 1:3])) == (3,)

# ╔═╡ ba0e90f8-a310-40f9-a306-fb8700ea473f
# check if structure and type is ok
PlutoTest.@test typeof(extract_components([randn((2,2)) for i = 1:3])) == Vector{Matrix{ComplexF64}}

# ╔═╡ 5d263158-03b0-4c87-ad90-a81c24493b66
# check a random example for correctness
PlutoTest.@test extract_components([[1 2; 3 4], [1 3; 4 5], [1 10; 20 30]]) ≈ Matrix{ComplexF64}[[16.50000000000001 - 0.8660254037844412im -5.500000000000003 + 0.2886751345948141im; -11.500000000000005 + 0.28867513459481564im 0.5000000000000002 + 0.28867513459481253im], [28.00000000000001 + 1.5597088666161704e-15im -8.000000000000002 - 3.563506943082403e-16im; -16.000000000000007 - 6.01679086153965e-16im 1.1102230246251565e-16 - 1.1102230246251565e-16im], [16.5 + 0.8660254037844446im -5.5 - 0.2886751345948149im; -11.5 - 0.28867513459481736im 0.5 - 0.2886751345948127im]]

# ╔═╡ 515d2174-56e3-4ebc-a475-b84f911a5a2f
md"# 5 Reconstruction
Having the three parts of the Fourier space separated, we can try to combine them in a reasonable way to one Fourier spectrum.
Simply adding them would not be optimal with respect to Signal-to-Noise-Ratio (SNR).
"

# ╔═╡ a97d7c94-e69b-44cd-ae4c-61d8d86808a5
"""
	reconstruct(psf, Cₙ, fourier_space_shift)

`psf` is the PSF of the single image (without SIM part).
`Cₙ` is an vector containing the three components of the Fourier spectrum.
`fourier_space_shift` is the shift the three pictures are shifted with respect to the center.

## Procedure
* First shift the spectrum (`otf = fft(psf)`) by `fourier_space_shift` along the first dimension (`circshift`)
* apply the same shift for the weighting factors
* Combine the Fourier spectra using _weighted averaging_ (see slides)
* also return the effective OTF
"""
function reconstruct(psf, Cₙ, fourier_space_shift)
	# Int shift
	Δ = round(Int, fourier_space_shift)

	# TODO fix the weights
	w₋₁ = similar(psf)
	w₀ = similar(psf)
	w₁ = similar(psf)

	# TODO fix the mixing 
	C₋₁ = similar(psf)
	C₀ = similar(psf)
	C₁ = similar(psf)
	
	# the small 1f-8 factor is added to prevent division by zero
	res_fourier_space = (w₋₁ .* C₋₁ .+ w₀ .* C₀ .+ w₁ .* C₁ .+ 1f-8^2) ./ 
		  (w₋₁ .+ w₀ .+ w₁ .+ 1f-8)

	# todo calculate similarly to res the eff_otf but adapt it according to the slides
	eff_otf = similar(psf)

	# todo adapt res_fourier_space to be a real space image
	res = similar(psf)

	# don't change return args
	return res, eff_otf
end

# ╔═╡ 9e64def4-b397-4292-8fe9-8a828e08ee0a
res, eff_otf = reconstruct(psf, Cₙ, fourier_space_shift);

# ╔═╡ 54fa3a01-5a8d-4dd3-a521-a60a2f69b541
md"Unfiltered reconstruction"

# ╔═╡ d9c33b8c-6ccf-462f-b5c2-267fd7b93ba3
gray_show(res)

# ╔═╡ 2f14fb93-91bc-44af-8a6d-cebaa1607a51
md"Unfiltered Fourier spectrum"

# ╔═╡ fd53c66d-ba90-4d96-9a11-eabc1dd666dc
gray_show(log1p.(abs.(ft(res))))

# ╔═╡ 19546bad-d7be-4c09-a248-f7e98c53d42d
"""
	wiener_filter(img, otf, ϵ)

Copy the wiener filter from previous homeworks and adapt it (OTF instead of the PSF is passed).

"""
function wiener_filter(img, otf, ϵ)
	# todo
	# fix wiener filter but use otf instead of PSF (look old homework solutions)
	return img
end

# ╔═╡ 33c156b6-5c18-4377-9920-32c7865898e9
md"### Final Inspection"

# ╔═╡ 0cdf07a5-a87e-449e-ab09-871924cee6d1
md"
If everything is correct, we should definitely see an resolution improvement in the left image (the SIM reconstruction).
The resolution increase is mainly along the first dimension.
"

# ╔═╡ 0a729667-599a-41f1-98f3-ff94608c15bb
[ gray_show(wiener_filter(res, eff_otf, 1e-3)) gray_show(wiener_filter(poisson(conv(img, psf), 300), fft(psf), 1e-3)) gray_show(img)]

# ╔═╡ 0d78c765-1912-4ded-a5e8-aa98afe73cb4
gray_show(log1p.(abs.(ft(wiener_filter(res, eff_otf, 1e-1)))));

# ╔═╡ 5566b0c6-ac96-4342-a62b-0c292469c2eb
[gray_show(wiener_filter(res, eff_otf, 1e-3)) gray_show(wiener_filter(poisson(conv(img, psf), 300), fft(psf), 1e-3))]

# ╔═╡ 3bed0c72-ab5c-4dbf-85a5-6f6d062dec97
md"The left image shows the effective OTF for the SIM system.
On the right we can see the OTF of the same microscope without structured illumination"

# ╔═╡ d32536af-b369-4b39-87f6-4e1172d971ae
[gray_show(fftshift(log1p.(abs.(eff_otf))))  gray_show(log1p.(abs.(ffts(psf))))]

# ╔═╡ 35cdd4f9-87f7-408e-a3fd-7456b7238dd5
md"## 5 Test"

# ╔═╡ 1320b506-d378-4fa1-bbf1-c2f994abfff1
PlutoTest.@test wiener_filter([1, 2, 3, 4, 5], [1, -2, 3, 4, 0], 0.001) ≈ [2.9553001744303087, 3.5816540338359086, 2.9970029970029977, 2.4123519601700862, 3.0387058195756858]

# ╔═╡ Cell order:
# ╠═250252f0-6e61-11ec-2ffe-ebddaa9f0fb3
# ╠═0eeb5bb1-bb41-43cc-8c14-eb9c1ebf6fad
# ╠═1b2ebe1a-f3a7-494c-bcca-18df5403ee65
# ╟─4b46e310-cc26-4a96-8c2e-0c89307d4e34
# ╟─7054db2c-606e-48eb-ab93-8c0260cb7a81
# ╠═edaacc75-fd91-4d46-a31f-21e738253708
# ╠═cd5bef41-6246-4d88-91d9-c83b7a47e110
# ╠═29e6311e-eb5b-4073-81dd-7372ac06498e
# ╠═c4c8b57b-e09a-43f8-b371-bb1f0761215d
# ╠═599aabf7-6333-4272-ae07-fec07bdb02aa
# ╠═920c26f4-5750-4c83-871d-9622b3dca134
# ╟─a550fc7f-ff7c-4fd5-9e40-d8ed00da200f
# ╠═7cba5a99-21a7-45d6-a92a-7eb1e75e39d3
# ╠═eafd2e8a-6bbd-4fe4-a5fd-d721b78604e1
# ╠═75f2ea94-ba30-48d3-b676-8423f14c453c
# ╠═9b856e9c-b818-4e49-a27d-0c0db623698e
# ╠═11009f9c-de4c-4ade-ad30-375ed47c3901
# ╟─4ff25625-e450-47e4-97ae-bb24b903ed98
# ╠═ca8618e8-8389-4d30-8112-af0e987de417
# ╠═20aaf9b2-2660-413f-90a8-1f4fdc91d8c7
# ╠═4898da63-4da0-4538-b08d-cd4fe419584b
# ╠═8457cfeb-705f-41e8-a203-298c8ee4a7ab
# ╠═28784e50-285f-47a8-a311-4122ec8f47ce
# ╟─6e2814c9-5644-47b6-8a6e-3308e1623d5e
# ╠═ca0e55ca-ec4f-4cd8-a1f7-a2a63ba9782d
# ╠═fa957648-0b4a-48eb-96d5-bb731966693c
# ╠═287d85ae-efba-4095-b7ce-58d90bd22492
# ╠═fce697cc-67d1-4373-b2b0-a6a60b8a5893
# ╠═b961b3e0-6935-4f29-9f94-be6e21f302e3
# ╟─6e904b1d-2071-4d48-ad21-ab180e333474
# ╠═e3994f91-a7bc-4811-b6e6-1f67692ff554
# ╠═71af2b63-475c-429f-a15e-9a212f724a69
# ╠═2a78c81d-f8f9-4d99-9c24-1aefb9941294
# ╠═d68d9f24-bcea-4bcc-b597-3c051e77d99c
# ╟─23c98291-4c72-4a60-b722-910eadaf7e77
# ╠═9a75e192-9605-4787-acee-706ee7c90549
# ╟─524b208d-7fc3-4d96-bdc1-2bed72f2a9ee
# ╠═2c1a5b9e-8b1c-4619-b303-69d29181a5c4
# ╟─09593275-85bf-42ee-860e-ebbb74866a40
# ╠═1103b35d-cb86-4970-beb7-c8463e374f78
# ╠═ba74ec4a-b38f-4fcb-9b43-2448976153eb
# ╠═ab56310f-671d-4b54-b9c2-9be102c826e3
# ╠═db20d906-b22f-4f16-b355-eba9c82809d7
# ╟─b7f11d85-6859-4b5a-814e-003946fbd894
# ╠═96b8f1e6-9159-4616-be08-c88f17e9829e
# ╠═53af3f77-cbc2-4809-8dda-743e096df10c
# ╟─4c136f35-e489-4d6e-83e0-e153bfc7040d
# ╠═bf97497a-e149-4552-9bdd-9fbeb5c24987
# ╟─c922f283-3b31-43bd-9855-933be8a9e095
# ╠═460a8ea2-d077-48fc-804e-7367ac16eff8
# ╠═ba0e90f8-a310-40f9-a306-fb8700ea473f
# ╠═5d263158-03b0-4c87-ad90-a81c24493b66
# ╟─515d2174-56e3-4ebc-a475-b84f911a5a2f
# ╠═a97d7c94-e69b-44cd-ae4c-61d8d86808a5
# ╠═9e64def4-b397-4292-8fe9-8a828e08ee0a
# ╟─54fa3a01-5a8d-4dd3-a521-a60a2f69b541
# ╠═d9c33b8c-6ccf-462f-b5c2-267fd7b93ba3
# ╟─2f14fb93-91bc-44af-8a6d-cebaa1607a51
# ╠═fd53c66d-ba90-4d96-9a11-eabc1dd666dc
# ╠═19546bad-d7be-4c09-a248-f7e98c53d42d
# ╟─33c156b6-5c18-4377-9920-32c7865898e9
# ╟─0cdf07a5-a87e-449e-ab09-871924cee6d1
# ╠═0a729667-599a-41f1-98f3-ff94608c15bb
# ╠═0d78c765-1912-4ded-a5e8-aa98afe73cb4
# ╠═5566b0c6-ac96-4342-a62b-0c292469c2eb
# ╟─3bed0c72-ab5c-4dbf-85a5-6f6d062dec97
# ╠═d32536af-b369-4b39-87f6-4e1172d971ae
# ╟─35cdd4f9-87f7-408e-a3fd-7456b7238dd5
# ╠═1320b506-d378-4fa1-bbf1-c2f994abfff1
