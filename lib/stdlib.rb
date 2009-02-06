# Random additions to the ruby stdlibs.


class String
  # returns true iff the string converts nicely into an integer.
  # ie. it is an integer and nothing but integer
  def to_i?
    to_i.to_s == to_s
  end
  
  def to_f?
    # downcase is required because of exponentials that come capitalized
    to_f.to_s == to_s.downcase or to_i?
  end
end
