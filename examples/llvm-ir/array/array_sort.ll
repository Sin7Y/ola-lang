; ModuleID = 'ArraySortExample'
source_filename = "examples/source/array/array_sort.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

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

define void @main() {
entry:
  %array_literal = alloca [10 x i64], align 8
  %elemptr0 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 0
  store i64 3, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 1
  store i64 4, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 2
  store i64 5, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 3
  store i64 1, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 4
  store i64 7, ptr %elemptr4, align 4
  %elemptr5 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 5
  store i64 9, ptr %elemptr5, align 4
  %elemptr6 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 6
  store i64 0, ptr %elemptr6, align 4
  %elemptr7 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 7
  store i64 2, ptr %elemptr7, align 4
  %elemptr8 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 8
  store i64 8, ptr %elemptr8, align 4
  %elemptr9 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 9
  store i64 6, ptr %elemptr9, align 4
  %0 = call ptr @array_sort_test(ptr %array_literal)
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %1 = sub i64 %length, 1
  %2 = sub i64 %1, 0
  call void @builtin_range_check(i64 %2)
  %data = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 0
  %3 = load i64, ptr %index_access, align 4
  %4 = add i64 %3, 1
  call void @builtin_range_check(i64 %4)
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %5 = sub i64 %length2, 1
  %6 = sub i64 %5, 0
  call void @builtin_range_check(i64 %6)
  %data3 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access4 = getelementptr i64, ptr %data3, i64 0
  store i64 %4, ptr %index_access4, align 4
  %vector_len5 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length6 = load i64, ptr %vector_len5, align 4
  %7 = sub i64 %length6, 1
  %8 = sub i64 %7, 1
  call void @builtin_range_check(i64 %8)
  %data7 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access8 = getelementptr i64, ptr %data7, i64 1
  %9 = load i64, ptr %index_access8, align 4
  %10 = sub i64 %9, 1
  call void @builtin_range_check(i64 %10)
  %vector_len9 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length10 = load i64, ptr %vector_len9, align 4
  %11 = sub i64 %length10, 1
  %12 = sub i64 %11, 1
  call void @builtin_range_check(i64 %12)
  %data11 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access12 = getelementptr i64, ptr %data11, i64 1
  store i64 %10, ptr %index_access12, align 4
  ret void
}

define ptr @array_sort_test(ptr %0) {
entry:
  %i = alloca i64, align 8
  %source = alloca ptr, align 8
  store ptr %0, ptr %source, align 8
  %1 = call i64 @vector_new(i64 10)
  %2 = load i64, ptr @heap_address, align 4
  %allocated_size = sub i64 %2, %1
  call void @builtin_assert(i64 %allocated_size, i64 10)
  store i64 %1, ptr @heap_address, align 4
  %int_to_ptr = inttoptr i64 %1 to ptr
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 10
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr ptr, ptr %int_to_ptr, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 10, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  store i64 0, ptr %i, align 4
  br label %cond1

cond1:                                            ; preds = %next, %done
  %3 = load i64, ptr %i, align 4
  %4 = icmp ult i64 %3, 10
  br i1 %4, label %body2, label %endfor

body2:                                            ; preds = %cond1
  %5 = load i64, ptr %i, align 4
  %6 = sub i64 9, %5
  call void @builtin_range_check(i64 %6)
  %index_access3 = getelementptr [10 x i64], ptr %source, i64 0, i64 %5
  %7 = load i64, ptr %index_access3, align 4
  %8 = load i64, ptr %i, align 4
  %vector_len4 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length = load i64, ptr %vector_len4, align 4
  %9 = sub i64 %length, 1
  %10 = sub i64 %9, %8
  call void @builtin_range_check(i64 %10)
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access5 = getelementptr i64, ptr %data, i64 %8
  store i64 %7, ptr %index_access5, align 4
  br label %next

next:                                             ; preds = %body2
  %11 = load i64, ptr %i, align 4
  %12 = add i64 %11, 1
  call void @builtin_range_check(i64 %12)
  br label %cond1

endfor:                                           ; preds = %cond1
  %vector_len6 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length7 = load i64, ptr %vector_len6, align 4
  %13 = call ptr @prophet_u32_array_sort(ptr %vector_alloca, i64 %length7)
  ret ptr %13
}
