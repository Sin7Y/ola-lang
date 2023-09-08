; ModuleID = 'AssertContract'
source_filename = "examples/source/assert/bool_assert.ola"

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

define void @main() {
entry:
  %e = alloca i64, align 8
  %d = alloca i64, align 8
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 1, ptr %a, align 4
  store i64 2, ptr %b, align 4
  store i64 1, ptr %c, align 4
  store i64 1, ptr %d, align 4
  store i64 0, ptr %e, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %c, align 4
  %2 = icmp eq i64 %0, %1
  %3 = zext i1 %2 to i64
  call void @builtin_assert(i64 %3)
  %4 = load i64, ptr %a, align 4
  %5 = load i64, ptr %c, align 4
  %6 = icmp ule i64 %4, %5
  %7 = zext i1 %6 to i64
  call void @builtin_assert(i64 %7)
  %8 = load i64, ptr %a, align 4
  %9 = load i64, ptr %b, align 4
  %10 = icmp ne i64 %8, %9
  %11 = zext i1 %10 to i64
  call void @builtin_assert(i64 %11)
  %12 = load i64, ptr %b, align 4
  %13 = load i64, ptr %a, align 4
  %14 = icmp uge i64 %12, %13
  %15 = zext i1 %14 to i64
  call void @builtin_assert(i64 %15)
  %16 = load i64, ptr %d, align 4
  call void @builtin_assert(i64 %16)
  %17 = load i64, ptr %e, align 4
  %18 = icmp eq i64 %17, 0
  %19 = zext i1 %18 to i64
  call void @builtin_assert(i64 %19)
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3758009808, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @main()
  ret void
}

define void @call() {
entry:
  %0 = call i64 @vector_new(i64 1)
  %heap_start = sub i64 %0, 1
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 1)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 2)
  %heap_start1 = sub i64 %1, 2
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 2)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 2
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  ret void
}
