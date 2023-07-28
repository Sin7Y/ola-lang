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

define ptr @vector_new_init(i64 %0, ptr %1) {
entry:
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %0, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %1, ptr %vector_data, align 8
  ret ptr %vector_alloca
}

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define void @contract_init(ptr %0) {
entry:
  %1 = alloca [4 x i64], align 8
  %index_alloca13 = alloca i64, align 8
  %2 = alloca [4 x i64], align 8
  %index_alloca = alloca i64, align 8
  %struct_alloca = alloca { ptr, i64 }, align 8
  %i = alloca i64, align 8
  %proposalNames_ = alloca ptr, align 8
  store ptr %0, ptr %proposalNames_, align 8
  %3 = call [4 x i64] @get_caller()
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %3)
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %4 = load i64, ptr %i, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %5 = icmp ult i64 %4, %length
  br i1 %5, label %body, label %endfor

body:                                             ; preds = %cond
  %6 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %7 = extractvalue [4 x i64] %6, 3
  %8 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %9 = extractvalue [4 x i64] %8, 3
  %10 = add i64 %9, %7
  %11 = insertvalue [4 x i64] %8, i64 %10, 3
  %"struct member" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
  %12 = load i64, ptr %i, align 4
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %13 = sub i64 %length2, 1
  %14 = sub i64 %13, %12
  call void @builtin_range_check(i64 %14)
  %data = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 %12
  store ptr %index_access, ptr %"struct member", align 8
  %"struct member3" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 0, ptr %"struct member3", align 4
  %name = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
  %vector_len4 = getelementptr inbounds { i64, ptr }, ptr %name, i32 0, i32 0
  %length5 = load i64, ptr %vector_len4, align 4
  %15 = call [4 x i64] @get_storage([4 x i64] %11)
  %16 = extractvalue [4 x i64] %15, 3
  %17 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length5, 3
  call void @set_storage([4 x i64] %11, [4 x i64] %17)
  %18 = extractvalue [4 x i64] %11, 0
  %19 = extractvalue [4 x i64] %11, 1
  %20 = extractvalue [4 x i64] %11, 2
  %21 = extractvalue [4 x i64] %11, 3
  %22 = insertvalue [8 x i64] undef, i64 %21, 7
  %23 = insertvalue [8 x i64] %22, i64 %20, 6
  %24 = insertvalue [8 x i64] %23, i64 %19, 5
  %25 = insertvalue [8 x i64] %24, i64 %18, 4
  %26 = insertvalue [8 x i64] %25, i64 0, 3
  %27 = insertvalue [8 x i64] %26, i64 0, 2
  %28 = insertvalue [8 x i64] %27, i64 0, 1
  %29 = insertvalue [8 x i64] %28, i64 0, 0
  %30 = call [4 x i64] @poseidon_hash([8 x i64] %29)
  store i64 0, ptr %index_alloca, align 4
  store [4 x i64] %30, ptr %2, align 4
  br label %cond6

next:                                             ; preds = %done12
  %31 = load i64, ptr %i, align 4
  %32 = add i64 %31, 1
  store i64 %32, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void

cond6:                                            ; preds = %body7, %body
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length5
  br i1 %loop_cond, label %body7, label %done

body7:                                            ; preds = %cond6
  %33 = load [4 x i64], ptr %2, align 4
  %data8 = getelementptr inbounds { i64, ptr }, ptr %name, i32 0, i32 1
  %index_access9 = getelementptr i64, ptr %data8, i64 %index_value
  %34 = load i64, ptr %index_access9, align 4
  %35 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %34, 3
  call void @set_storage([4 x i64] %33, [4 x i64] %35)
  %36 = extractvalue [4 x i64] %33, 3
  %37 = add i64 %36, 1
  %38 = insertvalue [4 x i64] %33, i64 %37, 3
  store [4 x i64] %38, ptr %2, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond6

