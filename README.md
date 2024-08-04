# Gpt::Function

這個套件支援你在 Ruby 程式中使用 GPT 函數。

你可以確保每次呼叫 GPT 函數時，接近 100% 都會得到相同的結果。

目前能夠使用的模型有：

- gpt-4-1106-preview
- gpt-3.5-turbo-1106


## Installation

在你的 Gemfile 中加入下面這行：

```ruby
gem 'gpt-function'
```

就可以使用 `bundle install` 安裝這個套件。

## Usage

```ruby
# 在你的 Ruby 程式中引入 'gpt-function' Gem
require 'gpt-function'

# 你需要設定你的 api key 和 model name
GptFunction.configure(api_key: '...', model: 'gpt-4o-mini', batch_storage: MyBatchStorage)

# 使用內建的翻譯方法
p GptFunctions.翻譯成中文.call("banana") # "香蕉"

# 使用內建的擷取關鍵字方法
p GptFunctions.擷取關鍵字.call("臺北市政府推動綠色交通計劃，鼓勵民眾使用公共運輸和自行車")  # ["臺北市政府", "綠色交通計劃", "民眾", "公共運輸", "自行車"]

# 你也可以自己定義方法
def 擷取關鍵字
  # 創建一個簡單的 GPT 函數，你需要描述這個函數的功能，以及提供一些範例
  GptFunction.new("Extract all keywords",
  [
    [
      "臺灣最新5G網路覆蓋率達95%，推動智慧城市發展，領先亞洲多國",
      ["臺灣", "5G網路", "覆蓋率", "智慧城市", "亞洲"]
    ]
  ])
end
```

Batch Storage 是一個用來儲存 GPT 函數的結果的類別，你可以自己定義一個類似的類別，並且在 `GptFunction.configure` 中設定。

```ruby
class MyBatchStorage
  def initialize
    @queue = []
  end

  def enqueue(value)
    @queue << value
    true
  end

  def dequeue
    @queue.shift
  end
end

GptFunction.configure(api_key: '...', model: 'gpt-4o-mini', batch_storage: MyBatchStorage)
```

你可以用 Batch.create 建立一個新的 Batch, 在 create 成功時，會自動將 Batch 存入 BatchStorage 中。

```ruby
request1 = GptFunctions.翻譯成中文.to_request_body("apple")
request2 = GptFunctions.翻譯成中文.to_request_body("tesla")
batch = GptFunction::Batch.create([request1, request2])
```

你可以用 Batch.process 來處理 Batch，如果 Batch 的 status 在 "failed", "completed", "expired", "cancelled" 當中，Batch 會被從 queue 中移除，如果是其他狀態，Batch 會自動重新加入 queue 中，你只需要定期持續呼叫 process 就可以。

```ruby
GptFunction::Batch.process do |batch|
  puts "batch id: #{batch.id}, status: #{batch.status}, progress: #{batch.request_counts_completed}/#{batch.request_counts_total}"
  batch.pairs.each do |input, output|
    puts "input: #{input}, output: #{output}"
  end
end
```

可以用 count 參數來限制每次處理的數量，預設值為 1。

```ruby
GptFunction::Batch.process(count: 2) do |batch|
  ...
end
```

Batch Storage 整合 Active Record 的範例：

```ruby
class BatchStatus < ApplicationRecord
  class << self
    def enqueue(hash)
      model = BatchStatus.new
      model.batch_id = hash[:id]
      model.status = hash[:status]
      model.request_counts_completed = hash[:request_counts_completed]
      model.request_counts_failed = hash[:request_counts_failed]
      model.request_counts_total = hash[:request_counts_total]
      model.metadata = hash[:metadata]
      model.payload = hash
      model.save
      true
    end

    def dequeue
      model = first
      model.destroy
      model.payload
    end
  end
end


GptFunction.configure(api_key: '...', model: 'gpt-4o-mini', batch_storage: BatchStatus)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
