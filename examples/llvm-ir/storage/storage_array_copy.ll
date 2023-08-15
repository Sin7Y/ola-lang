; ModuleID = 'StorageToStorage'
source_filename = "examples/source/storage/storage_array_copy.ola"

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

define void @setArray1(ptr %0) {
entry:
  %1 = alloca [4 x i64], align 8
  %index_alloca4 = alloca i64, align 8
  %2 = alloca [4 x i64], align 8
  %index_alloca = alloca i64, align 8
  %length = load i64, ptr %0, align 4
  %3 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %4 = extractvalue [4 x i64] %3, 3
  %5 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length, 3
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %5)
  %6 = call [4 x i64] @poseidon_hash([8 x i64] zeroinitializer)
  store i64 0, ptr %index_alloca, align 4
  store [4 x i64] %6, ptr %2, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %7 = load [4 x i64], ptr %2, align 4
  %8 = ptrtoint ptr %0 to i64
  %9 = add i64 %8, 1
  %vector_data = inttoptr i64 %9 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  %10 = load i64, ptr %index_access, align 4
  %11 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %10, 3
  call void @set_storage([4 x i64] %7, [4 x i64] %11)
  %12 = extractvalue [4 x i64] %7, 3
  %13 = add i64 %12, 1
  %14 = insertvalue [4 x i64] %7, i64 %13, 3
  store [4 x i64] %14, ptr %2, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %length, ptr %index_alloca4, align 4
  store [4 x i64] %6, ptr %1, align 4
  br label %cond1

cond1:                                            ; preds = %body2, %done
  %index_value5 = load i64, ptr %index_alloca4, align 4
  %loop_cond6 = icmp ult i64 %index_value5, %4
  br i1 %loop_cond6, label %body2, label %done3

body2:                                            ; preds = %cond1
  %15 = load [4 x i64], ptr %1, align 4
  call void @set_storage([4 x i64] %15, [4 x i64] zeroinitializer)
  %16 = extractvalue [4 x i64] %15, 3
  %17 = add i64 %16, 1
  %18 = insertvalue [4 x i64] %15, i64 %17, 3
  store [4 x i64] %18, ptr %1, align 4
  %next_index7 = add i64 %index_value5, 1
  store i64 %next_index7, ptr %index_alloca4, align 4
  br label %cond1

done3:                                            ; preds = %cond1
  ret void
}
