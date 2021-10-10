### A Pluto.jl notebook ###
# v0.16.1

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

# ╔═╡ 56807afc-164e-11ec-2cf4-354654176242
begin
	using Pkg, Revise
	Pkg.activate("../../")
end

# ╔═╡ 8a11c2b7-b6e5-4c26-9e06-ad3ab958db9c
using TestImages, ImageShow, Colors, ImgProcMic, Statistics, PlutoTest, PlutoUI

# ╔═╡ 3ccbf4fb-0707-4ce8-83d8-b1af555f3fe1
using PoissonRandom

# ╔═╡ 62c6e2f0-0007-40ec-81c5-61cda80f59e5
using ImageFiltering, IndexFunArrays

# ╔═╡ 31cc54e9-d47b-4df7-a785-dad0120e8cdb
md"## Activate our environment"

# ╔═╡ d8c83f2c-76ea-42b9-bd39-7fa5cafcd4d3
md"# Homework 01"

# ╔═╡ 334ebdc5-dc11-4e83-ad12-a1961420a97b
begin
	img = Float64.(testimage("maduril_gray"))
	gray_show(img)
end

# ╔═╡ 2122c12f-0832-4f19-9a77-3047d5311cba
md"## 1. Add Noise To Images

This homework is dedicated to introduce into the basics of Julia.
As examples, we want to apply and remove noise from images
"

# ╔═╡ a7d7a415-7464-43fb-a2bf-8e3f2d999c32
md"## Task 1.1  - Gaussian Noise
In the first step, we want to add Gaussian noise with a certain 
standard deviation $\sigma$. Try to get yourself used to the Julia documentation
and check out whether such a function exists already and how you can apply it
to your image/array.

Codewords: **Julia, random, random normal distribution**
"

# ╔═╡ de104b0a-28a4-42de-ae8d-fa857a8f32e0
"""
	add_gauss_noise(img, σ=1)

This function adds normal distributed noise to `img`.
`σ` is an optional argument
"""
function add_gauss_noise(img, σ=one(img))
	return similar(img)
end

# ╔═╡ a4ffa72c-9896-48f8-aaac-f653e30d6244
1+1

# ╔═╡ f89bc1e4-d406-4550-988b-71496b64035a
md"
Now we want to use a for loop inside this function.
Try to find out how to write for loops to iterate through an array.
"

# ╔═╡ c0b5ff08-7342-4c25-9791-be3a4918c400
"""
	add_gauss_noise_fl!(img, σ=1)

This function adds normal distributed noise to `img`.
`σ` is an optional argument.
This function is memory efficient by using for loops.
`!` means that the input is modified.
Therefore, don't return a new array but instead modify the existing one!
The bang (!) is a convention in Julia that a function modifies the input.
"""
function add_gauss_noise_fl!(img, σ=1)
	# todo
	return img
end

