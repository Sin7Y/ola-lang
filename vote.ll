; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define void @contract_init(ptr %0) {
entry:
  %struct_alloca = alloca { ptr, i64 }, align 8
  %i = alloca i64, align 8
  %proposalNames_ = alloca ptr, align 8
  store ptr %0, ptr %proposalNames_, align 8
  %1 = call [4 x i64] @get_caller()
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %1)
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %2 = load i64, ptr %i, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %3 = icmp ult i64 %2, %length
  br i1 %3, label %body, label %endfor

body:                                             ; preds = %cond
  %4 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %5 = extractvalue [4 x i64] %4, 3
  %6 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %7 = extractvalue [4 x i64] %6, 3
  %8 = add i64 %7, %5
  %9 = insertvalue [4 x i64] %6, i64 %8, 3 ;  %9 是下一个要push storage位置
  %"struct member" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
  %10 = load i64, ptr %i, align 4
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 1
  %index_access = getelementptr { i64, ptr }, ptr %data, i64 %10
  store ptr %index_access, ptr %"struct member", align 8  ;存储proposalNames
  %"struct member3" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 0, ptr %"struct member3", align 4  ;存储voteCount
  %name = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
  %vector_len4 = getelementptr inbounds { i64, ptr }, ptr %name, i32 0, i32 0
  %length5 = load i64, ptr %vector_len4, align 4
  %11 = call [4 x i64] @get_storage([4 x i64] %9)
  %12 = extractvalue [4 x i64] %11, 3  ;proposals 的长度
  %13 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length5, 3  
  call void @set_storage([4 x i64] %9, [4 x i64] %13)
  %14 = extractvalue [4 x i64] %9, 0
  %15 = extractvalue [4 x i64] %9, 1
  %16 = extractvalue [4 x i64] %9, 2
  %17 = extractvalue [4 x i64] %9, 3
  %18 = insertvalue [8 x i64] undef, i64 %17, 7
  %19 = insertvalue [8 x i64] %18, i64 %16, 6
  %20 = insertvalue [8 x i64] %19, i64 %15, 5
  %21 = insertvalue [8 x i64] %20, i64 %14, 4
  %22 = insertvalue [8 x i64] %21, i64 0, 3
  %23 = insertvalue [8 x i64] %22, i64 0, 2
  %24 = insertvalue [8 x i64] %23, i64 0, 1
  %25 = insertvalue [8 x i64] %24, i64 0, 0
  %26 = call [4 x i64] @poseidon_hash([8 x i64] %25)
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  %27 = alloca [4 x i64], align 8
  store [4 x i64] %26, ptr %27, align 4
  br label %cond6

next:                                             ; preds = %done12
  %28 = load i64, ptr %i, align 4
  %29 = load i64, ptr %i, align 4
  %30 = add i64 %29, 1
  store i64 %30, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void

cond6:                                            ; preds = %body7, %body
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length5
  br i1 %loop_cond, label %body7, label %done

body7:                                            ; preds = %cond6
  %31 = load [4 x i64], ptr %27, align 4
  %data8 = getelementptr inbounds { i64, ptr }, ptr %name, i32 0, i32 1
  %index_access9 = getelementptr i64, ptr %data8, i64 %index_value
  %32 = load i64, ptr %index_access9, align 4
  %33 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %32, 3
  call void @set_storage([4 x i64] %31, [4 x i64] %33)
  %34 = extractvalue [4 x i64] %31, 3
  %35 = add i64 %34, 1
  %36 = insertvalue [4 x i64] %31, i64 %35, 3
  store [4 x i64] %36, ptr %27, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond6

done:                                             ; preds = %cond6
  %index_alloca13 = alloca i64, align 8
  store i64 %length5, ptr %index_alloca13, align 4
  %37 = alloca [4 x i64], align 8
  store [4 x i64] %26, ptr %37, align 4
  br label %cond10

cond10:                                           ; preds = %body11, %done
  %index_value14 = load i64, ptr %index_alloca13, align 4
  %loop_cond15 = icmp ult i64 %index_value14, %12
  br i1 %loop_cond15, label %body11, label %done12

body11:                                           ; preds = %cond10
  %38 = load [4 x i64], ptr %37, align 4
  call void @set_storage([4 x i64] %38, [4 x i64] zeroinitializer)
  %39 = extractvalue [4 x i64] %38, 3
  %40 = add i64 %39, 1
  %41 = insertvalue [4 x i64] %38, i64 %40, 3
  store [4 x i64] %41, ptr %37, align 4
  %next_index16 = add i64 %index_value14, 1
  store i64 %next_index16, ptr %index_alloca13, align 4
  br label %cond10

