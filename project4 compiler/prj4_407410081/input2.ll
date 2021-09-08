; === prologue ====
declare dso_local i32 @printf(i8*, ...)
@.str. = private unnamed_addr constant [20 x i8]c"c is bigger than d\0A\00", align 1
@.str.1 = private unnamed_addr constant [20 x i8]c"d is bigger than c\0A\00", align 1
define dso_local i32 @main()
{
	%t0 = alloca float, align 4
	%t1 = alloca float, align 4
	store float 0x4016000000000000, float* %t1, align 4
	store float 0x4022ccccc0000000, float* %t0, align 4
	%t2 = load float, float* %t0, align 4
	%t3 = load float, float* %t1, align 4
	%t4 = fdiv float %t2, %t3
	%t5 = fmul float %t4, 0x3ff3333340000000
	store float %t5, float* %t0, align 4
	%t6 = load float, float* %t1, align 4
	%t7 = load float, float* %t0, align 4
	%cond0 = fcmp ogt float %t6, %t7
	br i1 %cond0, label %L1, label %L2

L1:
	%t8 = load float, float* %t1, align 4
	%t9 = fadd float %t8, 0x3ff4ccccc0000000
	store float %t9, float* %t1, align 4
	%t10 = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str.,i64 0, i64 0))
	br label %L3

L2:
	%t11 = load float, float* %t0, align 4
	%t12 = fadd float %t11, 0x3ff4ccccc0000000
	store float %t12, float* %t0, align 4
	%t13 = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str.1,i64 0, i64 0))
	br label %L3

L3:

; === epilogue ===
	ret i32 0
}
