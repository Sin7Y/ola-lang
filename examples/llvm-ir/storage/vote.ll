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
  %index_alloca34 = alloca i64, align 8
  %index_alloca25 = alloca i64, align 8
  %index_alloca6 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
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
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 4
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %8 = add i64 0, %index_value
  %src_index_access = getelementptr i64, ptr %heap_to_ptr, i64 %8
  %9 = load i64, ptr %src_index_access, align 4
  %10 = add i64 0, %index_value
  %dest_index_access = getelementptr i64, ptr %heap_to_ptr2, i64 %10
  store i64 %9, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %index_alloca6, align 4
  br label %cond3

cond3:                                            ; preds = %body4, %done
  %index_value7 = load i64, ptr %index_alloca6, align 4
  %loop_cond8 = icmp ult i64 %index_value7, 4
  br i1 %loop_cond8, label %body4, label %done5

body4:                                            ; preds = %cond3
  %11 = add i64 0, %index_value7
  %src_index_access9 = getelementptr i64, ptr %2, i64 %11
  %12 = load i64, ptr %src_index_access9, align 4
  %13 = add i64 4, %index_value7
  %dest_index_access10 = getelementptr i64, ptr %heap_to_ptr2, i64 %13
  store i64 %12, ptr %dest_index_access10, align 4
  %next_index11 = add i64 %index_value7, 1
  store i64 %next_index11, ptr %index_alloca6, align 4
  br label %cond3

done5:                                            ; preds = %cond3
  %14 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %14, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr13, i64 8)
  %15 = getelementptr i64, ptr %heap_to_ptr13, i64 3
  %slot_value = load i64, ptr %15, align 4
  %16 = add i64 %slot_value, 0
  %17 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %17, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  %18 = call i64 @vector_new(i64 4)
  %heap_start16 = sub i64 %18, 4
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  store i64 %16, ptr %heap_to_ptr17, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr17, i64 1
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %heap_to_ptr17, i64 2
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr17, i64 3
  store i64 0, ptr %21, align 4
  call void @get_storage(ptr %heap_to_ptr17, ptr %heap_to_ptr15)
  %storage_value = load i64, ptr %heap_to_ptr15, align 4
  %22 = icmp eq i64 %storage_value, 0
  %23 = zext i1 %22 to i64
  call void @builtin_assert(i64 %23)
  %24 = load ptr, ptr %msgSender, align 8
  %25 = call i64 @vector_new(i64 4)
  %heap_start18 = sub i64 %25, 4
  %heap_to_ptr19 = inttoptr i64 %heap_start18 to ptr
  store i64 0, ptr %heap_to_ptr19, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr19, i64 1
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr19, i64 2
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr19, i64 3
  store i64 0, ptr %28, align 4
  %29 = call i64 @vector_new(i64 8)
  %heap_start20 = sub i64 %29, 8
  %heap_to_ptr21 = inttoptr i64 %heap_start20 to ptr
  store i64 0, ptr %index_alloca25, align 4
  br label %cond22

cond22:                                           ; preds = %body23, %done5
  %index_value26 = load i64, ptr %index_alloca25, align 4
  %loop_cond27 = icmp ult i64 %index_value26, 4
  br i1 %loop_cond27, label %body23, label %done24

body23:                                           ; preds = %cond22
  %30 = add i64 0, %index_value26
  %src_index_access28 = getelementptr i64, ptr %heap_to_ptr19, i64 %30
  %31 = load i64, ptr %src_index_access28, align 4
  %32 = add i64 0, %index_value26
  %dest_index_access29 = getelementptr i64, ptr %heap_to_ptr21, i64 %32
  store i64 %31, ptr %dest_index_access29, align 4
  %next_index30 = add i64 %index_value26, 1
  store i64 %next_index30, ptr %index_alloca25, align 4
  br label %cond22

done24:                                           ; preds = %cond22
  store i64 0, ptr %index_alloca34, align 4
  br label %cond31

cond31:                                           ; preds = %body32, %done24
  %index_value35 = load i64, ptr %index_alloca34, align 4
  %loop_cond36 = icmp ult i64 %index_value35, 4
  br i1 %loop_cond36, label %body32, label %done33

body32:                                           ; preds = %cond31
  %33 = add i64 0, %index_value35
  %src_index_access37 = getelementptr i64, ptr %24, i64 %33
  %34 = load i64, ptr %src_index_access37, align 4
  %35 = add i64 4, %index_value35
  %dest_index_access38 = getelementptr i64, ptr %heap_to_ptr21, i64 %35
  store i64 %34, ptr %dest_index_access38, align 4
  %next_index39 = add i64 %index_value35, 1
  store i64 %next_index39, ptr %index_alloca34, align 4
  br label %cond31

