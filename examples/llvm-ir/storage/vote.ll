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

declare void @get_context_data(i64, i64)

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

define void @memory_copy(ptr %0, i64 %1, ptr %2, i64 %3, i64 %4) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %4
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %5 = add i64 %1, %index_value
  %src_index_access = getelementptr i64, ptr %0, i64 %5
  %6 = load i64, ptr %src_index_access, align 4
  %7 = add i64 %3, %index_value
  %dest_index_access = getelementptr i64, ptr %2, i64 %7
  store i64 %6, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
}

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
  %3 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %3, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %4 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %4, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 1, ptr %heap_to_ptr2, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %7, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  %storage_value = load i64, ptr %heap_to_ptr, align 4
  %8 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %8, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 1, ptr %heap_to_ptr4, align 4
  %9 = getelementptr i64, ptr %heap_to_ptr4, i64 1
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr4, i64 2
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr4, i64 3
  store i64 0, ptr %11, align 4
  %12 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %12, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr4, ptr %heap_to_ptr6, i64 4)
  %13 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  %14 = load i64, ptr %13, align 4
  %15 = mul i64 %storage_value, 2
  %16 = add i64 %14, %15
  store i64 %16, ptr %13, align 4
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %17 = load i64, ptr %i, align 4
  %length7 = load i64, ptr %0, align 4
  %18 = sub i64 %length7, 1
  %19 = sub i64 %18, %17
  call void @builtin_range_check(i64 %19)
  %20 = ptrtoint ptr %0 to i64
  %21 = add i64 %20, 1
  %vector_data = inttoptr i64 %21 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %17
  %22 = load i64, ptr %index_access, align 4
  store i64 %22, ptr %"struct member", align 4
  %"struct member8" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 0, ptr %"struct member8", align 4
  %name = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  call void @set_storage(ptr %heap_to_ptr6, ptr %name)
  %23 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  %slot_value = load i64, ptr %23, align 4
  %24 = add i64 %slot_value, 1
  %voteCount = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  %25 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %25, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 %24, ptr %heap_to_ptr10, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %28, align 4
  call void @set_storage(ptr %heap_to_ptr10, ptr %voteCount)
  %new_length = add i64 %storage_value, 1
  %29 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %29, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 1, ptr %heap_to_ptr12, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %32, align 4
  %33 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %33, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 %new_length, ptr %heap_to_ptr14, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %36, align 4
  call void @set_storage(ptr %heap_to_ptr12, ptr %heap_to_ptr14)
  br label %next

next:                                             ; preds = %body
  %37 = load i64, ptr %i, align 4
  %38 = add i64 %37, 1
  store i64 %38, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
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
  %1 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %1, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %2 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %2, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 1, ptr %heap_to_ptr2, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %5, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  %storage_value = load i64, ptr %heap_to_ptr, align 4
  %6 = icmp ult i64 %0, %storage_value
  br i1 %6, label %body, label %endfor

body:                                             ; preds = %cond
  %7 = load i64, ptr %p, align 4
  %8 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %8, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  %9 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %9, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 1, ptr %heap_to_ptr6, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %12, align 4
  call void @get_storage(ptr %heap_to_ptr6, ptr %heap_to_ptr4)
  %storage_value7 = load i64, ptr %heap_to_ptr4, align 4
  %13 = sub i64 %storage_value7, 1
  %14 = sub i64 %13, %7
  call void @builtin_range_check(i64 %14)
  %15 = call i64 @vector_new(i64 4)
  %heap_start8 = sub i64 %15, 4
  %heap_to_ptr9 = inttoptr i64 %heap_start8 to ptr
  store i64 1, ptr %heap_to_ptr9, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr9, i64 1
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr9, i64 2
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr9, i64 3
  store i64 0, ptr %18, align 4
  %19 = call i64 @vector_new(i64 4)
  %heap_start10 = sub i64 %19, 4
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr9, ptr %heap_to_ptr11, i64 4)
  %20 = getelementptr i64, ptr %heap_to_ptr11, i64 3
  %21 = load i64, ptr %20, align 4
  %22 = mul i64 %7, 2
  %23 = add i64 %21, %22
  store i64 %23, ptr %20, align 4
  %24 = getelementptr i64, ptr %heap_to_ptr11, i64 3
  %slot_value = load i64, ptr %24, align 4
  %25 = add i64 %slot_value, 1
  %26 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %26, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  %27 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %27, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 %25, ptr %heap_to_ptr15, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr15, i64 1
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr15, i64 2
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr15, i64 3
  store i64 0, ptr %30, align 4
  call void @get_storage(ptr %heap_to_ptr15, ptr %heap_to_ptr13)
  %storage_value16 = load i64, ptr %heap_to_ptr13, align 4
  %31 = load i64, ptr %winningVoteCount, align 4
  %32 = icmp ugt i64 %storage_value16, %31
  br i1 %32, label %then, label %enif

