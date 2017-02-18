# OAuth
Twitterで呟くやつです

準備
1. Twitterからconsumer_keyとconsumer_secretを取得する


2. my_key.rbの各要素に、それぞれconsumer_key, consumer_key_secret, oauth_token, oauth_token_secretを入れる

   my_key.rbの内容
    KEYS = {
      consumer_key: "",
      consumer_secret: "",
    }
    TOKENS = {
      token: "",
      token_secret: "",
    }

3. http.rbのstatus: の値をツイートしたい内容に書き換える

実行
$ ruby http.rb
