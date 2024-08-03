# frozen_string_literal: true

require "net/http"
require "json"

class GptFunction
  class File
    attr_reader :object
    attr_reader :id
    attr_reader :purpose
    attr_reader :filename
    attr_reader :bytes
    attr_reader :created_at
    attr_reader :status
    attr_reader :status_details

    def initialize(hash)
      @object = hash["object"]
      @id = hash["id"]
      @purpose = hash["purpose"]
      @filename = hash["filename"]
      @bytes = hash["bytes"]
      @created_at = hash["created_at"]
      @status = hash["status"]
      @status_details = hash["status_details"]
    end

    def to_hash
      {
        object: object,
        id: id,
        purpose: purpose,
        filename: filename,
        bytes: bytes,
        created_at: created_at,
        status: status,
        status_details: status_details,
      }
    end

    def content
      File.content(id)
    end

    def jsonl
      File.jsonl(id)
    end

    def delete
      File.delete(id)
    end

    def to_s
      to_hash.to_json
    end

    def inspect
      to_hash.to_json
    end

    class << self
      def list
        uri = URI("https://api.openai.com/v1/files")
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{GptFunction.api_key}"

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        raise "File retrieval failed: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        # example response body
        # {
        #   "object": "list",
        #   "data": [
        #     {
        #       "object": "file",
        #       "id": "file-uYu4HIFAoq0OeZDGBD5Ci8wL",
        #       "purpose": "batch_output",
        #       "filename": "batch_YMZbhJWcBYETMTfOfEf041qF_output.jsonl",
        #       "bytes": 1934,
        #       "created_at": 1722327874,
        #       "status": "processed",
        #       "status_details": null
        #     },
        #     {
        #       "object": "file",
        #       "id": "file-5AW0tCvRFKomu5s5G90yfWhs",
        #       "purpose": "batch",
        #       "filename": "batchinput.jsonl",
        #       "bytes": 728,
        #       "created_at": 1722327858,
        #       "status": "processed",
        #       "status_details": null
        #     },
        #   ]
        # }
        body_hash = JSON.parse(response.body)
        body_hash.dig("data").map do |hash|
          File.new(hash)
        end
      end

      def create(hash_array)
        # 將請求資料轉換為 JSONL 格式的字串
        jsonl = hash_array.map(&:to_json).join("\n")

        # 上傳資料
        uri = URI('https://api.openai.com/v1/files')
        request = Net::HTTP::Post.new(uri)
        request['Authorization'] = "Bearer #{GptFunction.api_key}"
        request['Content-Type'] = 'multipart/form-data'

        # 創建 multipart form data
        boundary = "CustomBoundary"
        post_body = []
        post_body << "--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"purpose\"\r\n\r\n"
        post_body << "batch\r\n"
        post_body << "--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"batchinput.jsonl\"\r\n"
        post_body << "Content-Type: application/json\r\n\r\n"
        post_body << jsonl
        post_body << "\r\n--#{boundary}--\r\n"

        request.body = post_body.join
        request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        raise "File upload failed: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        hash = JSON.parse(response.body)
        File.new(hash)
      end

      def from_id(file_id)
        uri = URI("https://api.openai.com/v1/files/#{file_id}")
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{GptFunction.api_key}"

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        raise "File retrieval failed: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        hash = JSON.parse(response.body)
        File.new(hash)
      end

      def content(file_id)
        uri = URI("https://api.openai.com/v1/files/#{file_id}/content")
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{GptFunction.api_key}"

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        # {
        #   "error": {
        #     "message": "No such File object: #{file_id}",
        #     "type": "invalid_request_error",
        #     "param": "id",
        #     "code": null
        #   }
        # }
        raise "File retrieval failed: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
        response.body
      end

      def jsonl(file_id)
        content(file_id).split("\n").map { |line| JSON.parse(line) }
      end

      def delete(file_id)
        uri = URI("https://api.openai.com/v1/files/#{file_id}")
        request = Net::HTTP::Delete.new(uri)
        request['Authorization'] = "Bearer #{GptFunction.api_key}"

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

      #   {
      #    "error": {
      #      "message": "No such File object: file-5m1Cn4M36GOfd7bEVAoTCmcC",
      #      "type": "invalid_request_error",
      #      "param": "id",
      #      "code": null
      #    }
      #  }
        raise "File deletion failed: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        # {"object"=>"file", "deleted"=>true, "id"=>"file-vsCH6lJkiFzi6gF9B8un3ZLT"}
        JSON.parse(response.body)
      end
    end
  end
end
