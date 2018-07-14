if Rails.version.start_with? "4"
  def file_fixture(filename)
    Pathname(File.join(__dir__, "../fixtures/files", filename))
  end
end