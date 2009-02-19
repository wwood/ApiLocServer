# A join model (1 to N) between coding region and go term
class CodingRegionGoTerm < ActiveRecord::Base
  validates_presence_of :coding_region_id
  validates_presence_of :go_term_id
  
  # Taken from http
  EVIDENCE_CODES = %w(
    EXP
    IDA
    IPI
    IMP
    IGI
    IEP

    ISS
    ISO
    ISA
    ISM
    IGC
    RCA

    TAS
    NAS

    IC
    ND

    IEA

    NR
  )
  
  validates_each :evidence_code do |record, attr, value|
    record.errors.add attr, 'invalid evidence code' unless EVIDENCE_CODES.include?(value)
  end
  
  belongs_to :coding_region
  belongs_to :go_term
end
