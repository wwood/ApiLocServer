# Modules surrounding the orthomcl database, as it relates to gnr

class BScript
  def orthomcl_to_database
    orthomcl_groups_to_database
    upload_orthomcl_official_deflines
  end
  
  # Load the data from the groups file alone - upload all genes and groups
  # in the process
  def orthomcl2_groups_to_database
    orthomcl_groups_to_database(
      "#{ORTHOMCL_BASE_DIR}/v2/groups_orthomcl-2.txt.gz",
    OrthomclRun.official_run_v2
    )
  end
  
  def orthomcl_groups_to_database(run_name = OrthomclRun::ORTHOMCL_OFFICIAL_NEWEST_NAME,
    gz_filename=nil
    )
    if gz_filename.nil?
      gz_filename = "#{ORTHOMCL_BASE_DIR}/#{OrthomclRun.version_name_to_local_data_dir(OrthomclRun::ORTHOMCL_OFFICIAL_NEWEST_NAME)}/#{OrthomclRun.groups_gz_filename(OrthomclRun::ORTHOMCL_OFFICIAL_NEWEST_NAME)}"
    end
    
    run = OrthomclRun.find_or_create_by_name(run_name)
    wc = `gunzip -c '#{gz_filename}' |wc -l`.to_i
    progress = ProgressBar.new('orthomcl_groups',wc)
    
    Zlib::GzipReader.open(gz_filename) do |gz|
      gz.each do |line|
        progress.inc
        next if !line or line === ''
        
        splits1 = line.split(': ')
        if splits1.length != 2
          raise Exception, "Bad line: #{line}"
        end
        
        g = OrthomclGroup.find_or_create_by_orthomcl_name(splits1[0])
        
        splits2 = splits1[1].split(' ')
        if splits2.length < 1
          raise Exception, "Bad line (2): #{line}"
        end
        splits2.each do |name|
          og = OrthomclGene.find_or_create_by_orthomcl_name(name)
          OrthomclGeneOrthomclGroupOrthomclRun.find_or_create_by_orthomcl_gene_id_and_orthomcl_group_id_and_orthomcl_run_id(
                                                                                                                            og.id, g.id, run.id
          )
        end
      end
    end
    progress.finish
  end
  
  # The directory of the orthomcl data
  def orthomcl_dot_org_download_dir(orthomcl_version)
    base_dir = 'http://orthomcl.org/common/downloads/'
    num = OrthomclRun.version_name_to_number(orthomcl_version)
    dir = "release-#{num}"
    if [1,2,2.2].include?(num) # These are the exceptions
      return "#{base_dir}/#{num}"
    else
      return "#{base_dir}/#{dir}"
    end
  end
  
  # Download the data from orthomcl used in apiloc
  def download_orthomcl(orthomcl_version=OrthomclRun::ORTHOMCL_OFFICIAL_NEWEST_NAME)
    orthomcl_base_dir = ORTHOMCL_BASE_DIR
    dir = "#{orthomcl_base_dir}/#{OrthomclRun.version_name_to_local_data_dir(orthomcl_version)}"
    
    # Ensure the directories to be downloaded exist
    Dir.mkdir orthomcl_base_dir unless File.exists?(orthomcl_base_dir)
    Dir.mkdir dir unless File.exists?(dir)
    
    # Find the path of the download directory at orthomcl.org
    download_dir = orthomcl_dot_org_download_dir(orthomcl_version)
    
    # Download the groups
    orthomcl_groups_gz_filename = OrthomclRun.groups_gz_filename(orthomcl_version)
    local_path = "#{dir}/#{orthomcl_groups_gz_filename}"
    unless File.exists?(local_path)
      cmd = "wget -O '#{local_path}' '#{download_dir}/#{orthomcl_groups_gz_filename}'"
      puts cmd
      `#{cmd}`
    end
    
    # Download the deflines
    orthomcl_deflines_gz_filename = OrthomclRun.deflines_gz_filename(orthomcl_version)
    local_path = "#{dir}/#{orthomcl_deflines_gz_filename}"
    unless File.exists?(local_path)
      cmd = "wget -O '#{local_path}' '#{download_dir}/#{orthomcl_deflines_gz_filename}'"
      puts cmd
      `#{cmd}`
    end
  end
  
  # upload just using the deflines - I don't really need the sequences
  def upload_orthomcl_official_deflines(run_name = OrthomclRun::ORTHOMCL_OFFICIAL_NEWEST_NAME,
    gz_filename=nil)
    if gz_filename.nil?
      gz_filename = "#{ORTHOMCL_BASE_DIR}/#{OrthomclRun.version_name_to_local_data_dir(OrthomclRun::ORTHOMCL_OFFICIAL_NEWEST_NAME)}/#{OrthomclRun.deflines_gz_filename(OrthomclRun::ORTHOMCL_OFFICIAL_NEWEST_NAME)}"
    end
    
    run = OrthomclRun.find_or_create_by_name(run_name)
    wc = `gunzip -c '#{gz_filename}' |wc -l`.to_i
    progress = ProgressBar.new('orthomcl_deflines',wc)
    
    Zlib::GzipReader.open(gz_filename) do |gz|
      gz.each do |line|
        line.strip!
        progress.inc
        
        parsed = OrthomclDeflineParser.parse(line)

        orthomcl_id = parsed.gene_id
        orthomcl_group_name = parsed.group_id
        annot = parsed.annotation
        
        ogene = nil
        
        if orthomcl_group_name == 'no_group'
          # Upload the gene as well now
          ogene = OrthomclGene.find_or_create_by_orthomcl_name(orthomcl_id)
          
          OrthomclGeneOrthomclGroupOrthomclRun.find_or_create_by_orthomcl_gene_id_and_orthomcl_run_id(
                                                                                                      ogene.id, run.id
          )
        else
          ogenes = OrthomclGene.official.find(:all,
          :conditions => {:orthomcl_genes => {:orthomcl_name => orthomcl_id}}
          )
          
          if ogenes.length != 1
            if ogenes.length == 0
              # Raise exceptions now because singlets are uploaded now - this gene apparently has a group
              raise Exception, "No gene found for #{orthomcl_id} when there should be when uploading orthomcl deflines. Are the singletons uploaded?"
            else
              raise Exception, "Too many genes found for #{orthomcl_id}"
            end
          end
          
          ogene = ogenes[0]
        end
        
        # find the annotation
        unless annot == ''
          OrthomclGeneOfficialData.find_or_create_by_orthomcl_gene_id_and_annotation(
                                                                                     ogene.id,
                                                                                     annot
          )
        end
      end
    end
    progress.finish
  end
  
  def upload_orthomcl_official_sequences(fasta_filename="#{WORK_DIR}/Orthomcl/seqs_orthomcl-2.fasta")
    raise Exception, "out of date method. needs fixing, or just use upload_orthomcl_official_deflines"
    flat = Bio::FlatFile.open(Bio::FastaFormat, fasta_filename)
    
    run = OrthomclRun.official_run_v2
    
    flat.each do |seq|
      
      # Parse out the official ID
      line = seq.definition
      splits_space = line.split(' ')
      if splits_space.length < 3
        raise Exception, "Badly handled line because of spaces: #{line}"
      end
      orthomcl_id = splits_space[0]
      
      orthomcl_group_name = splits_space[2]
      ogene = nil
      
      if orthomcl_group_name == 'no_group'
        # Upload the gene as well now
        ogene = OrthomclGene.find_or_create_by_orthomcl_name(orthomcl_id)
        
        OrthomclGeneOrthomclGroupOrthomclRun.find_or_create_by_orthomcl_gene_id_and_orthomcl_run_id(
                                                                                                    ogene.id, run.id
        )
      else
        ogenes = OrthomclGene.official.find(:all,
          :conditions => {:orthomcl_genes => {:orthomcl_name => orthomcl_id}}
        )
        
        if ogenes.length != 1
          if ogenes.length == 0
            # Raise exceptions now because singlets are uploaded now - this gene apparently has a group
            raise Exception, "No gene found for #{orthomcl_id} when there should be when uploading orthomcl sequences"
          else
            raise Exception, "Too many genes found for #{orthomcl_id}"
          end
        end
        
        ogene = ogenes[0]
      end
      
      # find the annotation
      splits_bar = line.split('|')
      if splits_bar.length == 3
        annot = ''
      elsif splits_bar.length > 4
        annot = splits_bar[3..splits_bar.length-1].join('|')
      elsif splits_bar.length != 4
        raise Exception, "Bad number of bars (#{splits_bar.length}): #{line}"
      else
        annot = splits_bar[3].strip
      end
      
      OrthomclGeneOfficialData.find_or_create_by_orthomcl_gene_id_and_sequence_and_annotation(
                                                                                              ogene.id,
                                                                                              seq.aaseq,
                                                                                              annot
      )
    end
  end
  
  def paralogous_elegans_groups
    OrthomclRun.official_run_v2.orthomcl_groups.all.each do |group|
      if group.orthomcl_genes.code('cel').count > 1
        puts group.orthomcl_name
      end
    end
  end
end
