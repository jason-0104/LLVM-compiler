Project 4
Readme:
我將所有檔案打包成一個資料夾 以下動作都要在資料夾內執行 以便不用改class path 
1.一開始使用此指令吃org.antlr.Tool myCompiler.g檔 myCompilerLexer.java myCompilerParser.java myCompiler.token
	java -cp ./antlr-3.5.2-complete-no-st3.jar org.antlr.Tool myCompiler.g

2.然後使用以下指令編譯myCompiler_test.java myCompilerLexer.java myCompilerParser.java myCompiler_test.java這個檔是用來吃c檔然後吐出結果)產生class檔
	javac -cp ./antlr-3.5.2-complete-no-st3.jar myCompiler_test.java myCompilerLexer.java myCompilerParser.java

3.編譯完最後執行myCompiler_test 並且吃一個.c檔作為input即可看到輸出的llvm程式碼   若要輸出.ll檔 請在原本指令後面加入括號的指令(已經有附上)
	java -cp ./antlr-3.5.2-complete-no-st3.jar:. myCompiler_test input.c  (> input.ll)

4.可以用lli input.ll檔檢查結果與輸出是否正確(若有輸出ll檔再做這個步驟即可) 
	
make會做完編譯的動作(也就是1 2) 之後第3 個步驟請打以上(java -cp ./antlr-3.5.2-complete-no-st3.jar:. myCompiler_test input.c)指令並更改c檔即可(第四個步驟也是)
make clean會將編譯時產生的java token class檔 以及執行產生的ll檔都清除




我的三個檔案:
input1是測試基本宣告與運算(運算結果會列印)與printf 1與多參數的 function (浮點數的部份我利用老師教的十六進位轉換函式 所以可以使用任何浮點數)
input2是測試if else statement(會印出結果確認)
input3是測試for loop的單與雙迴圈使用(會做運算並會印出結果確認)


PS:c_subet我交了odt檔及docx檔兩種版本 都是MS 內容都一樣 只是怕其中一種會打不開 謝謝助教

