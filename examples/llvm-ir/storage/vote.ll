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
  %slot = alloca i64, align 8
  store i64 0, ptr %slot, align 4
  %2 = load i64, ptr %slot, align 4
  %3 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %2, 3
  call void @set_storage([4 x i64] %3, [4 x i64] %1)
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %4 = load i64, ptr %i, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %5 = icmp ult i64 %4, %length
  br i1 %5, label %body, label %endfor

body:                                             ; preds = %cond
  %slot1 = alloca i64, align 8
  store i64 2, ptr %slot1, align 4
  %6 = load i64, ptr %slot1, align 4
  %7 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %6, 3
  %8 = call [4 x i64] @get_storage([4 x i64] %7)
  %9 = extractvalue [4 x i64] %8, 3
  %10 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %11 = extractvalue [4 x i64] %10, 3
  %12 = add i64 %11, %9
  %13 = insertvalue [4 x i64] %10, i64 %12, 3
  %"struct member" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
  %14 = load i64, ptr %i, align 4
  %vector_len2 = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 0
  %length3 = load i64, ptr %vector_len2, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 1
  %index_access = getelementptr { i64, ptr }, ptr %data, i64 %14
  store ptr %index_access, ptr %"struct member", align 8
  %"struct member4" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 0, ptr %"struct member4", align 4
  %slot5 = alloca [4 x i64], align 8
  %name = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
  store [4 x i64] %13, ptr %slot5, align 4
  %vector_len6 = getelementptr inbounds { i64, ptr }, ptr %name, i32 0, i32 0
  %length7 = load i64, ptr %vector_len6, align 4
  store [4 x i64] %13, ptr %slot5, align 4
  %15 = load [4 x i64], ptr %slot5, align 4
  %16 = call [4 x i64] @get_storage([4 x i64] %15)
  %17 = extractvalue [4 x i64] %16, 3
  %18 = extractvalue [4 x i64] %13, 3
  %19 = add i64 %18, 1
  %20 = insertvalue [4 x i64] %13, i64 %19, 3
  %21 = load [4 x i64], ptr %slot5, align 4
  %22 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length7, 3
  call void @set_storage([4 x i64] %21, [4 x i64] %22)
  %23 = load [4 x i64], ptr %slot5, align 4
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
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  %37 = alloca [4 x i64], align 8
  store [4 x i64] %36, ptr %37, align 4
  br label %cond8

next:                                             ; preds = %done14
  %38 = load i64, ptr %i, align 4
  %39 = add i64 %38, 1
  store i64 %39, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void

cond8:                                            ; preds = %body9, %body
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length7
  br i1 %loop_cond, label %body9, label %done

body9:                                            ; preds = %cond8
  %40 = load [4 x i64], ptr %37, align 4
  %data10 = getelementptr inbounds { i64, ptr }, ptr %name, i32 0, i32 1
  %index_access11 = getelementptr i64, ptr %data10, i64 %index_value
  store [4 x i64] %40, ptr %slot5, align 4
  %41 = load i64, ptr %index_access11, align 4
  %42 = load [4 x i64], ptr %slot5, align 4
  %43 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %41, 3
  call void @set_storage([4 x i64] %42, [4 x i64] %43)
  %44 = extractvalue [4 x i64] %40, 3
  %45 = add i64 %44, 1
  %46 = insertvalue [4 x i64] %40, i64 %45, 3
  store [4 x i64] %46, ptr %37, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond8

done:                                             ; preds = %cond8
  %index_alloca15 = alloca i64, align 8
  store i64 %length7, ptr %index_alloca15, align 4
  %47 = alloca [4 x i64], align 8
  store [4 x i64] %36, ptr %47, align 4
  br label %cond12

cond12:                                           ; preds = %body13, %done
  %index_value16 = load i64, ptr %index_alloca15, align 4
  %loop_cond17 = icmp ult i64 %index_value16, %17
  br i1 %loop_cond17, label %body13, label %done14

body13:                                           ; preds = %cond12
  %48 = load [4 x i64], ptr %47, align 4
  store [4 x i64] %48, ptr %slot5, align 4
  %49 = load [4 x i64], ptr %slot5, align 4
  call void @set_storage([4 x i64] %49, [4 x i64] zeroinitializer)
  %50 = extractvalue [4 x i64] %48, 3
  %51 = add i64 %50, 1
  %52 = insertvalue [4 x i64] %48, i64 %51, 3
  store [4 x i64] %52, ptr %47, align 4
  %next_index18 = add i64 %index_value16, 1
  store i64 %next_index18, ptr %index_alloca15, align 4
  br label %cond12

