void main(){
    
   int a;
   int b;
   int c;
   int d;
   a = 5;
   b = 3;
   c = 0;
   for(a = 0;a < 5 ;a = a + 1){
	printf("The result of a  is %d\n",a );
	b = 1 + c;
        c = c + b;
        for(d = 0;d < 5 ;d = d + 1){
	     printf("The result of d  is %d\n",d );
	}
   }

   printf("The result of b is %d, c is %d\n",b ,c);
}
