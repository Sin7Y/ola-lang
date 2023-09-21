; ModuleID = 'StructExample'
source_filename = "examples/source/struct/struct_1.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @contract_call(i64, i64)

define ptr @createBook() {
entry:
  %struct_alloca2 = alloca { i64, i64 }, align 8
  %struct_alloca = alloca { i64, i64 }, align 8
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  store i64 1, ptr %"struct member", align 4
  %"struct member1" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 3, ptr %"struct member1", align 4
  %"struct member3" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca2, i32 0, i32 0
  store i64 2, ptr %"struct member3", align 4
  %"struct member4" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca2, i32 0, i32 1
  store i64 4, ptr %"struct member4", align 4
  ret ptr %struct_alloca2
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 1078588283, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @createBook()
  %4 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %4, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 2, ptr %start, align 4
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %3, i32 0, i32 0
  %elem = load i64, ptr %"struct member", align 4
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %elem, ptr %start1, align 4
  %"struct member2" = getelementptr inbounds { i64, i64 }, ptr %3, i32 0, i32 1
  %elem3 = load i64, ptr %"struct member2", align 4
  %start4 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %elem3, ptr %start4, align 4
  call void @set_tape_data(i64 %heap_start, i64 3)
  ret void
}

define void @call() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 14, %input_length
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  ret void
}
