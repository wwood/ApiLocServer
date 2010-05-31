class SecondClassCitizenInformation < ActiveRecord::Base
  has_many :second_class_citizen_informations, :dependent => :destroy
end
