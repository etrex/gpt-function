# frozen_string_literal: true

require "spec_helper"
RSpec.describe GptFunction::Batch do
  before do
    GptFunction.configure(api_key: ENV['API_KEY'], model: "gpt-4o-mini")
  end

  it "list" do
    batchs = GptFunction::Batch.list
    puts batchs
  end

  it "create" do
    request1 = GptFunctions.翻譯成中文.to_request_body("apple")
    request2 = GptFunctions.翻譯成中文.to_request_body("tesla")
    batch = GptFunction::Batch.create([request1, request2])
    puts batch
  end

  it "from_id" do
    batch = GptFunction::Batch.from_id("batch_eCRAXbbU68r0hkfrldPaXHIT")
    puts batch
  end

  it "inputs & outputs" do
    batch = GptFunction::Batch.from_id("batch_eCRAXbbU68r0hkfrldPaXHIT")
    puts "inputs:"
    p batch.inputs
    puts ""
    puts "outputs:"
    p batch.outputs
  end

  it "pairs" do
    batch = GptFunction::Batch.from_id("batch_eCRAXbbU68r0hkfrldPaXHIT")
    p batch.pairs
  end

  it "cancel" do
    batch_ids = [
      "batch_1BUdy9JLQCDEhQsKZeIVsHe5",
      # "batch_kwtSST8SxLz5v5ftfBq8CCqi",
      # "batch_4cACuhQD2tZhzo36BVyUqgCY",
      # "batch_YMZbhJWcBYETMTfOfEf041qF",
      # "batch_bjvJ7lNPNGBBJklqX8K00mwd",
      # "batch_5fvUzEoseLfTvmxNZAjcSxnc",
      # "batch_AQghZdqTDesENltaFBqyQJkh",
      # "batch_28h9PogijSk1GBHbO1tHA8cg",
      # "batch_IMROuJHevl1aLqtQ4d89GN22",
      # "batch_h4ZciT76yWgxBoq1fEVmIYFE",
      # "batch_jxbnIcHjg7Bh5vdKVAadNPwn",
      # "batch_v5c5qX6e4BfdO4cDhbGjRNYL",
      # "batch_YHAktEGNn4eX55NNQVxeLD4L",
      # "batch_mT866RnCFYq020YgB26TfvpA",
      # "batch_IOmv6XbfZMmo3MIFxO4KyZio",
      # "batch_3bUMIDe9PoEv2EqdOkVkDKfx",
      # "batch_YzPDDkT2q51QOo869og7UJz9",
      # "batch_UUjYMgsmcFCDRMY5z8xmCGZ3",
    ]

    batchs = batch_ids.map do |batch_id|
      GptFunction::Batch.from_id(batch_id)
    end

    batchs.each do |batch|
      response = batch.cancel
      p response
    end
  end

  it "整合測試" do
    inputs = [{"A"=>"B"},{"C"=>"D"}]
    file1 = GptFunction::File.create(inputs)
    file2 = GptFunction::File.from_id(file1.id)

    expect(file1.jsonl).to eq(file2.jsonl)
    expect(file1.jsonl).to eq(inputs)

    response = file1.delete
    expect(response["deleted"]).to eq(true)
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
