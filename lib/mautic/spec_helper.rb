require File.expand_path('../../../spec/spec_helper', __FILE__)
Dir.glob(File.expand_path('../../../spec/{factories,support}/*.rb', __FILE__)).each do |file|
  require file
end
