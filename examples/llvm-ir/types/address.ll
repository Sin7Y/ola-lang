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

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

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

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 1416181918, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 4, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %4 = insertvalue [4 x i64] undef, i64 %value, 0
  %start1 = getelementptr i64, ptr %2, i64 1
  %value2 = load i64, ptr %start1, align 4
  %5 = insertvalue [4 x i64] undef, i64 %value2, 1
  %start3 = getelementptr i64, ptr %2, i64 2
  %value4 = load i64, ptr %start3, align 4
  %6 = insertvalue [4 x i64] undef, i64 %value4, 2
  %start5 = getelementptr i64, ptr %2, i64 3
  %value6 = load i64, ptr %start5, align 4
  %7 = insertvalue [4 x i64] undef, i64 %value6, 3
  %8 = icmp ult i64 4, %1
  br i1 %8, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  %9 = call i64 @compare_address([4 x i64] undef)
}

define void @call() {
entry:
  %0 = call ptr @contract_input()
  %input_selector = getelementptr inbounds { i64, i64, ptr }, ptr %0, i32 0, i32 0
  %selector = load i64, ptr %input_selector, align 4
  %input_len = getelementptr inbounds { i64, i64, ptr }, ptr %0, i32 0, i32 1
  %len = load i64, ptr %input_len, align 4
  %input_data = getelementptr inbounds { i64, i64, ptr }, ptr %0, i32 0, i32 2
  %data = load ptr, ptr %input_data, align 8
  call void @function_dispatch(i64 %selector, i64 %len, ptr %data)
  unreachable
}
