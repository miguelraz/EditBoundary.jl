	get_dir() = pick_folder(pwd())

	get_path_img() = pick_file(pwd(); filterlist="png,jpeg,jpg")

	get_path_geo() = pick_file(pwd(); filterlist="geo")

	get_path_region() = pick_file(pwd(); filterlist="geo,xyz")

	"""
	dirpath, filestrings = get_dirfiles(name,ext)
	"""
	function get_dirfiles(name::String,ext::String)
		# delimiter
      	delim = Sys.iswindows() ? "\\" : "/"
      	# directory of the regions
      	dirpath  = pwd()*delim*"tests"*delim*name*delim
      	~isdir(dirpath) && mkdir(dirpath)
      	dirpath *= ext*delim
      	~isdir(dirpath) && mkdir(dirpath)
      	# read files of the directory
      	filestrings = readdir(dirpath)
		# filter only files
		filestrings = filestrings[isfile.(dirpath.*filestrings)]
		# filter only names of the regions
		filestrings = filter(contains(r"^"*name*"_"), filestrings)
		return dirpath, filestrings
	end