done:                                             ; preds = %cond6
  store i64 %length5, ptr %index_alloca13, align 4
  store [4 x i64] %30, ptr %1, align 4
  br label %cond10

cond10:                                           ; preds = %body11, %done
  %index_value14 = load i64, ptr %index_alloca13, align 4
  %loop_cond15 = icmp ult i64 %index_value14, %16
  br i1 %loop_cond15, label %body11, label %done12

body11:                                           ; preds = %cond10
  %39 = load [4 x i64], ptr %1, align 4
  call void @set_storage([4 x i64] %39, [4 x i64] zeroinitializer)
  %40 = extractvalue [4 x i64] %39, 3
  %41 = add i64 %40, 1
  %42 = insertvalue [4 x i64] %39, i64 %41, 3
  store [4 x i64] %42, ptr %1, align 4
  %next_index16 = add i64 %index_value14, 1
  store i64 %next_index16, ptr %index_alloca13, align 4
  br label %cond10

done12:                                           ; preds = %cond10
  %43 = extractvalue [4 x i64] %11, 3
  %44 = add i64 %43, 1
  %45 = insertvalue [4 x i64] %11, i64 %44, 3
  %voteCount = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
  %46 = load i64, ptr %voteCount, align 4
  %47 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %46, 3
  call void @set_storage([4 x i64] %45, [4 x i64] %47)
  %new_length = add i64 %7, 1
  %48 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2], [4 x i64] %48)
  br label %next
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
  %11 = insertvalue [8 x i64] %10, i64 1, 3
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
  br i1 %21, label %noassert, label %doassert

