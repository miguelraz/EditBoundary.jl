function readXYZ(A)

  sₙ = 2
  H = Dict{Int64,Matrix{Float64}}([])
  counter = 0

  while sₙ < size(A, 1)
    np = Int64(A[sₙ, 1])
    list = [sₙ .+ (1:np); sₙ + 1]
    H[counter] = Float64.(A[list, 1:2])
    sₙ += np + 1
    counter += 1
  end
  E = H[0]
  delete!(H, 0)

  return E, H
end

"""
  readGEO(A)

Get two-column array of countour points coordinates

from GEO file of GMSH
"""
function readGEO(A)

  id₁ = findfirst(x -> x == "//region", A)
  id₂ = findfirst(x -> x == "//idreg", A)
  id₄ = findfirst(x -> x == "//ncuts", A)
  idnp = findall(x -> x == "//npts", A)

  name_array = A[id₁[1], id₁[2]+1:end]
  name = string(strip(join(name_array .* " ")))
  idreg = A[id₂[1], id₂[2]+1]
  ~isa(idreg, Int) && (idreg = 0)

  ls = ('{', '}', ';')
  H = Dict{Int64,Matrix{Float64}}([])

  for k in eachindex(idnp)
    cₖ = idnp[k]
    nₖ = A[cₖ[1], cₖ[2]+1]
    Lₖ = cₖ[1] .+ (1:nₖ)
    H[k-1] = [parse.(Float64, string.(split(strip(A[iₖ, 3], ls), ",")[j])) for iₖ ∈ Lₖ, j = 1:2]
  end
  E = H[0]
  delete!(H, 0)

  return DataRegion(E, H, name)
end

function read_region(path::String="")
  if isempty(path)
    path = get_path_region()
  end

  name, ext = get_name(path)
  region_array = readdlm(path)

  if ext == "geo"
    R = readGEO(region_array)
  elseif ext == "xyz"
      E, H = readXYZ(region_array)
    R = DataRegion(E, H, name)
  else
    throw("sorry, file format is not 'geo' or 'xyz'. Can't read.")
  end

  return R
end

function save_poly(R::DataRegion)

  nH = length(R.H)
  np = 1 + nH

  delim = Sys.iswindows() ? "\\" : "/"
  dirpath = pwd() * delim * "tests" * delim * R.name
  ~isdir(dirpath) && mkdir(dirpath)
  dirpath *= delim * "poly"
  ~isdir(dirpath) && mkdir(dirpath)

  filepath = dirpath * delim * R.name
  #(R.idreg ≠ 0) && (filepath *= "_$(R.idreg)")
  filepath *= ".poly"

  open(filepath, "w") do f
    write(f, "$(np)\n")
    # exterior boundary
    nE = size(R.E, 1)
    write(f, "$(nE) out\n")
    for i = 1:nE
      x = R.E[i, 1]
      y = R.E[i, 2]
      write(f, "$x $y\n")
    end
    list = join(string.(1:nE) .* fill(" ", nE)) * "\n"
    write(f, list)
    # holes
    if ~isempty(R.H)
      for iH = 1:nH
        nᵢ = size(R.H[iH], 1)
        write(f, "$(nᵢ) in\n")
        for i = 1:nᵢ
          x = R.H[iH][i, 1]
          y = R.H[iH][i, 2]
          write(f, "$x $y\n")
        end
        list = join(string.(1:nᵢ) .* fill(" ", nᵢ)) * "\n"
        write(f, list)
      end
    end
  end

  return filepath
end

function saveXYZ(R::DataRegion)
  # delimiter
  delim = Sys.iswindows() ? "\\" : "/"
  # directory of regions
  dirpath = pwd() * delim * "tests" * delim * R.name
  ~isdir(dirpath) && mkdir(dirpath)
  dirpath *= delim * "xyz" * delim
  ~isdir(dirpath) && mkdir(dirpath)
  # save region
  saveXYZ(R, dirpath)
end

function saveXYZ(Ω::Union{Matrix{Float64},Matrix{Int64}},
  name::String,
  dirpath::String)

  filepath = dirpath * name * ".xyz"
  open(filepath, "w") do f
    nΩ = size(Ω, 1)
    write(f, "X Y Z\n$(nΩ)\n")
    for r in eachrow(Ω)
      x, y = r[1], r[2]
      write(f, "$x $y\n")
    end
  end
end

function saveXYZ(R::DataRegion, dirpath::String)

  # file name
  filename = R.name
  # file path
  filepath = dirpath * filename * ".xyz"
  # write contents
  open(filepath, "w") do f
    nE = size(R.E, 1)
    nH = length(R.H)
    write(f, "X Y Z\n$(nE)\n")
    for r in eachrow(R.E)
      x, y = r[1], r[2]
      write(f, "$x $y \"exterior\"\n")
    end
    if nH ≠ 0
      for iH = 1:nH
        nHᵢ = size(R.H[iH], 1)
        write(f, "$(nHᵢ)\n")
        for r in eachrow(R.H[iH])
          x, y = r[1], r[2]
          write(f, "$x $y \"hole\"\n")
        end
      end
    end
  end