done14:                                           ; preds = %cond12
  %53 = extractvalue [4 x i64] %20, 3
  %54 = add i64 %53, 1
  %55 = insertvalue [4 x i64] %20, i64 %54, 3
  %voteCount = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
  store [4 x i64] %55, ptr %slot5, align 4
  %56 = load i64, ptr %voteCount, align 4
  %57 = load [4 x i64], ptr %slot5, align 4
  %58 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %56, 3
  call void @set_storage([4 x i64] %57, [4 x i64] %58)
  %59 = extractvalue [4 x i64] %55, 3
  %60 = add i64 %59, 1
  %61 = insertvalue [4 x i64] %55, i64 %60, 3
  %new_length = add i64 %9, 1
  %slot19 = alloca i64, align 8
  store i64 2, ptr %slot19, align 4
  %62 = load i64, ptr %slot19, align 4
  %63 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %62, 3
  %64 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] %63, [4 x i64] %64)
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
  %slot = alloca i64, align 8
  store i64 %17, ptr %slot, align 4
  %18 = load i64, ptr %slot, align 4
  %19 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %18, 3
  call void @set_storage([4 x i64] %19, [4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %20 = load i64, ptr %proposal_, align 4
  %21 = load i64, ptr %sender, align 4
  %22 = add i64 %21, 1
  %slot1 = alloca i64, align 8
  store i64 %22, ptr %slot1, align 4
  %23 = load i64, ptr %slot1, align 4
  %24 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %23, 3
  %25 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %20, 3
  call void @set_storage([4 x i64] %24, [4 x i64] %25)
  %26 = load i64, ptr %proposal_, align 4
  %slot2 = alloca i64, align 8
  store i64 2, ptr %slot2, align 4
  %27 = load i64, ptr %slot2, align 4
  %28 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %27, 3
  %29 = call [4 x i64] @get_storage([4 x i64] %28)
  %30 = extractvalue [4 x i64] %29, 3
  %31 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %32 = extractvalue [4 x i64] %31, 3
  %33 = add i64 %32, %26
  %34 = insertvalue [4 x i64] %31, i64 %33, 3
  %35 = extractvalue [4 x i64] %34, 3
  %36 = add i64 %35, 1
  %37 = insertvalue [4 x i64] %34, i64 %36, 3
  %slot3 = alloca [4 x i64], align 8
  store [4 x i64] %37, ptr %slot3, align 4
  %38 = load [4 x i64], ptr %slot3, align 4
  %39 = call [4 x i64] @get_storage([4 x i64] %38)
  %40 = extractvalue [4 x i64] %39, 3
  %41 = extractvalue [4 x i64] %37, 3
  %42 = add i64 %41, 1
  %43 = insertvalue [4 x i64] %37, i64 %42, 3
  %44 = add i64 %40, 1
  call void @builtin_range_check(i64 %44)
  %45 = load i64, ptr %proposal_, align 4
  %slot4 = alloca i64, align 8
  store i64 2, ptr %slot4, align 4
  %46 = load i64, ptr %slot4, align 4
  %47 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %46, 3
  %48 = call [4 x i64] @get_storage([4 x i64] %47)
  %49 = extractvalue [4 x i64] %48, 3
  %50 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %51 = extractvalue [4 x i64] %50, 3
  %52 = add i64 %51, %45
  %53 = insertvalue [4 x i64] %50, i64 %52, 3
  %54 = extractvalue [4 x i64] %53, 3
  %55 = add i64 %54, 1
  %56 = insertvalue [4 x i64] %53, i64 %55, 3
  %slot5 = alloca [4 x i64], align 8
  store [4 x i64] %56, ptr %slot5, align 4
  %57 = load [4 x i64], ptr %slot5, align 4
  %58 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %44, 3
  call void @set_storage([4 x i64] %57, [4 x i64] %58)
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
  %slot = alloca i64, align 8
  store i64 2, ptr %slot, align 4
  %1 = load i64, ptr %slot, align 4
  %2 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %1, 3
  %3 = call [4 x i64] @get_storage([4 x i64] %2)
  %4 = extractvalue [4 x i64] %3, 3
  %5 = icmp ult i64 %0, %4
  br i1 %5, label %body, label %endfor

body:                                             ; preds = %cond
  %6 = load i64, ptr %p, align 4
  %slot1 = alloca i64, align 8
  store i64 2, ptr %slot1, align 4
  %7 = load i64, ptr %slot1, align 4
  %8 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %7, 3
  %9 = call [4 x i64] @get_storage([4 x i64] %8)
  %10 = extractvalue [4 x i64] %9, 3
  %11 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %12 = extractvalue [4 x i64] %11, 3
  %13 = add i64 %12, %6
  %14 = insertvalue [4 x i64] %11, i64 %13, 3
  %15 = extractvalue [4 x i64] %14, 3
  %16 = add i64 %15, 1
  %17 = insertvalue [4 x i64] %14, i64 %16, 3
  %slot2 = alloca [4 x i64], align 8
  store [4 x i64] %17, ptr %slot2, align 4
  %18 = load [4 x i64], ptr %slot2, align 4
  %19 = call [4 x i64] @get_storage([4 x i64] %18)
  %20 = extractvalue [4 x i64] %19, 3
  %21 = extractvalue [4 x i64] %17, 3
  %22 = add i64 %21, 1
  %23 = insertvalue [4 x i64] %17, i64 %22, 3
  %24 = load i64, ptr %winningVoteCount, align 4
  %25 = icmp ugt i64 %20, %24
  br i1 %25, label %then, label %enif

next:                                             ; preds = %enif
  %26 = load i64, ptr %p, align 4
  %27 = add i64 %26, 1
  store i64 %27, ptr %p, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %28 = load i64, ptr %winningProposal_, align 4
  ret i64 %28

then:                                             ; preds = %body
  %29 = load i64, ptr %p, align 4
  %slot3 = alloca i64, align 8
  store i64 2, ptr %slot3, align 4
  %30 = load i64, ptr %slot3, align 4
  %31 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %30, 3
  %32 = call [4 x i64] @get_storage([4 x i64] %31)
  %33 = extractvalue [4 x i64] %32, 3
  %34 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %35 = extractvalue [4 x i64] %34, 3
  %36 = add i64 %35, %29
  %37 = insertvalue [4 x i64] %34, i64 %36, 3
  %38 = extractvalue [4 x i64] %37, 3
  %39 = add i64 %38, 1
  %40 = insertvalue [4 x i64] %37, i64 %39, 3
  %slot4 = alloca [4 x i64], align 8
  store [4 x i64] %40, ptr %slot4, align 4
  %41 = load [4 x i64], ptr %slot4, align 4
  %42 = call [4 x i64] @get_storage([4 x i64] %41)
  %43 = extractvalue [4 x i64] %42, 3
  %44 = extractvalue [4 x i64] %40, 3
  %45 = add i64 %44, 1
  %46 = insertvalue [4 x i64] %40, i64 %45, 3
  %47 = load i64, ptr %p, align 4
  br label %enif

enif:                                             ; preds = %then, %body
  br label %next
}

define ptr @getWinnerName() {
entry:
  %0 = call i64 @winningProposal()
  %slot = alloca i64, align 8
  store i64 2, ptr %slot, align 4
  %1 = load i64, ptr %slot, align 4
  %2 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %1, 3
  %3 = call [4 x i64] @get_storage([4 x i64] %2)
  %4 = extractvalue [4 x i64] %3, 3
  %5 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %6 = extractvalue [4 x i64] %5, 3
  %7 = add i64 %6, %0
  %8 = insertvalue [4 x i64] %5, i64 %7, 3
  %9 = extractvalue [4 x i64] %8, 3
  %10 = add i64 %9, 0
  %11 = insertvalue [4 x i64] %8, i64 %10, 3
  %slot1 = alloca [4 x i64], align 8
  store [4 x i64] %11, ptr %slot1, align 4
  store [4 x i64] %11, ptr %slot1, align 4
  %12 = load [4 x i64], ptr %slot1, align 4
  %13 = call [4 x i64] @get_storage([4 x i64] %12)
  %14 = extractvalue [4 x i64] %13, 3
  %15 = extractvalue [4 x i64] %11, 3
  %16 = add i64 %15, 1
  %17 = insertvalue [4 x i64] %11, i64 %16, 3
  %18 = call ptr @vector_new(i64 %14, ptr null)
  %19 = load [4 x i64], ptr %slot1, align 4
  %20 = extractvalue [4 x i64] %19, 0
  %21 = extractvalue [4 x i64] %19, 1
  %22 = extractvalue [4 x i64] %19, 2
  %23 = extractvalue [4 x i64] %19, 3
  %24 = insertvalue [8 x i64] undef, i64 %23, 7
  %25 = insertvalue [8 x i64] %24, i64 %22, 6
  %26 = insertvalue [8 x i64] %25, i64 %21, 5
  %27 = insertvalue [8 x i64] %26, i64 %20, 4
  %28 = insertvalue [8 x i64] %27, i64 0, 3
  %29 = insertvalue [8 x i64] %28, i64 0, 2
  %30 = insertvalue [8 x i64] %29, i64 0, 1
  %31 = insertvalue [8 x i64] %30, i64 0, 0
  %32 = call [4 x i64] @poseidon_hash([8 x i64] %31)
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  %33 = alloca [4 x i64], align 8
  store [4 x i64] %32, ptr %33, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %14
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %34 = load [4 x i64], ptr %33, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %18, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 %index_value
  store [4 x i64] %34, ptr %slot1, align 4
  %35 = load [4 x i64], ptr %slot1, align 4
  %36 = call [4 x i64] @get_storage([4 x i64] %35)
  %37 = extractvalue [4 x i64] %36, 3
  %38 = extractvalue [4 x i64] %34, 3
  %39 = add i64 %38, 1
  %40 = insertvalue [4 x i64] %34, i64 %39, 3
  store i64 %37, ptr %index_access, align 4
  store [4 x i64] %40, ptr %33, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %41 = extractvalue [4 x i64] %17, 3
  %42 = add i64 %41, 1
  %43 = insertvalue [4 x i64] %17, i64 %42, 3
  ret ptr %18
}

define [4 x i64] @get_caller() {
entry:
  ret [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938]
}
