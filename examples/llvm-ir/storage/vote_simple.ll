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

declare void @get_call_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define void @vote_proposal(i64 %0) {
entry:
  %sender = alloca i64, align 8
  %msgSender = alloca [4 x i64], align 8
  %proposal_ = alloca i64, align 8
  store i64 %0, ptr %proposal_, align 4
  %1 = call [4 x i64] @get_caller()
  store [4 x i64] %1, ptr %msgSender, align 4
  %2 = load [4 x i64], ptr %msgSender, align 4
  %3 = extractvalue [4 x i64] %2, 0
  %4 = extractvalue [4 x i64] %2, 1
  %5 = extractvalue [4 x i64] %2, 2
  %6 = extractvalue [4 x i64] %2, 3
  %7 = insertvalue [8 x i64] undef, i64 %6, 7
  %8 = insertvalue [8 x i64] %7, i64 %5, 6
  %9 = insertvalue [8 x i64] %8, i64 %4, 5
  %10 = insertvalue [8 x i64] %9, i64 %3, 4
  %11 = insertvalue [8 x i64] %10, i64 0, 3
  %12 = insertvalue [8 x i64] %11, i64 0, 2
  %13 = insertvalue [8 x i64] %12, i64 0, 1
  %14 = insertvalue [8 x i64] %13, i64 0, 0
  %15 = call [4 x i64] @poseidon_hash([8 x i64] %14)
  store [4 x i64] %15, ptr %sender, align 4
  %16 = load i64, ptr %sender, align 4
  %17 = add i64 %16, 0
  %18 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %17, 3
  %19 = call [4 x i64] @get_storage([4 x i64] %18)
  %20 = extractvalue [4 x i64] %19, 3
  %21 = icmp eq i64 %20, 0
  %22 = zext i1 %21 to i64
  call void @builtin_assert(i64 %22)
  %23 = load i64, ptr %sender, align 4
  %24 = add i64 %23, 0
  %25 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %24, 3
  call void @set_storage([4 x i64] %25, [4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %26 = load i64, ptr %sender, align 4
  %27 = add i64 %26, 1
  %28 = load i64, ptr %proposal_, align 4
  %29 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %27, 3
  %30 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %28, 3
  call void @set_storage([4 x i64] %29, [4 x i64] %30)
  %31 = load i64, ptr %proposal_, align 4
  %32 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %33 = extractvalue [4 x i64] %32, 3
  %34 = sub i64 %33, 1
  %35 = sub i64 %34, %31
  call void @builtin_range_check(i64 %35)
  %36 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %37 = extractvalue [4 x i64] %36, 3
  %38 = mul i64 %31, 2
  %39 = add i64 %37, %38
  %40 = insertvalue [4 x i64] %36, i64 %39, 3
  %41 = extractvalue [4 x i64] %40, 3
  %42 = add i64 %41, 1
  %43 = insertvalue [4 x i64] %40, i64 %42, 3
  %44 = load i64, ptr %proposal_, align 4
  %45 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %46 = extractvalue [4 x i64] %45, 3
  %47 = sub i64 %46, 1
  %48 = sub i64 %47, %44
  call void @builtin_range_check(i64 %48)
  %49 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %50 = extractvalue [4 x i64] %49, 3
  %51 = mul i64 %44, 2
  %52 = add i64 %50, %51
  %53 = insertvalue [4 x i64] %49, i64 %52, 3
  %54 = extractvalue [4 x i64] %53, 3
  %55 = add i64 %54, 1
  %56 = insertvalue [4 x i64] %53, i64 %55, 3
  %57 = call [4 x i64] @get_storage([4 x i64] %56)
  %58 = extractvalue [4 x i64] %57, 3
  %59 = add i64 %58, 1
  call void @builtin_range_check(i64 %59)
  %60 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %59, 3
  call void @set_storage([4 x i64] %43, [4 x i64] %60)
  ret void
}

define [4 x i64] @get_caller() {
entry:
  ret [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938]
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
  %5 = call [4 x i64] @get_caller()
  %6 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %6, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %7 = extractvalue [4 x i64] %5, 0
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %7, ptr %start1, align 4
  %8 = extractvalue [4 x i64] %5, 1
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %8, ptr %start2, align 4
  %9 = extractvalue [4 x i64] %5, 2
  %start3 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %9, ptr %start3, align 4
  %10 = extractvalue [4 x i64] %5, 3
  %start4 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %10, ptr %start4, align 4
  call void @set_tape_data(i64 %heap_start, i64 4)
  ret void
}

define void @call() {
entry:
  %0 = call i64 @vector_new(i64 1)
  %heap_start = sub i64 %0, 1
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_call_data(i64 %heap_start, i64 0)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 1)
  %heap_start1 = sub i64 %1, 1
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_call_data(i64 %heap_start1, i64 1)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = call i64 @vector_new(i64 %input_length)
  %heap_start3 = sub i64 %2, %input_length
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_call_data(i64 %heap_start3, i64 2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  unreachable
}
