# lib/gpt_function/batch.rb
# frozen_string_literal: true

require "net/http"
require "json"
require "byebug"

class GptFunction
  class Batch
    attr_reader :id
    attr_reader :object
    attr_reader :endpoint
    attr_reader :errors
    attr_reader :input_file_id
    attr_reader :completion_window
    attr_reader :status
    attr_reader :output_file_id
    attr_reader :error_file_id
    attr_reader :created_at
    attr_reader :in_progress_at
    attr_reader :expires_at
    attr_reader :finalizing_at
    attr_reader :completed_at
    attr_reader :failed_at
    attr_reader :expired_at
    attr_reader :cancelling_at
    attr_reader :cancelled_at

    attr_reader :request_counts_total
    attr_reader :request_counts_completed
    attr_reader :request_counts_failed

    attr_reader :metadata_customer_id
    attr_reader :metadata_batch_description

    def initialize(hash)
      @id = hash["id"]
      @object = hash["object"]
      @endpoint = hash["endpoint"]
      @errors = hash["errors"]
      @input_file_id = hash["input_file_id"]
      @completion_window = hash["completion_window"]
      @status = hash["status"]
      @output_file_id = hash["output_file_id"]
      @error_file_id = hash["error_file_id"]
      @created_at = hash["created_at"]
      @in_progress_at = hash["in_progress_at"]
      @expires_at = hash["expires_at"]
      @finalizing_at = hash["finalizing_at"]
      @completed_at = hash["completed_at"]
      @failed_at = hash["failed_at"]
      @expired_at = hash["expired_at"]
      @cancelling_at = hash["cancelling_at"]
      @cancelled_at = hash["cancelled_at"]

      @request_counts_total = hash.dig("request_counts", "total")
      @request_counts_completed = hash.dig("request_counts", "completed")
      @request_counts_failed = hash.dig("request_counts", "failed")

      @metadata_customer_id = hash.dig("metadata", "customer_id")
      @metadata_batch_description = hash.dig("metadata", "batch_description")
    end

    def to_hash
      {
        id: id,
        object: object,
        endpoint: endpoint,
        errors: errors,
        input_file_id: input_file_id,
        completion_window: completion_window,
        status: status,
        output_file_id: output_file_id,
        error_file_id: error_file_id,
        created_at: created_at,
        in_progress_at: in_progress_at,
        expires_at: expires_at,
        finalizing_at: finalizing_at,
        completed_at: completed_at,
        failed_at: failed_at,
        expired_at: expired_at,
        cancelling_at: cancelling_at,
        cancelled_at: cancelled_at,
        request_counts_total: request_counts_total,
        request_counts_completed: request_counts_completed,
        request_counts_failed: request_counts_failed,
        metadata_customer_id: metadata_customer_id,
        metadata_batch_description: metadata_batch_description,
      }
    end

    def to_s
      to_hash.to_json
    end

    def inspect
      to_hash.to_json
    end

    def input_file
      @input_file ||= File.from_id(input_file_id)
    end

    def output_file
      @output_file ||= File.from_id(output_file_id)
    end

    def input_jsonl
      @input_jsonl ||= input_file.jsonl
    end

    def output_jsonl
      @output_jsonl ||= output_file.jsonl
    end

    def inputs
      @inputs ||= input_jsonl.map do |hash|
        {
          "custom_id" => hash.dig("custom_id"),
          "content" => hash.dig("body", "messages", -1, "content")
        }
      end
    end

    def outputs
      @outputs ||= output_jsonl.map do |hash|
        content = hash.dig("response", "body", "choices", 0, "message", "content")
        content = JSON.parse(content)["output"] rescue content
        {
          "custom_id" => hash.dig("custom_id"),
          "content" => content
        }
      end
    end

    def pairs
      hash = {}
      inputs.each do |input|
        hash[input["custom_id"]] = {
          "input" => input["content"],
        }
      end
      outputs.each do |output|
        hash[output["custom_id"]]["output"] = output["content"]
      end
      hash.values
    end

    def cancel
      Batch.cancel(id)
    end

    class << self
      def list(limit: 20, after: nil)
        # 創建批次請求
        uri = URI('https://api.openai.com/v1/batches')
        request = Net::HTTP::Get.new(uri, 'Content-Type' => 'application/json')
        request['Authorization'] = "Bearer #{GptFunction.api_key}"

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        raise "Batch creation failed: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        body_hash = JSON.parse(response.body)
        body_hash.dig("data").map do |hash|
          Batch.new(hash)
        end
      end

      def create(requests)
        requests = requests.each_with_index.map do |request, index|
          {
            custom_id: "request-#{index + 1}",
            method: "POST",
            url: "/v1/chat/completions",
            body: request,
          }
        end

        # 上傳資料
        file = File.create(requests)

        # 創建批次請求
        uri = URI('https://api.openai.com/v1/batches')
        request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        request['Authorization'] = "Bearer #{GptFunction.api_key}"
        request.body = {
          input_file_id: file.id,
          endpoint: '/v1/chat/completions',
          completion_window: '24h'
        }.to_json

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        raise "Batch creation failed: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        hash = JSON.parse(response.body)
        Batch.new(hash)
      rescue => e
        file&.delete
        raise e
      end

      def from_id(batch_id)
        # 檢查批次狀態
        uri = URI("https://api.openai.com/v1/batches/#{batch_id}")
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{GptFunction.api_key}"
        request['Content-Type'] = 'application/json'

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        raise "Batch status check failed: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        hash = JSON.parse(response.body)
        Batch.new(hash)
      end

      def cancel(batch_id)
        uri = URI("https://api.openai.com/v1/batches/#{batch_id}/cancel")
        request = Net::HTTP::Post.new(uri)
        request['Authorization'] = "Bearer #{GptFunction.api_key}"
        request['Content-Type'] = 'application/json'

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        # {
        #   "error": {
        #     "message": "Cannot cancel a batch with status 'completed'.",
        #     "type": "invalid_request_error",
        #     "param": null,
        #     "code": null
        #   }
        # }
        raise "Batch cancel failed: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        response.body
      end

    end
  end
end