next:                                             ; preds = %enif
  %33 = load i64, ptr %p, align 4
  %34 = add i64 %33, 1
  store i64 %34, ptr %p, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %35 = load i64, ptr %winningProposal_, align 4
  ret i64 %35

then:                                             ; preds = %body
  %36 = load i64, ptr %p, align 4
  %37 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %37, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  %38 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %38, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 1, ptr %heap_to_ptr20, align 4
  %39 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %41, align 4
  call void @get_storage(ptr %heap_to_ptr20, ptr %heap_to_ptr18)
  %storage_value21 = load i64, ptr %heap_to_ptr18, align 4
  %42 = sub i64 %storage_value21, 1
  %43 = sub i64 %42, %36
  call void @builtin_range_check(i64 %43)
  %44 = call i64 @vector_new(i64 4)
  %heap_start22 = sub i64 %44, 4
  %heap_to_ptr23 = inttoptr i64 %heap_start22 to ptr
  store i64 1, ptr %heap_to_ptr23, align 4
  %45 = getelementptr i64, ptr %heap_to_ptr23, i64 1
  store i64 0, ptr %45, align 4
  %46 = getelementptr i64, ptr %heap_to_ptr23, i64 2
  store i64 0, ptr %46, align 4
  %47 = getelementptr i64, ptr %heap_to_ptr23, i64 3
  store i64 0, ptr %47, align 4
  %48 = call i64 @vector_new(i64 4)
  %heap_start24 = sub i64 %48, 4
  %heap_to_ptr25 = inttoptr i64 %heap_start24 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr23, ptr %heap_to_ptr25, i64 4)
  %49 = getelementptr i64, ptr %heap_to_ptr25, i64 3
  %50 = load i64, ptr %49, align 4
  %51 = mul i64 %36, 2
  %52 = add i64 %50, %51
  store i64 %52, ptr %49, align 4
  %53 = getelementptr i64, ptr %heap_to_ptr25, i64 3
  %slot_value26 = load i64, ptr %53, align 4
  %54 = add i64 %slot_value26, 1
  %55 = call i64 @vector_new(i64 4)
  %heap_start27 = sub i64 %55, 4
  %heap_to_ptr28 = inttoptr i64 %heap_start27 to ptr
  %56 = call i64 @vector_new(i64 4)
  %heap_start29 = sub i64 %56, 4
  %heap_to_ptr30 = inttoptr i64 %heap_start29 to ptr
  store i64 %54, ptr %heap_to_ptr30, align 4
  %57 = getelementptr i64, ptr %heap_to_ptr30, i64 1
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %heap_to_ptr30, i64 2
  store i64 0, ptr %58, align 4
  %59 = getelementptr i64, ptr %heap_to_ptr30, i64 3
  store i64 0, ptr %59, align 4
  call void @get_storage(ptr %heap_to_ptr30, ptr %heap_to_ptr28)
  %storage_value31 = load i64, ptr %heap_to_ptr28, align 4
  %60 = load i64, ptr %p, align 4
  br label %enif

enif:                                             ; preds = %then, %body
  br label %next
}

