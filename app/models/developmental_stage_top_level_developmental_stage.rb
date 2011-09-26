require 'developmental_stage_umbrella_mappings'

class DevelopmentalStageTopLevelDevelopmentalStage < ActiveRecord::Base
  belongs_to :developmental_stage
  belongs_to :top_level_developmental_stage

  include ApiLocUmbrellaDevelopmentalStageMappings
  APILOC_DEVELOPMENTAL_STAGE_TOP_LEVEL_DEVELOPMENTAL_STAGES = APILOC_UMBRELLA_DEVELOPMENTAL_STAGE_MAPPINGS
  
  def upload_apiloc_top_level_developmental_stages
    # positive
    APILOC_DEVELOPMENTAL_STAGE_TOP_LEVEL_DEVELOPMENTAL_STAGES.each do |low, high|
      top = TopLevelDevelopmentalStage.find_or_create_by_name(high.downcase)
      bottoms = DevelopmentalStage.find_all_by_name(low.downcase)
      if bottoms.length == 0
        $stderr.puts "Unable to find low level developmental stage '#{low}' - remove it from the top_level hash?"
        next
      end
      
      bottoms.each do |b|
        DevelopmentalStageTopLevelDevelopmentalStage.find_or_create_by_developmental_stage_id_and_top_level_developmental_stage_id(
                                                                                                                                   b.id, top.id
        ).save!
      end
    end
    #negative, not quite DRY but meh
    APILOC_DEVELOPMENTAL_STAGE_TOP_LEVEL_DEVELOPMENTAL_STAGES.each do |l, h|
      high = DevelopmentalStage.add_negation(h)
      low = DevelopmentalStage.add_negation(l)
      top = TopLevelDevelopmentalStage.find_or_create_by_name(high.downcase)
      bottoms = DevelopmentalStage.find_all_by_name(low.downcase)
      if bottoms.length == 0
        $stderr.puts "Unable to find low level developmental stage '#{low}' - remove it from the top_level hash?"
        next
      end
      
      bottoms.each do |b|
        DevelopmentalStageTopLevelDevelopmentalStage.find_or_create_by_developmental_stage_id_and_top_level_developmental_stage_id(
                                                                                                                                   b.id, top.id
        ).save!
      end
    end
    check_for_unclassified
  end
  
  # Check to make sure each developmental stage is assigned a top level
  # developmental stage
  def check_for_unclassified
    DevelopmentalStage.all.each do |dev|
      if dev.top_level_developmental_stage.nil?
        $stderr.puts "Couldn't find '#{dev.name}' from #{dev.species.name}, #{dev.id} classified in the top level: #{dev.top_level_developmental_stage.inspect}"
      end
    end
  end
end
