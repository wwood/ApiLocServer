class LocalisationModifier < ActiveRecord::Base
  KNOWN_MODIFIERS = %w(
    weak some little sporadically reduced variable partially barely minority
    strong substantial mainly throughout predominantly bright especially concentrated dispersed
    punctate homogenous homogenously diffuse uniform heterogenous entire granular punctuated
    semi-punctate smooth beaded patchy varied dotty foci faint
  ).push([
      'sometimes', #sometimes has be after some -> higher ids are implemented first
      'strongly', #has to be after strong
      'strongest',
      'strongest near',
      'concentrated in',
    ]).push([
      'spot in',
      'single spot in',
      'discrete compartments at',
      'punctate spots within the',
      'strong diffuse',
      'foci in',
      'foci at',
      'large foci',
      'random in',
      'spiralling on',
      'very weak',
      'somewhat punctate',
      'unpolarised on',
      'very low levels in',
      'lower concentration in',
      'diffused but granular'
    ]).flatten

  def upload_known_modifiers
    KNOWN_MODIFIERS.each do |mod|
      LocalisationModifier.find_or_create_by_modifier(mod)
    end
  end
end
