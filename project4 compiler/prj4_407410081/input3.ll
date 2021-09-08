; === prologue ====
declare dso_local i32 @printf(i8*, ...)
@.str. = private unnamed_addr constant [24 x i8]c"The result of a  is %d\0A\00", align 1
@.str.1 = private unnamed_addr constant [24 x i8]c"The result of d  is %d\0A\00", align 1
@.str.2 = private unnamed_addr constant [32 x i8]c"The result of b is %d, c is %d\0A\00", align 1
define dso_local i32 @main()
{
	%t0 = alloca i32, align 4
	%t1 = alloca i32, align 4
	%t2 = alloca i32, align 4
	%t3 = alloca i32, align 4
	store i32 5, i32* %t3, align 4
	store i32 3, i32* %t2, align 4
	store i32 0, i32* %t1, align 4
	store i32 0, i32* %t3, align 4
	br label %L2

L2:
	%t4 = load i32, i32* %t3, align 4
	%cond0 = icmp slt i32 %t4, 5
	br i1 %cond0, label %L3, label %L4

L1:
	%t5 = load i32, i32* %t3, align 4
	%t6 = add nsw i32 %t5, 1
	store i32 %t6, i32* %t3, align 4
	br label%L2

L3:
	%t7 = load i32, i32* %t3, align 4
	%t8 = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.,i64 0, i64 0), i32 %t7)
	%t9 = load i32, i32* %t1, align 4
	%t10 = add nsw i32 1, %t9
	store i32 %t10, i32* %t2, align 4
	%t11 = load i32, i32* %t1, align 4
	%t12 = load i32, i32* %t2, align 4
	%t13 = add nsw i32 %t11, %t12
	store i32 %t13, i32* %t1, align 4
	store i32 0, i32* %t0, align 4
	br label %L6

L6:
	%t14 = load i32, i32* %t0, align 4
	%cond1 = icmp slt i32 %t14, 5
	br i1 %cond1, label %L7, label %L8

L5:
	%t15 = load i32, i32* %t0, align 4
	%t16 = add nsw i32 %t15, 1
	store i32 %t16, i32* %t0, align 4
	br label%L6

L7:
	%t17 = load i32, i32* %t0, align 4
	%t18 = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1,i64 0, i64 0), i32 %t17)
	br label %L5

L8:
	br label %L1

L4:
	%t19 = load i32, i32* %t2, align 4
	%t20 = load i32, i32* %t1, align 4
	%t21 = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([32 x i8], [32 x i8]* @.str.2,i64 0, i64 0), i32 %t19, i32 %t20)

; === epilogue ===
	ret i32 0
}
