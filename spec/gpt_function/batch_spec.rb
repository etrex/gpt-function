# frozen_string_literal: true

require "spec_helper"
RSpec.describe GptFunction::Batch do
  before do
    GptFunction.configure(api_key: ENV['API_KEY'], model: ENV["MODEL"])
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
    batch.pairs.each do |input, output|
      puts "input: #{input}, output: #{output}"
    end
  end

  it "cancel" do
    batch_ids = [
      "batch_1BUdy9JLQCDEhQsKZeIVsHe5",
    ]

    batchs = batch_ids.map do |batch_id|
      GptFunction::Batch.from_id(batch_id)
    end

    batchs.each do |batch|
      response = batch.cancel
      p response
    end
  end

  it "enqueue" do
    batch = GptFunction::Batch.create([GptFunctions.翻譯成中文.to_request_body("apple")])
    expect(batch.enqueue).to be_truthy
  end

  it "dequeue" do
    batch = GptFunction::Batch.create([GptFunctions.翻譯成中文.to_request_body("apple")])
    batch.enqueue
    dequeued_batch = GptFunction::Batch.dequeue
    expect(dequeued_batch.id).to eq(batch.id)
  end

  it "process" do
    batch = GptFunction::Batch.create([GptFunctions.翻譯成中文.to_request_body("apple")])
    batch.enqueue

    # 每 1 秒執行一次
    processed = false
    loop do
      GptFunction::Batch.process do |batch|
        puts "batch id: #{batch.id}, status: #{batch.status}, progress: #{batch.request_counts_completed}/#{batch.request_counts_total}"
        batch.pairs.each do |input, output|
          puts "input: #{input}, output: #{output}"
        end
        processed = batch.is_processed
      end
      # show current time in format 2021-09-01 12:00:00
      puts "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")} processed: #{processed}"
      break if processed
      sleep 1
    end
  end

  it "process_all" do
    batch1 = GptFunction::Batch.create([GptFunctions.翻譯成中文.to_request_body("apple")])
    batch2 = GptFunction::Batch.create([GptFunctions.翻譯成中文.to_request_body("banana")])
    batch1.enqueue
    batch2.enqueue

    GptFunction::Batch.process(count: 5) do |batch|
      expect([batch1.id, batch2.id]).to include(batch.id)
    end
  end
end