noassert:                                         ; preds = %entry
  %22 = load i64, ptr %sender, align 4
  %23 = add i64 %22, 0
  %24 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %23, 3
  call void @set_storage([4 x i64] %24, [4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %25 = load i64, ptr %sender, align 4
  %26 = add i64 %25, 1
  %27 = load i64, ptr %proposal_, align 4
  %28 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %26, 3
  %29 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %27, 3
  call void @set_storage([4 x i64] %28, [4 x i64] %29)
  %30 = load i64, ptr %proposal_, align 4
  %31 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %32 = extractvalue [4 x i64] %31, 3
  %33 = sub i64 %32, 1
  %34 = sub i64 %33, %30
  call void @builtin_range_check(i64 %34)
  %35 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %36 = extractvalue [4 x i64] %35, 3
  %37 = add i64 %36, %30
  %38 = insertvalue [4 x i64] %35, i64 %37, 3
  %39 = extractvalue [4 x i64] %38, 3
  %40 = add i64 %39, 1
  %41 = insertvalue [4 x i64] %38, i64 %40, 3
  %42 = load i64, ptr %proposal_, align 4
  %43 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %44 = extractvalue [4 x i64] %43, 3
  %45 = sub i64 %44, 1
  %46 = sub i64 %45, %42
  call void @builtin_range_check(i64 %46)
  %47 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %48 = extractvalue [4 x i64] %47, 3
  %49 = add i64 %48, %42
  %50 = insertvalue [4 x i64] %47, i64 %49, 3
  %51 = extractvalue [4 x i64] %50, 3
  %52 = add i64 %51, 1
  %53 = insertvalue [4 x i64] %50, i64 %52, 3
  %54 = call [4 x i64] @get_storage([4 x i64] %53)
  %55 = extractvalue [4 x i64] %54, 3
  %56 = add i64 %55, 1
  call void @builtin_range_check(i64 %56)
  %57 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %56, 3
  call void @set_storage([4 x i64] %41, [4 x i64] %57)
  ret void

doassert:                                         ; preds = %entry
  unreachable
}

define i64 @winningProposal() {
entry:
  %p = alloca i64, align 8
  %winningVoteCount = alloca i64, align 8
  %winningProposal_ = alloca i64, align 8
  store i64 0, ptr %winningProposal_, align 4
  store i64 0, ptr %winningVoteCount, align 4
  store i64 0, ptr %p, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %0 = load i64, ptr %p, align 4
  %1 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %2 = extractvalue [4 x i64] %1, 3
  %3 = icmp ult i64 %0, %2
  br i1 %3, label %body, label %endfor

body:                                             ; preds = %cond
  %4 = load i64, ptr %p, align 4
  %5 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %6 = extractvalue [4 x i64] %5, 3
  %7 = sub i64 %6, 1
  %8 = sub i64 %7, %4
  call void @builtin_range_check(i64 %8)
  %9 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %10 = extractvalue [4 x i64] %9, 3
  %11 = add i64 %10, %4
  %12 = insertvalue [4 x i64] %9, i64 %11, 3
  %13 = extractvalue [4 x i64] %12, 3
  %14 = add i64 %13, 1
  %15 = insertvalue [4 x i64] %12, i64 %14, 3
  %16 = call [4 x i64] @get_storage([4 x i64] %15)
  %17 = extractvalue [4 x i64] %16, 3
  %18 = load i64, ptr %winningVoteCount, align 4
  %19 = icmp ugt i64 %17, %18
  br i1 %19, label %then, label %enif

next:                                             ; preds = %enif
  %20 = load i64, ptr %p, align 4
  %21 = add i64 %20, 1
  store i64 %21, ptr %p, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %22 = load i64, ptr %winningProposal_, align 4
  ret i64 %22

then:                                             ; preds = %body
  %23 = load i64, ptr %p, align 4
  %24 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %25 = extractvalue [4 x i64] %24, 3
  %26 = sub i64 %25, 1
  %27 = sub i64 %26, %23
  call void @builtin_range_check(i64 %27)
  %28 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %29 = extractvalue [4 x i64] %28, 3
  %30 = add i64 %29, %23
  %31 = insertvalue [4 x i64] %28, i64 %30, 3
  %32 = extractvalue [4 x i64] %31, 3
  %33 = add i64 %32, 1
  %34 = insertvalue [4 x i64] %31, i64 %33, 3
  %35 = call [4 x i64] @get_storage([4 x i64] %34)
  %36 = extractvalue [4 x i64] %35, 3
  %37 = load i64, ptr %p, align 4
  br label %enif

enif:                                             ; preds = %then, %body
  br label %next
}

define ptr @getWinnerName() {
entry:
  %0 = alloca [4 x i64], align 8
  %index_alloca = alloca i64, align 8
  %1 = call i64 @winningProposal()
  %2 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %3 = extractvalue [4 x i64] %2, 3
  %4 = sub i64 %3, 1
  %5 = sub i64 %4, %1
  call void @builtin_range_check(i64 %5)
  %6 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %7 = extractvalue [4 x i64] %6, 3
  %8 = add i64 %7, %1
  %9 = insertvalue [4 x i64] %6, i64 %8, 3
  %10 = extractvalue [4 x i64] %9, 3
  %11 = add i64 %10, 0
  %12 = insertvalue [4 x i64] %9, i64 %11, 3
  %13 = call [4 x i64] @get_storage([4 x i64] %12)
  %14 = extractvalue [4 x i64] %13, 3
  %size = mul i64 %14, 1
  %15 = call i64 @vector_new(i64 %size)
  %heap_ptr = sub i64 %15, %size
  %int_to_ptr = inttoptr i64 %heap_ptr to ptr
  %16 = call ptr @vector_new_init(i64 %size, ptr %int_to_ptr)
  %17 = extractvalue [4 x i64] %12, 0
  %18 = extractvalue [4 x i64] %12, 1
  %19 = extractvalue [4 x i64] %12, 2
  %20 = extractvalue [4 x i64] %12, 3
  %21 = insertvalue [8 x i64] undef, i64 %20, 7
  %22 = insertvalue [8 x i64] %21, i64 %19, 6
  %23 = insertvalue [8 x i64] %22, i64 %18, 5
  %24 = insertvalue [8 x i64] %23, i64 %17, 4
  %25 = insertvalue [8 x i64] %24, i64 0, 3
  %26 = insertvalue [8 x i64] %25, i64 0, 2
  %27 = insertvalue [8 x i64] %26, i64 0, 1
  %28 = insertvalue [8 x i64] %27, i64 0, 0
  %29 = call [4 x i64] @poseidon_hash([8 x i64] %28)
  store i64 0, ptr %index_alloca, align 4
  store [4 x i64] %29, ptr %0, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %14
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %30 = load [4 x i64], ptr %0, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %16, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 %index_value
  %31 = call [4 x i64] @get_storage([4 x i64] %30)
  %32 = extractvalue [4 x i64] %31, 3
  store i64 %32, ptr %index_access, align 4
  store [4 x i64] %30, ptr %0, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret ptr %16
}

define [4 x i64] @get_caller() {
entry:
  ret [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938]
}

define void @main() {
entry:
  %0 = alloca [4 x i64], align 8
  %index_alloca69 = alloca i64, align 8
  %1 = alloca [4 x i64], align 8
  %index_alloca60 = alloca i64, align 8
  %struct_alloca = alloca { ptr, i64 }, align 8
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %2 = call i64 @vector_new(i64 3)
  %heap_ptr = sub i64 %2, 3
  %int_to_ptr = inttoptr i64 %heap_ptr to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr { i64, ptr }, ptr %int_to_ptr, i64 %index_value
  store ptr null, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %3 = call ptr @vector_new_init(i64 3, ptr %int_to_ptr)
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %4 = sub i64 %length, 1
  %5 = sub i64 %4, 0
  call void @builtin_range_check(i64 %5)
  %data = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 1
  %index_access1 = getelementptr ptr, ptr %data, i64 0
  %6 = call i64 @vector_new(i64 10)
  %heap_ptr2 = sub i64 %6, 10
  %int_to_ptr3 = inttoptr i64 %heap_ptr2 to ptr
  %index_access4 = getelementptr i64, ptr %int_to_ptr3, i64 0
  store i64 80, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %int_to_ptr3, i64 1
  store i64 114, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %int_to_ptr3, i64 2
  store i64 111, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %int_to_ptr3, i64 3
  store i64 112, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %int_to_ptr3, i64 4
  store i64 111, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %int_to_ptr3, i64 5
  store i64 115, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %int_to_ptr3, i64 6
  store i64 97, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %int_to_ptr3, i64 7
  store i64 108, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %int_to_ptr3, i64 8
  store i64 32, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %int_to_ptr3, i64 9
  store i64 49, ptr %index_access13, align 4
  %7 = call ptr @vector_new_init(i64 10, ptr %int_to_ptr3)
  store ptr %7, ptr %index_access1, align 8
  %vector_len14 = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 0
  %length15 = load i64, ptr %vector_len14, align 4
  %8 = sub i64 %length15, 1
  %9 = sub i64 %8, 1
  call void @builtin_range_check(i64 %9)
  %data16 = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 1
  %index_access17 = getelementptr ptr, ptr %data16, i64 1
  %10 = call i64 @vector_new(i64 10)
  %heap_ptr18 = sub i64 %10, 10
  %int_to_ptr19 = inttoptr i64 %heap_ptr18 to ptr
  %index_access20 = getelementptr i64, ptr %int_to_ptr19, i64 0
  store i64 80, ptr %index_access20, align 4
  %index_access21 = getelementptr i64, ptr %int_to_ptr19, i64 1
  store i64 114, ptr %index_access21, align 4
  %index_access22 = getelementptr i64, ptr %int_to_ptr19, i64 2
  store i64 111, ptr %index_access22, align 4
  %index_access23 = getelementptr i64, ptr %int_to_ptr19, i64 3
  store i64 112, ptr %index_access23, align 4
  %index_access24 = getelementptr i64, ptr %int_to_ptr19, i64 4
  store i64 111, ptr %index_access24, align 4
  %index_access25 = getelementptr i64, ptr %int_to_ptr19, i64 5
  store i64 115, ptr %index_access25, align 4
  %index_access26 = getelementptr i64, ptr %int_to_ptr19, i64 6
  store i64 97, ptr %index_access26, align 4
  %index_access27 = getelementptr i64, ptr %int_to_ptr19, i64 7
  store i64 108, ptr %index_access27, align 4
  %index_access28 = getelementptr i64, ptr %int_to_ptr19, i64 8
  store i64 32, ptr %index_access28, align 4
  %index_access29 = getelementptr i64, ptr %int_to_ptr19, i64 9
  store i64 50, ptr %index_access29, align 4
  %11 = call ptr @vector_new_init(i64 10, ptr %int_to_ptr19)
  store ptr %11, ptr %index_access17, align 8
  %vector_len30 = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 0
  %length31 = load i64, ptr %vector_len30, align 4
  %12 = sub i64 %length31, 1
  %13 = sub i64 %12, 2
  call void @builtin_range_check(i64 %13)
  %data32 = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 1
  %index_access33 = getelementptr ptr, ptr %data32, i64 2
  %14 = call i64 @vector_new(i64 10)
  %heap_ptr34 = sub i64 %14, 10
  %int_to_ptr35 = inttoptr i64 %heap_ptr34 to ptr
  %index_access36 = getelementptr i64, ptr %int_to_ptr35, i64 0
  store i64 80, ptr %index_access36, align 4
  %index_access37 = getelementptr i64, ptr %int_to_ptr35, i64 1
  store i64 114, ptr %index_access37, align 4
  %index_access38 = getelementptr i64, ptr %int_to_ptr35, i64 2
  store i64 111, ptr %index_access38, align 4
  %index_access39 = getelementptr i64, ptr %int_to_ptr35, i64 3
  store i64 112, ptr %index_access39, align 4
  %index_access40 = getelementptr i64, ptr %int_to_ptr35, i64 4
  store i64 111, ptr %index_access40, align 4
  %index_access41 = getelementptr i64, ptr %int_to_ptr35, i64 5
  store i64 115, ptr %index_access41, align 4
  %index_access42 = getelementptr i64, ptr %int_to_ptr35, i64 6
  store i64 97, ptr %index_access42, align 4
  %index_access43 = getelementptr i64, ptr %int_to_ptr35, i64 7
  store i64 108, ptr %index_access43, align 4
  %index_access44 = getelementptr i64, ptr %int_to_ptr35, i64 8
  store i64 32, ptr %index_access44, align 4
  %index_access45 = getelementptr i64, ptr %int_to_ptr35, i64 9
  store i64 51, ptr %index_access45, align 4
  %15 = call ptr @vector_new_init(i64 10, ptr %int_to_ptr35)
  store ptr %15, ptr %index_access33, align 8
  store i64 0, ptr %i, align 4
  br label %cond46

cond46:                                           ; preds = %next, %done
  %16 = load i64, ptr %i, align 4
  %vector_len48 = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 0
  %length49 = load i64, ptr %vector_len48, align 4
  %17 = icmp ult i64 %16, %length49
  br i1 %17, label %body47, label %endfor

body47:                                           ; preds = %cond46
  %18 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %19 = extractvalue [4 x i64] %18, 3
  %20 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %21 = extractvalue [4 x i64] %20, 3
  %22 = add i64 %21, %19
  %23 = insertvalue [4 x i64] %20, i64 %22, 3
  %"struct member" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
  %24 = load i64, ptr %i, align 4
  %vector_len50 = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 0
  %length51 = load i64, ptr %vector_len50, align 4
  %25 = sub i64 %length51, 1
  %26 = sub i64 %25, %24
  call void @builtin_range_check(i64 %26)
  %data52 = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 1
  %index_access53 = getelementptr ptr, ptr %data52, i64 %24
  store ptr %index_access53, ptr %"struct member", align 8
  %"struct member54" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 0, ptr %"struct member54", align 4
  %name = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
  %vector_len55 = getelementptr inbounds { i64, ptr }, ptr %name, i32 0, i32 0
  %length56 = load i64, ptr %vector_len55, align 4
  %27 = call [4 x i64] @get_storage([4 x i64] %23)
  %28 = extractvalue [4 x i64] %27, 3
  %29 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length56, 3
  call void @set_storage([4 x i64] %23, [4 x i64] %29)
  %30 = extractvalue [4 x i64] %23, 0
  %31 = extractvalue [4 x i64] %23, 1
  %32 = extractvalue [4 x i64] %23, 2
  %33 = extractvalue [4 x i64] %23, 3
  %34 = insertvalue [8 x i64] undef, i64 %33, 7
  %35 = insertvalue [8 x i64] %34, i64 %32, 6
  %36 = insertvalue [8 x i64] %35, i64 %31, 5
  %37 = insertvalue [8 x i64] %36, i64 %30, 4
  %38 = insertvalue [8 x i64] %37, i64 0, 3
  %39 = insertvalue [8 x i64] %38, i64 0, 2
  %40 = insertvalue [8 x i64] %39, i64 0, 1
  %41 = insertvalue [8 x i64] %40, i64 0, 0
  %42 = call [4 x i64] @poseidon_hash([8 x i64] %41)
  store i64 0, ptr %index_alloca60, align 4
  store [4 x i64] %42, ptr %1, align 4
  br label %cond57

next:                                             ; preds = %done68
  %43 = load i64, ptr %i, align 4
  %44 = add i64 %43, 1
  store i64 %44, ptr %i, align 4
  br label %cond46

endfor:                                           ; preds = %cond46
  ret void

cond57:                                           ; preds = %body58, %body47
  %index_value61 = load i64, ptr %index_alloca60, align 4
  %loop_cond62 = icmp ult i64 %index_value61, %length56
  br i1 %loop_cond62, label %body58, label %done59

body58:                                           ; preds = %cond57
  %45 = load [4 x i64], ptr %1, align 4
  %data63 = getelementptr inbounds { i64, ptr }, ptr %name, i32 0, i32 1
  %index_access64 = getelementptr i64, ptr %data63, i64 %index_value61
  %46 = load i64, ptr %index_access64, align 4
  %47 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %46, 3
  call void @set_storage([4 x i64] %45, [4 x i64] %47)
  %48 = extractvalue [4 x i64] %45, 3
  %49 = add i64 %48, 1
  %50 = insertvalue [4 x i64] %45, i64 %49, 3
  store [4 x i64] %50, ptr %1, align 4
  %next_index65 = add i64 %index_value61, 1
  store i64 %next_index65, ptr %index_alloca60, align 4
  br label %cond57

done59:                                           ; preds = %cond57
  store i64 %length56, ptr %index_alloca69, align 4
  store [4 x i64] %42, ptr %0, align 4
  br label %cond66

cond66:                                           ; preds = %body67, %done59
  %index_value70 = load i64, ptr %index_alloca69, align 4
  %loop_cond71 = icmp ult i64 %index_value70, %28
  br i1 %loop_cond71, label %body67, label %done68

body67:                                           ; preds = %cond66
  %51 = load [4 x i64], ptr %0, align 4
  call void @set_storage([4 x i64] %51, [4 x i64] zeroinitializer)
  %52 = extractvalue [4 x i64] %51, 3
  %53 = add i64 %52, 1
  %54 = insertvalue [4 x i64] %51, i64 %53, 3
  store [4 x i64] %54, ptr %0, align 4
  %next_index72 = add i64 %index_value70, 1
  store i64 %next_index72, ptr %index_alloca69, align 4
  br label %cond66

done68:                                           ; preds = %cond66
  %55 = extractvalue [4 x i64] %23, 3
  %56 = add i64 %55, 1
  %57 = insertvalue [4 x i64] %23, i64 %56, 3
  %voteCount = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
  %58 = load i64, ptr %voteCount, align 4
  %59 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %58, 3
  call void @set_storage([4 x i64] %57, [4 x i64] %59)
  %new_length = add i64 %19, 1
  %60 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2], [4 x i64] %60)
  br label %next
}

