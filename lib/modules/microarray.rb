
# A collection of methods to do with microarray
class BScript
  # upload the derisi data to my second microarray database implementation
  def derisi_microarray_to_database2(filename = "#{DATA_DIR}/falciparum/microarray/DeRisi2006/S03_3D7_QC.tab")
    microarray = Microarray.find_or_create_by_description Microarray.derisi_2006_3D7_default
    
#    microarray.microarray_timepoints.each do |t|
#      # destroys timepoint and all measurements as well
#      t.destroy
#    end
    
    alpha_cols = 2..63
    orf_name_col = 1
    timepoints = []
    
    first = true
    
    wc = `wc -l '#{filename}'`.to_i
    progress = ProgressBar.new('derisi2006_upload',wc)
    
    CSV.open(filename, 'r', "\t") do |row|
      progress.inc
      if first
        timepoints = row[alpha_cols].collect do |name|
          MicroarrayTimepoint.find_or_create_by_microarray_id_and_name(
                                                                       microarray.id,
                                                                       name
          )
        end
        
        first = false
        next
      end
      
      # find the coding regions
      orf_name = row[orf_name_col]
      code = CodingRegion.falciparum.find_by_name_or_alternate(orf_name)
      if !code
        $stderr.puts "No coding region #{orf_name} found"
        next
      end
      
      # Normal Column. Add the data
      alpha_cols.each do |i|
        cell = row[i]
        value = cell
        if value
          t = timepoints[i-alpha_cols.begin]
          
          # Uploading mulitple at one time is fine. Assume the whole dataset is being uploaded at once here
          
          # There is actually a small bug here. It is theoretically possible that you can have the same region be measured twice.
          MicroarrayMeasurement.create!(
            :microarray_timepoint_id => t.id,
            :measurement => value,
            :coding_region_id => code.id
          )
        end
      end
    end
    progress.finish
  end
end