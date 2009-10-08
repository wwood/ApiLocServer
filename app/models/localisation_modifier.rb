class LocalisationModifier < ActiveRecord::Base
  KNOWN_MODIFIERS = %w(
    weak sometimes some little sporadically reduced variable partially
    strong substantial mainly throughout predominantly bright
    punctate homogenous homogenously diffuse uniform heterogenous entire
    semi-punctate smooth beaded patchy
  )

  def upload_known_modifiers
    KNOWN_MODIFIERS.each do |mod|
      LocalisationModifier.find_or_create_by_modifier(mod)
    end
  end
end
