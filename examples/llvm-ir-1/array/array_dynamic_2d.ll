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

define ptr @vector_new_init(i64 %0, ptr %1) {
entry:
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %0, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %1, ptr %vector_data, align 8
  ret ptr %vector_alloca
}

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define ptr @initialize(i64 %0, i64 %1) {
entry:
  %index_alloca10 = alloca i64, align 8
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %columns = alloca i64, align 8
  %rows = alloca i64, align 8
  store i64 %0, ptr %rows, align 4
  store i64 %1, ptr %columns, align 4
  %2 = load i64, ptr %rows, align 4
  %size = mul i64 %2, 1
  %3 = call i64 @vector_new(i64 %size)
  %heap_ptr = sub i64 %3, %size
  %int_to_ptr = inttoptr i64 %heap_ptr to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %size
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr { i64, ptr }, ptr %int_to_ptr, i64 %index_value
  store ptr null, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %4 = call ptr @vector_new_init(i64 %size, ptr %int_to_ptr)
  store i64 0, ptr %i, align 4
  br label %cond1

cond1:                                            ; preds = %next, %done
  %5 = load i64, ptr %i, align 4
  %6 = load i64, ptr %rows, align 4
  %7 = icmp ult i64 %5, %6
  br i1 %7, label %body2, label %endfor

body2:                                            ; preds = %cond1
  %8 = load i64, ptr %i, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %4, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %9 = sub i64 %length, 1
  %10 = sub i64 %9, %8
  call void @builtin_range_check(i64 %10)
  %data = getelementptr inbounds { i64, ptr }, ptr %4, i32 0, i32 1
  %index_access3 = getelementptr ptr, ptr %data, i64 %8
  %11 = load i64, ptr %columns, align 4
  %size4 = mul i64 %11, 1
  %12 = call i64 @vector_new(i64 %size4)
  %heap_ptr5 = sub i64 %12, %size4
  %int_to_ptr6 = inttoptr i64 %heap_ptr5 to ptr
  store i64 0, ptr %index_alloca10, align 4
  br label %cond7

next:                                             ; preds = %done9
  %13 = load i64, ptr %i, align 4
  %14 = add i64 %13, 1
  store i64 %14, ptr %i, align 4
  br label %cond1

endfor:                                           ; preds = %cond1
  ret ptr %4

cond7:                                            ; preds = %body8, %body2
  %index_value11 = load i64, ptr %index_alloca10, align 4
  %loop_cond12 = icmp ult i64 %index_value11, %size4
  br i1 %loop_cond12, label %body8, label %done9

body8:                                            ; preds = %cond7
  %index_access13 = getelementptr i64, ptr %int_to_ptr6, i64 %index_value11
  store i64 0, ptr %index_access13, align 4
  %next_index14 = add i64 %index_value11, 1
  store i64 %next_index14, ptr %index_alloca10, align 4
  br label %cond7

done9:                                            ; preds = %cond7
  %15 = call ptr @vector_new_init(i64 %size4, ptr %int_to_ptr6)
  store ptr %15, ptr %index_access3, align 8
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
  %4 = load i64, ptr %row, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %5 = sub i64 %length, 1
  %6 = sub i64 %5, %4
  call void @builtin_range_check(i64 %6)
  %data = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 %4
  %7 = load i64, ptr %column, align 4
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %index_access, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %8 = sub i64 %length2, 1
  %9 = sub i64 %8, %7
  call void @builtin_range_check(i64 %9)
  %data3 = getelementptr inbounds { i64, ptr }, ptr %index_access, i32 0, i32 1
  %index_access4 = getelementptr i64, ptr %data3, i64 %7
  %10 = load i64, ptr %value, align 4
  store i64 %10, ptr %index_access4, align 4
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
  %index_access = getelementptr ptr, ptr %data, i64 %3
  %6 = load i64, ptr %column, align 4
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %index_access, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %7 = sub i64 %length2, 1
  %8 = sub i64 %7, %6
  call void @builtin_range_check(i64 %8)
  %data3 = getelementptr inbounds { i64, ptr }, ptr %index_access, i32 0, i32 1
  %index_access4 = getelementptr i64, ptr %data3, i64 %6
  %9 = load i64, ptr %index_access4, align 4
  ret i64 %9
}
