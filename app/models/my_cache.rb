class MyCache < ActiveRecord::Base
  serialize :cache

  FALCIPARUM_AMINO_ACID_FRACTIONS = 'falciparum amino acid fractions'
end
