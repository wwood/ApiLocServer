# A script for automatic creation and setup of pbs scripts, so
# that a script doesn't have to be set up for each job that is to be submitted

require 'tempfile'

class Pbs

  DEFAULT_PARAMETERS = {
    :email => 'b.woodcroft@pgrad.unimelb.edu.au',
    :job_name => 'MyJob',
    :nodes => 'nodes=1', #default to serial jobs
    :walltime => '24:00:00',
    :receive_email => 'ae',
    :shell => '/bin/bash'
  }

  PARAMETER_CONVERSIONS = {
    :email => 'PBS -M ',
    :job_name => 'PBS -N ',
    :nodes => 'PBS -l ',
    :walltime => 'PBS -l walltime=',
    :receive_email => 'PBS -m ',
    :shell => 'PBS -S '
  }

  def self.qsub(command, pbs_parameters = {})
    # Create a tempfile to create the script in
    Tempfile.open('rpbs_qsub_script') do |tempfile|

      # write each of the parameters to the tempfile
      final_hash = DEFAULT_PARAMETERS.merge pbs_parameters
      final_hash.each do |parameter, endpoint|
        conv = PARAMETER_CONVERSIONS[parameter]
        raise Exception, "RPBS: Don't know how to handle parameter: #{parameter}" if conv.nil?

        tempfile.puts "##{conv}#{endpoint}"
      end

      # some other stuff
      tempfile.puts '# Changes directory to your execution directory (Leave as is)'
      tempfile.puts 'cd $PBS_O_WORKDIR'

      # write the command to the tempfile
      tempfile.puts command

      tempfile.flush

      # qsub in reality
      system "qsub #{tempfile.path}"
    end
  end

  # Return the string that is to be written to the tempfile that is to be qsub'd
  def self.get_pbs_script(command, pbs_parameters={})
    toReturn = ''
    
    # write each of the parameters to the tempfile
    final_hash = DEFAULT_PARAMETERS.merge pbs_parameters
    final_hash.each do |parameter, endpoint|
      conv = PARAMETER_CONVERSIONS[parameter]
      raise Exception, "RPBS: Don't know how to handle parameter: #{parameter}" if conv.nil?

      toReturn << "##{conv}#{endpoint}\n"
    end

    # some other stuff
    toReturn << "# Changes directory to your execution directory (Leave as is)\n"
    toReturn << "cd $PBS_O_WORKDIR\n"
    toReturn << "# Actual command to run is below\n"

    # write the command to the tempfile
    toReturn << "#{command}\n"

    return toReturn
  end
end