# frozen_string_literal: true

require "spec_helper"
# rubocop:disable Metrics/BlockLength
RSpec.describe GptFunction do
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
      translater = GptFunction.new("請翻譯成繁體中文", [%w[apple 蘋果]])
      result = translater.call("apple")
      expect(result).to eq("蘋果")
    end
  end

  context "when extracting keywords" do
    # before do
    #   content = { output: ["臺灣", "5G網路", "覆蓋率", "95%", "智慧城市", "發展", "領先", "亞洲", "多國"] }.to_json
    #   body = { choices: [{ message: { content: content } }] }.to_json
    #   # 模擬 HTTP 請求和響應
    #   stub_request(:post, "https://api.openai.com/v1/chat/completions").to_return(status: 200,
    #                                                                               body: body)
    # end

    it "extracts keywords correctly" do
      keywords_extractor = GptFunction.new("請擷取出所有關鍵字",
                                             [["臺灣最新5G網路覆蓋率達95%，推動智慧城市發展，領先亞洲多國", ["臺灣", "5G網路", "覆蓋率", "95%", "智慧城市", "發展", "領先", "亞洲", "多國"]]])
      result = keywords_extractor.call("臺灣最新5G網路覆蓋率達95%，推動智慧城市發展，領先亞洲多國")
      expect(result).to eq(["臺灣", "5G網路", "覆蓋率", "95%", "智慧城市", "發展", "領先", "亞洲", "多國"])
    end
  end
end
