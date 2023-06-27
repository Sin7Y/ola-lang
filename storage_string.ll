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
  %1 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %2 = extractvalue [4 x i64] %1, 3
  %3 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length, 3
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %3)
  %4 = call [4 x i64] @poseidon_hash([8 x i64] zeroinitializer)
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  %5 = alloca [4 x i64], align 8
  store [4 x i64] %4, ptr %5, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %6 = load [4 x i64], ptr %5, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 %index_value
  store [4 x i64] %6, ptr %slot, align 4
  %7 = load i64, ptr %index_access, align 4
  %8 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %7, 3
  call void @set_storage([4 x i64] %6, [4 x i64] %8)
  %9 = extractvalue [4 x i64] %6, 3
  %10 = add i64 %9, 1
  %11 = insertvalue [4 x i64] %6, i64 %10, 3
  store [4 x i64] %11, ptr %5, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %index_alloca4 = alloca i64, align 8
  store i64 %length, ptr %index_alloca4, align 4
  %12 = alloca [4 x i64], align 8
  store [4 x i64] %4, ptr %12, align 4
  br label %cond1

cond1:                                            ; preds = %body2, %done
  %index_value5 = load i64, ptr %index_alloca4, align 4
  %loop_cond6 = icmp ult i64 %index_value5, %2
  br i1 %loop_cond6, label %body2, label %done3

body2:                                            ; preds = %cond1
  %13 = load [4 x i64], ptr %12, align 4
  store [4 x i64] %13, ptr %slot, align 4
  call void @set_storage([4 x i64] %13, [4 x i64] zeroinitializer)
  %14 = extractvalue [4 x i64] %13, 3
  %15 = add i64 %14, 1
  %16 = insertvalue [4 x i64] %13, i64 %15, 3
  store [4 x i64] %16, ptr %12, align 4
  %next_index7 = add i64 %index_value5, 1
  store i64 %next_index7, ptr %index_alloca4, align 4
  br label %cond1

done3:                                            ; preds = %cond1
  ret void
}
