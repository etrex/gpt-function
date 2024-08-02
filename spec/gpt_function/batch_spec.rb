# frozen_string_literal: true

require "spec_helper"
RSpec.describe GptFunction::Batch do
  # before do
  #   GptFunction.configure(api_key: ENV['API_KEY'], model: ENV["MODEL"])
  # end

  # it "list" do
  #   batchs = GptFunction::Batch.list
  #   puts batchs
  # end

  # it "create" do
  #   request1 = GptFunctions.翻譯成中文.to_request_body("apple")
  #   request2 = GptFunctions.翻譯成中文.to_request_body("tesla")
  #   batch = GptFunction::Batch.create([request1, request2])
  #   puts batch
  # end

  # it "from_id" do
  #   batch = GptFunction::Batch.from_id("batch_eCRAXbbU68r0hkfrldPaXHIT")
  #   puts batch
  # end

  # it "inputs & outputs" do
  #   batch = GptFunction::Batch.from_id("batch_eCRAXbbU68r0hkfrldPaXHIT")
  #   puts "inputs:"
  #   p batch.inputs
  #   puts ""
  #   puts "outputs:"
  #   p batch.outputs
  # end

  # it "pairs" do
  #   batch = GptFunction::Batch.from_id("batch_eCRAXbbU68r0hkfrldPaXHIT")
  #   p batch.pairs
  # end

  # it "cancel" do
  #   batch_ids = [
  #     "batch_1BUdy9JLQCDEhQsKZeIVsHe5",
  #   ]

  #   batchs = batch_ids.map do |batch_id|
  #     GptFunction::Batch.from_id(batch_id)
  #   end

  #   batchs.each do |batch|
  #     response = batch.cancel
  #     p response
  #   end
  # end
end
