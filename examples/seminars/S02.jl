### A Pluto.jl notebook ###
# v0.16.4

using Markdown
using InteractiveUtils

# ╔═╡ 50c6aa0a-38b8-11ec-36c5-7784eaef9e4c
begin
	using Pkg, Revise
	Pkg.activate("../../")
end

# ╔═╡ 69dd34c7-ac62-443c-8908-eba042438f07
function add_gauss_noise_fl!(img, σ)
	for i in eachindex(img)
		img[i] = img[i] + randn(eltype(img)) * eltype(img)(σ) 
		# img[i] = img[i] + randn() * σ # this also works
	end
	return img
end

# ╔═╡ bb684353-9d66-4ecd-b2bc-b24aeadcf972
randn() # returns normal distribution noise

# ╔═╡ 9f6dbe12-a0f1-47a1-9b81-0f0b417b43b3
typeof(randn())

# ╔═╡ a6be7e47-6837-487d-9490-3b4689c1a3fc
begin
	arr = ones(Float32, (10, 10))
	add_gauss_noise_fl!(arr, 123213)
end

# ╔═╡ d82c4907-8de1-47f9-9959-2f562b544770
eltype(arr)

# ╔═╡ 6104149f-c39c-45d1-a9fd-50c1c8b0d71e
arr

# ╔═╡ 8092c8a3-2b09-442a-b8c0-6fce4e8e0889


# ╔═╡ 2ab1d4fc-e191-4261-9bb3-d189db987b55


# ╔═╡ Cell order:
# ╠═50c6aa0a-38b8-11ec-36c5-7784eaef9e4c
# ╠═69dd34c7-ac62-443c-8908-eba042438f07
# ╠═d82c4907-8de1-47f9-9959-2f562b544770
# ╠═bb684353-9d66-4ecd-b2bc-b24aeadcf972
# ╠═9f6dbe12-a0f1-47a1-9b81-0f0b417b43b3
# ╠═a6be7e47-6837-487d-9490-3b4689c1a3fc
# ╠═6104149f-c39c-45d1-a9fd-50c1c8b0d71e
# ╠═8092c8a3-2b09-442a-b8c0-6fce4e8e0889
# ╠═2ab1d4fc-e191-4261-9bb3-d189db987b55
