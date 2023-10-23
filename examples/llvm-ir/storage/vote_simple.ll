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

define void @memory_copy(ptr %0, i64 %1, ptr %2, i64 %3, i64 %4) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %4
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %5 = add i64 %1, %index_value
  %src_index_access = getelementptr i64, ptr %0, i64 %5
  %6 = load i64, ptr %src_index_access, align 4
  %7 = add i64 %3, %index_value
  %dest_index_access = getelementptr i64, ptr %2, i64 %7
  store i64 %6, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
}

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
  call void @memory_copy(ptr %heap_to_ptr, i64 0, ptr %heap_to_ptr2, i64 0, i64 4)
  call void @memory_copy(ptr %2, i64 0, ptr %heap_to_ptr2, i64 4, i64 4)
  %8 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %8, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr4, i64 8)
  store ptr %heap_to_ptr4, ptr %sender, align 8
  %9 = load i64, ptr %sender, align 4
  %10 = add i64 %9, 0
  %11 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %11, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  %12 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %12, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 %10, ptr %heap_to_ptr8, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr8, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr8, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr8, i64 3
  store i64 0, ptr %15, align 4
  call void @get_storage(ptr %heap_to_ptr8, ptr %heap_to_ptr6)
  %storage_value = load i64, ptr %heap_to_ptr6, align 4
  %16 = icmp eq i64 %storage_value, 0
  %17 = zext i1 %16 to i64
  call void @builtin_assert(i64 %17)
  %18 = load i64, ptr %sender, align 4
  %19 = add i64 %18, 0
  %20 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %20, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 %19, ptr %heap_to_ptr10, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %23, align 4
  %24 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %24, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 1, ptr %heap_to_ptr12, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %27, align 4
  call void @set_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr12)
  %28 = load i64, ptr %sender, align 4
  %29 = add i64 %28, 1
  %30 = load i64, ptr %proposal_, align 4
  %31 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %31, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 %29, ptr %heap_to_ptr14, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %33, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %34, align 4
  %35 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %35, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  store i64 %30, ptr %heap_to_ptr16, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr16, i64 1
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr16, i64 2
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  store i64 0, ptr %38, align 4
  call void @set_storage(ptr %heap_to_ptr14, ptr %heap_to_ptr16)
  %39 = load i64, ptr %proposal_, align 4
  %40 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %40, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  %41 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %41, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 1, ptr %heap_to_ptr20, align 4
  %42 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %44, align 4
  call void @get_storage(ptr %heap_to_ptr20, ptr %heap_to_ptr18)
  %storage_value21 = load i64, ptr %heap_to_ptr18, align 4
  %45 = sub i64 %storage_value21, 1
  %46 = sub i64 %45, %39
  call void @builtin_range_check(i64 %46)
  %47 = call i64 @vector_new(i64 4)
  %heap_start22 = sub i64 %47, 4
  %heap_to_ptr23 = inttoptr i64 %heap_start22 to ptr
  store i64 1, ptr %heap_to_ptr23, align 4
  %48 = getelementptr i64, ptr %heap_to_ptr23, i64 1
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %heap_to_ptr23, i64 2
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %heap_to_ptr23, i64 3
  store i64 0, ptr %50, align 4
  %51 = call i64 @vector_new(i64 4)
  %heap_start24 = sub i64 %51, 4
  %heap_to_ptr25 = inttoptr i64 %heap_start24 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr23, ptr %heap_to_ptr25, i64 4)
  %52 = getelementptr i64, ptr %heap_to_ptr25, i64 3
  %53 = load i64, ptr %52, align 4
  %54 = mul i64 %39, 2
  %55 = add i64 %53, %54
  store i64 %55, ptr %52, align 4
  %56 = getelementptr i64, ptr %heap_to_ptr25, i64 3
  %slot_value = load i64, ptr %56, align 4
  %57 = add i64 %slot_value, 1
  %58 = load i64, ptr %proposal_, align 4
  %59 = call i64 @vector_new(i64 4)
  %heap_start26 = sub i64 %59, 4
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  %60 = call i64 @vector_new(i64 4)
  %heap_start28 = sub i64 %60, 4
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  store i64 1, ptr %heap_to_ptr29, align 4
  %61 = getelementptr i64, ptr %heap_to_ptr29, i64 1
  store i64 0, ptr %61, align 4
  %62 = getelementptr i64, ptr %heap_to_ptr29, i64 2
  store i64 0, ptr %62, align 4
  %63 = getelementptr i64, ptr %heap_to_ptr29, i64 3
  store i64 0, ptr %63, align 4
  call void @get_storage(ptr %heap_to_ptr29, ptr %heap_to_ptr27)
  %storage_value30 = load i64, ptr %heap_to_ptr27, align 4
  %64 = sub i64 %storage_value30, 1
  %65 = sub i64 %64, %58
  call void @builtin_range_check(i64 %65)
  %66 = call i64 @vector_new(i64 4)
  %heap_start31 = sub i64 %66, 4
  %heap_to_ptr32 = inttoptr i64 %heap_start31 to ptr
  store i64 1, ptr %heap_to_ptr32, align 4
  %67 = getelementptr i64, ptr %heap_to_ptr32, i64 1
  store i64 0, ptr %67, align 4
  %68 = getelementptr i64, ptr %heap_to_ptr32, i64 2
  store i64 0, ptr %68, align 4
  %69 = getelementptr i64, ptr %heap_to_ptr32, i64 3
  store i64 0, ptr %69, align 4
  %70 = call i64 @vector_new(i64 4)
  %heap_start33 = sub i64 %70, 4
  %heap_to_ptr34 = inttoptr i64 %heap_start33 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr32, ptr %heap_to_ptr34, i64 4)
  %71 = getelementptr i64, ptr %heap_to_ptr34, i64 3
  %72 = load i64, ptr %71, align 4
  %73 = mul i64 %58, 2
  %74 = add i64 %72, %73
  store i64 %74, ptr %71, align 4
  %75 = getelementptr i64, ptr %heap_to_ptr34, i64 3
  %slot_value35 = load i64, ptr %75, align 4
  %76 = add i64 %slot_value35, 1
  %77 = call i64 @vector_new(i64 4)
  %heap_start36 = sub i64 %77, 4
  %heap_to_ptr37 = inttoptr i64 %heap_start36 to ptr
  %78 = call i64 @vector_new(i64 4)
  %heap_start38 = sub i64 %78, 4
  %heap_to_ptr39 = inttoptr i64 %heap_start38 to ptr
  store i64 %76, ptr %heap_to_ptr39, align 4
  %79 = getelementptr i64, ptr %heap_to_ptr39, i64 1
  store i64 0, ptr %79, align 4
  %80 = getelementptr i64, ptr %heap_to_ptr39, i64 2
  store i64 0, ptr %80, align 4
  %81 = getelementptr i64, ptr %heap_to_ptr39, i64 3
  store i64 0, ptr %81, align 4
  call void @get_storage(ptr %heap_to_ptr39, ptr %heap_to_ptr37)
  %storage_value40 = load i64, ptr %heap_to_ptr37, align 4
  %82 = add i64 %storage_value40, 1
  call void @builtin_range_check(i64 %82)
  %83 = call i64 @vector_new(i64 4)
  %heap_start41 = sub i64 %83, 4
  %heap_to_ptr42 = inttoptr i64 %heap_start41 to ptr
  store i64 %57, ptr %heap_to_ptr42, align 4
  %84 = getelementptr i64, ptr %heap_to_ptr42, i64 1
  store i64 0, ptr %84, align 4
  %85 = getelementptr i64, ptr %heap_to_ptr42, i64 2
  store i64 0, ptr %85, align 4
  %86 = getelementptr i64, ptr %heap_to_ptr42, i64 3
  store i64 0, ptr %86, align 4
  %87 = call i64 @vector_new(i64 4)
  %heap_start43 = sub i64 %87, 4
  %heap_to_ptr44 = inttoptr i64 %heap_start43 to ptr
  store i64 %82, ptr %heap_to_ptr44, align 4
  %88 = getelementptr i64, ptr %heap_to_ptr44, i64 1
  store i64 0, ptr %88, align 4
  %89 = getelementptr i64, ptr %heap_to_ptr44, i64 2
  store i64 0, ptr %89, align 4
  %90 = getelementptr i64, ptr %heap_to_ptr44, i64 3
  store i64 0, ptr %90, align 4
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
  switch i64 %0, label %missing_function [
    i64 2791810083, label %func_0_dispatch
    i64 2868727644, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 1, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %4 = icmp ult i64 1, %1
  br i1 %4, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @vote_proposal(i64 %value)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %5 = call ptr @get_caller()
  %6 = call i64 @vector_new(i64 5)
  %heap_start = sub i64 %6, 5
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %7 = getelementptr i64, ptr %5, i64 0
  %8 = load i64, ptr %7, align 4
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %8, ptr %start1, align 4
  %9 = getelementptr i64, ptr %5, i64 1
  %10 = load i64, ptr %9, align 4
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %10, ptr %start2, align 4
  %11 = getelementptr i64, ptr %5, i64 2
  %12 = load i64, ptr %11, align 4
  %start3 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %12, ptr %start3, align 4
  %13 = getelementptr i64, ptr %5, i64 3
  %14 = load i64, ptr %13, align 4
  %start4 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %14, ptr %start4, align 4
  %start5 = getelementptr i64, ptr %heap_to_ptr, i64 4
  store i64 4, ptr %start5, align 4
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
