class NeafseyNonSynonymousSnp < IntegerCodingRegionMeasurement
  validates_uniqueness_of :coding_region_id
end
