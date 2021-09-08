#include<stdio.h>
#include<math.h>
#include <string.h>
#include <stdlib.h>
typedef struct list *pointer;
typedef struct list{
    int data;
    pointer link;
};
int main()
{
    pointer first,FIRST_1;
    first=malloc(sizeof(*first));
    FIRST_1=malloc(sizeof(*FIRST_1));
    int k;
    pointer finder;
    finder=malloc(sizeof(*finder));
    finder->link=NULL;
    int j=0;
    while(scanf("%d",&k)!=EOF)
    {
        pointer temp;
        temp=malloc(sizeof(*temp));
        temp->data=k;
        temp->link=finder->link;
        finder->link=temp;
        finder=temp;
        if(j==0)
            {
                first=temp;
                FIRST_1=temp;
                j++;
            }
    }
    pointer middle ,trail;
    middle=malloc(sizeof(*middle));
    trail=malloc(sizeof(*trail));
    middle=NULL;

    while(first)
    {
        trail=middle;
        middle=first;
        first=first->link;
        middle->link=trail;
    }
    while(middle!=NULL)
    {
        if(middle->link==NULL)
            printf("%d\n",middle->data);
        else
            printf("%d ",middle->data);

        middle=middle->link;
    }


