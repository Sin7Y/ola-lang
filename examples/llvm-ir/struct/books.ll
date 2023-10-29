; ModuleID = 'BookExample'
source_filename = "examples/source/struct/books.ola"

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

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

declare void @prophet_printf(i64, i64)

define ptr @createBook(i64 %0, ptr %1) {
entry:
  %name = alloca ptr, align 8
  %id = alloca i64, align 8
  store i64 %0, ptr %id, align 4
  store ptr %1, ptr %name, align 8
  %2 = load ptr, ptr %name, align 8
  %3 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %3, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %struct_member = getelementptr inbounds { i64, ptr }, ptr %heap_to_ptr, i32 0, i32 0
  %4 = load i64, ptr %id, align 4
  store i64 %4, ptr %struct_member, align 4
  %struct_member1 = getelementptr inbounds { i64, ptr }, ptr %heap_to_ptr, i32 0, i32 1
  store ptr %2, ptr %struct_member1, align 8
  ret ptr %heap_to_ptr
}

define ptr @getBookName(ptr %0) {
entry:
  %_book = alloca ptr, align 8
  store ptr %0, ptr %_book, align 8
  %1 = load ptr, ptr %_book, align 8
  %struct_member = getelementptr { i64, ptr }, ptr %1, i64 1
  %2 = load ptr, ptr %struct_member, align 8
  ret ptr %2
}

