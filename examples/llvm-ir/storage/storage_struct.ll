; ModuleID = 'StructExample'
source_filename = "examples/source/storage/storage_struct.ola"

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

define void @setData(i64 %0, i64 %1) {
entry:
  %struct_alloca = alloca { i64, i64 }, align 8
  %_value = alloca i64, align 8
  %_id = alloca i64, align 8
  store i64 %0, ptr %_id, align 4
  store i64 %1, ptr %_value, align 4
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %2 = load i64, ptr %_id, align 4
  store i64 %2, ptr %"struct member", align 4
  %"struct member1" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  %3 = load i64, ptr %_value, align 4
  store i64 %3, ptr %"struct member1", align 4
  %id = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %4 = load i64, ptr %id, align 4
  %5 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %4, 3
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %5)
  %value = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  %6 = load i64, ptr %value, align 4
  %7 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %6, 3
  call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1], [4 x i64] %7)
  ret void
}

define i64 @getData() {
entry:
  %0 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %1 = extractvalue [4 x i64] %0, 3
  ret i64 %1
}

define void @function_dispatch(i64 %0, i64 %1, i64 %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 596322589, label %func_0_dispatch
    i64 819905851, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 2, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %4 = call i64 @tape_load(i64 %2, i64 0)
  %5 = call i64 @tape_load(i64 %2, i64 1)
  %6 = icmp ult i64 2, %1
  br i1 %6, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @setData(i64 %4, i64 %5)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %7 = call i64 @getData()
  call void @tape_store(i64 0, i64 %7)
  ret void
}

define void @call() {
entry:
  %0 = call ptr @contract_input()
  %input_selector = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 0
  %selector = load i64, ptr %input_selector, align 4
  %input_len = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 1
  %len = load i64, ptr %input_len, align 4
  %input_data = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 2
  %data = load i64, ptr %input_data, align 4
  call void @function_dispatch(i64 %selector, i64 %len, i64 %data)
  unreachable
}
