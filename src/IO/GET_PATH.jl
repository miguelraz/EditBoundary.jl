	# these routines require GTK

	"""
	Gtk_save_dialog(title,filename)
	"""
	function Gtk_save_dialog(title::String,filename::String)
		
	    dlg = GtkFileChooserDialog( 
	    			title, 
					GtkNullContainer(), 
					Gtk.GConstants.GtkFileChooserAction.SAVE,
                    (("_Cancel", Gtk.GConstants.GtkResponseType.CANCEL),
                     ("_Save",   Gtk.GConstants.GtkResponseType.ACCEPT)) 
	            )
	    dlgp = GtkFileChooser(dlg)
	    ccall(  (:gtk_file_chooser_set_current_name, Gtk.libgtk), 
	            Nothing, 
	            (Ptr{GObject}, Ptr{UInt8}), 
	            dlgp, 
	            filename
	         )
	    ccall( (:gtk_file_chooser_set_do_overwrite_confirmation, Gtk.libgtk), 
	            Nothing, 
	            (Ptr{GObject}, Cint), 
	            dlg, 
	            true
	        )
	    response = run(dlg)
	    if response == Gtk.GConstants.GtkResponseType.ACCEPT
	        selection = Gtk.bytestring(Gtk.GAccessor.filename(dlgp))
	    else
	        selection = ""
	    end
	    Gtk.destroy(dlg)
	    return selection
	end

	get_path(title::T,ext::NTuple{N,T}) where {N,T<:String} =
	open_dialog(title,GtkNullContainer(),ext)

	get_dir() = open_dialog("Choose Folder", 
							 action = GtkFileChooserAction.SELECT_FOLDER 
							)

	function get_path_cut()::String
		title = "Choose cut file"
		ext   = ("*.txt",)
		return get_path(title,ext)
	end

	function get_path_img()::String
		title = "Choose image file"
		ext   = ("*.png","*.jpeg","*.jpg",)
		return get_path(title,ext)
	end

	function get_path_red()::String
		title = "Choose RED file"
		ext   = ("*.red",)
		return get_path(title,ext)
	end

	function get_path_msh()::String
		title = "Choose MSH file"
		ext   = ("*.msh",)
		return get_path(title,ext)
	end

	function get_path_mesh()::String
		title = "Choose MSH file"
		ext   = ("*.msh","*.red",)
		return get_path(title,ext)
	end

	function get_path_geo()::String
		title = "Choose GEO file"
		ext   = ("*.geo",)
		return get_path(title,ext)
	end

	function get_path_region()::String

		title = "Choose region file"
		name  = "GEO, XYZ formats"
		ext   = ( GtkFileFilter("*.geo, *.xyz", name=name), )
		return open_dialog(title,GtkNullContainer(),ext)
	end


	"""
	path = get_path_figures(name)
	"""
	function get_path_figures(name::String)::String
	    delim = Sys.iswindows() ? "\\" : "/"
	    path  = pwd()*delim*"tests"*delim*name
	    ~isdir(path) && mkdir(path)
	    path *= delim*"pdf"
	    ~isdir(path) && mkdir(path)
	    path *= delim
	    return path
	end

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