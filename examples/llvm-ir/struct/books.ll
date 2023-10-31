; ModuleID = 'BookExample'
source_filename = "examples/source/struct/books.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

define void @mempcy(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %dest_ptr_alloca = alloca ptr, align 8
  %src_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %src_ptr_alloca, align 8
  %src_ptr = load ptr, ptr %src_ptr_alloca, align 8
  store ptr %1, ptr %dest_ptr_alloca, align 8
  %dest_ptr = load ptr, ptr %dest_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %len
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %src_index_access = getelementptr i64, ptr %src_ptr, i64 %index_value
  %3 = load i64, ptr %src_index_access, align 4
  %dest_index_access = getelementptr i64, ptr %dest_ptr, i64 %index_value
  store i64 %3, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret void
}

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
  %struct_member = getelementptr { i64, ptr }, ptr %heap_to_ptr, i64 0
  %4 = load i64, ptr %id, align 4
  store i64 %4, ptr %struct_member, align 4
  %struct_member1 = getelementptr { i64, ptr }, ptr %heap_to_ptr, i64 1
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
  %struct_member = getelementptr { i64, ptr }, ptr %7, i64 0
  %elem = load i64, ptr %struct_member, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %elem, ptr %encode_value_ptr, align 4
  %struct_member2 = getelementptr { i64, ptr }, ptr %7, i64 1
  %length3 = load i64, ptr %struct_member2, align 4
  %15 = ptrtoint ptr %heap_to_ptr to i64
  %buffer_start = add i64 %15, 2
  %16 = inttoptr i64 %buffer_start to ptr
  %encode_value_ptr4 = getelementptr i64, ptr %16, i64 2
  store i64 %length3, ptr %encode_value_ptr4, align 4
  %17 = ptrtoint ptr %struct_member2 to i64
  %18 = add i64 %17, 1
  %vector_data = inttoptr i64 %18 to ptr
  call void @mempcy(ptr %vector_data, ptr %16, i64 %length3)
  %19 = add i64 %length3, 1
  %20 = add i64 %19, 1
  %encode_value_ptr5 = getelementptr i64, ptr %heap_to_ptr, i64 %20
  store i64 %13, ptr %encode_value_ptr5, align 4
  call void @set_tape_data(i64 %heap_start, i64 %heap_size)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start6 = ptrtoint ptr %input to i64
  %21 = inttoptr i64 %input_start6 to ptr
  %decode_value7 = load i64, ptr %21, align 4
  %struct_offset = add i64 %input_start6, 1
  %22 = inttoptr i64 %struct_offset to ptr
  %length8 = load i64, ptr %22, align 4
  %23 = add i64 %length8, 1
  %struct_offset9 = add i64 %struct_offset, %23
  %struct_decode_size = sub i64 %struct_offset9, %input_start6
  %24 = call i64 @vector_new(i64 2)
  %heap_start10 = sub i64 %24, 2
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  %struct_member12 = getelementptr { i64, ptr }, ptr %heap_to_ptr11, i64 0
  store i64 %decode_value7, ptr %struct_member12, align 4
  %struct_member13 = getelementptr { i64, ptr }, ptr %heap_to_ptr11, i64 1
  store ptr %22, ptr %struct_member13, align 8
  %25 = call ptr @getBookName(ptr %heap_to_ptr11)
  %length14 = load i64, ptr %25, align 4
  %26 = add i64 %length14, 1
  %heap_size15 = add i64 %26, 1
  %27 = call i64 @vector_new(i64 %heap_size15)
  %heap_start16 = sub i64 %27, %heap_size15
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  %length18 = load i64, ptr %25, align 4
  %28 = ptrtoint ptr %heap_to_ptr17 to i64
  %buffer_start19 = add i64 %28, 1
  %29 = inttoptr i64 %buffer_start19 to ptr
  %encode_value_ptr20 = getelementptr i64, ptr %29, i64 1
  store i64 %length18, ptr %encode_value_ptr20, align 4
  %30 = ptrtoint ptr %25 to i64
  %31 = add i64 %30, 1
  %vector_data21 = inttoptr i64 %31 to ptr
  call void @mempcy(ptr %vector_data21, ptr %29, i64 %length18)
  %32 = add i64 %length18, 1
  %encode_value_ptr22 = getelementptr i64, ptr %heap_to_ptr17, i64 %32
  store i64 %26, ptr %encode_value_ptr22, align 4
  call void @set_tape_data(i64 %heap_start16, i64 %heap_size15)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %input_start23 = ptrtoint ptr %input to i64
  %33 = inttoptr i64 %input_start23 to ptr
  %decode_value24 = load i64, ptr %33, align 4
  %struct_offset25 = add i64 %input_start23, 1
  %34 = inttoptr i64 %struct_offset25 to ptr
  %length26 = load i64, ptr %34, align 4
  %35 = add i64 %length26, 1
  %struct_offset27 = add i64 %struct_offset25, %35
  %struct_decode_size28 = sub i64 %struct_offset27, %input_start23
  %36 = call i64 @vector_new(i64 2)
  %heap_start29 = sub i64 %36, 2
  %heap_to_ptr30 = inttoptr i64 %heap_start29 to ptr
  %struct_member31 = getelementptr { i64, ptr }, ptr %heap_to_ptr30, i64 0
  store i64 %decode_value24, ptr %struct_member31, align 4
  %struct_member32 = getelementptr { i64, ptr }, ptr %heap_to_ptr30, i64 1
  store ptr %34, ptr %struct_member32, align 8
  %37 = call i64 @getBookId(ptr %heap_to_ptr30)
  %38 = call i64 @vector_new(i64 2)
  %heap_start33 = sub i64 %38, 2
  %heap_to_ptr34 = inttoptr i64 %heap_start33 to ptr
  %encode_value_ptr35 = getelementptr i64, ptr %heap_to_ptr34, i64 0
  store i64 %37, ptr %encode_value_ptr35, align 4
  %encode_value_ptr36 = getelementptr i64, ptr %heap_to_ptr34, i64 1
  store i64 1, ptr %encode_value_ptr36, align 4
  call void @set_tape_data(i64 %heap_start33, i64 2)
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
