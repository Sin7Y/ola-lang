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
  %2 = load i64, ptr @heap_address, align 4
  %allocated_size = sub i64 %2, %1
  call void @builtin_assert(i64 %allocated_size, i64 10)
  store i64 %1, ptr @heap_address, align 4
  %int_to_ptr = inttoptr i64 %1 to ptr
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 10, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  store i64 0, ptr %totalSum, align 4
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %3 = load i64, ptr %i, align 4
  %4 = icmp ult i64 %3, 10
  br i1 %4, label %body, label %endfor

body:                                             ; preds = %cond
  %5 = load i64, ptr %i, align 4
  %6 = sub i64 9, %5
  call void @builtin_range_check(i64 %6)
  %index_access = getelementptr [10 x i64], ptr %inputArray, i64 0, i64 %5
  %7 = load i64, ptr %index_access, align 4
  %8 = load i64, ptr %i, align 4
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length = load i64, ptr %vector_len1, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access2 = getelementptr i64, ptr %data, i64 %8
  store i64 %7, ptr %index_access2, align 4
  %9 = load i64, ptr %totalSum, align 4
  %10 = load i64, ptr %i, align 4
  %vector_len3 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length4 = load i64, ptr %vector_len3, align 4
  %data5 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access6 = getelementptr i64, ptr %data5, i64 %10
  %11 = load i64, ptr %index_access6, align 4
  %12 = add i64 %9, %11
  call void @builtin_range_check(i64 %12)
  br label %next

next:                                             ; preds = %body
  %13 = load i64, ptr %i, align 4
  %14 = add i64 %13, 1
  store i64 %14, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %15 = load i64, ptr %totalSum, align 4
  ret i64 %15
}
