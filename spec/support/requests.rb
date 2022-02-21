RSpec.shared_context "requests", shared_context: :metadata do
  def params(hash)
    if Rails.version.start_with?("4")
      hash
    else
      { params: hash }
    end
  end
end