define i64 @getWinnerName() {
entry:
  %winnerName = alloca i64, align 8
  %_winningProposal = alloca i64, align 8
  %0 = call i64 @winningProposal()
  store i64 %0, ptr %_winningProposal, align 4
  %1 = load i64, ptr %_winningProposal, align 4
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %3 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %3, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 1, ptr %heap_to_ptr2, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %6, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  %storage_value = load i64, ptr %heap_to_ptr, align 4
  %7 = sub i64 %storage_value, 1
  %8 = sub i64 %7, %1
  call void @builtin_range_check(i64 %8)
  %9 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %9, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 1, ptr %heap_to_ptr4, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr4, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr4, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr4, i64 3
  store i64 0, ptr %12, align 4
  %13 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %13, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr4, ptr %heap_to_ptr6, i64 4)
  %14 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  %15 = load i64, ptr %14, align 4
  %16 = mul i64 %1, 2
  %17 = add i64 %15, %16
  store i64 %17, ptr %14, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  %slot_value = load i64, ptr %18, align 4
  %19 = add i64 %slot_value, 0
  %20 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %20, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  %21 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %21, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 %19, ptr %heap_to_ptr10, align 4
  %22 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %24, align 4
  call void @get_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr8)
  %storage_value11 = load i64, ptr %heap_to_ptr8, align 4
  store i64 %storage_value11, ptr %winnerName, align 4
  %25 = load i64, ptr %winnerName, align 4
  ret i64 %25
}

