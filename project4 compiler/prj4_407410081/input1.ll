; === prologue ====
declare dso_local i32 @printf(i8*, ...)
@.str. = private unnamed_addr constant [14 x i8]c"Hello World!\0A\00", align 1
@.str.1 = private unnamed_addr constant [23 x i8]c"the result of a is %d\0A\00", align 1
@.str.2 = private unnamed_addr constant [41 x i8]c"the result of b is %d ,c is %f, d is %f\0A\00", align 1
define dso_local i32 @main()
{
	%t0 = alloca i8
	%t1 = alloca float, align 4
	%t2 = alloca float, align 4
	%t3 = alloca i32, align 4
	%t4 = alloca i32, align 4
	store i32 3, i32* %t3, align 4
	%t5 = load i32, i32* %t3, align 4
	%t6 = srem i32 %t5, 2
	store i32 %t6, i32* %t4, align 4
	%t7 = load i32, i32* %t3, align 4
	%t8 = sub i32 100, 1
	%t9 = mul nsw i32 2, %t8
	%t10 = add nsw i32 %t7, %t9
	store i32 %t10, i32* %t4, align 4
	store float 0x4016000000000000, float* %t2, align 4
	store float 0x4022ccccc0000000, float* %t1, align 4
	%t11 = load float, float* %t1, align 4
	%t12 = load float, float* %t2, align 4
	%t13 = fdiv float %t11, %t12
	%t14 = fmul float %t13, 0x3ff3333340000000
	store float %t14, float* %t1, align 4
	%t15 = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.,i64 0, i64 0))
	%t16 = load i32, i32* %t4, align 4
	%t17 = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.1,i64 0, i64 0), i32 %t16)
	%t18 = load i32, i32* %t3, align 4
	%t19 = load float, float* %t2, align 4
	%t20 = fpext float %t19 to double
	%t21 = load float, float* %t1, align 4
	%t22 = fpext float %t21 to double
	%t23 = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([41 x i8], [41 x i8]* @.str.2,i64 0, i64 0), i32 %t18, double %t20, double %t22)

; === epilogue ===
	ret i32 0
}
