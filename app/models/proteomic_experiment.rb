class ProteomicExperiment < ActiveRecord::Base
  has_many :proteomic_experiment_results, :dependent => :destroy

  FALCIPARUM_FOOD_VACUOLE_2008_NAME = 'P. falciparum Food Vacuole Lamarque et al 2008'
  
  FALCIPARUM_WHOLE_CELL_2002_SPOROZOITE_NAME = 'P. falciparum Whole Cell Florens et al 2008 during Sporozoite'
  FALCIPARUM_WHOLE_CELL_2002_MEROZOITE_NAME = 'P. falciparum Whole Cell Florens et al 2008 during Merozoite'
  FALCIPARUM_WHOLE_CELL_2002_TROPHOZOITE_NAME = 'P. falciparum Whole Cell Florens et al 2008 during Trophozoite'
  FALCIPARUM_WHOLE_CELL_2002_GAMETOCYTE_NAME = 'P. falciparum Whole Cell Florens et al 2008 during Gametocyte'
end
