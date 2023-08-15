; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote.ola"

@heap_address = internal global i64 -4294967353

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

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define void @main() {
entry:
  %struct_alloca = alloca { i64, i64 }, align 8
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_start_ptr = inttoptr i64 %heap_start to ptr
  store i64 3, ptr %heap_start_ptr, align 4
  %1 = ptrtoint ptr %heap_start_ptr to i64
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %length = load i64, ptr %heap_start_ptr, align 4
  %3 = sub i64 %length, 1
  %4 = sub i64 %3, 0
  call void @builtin_range_check(i64 %4)
  %5 = ptrtoint ptr %heap_start_ptr to i64
  %6 = add i64 %5, 1
  %vector_data1 = inttoptr i64 %6 to ptr
  %index_access2 = getelementptr i64, ptr %vector_data1, i64 0
  store i64 65, ptr %index_access2, align 4
  %length3 = load i64, ptr %heap_start_ptr, align 4
  %7 = sub i64 %length3, 1
  %8 = sub i64 %7, 1
  call void @builtin_range_check(i64 %8)
  %9 = ptrtoint ptr %heap_start_ptr to i64
  %10 = add i64 %9, 1
  %vector_data4 = inttoptr i64 %10 to ptr
  %index_access5 = getelementptr i64, ptr %vector_data4, i64 1
  store i64 66, ptr %index_access5, align 4
  %length6 = load i64, ptr %heap_start_ptr, align 4
  %11 = sub i64 %length6, 1
  %12 = sub i64 %11, 2
  call void @builtin_range_check(i64 %12)
  %13 = ptrtoint ptr %heap_start_ptr to i64
  %14 = add i64 %13, 1
  %vector_data7 = inttoptr i64 %14 to ptr
  %index_access8 = getelementptr i64, ptr %vector_data7, i64 2
  store i64 67, ptr %index_access8, align 4
  store i64 0, ptr %i, align 4
  br label %cond9

cond9:                                            ; preds = %next, %done
  %15 = load i64, ptr %i, align 4
  %length11 = load i64, ptr %heap_start_ptr, align 4
  %16 = icmp ult i64 %15, %length11
  br i1 %16, label %body10, label %endfor

body10:                                           ; preds = %cond9
  %17 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %18 = extractvalue [4 x i64] %17, 3
  %19 = call [4 x i64] @poseidon_hash([8 x i64] zeroinitializer)
  %20 = extractvalue [4 x i64] %19, 3
  %21 = add i64 %20, %18
  %22 = insertvalue [4 x i64] %19, i64 %21, 3
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %23 = load i64, ptr %i, align 4
  %length12 = load i64, ptr %heap_start_ptr, align 4
  %24 = sub i64 %length12, 1
  %25 = sub i64 %24, %23
  call void @builtin_range_check(i64 %25)
  %26 = ptrtoint ptr %heap_start_ptr to i64
  %27 = add i64 %26, 1
  %vector_data13 = inttoptr i64 %27 to ptr
  %index_access14 = getelementptr i64, ptr %vector_data13, i64 %23
  %28 = load i64, ptr %index_access14, align 4
  store i64 %28, ptr %"struct member", align 4
  %"struct member15" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  %29 = load i64, ptr %i, align 4
  store i64 %29, ptr %"struct member15", align 4
  %name = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %30 = load i64, ptr %name, align 4
  %31 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %30, 3
  call void @set_storage([4 x i64] %22, [4 x i64] %31)
  %32 = extractvalue [4 x i64] %22, 3
  %33 = add i64 %32, 1
  %34 = insertvalue [4 x i64] %22, i64 %33, 3
  %voteCount = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  %35 = load i64, ptr %voteCount, align 4
  %36 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %35, 3
  call void @set_storage([4 x i64] %34, [4 x i64] %36)
  %new_length = add i64 %18, 1
  %37 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %37)
  br label %next

next:                                             ; preds = %body10
  %38 = load i64, ptr %i, align 4
  %39 = add i64 %38, 1
  store i64 %39, ptr %i, align 4
  br label %cond9

endfor:                                           ; preds = %cond9
  %length16 = load i64, ptr %heap_start_ptr, align 4
  %40 = sub i64 %length16, 1
  %41 = sub i64 %40, 1
  call void @builtin_range_check(i64 %41)
  %42 = ptrtoint ptr %heap_start_ptr to i64
  %43 = add i64 %42, 1
  %vector_data17 = inttoptr i64 %43 to ptr
  %index_access18 = getelementptr i64, ptr %vector_data17, i64 1
  %44 = load i64, ptr %index_access18, align 4
  call void @builtin_assert(i64 %44, i64 66)
  ret void
}
