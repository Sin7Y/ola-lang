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
  %length2 = alloca i64, align 8
  %0 = call i64 @vector_new(i64 5)
  %1 = load i64, ptr @heap_address, align 4
  %allocated_size = sub i64 %1, %0
  call void @builtin_assert(i64 %allocated_size, i64 5)
  store i64 %0, ptr @heap_address, align 4
  %int_to_ptr = inttoptr i64 %0 to ptr
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 5, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length = load i64, ptr %vector_len1, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 0
  store i64 1, ptr %index_access, align 4
  %2 = call i64 @array_call(ptr %vector_alloca)
  store i64 %2, ptr %length2, align 4
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
  %data = getelementptr inbounds { i64, ptr }, ptr %source, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 %4
  store i64 %3, ptr %index_access, align 4
  br label %next

next:                                             ; preds = %body
  %5 = load i64, ptr %i, align 4
  %6 = add i64 %5, 1
  call void @builtin_range_check(i64 %6)
  br label %cond

endfor:                                           ; preds = %cond
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %source, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  ret i64 %length2
}