end

"""
  save_region(R,dirpath)

Save polygonal region in GEO format of GMSH
"""
function save_region(R::DataRegion, dirpath::String)

  # unpack region data structure
  E = R.E
  H = R.H
  #idcuts = R.idcuts
  #idreg = R.idreg
  name = R.name
  # delimiter
  delim = Sys.iswindows() ? "\\" : "/"
  # path
  filepath = dirpath * name
  (idreg ≠ 0) && (filepath *= "_$idreg")
  filepath *= ".geo"
  # number of points in exterior boundary
  n = size(E, 1)
  # number of holes
  nh = length(H)

  if nh > 0
    # array of the number of points in each hole boundary
    hs = [size(H[k], 1) for k = 1:nh]
    # array of incremental sums of the number of points 
    # in each hole boundary
    Σs = n .+ [0; [sum(hs[1:k]) for k = 1:nh-1]]
  end

  open(filepath, "w") do f

    str = "//region " * name * "\n" *
          "//idreg $idreg\n" *
          "//nholes $nh\n" *
          "//extbnd\n" *
          "//npts $n\n"

    write(f, str)
    # loop for write vertices of exterior boundary
    for i = 1:n
      x, y = tuple(E[i, 1:2]...)
      write(f, "Point($i) = {$x,$y,0,1};\n")
    end
    # loop for write vertices of each hole boundary
    if nh > 0
      for k = 1:nh
        str = "//hole $k\n" *
              "//npts $(hs[k])\n"
        write(f, str)
        for i = 1:hs[k]
          x, y = tuple(H[k][i, 1:2]...)
          write(f, "Point($(Σs[k]+i)) = {$x,$y,0,1};\n")
        end
      end
    end
    # loop for write segments of exterior boundary
    write(f, "//lines\nLine(1) = {$n,1};\n")
    for i ∈ 2:n
      write(f, "Line($i) = {$(i-1),$i};\n")
    end
    # loop for write segments of each hole boundary
    if nh > 0
      for k = 1:nh
        write(f, "Line($(Σs[k]+1)) = {$(Σs[k]+hs[k]),$(Σs[k]+1)};\n")
        for i = 2:hs[k]
          write(f, "Line($(Σs[k]+i)) = {$(Σs[k]+i-1),$(Σs[k]+i)};\n")
        end
      end
    end

    str = "//polygons\n" *
          "Line Loop(1) = {1:$n};\n" *
          "Plane Surface(1) = {1};\n"
    write(f, str)

    if nh > 0
      for k = 1:nh
        write(f, "Line Loop($(k+1)) = {$(Σs[k]+1):$(Σs[k]+hs[k])};\n")
        write(f, "Plane Surface($(k+1)) = {$(k+1)};\n")
      end
    end

    #=
    if ~isempty(idcuts)
      nc = size(idcuts, 1)
      write(f, "//ncuts $nc\n")
      for i = 1:nc
        str = join(" " .* string.(idcuts[i, :]))
        write(f, "//" * str * "\n")
      end
    end
    =#
  end
end

function save_region(R::DataRegion)

  # delimiter
  delim = Sys.iswindows() ? "\\" : "/"
  # directory of regions
  dirpath = pwd() * delim * "tests" * delim * R.name
  ~isdir(dirpath) && mkdir(dirpath)
  dirpath *= delim * "geo" * delim
  ~isdir(dirpath) && mkdir(dirpath)
  # save region in the directory
  save_region(R, dirpath)
end

function save_region(Dreg::Dict{Int64,DataRegion},
  nold::Int64
)

  # name of the original region
  name = Dreg[1].name
  # delimiter
  delim = Sys.iswindows() ? "\\" : "/"
  # directory of regions
  dirpath = pwd() * delim * "tests" * delim * name
  ~isdir(dirpath) && mkdir(dirpath)
  dirpath *= delim * "geo"
  ~isdir(dirpath) && mkdir(dirpath)
  # path of the original region
  pathgeo = dirpath * delim * name
  # delete regions from previous decomposition
  foreach(rm, pathgeo .* ["_$k.geo" for k = 1:nold])
  # save regions from new decomposition
  foreach(save_region, values(Dreg))
end

function ask_save_region(R::DataRegion)

  # reset identifier and cuts 
  #R.idreg = 0
  #R.idcuts = Matrix{Int64}(undef, 0, 3)
  # open a window to save file
  filepath = save_file(pwd(); filterlist="xyz")
  # update name
  R.name = get_name(filepath)[1]
  # delimiter
  delim = Sys.iswindows() ? "\\" : "/"
  # directory
  dirpath = join(split(filepath, delim)[1:end-1] .* delim)
  # save region in XYZ format
  saveXYZ(R, dirpath)
  return dirpath * R.name
end

function save_new_region(R::DataRegion)
  # delimiter
  delim = Sys.iswindows() ? "\\" : "/"
  # directory of regions
  dirpath = pwd() * delim * "tests" * delim
  # save region in the directory
  save_region(R, dirpath)
  saveXYZ(R, dirpath)
end
