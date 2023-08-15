	function read_order(name::String)::Vector{Int64}

		delim = Sys.iswindows() ? "\\" : "/"
		dirpath  = pwd()*delim*"tests"*delim*name
		filepath = dirpath*delim*name*"_order.txt"
		if isfile(filepath)
			list = vec(readdlm(filepath, Int64))
		else
			list = Int64[]
			@info "NO merging order file was found"
		end
		return list
	end

	#=
	function save_order(list::Vector{Int64},name::String)

		nR = length(list)
		delim = Sys.iswindows() ? "\\" : "/"
		dirpath = pwd()*delim*"tests"*delim*name
		~isdir(dirpath) && mkdir(dirpath)
		filepath = dirpath*delim*name*"_order.txt"
		
      	open(filepath, "w") do f           
          for i = 1:nR
          	write(f, "$(list[i])\n")
          end
      	end
	end
	=#
