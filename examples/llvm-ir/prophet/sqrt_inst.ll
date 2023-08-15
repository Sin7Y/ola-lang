; ModuleID = 'SqrtContract'
source_filename = "examples/source/prophet/sqrt_inst.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define void @main() {
entry:
  %0 = call i64 @sqrt_test(i64 10000)
  ret void
}

define i64 @sqrt_test(i64 %0) {
entry:
  %i = alloca i64, align 8
  %x = alloca i64, align 8
  %result = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 %0, ptr %a, align 4
  store i64 0, ptr %result, align 4
  %1 = load i64, ptr %a, align 4
  %2 = icmp ugt i64 %1, 3
  br i1 %2, label %then, label %else

then:                                             ; preds = %entry
  %3 = load i64, ptr %a, align 4
  %4 = load i64, ptr %a, align 4
  %5 = call i64 @prophet_u32_mod(i64 %4, i64 2)
  call void @builtin_range_check(i64 %5)
  %6 = add i64 %5, 1
  %7 = sub i64 2, %6
  call void @builtin_range_check(i64 %7)
  %8 = call i64 @prophet_u32_div(i64 %4, i64 2)
  call void @builtin_range_check(i64 %8)
  %9 = mul i64 %8, 2
  %10 = add i64 %9, %5
  %11 = icmp eq i64 %10, %4
  %12 = zext i1 %11 to i64
  call void @builtin_assert(i64 %12)
  %13 = add i64 %8, 1
  call void @builtin_range_check(i64 %13)
  store i64 %13, ptr %x, align 4
  store i64 0, ptr %i, align 4
  br label %cond

else:                                             ; preds = %entry
  %14 = load i64, ptr %a, align 4
  %15 = icmp ne i64 %14, 0
  br i1 %15, label %then3, label %enif4

enif:                                             ; preds = %enif4, %endfor
  %16 = load i64, ptr %result, align 4
  ret i64 %16

cond:                                             ; preds = %next, %then
  %17 = load i64, ptr %i, align 4
  %18 = icmp ult i64 %17, 100
  br i1 %18, label %body, label %endfor

body:                                             ; preds = %cond
  %19 = load i64, ptr %x, align 4
  %20 = load i64, ptr %result, align 4
  %21 = icmp uge i64 %19, %20
  br i1 %21, label %then1, label %enif2

next:                                             ; preds = %enif2
  %22 = load i64, ptr %i, align 4
  %23 = add i64 %22, 1
  store i64 %23, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %then1, %cond
  br label %enif

then1:                                            ; preds = %body
  br label %endfor

enif2:                                            ; preds = %body
  %24 = load i64, ptr %x, align 4
  %25 = load i64, ptr %a, align 4
  %26 = load i64, ptr %x, align 4
  %27 = call i64 @prophet_u32_mod(i64 %25, i64 %26)
  call void @builtin_range_check(i64 %27)
  %28 = add i64 %27, 1
  %29 = sub i64 %26, %28
  call void @builtin_range_check(i64 %29)
  %30 = call i64 @prophet_u32_div(i64 %25, i64 %26)
  call void @builtin_range_check(i64 %30)
  %31 = mul i64 %30, %26
  %32 = add i64 %31, %27
  %33 = icmp eq i64 %32, %25
  %34 = zext i1 %33 to i64
  call void @builtin_assert(i64 %34)
  %35 = load i64, ptr %x, align 4
  %36 = add i64 %30, %35
  call void @builtin_range_check(i64 %36)
  %37 = call i64 @prophet_u32_mod(i64 %36, i64 2)
  call void @builtin_range_check(i64 %37)
  %38 = add i64 %37, 1
  %39 = sub i64 2, %38
  call void @builtin_range_check(i64 %39)
  %40 = call i64 @prophet_u32_div(i64 %36, i64 2)
  call void @builtin_range_check(i64 %40)
  %41 = mul i64 %40, 2
  %42 = add i64 %41, %37
  %43 = icmp eq i64 %42, %36
  %44 = zext i1 %43 to i64
  call void @builtin_assert(i64 %44)
  br label %next

then3:                                            ; preds = %else
  br label %enif4

enif4:                                            ; preds = %then3, %else
  br label %enif
}
