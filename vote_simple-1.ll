; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote_simple.ola"

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
  %struct_alloca = alloca { i64, i64 }, align 8
  %i = alloca i64, align 8
  %proposalNames_ = alloca ptr, align 8
  store ptr %0, ptr %proposalNames_, align 8
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %1 = load i64, ptr %i, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %2 = icmp ult i64 %1, %length
  br i1 %2, label %body, label %endfor

body:                                             ; preds = %cond
  %slot = alloca i64, align 8
  store i64 1, ptr %slot, align 4
  %3 = load i64, ptr %slot, align 4
  %4 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %3, 3
  %5 = call [4 x i64] @get_storage([4 x i64] %4)
  %6 = extractvalue [4 x i64] %5, 3
  %7 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %8 = extractvalue [4 x i64] %7, 3
  %9 = add i64 %8, %6
  %10 = insertvalue [4 x i64] %7, i64 %9, 3
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %11 = load i64, ptr %i, align 4
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 %11
  %12 = load i64, ptr %index_access, align 4
  store i64 %12, ptr %"struct member", align 4
  %"struct member3" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 0, ptr %"struct member3", align 4


  %slot4 = alloca [4 x i64], align 8
  %name = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  store [4 x i64] %10, ptr %slot4, align 4
  %13 = load i64, ptr %name, align 4
  %14 = load [4 x i64], ptr %slot4, align 4
  %15 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %13, 3
  call void @set_storage([4 x i64] %14, [4 x i64] %15)
  %16 = extractvalue [4 x i64] %10, 3
  %17 = add i64 %16, 1
  %18 = insertvalue [4 x i64] %10, i64 %17, 3
  %voteCount = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  store [4 x i64] %18, ptr %slot4, align 4
  %19 = load i64, ptr %voteCount, align 4
  %20 = load [4 x i64], ptr %slot4, align 4
  %21 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %19, 3
  call void @set_storage([4 x i64] %20, [4 x i64] %21)
  %22 = extractvalue [4 x i64] %18, 3
  %23 = add i64 %22, 1
  %24 = insertvalue [4 x i64] %18, i64 %23, 3
  %new_length = add i64 %6, 1
  %slot5 = alloca i64, align 8
  store i64 1, ptr %slot5, align 4
  %25 = load i64, ptr %slot5, align 4
  %26 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %25, 3
  %27 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] %26, [4 x i64] %27)
  br label %next

next:                                             ; preds = %body
  %28 = load i64, ptr %i, align 4
  %29 = add i64 %28, 1
  store i64 %29, ptr %i, align 4
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
  store i64 1, ptr %slot2, align 4
  %27 = load i64, ptr %slot2, align 4
  %28 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %27, 3
  %29 = call [4 x i64] @get_storage([4 x i64] %28)
  %30 = extractvalue [4 x i64] %29, 3
  %31 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
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
  store i64 1, ptr %slot4, align 4
  %46 = load i64, ptr %slot4, align 4
  %47 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %46, 3
  %48 = call [4 x i64] @get_storage([4 x i64] %47)
  %49 = extractvalue [4 x i64] %48, 3
  %50 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
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
  store i64 1, ptr %slot, align 4
  %1 = load i64, ptr %slot, align 4
  %2 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %1, 3
  %3 = call [4 x i64] @get_storage([4 x i64] %2)
  %4 = extractvalue [4 x i64] %3, 3
  %5 = icmp ult i64 %0, %4
  br i1 %5, label %body, label %endfor

body:                                             ; preds = %cond
  %6 = load i64, ptr %p, align 4
  %slot1 = alloca i64, align 8
  store i64 1, ptr %slot1, align 4
  %7 = load i64, ptr %slot1, align 4
  %8 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %7, 3
  %9 = call [4 x i64] @get_storage([4 x i64] %8)
  %10 = extractvalue [4 x i64] %9, 3
  %11 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
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
  store i64 1, ptr %slot3, align 4
  %30 = load i64, ptr %slot3, align 4
  %31 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %30, 3
  %32 = call [4 x i64] @get_storage([4 x i64] %31)
  %33 = extractvalue [4 x i64] %32, 3
  %34 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
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

define i64 @getWinnerName() {
entry:
  %winnerName = alloca i64, align 8
  %0 = call i64 @winningProposal()
  %slot = alloca i64, align 8
  store i64 1, ptr %slot, align 4
  %1 = load i64, ptr %slot, align 4
  %2 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %1, 3
  %3 = call [4 x i64] @get_storage([4 x i64] %2)
  %4 = extractvalue [4 x i64] %3, 3
  %5 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %6 = extractvalue [4 x i64] %5, 3
  %7 = add i64 %6, %0
  %8 = insertvalue [4 x i64] %5, i64 %7, 3
  %9 = extractvalue [4 x i64] %8, 3
  %10 = add i64 %9, 0
  %11 = insertvalue [4 x i64] %8, i64 %10, 3
  %slot1 = alloca [4 x i64], align 8
  store [4 x i64] %11, ptr %slot1, align 4
  %12 = load [4 x i64], ptr %slot1, align 4
  %13 = call [4 x i64] @get_storage([4 x i64] %12)
  %14 = extractvalue [4 x i64] %13, 3
  %15 = extractvalue [4 x i64] %11, 3
  %16 = add i64 %15, 1
  %17 = insertvalue [4 x i64] %11, i64 %16, 3
  store i64 %14, ptr %winnerName, align 4
  %18 = load i64, ptr %winnerName, align 4
  ret i64 %18
}

define [4 x i64] @get_caller() {
entry:
  ret [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938]
}