define void @vote_proposal(i64 %0) {
entry:
  %sender = alloca i64, align 8
  %msgSender = alloca ptr, align 8
  %proposal_ = alloca i64, align 8
  store i64 %0, ptr %proposal_, align 4
  %1 = call ptr @get_caller()
  store ptr %1, ptr %msgSender, align 8
  %2 = load ptr, ptr %msgSender, align 8
  %3 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %3, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %6, align 4
  %7 = call i64 @vector_new(i64 8)
  %heap_start1 = sub i64 %7, 8
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @memory_copy(ptr %heap_to_ptr, i64 0, ptr %heap_to_ptr2, i64 0, i64 4)
  call void @memory_copy(ptr %2, i64 0, ptr %heap_to_ptr2, i64 4, i64 4)
  %8 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %8, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr4, i64 8)
  %9 = getelementptr i64, ptr %heap_to_ptr4, i64 3
  %slot_value = load i64, ptr %9, align 4
  %10 = add i64 %slot_value, 0
  %11 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %11, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  %12 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %12, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 %10, ptr %heap_to_ptr8, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr8, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr8, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr8, i64 3
  store i64 0, ptr %15, align 4
  call void @get_storage(ptr %heap_to_ptr8, ptr %heap_to_ptr6)
  %storage_value = load i64, ptr %heap_to_ptr6, align 4
  %16 = icmp eq i64 %storage_value, 0
  %17 = zext i1 %16 to i64
  call void @builtin_assert(i64 %17)
  %18 = load ptr, ptr %msgSender, align 8
  %19 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %19, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 0, ptr %heap_to_ptr10, align 4
  %20 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %22, align 4
  %23 = call i64 @vector_new(i64 8)
  %heap_start11 = sub i64 %23, 8
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  call void @memory_copy(ptr %heap_to_ptr10, i64 0, ptr %heap_to_ptr12, i64 0, i64 4)
  call void @memory_copy(ptr %18, i64 0, ptr %heap_to_ptr12, i64 4, i64 4)
  %24 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %24, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr12, ptr %heap_to_ptr14, i64 8)
  store ptr %heap_to_ptr14, ptr %sender, align 8
  %25 = load i64, ptr %sender, align 4
  %26 = add i64 %25, 0
  %27 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %27, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  store i64 %26, ptr %heap_to_ptr16, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr16, i64 1
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr16, i64 2
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  store i64 0, ptr %30, align 4
  %31 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %31, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  store i64 1, ptr %heap_to_ptr18, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr18, i64 1
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr18, i64 2
  store i64 0, ptr %33, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr18, i64 3
  store i64 0, ptr %34, align 4
  call void @set_storage(ptr %heap_to_ptr16, ptr %heap_to_ptr18)
  %35 = load i64, ptr %sender, align 4
  %36 = add i64 %35, 1
  %37 = load i64, ptr %proposal_, align 4
  %38 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %38, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 %36, ptr %heap_to_ptr20, align 4
  %39 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %41, align 4
  %42 = call i64 @vector_new(i64 4)
  %heap_start21 = sub i64 %42, 4
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  store i64 %37, ptr %heap_to_ptr22, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr22, i64 1
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr22, i64 2
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %heap_to_ptr22, i64 3
  store i64 0, ptr %45, align 4
  call void @set_storage(ptr %heap_to_ptr20, ptr %heap_to_ptr22)
  %46 = load i64, ptr %proposal_, align 4
  %47 = call i64 @vector_new(i64 4)
  %heap_start23 = sub i64 %47, 4
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  %48 = call i64 @vector_new(i64 4)
  %heap_start25 = sub i64 %48, 4
  %heap_to_ptr26 = inttoptr i64 %heap_start25 to ptr
  store i64 1, ptr %heap_to_ptr26, align 4
  %49 = getelementptr i64, ptr %heap_to_ptr26, i64 1
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %heap_to_ptr26, i64 2
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %heap_to_ptr26, i64 3
  store i64 0, ptr %51, align 4
  call void @get_storage(ptr %heap_to_ptr26, ptr %heap_to_ptr24)
  %storage_value27 = load i64, ptr %heap_to_ptr24, align 4
  %52 = sub i64 %storage_value27, 1
  %53 = sub i64 %52, %46
  call void @builtin_range_check(i64 %53)
  %54 = call i64 @vector_new(i64 4)
  %heap_start28 = sub i64 %54, 4
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  store i64 1, ptr %heap_to_ptr29, align 4
  %55 = getelementptr i64, ptr %heap_to_ptr29, i64 1
  store i64 0, ptr %55, align 4
  %56 = getelementptr i64, ptr %heap_to_ptr29, i64 2
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %heap_to_ptr29, i64 3
  store i64 0, ptr %57, align 4
  %58 = call i64 @vector_new(i64 4)
  %heap_start30 = sub i64 %58, 4
  %heap_to_ptr31 = inttoptr i64 %heap_start30 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr29, ptr %heap_to_ptr31, i64 4)
  %59 = getelementptr i64, ptr %heap_to_ptr31, i64 3
  %60 = load i64, ptr %59, align 4
  %61 = mul i64 %46, 2
  %62 = add i64 %60, %61
  store i64 %62, ptr %59, align 4
  %63 = getelementptr i64, ptr %heap_to_ptr31, i64 3
  %slot_value32 = load i64, ptr %63, align 4
  %64 = add i64 %slot_value32, 1
  %65 = load i64, ptr %proposal_, align 4
  %66 = call i64 @vector_new(i64 4)
  %heap_start33 = sub i64 %66, 4
  %heap_to_ptr34 = inttoptr i64 %heap_start33 to ptr
  %67 = call i64 @vector_new(i64 4)
  %heap_start35 = sub i64 %67, 4
  %heap_to_ptr36 = inttoptr i64 %heap_start35 to ptr
  store i64 1, ptr %heap_to_ptr36, align 4
  %68 = getelementptr i64, ptr %heap_to_ptr36, i64 1
  store i64 0, ptr %68, align 4
  %69 = getelementptr i64, ptr %heap_to_ptr36, i64 2
  store i64 0, ptr %69, align 4
  %70 = getelementptr i64, ptr %heap_to_ptr36, i64 3
  store i64 0, ptr %70, align 4
  call void @get_storage(ptr %heap_to_ptr36, ptr %heap_to_ptr34)
  %storage_value37 = load i64, ptr %heap_to_ptr34, align 4
  %71 = sub i64 %storage_value37, 1
  %72 = sub i64 %71, %65
  call void @builtin_range_check(i64 %72)
  %73 = call i64 @vector_new(i64 4)
  %heap_start38 = sub i64 %73, 4
  %heap_to_ptr39 = inttoptr i64 %heap_start38 to ptr
  store i64 1, ptr %heap_to_ptr39, align 4
  %74 = getelementptr i64, ptr %heap_to_ptr39, i64 1
  store i64 0, ptr %74, align 4
  %75 = getelementptr i64, ptr %heap_to_ptr39, i64 2
  store i64 0, ptr %75, align 4
  %76 = getelementptr i64, ptr %heap_to_ptr39, i64 3
  store i64 0, ptr %76, align 4
  %77 = call i64 @vector_new(i64 4)
  %heap_start40 = sub i64 %77, 4
  %heap_to_ptr41 = inttoptr i64 %heap_start40 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr39, ptr %heap_to_ptr41, i64 4)
  %78 = getelementptr i64, ptr %heap_to_ptr41, i64 3
  %79 = load i64, ptr %78, align 4
  %80 = mul i64 %65, 2
  %81 = add i64 %79, %80
  store i64 %81, ptr %78, align 4
  %82 = getelementptr i64, ptr %heap_to_ptr41, i64 3
  %slot_value42 = load i64, ptr %82, align 4
  %83 = add i64 %slot_value42, 1
  %84 = call i64 @vector_new(i64 4)
  %heap_start43 = sub i64 %84, 4
  %heap_to_ptr44 = inttoptr i64 %heap_start43 to ptr
  %85 = call i64 @vector_new(i64 4)
  %heap_start45 = sub i64 %85, 4
  %heap_to_ptr46 = inttoptr i64 %heap_start45 to ptr
  store i64 %83, ptr %heap_to_ptr46, align 4
  %86 = getelementptr i64, ptr %heap_to_ptr46, i64 1
  store i64 0, ptr %86, align 4
  %87 = getelementptr i64, ptr %heap_to_ptr46, i64 2
  store i64 0, ptr %87, align 4
  %88 = getelementptr i64, ptr %heap_to_ptr46, i64 3
  store i64 0, ptr %88, align 4
  call void @get_storage(ptr %heap_to_ptr46, ptr %heap_to_ptr44)
  %storage_value47 = load i64, ptr %heap_to_ptr44, align 4
  %89 = add i64 %storage_value47, 1
  call void @builtin_range_check(i64 %89)
  %90 = call i64 @vector_new(i64 4)
  %heap_start48 = sub i64 %90, 4
  %heap_to_ptr49 = inttoptr i64 %heap_start48 to ptr
  store i64 %64, ptr %heap_to_ptr49, align 4
  %91 = getelementptr i64, ptr %heap_to_ptr49, i64 1
  store i64 0, ptr %91, align 4
  %92 = getelementptr i64, ptr %heap_to_ptr49, i64 2
  store i64 0, ptr %92, align 4
  %93 = getelementptr i64, ptr %heap_to_ptr49, i64 3
  store i64 0, ptr %93, align 4
  %94 = call i64 @vector_new(i64 4)
  %heap_start50 = sub i64 %94, 4
  %heap_to_ptr51 = inttoptr i64 %heap_start50 to ptr
  store i64 %89, ptr %heap_to_ptr51, align 4
  %95 = getelementptr i64, ptr %heap_to_ptr51, i64 1
  store i64 0, ptr %95, align 4
  %96 = getelementptr i64, ptr %heap_to_ptr51, i64 2
  store i64 0, ptr %96, align 4
  %97 = getelementptr i64, ptr %heap_to_ptr51, i64 3
  store i64 0, ptr %97, align 4
  call void @set_storage(ptr %heap_to_ptr49, ptr %heap_to_ptr51)
  ret void
}

