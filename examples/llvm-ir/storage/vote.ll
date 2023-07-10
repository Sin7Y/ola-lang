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
  %index_access = getelementptr { i64, ptr }, ptr %data, i64 %12
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
  call void @set_storage([4 x i64] %18, [4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %19 = load i64, ptr %proposal_, align 4
  %20 = load i64, ptr %sender, align 4
  %21 = add i64 %20, 1
  %22 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %21, 3
  %23 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %19, 3
  call void @set_storage([4 x i64] %22, [4 x i64] %23)
  %24 = load i64, ptr %proposal_, align 4
  %25 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %26 = extractvalue [4 x i64] %25, 3
  %27 = sub i64 %26, 1
  %28 = sub i64 %27, %24
  call void @builtin_range_check(i64 %28)
  %29 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %30 = extractvalue [4 x i64] %29, 3
  %31 = add i64 %30, %24
  %32 = insertvalue [4 x i64] %29, i64 %31, 3
  %33 = extractvalue [4 x i64] %32, 3
  %34 = add i64 %33, 1
  %35 = insertvalue [4 x i64] %32, i64 %34, 3
  %36 = call [4 x i64] @get_storage([4 x i64] %35)
  %37 = extractvalue [4 x i64] %36, 3
  %38 = add i64 %37, 1
  call void @builtin_range_check(i64 %38)
  %39 = load i64, ptr %proposal_, align 4
  %40 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %41 = extractvalue [4 x i64] %40, 3
  %42 = sub i64 %41, 1
  %43 = sub i64 %42, %39
  call void @builtin_range_check(i64 %43)
  %44 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %45 = extractvalue [4 x i64] %44, 3
  %46 = add i64 %45, %39
  %47 = insertvalue [4 x i64] %44, i64 %46, 3
  %48 = extractvalue [4 x i64] %47, 3
  %49 = add i64 %48, 1
  %50 = insertvalue [4 x i64] %47, i64 %49, 3
  %51 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %38, 3
  call void @set_storage([4 x i64] %50, [4 x i64] %51)
  ret void
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
  %vector_alloca = alloca { i64, ptr }, align 8
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
  %15 = call i64 @vector_new(i64 %14)
  %int_to_ptr = inttoptr i64 %15 to ptr
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %14, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  %16 = extractvalue [4 x i64] %12, 0
  %17 = extractvalue [4 x i64] %12, 1
  %18 = extractvalue [4 x i64] %12, 2
  %19 = extractvalue [4 x i64] %12, 3
  %20 = insertvalue [8 x i64] undef, i64 %19, 7
  %21 = insertvalue [8 x i64] %20, i64 %18, 6
  %22 = insertvalue [8 x i64] %21, i64 %17, 5
  %23 = insertvalue [8 x i64] %22, i64 %16, 4
  %24 = insertvalue [8 x i64] %23, i64 0, 3
  %25 = insertvalue [8 x i64] %24, i64 0, 2
  %26 = insertvalue [8 x i64] %25, i64 0, 1
  %27 = insertvalue [8 x i64] %26, i64 0, 0
  %28 = call [4 x i64] @poseidon_hash([8 x i64] %27)
  store i64 0, ptr %index_alloca, align 4
  store [4 x i64] %28, ptr %0, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %14
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %29 = load [4 x i64], ptr %0, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 %index_value
  %30 = call [4 x i64] @get_storage([4 x i64] %29)
  %31 = extractvalue [4 x i64] %30, 3
  store i64 %31, ptr %index_access, align 4
  store [4 x i64] %29, ptr %0, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret ptr %vector_alloca
}

define [4 x i64] @get_caller() {
entry:
  ret [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938]
}

define void @main() {
entry:
  %vector_alloca46 = alloca { i64, ptr }, align 8
  %vector_alloca28 = alloca { i64, ptr }, align 8
  %vector_alloca12 = alloca { i64, ptr }, align 8
  %vector_alloca = alloca { i64, ptr }, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 3)
  %int_to_ptr = inttoptr i64 %0 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %int_to_ptr, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 3, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  %1 = call i64 @vector_new(i64 10)
  %int_to_ptr1 = inttoptr i64 %1 to ptr
  %index_access2 = getelementptr i64, ptr %int_to_ptr1, i64 0
  store i64 80, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %int_to_ptr1, i64 1
  store i64 114, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %int_to_ptr1, i64 2
  store i64 111, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %int_to_ptr1, i64 3
  store i64 112, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %int_to_ptr1, i64 4
  store i64 111, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %int_to_ptr1, i64 5
  store i64 115, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %int_to_ptr1, i64 6
  store i64 97, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %int_to_ptr1, i64 7
  store i64 108, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %int_to_ptr1, i64 8
  store i64 32, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %int_to_ptr1, i64 9
  store i64 49, ptr %index_access11, align 4
  %vector_len13 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca12, i32 0, i32 0
  store i64 10, ptr %vector_len13, align 4
  %vector_data14 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca12, i32 0, i32 1
  store ptr %int_to_ptr1, ptr %vector_data14, align 8
  %vector_len15 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length = load i64, ptr %vector_len15, align 4
  %2 = sub i64 %length, 1
  %3 = sub i64 %2, 0
  call void @builtin_range_check(i64 %3)
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access16 = getelementptr { i64, ptr }, ptr %data, i64 0
  store ptr %vector_alloca12, ptr %index_access16, align 8
  %4 = call i64 @vector_new(i64 10)
  %int_to_ptr17 = inttoptr i64 %4 to ptr
  %index_access18 = getelementptr i64, ptr %int_to_ptr17, i64 0
  store i64 80, ptr %index_access18, align 4
  %index_access19 = getelementptr i64, ptr %int_to_ptr17, i64 1
  store i64 114, ptr %index_access19, align 4
  %index_access20 = getelementptr i64, ptr %int_to_ptr17, i64 2
  store i64 111, ptr %index_access20, align 4
  %index_access21 = getelementptr i64, ptr %int_to_ptr17, i64 3
  store i64 112, ptr %index_access21, align 4
  %index_access22 = getelementptr i64, ptr %int_to_ptr17, i64 4
  store i64 111, ptr %index_access22, align 4
  %index_access23 = getelementptr i64, ptr %int_to_ptr17, i64 5
  store i64 115, ptr %index_access23, align 4
  %index_access24 = getelementptr i64, ptr %int_to_ptr17, i64 6
  store i64 97, ptr %index_access24, align 4
  %index_access25 = getelementptr i64, ptr %int_to_ptr17, i64 7
  store i64 108, ptr %index_access25, align 4
  %index_access26 = getelementptr i64, ptr %int_to_ptr17, i64 8
  store i64 32, ptr %index_access26, align 4
  %index_access27 = getelementptr i64, ptr %int_to_ptr17, i64 9
  store i64 50, ptr %index_access27, align 4
  %vector_len29 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca28, i32 0, i32 0
  store i64 10, ptr %vector_len29, align 4
  %vector_data30 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca28, i32 0, i32 1
  store ptr %int_to_ptr17, ptr %vector_data30, align 8
  %vector_len31 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length32 = load i64, ptr %vector_len31, align 4
  %5 = sub i64 %length32, 1
  %6 = sub i64 %5, 1
  call void @builtin_range_check(i64 %6)
  %data33 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access34 = getelementptr { i64, ptr }, ptr %data33, i64 1
  store ptr %vector_alloca28, ptr %index_access34, align 8
  %7 = call i64 @vector_new(i64 10)
  %int_to_ptr35 = inttoptr i64 %7 to ptr
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
  %vector_len47 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca46, i32 0, i32 0
  store i64 10, ptr %vector_len47, align 4
  %vector_data48 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca46, i32 0, i32 1
  store ptr %int_to_ptr35, ptr %vector_data48, align 8
  %vector_len49 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length50 = load i64, ptr %vector_len49, align 4
  %8 = sub i64 %length50, 1
  %9 = sub i64 %8, 2
  call void @builtin_range_check(i64 %9)
  %data51 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access52 = getelementptr { i64, ptr }, ptr %data51, i64 2
  store ptr %vector_alloca46, ptr %index_access52, align 8
  call void @contract_init(ptr %vector_alloca)
  call void @vote_proposal(i64 0)
  call void @vote_proposal(i64 1)
  call void @vote_proposal(i64 0)
  %10 = call ptr @getWinnerName()
  ret void
}
