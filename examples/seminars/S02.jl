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

# ╔═╡ 0900dd0b-483a-404d-bf84-43c075230b73
begin
	using Pkg
	Pkg.activate("../../")
	using Revise
end

# ╔═╡ aca53457-93bb-4e6c-a3dc-68c000e8db78
Pkg.add("ImageIO")

# ╔═╡ 3d47cb3e-43b3-11ec-1b61-992ecbb3d16f
using Colors, ImageShow, TestImages, Noise, PlutoUI, Plots, FFTW

# ╔═╡ 5cdc016a-b0aa-42b4-841c-657c8bf72ca3
Pkg.add("FFTW")

# ╔═╡ e1f76c58-fa78-4a20-b30f-5ef087874899
md" ## Detectors

More bits $\rightarrow$ finer resolution of the intensity.

A lot of detectors have only 8 Bit (1 Byte)
* 8 Bit means: each pixel can measure $2^8$ different values

Some sensor have 12 Bit pixels
* 12 Bit means: each pixel can measure $2^{12}$ different values

Image sensors distributes those $N$ Bits in a certain interval equally spaced: $[0, I_\text{max}]$

## Examples
2 Bits per pixel (4 different values), the sensor can only measure: $[0, \frac13 I_\text{max}, \frac23 I_\text{max}, I_\text{max}]$ 

## Float64
Floating works differently. They store numbers not equally spaced, but more like exponentially spaced.
Of course, you can count how many possible values are in a certain interval $[0, 1.23]$, however that's not too easy to calculate.
"

# ╔═╡ c5e12406-97b2-450d-9fe7-b2da82452f33
2^8

# ╔═╡ 73f690da-3ee9-4a27-8e97-b062a615266e
2^12

# ╔═╡ 1f73e297-6a82-4d33-8862-5a166da4dc2f
# Float64 -> 64bits -> 2^64
img = Float64.(testimage("mandril_gray"));

# ╔═╡ fcbb40e5-87be-49f8-968b-e8bdd962ee53
# Image Sensor with only 2 Bits -> 4 values
Gray.(quantization(img, 2^2))

# ╔═╡ a564a1d9-0c5f-4391-bae4-04ffc9abc861
# Image Sensor with only 4 Bits -> 16 values
Gray.(quantization(img, 2^4))

# ╔═╡ c4087dcf-ea75-4b57-b4cc-73934f509af8
# Image Sensor with only 4 Bits -> 256 values
Gray.(quantization(img, 2^8))

# ╔═╡ 4c4199cf-a62f-4b82-ac04-0b1cb9b2543f


# ╔═╡ fc992ffe-1f4e-45e8-b2f2-7e4ec53d2188


# ╔═╡ 26eb3fff-ece9-40c9-bd9d-32cba04746a1
md"# Homework"

# ╔═╡ 09c7396d-57d4-4e26-a0bf-7b5730836135
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
	# only function definitions!
	red_map(x) = x^2 # red_map is a function 
	# you call by: red_map(0.123)
	green_map(x) = x^3 # TODO
	blue_map(x) = x^4 # TODO

	# that's a function call of red_map
	# red_map(value)
	
	return (3.0, 4f0, 2) # TODO, return the correct tuple! You should call
	# red_map, green_map, blue_map
end

# ╔═╡ 2c9d77c0-a5e0-4fe6-aa26-dcb3832904ff
red_map(x) = x

# ╔═╡ fe1b69e1-966d-49fe-bcc8-63781aa334ba
red_map(0.123)

# ╔═╡ 719c42e4-44f3-4519-a107-76b3d64717e7


# ╔═╡ 0d53abcb-281a-4e29-b695-ea1d11520d09
md"## Colors are only a datatype"

# ╔═╡ 38354d23-6a58-49bc-a19b-0a4b0186b8c1
@bind g Slider(0:0.01:1, show_value=true)

# ╔═╡ 6ba803f5-bb30-4d9b-a96f-fc23fd8fa8c8
@bind r Slider(0:0.01:1, show_value=true)

# ╔═╡ 76cdfdb7-9ca9-49d3-9ec9-0d26edbd458f
@bind b Slider(0:0.01:1, show_value=true)

# ╔═╡ 3896942f-36fe-4326-a4a0-1a502610e451
t = (r, g, b)

# ╔═╡ 63a0fc2c-3171-4dac-9eff-2f7bd2dce253
RGB(t[1], t[2], t[3])

# ╔═╡ 1b2e1d30-6805-40a2-9ce8-113e5664e434
typeof(RGB(t...))

# ╔═╡ 817bbf4d-7856-4269-84bb-b3344345f9fb


# ╔═╡ fb13e2f5-62a3-4b87-bc78-44f3e8dbef7f
md"## Documentation"

# ╔═╡ 3931594b-2353-4950-83e1-5ce163e69e64
"""
	f(x)


Returns `x+1`


## Examples

```julia-repl
julia> f(10)
11

```
"""
function f(x)
	return x + 1
end

# ╔═╡ a84872cf-b435-4806-b016-2a5fa71214e9
f

# ╔═╡ e9cdd216-17dd-4e74-9f94-f62b9fb1160f


# ╔═╡ 264ae342-b0f7-4a3d-b309-377fc89f1595
md"# Sampling

## Nyquist Theorem
You need to sample a function with twice the highest occuring frequency in the signal itself.


