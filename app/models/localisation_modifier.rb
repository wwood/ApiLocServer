class LocalisationModifier < ActiveRecord::Base
  KNOWN_MODIFIERS = %w(
    weak  some little sporadically reduced variable partially
    strong substantial mainly throughout predominantly bright especially concentrated
    punctate homogenous homogenously diffuse uniform heterogenous entire granular
    semi-punctate smooth beaded patchy varied dotty foci
  ).push([
      'sometimes', #sometimes has be after some -> higher ids are implemented first
      'strongly', #has to be after strong
      'strongest',
      'strongest near'
    ]).push([
      'spot in',
      'discrete compartments at',
      'strong diffuse',
      'foci in',
      'large foci',
      'random in',
      'spiralling on',
    ]).flatten

  def upload_known_modifiers
    KNOWN_MODIFIERS.each do |mod|
      LocalisationModifier.find_or_create_by_modifier(mod)
    end
  end
end