define ptr @get_caller() {
entry:
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 402443140940559753, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 -5438528055523826848, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 6500940582073311439, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 -6711892513312253938, ptr %index_access3, align 4
  ret ptr %heap_to_ptr
}

define void @vote_test() {
entry:
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 3, ptr %heap_to_ptr, align 4
  %1 = ptrtoint ptr %heap_to_ptr to i64
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
  %length = load i64, ptr %heap_to_ptr, align 4
  %3 = sub i64 %length, 1
  %4 = sub i64 %3, 0
  call void @builtin_range_check(i64 %4)
  %5 = ptrtoint ptr %heap_to_ptr to i64
  %6 = add i64 %5, 1
  %vector_data1 = inttoptr i64 %6 to ptr
  %index_access2 = getelementptr i64, ptr %vector_data1, i64 0
  store i64 65, ptr %index_access2, align 4
  %length3 = load i64, ptr %heap_to_ptr, align 4
  %7 = sub i64 %length3, 1
  %8 = sub i64 %7, 1
  call void @builtin_range_check(i64 %8)
  %9 = ptrtoint ptr %heap_to_ptr to i64
  %10 = add i64 %9, 1
  %vector_data4 = inttoptr i64 %10 to ptr
  %index_access5 = getelementptr i64, ptr %vector_data4, i64 1
  store i64 66, ptr %index_access5, align 4
  %length6 = load i64, ptr %heap_to_ptr, align 4
  %11 = sub i64 %length6, 1
  %12 = sub i64 %11, 2
  call void @builtin_range_check(i64 %12)
  %13 = ptrtoint ptr %heap_to_ptr to i64
  %14 = add i64 %13, 1
  %vector_data7 = inttoptr i64 %14 to ptr
  %index_access8 = getelementptr i64, ptr %vector_data7, i64 2
  store i64 67, ptr %index_access8, align 4
  call void @contract_init(ptr %heap_to_ptr)
  call void @vote_proposal(i64 1)
  %15 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %15, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  %16 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %16, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 1, ptr %heap_to_ptr12, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %19, align 4
  call void @get_storage(ptr %heap_to_ptr12, ptr %heap_to_ptr10)
  %storage_value = load i64, ptr %heap_to_ptr10, align 4
  %20 = sub i64 %storage_value, 1
  %21 = sub i64 %20, 1
  call void @builtin_range_check(i64 %21)
  %22 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %22, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 1, ptr %heap_to_ptr14, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %25, align 4
  %26 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %26, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr14, ptr %heap_to_ptr16, i64 4)
  %27 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  %28 = load i64, ptr %27, align 4
  %29 = add i64 %28, 2
  store i64 %29, ptr %27, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  %slot_value = load i64, ptr %30, align 4
  %31 = add i64 %slot_value, 1
  %32 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %32, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  %33 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %33, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 %31, ptr %heap_to_ptr20, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %36, align 4
  call void @get_storage(ptr %heap_to_ptr20, ptr %heap_to_ptr18)
  %storage_value21 = load i64, ptr %heap_to_ptr18, align 4
  %37 = icmp eq i64 %storage_value21, 1
  %38 = zext i1 %37 to i64
  call void @builtin_assert(i64 %38)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %index_ptr = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 2817135588, label %func_0_dispatch
    i64 3186728800, label %func_1_dispatch
    i64 363199787, label %func_2_dispatch
    i64 2791810083, label %func_3_dispatch
    i64 2868727644, label %func_4_dispatch
    i64 69185575, label %func_5_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %3 = add i64 1, %value
  %4 = icmp ule i64 1, %1
  br i1 %4, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %size = mul i64 %value, 1
  %size_add_one = add i64 %size, 1
  %5 = call i64 @vector_new(i64 %size_add_one)
  %heap_start = sub i64 %5, %size_add_one
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 %size, ptr %heap_to_ptr, align 4
  %6 = ptrtoint ptr %heap_to_ptr to i64
  %7 = add i64 %6, 1
  %vector_data = inttoptr i64 %7 to ptr
  %array_elem_num = mul i64 %value, 1
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

