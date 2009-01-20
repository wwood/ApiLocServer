# Random additions to the ruby stdlibs.


class String
  # returns true iff the string converts nicely into an integer.
  # ie. it is an integer and nothing but integer
  def to_i?
    to_i.to_s == to_s
  end
end
