# A class to represent a distance matrix like BLOSUM62

class DistanceMatrix
  def load_matrix(io)
    column_names = []
    @matrix_hash = {}
    io.each do |line|
      if line.match(/   /)
        column_names = line.strip.split
      elsif line.match(/\#/)
        next #ignore comment lines
      else
        # actual data line
        splut = line.strip.split
        r = {}
        column_names.each_with_index do |col, index|
          r[col] = splut[index+1]
        end
        @matrix_hash[splut[0]] = r
      end
    end
  end
  
  def get(column_letter, row_letter)
    @matrix_hash[row_letter][column_letter]
  end
end
