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

define void @vote_proposal(i64 %0) {
entry:
  %sender = alloca i64, align 8
  %index_alloca7 = alloca i64, align 8
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
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 %index_value
  %8 = load i64, ptr %index_access, align 4
  %9 = add i64 0, %index_value
  %index_access3 = getelementptr i64, ptr %heap_to_ptr2, i64 %9
  store i64 %8, ptr %index_access3, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %index_alloca7, align 4
  br label %cond4

cond4:                                            ; preds = %body5, %done
  %index_value8 = load i64, ptr %index_alloca7, align 4
  %loop_cond9 = icmp ult i64 %index_value8, 4
  br i1 %loop_cond9, label %body5, label %done6

body5:                                            ; preds = %cond4
  %index_access10 = getelementptr i64, ptr %2, i64 %index_value8
  %10 = load i64, ptr %index_access10, align 4
  %11 = add i64 4, %index_value8
  %index_access11 = getelementptr i64, ptr %heap_to_ptr2, i64 %11
  store i64 %10, ptr %index_access11, align 4
  %next_index12 = add i64 %index_value8, 1
  store i64 %next_index12, ptr %index_alloca7, align 4
  br label %cond4

done6:                                            ; preds = %cond4
  %12 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %12, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr14, i64 8)
  store ptr %heap_to_ptr14, ptr %sender, align 8
  %13 = load i64, ptr %sender, align 4
  %14 = add i64 %13, 0
  %15 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %15, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  %16 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %16, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  store i64 %14, ptr %heap_to_ptr18, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr18, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr18, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr18, i64 3
  store i64 0, ptr %19, align 4
  call void @get_storage(ptr %heap_to_ptr18, ptr %heap_to_ptr16)
  %storage_value = load i64, ptr %heap_to_ptr16, align 4
  %20 = icmp eq i64 %storage_value, 0
  %21 = zext i1 %20 to i64
  call void @builtin_assert(i64 %21)
  %22 = load i64, ptr %sender, align 4
  %23 = add i64 %22, 0
  %24 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %24, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 %23, ptr %heap_to_ptr20, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %27, align 4
  %28 = call i64 @vector_new(i64 4)
  %heap_start21 = sub i64 %28, 4
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  store i64 1, ptr %heap_to_ptr22, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr22, i64 1
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr22, i64 2
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr22, i64 3
  store i64 0, ptr %31, align 4
  call void @set_storage(ptr %heap_to_ptr20, ptr %heap_to_ptr22)
  %32 = load i64, ptr %sender, align 4
  %33 = add i64 %32, 1
  %34 = load i64, ptr %proposal_, align 4
  %35 = call i64 @vector_new(i64 4)
  %heap_start23 = sub i64 %35, 4
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  store i64 %33, ptr %heap_to_ptr24, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr24, i64 1
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr24, i64 2
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %heap_to_ptr24, i64 3
  store i64 0, ptr %38, align 4
  %39 = call i64 @vector_new(i64 4)
  %heap_start25 = sub i64 %39, 4
  %heap_to_ptr26 = inttoptr i64 %heap_start25 to ptr
  store i64 %34, ptr %heap_to_ptr26, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr26, i64 1
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %heap_to_ptr26, i64 2
  store i64 0, ptr %41, align 4
  %42 = getelementptr i64, ptr %heap_to_ptr26, i64 3
  store i64 0, ptr %42, align 4
  call void @set_storage(ptr %heap_to_ptr24, ptr %heap_to_ptr26)
  %43 = load i64, ptr %proposal_, align 4
  %44 = call i64 @vector_new(i64 4)
  %heap_start27 = sub i64 %44, 4
  %heap_to_ptr28 = inttoptr i64 %heap_start27 to ptr
  %45 = call i64 @vector_new(i64 4)
  %heap_start29 = sub i64 %45, 4
  %heap_to_ptr30 = inttoptr i64 %heap_start29 to ptr
  store i64 1, ptr %heap_to_ptr30, align 4
  %46 = getelementptr i64, ptr %heap_to_ptr30, i64 1
  store i64 0, ptr %46, align 4
  %47 = getelementptr i64, ptr %heap_to_ptr30, i64 2
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %heap_to_ptr30, i64 3
  store i64 0, ptr %48, align 4
  call void @get_storage(ptr %heap_to_ptr30, ptr %heap_to_ptr28)
  %storage_value31 = load i64, ptr %heap_to_ptr28, align 4
  %49 = sub i64 %storage_value31, 1
  %50 = sub i64 %49, %43
  call void @builtin_range_check(i64 %50)
  %51 = call i64 @vector_new(i64 4)
  %heap_start32 = sub i64 %51, 4
  %heap_to_ptr33 = inttoptr i64 %heap_start32 to ptr
  store i64 1, ptr %heap_to_ptr33, align 4
  %52 = getelementptr i64, ptr %heap_to_ptr33, i64 1
  store i64 0, ptr %52, align 4
  %53 = getelementptr i64, ptr %heap_to_ptr33, i64 2
  store i64 0, ptr %53, align 4
  %54 = getelementptr i64, ptr %heap_to_ptr33, i64 3
  store i64 0, ptr %54, align 4
  %55 = call i64 @vector_new(i64 4)
  %heap_start34 = sub i64 %55, 4
  %heap_to_ptr35 = inttoptr i64 %heap_start34 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr33, ptr %heap_to_ptr35, i64 4)
  %56 = getelementptr i64, ptr %heap_to_ptr35, i64 3
  %57 = load i64, ptr %56, align 4
  %58 = mul i64 %43, 2
  %59 = add i64 %57, %58
  store i64 %59, ptr %56, align 4
  %60 = getelementptr i64, ptr %heap_to_ptr35, i64 3
  %slot_value = load i64, ptr %60, align 4
  %61 = add i64 %slot_value, 1
  %62 = load i64, ptr %proposal_, align 4
  %63 = call i64 @vector_new(i64 4)
  %heap_start36 = sub i64 %63, 4
  %heap_to_ptr37 = inttoptr i64 %heap_start36 to ptr
  %64 = call i64 @vector_new(i64 4)
  %heap_start38 = sub i64 %64, 4
  %heap_to_ptr39 = inttoptr i64 %heap_start38 to ptr
  store i64 1, ptr %heap_to_ptr39, align 4
  %65 = getelementptr i64, ptr %heap_to_ptr39, i64 1
  store i64 0, ptr %65, align 4
  %66 = getelementptr i64, ptr %heap_to_ptr39, i64 2
  store i64 0, ptr %66, align 4
  %67 = getelementptr i64, ptr %heap_to_ptr39, i64 3
  store i64 0, ptr %67, align 4
  call void @get_storage(ptr %heap_to_ptr39, ptr %heap_to_ptr37)
  %storage_value40 = load i64, ptr %heap_to_ptr37, align 4
  %68 = sub i64 %storage_value40, 1
  %69 = sub i64 %68, %62
  call void @builtin_range_check(i64 %69)
  %70 = call i64 @vector_new(i64 4)
  %heap_start41 = sub i64 %70, 4
  %heap_to_ptr42 = inttoptr i64 %heap_start41 to ptr
  store i64 1, ptr %heap_to_ptr42, align 4
  %71 = getelementptr i64, ptr %heap_to_ptr42, i64 1
  store i64 0, ptr %71, align 4
  %72 = getelementptr i64, ptr %heap_to_ptr42, i64 2
  store i64 0, ptr %72, align 4
  %73 = getelementptr i64, ptr %heap_to_ptr42, i64 3
  store i64 0, ptr %73, align 4
  %74 = call i64 @vector_new(i64 4)
  %heap_start43 = sub i64 %74, 4
  %heap_to_ptr44 = inttoptr i64 %heap_start43 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr42, ptr %heap_to_ptr44, i64 4)
  %75 = getelementptr i64, ptr %heap_to_ptr44, i64 3
  %76 = load i64, ptr %75, align 4
  %77 = mul i64 %62, 2
  %78 = add i64 %76, %77
  store i64 %78, ptr %75, align 4
  %79 = getelementptr i64, ptr %heap_to_ptr44, i64 3
  %slot_value45 = load i64, ptr %79, align 4
  %80 = add i64 %slot_value45, 1
  %81 = call i64 @vector_new(i64 4)
  %heap_start46 = sub i64 %81, 4
  %heap_to_ptr47 = inttoptr i64 %heap_start46 to ptr
  %82 = call i64 @vector_new(i64 4)
  %heap_start48 = sub i64 %82, 4
  %heap_to_ptr49 = inttoptr i64 %heap_start48 to ptr
  store i64 %80, ptr %heap_to_ptr49, align 4
  %83 = getelementptr i64, ptr %heap_to_ptr49, i64 1
  store i64 0, ptr %83, align 4
  %84 = getelementptr i64, ptr %heap_to_ptr49, i64 2
  store i64 0, ptr %84, align 4
  %85 = getelementptr i64, ptr %heap_to_ptr49, i64 3
  store i64 0, ptr %85, align 4
  call void @get_storage(ptr %heap_to_ptr49, ptr %heap_to_ptr47)
  %storage_value50 = load i64, ptr %heap_to_ptr47, align 4
  %86 = add i64 %storage_value50, 1
  call void @builtin_range_check(i64 %86)
  %87 = call i64 @vector_new(i64 4)
  %heap_start51 = sub i64 %87, 4
  %heap_to_ptr52 = inttoptr i64 %heap_start51 to ptr
  store i64 %61, ptr %heap_to_ptr52, align 4
  %88 = getelementptr i64, ptr %heap_to_ptr52, i64 1
  store i64 0, ptr %88, align 4
  %89 = getelementptr i64, ptr %heap_to_ptr52, i64 2
  store i64 0, ptr %89, align 4
  %90 = getelementptr i64, ptr %heap_to_ptr52, i64 3
  store i64 0, ptr %90, align 4
  %91 = call i64 @vector_new(i64 4)
  %heap_start53 = sub i64 %91, 4
  %heap_to_ptr54 = inttoptr i64 %heap_start53 to ptr
  store i64 %86, ptr %heap_to_ptr54, align 4
  %92 = getelementptr i64, ptr %heap_to_ptr54, i64 1
  store i64 0, ptr %92, align 4
  %93 = getelementptr i64, ptr %heap_to_ptr54, i64 2
  store i64 0, ptr %93, align 4
  %94 = getelementptr i64, ptr %heap_to_ptr54, i64 3
  store i64 0, ptr %94, align 4
  call void @set_storage(ptr %heap_to_ptr52, ptr %heap_to_ptr54)
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
