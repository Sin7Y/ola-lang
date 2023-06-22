; ModuleID = 'SqrtContract'
source_filename = "examples/source/prophet/sqrt_inst.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

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
  call void @builtin_assert(i64 %10, i64 %4)
  %11 = add i64 %8, 1
  call void @builtin_range_check(i64 %11)
  store i64 %11, ptr %x, align 4
  store i64 0, ptr %i, align 4
  br label %cond

else:                                             ; preds = %entry
  %12 = load i64, ptr %a, align 4
  %13 = icmp ne i64 %12, 0
  br i1 %13, label %then3, label %enif4

enif:                                             ; preds = %enif4, %endfor
  %14 = load i64, ptr %result, align 4
  ret i64 %14

cond:                                             ; preds = %next, %then
  %15 = load i64, ptr %i, align 4
  %16 = icmp ult i64 %15, 100
  br i1 %16, label %body, label %endfor

body:                                             ; preds = %cond
  %17 = load i64, ptr %x, align 4
  %18 = load i64, ptr %result, align 4
  %19 = icmp uge i64 %17, %18
  br i1 %19, label %then1, label %enif2

next:                                             ; preds = %enif2
  %20 = load i64, ptr %i, align 4
  %21 = load i64, ptr %i, align 4
  %22 = add i64 %21, 1
  store i64 %22, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %then1, %cond
  br label %enif

then1:                                            ; preds = %body
  br label %endfor

enif2:                                            ; preds = %body
  %23 = load i64, ptr %x, align 4
  %24 = load i64, ptr %a, align 4
  %25 = load i64, ptr %x, align 4
  %26 = call i64 @prophet_u32_mod(i64 %24, i64 %25)
  call void @builtin_range_check(i64 %26)
  %27 = add i64 %26, 1
  %28 = sub i64 %25, %27
  call void @builtin_range_check(i64 %28)
  %29 = call i64 @prophet_u32_div(i64 %24, i64 %25)
  call void @builtin_range_check(i64 %29)
  %30 = mul i64 %29, %25
  %31 = add i64 %30, %26
  call void @builtin_assert(i64 %31, i64 %24)
  %32 = load i64, ptr %x, align 4
  %33 = add i64 %29, %32
  call void @builtin_range_check(i64 %33)
  %34 = call i64 @prophet_u32_mod(i64 %33, i64 2)
  call void @builtin_range_check(i64 %34)
  %35 = add i64 %34, 1
  %36 = sub i64 2, %35
  call void @builtin_range_check(i64 %36)
  %37 = call i64 @prophet_u32_div(i64 %33, i64 2)
  call void @builtin_range_check(i64 %37)
  %38 = mul i64 %37, 2
  %39 = add i64 %38, %34
  call void @builtin_assert(i64 %39, i64 %33)
  br label %next

then3:                                            ; preds = %else
  br label %enif4

enif4:                                            ; preds = %then3, %else
  br label %enif
}
