# frozen_string_literal: true

require "spec_helper"
RSpec.describe GptFunction::File do
  before do
    GptFunction.configure(api_key: ENV['API_KEY'], model: ENV["MODEL"])
  end

  it "list" do
    files = GptFunction::File.list
    puts files
  end

  it "create" do
    file = GptFunction::File.create([{"A":"B"}])
    puts file
  end

  # it "from_id" do
  #   file = GptFunction::File.from_id("file-5m1Cn4M36GOfd7bEVAoTCmcC")
  #   puts file
  # end

  # it "content" do
  #   content = GptFunction::File.content("file-5m1Cn4M36GOfd7bEVAoTCmcC")
  #   p content
  # end

  # it "jsonl" do
  #   hash_array = GptFunction::File.jsonl("file-5m1Cn4M36GOfd7bEVAoTCmcC")
  #   p hash_array
  # end

  # it "delete" do
  #   response = GptFunction::File.delete("file-5m1Cn4M36GOfd7bEVAoTCmcC")
  #   p response
  # end

  it "整合測試" do
    inputs = [{"A"=>"B"},{"C"=>"D"}]
    file1 = GptFunction::File.create(inputs)
    file2 = GptFunction::File.from_id(file1.id)

    expect(file1.jsonl).to eq(file2.jsonl)
    expect(file1.jsonl).to eq(inputs)

    response = file1.delete
    expect(response["deleted"]).to eq(true)
  end

  it "delete files" do
    files = GptFunction::File.list
    files.each do |file|
      p file.filename.start_with?("batch")
    end
  end

  # context "create & delete" do
  #   before do
      # 模擬 HTTP 請求和響應
      # content = { output: "蘋果" }.to_json
      # body = { choices: [{ message: { content: content } }] }.to_json
      # stub_request(:post, "https://api.openai.com/v1/chat/completions").to_return(status: 200,
      #                                                                             body: body)
    # end

  # end
end
