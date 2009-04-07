require 'gsl'

class LocalisationMedianMicroarrayMeasurement < MetaMicroarrayMeasurement
  LOCALISATIONS = [
    'parasite plasma membrane',
    'exported',
    'mitochondria',
    'food vacuole',
    'parasitophorous vacuole',
    'apicoplast',
    'cytosol',
    'nucleus',
    'golgi',
    'endoplasmic reticulum',
    'merozoite surface',
    'inner membrane complex',
    'apical'
  ]

  # Calculate the pearson distance from each localisation median, in the
  # order of LocalisationMedianMicroarrayMeasurement::LOCALISATIONS. Return
  # an array of distances from those medians
  def self.pearson_distance_from_localisation_medians(coding_region)
    self.distance_from_localisation_medians(coding_region) do |codes, medians|
      GSL::Stats::correlation(
        GSL::Vector.alloc(codes),
        GSL::Vector.alloc(medians)
      )
    end
  end

  def self.euclidean_distance_from_localisation_medians(coding_region)
     self.distance_from_localisation_medians(coding_region) do |codes, medians|
       # How dare I code this myself.
      sum = 0
      codes.each_with_index do |code, index|
        # have to convert this to a real number for some reason, otherwise I get
        # 0.0i bits
        sum += (code-medians[index]).power(2).real
      end
      Math.sqrt(sum).real
    end
  end

  # Allow calculation the distance from each localisation median, in the
  # order of LocalisationMedianMicroarrayMeasurement::LOCALISATIONS. Return
  # an array of distances from those medians
  def self.distance_from_localisation_medians(coding_region)
    return LOCALISATIONS.collect do |loc|
      timepoints = MicroarrayTimepoint.all(
        :conditions => ['name like ?', MicroarrayTimepoint.get_derisi_3d7_localisation_median_names_sql(loc)],
        :order => 'name'
      )
      loc_measures = timepoints.reach.localisation_median_microarray_measurement
      if loc_measures[0].nil?
        return 'yaha'
        return nil
      else
        loc_measures = loc_measures.measurement.retract
      end

      # Get the first coding region - don't care about duplicates for the moment
      code_measures = MicroarrayTimepoint.microarray_name(Microarray::DERISI_2006_3D7_DEFAULT_NAME).all(
        :order => 'name',
        :conditions => ['name like ?','%Timepoint%']
      ).collect do |timepoint|
        m = MicroarrayMeasurement.find_by_coding_region_id_and_microarray_timepoint_id(coding_region.id, timepoint.id)
        if m.nil?
          nil # Just because one timepoint is missing, that doesn't matter just now.
        else
          m.measurement
        end
      end

      # shorten the arrays so that there are no nils to send to GSL
      final_code_measures = []
      final_median_measures = []
      code_measures.each_with_index do |m, i|
        unless m.nil?
          final_code_measures.push(m)
          final_median_measures.push loc_measures[i]
        end
      end

      if final_code_measures.empty?
        # Ignore unmeasured components
        nil
      else
        # Do the final correlation
        yield final_code_measures, final_median_measures
      end
    end
  end
end
