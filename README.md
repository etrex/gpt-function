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

# 使用內建的翻譯方法
p Gpt::Functions.翻譯成中文("banana") # "香蕉"

# 使用內建的擷取關鍵字方法
p Gpt::Functions.擷取關鍵字("臺北市政府推動綠色交通計劃，鼓勵民眾使用公共運輸和自行車")  # ["臺北市政府", "綠色交通計劃", "民眾", "公共運輸", "自行車"]

# 你也可以自己定義方法
def 擷取關鍵字(input)
  # 創建一個簡單的 GPT 函數，你需要描述這個函數的功能，以及提供一些範例
  Gpt::Function.new("Extract all keywords",
  [
    [
      "臺灣最新5G網路覆蓋率達95%，推動智慧城市發展，領先亞洲多國",
      ["臺灣", "5G網路", "覆蓋率", "智慧城市", "亞洲"]
    ]
  ]).call(input)
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