loop_body:                                        ; preds = %inbounds1, %inbounds
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr i64, ptr %vector_data, i64 %index
  %8 = icmp ule i64 2, %1
  br i1 %8, label %inbounds1, label %out_of_bounds2

loop_end:                                         ; preds = %inbounds1
  %9 = add i64 0, %array_elem_num
  %10 = icmp ule i64 %9, %1
  br i1 %10, label %inbounds5, label %out_of_bounds6

inbounds1:                                        ; preds = %loop_body
  %start3 = getelementptr i64, ptr %2, i64 1
  %value4 = load i64, ptr %start3, align 4
  store i64 %value4, ptr %element, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %value
  br i1 %index_cond, label %loop_body, label %loop_end

out_of_bounds2:                                   ; preds = %loop_body
  unreachable

inbounds5:                                        ; preds = %loop_end
  %11 = add i64 0, %3
  %12 = icmp ule i64 %11, %1
  br i1 %12, label %inbounds7, label %out_of_bounds8

out_of_bounds6:                                   ; preds = %loop_end
  unreachable

inbounds7:                                        ; preds = %inbounds5
  %13 = add i64 0, %3
  %14 = icmp ult i64 %13, %1
  br i1 %14, label %not_all_bytes_read, label %buffer_read

out_of_bounds8:                                   ; preds = %inbounds5
  unreachable

