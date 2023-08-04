; ModuleID = 'AddressExample'
source_filename = "examples/source/types/address.ola"

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

define i64 @compare_address([4 x i64] %0) {
entry:
  %_address = alloca [4 x i64], align 8
  store [4 x i64] %0, ptr %_address, align 4
  %1 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %2 = load [4 x i64], ptr %_address, align 4
  %left_elem_0 = extractvalue [4 x i64] %1, 0
  %right_elem_0 = extractvalue [4 x i64] %2, 0
  %compare_0 = icmp eq i64 %left_elem_0, %right_elem_0
  %result_0 = and i1 true, %compare_0
  %left_elem_1 = extractvalue [4 x i64] %1, 1
  %right_elem_1 = extractvalue [4 x i64] %2, 1
  %compare_1 = icmp eq i64 %left_elem_1, %right_elem_1
  %result_1 = and i1 %result_0, %compare_1
  %left_elem_2 = extractvalue [4 x i64] %1, 2
  %right_elem_2 = extractvalue [4 x i64] %2, 2
  %compare_2 = icmp eq i64 %left_elem_2, %right_elem_2
  %result_2 = and i1 %result_1, %compare_2
  %left_elem_3 = extractvalue [4 x i64] %1, 3
  %right_elem_3 = extractvalue [4 x i64] %2, 3
  %compare_3 = icmp eq i64 %left_elem_3, %right_elem_3
  %result_3 = and i1 %result_2, %compare_3
  ret i1 %result_3
}
