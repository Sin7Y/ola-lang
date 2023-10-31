; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote_simple.ola"

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

define void @vote_proposal(i64 %0) {
entry:
  %sender = alloca i64, align 8
  %msgSender = alloca ptr, align 8
  %proposal_ = alloca i64, align 8
  store i64 %0, ptr %proposal_, align 4
  %1 = call ptr @get_caller()
  store ptr %1, ptr %msgSender, align 8
  %2 = load ptr, ptr %msgSender, align 8
  %3 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %3, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %6, align 4
  %7 = call i64 @vector_new(i64 8)
  %heap_start1 = sub i64 %7, 8
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  %8 = inttoptr i64 %heap_start1 to ptr
  call void @mempcy(ptr %heap_to_ptr, ptr %8, i64 4)
  %next_dest_offset = add i64 %heap_start1, 4
  %9 = inttoptr i64 %next_dest_offset to ptr
  call void @mempcy(ptr %2, ptr %9, i64 4)
  %10 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %10, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr4, i64 8)
  store ptr %heap_to_ptr4, ptr %sender, align 8
  %11 = load i64, ptr %sender, align 4
  %12 = add i64 %11, 0
  %13 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %13, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  %14 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %14, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 %12, ptr %heap_to_ptr8, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr8, i64 1
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr8, i64 2
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr8, i64 3
  store i64 0, ptr %17, align 4
  call void @get_storage(ptr %heap_to_ptr8, ptr %heap_to_ptr6)
  %storage_value = load i64, ptr %heap_to_ptr6, align 4
  %18 = icmp eq i64 %storage_value, 0
  %19 = zext i1 %18 to i64
  call void @builtin_assert(i64 %19)
  %20 = load i64, ptr %sender, align 4
  %21 = add i64 %20, 0
  %22 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %22, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 %21, ptr %heap_to_ptr10, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %25, align 4
  %26 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %26, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 1, ptr %heap_to_ptr12, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %29, align 4
  call void @set_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr12)
  %30 = load i64, ptr %sender, align 4
  %31 = add i64 %30, 1
  %32 = load i64, ptr %proposal_, align 4
  %33 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %33, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 %31, ptr %heap_to_ptr14, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %36, align 4
  %37 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %37, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  store i64 %32, ptr %heap_to_ptr16, align 4
  %38 = getelementptr i64, ptr %heap_to_ptr16, i64 1
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %heap_to_ptr16, i64 2
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  store i64 0, ptr %40, align 4
  call void @set_storage(ptr %heap_to_ptr14, ptr %heap_to_ptr16)
  %41 = load i64, ptr %proposal_, align 4
  %42 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %42, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  %43 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %43, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 1, ptr %heap_to_ptr20, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %45, align 4
  %46 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %46, align 4
  call void @get_storage(ptr %heap_to_ptr20, ptr %heap_to_ptr18)
  %storage_value21 = load i64, ptr %heap_to_ptr18, align 4
  %47 = sub i64 %storage_value21, 1
  %48 = sub i64 %47, %41
  call void @builtin_range_check(i64 %48)
  %49 = call i64 @vector_new(i64 4)
  %heap_start22 = sub i64 %49, 4
  %heap_to_ptr23 = inttoptr i64 %heap_start22 to ptr
  store i64 1, ptr %heap_to_ptr23, align 4
  %50 = getelementptr i64, ptr %heap_to_ptr23, i64 1
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %heap_to_ptr23, i64 2
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %heap_to_ptr23, i64 3
  store i64 0, ptr %52, align 4
  %53 = call i64 @vector_new(i64 4)
  %heap_start24 = sub i64 %53, 4
  %heap_to_ptr25 = inttoptr i64 %heap_start24 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr23, ptr %heap_to_ptr25, i64 4)
  %54 = getelementptr i64, ptr %heap_to_ptr25, i64 3
  %55 = load i64, ptr %54, align 4
  %56 = mul i64 %41, 2
  %57 = add i64 %55, %56
  store i64 %57, ptr %54, align 4
  %58 = getelementptr i64, ptr %heap_to_ptr25, i64 3
  %slot_value = load i64, ptr %58, align 4
  %59 = add i64 %slot_value, 1
  %60 = load i64, ptr %proposal_, align 4
  %61 = call i64 @vector_new(i64 4)
  %heap_start26 = sub i64 %61, 4
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  %62 = call i64 @vector_new(i64 4)
  %heap_start28 = sub i64 %62, 4
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  store i64 1, ptr %heap_to_ptr29, align 4
  %63 = getelementptr i64, ptr %heap_to_ptr29, i64 1
  store i64 0, ptr %63, align 4
  %64 = getelementptr i64, ptr %heap_to_ptr29, i64 2
  store i64 0, ptr %64, align 4
  %65 = getelementptr i64, ptr %heap_to_ptr29, i64 3
  store i64 0, ptr %65, align 4
  call void @get_storage(ptr %heap_to_ptr29, ptr %heap_to_ptr27)
  %storage_value30 = load i64, ptr %heap_to_ptr27, align 4
  %66 = sub i64 %storage_value30, 1
  %67 = sub i64 %66, %60
  call void @builtin_range_check(i64 %67)
  %68 = call i64 @vector_new(i64 4)
  %heap_start31 = sub i64 %68, 4
  %heap_to_ptr32 = inttoptr i64 %heap_start31 to ptr
  store i64 1, ptr %heap_to_ptr32, align 4
  %69 = getelementptr i64, ptr %heap_to_ptr32, i64 1
  store i64 0, ptr %69, align 4
  %70 = getelementptr i64, ptr %heap_to_ptr32, i64 2
  store i64 0, ptr %70, align 4
  %71 = getelementptr i64, ptr %heap_to_ptr32, i64 3
  store i64 0, ptr %71, align 4
  %72 = call i64 @vector_new(i64 4)
  %heap_start33 = sub i64 %72, 4
  %heap_to_ptr34 = inttoptr i64 %heap_start33 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr32, ptr %heap_to_ptr34, i64 4)
  %73 = getelementptr i64, ptr %heap_to_ptr34, i64 3
  %74 = load i64, ptr %73, align 4
  %75 = mul i64 %60, 2
  %76 = add i64 %74, %75
  store i64 %76, ptr %73, align 4
  %77 = getelementptr i64, ptr %heap_to_ptr34, i64 3
  %slot_value35 = load i64, ptr %77, align 4
  %78 = add i64 %slot_value35, 1
  %79 = call i64 @vector_new(i64 4)
  %heap_start36 = sub i64 %79, 4
  %heap_to_ptr37 = inttoptr i64 %heap_start36 to ptr
  %80 = call i64 @vector_new(i64 4)
  %heap_start38 = sub i64 %80, 4
  %heap_to_ptr39 = inttoptr i64 %heap_start38 to ptr
  store i64 %78, ptr %heap_to_ptr39, align 4
  %81 = getelementptr i64, ptr %heap_to_ptr39, i64 1
  store i64 0, ptr %81, align 4
  %82 = getelementptr i64, ptr %heap_to_ptr39, i64 2
  store i64 0, ptr %82, align 4
  %83 = getelementptr i64, ptr %heap_to_ptr39, i64 3
  store i64 0, ptr %83, align 4
  call void @get_storage(ptr %heap_to_ptr39, ptr %heap_to_ptr37)
  %storage_value40 = load i64, ptr %heap_to_ptr37, align 4
  %84 = add i64 %storage_value40, 1
  call void @builtin_range_check(i64 %84)
  %85 = call i64 @vector_new(i64 4)
  %heap_start41 = sub i64 %85, 4
  %heap_to_ptr42 = inttoptr i64 %heap_start41 to ptr
  store i64 %59, ptr %heap_to_ptr42, align 4
  %86 = getelementptr i64, ptr %heap_to_ptr42, i64 1
  store i64 0, ptr %86, align 4
  %87 = getelementptr i64, ptr %heap_to_ptr42, i64 2
  store i64 0, ptr %87, align 4
  %88 = getelementptr i64, ptr %heap_to_ptr42, i64 3
  store i64 0, ptr %88, align 4
  %89 = call i64 @vector_new(i64 4)
  %heap_start43 = sub i64 %89, 4
  %heap_to_ptr44 = inttoptr i64 %heap_start43 to ptr
  store i64 %84, ptr %heap_to_ptr44, align 4
  %90 = getelementptr i64, ptr %heap_to_ptr44, i64 1
  store i64 0, ptr %90, align 4
  %91 = getelementptr i64, ptr %heap_to_ptr44, i64 2
  store i64 0, ptr %91, align 4
  %92 = getelementptr i64, ptr %heap_to_ptr44, i64 3
  store i64 0, ptr %92, align 4
  call void @set_storage(ptr %heap_to_ptr42, ptr %heap_to_ptr44)
  ret void
}

