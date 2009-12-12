# Modules surrounding the orthomcl database, as it relates to gnr

class BScript
  def orthomcl_to_database
    orthomcl_groups_to_database
    upload_orthomcl_official_sequences
  end

  # Load the data from the groups file alone - upload all genes and groups
  # in the process
  def orthomcl2_groups_to_database
    orthomcl_groups_to_database(
      "#{DATA_DIR}/orthomcl/v2/groups_orthomcl-2.txt.gz",
      OrthomclRun.official_run_v2
    )
  end

  def orthomcl_groups_to_database(
      filename="#{DATA_DIR}/orthomcl/v3/groups_OrthoMCL-3.txt.gz",
      run = OrthomclRun.official_run_v3
    )
    #    OrthomclGene.delete_all
    #    OrthomclGroup.delete_all
    #    OrthomclGeneCodingRegion.delete_all

    Zlib::GzipReader.open(filename) do |gz|
      gz.each do |line|
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
  end

  # Load the data from the groups file alone - upload all genes and groups
  # in the process
  def orthomcl_groups_to_database_test
    OrthomclGene.delete_all
    OrthomclGroup.delete_all

    r = File.open("/tmp/2")

    r.each do |line|
      if !line or line === ''
        next
      end

      splits1 = line.split(': ')
      if splits1.length != 2
        raise Exception, "Bad line: #{line}"
      end

      puts splits1[0]
      g = OrthomclGroup.find_or_create_by_version_and_orthomcl_name(2, splits1[0])

      splits2 = splits1[1].split(' ')
      if splits2.length < 1
        raise Exception, "Bad line (2): #{line}"
      end
      splits2.each do |name|
        OrthomclGene.find_or_create_by_orthomcl_group_id_and_orthomcl_name(g.id, name)
        puts name
      end

      puts
    end
  end

  # upload just using the deflines - I don't really need the sequences
  def upload_orthomcl_official_deflines(filename="#{DATA_DIR}/orthomcl/v3/aa_deflines_OrthoMCL-3.txt")
    run = OrthomclRun.find_by_name(OrthomclRun::ORTHOMCL_OFFICIAL_NEWEST_NAME)

    File.foreach(filename) do |line|
      line.strip!
      
      # Parse out the official ID
      line = line.gsub(/^>/,'')
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
            raise Exception, "No gene found for #{line} when there should be"
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

      OrthomclGeneOfficialData.find_or_create_by_orthomcl_gene_id_and_annotation(
        ogene.id,
        annot
      )
    end
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
            raise Exception, "No gene found for #{line} when there should be"
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
end
