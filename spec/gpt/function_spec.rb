# frozen_string_literal: true

require "spec_helper"
# rubocop:disable Metrics/BlockLength
RSpec.describe Gpt::Function do
  before do
    Gpt::Function.configure(api_key: "...", model: "gpt-3.5-turbo-1106")
  end

  context "when translating words" do
    before do
      # 模擬 HTTP 請求和響應
      content = { output: "蘋果" }.to_json
      body = { choices: [{ message: { content: content } }] }.to_json
      stub_request(:post, "https://api.openai.com/v1/chat/completions").to_return(status: 200,
                                                                                  body: body)
    end

    it "translates English to Traditional Chinese correctly" do
      translater = Gpt::Function.new("請翻譯成繁體中文", [%w[apple 蘋果]])
      result = translater.call("apple")
      expect(result).to eq("蘋果")
    end
  end

  context "when extracting keywords" do
    before do
      content = { output: %w[臺灣 5G網路 覆蓋率 智慧城市 亞洲] }.to_json
      body = { choices: [{ message: { content: content } }] }.to_json
      # 模擬 HTTP 請求和響應
      stub_request(:post, "https://api.openai.com/v1/chat/completions").to_return(status: 200,
                                                                                  body: body)
    end

    it "extracts keywords correctly" do
      keywords_extractor = Gpt::Function.new("請擷取出所有關鍵字",
                                             [["臺灣最新5G網路覆蓋率達95%，推動智慧城市發展，領先亞洲多國", %w[臺灣 5G網路 覆蓋率 智慧城市 亞洲]]])
      result = keywords_extractor.call("臺灣最新5G網路覆蓋率達95%，推動智慧城市發展，領先亞洲多國")
      expect(result).to eq(%w[臺灣 5G網路 覆蓋率 智慧城市 亞洲])
    end
  end
end
# rubocop:enable Metrics/BlockLength
