module ApilocHelper
  def popular_localisations
    [
      'apicoplast',
      'mitochondrion',
      'nucleus'
    ]
  end

  def code_name(code)
    "#{link_to code.string_id, :action => :gene, :id => code.string_id} (#{code.case_sensitive_literature_defined_coding_region_alternate_string_ids.reach.name.join(', ')})"
  end
end
