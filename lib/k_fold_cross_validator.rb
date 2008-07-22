module Prediction

  # Maps to array indices in PredictorResult.predictor_counts
  TP = 0
  TN = 1
  FP = 2
  FN = 3
  NOT_PREDICTED =4
  
  class LocalisationKFoldCrossValidator
    attr_accessor :k
  
    def initialize
      @k = 5
    end
  
    # Given a predictor that conforms to the interface,
    # return a KFoldCrossValidatorResult that shows how well
    # the predictor worked.
    def cross_validate(predictor, data=LocalisationDataSet.new)    
      result = KFoldCrossValidatorResult.new
    
      num_to_train = data.length*(@k-1)/@k
    
      (1..@k).each do |i|
        # separate out a list of validations
        #        ides = data.keys.shuffle # this only works in newer versions of ruby, not for me (1.8.6)
        ides = data.sort_by { rand }
        count = 0
        training_array, validation_array = ides.partition{|k|
          count += 1
          count < num_to_train
        }
        training_hash = Hash.new
        training_array.each {|point| training_hash.store point[0], point[1]}
        validation_hash = Hash.new
        validation_array.each {|point| validation_hash.store point[0], point[1]}
      
        # train the predictor
        trained_predictor = predictor.train(training_hash)
    
        # validate the predictor
        this_result = trained_predictor.validate(validation_hash)
      
        # add the results of the run to the result to return
        result.add_result(this_result, validation_hash.keys)
      end
    
      return result
    end
  end


  # A Hash-like object that transforms analagous to 
  # {CodingRegion.id => localisation_name}
  # Or more generally {id => classification} 
  # but I predict localisation so..
  class LocalisationDataSet < Hash
    attr_accessor :loc_hash
  
    def initialize
      @loc_hash = {
        'apicoplast.Stuart.20080220' => 'apicoplast',
        'exportPred10' => 'exported'
      }
    
      CodingRegion.find(:all,
        :include => :plasmodb_gene_lists,
        :conditions => "plasmodb_gene_lists.description in ('#{@loc_hash.keys.join('\',\'')}')"
      ).each do |code|
        lists = code.plasmodb_gene_lists
        if lists.length == 1
          store code.id, @loc_hash[lists[0].description]
        else
          $stderr.puts "Wrong number of plasmodb gene lists - software software bug for #{code.string_id}: #{lists.length}"
        end
      end
    end
  
  
  end



  # Made up of a number of runs - the overall result
  class KFoldCrossValidatorResult<Array
    attr_reader :data_sets
    
    
    def add_result(predictor_result, set)
      push predictor_result
      @data_sets ||= []
      @data_sets.push set
    end
  
    def specificity
      # accuracy is the average accuracy of all the results individually
      collected_results = collect do |result|
        result.specificity
      end
    
      return average(collected_results)
    end
  
    def sensitivity
      collected_results = collect do |result|
        result.sensitivity
      end
    
      return average(collected_results)
    end
    
    def coverage
      collected_results = collect do |result|
        result.coverage
      end
    
      return average(collected_results)
    end
  
    protected
    def average(array)
      array.inject{|sum, n| sum+=n}.to_f/array.length.to_f
    end
    
  end
  
  



  # An array of results. 
  class PredictorResult<Array
    def specificity
      cees = prediction_counts
      return (cees[TN]).to_f/(cees[FP]+cees[TN]).to_f
    end
  
    def coverage
      cees = prediction_counts
      return (length-cees[NOT_PREDICTED]).to_f/length.to_f
    end
    
    def sensitivity
      cees = prediction_counts
      return cees[TP].to_f/(cees[TP]+cees[FN]).to_f
    end
  
    # return an array of counts of [TP, TN, FP, FN, NOT_PREDICTED]
    def prediction_counts
      # since the constants map to these indices, this is easy
      a = [0, 0, 0, 0, 0]
      each do |e|
        a[e] += 1
      end
      return a
    end
  end


  # A predictor conforming to the interface used in the LocalisationKFoldCrossValidator
  # first it is trained, and secondly it is validated many times
  class AbstractPredictor
    # train the predictor, based on the given data set. The data_set is a hash that maps
    # identifiers to classifications.
    # Return a trained predictor, which in the simple case is just going to be this class
    def train(data_set)
      raise Exception, "train method not yet implemented in concrete subclass"
    end
    
    # Validate the data_set based on the training. The dataset is the same as for train().
    def validate(data_set)
      raise Exception, "validate method not yet implemented in concrete subclass"
    end
  end
end