not_all_bytes_read:                               ; preds = %inbounds7
  unreachable

buffer_read:                                      ; preds = %inbounds7
  call void @contract_init(ptr %heap_to_ptr)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %15 = call i64 @winningProposal()
  %16 = call i64 @vector_new(i64 2)
  %heap_start9 = sub i64 %16, 2
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  %start11 = getelementptr i64, ptr %heap_to_ptr10, i64 0
  store i64 %15, ptr %start11, align 4
  %start12 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 1, ptr %start12, align 4
  call void @set_tape_data(i64 %heap_start9, i64 2)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %17 = call i64 @getWinnerName()
  %18 = call i64 @vector_new(i64 2)
  %heap_start13 = sub i64 %18, 2
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  %start15 = getelementptr i64, ptr %heap_to_ptr14, i64 0
  store i64 %17, ptr %start15, align 4
  %start16 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 1, ptr %start16, align 4
  call void @set_tape_data(i64 %heap_start13, i64 2)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %19 = icmp ule i64 1, %1
  br i1 %19, label %inbounds17, label %out_of_bounds18

inbounds17:                                       ; preds = %func_3_dispatch
  %start19 = getelementptr i64, ptr %2, i64 0
  %value20 = load i64, ptr %start19, align 4
  %20 = icmp ult i64 1, %1
  br i1 %20, label %not_all_bytes_read21, label %buffer_read22

out_of_bounds18:                                  ; preds = %func_3_dispatch
  unreachable

not_all_bytes_read21:                             ; preds = %inbounds17
  unreachable

buffer_read22:                                    ; preds = %inbounds17
  call void @vote_proposal(i64 %value20)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %21 = call ptr @get_caller()
  %22 = call i64 @vector_new(i64 5)
  %heap_start23 = sub i64 %22, 5
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  %23 = getelementptr i64, ptr %21, i64 0
  %24 = load i64, ptr %23, align 4
  %start25 = getelementptr i64, ptr %heap_to_ptr24, i64 0
  store i64 %24, ptr %start25, align 4
  %25 = getelementptr i64, ptr %21, i64 1
  %26 = load i64, ptr %25, align 4
  %start26 = getelementptr i64, ptr %heap_to_ptr24, i64 1
  store i64 %26, ptr %start26, align 4
  %27 = getelementptr i64, ptr %21, i64 2
  %28 = load i64, ptr %27, align 4
  %start27 = getelementptr i64, ptr %heap_to_ptr24, i64 2
  store i64 %28, ptr %start27, align 4
  %29 = getelementptr i64, ptr %21, i64 3
  %30 = load i64, ptr %29, align 4
  %start28 = getelementptr i64, ptr %heap_to_ptr24, i64 3
  store i64 %30, ptr %start28, align 4
  %start29 = getelementptr i64, ptr %heap_to_ptr24, i64 4
  store i64 4, ptr %start29, align 4
  call void @set_tape_data(i64 %heap_start23, i64 5)
  ret void

func_5_dispatch:                                  ; preds = %entry
  call void @vote_test()
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  ret void
}
