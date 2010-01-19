class AddPublicationToProteomicExperiment < ActiveRecord::Migration
  def self.up
    $stderr.puts "I'm deleting all the proteomic data now"
    ProteomicExperiment.destroy_all
    add_column :proteomic_experiments, :publication_id, :integer, :null => false
    add_foreign_key :proteomic_experiments, :publications, :dependent => :delete
  end

  def self.down
    remove_column :proteomic_experiments, :publication_id
  end
end