define void @function_dispatch(i64 %0, i64 %1, i64 %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3920769769, label %func_0_dispatch
    i64 2791810083, label %func_1_dispatch
    i64 3186728800, label %func_2_dispatch
    i64 363199787, label %func_3_dispatch
    i64 2868727644, label %func_4_dispatch
    i64 3501063903, label %func_5_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %offset_var = alloca i64, align 8
  store i64 0, ptr %offset_var, align 4
  %3 = load i64, ptr %offset_var, align 4
  %4 = call i64 @tape_load(i64 %2, i64 %3)
  %5 = add i64 %3, 1
  %6 = icmp ule i64 %5, %1
  br i1 %6, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  store i64 %5, ptr %offset_var, align 4
  %size = mul i64 %4, 1
  %7 = call i64 @vector_new(i64 %size)
  %heap_ptr = sub i64 %7, %size
  %int_to_ptr = inttoptr i64 %heap_ptr to ptr
  %8 = call ptr @vector_new_init(i64 %size, ptr %int_to_ptr)
  store ptr %8, ptr null, align 8
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

cond:                                             ; preds = %next, %inbounds
  %length = load i64, ptr null, align 4
  %9 = icmp ult i64 %index, %length
  br i1 %9, label %body, label %end_for

next:                                             ; preds = %loop_end
  %index14 = load i64, ptr %index_ptr, align 4
  %10 = add i64 %index14, 1
  store i64 %10, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %11 = call i64 @tape_load(i64 %2, i64 %3)
  %12 = add i64 1, %11
  %13 = add i64 %3, 1
  %14 = icmp ule i64 %13, %1
  br i1 %14, label %inbounds1, label %out_of_bounds2

end_for:                                          ; preds = %cond
  %15 = load ptr, ptr null, align 8
  %16 = load i64, ptr %offset_var, align 4
  %17 = sub i64 %16, 0
  %18 = add i64 0, %17
  %19 = icmp ult i64 %18, %1
  br i1 %19, label %not_all_bytes_read, label %buffer_read

inbounds1:                                        ; preds = %body
  %20 = add i64 %3, %12
  %21 = icmp ule i64 %20, %1
  br i1 %21, label %inbounds3, label %out_of_bounds4

out_of_bounds2:                                   ; preds = %body
  unreachable

inbounds3:                                        ; preds = %inbounds1
  %size5 = mul i64 %11, 1
  %22 = call i64 @vector_new(i64 %size5)
  %heap_ptr6 = sub i64 %22, %size5
  %int_to_ptr7 = inttoptr i64 %heap_ptr6 to ptr
  %23 = call ptr @vector_new_init(i64 %size5, ptr %int_to_ptr7)
  %data = getelementptr inbounds { i64, ptr }, ptr %23, i32 0, i32 1
  %index_ptr8 = alloca i64, align 8
  store i64 0, ptr %index_ptr8, align 4
  br label %loop_body

out_of_bounds4:                                   ; preds = %inbounds1
  unreachable

loop_body:                                        ; preds = %inbounds10, %inbounds3
  %index9 = load i64, ptr %index_ptr8, align 4
  %element = getelementptr i64, ptr %data, i64 %index9
  %24 = add i64 %13, 1
  %25 = icmp ule i64 %24, %1
  br i1 %25, label %inbounds10, label %out_of_bounds11

loop_end:                                         ; preds = %inbounds10
  %26 = load ptr, ptr null, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %26, i32 0, i32 0
  %length12 = load i64, ptr %vector_len, align 4
  %27 = sub i64 %length12, 1
  %28 = sub i64 %27, %index
  call void @builtin_range_check(i64 %28)
  %data13 = getelementptr inbounds { i64, ptr }, ptr %26, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data13, i64 %index
  store ptr %23, ptr %26, align 8
  %29 = add i64 %3, %12
  store i64 %29, ptr %offset_var, align 4
  br label %next

inbounds10:                                       ; preds = %loop_body
  %30 = call i64 @tape_load(i64 %2, i64 %13)
  %offset = add i64 %13, 1
  store i64 %30, ptr %element, align 4
  %next_index = add i64 %index9, 1
  store i64 %next_index, ptr %index_ptr8, align 4
  %index_cond = icmp ult i64 %next_index, %11
  br i1 %index_cond, label %loop_body, label %loop_end

out_of_bounds11:                                  ; preds = %loop_body
  unreachable

not_all_bytes_read:                               ; preds = %end_for
  unreachable

buffer_read:                                      ; preds = %end_for
  call void @contract_init(ptr %15)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %31 = icmp ule i64 1, %1
  br i1 %31, label %inbounds15, label %out_of_bounds16

inbounds15:                                       ; preds = %func_1_dispatch
  %32 = call i64 @tape_load(i64 %2, i64 0)
  %33 = icmp ult i64 1, %1
  br i1 %33, label %not_all_bytes_read17, label %buffer_read18

out_of_bounds16:                                  ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read17:                             ; preds = %inbounds15
  unreachable

buffer_read18:                                    ; preds = %inbounds15
  call void @vote_proposal(i64 %32)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %34 = call i64 @winningProposal()
  call void @tape_store(i64 0, i64 %34)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %35 = call ptr @getWinnerName()
  %vector_len19 = getelementptr inbounds { i64, ptr }, ptr %35, i32 0, i32 0
  %length20 = load i64, ptr %vector_len19, align 4
  call void @tape_store(i64 0, i64 %length20)
  %data21 = getelementptr inbounds { i64, ptr }, ptr %35, i32 0, i32 1
  %index_ptr24 = alloca i64, align 8
  store i64 0, ptr %index_ptr24, align 4
  br label %loop_body22

loop_body22:                                      ; preds = %loop_body22, %func_3_dispatch
  %index25 = load i64, ptr %index_ptr24, align 4
  %element26 = getelementptr { i64, ptr }, ptr %data21, i64 %index25
  %elem = load i64, ptr %element26, align 4
  call void @tape_store(i64 1, i64 %elem)
  %next_index27 = add i64 %index25, 1
  store i64 %next_index27, ptr %index_ptr24, align 4
  %index_cond28 = icmp ult i64 %next_index27, %length20
  br i1 %index_cond28, label %loop_body22, label %loop_end23

loop_end23:                                       ; preds = %loop_body22
  %36 = add i64 %length20, 1
  %37 = add i64 0, %36
  ret void

func_4_dispatch:                                  ; preds = %entry
  %38 = call [4 x i64] @get_caller()
  %39 = extractvalue [4 x i64] %38, 0
  call void @tape_store(i64 0, i64 %39)
  %40 = extractvalue [4 x i64] %38, 1
  call void @tape_store(i64 1, i64 %40)
  %41 = extractvalue [4 x i64] %38, 2
  call void @tape_store(i64 2, i64 %41)
  %42 = extractvalue [4 x i64] %38, 3
  call void @tape_store(i64 3, i64 %42)
  ret void

func_5_dispatch:                                  ; preds = %entry
  call void @main()
  ret void
}

define void @call() {
entry:
  %0 = call ptr @contract_input()
  %input_selector = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 0
  %selector = load i64, ptr %input_selector, align 4
  %input_len = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 1
  %len = load i64, ptr %input_len, align 4
  %input_data = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 2
  %data = load i64, ptr %input_data, align 4
  call void @function_dispatch(i64 %selector, i64 %len, i64 %data)
  unreachable
}
