; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define ptr @getWinnerName() {
entry:
  %0 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %1 = extractvalue [4 x i64] %0, 3
  %2 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %3 = extractvalue [4 x i64] %2, 3
  %4 = add i64 %3, 1
  %5 = insertvalue [4 x i64] %2, i64 %4, 3
  %6 = extractvalue [4 x i64] %5, 3
  %7 = add i64 %6, 0
  %8 = insertvalue [4 x i64] %5, i64 %7, 3
  %9 = call [4 x i64] @get_storage([4 x i64] %8)
  %10 = extractvalue [4 x i64] %9, 3
  %11 = call i64 @vector_new(i64 %10)
  %int_to_ptr = inttoptr i64 %11 to ptr
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %10, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  %12 = extractvalue [4 x i64] %8, 0
  %13 = extractvalue [4 x i64] %8, 1
  %14 = extractvalue [4 x i64] %8, 2
  %15 = extractvalue [4 x i64] %8, 3
  %16 = insertvalue [8 x i64] undef, i64 %15, 7
  %17 = insertvalue [8 x i64] %16, i64 %14, 6
  %18 = insertvalue [8 x i64] %17, i64 %13, 5
  %19 = insertvalue [8 x i64] %18, i64 %12, 4
  %20 = insertvalue [8 x i64] %19, i64 0, 3
  %21 = insertvalue [8 x i64] %20, i64 0, 2
  %22 = insertvalue [8 x i64] %21, i64 0, 1
  %23 = insertvalue [8 x i64] %22, i64 0, 0
  %24 = call [4 x i64] @poseidon_hash([8 x i64] %23)
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  %25 = alloca [4 x i64], align 8
  store [4 x i64] %24, ptr %25, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %10
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %26 = load [4 x i64], ptr %25, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 %index_value
  %27 = call [4 x i64] @get_storage([4 x i64] %26)
  %28 = extractvalue [4 x i64] %27, 3
  store i64 %28, ptr %index_access, align 4
  store [4 x i64] %26, ptr %25, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret ptr %vector_alloca
}
