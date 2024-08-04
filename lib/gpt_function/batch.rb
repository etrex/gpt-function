# frozen_string_literal: true

require "net/http"
require "json"

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

    attr_reader :metadata

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

      @metadata = hash.dig("metadata")
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
        metadata: metadata
      }
    end

    def to_s
      to_hash.to_json
    end

    def inspect
      to_hash.to_json
    end

    def input_file
      return nil if input_file_id.nil?
      @input_file ||= File.from_id(input_file_id)
    end

    def output_file
      return nil if output_file_id.nil?
      @output_file ||= File.from_id(output_file_id)
    end

    def error_file
      return nil if error_file_id.nil?
      @error_file ||= File.from_id(error_file_id)
    end

    def input_jsonl
      @input_jsonl ||= input_file&.jsonl || []
    end

    def output_jsonl
      @output_jsonl ||= output_file&.jsonl || []
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

      outputs.each do |output|
        hash[output["custom_id"]] = [nil ,output["content"]]
      end

      inputs.each do |input|
        next if hash[input["custom_id"]].nil?
        hash[input["custom_id"]][0] = input["content"]
      end

      hash.values
    end

    def cancel
      Batch.cancel(id)
    end

    def enqueue
      return false if GptFunction::Storage.batch_storage.nil?

      GptFunction::Storage.batch_storage.enqueue(self.to_hash)
    end

    # validating	the input file is being validated before the batch can begin
    # failed	the input file has failed the validation process
    # in_progress	the input file was successfully validated and the batch is currently being run
    # finalizing	the batch has completed and the results are being prepared
    # completed	the batch has been completed and the results are ready
    # expired	the batch was not able to be completed within the 24-hour time window
    # cancelling	the batch is being cancelled (may take up to 10 minutes)
    # cancelled	the batch was cancelled
    def is_processed
      ["failed", "completed", "expired", "cancelled"].include? status
    end

    def auto_delete
      metadata&.dig("auto_delete") == "true"
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

      def create(requests, metadata: nil)
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
        body = {
          input_file_id: file.id,
          endpoint: '/v1/chat/completions',
          completion_window: '24h'
        }
        body[:metadata] = metadata unless metadata.nil?
        request.body = body.to_json

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        raise "Batch creation failed: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        hash = JSON.parse(response.body)
        batch = Batch.new(hash)
        batch.enqueue
        batch
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

      def dequeue
        hash = GptFunction::Storage.batch_storage&.dequeue
        id = hash&.dig("id") || hash&.dig(:id)
        from_id(id) if id
      end

      # 進行批次請求處理
      # count: 處理批次請求的數量
      # block: 處理批次請求的 block
      # 返回值: 是否還有批次請求需要處理
      def process(count: 1, &block)
        # 從 Storage 取出 count 個批次請求
        count.times do
          batch = dequeue

          # 如果沒有批次請求，則跳出迴圈
          return false if batch.nil?

          yield batch

          # 如果 batch 還未處理完成，將批次請求重新加入 Storage
          if batch.is_processed && batch.auto_delete
            batch&.input_file&.delete rescue nil
            batch&.output_file&.delete rescue nil
            batch&.error_file&.delete rescue nil
          else
            batch.enqueue
          end
        end

        true
      end
    end
  end
end
