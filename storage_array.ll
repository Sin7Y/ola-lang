; ModuleID = 'StaticArrayExample'
source_filename = "examples/source/storage/storage_array.ola"

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

define void @init() {
entry:
  %array_literal = alloca [5 x i64], align 8
  %elemptr0 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 2
  store i64 3, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 3
  store i64 4, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 4
  store i64 5, ptr %elemptr4, align 4
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  %0 = alloca i64, align 8
  store i64 0, ptr %0, align 4
  br label %body

body:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %1 = load i64, ptr %0, align 4
  %index_access = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 %index_value
  %2 = load i64, ptr %index_access, align 4
  %3 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %1, 3
  %4 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %2, 3
  call void @set_storage([4 x i64] %3, [4 x i64] %4)
  %5 = add i64 %1, 1
  store i64 %5, ptr %0, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %next_index, 5
  br i1 %loop_cond, label %body, label %done

done:                                             ; preds = %body
  ret void
}

define void @setElement(i64 %0, i64 %1) {
entry:
  %value = alloca i64, align 8
  %index = alloca i64, align 8
  store i64 %0, ptr %index, align 4
  store i64 %1, ptr %value, align 4
  %2 = load i64, ptr %value, align 4
  %3 = load i64, ptr %index, align 4
  %4 = call [4 x i64] @poseidon_hash([8 x i64] zeroinitializer)
  %5 = extractvalue [4 x i64] %4, 3
  %6 = add i64 %5, %3
  %7 = insertvalue [4 x i64] %4, i64 %6, 3
  %8 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %2, 3
  call void @set_storage([4 x i64] %7, [4 x i64] %8)
  ret void
}
