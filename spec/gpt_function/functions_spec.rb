# frozen_string_literal: true

require "spec_helper"
# rubocop:disable Metrics/BlockLength
RSpec.describe GptFunctions do
  before do
    GptFunction.configure(api_key: ENV['API_KEY'], model: ENV["MODEL"])
  end

  context "when translating words" do
    # before do
    #   # 模擬 HTTP 請求和響應
    #   content = { output: "蘋果" }.to_json
    #   body = { choices: [{ message: { content: content } }] }.to_json
    #   stub_request(:post, "https://api.openai.com/v1/chat/completions").to_return(status: 200,
    #                                                                               body: body)
    # end

    it "translates English to Traditional Chinese correctly" do
      result = GptFunctions.翻譯成中文.call("apple")
      expect(result).to eq("蘋果")
    end
  end

  context "when extracting keywords" do
    # before do
    #   content = { output: %w[臺灣 5G網路 覆蓋率 智慧城市 亞洲] }.to_json
    #   body = { choices: [{ message: { content: content } }] }.to_json
    #   # 模擬 HTTP 請求和響應
    #   stub_request(:post, "https://api.openai.com/v1/chat/completions").to_return(status: 200,
    #                                                                               body: body)
    # end

    it "extracts keywords correctly" do
      result = GptFunctions.擷取關鍵字.call("臺灣最新5G網路覆蓋率達95%，推動智慧城市發展，領先亞洲多國")
      expect(result).to eq(["臺灣", "最新", "5G網路", "覆蓋率", "95%", "推動", "智慧城市", "發展", "領先", "亞洲", "多國"])
    end
  end
end
# rubocop:enable Metrics/BlockLength
