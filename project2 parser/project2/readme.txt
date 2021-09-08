Project 2
Readme:
我將所有檔案打包成一個資料夾 以下動作都要在資料夾內執行 以便不用改class path 
1.一開始使用此指令吃org.antlr.Tool myparser.g檔 產生myparserLexer.java myparserParser.java myparser.token
java -cp ./antlr-3.5.2-complete-no-st3.jar org.antlr.Tool myparser.g

2.然後使用以下指令編譯testParser.java myparserLexer.java myparserParser.java(testParser.java這個檔是用來吃c檔然後吐出結果)產生class檔
javac -cp ./antlr-3.5.2-complete-no-st3.jar testParser.java myparserLexer.java myparserParser.java

3.編譯完最後執行testParser 並且吃一個.c檔作為input即可完成parser輸出
java -cp ./antlr-3.5.2-complete-no-st3.jar:. testParser input.c  

make會做完編譯的動作(也就是1 2) 之後第3個步驟請打以上(java -cp ./antlr-3.5.2-complete-no-st3.jar:. testParser input.c )指令並更改c檔即可
make clean會將編譯時產生的java token class檔都清除


我的三個檔案:
input1是測試一些基本宣告(int ,char,float,double,signed,unsigned,long,short,void),以及變數的初始化,還有陣列及指標的宣告,
typedef struct union enum的宣告,最後測試指標連結(->)以及結構物件(.)的功能

input2是測試標頭檔,函式的宣告,(包括有無參數或是函數只是單純宣告或是有實做),進入main後測試函式呼叫,for 迴圈,巢狀迴圈與while迴圈,
以及do while的功能,還有一些jump功能(比如 break continue return )

input3是測試條件 比如邏輯運算子與條件運算子以及稍微複雜的算術運算,if else的語句  ,printf語句,最後測試switch case default

註:檔案裡面都有註解哪個地方是在測試什麼東西

測試時有時會印出一些能辨別是否是對的的資訊 比如type或變數內容或header if while之類的等等,(接近terminal的地方),但有些有優先順序的或結構複雜跟比較上層的rule我就沒有印,
因為會一直重複印出許多不必要的,比如有優先順序的邏輯運算子, 像>的優先順序比＆＆高 ,如果我想印>,勢必就會印出＆＆,會重複印很多,或是declaration或statement這種比較上層的rule,
都會一直重複出現,所以這些我就沒有特別印,但通常只要執行沒有mismatch的話 基本上都是有符合我定的LL1 parse tree的 rule ,助教想確認可以到.g檔查看,
然後use header or not 這裡無論有沒有header都會印(因為是start symbol)

project 2感言:這次作業覺得蠻複雜而且蠻燒腦的,雖然有檔案可以參考,但基本上檔案很多部份是不符合LL(1)的結構,有許多時候可以選兩條路,以及有沒有適當使用 ? * + 等等的rule 造成錯誤而無法產生parser,
所以還是要自己花時間想清楚遞迴式的邏輯並親自實做。還有一點很重要就是有沒有亂用𝛆,如果稍微使用不慎就會造成無窮遞迴,其他還有一些地方像是terminal不能重複定義等等的小問題,都是讓我在這次作業花比較多時間處理的部份

PS:c_subet我交了odt檔及docx檔兩種版本 都是MS 內容都一樣 只是怕其中一種會打不開 謝謝助教

