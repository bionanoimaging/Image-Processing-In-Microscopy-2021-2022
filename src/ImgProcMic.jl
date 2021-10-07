module ImgProcMic

using ColorTypes

export complex_show, gray_show


"""
    complex_show(arr)

Displays a complex array. Color encodes phase, brightness encodes magnitude.
Works within Jupyter and Pluto.
"""
function complex_show(cpx::AbstractArray{<:Complex, N}) where N
	ac = abs.(cpx)
	HSV.(angle.(cpx)./2pi*256,ones(Float32,size(cpx)),ac./maximum(ac))
end

"""
    complex_show(arr; set_one=false, set_zero=false)
Displays a real gray color array. Brightness encodes magnitude.
Works within Jupyter and Pluto.

## Keyword args
* `set_one=false` divides by the maximum to set maximum to 1
* `set_zero=false` subtracts the minimum to set minimum to 1
"""
function gray_show(arr; set_one=true, set_zero=false)
    arr = set_zero ? arr .- minimum(arr) : arr
    arr = set_one ? arr ./ maximum(arr) : arr
    Gray.(arr)
end


end 
