void main(){
    
    //test for const ,long,int and variable declartion and initialize
    const long long int test1 ,test2 = 1;

    //test for  signed short  and array declartion
    signed int test3[100];
   
   //test for  static short and array declartion and initialize
    static short int test4[100] = {0};
    
    //test for  float
    float test5 = 1.11;

    //test for  volatile
    volatile int test6;

    //test for   unsigned ,char
    unsigned char test7;
    
    //test for typedef declartion 
    typedef struct test{
        double d;
        struct test *link;
    }test8;
    
    //test for struct declartion
    struct test j;
    
    //test for union declartion
    union test9{
        int m;
    };

    //test for enum declartion
    enum test10{Mon, Tue, Wed, Thur, Fri, Sat, Sun};

    //test for struct and pointer (linked-list)expression
    j.link->link->d = 0;
    
    

 }