define i64 @getBookId(ptr %0) {
entry:
  %b = alloca i64, align 8
  %_book = alloca ptr, align 8
  store ptr %0, ptr %_book, align 8
  %1 = load ptr, ptr %_book, align 8
  %struct_member = getelementptr { i64, ptr }, ptr %1, i64 0
  %2 = load i64, ptr %struct_member, align 4
  %3 = add i64 %2, 1
  call void @builtin_range_check(i64 %3)
  store i64 %3, ptr %b, align 4
  %4 = load i64, ptr %b, align 4
  ret i64 %4
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %offset_ptr26 = alloca i64, align 8
  %index_ptr25 = alloca i64, align 8
  %offset_ptr = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 2541629191, label %func_0_dispatch
    i64 3203145282, label %func_1_dispatch
    i64 974157710, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %decode_value = load i64, ptr %3, align 4
  %4 = add i64 %input_start, 1
  %5 = inttoptr i64 %4 to ptr
  %length = load i64, ptr %5, align 4
  %6 = add i64 %length, 1
  %7 = call ptr @createBook(i64 %decode_value, ptr %5)
  %struct_start = ptrtoint ptr %7 to i64
  %8 = add i64 %struct_start, 1
  %9 = inttoptr i64 %8 to ptr
  %length1 = load i64, ptr %9, align 4
  %10 = add i64 %length1, 1
  %11 = add i64 %8, %10
  %12 = inttoptr i64 %11 to ptr
  %13 = sub i64 %11, %struct_start
  %heap_size = add i64 %13, 1
  %14 = call i64 @vector_new(i64 %heap_size)
  %heap_start = sub i64 %14, %heap_size
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %struct_member = getelementptr inbounds { i64, ptr }, ptr %7, i32 0, i32 0
  %elem = load i64, ptr %struct_member, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %elem, ptr %encode_value_ptr, align 4
  %struct_member2 = getelementptr inbounds { i64, ptr }, ptr %7, i32 0, i32 1
  %length3 = load i64, ptr %struct_member2, align 4
  %encode_value_ptr4 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %length3, ptr %encode_value_ptr4, align 4
  %15 = ptrtoint ptr %struct_member2 to i64
  %16 = add i64 %15, 1
  %vector_data = inttoptr i64 %16 to ptr
  store i64 2, ptr %offset_ptr, align 4
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

loop_body:                                        ; preds = %loop_body, %func_0_dispatch
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr ptr, ptr %vector_data, i64 %index
  %elem5 = load i64, ptr %element, align 4
  %offset = load i64, ptr %offset_ptr, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %heap_to_ptr, i64 %offset
  store i64 %elem5, ptr %encode_value_ptr6, align 4
  %next_offset = add i64 1, %offset
  store i64 %next_offset, ptr %offset_ptr, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %length3
  br i1 %index_cond, label %loop_body, label %loop_end

loop_end:                                         ; preds = %loop_body
  %17 = add i64 %length3, 1
  %18 = add i64 %17, 1
  %encode_value_ptr7 = getelementptr i64, ptr %heap_to_ptr, i64 %18
  store i64 %13, ptr %encode_value_ptr7, align 4
  call void @set_tape_data(i64 %heap_start, i64 %heap_size)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start8 = ptrtoint ptr %input to i64
  %19 = inttoptr i64 %input_start8 to ptr
  %decode_value9 = load i64, ptr %19, align 4
  %struct_offset = add i64 %input_start8, 1
  %20 = inttoptr i64 %struct_offset to ptr
  %length10 = load i64, ptr %20, align 4
  %21 = add i64 %length10, 1
  %struct_offset11 = add i64 %struct_offset, %21
  %struct_decode_size = sub i64 %struct_offset11, %input_start8
  %22 = call i64 @vector_new(i64 2)
  %heap_start12 = sub i64 %22, 2
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  %struct_member14 = getelementptr { i64, ptr }, ptr %heap_to_ptr13, i64 0
  store i64 %decode_value9, ptr %struct_member14, align 4
  %struct_member15 = getelementptr { i64, ptr }, ptr %heap_to_ptr13, i64 1
  store ptr %20, ptr %struct_member15, align 8
  %23 = call ptr @getBookName(ptr %heap_to_ptr13)
  %length16 = load i64, ptr %23, align 4
  %24 = add i64 %length16, 1
  %heap_size17 = add i64 %24, 1
  %25 = call i64 @vector_new(i64 %heap_size17)
  %heap_start18 = sub i64 %25, %heap_size17
  %heap_to_ptr19 = inttoptr i64 %heap_start18 to ptr
  %length20 = load i64, ptr %23, align 4
  %encode_value_ptr21 = getelementptr i64, ptr %heap_to_ptr19, i64 0
  store i64 %length20, ptr %encode_value_ptr21, align 4
  %26 = ptrtoint ptr %23 to i64
  %27 = add i64 %26, 1
  %vector_data22 = inttoptr i64 %27 to ptr
  store i64 1, ptr %offset_ptr26, align 4
  store i64 0, ptr %index_ptr25, align 4
  br label %loop_body23

loop_body23:                                      ; preds = %loop_body23, %func_1_dispatch
  %index27 = load i64, ptr %index_ptr25, align 4
  %element28 = getelementptr ptr, ptr %vector_data22, i64 %index27
  %elem29 = load i64, ptr %element28, align 4
  %offset30 = load i64, ptr %offset_ptr26, align 4
  %encode_value_ptr31 = getelementptr i64, ptr %heap_to_ptr19, i64 %offset30
  store i64 %elem29, ptr %encode_value_ptr31, align 4
  %next_offset32 = add i64 1, %offset30
  store i64 %next_offset32, ptr %offset_ptr26, align 4
  %next_index33 = add i64 %index27, 1
  store i64 %next_index33, ptr %index_ptr25, align 4
  %index_cond34 = icmp ult i64 %next_index33, %length20
  br i1 %index_cond34, label %loop_body23, label %loop_end24

loop_end24:                                       ; preds = %loop_body23
  %28 = add i64 %length20, 1
  %encode_value_ptr35 = getelementptr i64, ptr %heap_to_ptr19, i64 %28
  store i64 %24, ptr %encode_value_ptr35, align 4
  call void @set_tape_data(i64 %heap_start18, i64 %heap_size17)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %input_start36 = ptrtoint ptr %input to i64
  %29 = inttoptr i64 %input_start36 to ptr
  %decode_value37 = load i64, ptr %29, align 4
  %struct_offset38 = add i64 %input_start36, 1
  %30 = inttoptr i64 %struct_offset38 to ptr
  %length39 = load i64, ptr %30, align 4
  %31 = add i64 %length39, 1
  %struct_offset40 = add i64 %struct_offset38, %31
  %struct_decode_size41 = sub i64 %struct_offset40, %input_start36
  %32 = call i64 @vector_new(i64 2)
  %heap_start42 = sub i64 %32, 2
  %heap_to_ptr43 = inttoptr i64 %heap_start42 to ptr
  %struct_member44 = getelementptr { i64, ptr }, ptr %heap_to_ptr43, i64 0
  store i64 %decode_value37, ptr %struct_member44, align 4
  %struct_member45 = getelementptr { i64, ptr }, ptr %heap_to_ptr43, i64 1
  store ptr %30, ptr %struct_member45, align 8
  %33 = call i64 @getBookId(ptr %heap_to_ptr43)
  %34 = call i64 @vector_new(i64 2)
  %heap_start46 = sub i64 %34, 2
  %heap_to_ptr47 = inttoptr i64 %heap_start46 to ptr
  %encode_value_ptr48 = getelementptr i64, ptr %heap_to_ptr47, i64 0
  store i64 %33, ptr %encode_value_ptr48, align 4
  %encode_value_ptr49 = getelementptr i64, ptr %heap_to_ptr47, i64 1
  store i64 1, ptr %encode_value_ptr49, align 4
  call void @set_tape_data(i64 %heap_start46, i64 2)
  ret void
}

define void @main() {
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
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  ret void
}
