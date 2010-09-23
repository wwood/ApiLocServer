class Microarray < ActiveRecord::Base
  has_many :microarray_timepoints, :dependent => :destroy
  
  WINZELER_2003_NAME = "Winzeler Cell Cycle 2003"
  WINZELER_2005_GAMETOCYTE_NAME = "Winzeler Gametocyte 2005"
  WINZELER_2009_TILING_NAME = "Winzeler Tiling Array 2009"
  DERISI_3D7_LOCALISATION_MEDIAN_TIMEPOINTS = 'DeRisi 3D7 Localisation Medians'
  DERISI_2006_3D7_DEFAULT_NAME = 'DeRisi 2006 3D7 Quality Control Published'

  TOXOPLASMA_ARCHETYPAL_LINEAGE_PERCENTILES_NAME = 'Three archetypal T. gondii lineages - Percentiles'
  
  WINZELER_IRBC_SPZ_GAM_MAX_PERCENTILE = 'Pf-iRBC+Spz+Gam max expr %ile (Affy)'
  
  def self.yeast_alpha_arrest_name
    'Yeast Spellman Alpha Arrest'
  end
  
  def self.derisi_2006_3D7_default
    DERISI_2006_3D7_DEFAULT_NAME
  end
end