done12:                                           ; preds = %cond10
  %42 = extractvalue [4 x i64] %9, 3
  %43 = add i64 %42, 1
  %44 = insertvalue [4 x i64] %9, i64 %43, 3
  %voteCount = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
  %45 = load i64, ptr %voteCount, align 4
  %46 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %45, 3
  call void @set_storage([4 x i64] %44, [4 x i64] %46)
  %47 = extractvalue [4 x i64] %44, 3
  %48 = add i64 %47, 1
  %49 = insertvalue [4 x i64] %44, i64 %48, 3
  %new_length = add i64 %5, 1
  %50 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 3], [4 x i64] %50)
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
  %27 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %28 = add i64 %24, 1
  %29 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %28, 3
  %30 = call [4 x i64] @get_storage([4 x i64] %29)
  %31 = extractvalue [4 x i64] %30, 3
  %32 = add i64 %28, 1
  %33 = add i64 %31, 1
  call void @builtin_range_check(i64 %33)
  %34 = load i64, ptr %proposal_, align 4
  %35 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %36 = extractvalue [4 x i64] %35, 3
  %37 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %38 = add i64 %34, 1
  %39 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %38, 3
  %40 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %33, 3
  call void @set_storage([4 x i64] %39, [4 x i64] %40)
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
  %7 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %8 = add i64 %4, 1
  %9 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %8, 3
  %10 = call [4 x i64] @get_storage([4 x i64] %9)
  %11 = extractvalue [4 x i64] %10, 3
  %12 = add i64 %8, 1
  %13 = load i64, ptr %winningVoteCount, align 4
  %14 = icmp ugt i64 %11, %13
  br i1 %14, label %then, label %enif

next:                                             ; preds = %enif
  %15 = load i64, ptr %p, align 4
  %16 = load i64, ptr %p, align 4
  %17 = add i64 %16, 1
  store i64 %17, ptr %p, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %18 = load i64, ptr %winningProposal_, align 4
  ret i64 %18

then:                                             ; preds = %body
  %19 = load i64, ptr %p, align 4
  %20 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %21 = extractvalue [4 x i64] %20, 3
  %22 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %23 = add i64 %19, 1
  %24 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %23, 3
  %25 = call [4 x i64] @get_storage([4 x i64] %24)
  %26 = extractvalue [4 x i64] %25, 3
  %27 = add i64 %23, 1
  %28 = load i64, ptr %p, align 4
  br label %enif

enif:                                             ; preds = %then, %body
  br label %next
}

define ptr @getWinnerName() {
entry:
  %0 = call i64 @winningProposal()
  %1 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %2 = extractvalue [4 x i64] %1, 3
  %3 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %4 = add i64 %0, 0
  %5 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %4, 3
  %6 = call [4 x i64] @get_storage([4 x i64] %5)
  %7 = extractvalue [4 x i64] %6, 3
  %8 = add i64 %4, 1
  %9 = call ptr @vector_new(i64 %7, ptr null)
  %10 = insertvalue [8 x i64] undef, i64 %8, 7
  %11 = insertvalue [8 x i64] %10, i64 0, 6
  %12 = insertvalue [8 x i64] %11, i64 0, 5
  %13 = insertvalue [8 x i64] %12, i64 0, 4
  %14 = insertvalue [8 x i64] %13, i64 0, 3
  %15 = insertvalue [8 x i64] %14, i64 0, 2
  %16 = insertvalue [8 x i64] %15, i64 0, 1
  %17 = insertvalue [8 x i64] %16, i64 0, 0
  %18 = call [4 x i64] @poseidon_hash([8 x i64] %17)
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  %19 = alloca [4 x i64], align 8
  store [4 x i64] %18, ptr %19, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %7
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %20 = load [4 x i64], ptr %19, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %9, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 %index_value
  %21 = call [4 x i64] @get_storage([4 x i64] %20)
  %22 = extractvalue [4 x i64] %21, 3
  store i64 %22, ptr %index_access, align 4
  store [4 x i64] %20, ptr %19, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %23 = add i64 %8, 1
  ret ptr %9
}

define [4 x i64] @get_caller() {
entry:
  ret [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938]
}
