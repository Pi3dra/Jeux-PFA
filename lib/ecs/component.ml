let init v =
  object
    val mutable r = v (*Reference*)
    method get = r
    method set w = r <- w
  end