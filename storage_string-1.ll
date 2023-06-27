; ModuleID = 'AddressExample'
source_filename = "examples/source/storage/storage_string.ola"

@const_string = internal unnamed_addr constant [7 x i64] [i64 34, i64 104, i64 101, i64 108, i64 108, i64 111, i64 34]

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

define void @setStringLiteral() {
entry:
  %0 = call ptr @vector_new(i64 7, ptr @const_string)
  %slot = alloca i64, align 8
  store i64 0, ptr %slot, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  store i64 0, ptr %slot, align 4
  %1 = load i64, ptr %slot, align 4
  %2 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %1, 3
  %3 = call [4 x i64] @get_storage([4 x i64] %2)
  %4 = extractvalue [4 x i64] %3, 3
  %5 = load i64, ptr %slot, align 4
  %6 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %5, 3
  %7 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length, 3
  call void @set_storage([4 x i64] %6, [4 x i64] %7)
  %8 = load i64, ptr %slot, align 4
  %9 = insertvalue [8 x i64] undef, i64 %8, 7
  %10 = insertvalue [8 x i64] %9, i64 0, 6
  %11 = insertvalue [8 x i64] %10, i64 0, 5
  %12 = insertvalue [8 x i64] %11, i64 0, 4
  %13 = insertvalue [8 x i64] %12, i64 0, 3
  %14 = insertvalue [8 x i64] %13, i64 0, 2
  %15 = insertvalue [8 x i64] %14, i64 0, 1
  %16 = insertvalue [8 x i64] %15, i64 0, 0
  %17 = call [4 x i64] @poseidon_hash([8 x i64] %16)
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  %18 = alloca [4 x i64], align 8
  store [4 x i64] %17, ptr %18, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %19 = load [4 x i64], ptr %18, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 %index_value
  store [4 x i64] %19, ptr %slot, align 4
  %20 = load i64, ptr %index_access, align 4
  %21 = load [4 x i64], ptr %slot, align 4
  %22 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %20, 3
  call void @set_storage([4 x i64] %21, [4 x i64] %22)
  %23 = extractvalue [4 x i64] %19, 3
  %24 = add i64 %23, 1
  %25 = insertvalue [4 x i64] %19, i64 %24, 3
  store [4 x i64] %25, ptr %18, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %index_alloca4 = alloca i64, align 8
  store i64 %length, ptr %index_alloca4, align 4
  %26 = alloca [4 x i64], align 8
  store [4 x i64] %17, ptr %26, align 4
  br label %cond1

cond1:                                            ; preds = %body2, %done
  %index_value5 = load i64, ptr %index_alloca4, align 4
  %loop_cond6 = icmp ult i64 %index_value5, %4
  br i1 %loop_cond6, label %body2, label %done3

body2:                                            ; preds = %cond1
  %27 = load [4 x i64], ptr %26, align 4
  store [4 x i64] %27, ptr %slot, align 4
  %28 = load [4 x i64], ptr %slot, align 4
  call void @set_storage([4 x i64] %28, [4 x i64] zeroinitializer)
  %29 = extractvalue [4 x i64] %27, 3
  %30 = add i64 %29, 1
  %31 = insertvalue [4 x i64] %27, i64 %30, 3
  store [4 x i64] %31, ptr %26, align 4
  %next_index7 = add i64 %index_value5, 1
  store i64 %next_index7, ptr %index_alloca4, align 4
  br label %cond1

done3:                                            ; preds = %cond1
  ret void
}