define ptr @get_caller() {
entry:
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 402443140940559753, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 -5438528055523826848, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 6500940582073311439, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 -6711892513312253938, ptr %index_access3, align 4
  ret ptr %heap_to_ptr
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 2791810083, label %func_0_dispatch
    i64 2868727644, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %decode_value = load i64, ptr %3, align 4
  call void @vote_proposal(i64 %decode_value)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %4 = call ptr @get_caller()
  %5 = call i64 @vector_new(i64 5)
  %heap_start = sub i64 %5, 5
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %6 = getelementptr i64, ptr %4, i64 0
  %7 = load i64, ptr %6, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %7, ptr %encode_value_ptr, align 4
  %8 = getelementptr i64, ptr %4, i64 1
  %9 = load i64, ptr %8, align 4
  %encode_value_ptr1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %9, ptr %encode_value_ptr1, align 4
  %10 = getelementptr i64, ptr %4, i64 2
  %11 = load i64, ptr %10, align 4
  %encode_value_ptr2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %11, ptr %encode_value_ptr2, align 4
  %12 = getelementptr i64, ptr %4, i64 3
  %13 = load i64, ptr %12, align 4
  %encode_value_ptr3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %13, ptr %encode_value_ptr3, align 4
  %encode_value_ptr4 = getelementptr i64, ptr %heap_to_ptr, i64 4
  store i64 4, ptr %encode_value_ptr4, align 4
  call void @set_tape_data(i64 %heap_start, i64 5)
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
