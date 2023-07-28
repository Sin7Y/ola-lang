; ModuleID = 'DynamicArrayInMemory'
source_filename = "examples/source/array/array_dynamic/array_2d.ola"

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

define void @processDynamicArray() {
entry:
  %vector_alloca13 = alloca { i64, ptr }, align 8
  %index_alloca8 = alloca i64, align 8
  %vector_alloca = alloca { i64, ptr }, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 3)
  %heap_ptr = sub i64 %0, 3
  %int_to_ptr = inttoptr i64 %heap_ptr to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr { i64, ptr }, ptr %int_to_ptr, i64 %index_value
  store ptr null, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 3, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length = load i64, ptr %vector_len1, align 4
  %1 = sub i64 %length, 1
  %2 = sub i64 %1, 0
  call void @builtin_range_check(i64 %2)
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access2 = getelementptr ptr, ptr %data, i64 0
  %3 = call i64 @vector_new(i64 2)
  %heap_ptr3 = sub i64 %3, 2
  %int_to_ptr4 = inttoptr i64 %heap_ptr3 to ptr
  store i64 0, ptr %index_alloca8, align 4
  br label %cond5

cond5:                                            ; preds = %body6, %done
  %index_value9 = load i64, ptr %index_alloca8, align 4
  %loop_cond10 = icmp ult i64 %index_value9, 2
  br i1 %loop_cond10, label %body6, label %done7

body6:                                            ; preds = %cond5
  %index_access11 = getelementptr i64, ptr %int_to_ptr4, i64 %index_value9
  store i64 0, ptr %index_access11, align 4
  %next_index12 = add i64 %index_value9, 1
  store i64 %next_index12, ptr %index_alloca8, align 4
  br label %cond5

done7:                                            ; preds = %cond5
  %vector_len14 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca13, i32 0, i32 0
  store i64 2, ptr %vector_len14, align 4
  %vector_data15 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca13, i32 0, i32 1
  store ptr %int_to_ptr4, ptr %vector_data15, align 8
  store ptr %vector_alloca13, ptr %index_access2, align 8
  %vector_len16 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length17 = load i64, ptr %vector_len16, align 4
  %4 = sub i64 %length17, 1
  %5 = sub i64 %4, 0
  call void @builtin_range_check(i64 %5)
  %data18 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access19 = getelementptr ptr, ptr %data18, i64 0
  %vector_len20 = getelementptr inbounds { i64, ptr }, ptr %index_access19, i32 0, i32 0
  %length21 = load i64, ptr %vector_len20, align 4
  %6 = sub i64 %length21, 1
  %7 = sub i64 %6, 0
  call void @builtin_range_check(i64 %7)
  %data22 = getelementptr inbounds { i64, ptr }, ptr %index_access19, i32 0, i32 1
  %index_access23 = getelementptr i64, ptr %data22, i64 0
  store i64 1, ptr %index_access23, align 4
  ret void
}
