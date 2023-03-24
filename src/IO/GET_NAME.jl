
  """
  get_name(path)
  """
  function get_name(path::String)

    delimiter = Sys.iswindows() ? "\\" : "/"
    namext = split(path,delimiter)[end]
    name   = join(split(namext,".")[1:end-1].*".")[1:end-1]
    ext    = join(split(namext,".")[end])

    return name, ext
  end