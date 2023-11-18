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
      content = { output: [
        "藍白", "3%", "翻臉", "倒數", "學者", "關鍵指標"
      ] }.to_json
      body = { choices: [{ message: { content: content } }] }.to_json
      # 模擬 HTTP 請求和響應
      stub_request(:post, "https://api.openai.com/v1/chat/completions").to_return(status: 200,
                                                                                  body: body)
    end

    it "extracts keywords correctly" do
      keywords_extractor = Gpt::Function.new("請擷取出所有關鍵字",
                                             [["藍白合「難產」！游盈隆認定「平手」 稱解套辦法就是「再做一次民調」", %w[藍白合 難產 游盈隆 解套 民調]]])
      result = keywords_extractor.call("藍白「3％各表」翻臉倒數？學者曝1關鍵指標")
      expect(result).to eq(["藍白", "3%", "翻臉", "倒數", "學者", "關鍵指標"])
    end
  end
end
# rubocop:enable Metrics/BlockLength
