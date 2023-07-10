; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/array/array_dynamic/array_1.ola"

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
  %vector_alloca = alloca { i64, ptr }, align 8
  %0 = call i64 @vector_new(i64 3)
  %int_to_ptr = inttoptr i64 %0 to ptr
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 3, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 0
  store i64 1, ptr %index_access, align 4
  %index_access1 = getelementptr ptr, ptr %data, i64 1
  store i64 2, ptr %index_access1, align 4
  %index_access2 = getelementptr ptr, ptr %data, i64 2
  store i64 3, ptr %index_access2, align 4
  ret void
}
