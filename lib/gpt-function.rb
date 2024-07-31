# frozen_string_literal: true

require "net/http"
require "json"

require_relative "gpt_function/version"
require_relative "gpt_function/file"
require_relative "gpt_function/batch"
require_relative "gpt_functions"

class GptFunction
  class Error < StandardError; end

  @api_key = nil
  @model = nil

  class << self
    attr_accessor :api_key, :model

    def configure(api_key:, model:)
      @api_key = api_key
      @model = model
    end
  end

  def initialize(prompt, examples = [], temperature = 0)
    @temperature = temperature
    @messages = [
      {
        role: "system",
        content: "#{prompt}\n Note: The response format is always a JSON with the key output like this:{output: ...}"
      },
      *examples.flat_map do |example|
        [
          {
            role: "user",
            content: example[0]
          },
          {
            role: "assistant",
            content: { output: example[1] }.to_json
          }
        ]
      end
    ]
  end

  def call(input)
    # 使用類別級別的變量來發送請求
    response = send_request(input)
    body = response.body.force_encoding("UTF-8")
    json = JSON.parse(body)
    # 處理可能的錯誤回應
    raise StandardError, json.dig("error", "message") if json.dig("error", "code")

    # 處理正常的回應
    JSON.parse(json.dig("choices", 0, "message", "content"))["output"]
  end

  def to_request_body(input)
    {
      model: GptFunction.model,
      response_format: {
        type: "json_object"
      },
      seed: 0,
      messages: [
        *@messages,
        {
          "role": "user",
          "content": input
        }
      ],
      temperature: @temperature
    }
  end

  def batch(inputs, post_processor_class)
    file_content = inputs.map.with_index do |input, index|
      {
        "custom_id": "request-#{index + 1}",
        "method": "POST",
        "url": "/v1/chat/completions",
        "body": to_request_body(input)
      }
    end

    batch_instance = Batch.new(Function.api_key)
    batch_id = batch_instance.request(file_content)
    puts "Batch created with ID: #{batch_id}"

    # 創建 BatchRequest 並啟動 ProcessBatchJob
    batch_request = BatchRequest.create(
      batch_id: batch_id,
      status: 'created',
      total_request_counts: inputs.size,
      completed_request_counts: 0,
      post_processor_class: post_processor_class.to_s
    )
    ProcessBatchJob.perform_later(batch_request.id)
  end

  private

  def send_request(input)
    uri = URI.parse("https://api.openai.com/v1/chat/completions")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{Function.api_key}"
    request.body = to_request_body(input).to_json

    req_options = {
      use_ssl: uri.scheme == "https",
      open_timeout: 60, # opening a connection timeout
      read_timeout: 300 # reading one block of response timeout
    }

    Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end
end
