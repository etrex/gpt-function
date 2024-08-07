# frozen_string_literal: true

# 這是一個簡單的 GPT 函數類別
module GptFunctions
  class << self
    def 翻譯成中文
      GptFunction.new("Translate into Taiwanese traditional Chinese", [%w[apple 蘋果]])
    end

    def 擷取關鍵字
      GptFunction.new("Extract all keywords",
        [
          [
            "臺灣最新5G網路覆蓋率達95%，推動智慧城市發展，領先亞洲多國",
            ["臺灣", "5G網路", "覆蓋率", "95%", "智慧城市", "發展", "領先", "亞洲", "多國"]
          ]
        ]
      )
    end

    def 擷取文章標題
      document = <<~DOCUMENT
        今日頭條
        科技日報｜臺灣科技業最新突破，AI技術大躍進
        科技日報
        科技日報
        2023-11-17
        102
        生活新聞｜臺北市最新公共交通計畫公開
        生活日報
        生活日報
        2023-11-16
        89
        健康專欄｜最新研究：日常運動對心臟健康的重要性
        健康雜誌
        健康雜誌
        2023-11-15
        76
        旅遊特輯｜探索臺灣東部的隱藏美食與景點
        旅遊週刊
        旅遊週刊
        2023-11-14
        65
      DOCUMENT

      keywords = [
        "科技日報｜臺灣科技業最新突破，AI技術大躍進",
        "生活新聞｜臺北市最新公共交通計畫公開",
        "健康專欄｜最新研究：日常運動對心臟健康的重要性",
        "旅遊特輯｜探索臺灣東部的隱藏美食與景點"
      ]

      GptFunction.new("Extract all titles", [[document, keywords]])
    end
  end
end
