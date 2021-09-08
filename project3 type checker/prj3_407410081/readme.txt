Project 3
Readme:
我將所有檔案打包成一個資料夾 以下動作都要在資料夾內執行 以便不用改class path 
1.一開始使用此指令吃org.antlr.Tool myChecker.g檔 myCheckerLexer.java myCheckerParser.java myChecker.token
java -cp ./antlr-3.5.2-complete-no-st3.jar org.antlr.Tool myChecker.g

2.然後使用以下指令編譯myChecker_test.java myCheckerLexer.java myCheckerParser.java(myChecker_test.java這個檔是用來吃c檔然後吐出結果)產生class檔
	javac -cp ./antlr-3.5.2-complete-no-st3.jar myChecker_test.java myCheckerLexer.java myCheckerParser.java

3.編譯完最後執行testParser 並且吃一個.c檔作為input即可完成parser輸出
java -cp ./antlr-3.5.2-complete-no-st3.jar:. myChecker_test input.c  

make會做完編譯的動作(也就是1 2) 之後第3個步驟請打以上(java -cp ./antlr-3.5.2-complete-no-st3.jar:. myChecker_test input.c )指令並更改c檔即可
make clean會將編譯時產生的java token class檔都清除




我的三個檔案:
input1是測試最簡單的重複宣告以及測試變數使用前要先宣告,以及printf的參數要宣告 而沒有宣告的變數我會印出來 跑出的訊息如下 括號為講解錯誤原因：
Error: 4: Redeclared identifier.(a重複宣告 )
Error: 8: Redeclared identifier.(b重複宣告 )
Error: 9: Redeclared identifier.(c重複宣告 )
Error: 10: Undefined identifier : h (h沒有宣告就使用)
Error: 11: Undefined identifier : i (printf 的參數i沒有宣告就使用)
Error: 11: Undefined identifier : j (printf 的參數j沒有宣告就使用)
Error: 11: Undefined identifier : k (printf 的參數k沒有宣告就使用)

input2是測試初始值的type的type必須相同以及運算子跟兩邊運算元的type必須相同 跑出的訊息如下 括號為講解錯誤原因：
Error: 7: Undefined identifier : e(e沒有宣告就使用)
Error: 7: Undefined identifier : r(r沒有宣告就使用)
Error: 8: Type mismatch for the arithmetic operator  in an expression. (初始值a為int 但做浮點數除法)
Error: 8: Redeclared identifier. (b重複宣告 )
Error: 9: Undefined identifier : r(初始值r沒有宣告)
Error: 10: Type mismatch for the operator assignment in an expression.( 初始值b * a為int 但d為浮點數)
Error: 11: Undefined identifier : t(t沒有宣告就使用)
Error: 13: Undefined identifier : k(k沒有宣告就使用)
Error: 14: Type mismatch for the arithmetic operator in an expression. ( arithmetic operator '*'兩邊的type不同 a為int d為double)
Error: 15: Type mismatch for the arithmetic operator in an expression. ( arithmetic operator '-'兩邊的type不同 a為int c為float)
Error: 15: Undefined identifier : r(r沒有宣告就使用)
Error: 16: Type mismatch for the assignment operator in an expression.(assignment operator '/='兩邊的type不同 b為unsigned int d為double)


input3是測試 if else while for switch do while等條件語句裡面可以放的expression 而我遵守c的規範 裡面放變數或算術運算或比較運算都可以(type == bool) 比如if(a) ,if(a+b),if(a<b)... 會出錯的語句為賦值運算式 例如if(a=b),if(a=a+b) (type != bool)跑出的訊息如下 括號為講解錯誤原因：
Error: 20: Type mismatch for the assignment operator in an expression. (f1為浮點數 無法做整數除法)
Error: 18: Type of the expression isn't boolean (if裡面放了非bool的條件運算)
Error: 30: Type mismatch for the comparison operator in an expression.(test1為整數 無法做浮點數的比較)
Error: 31: Type mismatch for the assignment operator in an expression.(test1為整數 無法做浮點數的運算)
Error: 31: Type of the expression isn't boolean (while裡面放了非bool的條件運算)
Error: 39: Type of the expression isn't boolean (for裡面的條件放了非bool的條件運算)
Error: 45: Type of the expression isn't boolean (do while裡面放了非bool的條件運算)
Error: 47: Undefined identifier : r(r沒有宣告就使用)
Error: 47: Type of the expression isn't boolean(switch裡面放了非bool的條件運算)


註:1.檔案裡面都有註解哪個地方是在測試什麼東西
   2.若測資為a = a + b 且b沒有宣告 則只會出現 Undefined identifier : b 不會出現兩邊運算type不同
   3.attr_type>0為正常type種類 若=-2代表運算元兩邊運算子type不同 若=-3代表變數未宣告
   4.錯誤訊息 Type mismatch for the "arithmetic| assignment| comparison" in an expression 
(這裡我有三種錯誤 如果是算術運算子兩邊出錯 則是arithmetic 如果是賦值運算子兩邊出錯 則是assignment 如果是比較運算子兩邊出錯 則是comparison)



PS:c_subet我交了odt檔及docx檔兩種版本 都是MS 內容都一樣 只是怕其中一種會打不開 謝謝助教

