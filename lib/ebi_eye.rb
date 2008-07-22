require 'soap/wsdlDriver'
# URL for the service WSDL
wsdl = 'http://www.ebi.ac.uk/Tools/webservices/wsdl/WSDbfetch.wsdl'
begin
  # Get the object from the WSDL
  dbfetch= SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
  #fout = File.open("sequence.fasta","w")
  puts dbfetch.fetchData("uniprot:slpi_human", "fasta", "raw")
#  fout.close
end