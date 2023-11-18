# Gpt::Function

這個套件支援你在 Ruby 程式中使用 GPT 函數。

你可以確保每次呼叫 GPT 函數時，都會得到相同的結果。

目前能夠使用的模型有：

- gpt-4-1106-preview
- gpt-3.5-turbo-1106


## Installation

...

## Usage

```ruby
# 在你的 Ruby 程式中引入 'gpt-function' Gem
require 'gpt-function'

# 你需要設定你的 api key 和 model name
Gpt::Function.configure(api_key: '...', model: 'gpt-3.5-turbo-1106')

# 創建一個簡單的 GPT 函數，你需要描述這個函數的功能，以及提供一些範例
translater = Gpt::Function.new("請翻譯成繁體中文", [["apple", "蘋果"]])

# 然後就可以使用這個函數了
result = translater.call("apple")

# 回傳的結果型別會參考範例的型別
puts result # "蘋果"

# 一個較複雜的 GPT 函數，用於擷取關鍵字
keywords_extractor = Gpt::Function.new("請擷取出所有關鍵字", [
    [
      "藍白合「難產」！游盈隆認定「平手」 稱解套辦法就是「再做一次民調」",
      ["藍白合", "難產", "游盈隆", "解套", "民調"]
    ]
  ]
)
result = keywords_extractor.call("藍白「3％各表」翻臉倒數？學者曝1關鍵指標")

# 可以看到回傳的型別是陣列
puts result # ["藍白", "3％各表", "翻臉", "關鍵指標"]
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
