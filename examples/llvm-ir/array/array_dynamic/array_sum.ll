; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/array/array_dynamic/array_sum.ola"

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

define i64 @sum(ptr %0) {
entry:
  %i = alloca i64, align 8
  %totalSum = alloca i64, align 8
  %inputArray = alloca ptr, align 8
  store ptr %0, ptr %inputArray, align 8
  %1 = call i64 @vector_new(i64 10)
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
  store i64 0, ptr %totalSum, align 4
  store i64 0, ptr %i, align 4
  br label %cond1

cond1:                                            ; preds = %next, %done
  %2 = load i64, ptr %i, align 4
  %3 = icmp ult i64 %2, 10
  br i1 %3, label %body2, label %endfor

body2:                                            ; preds = %cond1
  %4 = load i64, ptr %i, align 4
  %5 = sub i64 9, %4
  call void @builtin_range_check(i64 %5)
  %index_access3 = getelementptr [10 x i64], ptr %inputArray, i64 0, i64 %4
  %6 = load i64, ptr %index_access3, align 4
  %7 = load i64, ptr %i, align 4
  %vector_len4 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length = load i64, ptr %vector_len4, align 4
  %8 = sub i64 %length, 1
  %9 = sub i64 %8, %7
  call void @builtin_range_check(i64 %9)
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access5 = getelementptr i64, ptr %data, i64 %7
  store i64 %6, ptr %index_access5, align 4
  %10 = load i64, ptr %totalSum, align 4
  %11 = load i64, ptr %i, align 4
  %vector_len6 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length7 = load i64, ptr %vector_len6, align 4
  %12 = sub i64 %length7, 1
  %13 = sub i64 %12, %11
  call void @builtin_range_check(i64 %13)
  %data8 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access9 = getelementptr i64, ptr %data8, i64 %11
  %14 = load i64, ptr %index_access9, align 4
  %15 = add i64 %10, %14
  call void @builtin_range_check(i64 %15)
  br label %next

next:                                             ; preds = %body2
  %16 = load i64, ptr %i, align 4
  %17 = add i64 %16, 1
  store i64 %17, ptr %i, align 4
  br label %cond1

endfor:                                           ; preds = %cond1
  %18 = load i64, ptr %totalSum, align 4
  ret i64 %18
}
