# A join model (1 to N) between coding region and go term
class CodingRegionGoTerm < ActiveRecord::Base
  validates_presence_of :coding_region_id
  validates_presence_of :go_term_id

  COMPUTATIONAL_ANALYSIS_CODES = %w(
    ISS
    ISO
    ISA
    ISM
    IGC
    RCA
  )

  # Taken from http
  EVIDENCE_CODES = %w(
    EXP
    IDA
    IPI
    IMP
    IGI
    IEP

    TAS
    NAS

    IC
    ND

    IEA

    NR
  ).push(COMPUTATIONAL_ANALYSIS_CODES).flatten
  
  validates_each :evidence_code do |record, attr, value|
    record.errors.add attr, 'invalid evidence code' unless value.nil? or EVIDENCE_CODES.include?(value)
  end
  
  belongs_to :coding_region
  belongs_to :go_term

  named_scope :insilico, {
    :conditions => ['evidence_code in (?)', COMPUTATIONAL_ANALYSIS_CODES.push('IEA')]
  }
  named_scope :not_insilico, {
    :conditions => ['evidence_code not in (?)', COMPUTATIONAL_ANALYSIS_CODES.push('IEA')]
  }
  named_scope :useful, {
    :conditions => ['evidence_code not in (?)', COMPUTATIONAL_ANALYSIS_CODES.push(%w(IEA ND)).flatten]
  }

  def experimental_annotation?

  end

  def insilico_annotation?
    evidence_code == 'IEA' or COMPUTATIONAL_ANALYSIS_CODES.include?(evidence_code)
  end
end
