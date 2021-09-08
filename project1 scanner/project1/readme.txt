Project 1 
Readme:
我將所有檔案打包成一個資料夾 以下動作都要在資料夾內執行 以便不用改class path 
1.一開始使用此指令吃org.antlr.Tool test1.g檔 產生test1.java test1.token
java -cp ./antlr-3.5.2-complete-no-st3.jar org.antlr.Tool test1.g 

2.然後使用以下指令編譯test1.java textLexer.java(textLexer.java這個檔是用來吃c檔然後吐出結果)產生class檔
javac -cp ./antlr-3.5.2-complete-no-st3.jar  textLexer.java test1.java  

3.編譯完最後執行textLexer 並且吃一個.c檔作為input即可完成scanner輸出
java -cp ./antlr-3.5.2-complete-no-st3.jar:. textLexer input.c  

make會做完編譯的動作(也就是1 2) 之後第3個步驟請打以上(java -cp ./antlr-3.5.2-complete-no-st3.jar:. textLexer input.c)指令並更改c檔即可
make clean會將編譯產生的java token class檔都清除

我的三個檔案
input1是測試一些整數 浮點數 八進位 十進位 十六進位 以及hello world字串和幾個邏輯運算子(沒有測全部 因為可以切個某個久可以切割其他的)
input2是link list的reverse 主要測試一些指標的token及其他id的切割
input3是 rw-spinlock 是與thread有關的操作 這個檔案有很多函式也是最長最複雜的的 主要用意是測試我的scanner對比較正式的程式也能正常切割(裡面有許多keyword及運算子)

PS:c_subet我交了odt檔及docx檔兩種版本 都是MS 內容都一樣 只是怕其中一種會打不開 謝謝助教

