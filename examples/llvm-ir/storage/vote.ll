; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote.ola"

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

define void @contract_init(ptr %0) {
entry:
  %struct_alloca = alloca { i64, i64 }, align 8
  %i = alloca i64, align 8
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %1 = load i64, ptr %i, align 4
  %length = load i64, ptr %0, align 4
  %2 = icmp ult i64 %1, %length
  br i1 %2, label %body, label %endfor

body:                                             ; preds = %cond
  %3 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %4 = extractvalue [4 x i64] %3, 3
  %5 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %6 = extractvalue [4 x i64] %5, 3
  %7 = mul i64 %4, 2
  %8 = add i64 %6, %7
  %9 = insertvalue [4 x i64] %5, i64 %8, 3
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %10 = load i64, ptr %i, align 4
  %length1 = load i64, ptr %0, align 4
  %11 = sub i64 %length1, 1
  %12 = sub i64 %11, %10
  call void @builtin_range_check(i64 %12)
  %13 = ptrtoint ptr %0 to i64
  %14 = add i64 %13, 1
  %vector_data = inttoptr i64 %14 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %10
  %15 = load i64, ptr %index_access, align 4
  store i64 %15, ptr %"struct member", align 4
  %"struct member2" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 0, ptr %"struct member2", align 4
  %name = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %16 = load i64, ptr %name, align 4
  %17 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %16, 3
  call void @set_storage([4 x i64] %9, [4 x i64] %17)
  %18 = extractvalue [4 x i64] %9, 3
  %19 = add i64 %18, 1
  %20 = insertvalue [4 x i64] %9, i64 %19, 3
  %voteCount = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  %21 = load i64, ptr %voteCount, align 4
  %22 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %21, 3
  call void @set_storage([4 x i64] %20, [4 x i64] %22)
  %new_length = add i64 %4, 1
  %23 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1], [4 x i64] %23)
  br label %next

next:                                             ; preds = %body
  %24 = load i64, ptr %i, align 4
  %25 = add i64 %24, 1
  store i64 %25, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void
}

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
  %16 = extractvalue [4 x i64] %15, 3
  %17 = add i64 %16, 0
  %18 = insertvalue [4 x i64] %15, i64 %17, 3
  %19 = call [4 x i64] @get_storage([4 x i64] %18)
  %20 = extractvalue [4 x i64] %19, 3
  %21 = icmp eq i64 %20, 0
  %22 = zext i1 %21 to i64
  call void @builtin_assert(i64 %22)
  %23 = load [4 x i64], ptr %msgSender, align 4
  %24 = extractvalue [4 x i64] %23, 0
  %25 = extractvalue [4 x i64] %23, 1
  %26 = extractvalue [4 x i64] %23, 2
  %27 = extractvalue [4 x i64] %23, 3
  %28 = insertvalue [8 x i64] undef, i64 %27, 7
  %29 = insertvalue [8 x i64] %28, i64 %26, 6
  %30 = insertvalue [8 x i64] %29, i64 %25, 5
  %31 = insertvalue [8 x i64] %30, i64 %24, 4
  %32 = insertvalue [8 x i64] %31, i64 0, 3
  %33 = insertvalue [8 x i64] %32, i64 0, 2
  %34 = insertvalue [8 x i64] %33, i64 0, 1
  %35 = insertvalue [8 x i64] %34, i64 0, 0
  %36 = call [4 x i64] @poseidon_hash([8 x i64] %35)
  store [4 x i64] %36, ptr %sender, align 4
  %37 = load i64, ptr %sender, align 4
  %38 = add i64 %37, 0
  %39 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %38, 3
  call void @set_storage([4 x i64] %39, [4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %40 = load i64, ptr %sender, align 4
  %41 = add i64 %40, 1
  %42 = load i64, ptr %proposal_, align 4
  %43 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %41, 3
  %44 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %42, 3
  call void @set_storage([4 x i64] %43, [4 x i64] %44)
  %45 = load i64, ptr %proposal_, align 4
  %46 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %47 = extractvalue [4 x i64] %46, 3
  %48 = sub i64 %47, 1
  %49 = sub i64 %48, %45
  call void @builtin_range_check(i64 %49)
  %50 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %51 = extractvalue [4 x i64] %50, 3
  %52 = mul i64 %45, 2
  %53 = add i64 %51, %52
  %54 = insertvalue [4 x i64] %50, i64 %53, 3
  %55 = extractvalue [4 x i64] %54, 3
  %56 = add i64 %55, 1
  %57 = insertvalue [4 x i64] %54, i64 %56, 3
  %58 = load i64, ptr %proposal_, align 4
  %59 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %60 = extractvalue [4 x i64] %59, 3
  %61 = sub i64 %60, 1
  %62 = sub i64 %61, %58
  call void @builtin_range_check(i64 %62)
  %63 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %64 = extractvalue [4 x i64] %63, 3
  %65 = mul i64 %58, 2
  %66 = add i64 %64, %65
  %67 = insertvalue [4 x i64] %63, i64 %66, 3
  %68 = extractvalue [4 x i64] %67, 3
  %69 = add i64 %68, 1
  %70 = insertvalue [4 x i64] %67, i64 %69, 3
  %71 = call [4 x i64] @get_storage([4 x i64] %70)
  %72 = extractvalue [4 x i64] %71, 3
  %73 = add i64 %72, 1
  call void @builtin_range_check(i64 %73)
  %74 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %73, 3
  call void @set_storage([4 x i64] %57, [4 x i64] %74)
  ret void
}

define [4 x i64] @get_caller() {
entry:
  ret [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938]
}

define void @main() {
entry:
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
  call void @contract_init(ptr %heap_start_ptr)
  call void @vote_proposal(i64 1)
  %15 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %16 = extractvalue [4 x i64] %15, 3
  %17 = sub i64 %16, 1
  %18 = sub i64 %17, 1
  call void @builtin_range_check(i64 %18)
  %19 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %20 = extractvalue [4 x i64] %19, 3
  %21 = add i64 %20, 2
  %22 = insertvalue [4 x i64] %19, i64 %21, 3
  %23 = extractvalue [4 x i64] %22, 3
  %24 = add i64 %23, 1
  %25 = insertvalue [4 x i64] %22, i64 %24, 3
  %26 = call [4 x i64] @get_storage([4 x i64] %25)
  %27 = extractvalue [4 x i64] %26, 3
  %28 = icmp eq i64 %27, 1
  %29 = zext i1 %28 to i64
  call void @builtin_assert(i64 %29)
  ret void
}