# ╔═╡ d56bc500-f5cf-40f3-8c0b-b4ae26a58367
md"### Tests 1.1
Don't modify but rather take as input whether you are correct.
Green is excellent, red not :(
"

# ╔═╡ 1116455e-4698-489a-add2-4e1d8ecbb546
gray_show(add_gauss_noise(img, 0.15), set_one=true)

# ╔═╡ 8e343a3d-ab0f-45a1-9161-21fec07755c9
md"###### Type Stability of your functions.
That means that the output type is identical to the input type"

# ╔═╡ d865dddc-6d32-416b-ba12-8f6b3870e771
PlutoTest.@test Float32 == eltype(add_gauss_noise(ones(Float32, (512, 512)), 0.3f0))

# ╔═╡ 5c9a8c7b-e9c4-4177-86bb-b69113fce144
PlutoTest.@test Float32 == eltype(add_gauss_noise_fl!(ones(Float32, (512, 512)), 0.3))

# ╔═╡ cc7bbb55-b8dd-454b-b170-45137ab0c0b5
md"###### Check wether mean and standard deviation are correct"

# ╔═╡ c997c248-fba8-4ed8-ab75-179d248e6b83
PlutoTest.@test ≈(0.3, std(add_gauss_noise(ones((512, 512)), 0.3)), rtol=0.1)

# ╔═╡ 07bc00b7-81ad-4645-8fbe-8545ccdfe7e4
PlutoTest.@test ≈(0.3, std(add_gauss_noise_fl!(ones((512, 512)), 0.3)), rtol=0.1)

# ╔═╡ d317ed1a-1867-4293-8db4-51352212929c
PlutoTest.@test ≈(1, mean(add_gauss_noise(ones((512, 512)), 0.3)), rtol=0.1)

# ╔═╡ e69a8b77-833a-4498-8bc9-e4c970f6529d
md"## Task 1.2 - Poisson Noise
In microscopy and low light imaging situation, the dominant noise term is usually Poisson noise which we want to simulate here.

For adding Poisson noise we use: [PoissonRandom.jl](https://github.com/SciML/PoissonRandom.jl)

Read the documentation of this package how to generate Poisson Random numbers
"

# ╔═╡ 1e4b32cb-00ea-439f-900e-abadc850be95
"""
	add_poisson_noise!(img, scale_to=100)

This function adds poisson distributed noise to `img`.
Before adding noise, it scales the maximum value to `scale_to` and 
divides by it afterwards.
With that we can set the number of events (like a photon count)
`!` means that the input is modified.

"""
function add_poisson_noise!(img, scale_to=nothing)
	# todo
	return img
end

# ╔═╡ 6cf8ff2a-4255-4c53-9376-5a0d2d372569
add_poisson_noise!(10 .* ones(Float32, (3, 3)))

# ╔═╡ e3fcd381-9652-4e1d-8585-a91f87b73ce5
md"### Test 1.2 - Poisson Noise

You might encounter errors for Float32 types errors, try to put a `Float64(some_part)` at the right place.

Works like this:
* `typeof(1f0)` = $(typeof(1f0))
* `typeof(Float64(1f0))` = $(typeof(Float64(1f0)))

"

# ╔═╡ f3efcfcf-4516-43d2-9375-d8863b4b6f5b
gray_show(add_poisson_noise!(100 .* img), set_one=true)

# ╔═╡ 00c72e52-09fa-413b-acfd-83c760d42d7f
PlutoTest.@test Float32 == eltype(add_poisson_noise!(100 .* ones(Float32, (512, 512)), 0.3f0))

# ╔═╡ 5b68030f-557e-449e-8baf-cf7ae65e4425
mean(add_poisson_noise!(150 .* ones(Float64, (512, 512))))

# ╔═╡ 78a39a77-bc9d-427a-a113-4e64b0c9d311
PlutoTest.@test ≈(150, mean(add_poisson_noise!(150 .* ones(Float64, (512, 512)))), rtol=0.05)

# ╔═╡ 41118b3c-3e49-4fc7-8c80-7906b7cf91fe
PlutoTest.@test ≈(√(150), std(add_poisson_noise!(150 * ones(Float32, (512, 512)))), rtol=0.05)

# ╔═╡ f8be3a4b-d8f0-40cb-869e-81c17e58327a
md"###### Consider those tests as bonus"

# ╔═╡ 65a8981d-890b-4590-a913-6890ecf3817d
PlutoTest.@test ≈(150, 150 * mean(add_poisson_noise!(ones(Float32, (512, 512)), 150)), rtol=0.05)

# ╔═╡ 272c8afb-667f-49c7-af48-2feb1b9d06f7
PlutoTest.@test ≈(√(150), 150 * std(add_poisson_noise!(ones(Float32, (512, 512)), 150)), rtol=0.05)

# ╔═╡ 59482e49-d784-4303-9487-bf37f6a0462e
md"## 1.3 Hot Pixels

Another issues are hot pixels which show maximum value. This can be due to damaged pixels or cosmic rays. Sometimes this is called Pepper noise

" 

# ╔═╡ 6e050fc2-4db2-4e6e-abd4-2812b47c070f
"""
	add_hot_pixels(img, probability=0.1; max_value=one(eltype(img)))

Add randomly hot pixels. The probability for each pixel to be hot,
should be specified by `probability`.
"""
function add_hot_pixels!(img, probability=0.1; max_value=one(eltype(img)))
	# todo
	return img
end

# ╔═╡ 22985061-9740-45e9-af56-e0787dadba7b
gray_show(add_hot_pixels!(copy(img)))

# ╔═╡ 42f92a8c-54bb-4033-9ef2-f5ffb78f4f3a
md"### 1.3 Test"

# ╔═╡ a9ad9d52-53c9-44ce-8edc-af8d7bfdc81f
PlutoTest.@test sum(map(x -> x ≈ 2, add_hot_pixels!(copy(img), 0.5, max_value=2))) ≈ length(img) .* 0.5 rtol=0.05

# ╔═╡ 373a3e39-fd8c-4cea-88bb-2b9c3734f14f
md"## 2. Remove Noise From Images"

# ╔═╡ 2c274829-ef33-4f34-9ba0-63d3b8cd7343
md"## 2.1 Remove Noise with Gaussian Blur Kernel

One option to remove noise is, is to blur the image with a Gaussian kernel.
We can convolve a small gaussian (odd sized) Kernel over the array.
For that we are using `ImageFiltering.imfilter` for the convolution.

To create a Gaussian shaped function, checkout `IndexFunArrays.normal`. 
You probably want to normalize the sum of it again
"

# ╔═╡ 52ebebfc-940b-47e2-a059-40ec996f2f98
begin
	img_g = add_gauss_noise(img, 0.1)
	img_p = add_poisson_noise!(100 .* copy(img)) ./ 100
	img_h = add_hot_pixels!(copy(img))
end;

# ╔═╡ 2d6f25a5-b902-4e46-ac3f-cf452f525912
gray_show([img_g img_p img_h])

# ╔═╡ 75aa8212-8ba3-4fba-b8b2-af2dd9c82adf
# check out the help
imfilter

# ╔═╡ 6acf7ba6-445d-4ac0-a83f-6916318c783c
function gaussian_noise_remove(arr; kernel_size=(3,3), σ=1)
	# 
	return similar(arr)
end

# ╔═╡ 4f683117-9a09-4837-b0af-5818ac2e62fd
md"σ = $(@bind σ Slider(0.01:0.1:10, show_value=true))"

# ╔═╡ 01203c2c-4e67-492c-9d9c-dc84a84afe15
md"kernel size = $(@bind ks Slider(3:2:21, show_value=true))"

# ╔═╡ daae9a7d-99f4-4d34-a7fd-886fa754d59b
begin
	img_p_gauss = gaussian_noise_remove(img_p, kernel_size=(ks,ks), σ=σ);
	img_g_gauss = gaussian_noise_remove(img_g, kernel_size=(ks,ks), σ=σ);
	img_h_gauss = gaussian_noise_remove(img_h, kernel_size=(ks,ks), σ=σ);
end;

# ╔═╡ 92d43328-29a2-45b2-ae71-e169dec02316
gray_show([img_p_gauss img_g_gauss img_h_gauss])

# ╔═╡ 512486eb-1919-446a-9f24-e9713546d237
md"### 2.1 Test"

# ╔═╡ 9b83d92d-f838-4329-b0b1-62bf7a18f123
arr_rand = add_gauss_noise(ones((500, 500)), 0.2);

# ╔═╡ bbbed1b7-a406-44a7-8c77-959a3eba0197
PlutoTest.@test std(gaussian_noise_remove(arr_rand, kernel_size=(8,8), σ=2)) < 0.05

# ╔═╡ 911c2e1e-f04a-4efa-9aff-7f4a424011ae
PlutoTest.@test sum(abs2, img_g .- img) > sum(abs2, img_g_gauss .- img)

# ╔═╡ 0f6ff33f-e50a-4317-a240-3b2f52de7a97
md"## 2.2 Noise Removal with Median Filter
The median filter slides with an quadratic shaped box over the arrays and
always takes the median value of this array.

"

# ╔═╡ 7bc0f845-d5d4-4192-be1d-b97750e95761
function median_noise_remove!(arr; kernel_size=(5,5))
	# todo
		
	return arr
end

# ╔═╡ ac6e7ea7-c277-4180-a809-a37531ab4f11
md"kernel\_size\_2 = $(@bind ks_2 Slider(3:2:9, show_value=true))"

# ╔═╡ 8208b936-ad5d-45a0-96d1-04fd131f1e29
begin
	img_p_median = median_noise_remove!(copy(img_p), kernel_size=(ks_2,ks_2));
	img_g_median = median_noise_remove!(copy(img_g), kernel_size=(ks_2,ks_2));
	img_h_median = median_noise_remove!(copy(img_h), kernel_size=(ks_2,ks_2));
end;

# ╔═╡ 06af0b94-f4e1-4114-b565-730b87567995
gray_show([img_p_median img_g_median img_h_median])

# ╔═╡ 707a3be6-ac83-421d-a8e1-31d75444aeef
md"### 2.2 Test"

# ╔═╡ 07f5e6da-7868-4e22-90aa-7a81c2b41ab3
PlutoTest.@test sum(abs2, img_p .- img) > sum(abs2, img_p_median .- img)

# ╔═╡ 3dbe2b38-8609-41e5-b3b9-d62da394b89d
PlutoTest.@test sum(abs2, img_g .- img) > sum(abs2, img_g_median .- img)

# ╔═╡ 867d5676-8dfc-4bb5-b555-73aa767f7e9e
md"## 3 Final Images"

# ╔═╡ 3605fda7-078e-4bff-9e33-91c4025e775a
gray_show([img_g img_p img_h])

# ╔═╡ c09b3470-95bd-4f49-b64b-26459c95ab19
gray_show([median_noise_remove!(copy(img_g)) median_noise_remove!(copy(img_p)) median_noise_remove!(copy(img_h))])  

# ╔═╡ Cell order:
# ╟─31cc54e9-d47b-4df7-a785-dad0120e8cdb
# ╠═56807afc-164e-11ec-2cf4-354654176242
# ╠═8a11c2b7-b6e5-4c26-9e06-ad3ab958db9c
# ╠═d8c83f2c-76ea-42b9-bd39-7fa5cafcd4d3
# ╠═334ebdc5-dc11-4e83-ad12-a1961420a97b
# ╠═2122c12f-0832-4f19-9a77-3047d5311cba
# ╠═a7d7a415-7464-43fb-a2bf-8e3f2d999c32
# ╠═de104b0a-28a4-42de-ae8d-fa857a8f32e0
# ╠═a4ffa72c-9896-48f8-aaac-f653e30d6244
# ╠═f89bc1e4-d406-4550-988b-71496b64035a
# ╠═c0b5ff08-7342-4c25-9791-be3a4918c400
# ╠═d56bc500-f5cf-40f3-8c0b-b4ae26a58367
# ╠═1116455e-4698-489a-add2-4e1d8ecbb546
# ╠═8e343a3d-ab0f-45a1-9161-21fec07755c9
# ╠═d865dddc-6d32-416b-ba12-8f6b3870e771
# ╠═5c9a8c7b-e9c4-4177-86bb-b69113fce144
# ╠═cc7bbb55-b8dd-454b-b170-45137ab0c0b5
# ╠═c997c248-fba8-4ed8-ab75-179d248e6b83
# ╠═07bc00b7-81ad-4645-8fbe-8545ccdfe7e4
# ╠═d317ed1a-1867-4293-8db4-51352212929c
# ╠═e69a8b77-833a-4498-8bc9-e4c970f6529d
# ╠═3ccbf4fb-0707-4ce8-83d8-b1af555f3fe1
# ╠═1e4b32cb-00ea-439f-900e-abadc850be95
# ╠═6cf8ff2a-4255-4c53-9376-5a0d2d372569
# ╠═e3fcd381-9652-4e1d-8585-a91f87b73ce5
# ╠═f3efcfcf-4516-43d2-9375-d8863b4b6f5b
# ╠═00c72e52-09fa-413b-acfd-83c760d42d7f
# ╠═5b68030f-557e-449e-8baf-cf7ae65e4425
# ╠═78a39a77-bc9d-427a-a113-4e64b0c9d311
# ╠═41118b3c-3e49-4fc7-8c80-7906b7cf91fe
# ╠═f8be3a4b-d8f0-40cb-869e-81c17e58327a
# ╠═65a8981d-890b-4590-a913-6890ecf3817d
# ╠═272c8afb-667f-49c7-af48-2feb1b9d06f7
# ╠═59482e49-d784-4303-9487-bf37f6a0462e
# ╠═6e050fc2-4db2-4e6e-abd4-2812b47c070f
# ╠═22985061-9740-45e9-af56-e0787dadba7b
# ╠═42f92a8c-54bb-4033-9ef2-f5ffb78f4f3a
# ╠═a9ad9d52-53c9-44ce-8edc-af8d7bfdc81f
# ╠═373a3e39-fd8c-4cea-88bb-2b9c3734f14f
# ╠═2c274829-ef33-4f34-9ba0-63d3b8cd7343
# ╠═52ebebfc-940b-47e2-a059-40ec996f2f98
# ╠═2d6f25a5-b902-4e46-ac3f-cf452f525912
# ╠═62c6e2f0-0007-40ec-81c5-61cda80f59e5
# ╠═75aa8212-8ba3-4fba-b8b2-af2dd9c82adf
# ╠═6acf7ba6-445d-4ac0-a83f-6916318c783c
# ╠═4f683117-9a09-4837-b0af-5818ac2e62fd
# ╠═01203c2c-4e67-492c-9d9c-dc84a84afe15
# ╠═daae9a7d-99f4-4d34-a7fd-886fa754d59b
# ╠═92d43328-29a2-45b2-ae71-e169dec02316
# ╠═512486eb-1919-446a-9f24-e9713546d237
# ╠═9b83d92d-f838-4329-b0b1-62bf7a18f123
# ╠═bbbed1b7-a406-44a7-8c77-959a3eba0197
# ╠═911c2e1e-f04a-4efa-9aff-7f4a424011ae
# ╠═0f6ff33f-e50a-4317-a240-3b2f52de7a97
# ╠═7bc0f845-d5d4-4192-be1d-b97750e95761
# ╠═ac6e7ea7-c277-4180-a809-a37531ab4f11
# ╠═8208b936-ad5d-45a0-96d1-04fd131f1e29
# ╠═06af0b94-f4e1-4114-b565-730b87567995
# ╠═707a3be6-ac83-421d-a8e1-31d75444aeef
# ╠═07f5e6da-7868-4e22-90aa-7a81c2b41ab3
# ╠═3dbe2b38-8609-41e5-b3b9-d62da394b89d
# ╠═867d5676-8dfc-4bb5-b555-73aa767f7e9e
# ╠═3605fda7-078e-4bff-9e33-91c4025e775a
# ╠═c09b3470-95bd-4f49-b64b-26459c95ab19
