; ModuleID = 'DynamicTwoDimensionalArrayInMemory'
source_filename = "examples/source/array/array_dynamic_2d.ola"

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

define ptr @initialize(i64 %0, i64 %1) {
entry:
  %i = alloca i64, align 8
  %columns = alloca i64, align 8
  %rows = alloca i64, align 8
  store i64 %0, ptr %rows, align 4
  store i64 %1, ptr %columns, align 4
  %2 = load i64, ptr %rows, align 4
  %3 = call i64 @vector_new(i64 %2)
  %int_to_ptr = inttoptr i64 %3 to ptr
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %2
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
  store i64 %2, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  store i64 0, ptr %i, align 4
  br label %cond1

cond1:                                            ; preds = %next, %done
  %4 = load i64, ptr %i, align 4
  %5 = load i64, ptr %rows, align 4
  %6 = icmp ult i64 %4, %5
  br i1 %6, label %body2, label %endfor

body2:                                            ; preds = %cond1
  %7 = load i64, ptr %columns, align 4
  %8 = call i64 @vector_new(i64 %7)
  %int_to_ptr3 = inttoptr i64 %8 to ptr
  %index_alloca7 = alloca i64, align 8
  store i64 0, ptr %index_alloca7, align 4
  br label %cond4

next:                                             ; preds = %done6
  %9 = load i64, ptr %i, align 4
  %10 = add i64 %9, 1
  store i64 %10, ptr %i, align 4
  br label %cond1

endfor:                                           ; preds = %cond1
  ret ptr %vector_alloca

cond4:                                            ; preds = %body5, %body2
  %index_value8 = load i64, ptr %index_alloca7, align 4
  %loop_cond9 = icmp ult i64 %index_value8, %7
  br i1 %loop_cond9, label %body5, label %done6

body5:                                            ; preds = %cond4
  %index_access10 = getelementptr ptr, ptr %int_to_ptr3, i64 %index_value8
  store i64 0, ptr %index_access10, align 4
  %next_index11 = add i64 %index_value8, 1
  store i64 %next_index11, ptr %index_alloca7, align 4
  br label %cond4

done6:                                            ; preds = %cond4
  %vector_alloca12 = alloca { i64, ptr }, align 8
  %vector_len13 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca12, i32 0, i32 0
  store i64 %7, ptr %vector_len13, align 4
  %vector_data14 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca12, i32 0, i32 1
  store ptr %int_to_ptr3, ptr %vector_data14, align 8
  %11 = load i64, ptr %i, align 4
  %vector_len15 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length = load i64, ptr %vector_len15, align 4
  %12 = sub i64 %length, 1
  %13 = sub i64 %12, %11
  call void @builtin_range_check(i64 %13)
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access16 = getelementptr { i64, ptr }, ptr %data, i64 %11
  store ptr %vector_alloca12, ptr %index_access16, align 8
  br label %next
}

define void @setElement(ptr %0, i64 %1, i64 %2, i64 %3) {
entry:
  %value = alloca i64, align 8
  %column = alloca i64, align 8
  %row = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  store i64 %1, ptr %row, align 4
  store i64 %2, ptr %column, align 4
  store i64 %3, ptr %value, align 4
  %4 = load i64, ptr %value, align 4
  %5 = load i64, ptr %row, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %6 = sub i64 %length, 1
  %7 = sub i64 %6, %5
  call void @builtin_range_check(i64 %7)
  %data = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 1
  %index_access = getelementptr { i64, ptr }, ptr %data, i64 %5
  %8 = load i64, ptr %column, align 4
  %9 = load i64, ptr %row, align 4
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %10 = sub i64 %length2, 1
  %11 = sub i64 %10, %9
  call void @builtin_range_check(i64 %11)
  %data3 = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 1
  %index_access4 = getelementptr { i64, ptr }, ptr %data3, i64 %9
  %vector_len5 = getelementptr inbounds { i64, ptr }, ptr %index_access4, i32 0, i32 0
  %length6 = load i64, ptr %vector_len5, align 4
  %12 = sub i64 %length6, 1
  %13 = sub i64 %12, %8
  call void @builtin_range_check(i64 %13)
  %data7 = getelementptr inbounds { i64, ptr }, ptr %index_access, i32 0, i32 1
  %index_access8 = getelementptr i64, ptr %data7, i64 %8
  store i64 %4, ptr %index_access8, align 4
  ret void
}

define i64 @getElement(ptr %0, i64 %1, i64 %2) {
entry:
  %column = alloca i64, align 8
  %row = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  store i64 %1, ptr %row, align 4
  store i64 %2, ptr %column, align 4
  %3 = load i64, ptr %row, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %4 = sub i64 %length, 1
  %5 = sub i64 %4, %3
  call void @builtin_range_check(i64 %5)
  %data = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 1
  %index_access = getelementptr { i64, ptr }, ptr %data, i64 %3
  %6 = load i64, ptr %column, align 4
  %7 = load i64, ptr %row, align 4
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %8 = sub i64 %length2, 1
  %9 = sub i64 %8, %7
  call void @builtin_range_check(i64 %9)
  %data3 = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 1
  %index_access4 = getelementptr { i64, ptr }, ptr %data3, i64 %7
  %vector_len5 = getelementptr inbounds { i64, ptr }, ptr %index_access4, i32 0, i32 0
  %length6 = load i64, ptr %vector_len5, align 4
  %10 = sub i64 %length6, 1
  %11 = sub i64 %10, %6
  call void @builtin_range_check(i64 %11)
  %data7 = getelementptr inbounds { i64, ptr }, ptr %index_access, i32 0, i32 1
  %index_access8 = getelementptr i64, ptr %data7, i64 %6
  %12 = load i64, ptr %index_access8, align 4
  ret i64 %12
}
