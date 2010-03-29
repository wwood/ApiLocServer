class ProteomicExperiment < ActiveRecord::Base
  has_many :proteomic_experiment_results, :dependent => :destroy
  has_many :coding_regions, :through => :proteomic_experiment_results
  has_many :proteomic_experiment_peptides, :dependent => :destroy
  belongs_to :publication

  FALCIPARUM_FOOD_VACUOLE_2008_NAME = 'P. falciparum Food Vacuole Lamarque et al 2008'
  FALCIPARUM_FOOD_VACUOLE_2008_PUBLICATION_DETAILS = { #not in pubmed (any more?)
    :url => 'http://www3.interscience.wiley.com/journal/120840762/abstract',
    :authors => 'Mauld Lamarque, Christophe Tastet, Joël Poncet, Edith Demettre, Patrick Jouin, Henri Vial, Jean-François Dubremetz, Dr.',
    :date => '2008',
    :title => 'Food vacuole proteome of the malarial parasite Plasmodium falciparum',
    :abstract => 'The Plasmodium falciparum food vacuole (FV) is a lysosome-like organelle where erythrocyte hemoglobin digestion occurs. It is a favorite target in the development of antimalarials. We have used a tandem mass spectrometry approach to investigate the proteome of an FV-enriched fraction and identified 116 proteins. The electron microscopy analysis and the Western blot data showed that the major component of the fraction was the FV and, as expected, the majority of previously known FV markers were recovered. Of particular interest, several proteins involved in vesicle-mediated trafficking were identified, which are likely to play a key role in FV biogenesis and/or FV protein trafficking. Recovery of parasite surface proteins lends support to the cytostomal pathway of hemoglobin ingestion as a FV trafficking route. We have identified 32 proteins described as hypothetical in the databases. This insight into FV protein content provides new clues towards understanding the biological function of this organelle in P. falciparum.'
  }
  
  FALCIPARUM_WHOLE_CELL_2002_SPOROZOITE_NAME = 'P. falciparum Whole Cell Florens et al 2008 during Sporozoite'
  FALCIPARUM_WHOLE_CELL_2002_MEROZOITE_NAME = 'P. falciparum Whole Cell Florens et al 2008 during Merozoite'
  FALCIPARUM_WHOLE_CELL_2002_TROPHOZOITE_NAME = 'P. falciparum Whole Cell Florens et al 2008 during Trophozoite'
  FALCIPARUM_WHOLE_CELL_2002_GAMETOCYTE_NAME = 'P. falciparum Whole Cell Florens et al 2008 during Gametocyte'
  FALCIPARUM_WHOLE_CELL_2002_PUBMED_ID = 12368866

  FALCIPARUM_MAURERS_CLEFT_2005_NAME = 'P. falciparum Maurer\'s Cleft Vinvensini et al 2005'
  FALCIPARUM_MAURERS_CLEFT_2005_PUBMED_ID = 15140830

  FALCIPARUM_SUMOYLATION_2008_NAME = 'P. falciparum Sumoylated Isaar et al 2008'
  FALCIPARUM_SUMOYLATION_2008_PUBMED_ID = 18547337
  
  FALCIPARUM_GAMETOCYTOGENESIS_2010_PUBMED_ID = 20332084
  FALCIPARUM_GAMETOCYTOGENESIS_2010_TROPHOZOITE_NAME = 'P. falciparum Trophozoite Silvestrini et al 2010'
  FALCIPARUM_GAMETOCYTOGENESIS_2010_GAMETOCYTE_STAGE_I_AND_II_NAME = 'P. falciparum Gametocyte Stage I and II Silvestrini et al 2010'
  FALCIPARUM_GAMETOCYTOGENESIS_2010_GAMETOCYTE_STAGE_V_NAME = 'P. falciparum Gametocyte Stage V Silvestrini et al 2010'

  TOXOPLASMA_NAME_TO_PUBLICATION_HASH = {
    'T. gondii 1D Gel Tachyzoite Membrane fraction 10-2006' => 11796121,
    'T. gondii 1D Gel Tachyzoite Membrane fraction 12-2006' => 11796121,
    'T. gondii 2DLC MS/MS Tachyzoite Membrane fraction' => 11796121,
    'T. gondii Moreno DTASelect filter sample A' => 'http://toxodb.org/toxo/showXmlDataContent.do?name=XmlQuestions.DataSources&datasets=Moreno-1-annotated',
    'T. gondii Moreno DTASelect filter sample G' => 'http://toxodb.org/toxo/showXmlDataContent.do?name=XmlQuestions.DataSources&datasets=Moreno-1-annotated',
    'T. gondii MS Carruthers 2 distinct peptides' => 16002397,
    'T. gondii MS Carruthers MudPIT Twinscan hits' => 16002397,
    'T. gondii MS Tachyzoite Cytosolic Protein Fractions 05-2007' => 11796121,
    'T. gondii MS Tachyzoite Membrane fraction 02-03-2006' => 11796121,
    'T. gondii MS Tachyzoite Membrane fraction 05-02-2006' => 11796121,
    'T. gondii MS Tachyzoite Membrane fraction 05-10-2006' => 11796121,
    'T. gondii MS Tachyzoite Membrane fraction 06-2006' => 11796121,
    'T. gondii MS Tachyzoite Membrane Protein with Biotinlyation Purification 05-22-2007' => 11796121,
    'T. gondii Murray Conoid-depleted Fraction' => 16518471,
    'T. gondii Murray Conoid-enriched Fraction' => 16518471,
    'T. gondii Wastling 1-D SDS PAGE' => 11796121,
    'T. gondii Wastling 1-D SDS PAGE Insoluble' => 11796121,
    'T. gondii Wastling 1-D SDS PAGE Soluble' => 11796121,
    'T. gondii Wastling MudPIT Insoluble' => 11796121,
    'T. gondii Wastling MudPIT Soluble' => 11796121,
    'T. gondii Wastling Rhoptry' => 16002398
  }
end
