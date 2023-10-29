; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote_simple.ola"

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

define void @vote_proposal(i64 %0) {
entry:
  %sender = alloca i64, align 8
  %index_alloca6 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
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
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 4
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %8 = add i64 %index_value, 0
  %src_index_access = getelementptr i64, ptr %heap_to_ptr, i64 %8
  %9 = load i64, ptr %src_index_access, align 4
  %10 = add i64 %index_value, 0
  %dest_index_access = getelementptr i64, ptr %heap_to_ptr2, i64 %10
  store i64 %9, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %index_alloca6, align 4
  br label %cond3

cond3:                                            ; preds = %body4, %done
  %index_value7 = load i64, ptr %index_alloca6, align 4
  %loop_cond8 = icmp ult i64 %index_value7, 4
  br i1 %loop_cond8, label %body4, label %done5

body4:                                            ; preds = %cond3
  %11 = add i64 %index_value7, 0
  %src_index_access9 = getelementptr i64, ptr %2, i64 %11
  %12 = load i64, ptr %src_index_access9, align 4
  %13 = add i64 %index_value7, 4
  %dest_index_access10 = getelementptr i64, ptr %heap_to_ptr2, i64 %13
  store i64 %12, ptr %dest_index_access10, align 4
  %next_index11 = add i64 %index_value7, 1
  store i64 %next_index11, ptr %index_alloca6, align 4
  br label %cond3

done5:                                            ; preds = %cond3
  %14 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %14, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr13, i64 8)
  store ptr %heap_to_ptr13, ptr %sender, align 8
  %15 = load i64, ptr %sender, align 4
  %16 = add i64 %15, 0
  %17 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %17, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  %18 = call i64 @vector_new(i64 4)
  %heap_start16 = sub i64 %18, 4
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  store i64 %16, ptr %heap_to_ptr17, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr17, i64 1
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %heap_to_ptr17, i64 2
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr17, i64 3
  store i64 0, ptr %21, align 4
  call void @get_storage(ptr %heap_to_ptr17, ptr %heap_to_ptr15)
  %storage_value = load i64, ptr %heap_to_ptr15, align 4
  %22 = icmp eq i64 %storage_value, 0
  %23 = zext i1 %22 to i64
  call void @builtin_assert(i64 %23)
  %24 = load i64, ptr %sender, align 4
  %25 = add i64 %24, 0
  %26 = call i64 @vector_new(i64 4)
  %heap_start18 = sub i64 %26, 4
  %heap_to_ptr19 = inttoptr i64 %heap_start18 to ptr
  store i64 %25, ptr %heap_to_ptr19, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr19, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr19, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr19, i64 3
  store i64 0, ptr %29, align 4
  %30 = call i64 @vector_new(i64 4)
  %heap_start20 = sub i64 %30, 4
  %heap_to_ptr21 = inttoptr i64 %heap_start20 to ptr
  store i64 1, ptr %heap_to_ptr21, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr21, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr21, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr21, i64 3
  store i64 0, ptr %33, align 4
  call void @set_storage(ptr %heap_to_ptr19, ptr %heap_to_ptr21)
  %34 = load i64, ptr %sender, align 4
  %35 = add i64 %34, 1
  %36 = load i64, ptr %proposal_, align 4
  %37 = call i64 @vector_new(i64 4)
  %heap_start22 = sub i64 %37, 4
  %heap_to_ptr23 = inttoptr i64 %heap_start22 to ptr
  store i64 %35, ptr %heap_to_ptr23, align 4
  %38 = getelementptr i64, ptr %heap_to_ptr23, i64 1
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %heap_to_ptr23, i64 2
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr23, i64 3
  store i64 0, ptr %40, align 4
  %41 = call i64 @vector_new(i64 4)
  %heap_start24 = sub i64 %41, 4
  %heap_to_ptr25 = inttoptr i64 %heap_start24 to ptr
  store i64 %36, ptr %heap_to_ptr25, align 4
  %42 = getelementptr i64, ptr %heap_to_ptr25, i64 1
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr25, i64 2
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr25, i64 3
  store i64 0, ptr %44, align 4
  call void @set_storage(ptr %heap_to_ptr23, ptr %heap_to_ptr25)
  %45 = load i64, ptr %proposal_, align 4
  %46 = call i64 @vector_new(i64 4)
  %heap_start26 = sub i64 %46, 4
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  %47 = call i64 @vector_new(i64 4)
  %heap_start28 = sub i64 %47, 4
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  store i64 1, ptr %heap_to_ptr29, align 4
  %48 = getelementptr i64, ptr %heap_to_ptr29, i64 1
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %heap_to_ptr29, i64 2
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %heap_to_ptr29, i64 3
  store i64 0, ptr %50, align 4
  call void @get_storage(ptr %heap_to_ptr29, ptr %heap_to_ptr27)
  %storage_value30 = load i64, ptr %heap_to_ptr27, align 4
  %51 = sub i64 %storage_value30, 1
  %52 = sub i64 %51, %45
  call void @builtin_range_check(i64 %52)
  %53 = call i64 @vector_new(i64 4)
  %heap_start31 = sub i64 %53, 4
  %heap_to_ptr32 = inttoptr i64 %heap_start31 to ptr
  store i64 1, ptr %heap_to_ptr32, align 4
  %54 = getelementptr i64, ptr %heap_to_ptr32, i64 1
  store i64 0, ptr %54, align 4
  %55 = getelementptr i64, ptr %heap_to_ptr32, i64 2
  store i64 0, ptr %55, align 4
  %56 = getelementptr i64, ptr %heap_to_ptr32, i64 3
  store i64 0, ptr %56, align 4
  %57 = call i64 @vector_new(i64 4)
  %heap_start33 = sub i64 %57, 4
  %heap_to_ptr34 = inttoptr i64 %heap_start33 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr32, ptr %heap_to_ptr34, i64 4)
  %58 = getelementptr i64, ptr %heap_to_ptr34, i64 3
  %59 = load i64, ptr %58, align 4
  %60 = mul i64 %45, 2
  %61 = add i64 %59, %60
  store i64 %61, ptr %58, align 4
  %62 = getelementptr i64, ptr %heap_to_ptr34, i64 3
  %slot_value = load i64, ptr %62, align 4
  %63 = add i64 %slot_value, 1
  %64 = load i64, ptr %proposal_, align 4
  %65 = call i64 @vector_new(i64 4)
  %heap_start35 = sub i64 %65, 4
  %heap_to_ptr36 = inttoptr i64 %heap_start35 to ptr
  %66 = call i64 @vector_new(i64 4)
  %heap_start37 = sub i64 %66, 4
  %heap_to_ptr38 = inttoptr i64 %heap_start37 to ptr
  store i64 1, ptr %heap_to_ptr38, align 4
  %67 = getelementptr i64, ptr %heap_to_ptr38, i64 1
  store i64 0, ptr %67, align 4
  %68 = getelementptr i64, ptr %heap_to_ptr38, i64 2
  store i64 0, ptr %68, align 4
  %69 = getelementptr i64, ptr %heap_to_ptr38, i64 3
  store i64 0, ptr %69, align 4
  call void @get_storage(ptr %heap_to_ptr38, ptr %heap_to_ptr36)
  %storage_value39 = load i64, ptr %heap_to_ptr36, align 4
  %70 = sub i64 %storage_value39, 1
  %71 = sub i64 %70, %64
  call void @builtin_range_check(i64 %71)
  %72 = call i64 @vector_new(i64 4)
  %heap_start40 = sub i64 %72, 4
  %heap_to_ptr41 = inttoptr i64 %heap_start40 to ptr
  store i64 1, ptr %heap_to_ptr41, align 4
  %73 = getelementptr i64, ptr %heap_to_ptr41, i64 1
  store i64 0, ptr %73, align 4
  %74 = getelementptr i64, ptr %heap_to_ptr41, i64 2
  store i64 0, ptr %74, align 4
  %75 = getelementptr i64, ptr %heap_to_ptr41, i64 3
  store i64 0, ptr %75, align 4
  %76 = call i64 @vector_new(i64 4)
  %heap_start42 = sub i64 %76, 4
  %heap_to_ptr43 = inttoptr i64 %heap_start42 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr41, ptr %heap_to_ptr43, i64 4)
  %77 = getelementptr i64, ptr %heap_to_ptr43, i64 3
  %78 = load i64, ptr %77, align 4
  %79 = mul i64 %64, 2
  %80 = add i64 %78, %79
  store i64 %80, ptr %77, align 4
  %81 = getelementptr i64, ptr %heap_to_ptr43, i64 3
  %slot_value44 = load i64, ptr %81, align 4
  %82 = add i64 %slot_value44, 1
  %83 = call i64 @vector_new(i64 4)
  %heap_start45 = sub i64 %83, 4
  %heap_to_ptr46 = inttoptr i64 %heap_start45 to ptr
  %84 = call i64 @vector_new(i64 4)
  %heap_start47 = sub i64 %84, 4
  %heap_to_ptr48 = inttoptr i64 %heap_start47 to ptr
  store i64 %82, ptr %heap_to_ptr48, align 4
  %85 = getelementptr i64, ptr %heap_to_ptr48, i64 1
  store i64 0, ptr %85, align 4
  %86 = getelementptr i64, ptr %heap_to_ptr48, i64 2
  store i64 0, ptr %86, align 4
  %87 = getelementptr i64, ptr %heap_to_ptr48, i64 3
  store i64 0, ptr %87, align 4
  call void @get_storage(ptr %heap_to_ptr48, ptr %heap_to_ptr46)
  %storage_value49 = load i64, ptr %heap_to_ptr46, align 4
  %88 = add i64 %storage_value49, 1
  call void @builtin_range_check(i64 %88)
  %89 = call i64 @vector_new(i64 4)
  %heap_start50 = sub i64 %89, 4
  %heap_to_ptr51 = inttoptr i64 %heap_start50 to ptr
  store i64 %63, ptr %heap_to_ptr51, align 4
  %90 = getelementptr i64, ptr %heap_to_ptr51, i64 1
  store i64 0, ptr %90, align 4
  %91 = getelementptr i64, ptr %heap_to_ptr51, i64 2
  store i64 0, ptr %91, align 4
  %92 = getelementptr i64, ptr %heap_to_ptr51, i64 3
  store i64 0, ptr %92, align 4
  %93 = call i64 @vector_new(i64 4)
  %heap_start52 = sub i64 %93, 4
  %heap_to_ptr53 = inttoptr i64 %heap_start52 to ptr
  store i64 %88, ptr %heap_to_ptr53, align 4
  %94 = getelementptr i64, ptr %heap_to_ptr53, i64 1
  store i64 0, ptr %94, align 4
  %95 = getelementptr i64, ptr %heap_to_ptr53, i64 2
  store i64 0, ptr %95, align 4
  %96 = getelementptr i64, ptr %heap_to_ptr53, i64 3
  store i64 0, ptr %96, align 4
  call void @set_storage(ptr %heap_to_ptr51, ptr %heap_to_ptr53)
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
