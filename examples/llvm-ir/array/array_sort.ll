; ModuleID = 'ArraySortExample'
source_filename = "examples/source/array/array_sort.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

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

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define void @main() {
entry:
  %array_literal = alloca [10 x i64], align 8
  %elemptr0 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 0
  store i64 3, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 1
  store i64 4, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 2
  store i64 5, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 3
  store i64 1, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 4
  store i64 7, ptr %elemptr4, align 4
  %elemptr5 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 5
  store i64 9, ptr %elemptr5, align 4
  %elemptr6 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 6
  store i64 0, ptr %elemptr6, align 4
  %elemptr7 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 7
  store i64 2, ptr %elemptr7, align 4
  %elemptr8 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 8
  store i64 8, ptr %elemptr8, align 4
  %elemptr9 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 9
  store i64 6, ptr %elemptr9, align 4
  %0 = call ptr @array_sort_test(ptr %array_literal)
  %length = load i64, ptr %0, align 4
  %1 = sub i64 %length, 1
  %2 = sub i64 %1, 0
  call void @builtin_range_check(i64 %2)
  %3 = ptrtoint ptr %0 to i64
  %4 = add i64 %3, 1
  %vector_data = inttoptr i64 %4 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  %length1 = load i64, ptr %0, align 4
  %5 = sub i64 %length1, 1
  %6 = sub i64 %5, 0
  call void @builtin_range_check(i64 %6)
  %7 = ptrtoint ptr %0 to i64
  %8 = add i64 %7, 1
  %vector_data2 = inttoptr i64 %8 to ptr
  %index_access3 = getelementptr i64, ptr %vector_data2, i64 0
  %9 = load i64, ptr %index_access3, align 4
  %10 = add i64 %9, 1
  call void @builtin_range_check(i64 %10)
  store i64 %10, ptr %index_access, align 4
  %length4 = load i64, ptr %0, align 4
  %11 = sub i64 %length4, 1
  %12 = sub i64 %11, 1
  call void @builtin_range_check(i64 %12)
  %13 = ptrtoint ptr %0 to i64
  %14 = add i64 %13, 1
  %vector_data5 = inttoptr i64 %14 to ptr
  %index_access6 = getelementptr i64, ptr %vector_data5, i64 1
  %length7 = load i64, ptr %0, align 4
  %15 = sub i64 %length7, 1
  %16 = sub i64 %15, 1
  call void @builtin_range_check(i64 %16)
  %17 = ptrtoint ptr %0 to i64
  %18 = add i64 %17, 1
  %vector_data8 = inttoptr i64 %18 to ptr
  %index_access9 = getelementptr i64, ptr %vector_data8, i64 1
  %19 = load i64, ptr %index_access9, align 4
  %20 = sub i64 %19, 1
  call void @builtin_range_check(i64 %20)
  store i64 %20, ptr %index_access6, align 4
  ret void
}

define ptr @array_sort_test(ptr %0) {
entry:
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %1 = call i64 @vector_new(i64 11)
  %heap_start = sub i64 %1, 11
  %heap_start_ptr = inttoptr i64 %heap_start to ptr
  store i64 10, ptr %heap_start_ptr, align 4
  %2 = ptrtoint ptr %heap_start_ptr to i64
  %3 = add i64 %2, 1
  %vector_data = inttoptr i64 %3 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 10
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %i, align 4
  br label %cond1

cond1:                                            ; preds = %next, %done
  %4 = load i64, ptr %i, align 4
  %5 = icmp ult i64 %4, 10
  br i1 %5, label %body2, label %endfor

body2:                                            ; preds = %cond1
  %6 = load i64, ptr %i, align 4
  %length = load i64, ptr %heap_start_ptr, align 4
  %7 = sub i64 %length, 1
  %8 = sub i64 %7, %6
  call void @builtin_range_check(i64 %8)
  %9 = ptrtoint ptr %heap_start_ptr to i64
  %10 = add i64 %9, 1
  %vector_data3 = inttoptr i64 %10 to ptr
  %index_access4 = getelementptr i64, ptr %vector_data3, i64 %6
  %11 = load i64, ptr %i, align 4
  %12 = sub i64 9, %11
  call void @builtin_range_check(i64 %12)
  %index_access5 = getelementptr [10 x i64], ptr %0, i64 0, i64 %11
  %13 = load i64, ptr %index_access5, align 4
  store i64 %13, ptr %index_access4, align 4
  br label %next

next:                                             ; preds = %body2
  %14 = load i64, ptr %i, align 4
  %15 = add i64 %14, 1
  call void @builtin_range_check(i64 %15)
  br label %cond1

endfor:                                           ; preds = %cond1
  %length6 = load i64, ptr %heap_start_ptr, align 4
  %16 = call ptr @prophet_u32_array_sort(ptr %heap_start_ptr, i64 %length6)
  ret ptr %16
}
