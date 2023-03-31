	get_dir() = pick_folder(pwd())
	get_path_img() = pick_file(pwd(); filterlist="png,jpeg,jpg")
	get_path_geo() = pick_file(pwd(); filterlist="geo")
	get_path_region() = pick_file(pwd(); filterlist="geo,xyz")