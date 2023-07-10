; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/array/array_dynamic/array_5.ola"

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
  %length3 = alloca i64, align 8
  %vector_alloca = alloca { i64, ptr }, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 5)
  %int_to_ptr = inttoptr i64 %0 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 5
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %int_to_ptr, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 5, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length = load i64, ptr %vector_len1, align 4
  %1 = sub i64 %length, 1
  %2 = sub i64 %1, 0
  call void @builtin_range_check(i64 %2)
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access2 = getelementptr i64, ptr %data, i64 0
  store i64 1, ptr %index_access2, align 4
  %3 = call i64 @array_call(ptr %vector_alloca)
  store i64 %3, ptr %length3, align 4
  ret void
}

define i64 @array_call(ptr %0) {
entry:
  %i = alloca i64, align 8
  %source = alloca ptr, align 8
  store ptr %0, ptr %source, align 8
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %1 = load i64, ptr %i, align 4
  %2 = icmp ult i64 %1, 5
  br i1 %2, label %body, label %endfor

body:                                             ; preds = %cond
  %3 = load i64, ptr %i, align 4
  %4 = load i64, ptr %i, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %source, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %5 = sub i64 %length, 1
  %6 = sub i64 %5, %4
  call void @builtin_range_check(i64 %6)
  %data = getelementptr inbounds { i64, ptr }, ptr %source, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 %4
  store i64 %3, ptr %index_access, align 4
  br label %next

next:                                             ; preds = %body
  %7 = load i64, ptr %i, align 4
  %8 = add i64 %7, 1
  call void @builtin_range_check(i64 %8)
  br label %cond

endfor:                                           ; preds = %cond
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %source, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  ret i64 %length2
}