## Example
What is the highest frequency in the function s?

How do we calculate the frequency?

1 divided by the periodicity of the function

$$f_\text{max} = \frac{1}{T}$$


The frequency of our function s is 

$$f_\text{max} = \frac{1}{0.5s} = 2 Hz$$

The Nyquist frequency for s would be now $>4Hz$

(The real world consists of many, many frequencies)

"

# ╔═╡ a149d945-6ed5-40f9-b7c4-008181cd49ab
s(x) = sin(x * 2 * pi * 2)

# ╔═╡ 935556e9-a5f0-4676-b275-bb756d64979e
md"

"

# ╔═╡ b10b23fe-6aba-45b9-85e0-2fb44a6034c2
N = 1000

# ╔═╡ 648394b7-f059-443f-9308-12a26eac4f3b


# ╔═╡ 00eeb89c-9ba5-49b9-b1a5-be5a0f7c27eb
begin
	xs = range(0, 5, length=N)
	ys = s.(xs)
end

# ╔═╡ 483b5371-7e5d-42e9-abd1-64128d636090
# only a frequency Hz
bad_sampling_freq = range(0, 5, length=7)

# ╔═╡ 041b3e96-a866-41f5-a7d1-46294460c7ff
nyquist_sampling_freq = range(0, 5, length=22)

# ╔═╡ 64db368a-8fa0-4315-b27a-ad0628ff8e77
begin
	plot(xs, ys, xlabel="t in seconds")
	plot!(bad_sampling_freq, s.(bad_sampling_freq), mark="*")
	plot!(nyquist_sampling_freq, s.(nyquist_sampling_freq), mark="*")
end

# ╔═╡ cd6708f5-9a2a-4139-81b1-14381abbad73


# ╔═╡ 0d19eaca-d1f5-40e3-906e-caa82ad006b4
md"## Fourier Transform
Transforms a signal into Fourier space (Frequency space).

Fourier transform simply interprets the signal differently (or it displays it differently).
"

# ╔═╡ Cell order:
# ╠═0900dd0b-483a-404d-bf84-43c075230b73
# ╠═5cdc016a-b0aa-42b4-841c-657c8bf72ca3
# ╠═3d47cb3e-43b3-11ec-1b61-992ecbb3d16f
# ╠═aca53457-93bb-4e6c-a3dc-68c000e8db78
# ╠═e1f76c58-fa78-4a20-b30f-5ef087874899
# ╠═c5e12406-97b2-450d-9fe7-b2da82452f33
# ╠═73f690da-3ee9-4a27-8e97-b062a615266e
# ╠═1f73e297-6a82-4d33-8862-5a166da4dc2f
# ╠═fcbb40e5-87be-49f8-968b-e8bdd962ee53
# ╠═a564a1d9-0c5f-4391-bae4-04ffc9abc861
# ╠═c4087dcf-ea75-4b57-b4cc-73934f509af8
# ╠═4c4199cf-a62f-4b82-ac04-0b1cb9b2543f
# ╠═fc992ffe-1f4e-45e8-b2f2-7e4ec53d2188
# ╠═26eb3fff-ece9-40c9-bd9d-32cba04746a1
# ╠═09c7396d-57d4-4e26-a0bf-7b5730836135
# ╠═2c9d77c0-a5e0-4fe6-aa26-dcb3832904ff
# ╠═fe1b69e1-966d-49fe-bcc8-63781aa334ba
# ╠═719c42e4-44f3-4519-a107-76b3d64717e7
# ╠═0d53abcb-281a-4e29-b695-ea1d11520d09
# ╠═3896942f-36fe-4326-a4a0-1a502610e451
# ╠═38354d23-6a58-49bc-a19b-0a4b0186b8c1
# ╠═6ba803f5-bb30-4d9b-a96f-fc23fd8fa8c8
# ╠═76cdfdb7-9ca9-49d3-9ec9-0d26edbd458f
# ╠═63a0fc2c-3171-4dac-9eff-2f7bd2dce253
# ╠═1b2e1d30-6805-40a2-9ce8-113e5664e434
# ╠═817bbf4d-7856-4269-84bb-b3344345f9fb
# ╠═fb13e2f5-62a3-4b87-bc78-44f3e8dbef7f
# ╠═3931594b-2353-4950-83e1-5ce163e69e64
# ╠═a84872cf-b435-4806-b016-2a5fa71214e9
# ╠═e9cdd216-17dd-4e74-9f94-f62b9fb1160f
# ╠═264ae342-b0f7-4a3d-b309-377fc89f1595
# ╠═a149d945-6ed5-40f9-b7c4-008181cd49ab
# ╠═935556e9-a5f0-4676-b275-bb756d64979e
# ╠═b10b23fe-6aba-45b9-85e0-2fb44a6034c2
# ╠═648394b7-f059-443f-9308-12a26eac4f3b
# ╠═00eeb89c-9ba5-49b9-b1a5-be5a0f7c27eb
# ╠═483b5371-7e5d-42e9-abd1-64128d636090
# ╠═041b3e96-a866-41f5-a7d1-46294460c7ff
# ╠═64db368a-8fa0-4315-b27a-ad0628ff8e77
# ╠═cd6708f5-9a2a-4139-81b1-14381abbad73
# ╠═0d19eaca-d1f5-40e3-906e-caa82ad006b4
