# frozen_string_literal: true

require "net/http"
require "json"
require_relative "function/version"

module Gpt
  # 這是一個簡單的 GPT 函數類別
  class Function
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

    private

    def send_request(input)
      uri = URI.parse("https://api.openai.com/v1/chat/completions")
      request = Net::HTTP::Post.new(uri)
      request.content_type = "application/json"
      request["Authorization"] = "Bearer #{Function.api_key}"
      request.body = {
        model: Function.model,
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
      }.to_json

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
end
