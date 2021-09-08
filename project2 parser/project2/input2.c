//test for header
#include<stdio.h>
#include<string.h>
//test for function with parameter
void A(char a,char b){
   return ;
}
//test for function with declaration and statement in it
int B(int a,int b){
    int i = 0;
    int a = 0;
    for(i = 0 ; i<= b ; i ++)
       a /= i;
   return a;
}
//test for function with no parameter and only declaration
void C();

/* main */
int main(){
   int result = 0;
   
   int i ;
   int b = 0;
   int y[10];
   int a ;
   
   //test for function call 
   memset(y);
   a = B(1,b);

   //test for  Arithmetic operation
   result  = result +1 +2 +3 +4 +5; 

   // test for for loop
   for(i = 0 ; i != 10 ; i += 1)
      result = i;
   
   // test for for loop + break
   for(i = 0 ; i<= 10 ; )
      break;

   // test for double(Nested) loop (for + while)
   for(i=0 ; i < 8 ; i += 1)
   {
      b = 2 ;
      while(b<10)
      {
         ++b; 
         if(b==i)
            continue;
         else if(b+i>6)
            break;

      }
   }
   //  test for do while 
   do { b = b + 1 ; }
       while(b<10) ;

   //  test for return
   return result;
}