done33:                                           ; preds = %cond31
  %36 = call i64 @vector_new(i64 4)
  %heap_start40 = sub i64 %36, 4
  %heap_to_ptr41 = inttoptr i64 %heap_start40 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr21, ptr %heap_to_ptr41, i64 8)
  store ptr %heap_to_ptr41, ptr %sender, align 8
  %37 = load i64, ptr %sender, align 4
  %38 = add i64 %37, 0
  %39 = call i64 @vector_new(i64 4)
  %heap_start42 = sub i64 %39, 4
  %heap_to_ptr43 = inttoptr i64 %heap_start42 to ptr
  store i64 %38, ptr %heap_to_ptr43, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr43, i64 1
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %heap_to_ptr43, i64 2
  store i64 0, ptr %41, align 4
  %42 = getelementptr i64, ptr %heap_to_ptr43, i64 3
  store i64 0, ptr %42, align 4
  %43 = call i64 @vector_new(i64 4)
  %heap_start44 = sub i64 %43, 4
  %heap_to_ptr45 = inttoptr i64 %heap_start44 to ptr
  store i64 1, ptr %heap_to_ptr45, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr45, i64 1
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %heap_to_ptr45, i64 2
  store i64 0, ptr %45, align 4
  %46 = getelementptr i64, ptr %heap_to_ptr45, i64 3
  store i64 0, ptr %46, align 4
  call void @set_storage(ptr %heap_to_ptr43, ptr %heap_to_ptr45)
  %47 = load i64, ptr %sender, align 4
  %48 = add i64 %47, 1
  %49 = load i64, ptr %proposal_, align 4
  %50 = call i64 @vector_new(i64 4)
  %heap_start46 = sub i64 %50, 4
  %heap_to_ptr47 = inttoptr i64 %heap_start46 to ptr
  store i64 %48, ptr %heap_to_ptr47, align 4
  %51 = getelementptr i64, ptr %heap_to_ptr47, i64 1
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %heap_to_ptr47, i64 2
  store i64 0, ptr %52, align 4
  %53 = getelementptr i64, ptr %heap_to_ptr47, i64 3
  store i64 0, ptr %53, align 4
  %54 = call i64 @vector_new(i64 4)
  %heap_start48 = sub i64 %54, 4
  %heap_to_ptr49 = inttoptr i64 %heap_start48 to ptr
  store i64 %49, ptr %heap_to_ptr49, align 4
  %55 = getelementptr i64, ptr %heap_to_ptr49, i64 1
  store i64 0, ptr %55, align 4
  %56 = getelementptr i64, ptr %heap_to_ptr49, i64 2
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %heap_to_ptr49, i64 3
  store i64 0, ptr %57, align 4
  call void @set_storage(ptr %heap_to_ptr47, ptr %heap_to_ptr49)
  %58 = load i64, ptr %proposal_, align 4
  %59 = call i64 @vector_new(i64 4)
  %heap_start50 = sub i64 %59, 4
  %heap_to_ptr51 = inttoptr i64 %heap_start50 to ptr
  %60 = call i64 @vector_new(i64 4)
  %heap_start52 = sub i64 %60, 4
  %heap_to_ptr53 = inttoptr i64 %heap_start52 to ptr
  store i64 1, ptr %heap_to_ptr53, align 4
  %61 = getelementptr i64, ptr %heap_to_ptr53, i64 1
  store i64 0, ptr %61, align 4
  %62 = getelementptr i64, ptr %heap_to_ptr53, i64 2
  store i64 0, ptr %62, align 4
  %63 = getelementptr i64, ptr %heap_to_ptr53, i64 3
  store i64 0, ptr %63, align 4
  call void @get_storage(ptr %heap_to_ptr53, ptr %heap_to_ptr51)
  %storage_value54 = load i64, ptr %heap_to_ptr51, align 4
  %64 = sub i64 %storage_value54, 1
  %65 = sub i64 %64, %58
  call void @builtin_range_check(i64 %65)
  %66 = call i64 @vector_new(i64 4)
  %heap_start55 = sub i64 %66, 4
  %heap_to_ptr56 = inttoptr i64 %heap_start55 to ptr
  store i64 1, ptr %heap_to_ptr56, align 4
  %67 = getelementptr i64, ptr %heap_to_ptr56, i64 1
  store i64 0, ptr %67, align 4
  %68 = getelementptr i64, ptr %heap_to_ptr56, i64 2
  store i64 0, ptr %68, align 4
  %69 = getelementptr i64, ptr %heap_to_ptr56, i64 3
  store i64 0, ptr %69, align 4
  %70 = call i64 @vector_new(i64 4)
  %heap_start57 = sub i64 %70, 4
  %heap_to_ptr58 = inttoptr i64 %heap_start57 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr56, ptr %heap_to_ptr58, i64 4)
  %71 = getelementptr i64, ptr %heap_to_ptr58, i64 3
  %72 = load i64, ptr %71, align 4
  %73 = mul i64 %58, 2
  %74 = add i64 %72, %73
  store i64 %74, ptr %71, align 4
  %75 = getelementptr i64, ptr %heap_to_ptr58, i64 3
  %slot_value59 = load i64, ptr %75, align 4
  %76 = add i64 %slot_value59, 1
  %77 = load i64, ptr %proposal_, align 4
  %78 = call i64 @vector_new(i64 4)
  %heap_start60 = sub i64 %78, 4
  %heap_to_ptr61 = inttoptr i64 %heap_start60 to ptr
  %79 = call i64 @vector_new(i64 4)
  %heap_start62 = sub i64 %79, 4
  %heap_to_ptr63 = inttoptr i64 %heap_start62 to ptr
  store i64 1, ptr %heap_to_ptr63, align 4
  %80 = getelementptr i64, ptr %heap_to_ptr63, i64 1
  store i64 0, ptr %80, align 4
  %81 = getelementptr i64, ptr %heap_to_ptr63, i64 2
  store i64 0, ptr %81, align 4
  %82 = getelementptr i64, ptr %heap_to_ptr63, i64 3
  store i64 0, ptr %82, align 4
  call void @get_storage(ptr %heap_to_ptr63, ptr %heap_to_ptr61)
  %storage_value64 = load i64, ptr %heap_to_ptr61, align 4
  %83 = sub i64 %storage_value64, 1
  %84 = sub i64 %83, %77
  call void @builtin_range_check(i64 %84)
  %85 = call i64 @vector_new(i64 4)
  %heap_start65 = sub i64 %85, 4
  %heap_to_ptr66 = inttoptr i64 %heap_start65 to ptr
  store i64 1, ptr %heap_to_ptr66, align 4
  %86 = getelementptr i64, ptr %heap_to_ptr66, i64 1
  store i64 0, ptr %86, align 4
  %87 = getelementptr i64, ptr %heap_to_ptr66, i64 2
  store i64 0, ptr %87, align 4
  %88 = getelementptr i64, ptr %heap_to_ptr66, i64 3
  store i64 0, ptr %88, align 4
  %89 = call i64 @vector_new(i64 4)
  %heap_start67 = sub i64 %89, 4
  %heap_to_ptr68 = inttoptr i64 %heap_start67 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr66, ptr %heap_to_ptr68, i64 4)
  %90 = getelementptr i64, ptr %heap_to_ptr68, i64 3
  %91 = load i64, ptr %90, align 4
  %92 = mul i64 %77, 2
  %93 = add i64 %91, %92
  store i64 %93, ptr %90, align 4
  %94 = getelementptr i64, ptr %heap_to_ptr68, i64 3
  %slot_value69 = load i64, ptr %94, align 4
  %95 = add i64 %slot_value69, 1
  %96 = call i64 @vector_new(i64 4)
  %heap_start70 = sub i64 %96, 4
  %heap_to_ptr71 = inttoptr i64 %heap_start70 to ptr
  %97 = call i64 @vector_new(i64 4)
  %heap_start72 = sub i64 %97, 4
  %heap_to_ptr73 = inttoptr i64 %heap_start72 to ptr
  store i64 %95, ptr %heap_to_ptr73, align 4
  %98 = getelementptr i64, ptr %heap_to_ptr73, i64 1
  store i64 0, ptr %98, align 4
  %99 = getelementptr i64, ptr %heap_to_ptr73, i64 2
  store i64 0, ptr %99, align 4
  %100 = getelementptr i64, ptr %heap_to_ptr73, i64 3
  store i64 0, ptr %100, align 4
  call void @get_storage(ptr %heap_to_ptr73, ptr %heap_to_ptr71)
  %storage_value74 = load i64, ptr %heap_to_ptr71, align 4
  %101 = add i64 %storage_value74, 1
  call void @builtin_range_check(i64 %101)
  %102 = call i64 @vector_new(i64 4)
  %heap_start75 = sub i64 %102, 4
  %heap_to_ptr76 = inttoptr i64 %heap_start75 to ptr
  store i64 %76, ptr %heap_to_ptr76, align 4
  %103 = getelementptr i64, ptr %heap_to_ptr76, i64 1
  store i64 0, ptr %103, align 4
  %104 = getelementptr i64, ptr %heap_to_ptr76, i64 2
  store i64 0, ptr %104, align 4
  %105 = getelementptr i64, ptr %heap_to_ptr76, i64 3
  store i64 0, ptr %105, align 4
  %106 = call i64 @vector_new(i64 4)
  %heap_start77 = sub i64 %106, 4
  %heap_to_ptr78 = inttoptr i64 %heap_start77 to ptr
  store i64 %101, ptr %heap_to_ptr78, align 4
  %107 = getelementptr i64, ptr %heap_to_ptr78, i64 1
  store i64 0, ptr %107, align 4
  %108 = getelementptr i64, ptr %heap_to_ptr78, i64 2
  store i64 0, ptr %108, align 4
  %109 = getelementptr i64, ptr %heap_to_ptr78, i64 3
  store i64 0, ptr %109, align 4
  call void @set_storage(ptr %heap_to_ptr76, ptr %heap_to_ptr78)
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
  %index_ptr = alloca i64, align 8
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
