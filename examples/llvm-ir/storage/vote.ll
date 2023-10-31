; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

define void @mempcy(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %dest_ptr_alloca = alloca ptr, align 8
  %src_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %src_ptr_alloca, align 8
  %src_ptr = load ptr, ptr %src_ptr_alloca, align 8
  store ptr %1, ptr %dest_ptr_alloca, align 8
  %dest_ptr = load ptr, ptr %dest_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %len
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %src_index_access = getelementptr i64, ptr %src_ptr, i64 %index_value
  %3 = load i64, ptr %src_index_access, align 4
  %dest_index_access = getelementptr i64, ptr %dest_ptr, i64 %index_value
  store i64 %3, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret void
}

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

declare void @prophet_printf(i64, i64)

define void @contract_init(ptr %0) {
entry:
  %1 = alloca ptr, align 8
  %index_alloca30 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %i = alloca i64, align 8
  %proposalNames_ = alloca ptr, align 8
  store ptr %0, ptr %proposalNames_, align 8
  %3 = load ptr, ptr %proposalNames_, align 8
  %4 = call i64 @vector_new(i64 12)
  %heap_start = sub i64 %4, 12
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 12)
  %5 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %5, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 0, ptr %heap_to_ptr2, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %8, align 4
  call void @set_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %9 = load i64, ptr %i, align 4
  %length = load i64, ptr %3, align 4
  %10 = icmp ult i64 %9, %length
  br i1 %10, label %body, label %endfor

body:                                             ; preds = %cond
  %11 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %11, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  %12 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %12, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 2, ptr %heap_to_ptr6, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %15, align 4
  call void @get_storage(ptr %heap_to_ptr6, ptr %heap_to_ptr4)
  %storage_value = load i64, ptr %heap_to_ptr4, align 4
  %16 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %16, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 2, ptr %heap_to_ptr8, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr8, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr8, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr8, i64 3
  store i64 0, ptr %19, align 4
  %20 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %20, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr8, ptr %heap_to_ptr10, i64 4)
  %21 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  %22 = load i64, ptr %21, align 4
  %23 = mul i64 %storage_value, 2
  %24 = add i64 %22, %23
  store i64 %24, ptr %21, align 4
  %25 = call i64 @vector_new(i64 2)
  %heap_start11 = sub i64 %25, 2
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  %struct_member = getelementptr { ptr, i64 }, ptr %heap_to_ptr12, i64 0
  %26 = load i64, ptr %i, align 4
  %length13 = load i64, ptr %3, align 4
  %27 = sub i64 %length13, 1
  %28 = sub i64 %27, %26
  call void @builtin_range_check(i64 %28)
  %29 = ptrtoint ptr %3 to i64
  %30 = add i64 %29, 1
  %vector_data = inttoptr i64 %30 to ptr
  %index_access = getelementptr ptr, ptr %vector_data, i64 %26
  %31 = load ptr, ptr %index_access, align 8
  store ptr %31, ptr %struct_member, align 8
  %struct_member14 = getelementptr { ptr, i64 }, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %struct_member14, align 4
  %name = getelementptr { ptr, i64 }, ptr %heap_to_ptr12, i64 0
  %length15 = load i64, ptr %name, align 4
  %32 = call i64 @vector_new(i64 4)
  %heap_start16 = sub i64 %32, 4
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  call void @get_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr17)
  %storage_value18 = load i64, ptr %heap_to_ptr17, align 4
  %33 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %33, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 %length15, ptr %heap_to_ptr20, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %36, align 4
  call void @set_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr20)
  %37 = call i64 @vector_new(i64 4)
  %heap_start21 = sub i64 %37, 4
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr10, ptr %heap_to_ptr22, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %heap_to_ptr22, ptr %2, align 8
  br label %cond23

next:                                             ; preds = %done29
  %38 = load i64, ptr %i, align 4
  %39 = add i64 %38, 1
  store i64 %39, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void

cond23:                                           ; preds = %body24, %body
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length15
  br i1 %loop_cond, label %body24, label %done

body24:                                           ; preds = %cond23
  %40 = load ptr, ptr %2, align 8
  %41 = ptrtoint ptr %name to i64
  %42 = add i64 %41, 1
  %vector_data25 = inttoptr i64 %42 to ptr
  %index_access26 = getelementptr i64, ptr %vector_data25, i64 %index_value
  call void @set_storage(ptr %40, ptr %index_access26)
  %43 = getelementptr i64, ptr %40, i64 3
  %slot_value = load i64, ptr %43, align 4
  %44 = add i64 %slot_value, 1
  store i64 %44, ptr %2, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond23

done:                                             ; preds = %cond23
  store i64 %length15, ptr %index_alloca30, align 4
  store ptr %heap_to_ptr22, ptr %1, align 8
  br label %cond27

cond27:                                           ; preds = %body28, %done
  %index_value31 = load i64, ptr %index_alloca30, align 4
  %loop_cond32 = icmp ult i64 %index_value31, %storage_value18
  br i1 %loop_cond32, label %body28, label %done29

body28:                                           ; preds = %cond27
  %45 = load ptr, ptr %1, align 8
  %46 = call i64 @vector_new(i64 4)
  %heap_start33 = sub i64 %46, 4
  %heap_to_ptr34 = inttoptr i64 %heap_start33 to ptr
  %storage_key_ptr = getelementptr i64, ptr %heap_to_ptr34, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr35 = getelementptr i64, ptr %heap_to_ptr34, i64 1
  store i64 0, ptr %storage_key_ptr35, align 4
  %storage_key_ptr36 = getelementptr i64, ptr %heap_to_ptr34, i64 2
  store i64 0, ptr %storage_key_ptr36, align 4
  %storage_key_ptr37 = getelementptr i64, ptr %heap_to_ptr34, i64 3
  store i64 0, ptr %storage_key_ptr37, align 4
  call void @set_storage(ptr %45, ptr %heap_to_ptr34)
  %47 = getelementptr i64, ptr %45, i64 3
  %slot_value38 = load i64, ptr %47, align 4
  %48 = add i64 %slot_value38, 1
  store i64 %48, ptr %1, align 4
  %next_index39 = add i64 %index_value31, 1
  store i64 %next_index39, ptr %index_alloca30, align 4
  br label %cond27

done29:                                           ; preds = %cond27
  %49 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  %slot_value40 = load i64, ptr %49, align 4
  %50 = add i64 %slot_value40, 1
  %voteCount = getelementptr { ptr, i64 }, ptr %heap_to_ptr12, i64 1
  %51 = call i64 @vector_new(i64 4)
  %heap_start41 = sub i64 %51, 4
  %heap_to_ptr42 = inttoptr i64 %heap_start41 to ptr
  store i64 %50, ptr %heap_to_ptr42, align 4
  %52 = getelementptr i64, ptr %heap_to_ptr42, i64 1
  store i64 0, ptr %52, align 4
  %53 = getelementptr i64, ptr %heap_to_ptr42, i64 2
  store i64 0, ptr %53, align 4
  %54 = getelementptr i64, ptr %heap_to_ptr42, i64 3
  store i64 0, ptr %54, align 4
  call void @set_storage(ptr %heap_to_ptr42, ptr %voteCount)
  %new_length = add i64 %storage_value, 1
  %55 = call i64 @vector_new(i64 4)
  %heap_start43 = sub i64 %55, 4
  %heap_to_ptr44 = inttoptr i64 %heap_start43 to ptr
  store i64 2, ptr %heap_to_ptr44, align 4
  %56 = getelementptr i64, ptr %heap_to_ptr44, i64 1
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %heap_to_ptr44, i64 2
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %heap_to_ptr44, i64 3
  store i64 0, ptr %58, align 4
  %59 = call i64 @vector_new(i64 4)
  %heap_start45 = sub i64 %59, 4
  %heap_to_ptr46 = inttoptr i64 %heap_start45 to ptr
  store i64 %new_length, ptr %heap_to_ptr46, align 4
  %60 = getelementptr i64, ptr %heap_to_ptr46, i64 1
  store i64 0, ptr %60, align 4
  %61 = getelementptr i64, ptr %heap_to_ptr46, i64 2
  store i64 0, ptr %61, align 4
  %62 = getelementptr i64, ptr %heap_to_ptr46, i64 3
  store i64 0, ptr %62, align 4
  call void @set_storage(ptr %heap_to_ptr44, ptr %heap_to_ptr46)
  br label %next
}

define void @vote_proposal(i64 %0) {
entry:
  %sender = alloca i64, align 8
  %msgSender = alloca ptr, align 8
  %proposal_ = alloca i64, align 8
  store i64 %0, ptr %proposal_, align 4
  %1 = call i64 @vector_new(i64 12)
  %heap_start = sub i64 %1, 12
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 12)
  store ptr %heap_to_ptr, ptr %msgSender, align 8
  %2 = load ptr, ptr %msgSender, align 8
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
  %7 = call i64 @vector_new(i64 8)
  %heap_start3 = sub i64 %7, 8
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  %8 = inttoptr i64 %heap_start3 to ptr
  call void @mempcy(ptr %heap_to_ptr2, ptr %8, i64 4)
  %next_dest_offset = add i64 %heap_start3, 4
  %9 = inttoptr i64 %next_dest_offset to ptr
  call void @mempcy(ptr %2, ptr %9, i64 4)
  %10 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %10, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr4, ptr %heap_to_ptr6, i64 8)
  store ptr %heap_to_ptr6, ptr %sender, align 8
  %11 = load i64, ptr %sender, align 4
  %12 = add i64 %11, 0
  %13 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %13, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 %12, ptr %heap_to_ptr8, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr8, i64 1
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr8, i64 2
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr8, i64 3
  store i64 0, ptr %16, align 4
  %17 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %17, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 1, ptr %heap_to_ptr10, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %20, align 4
  call void @set_storage(ptr %heap_to_ptr8, ptr %heap_to_ptr10)
  %21 = load i64, ptr %sender, align 4
  %22 = add i64 %21, 1
  %23 = load i64, ptr %proposal_, align 4
  %24 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %24, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 %22, ptr %heap_to_ptr12, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %27, align 4
  %28 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %28, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 %23, ptr %heap_to_ptr14, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %31, align 4
  call void @set_storage(ptr %heap_to_ptr12, ptr %heap_to_ptr14)
  %32 = load i64, ptr %proposal_, align 4
  %33 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %33, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  %34 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %34, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  store i64 2, ptr %heap_to_ptr18, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr18, i64 1
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr18, i64 2
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr18, i64 3
  store i64 0, ptr %37, align 4
  call void @get_storage(ptr %heap_to_ptr18, ptr %heap_to_ptr16)
  %storage_value = load i64, ptr %heap_to_ptr16, align 4
  %38 = sub i64 %storage_value, 1
  %39 = sub i64 %38, %32
  call void @builtin_range_check(i64 %39)
  %40 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %40, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 2, ptr %heap_to_ptr20, align 4
  %41 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %41, align 4
  %42 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %43, align 4
  %44 = call i64 @vector_new(i64 4)
  %heap_start21 = sub i64 %44, 4
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr20, ptr %heap_to_ptr22, i64 4)
  %45 = getelementptr i64, ptr %heap_to_ptr22, i64 3
  %46 = load i64, ptr %45, align 4
  %47 = mul i64 %32, 2
  %48 = add i64 %46, %47
  store i64 %48, ptr %45, align 4
  %49 = getelementptr i64, ptr %heap_to_ptr22, i64 3
  %slot_value = load i64, ptr %49, align 4
  %50 = add i64 %slot_value, 1
  %51 = load i64, ptr %proposal_, align 4
  %52 = call i64 @vector_new(i64 4)
  %heap_start23 = sub i64 %52, 4
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  %53 = call i64 @vector_new(i64 4)
  %heap_start25 = sub i64 %53, 4
  %heap_to_ptr26 = inttoptr i64 %heap_start25 to ptr
  store i64 2, ptr %heap_to_ptr26, align 4
  %54 = getelementptr i64, ptr %heap_to_ptr26, i64 1
  store i64 0, ptr %54, align 4
  %55 = getelementptr i64, ptr %heap_to_ptr26, i64 2
  store i64 0, ptr %55, align 4
  %56 = getelementptr i64, ptr %heap_to_ptr26, i64 3
  store i64 0, ptr %56, align 4
  call void @get_storage(ptr %heap_to_ptr26, ptr %heap_to_ptr24)
  %storage_value27 = load i64, ptr %heap_to_ptr24, align 4
  %57 = sub i64 %storage_value27, 1
  %58 = sub i64 %57, %51
  call void @builtin_range_check(i64 %58)
  %59 = call i64 @vector_new(i64 4)
  %heap_start28 = sub i64 %59, 4
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  store i64 2, ptr %heap_to_ptr29, align 4
  %60 = getelementptr i64, ptr %heap_to_ptr29, i64 1
  store i64 0, ptr %60, align 4
  %61 = getelementptr i64, ptr %heap_to_ptr29, i64 2
  store i64 0, ptr %61, align 4
  %62 = getelementptr i64, ptr %heap_to_ptr29, i64 3
  store i64 0, ptr %62, align 4
  %63 = call i64 @vector_new(i64 4)
  %heap_start30 = sub i64 %63, 4
  %heap_to_ptr31 = inttoptr i64 %heap_start30 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr29, ptr %heap_to_ptr31, i64 4)
  %64 = getelementptr i64, ptr %heap_to_ptr31, i64 3
  %65 = load i64, ptr %64, align 4
  %66 = mul i64 %51, 2
  %67 = add i64 %65, %66
  store i64 %67, ptr %64, align 4
  %68 = getelementptr i64, ptr %heap_to_ptr31, i64 3
  %slot_value32 = load i64, ptr %68, align 4
  %69 = add i64 %slot_value32, 1
  %70 = call i64 @vector_new(i64 4)
  %heap_start33 = sub i64 %70, 4
  %heap_to_ptr34 = inttoptr i64 %heap_start33 to ptr
  %71 = call i64 @vector_new(i64 4)
  %heap_start35 = sub i64 %71, 4
  %heap_to_ptr36 = inttoptr i64 %heap_start35 to ptr
  store i64 %69, ptr %heap_to_ptr36, align 4
  %72 = getelementptr i64, ptr %heap_to_ptr36, i64 1
  store i64 0, ptr %72, align 4
  %73 = getelementptr i64, ptr %heap_to_ptr36, i64 2
  store i64 0, ptr %73, align 4
  %74 = getelementptr i64, ptr %heap_to_ptr36, i64 3
  store i64 0, ptr %74, align 4
  call void @get_storage(ptr %heap_to_ptr36, ptr %heap_to_ptr34)
  %storage_value37 = load i64, ptr %heap_to_ptr34, align 4
  %75 = add i64 %storage_value37, 1
  call void @builtin_range_check(i64 %75)
  %76 = call i64 @vector_new(i64 4)
  %heap_start38 = sub i64 %76, 4
  %heap_to_ptr39 = inttoptr i64 %heap_start38 to ptr
  store i64 %50, ptr %heap_to_ptr39, align 4
  %77 = getelementptr i64, ptr %heap_to_ptr39, i64 1
  store i64 0, ptr %77, align 4
  %78 = getelementptr i64, ptr %heap_to_ptr39, i64 2
  store i64 0, ptr %78, align 4
  %79 = getelementptr i64, ptr %heap_to_ptr39, i64 3
  store i64 0, ptr %79, align 4
  %80 = call i64 @vector_new(i64 4)
  %heap_start40 = sub i64 %80, 4
  %heap_to_ptr41 = inttoptr i64 %heap_start40 to ptr
  store i64 %75, ptr %heap_to_ptr41, align 4
  %81 = getelementptr i64, ptr %heap_to_ptr41, i64 1
  store i64 0, ptr %81, align 4
  %82 = getelementptr i64, ptr %heap_to_ptr41, i64 2
  store i64 0, ptr %82, align 4
  %83 = getelementptr i64, ptr %heap_to_ptr41, i64 3
  store i64 0, ptr %83, align 4
  call void @set_storage(ptr %heap_to_ptr39, ptr %heap_to_ptr41)
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
  store i64 2, ptr %heap_to_ptr2, align 4
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
  store i64 2, ptr %heap_to_ptr6, align 4
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
  store i64 2, ptr %heap_to_ptr9, align 4
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
  store i64 2, ptr %heap_to_ptr20, align 4
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
  store i64 2, ptr %heap_to_ptr23, align 4
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

define ptr @getWinnerName() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %1 = call i64 @winningProposal()
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %3 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %3, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 2, ptr %heap_to_ptr2, align 4
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
  store i64 2, ptr %heap_to_ptr4, align 4
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
  %length_and_data = add i64 %storage_value11, 1
  %25 = call i64 @vector_new(i64 %length_and_data)
  %heap_start12 = sub i64 %25, %length_and_data
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  store i64 %storage_value11, ptr %heap_to_ptr13, align 4
  %26 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %26, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 %19, ptr %heap_to_ptr15, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr15, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr15, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr15, i64 3
  store i64 0, ptr %29, align 4
  %30 = call i64 @vector_new(i64 4)
  %heap_start16 = sub i64 %30, 4
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr15, ptr %heap_to_ptr17, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %heap_to_ptr17, ptr %0, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %storage_value11
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %31 = load ptr, ptr %0, align 8
  %32 = ptrtoint ptr %heap_to_ptr13 to i64
  %33 = add i64 %32, 1
  %vector_data = inttoptr i64 %33 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  %34 = call i64 @vector_new(i64 4)
  %heap_start18 = sub i64 %34, 4
  %heap_to_ptr19 = inttoptr i64 %heap_start18 to ptr
  call void @get_storage(ptr %31, ptr %heap_to_ptr19)
  %storage_value20 = load i64, ptr %heap_to_ptr19, align 4
  store i64 %storage_value20, ptr %index_access, align 4
  store ptr %31, ptr %0, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret ptr %heap_to_ptr13
}

define void @vote_test() {
entry:
  %index = alloca i64, align 8
  %0 = alloca ptr, align 8
  %index_alloca126 = alloca i64, align 8
  %1 = alloca ptr, align 8
  %index_alloca85 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca76 = alloca i64, align 8
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %3 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %3, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 1, ptr %heap_to_ptr, align 4
  %4 = ptrtoint ptr %heap_to_ptr to i64
  %5 = add i64 %4, 1
  %vector_data = inttoptr i64 %5 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  store ptr null, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %length = load i64, ptr %heap_to_ptr, align 4
  %6 = sub i64 %length, 1
  %7 = sub i64 %6, 0
  call void @builtin_range_check(i64 %7)
  %8 = ptrtoint ptr %heap_to_ptr to i64
  %9 = add i64 %8, 1
  %vector_data1 = inttoptr i64 %9 to ptr
  %index_access2 = getelementptr ptr, ptr %vector_data1, i64 0
  %10 = call i64 @vector_new(i64 11)
  %heap_start3 = sub i64 %10, 11
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 10, ptr %heap_to_ptr4, align 4
  %11 = ptrtoint ptr %heap_to_ptr4 to i64
  %12 = add i64 %11, 1
  %vector_data5 = inttoptr i64 %12 to ptr
  %index_access6 = getelementptr i64, ptr %vector_data5, i64 0
  store i64 80, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %vector_data5, i64 1
  store i64 114, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %vector_data5, i64 2
  store i64 111, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %vector_data5, i64 3
  store i64 112, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %vector_data5, i64 4
  store i64 111, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %vector_data5, i64 5
  store i64 115, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %vector_data5, i64 6
  store i64 97, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %vector_data5, i64 7
  store i64 108, ptr %index_access13, align 4
  %index_access14 = getelementptr i64, ptr %vector_data5, i64 8
  store i64 95, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %vector_data5, i64 9
  store i64 49, ptr %index_access15, align 4
  store ptr %heap_to_ptr4, ptr %index_access2, align 8
  %length16 = load i64, ptr %heap_to_ptr, align 4
  %13 = sub i64 %length16, 1
  %14 = sub i64 %13, 1
  call void @builtin_range_check(i64 %14)
  %15 = ptrtoint ptr %heap_to_ptr to i64
  %16 = add i64 %15, 1
  %vector_data17 = inttoptr i64 %16 to ptr
  %index_access18 = getelementptr ptr, ptr %vector_data17, i64 1
  %17 = call i64 @vector_new(i64 11)
  %heap_start19 = sub i64 %17, 11
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 10, ptr %heap_to_ptr20, align 4
  %18 = ptrtoint ptr %heap_to_ptr20 to i64
  %19 = add i64 %18, 1
  %vector_data21 = inttoptr i64 %19 to ptr
  %index_access22 = getelementptr i64, ptr %vector_data21, i64 0
  store i64 80, ptr %index_access22, align 4
  %index_access23 = getelementptr i64, ptr %vector_data21, i64 1
  store i64 114, ptr %index_access23, align 4
  %index_access24 = getelementptr i64, ptr %vector_data21, i64 2
  store i64 111, ptr %index_access24, align 4
  %index_access25 = getelementptr i64, ptr %vector_data21, i64 3
  store i64 112, ptr %index_access25, align 4
  %index_access26 = getelementptr i64, ptr %vector_data21, i64 4
  store i64 111, ptr %index_access26, align 4
  %index_access27 = getelementptr i64, ptr %vector_data21, i64 5
  store i64 115, ptr %index_access27, align 4
  %index_access28 = getelementptr i64, ptr %vector_data21, i64 6
  store i64 97, ptr %index_access28, align 4
  %index_access29 = getelementptr i64, ptr %vector_data21, i64 7
  store i64 108, ptr %index_access29, align 4
  %index_access30 = getelementptr i64, ptr %vector_data21, i64 8
  store i64 95, ptr %index_access30, align 4
  %index_access31 = getelementptr i64, ptr %vector_data21, i64 9
  store i64 50, ptr %index_access31, align 4
  store ptr %heap_to_ptr20, ptr %index_access18, align 8
  %length32 = load i64, ptr %heap_to_ptr, align 4
  %20 = sub i64 %length32, 1
  %21 = sub i64 %20, 2
  call void @builtin_range_check(i64 %21)
  %22 = ptrtoint ptr %heap_to_ptr to i64
  %23 = add i64 %22, 1
  %vector_data33 = inttoptr i64 %23 to ptr
  %index_access34 = getelementptr ptr, ptr %vector_data33, i64 2
  %24 = call i64 @vector_new(i64 11)
  %heap_start35 = sub i64 %24, 11
  %heap_to_ptr36 = inttoptr i64 %heap_start35 to ptr
  store i64 10, ptr %heap_to_ptr36, align 4
  %25 = ptrtoint ptr %heap_to_ptr36 to i64
  %26 = add i64 %25, 1
  %vector_data37 = inttoptr i64 %26 to ptr
  %index_access38 = getelementptr i64, ptr %vector_data37, i64 0
  store i64 80, ptr %index_access38, align 4
  %index_access39 = getelementptr i64, ptr %vector_data37, i64 1
  store i64 114, ptr %index_access39, align 4
  %index_access40 = getelementptr i64, ptr %vector_data37, i64 2
  store i64 111, ptr %index_access40, align 4
  %index_access41 = getelementptr i64, ptr %vector_data37, i64 3
  store i64 112, ptr %index_access41, align 4
  %index_access42 = getelementptr i64, ptr %vector_data37, i64 4
  store i64 111, ptr %index_access42, align 4
  %index_access43 = getelementptr i64, ptr %vector_data37, i64 5
  store i64 115, ptr %index_access43, align 4
  %index_access44 = getelementptr i64, ptr %vector_data37, i64 6
  store i64 97, ptr %index_access44, align 4
  %index_access45 = getelementptr i64, ptr %vector_data37, i64 7
  store i64 108, ptr %index_access45, align 4
  %index_access46 = getelementptr i64, ptr %vector_data37, i64 8
  store i64 95, ptr %index_access46, align 4
  %index_access47 = getelementptr i64, ptr %vector_data37, i64 9
  store i64 51, ptr %index_access47, align 4
  store ptr %heap_to_ptr36, ptr %index_access34, align 8
  store i64 0, ptr %i, align 4
  br label %cond48

cond48:                                           ; preds = %next, %done
  %27 = load i64, ptr %i, align 4
  %length50 = load i64, ptr %heap_to_ptr, align 4
  %28 = icmp ult i64 %27, %length50
  br i1 %28, label %body49, label %endfor

body49:                                           ; preds = %cond48
  %29 = call i64 @vector_new(i64 4)
  %heap_start51 = sub i64 %29, 4
  %heap_to_ptr52 = inttoptr i64 %heap_start51 to ptr
  %30 = call i64 @vector_new(i64 4)
  %heap_start53 = sub i64 %30, 4
  %heap_to_ptr54 = inttoptr i64 %heap_start53 to ptr
  store i64 2, ptr %heap_to_ptr54, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr54, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr54, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr54, i64 3
  store i64 0, ptr %33, align 4
  call void @get_storage(ptr %heap_to_ptr54, ptr %heap_to_ptr52)
  %storage_value = load i64, ptr %heap_to_ptr52, align 4
  %34 = call i64 @vector_new(i64 4)
  %heap_start55 = sub i64 %34, 4
  %heap_to_ptr56 = inttoptr i64 %heap_start55 to ptr
  store i64 2, ptr %heap_to_ptr56, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr56, i64 1
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr56, i64 2
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr56, i64 3
  store i64 0, ptr %37, align 4
  %38 = call i64 @vector_new(i64 4)
  %heap_start57 = sub i64 %38, 4
  %heap_to_ptr58 = inttoptr i64 %heap_start57 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr56, ptr %heap_to_ptr58, i64 4)
  %39 = getelementptr i64, ptr %heap_to_ptr58, i64 3
  %40 = load i64, ptr %39, align 4
  %41 = mul i64 %storage_value, 2
  %42 = add i64 %40, %41
  store i64 %42, ptr %39, align 4
  %43 = call i64 @vector_new(i64 2)
  %heap_start59 = sub i64 %43, 2
  %heap_to_ptr60 = inttoptr i64 %heap_start59 to ptr
  %struct_member = getelementptr { ptr, i64 }, ptr %heap_to_ptr60, i64 0
  %44 = load i64, ptr %i, align 4
  %length61 = load i64, ptr %heap_to_ptr, align 4
  %45 = sub i64 %length61, 1
  %46 = sub i64 %45, %44
  call void @builtin_range_check(i64 %46)
  %47 = ptrtoint ptr %heap_to_ptr to i64
  %48 = add i64 %47, 1
  %vector_data62 = inttoptr i64 %48 to ptr
  %index_access63 = getelementptr ptr, ptr %vector_data62, i64 %44
  %49 = load ptr, ptr %index_access63, align 8
  store ptr %49, ptr %struct_member, align 8
  %struct_member64 = getelementptr { ptr, i64 }, ptr %heap_to_ptr60, i64 1
  %50 = load i64, ptr %i, align 4
  store i64 %50, ptr %struct_member64, align 4
  %name = getelementptr { ptr, i64 }, ptr %heap_to_ptr60, i64 0
  %length65 = load i64, ptr %name, align 4
  %51 = call i64 @vector_new(i64 4)
  %heap_start66 = sub i64 %51, 4
  %heap_to_ptr67 = inttoptr i64 %heap_start66 to ptr
  call void @get_storage(ptr %heap_to_ptr58, ptr %heap_to_ptr67)
  %storage_value68 = load i64, ptr %heap_to_ptr67, align 4
  %52 = call i64 @vector_new(i64 4)
  %heap_start69 = sub i64 %52, 4
  %heap_to_ptr70 = inttoptr i64 %heap_start69 to ptr
  store i64 %length65, ptr %heap_to_ptr70, align 4
  %53 = getelementptr i64, ptr %heap_to_ptr70, i64 1
  store i64 0, ptr %53, align 4
  %54 = getelementptr i64, ptr %heap_to_ptr70, i64 2
  store i64 0, ptr %54, align 4
  %55 = getelementptr i64, ptr %heap_to_ptr70, i64 3
  store i64 0, ptr %55, align 4
  call void @set_storage(ptr %heap_to_ptr58, ptr %heap_to_ptr70)
  %56 = call i64 @vector_new(i64 4)
  %heap_start71 = sub i64 %56, 4
  %heap_to_ptr72 = inttoptr i64 %heap_start71 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr58, ptr %heap_to_ptr72, i64 4)
  store i64 0, ptr %index_alloca76, align 4
  store ptr %heap_to_ptr72, ptr %2, align 8
  br label %cond73

next:                                             ; preds = %done84
  %57 = load i64, ptr %i, align 4
  %58 = add i64 %57, 1
  store i64 %58, ptr %i, align 4
  br label %cond48

endfor:                                           ; preds = %cond48
  %59 = call i64 @vector_new(i64 4)
  %heap_start102 = sub i64 %59, 4
  %heap_to_ptr103 = inttoptr i64 %heap_start102 to ptr
  %60 = call i64 @vector_new(i64 4)
  %heap_start104 = sub i64 %60, 4
  %heap_to_ptr105 = inttoptr i64 %heap_start104 to ptr
  store i64 2, ptr %heap_to_ptr105, align 4
  %61 = getelementptr i64, ptr %heap_to_ptr105, i64 1
  store i64 0, ptr %61, align 4
  %62 = getelementptr i64, ptr %heap_to_ptr105, i64 2
  store i64 0, ptr %62, align 4
  %63 = getelementptr i64, ptr %heap_to_ptr105, i64 3
  store i64 0, ptr %63, align 4
  call void @get_storage(ptr %heap_to_ptr105, ptr %heap_to_ptr103)
  %storage_value106 = load i64, ptr %heap_to_ptr103, align 4
  %64 = sub i64 %storage_value106, 1
  %65 = sub i64 %64, 0
  call void @builtin_range_check(i64 %65)
  %66 = call i64 @vector_new(i64 4)
  %heap_start107 = sub i64 %66, 4
  %heap_to_ptr108 = inttoptr i64 %heap_start107 to ptr
  store i64 2, ptr %heap_to_ptr108, align 4
  %67 = getelementptr i64, ptr %heap_to_ptr108, i64 1
  store i64 0, ptr %67, align 4
  %68 = getelementptr i64, ptr %heap_to_ptr108, i64 2
  store i64 0, ptr %68, align 4
  %69 = getelementptr i64, ptr %heap_to_ptr108, i64 3
  store i64 0, ptr %69, align 4
  %70 = call i64 @vector_new(i64 4)
  %heap_start109 = sub i64 %70, 4
  %heap_to_ptr110 = inttoptr i64 %heap_start109 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr108, ptr %heap_to_ptr110, i64 4)
  %71 = getelementptr i64, ptr %heap_to_ptr110, i64 3
  %72 = load i64, ptr %71, align 4
  %73 = add i64 %72, 0
  store i64 %73, ptr %71, align 4
  %74 = getelementptr i64, ptr %heap_to_ptr110, i64 3
  %slot_value111 = load i64, ptr %74, align 4
  %75 = add i64 %slot_value111, 0
  %76 = call i64 @vector_new(i64 4)
  %heap_start112 = sub i64 %76, 4
  %heap_to_ptr113 = inttoptr i64 %heap_start112 to ptr
  %77 = call i64 @vector_new(i64 4)
  %heap_start114 = sub i64 %77, 4
  %heap_to_ptr115 = inttoptr i64 %heap_start114 to ptr
  store i64 %75, ptr %heap_to_ptr115, align 4
  %78 = getelementptr i64, ptr %heap_to_ptr115, i64 1
  store i64 0, ptr %78, align 4
  %79 = getelementptr i64, ptr %heap_to_ptr115, i64 2
  store i64 0, ptr %79, align 4
  %80 = getelementptr i64, ptr %heap_to_ptr115, i64 3
  store i64 0, ptr %80, align 4
  call void @get_storage(ptr %heap_to_ptr115, ptr %heap_to_ptr113)
  %storage_value116 = load i64, ptr %heap_to_ptr113, align 4
  %length_and_data = add i64 %storage_value116, 1
  %81 = call i64 @vector_new(i64 %length_and_data)
  %heap_start117 = sub i64 %81, %length_and_data
  %heap_to_ptr118 = inttoptr i64 %heap_start117 to ptr
  store i64 %storage_value116, ptr %heap_to_ptr118, align 4
  %82 = call i64 @vector_new(i64 4)
  %heap_start119 = sub i64 %82, 4
  %heap_to_ptr120 = inttoptr i64 %heap_start119 to ptr
  store i64 %75, ptr %heap_to_ptr120, align 4
  %83 = getelementptr i64, ptr %heap_to_ptr120, i64 1
  store i64 0, ptr %83, align 4
  %84 = getelementptr i64, ptr %heap_to_ptr120, i64 2
  store i64 0, ptr %84, align 4
  %85 = getelementptr i64, ptr %heap_to_ptr120, i64 3
  store i64 0, ptr %85, align 4
  %86 = call i64 @vector_new(i64 4)
  %heap_start121 = sub i64 %86, 4
  %heap_to_ptr122 = inttoptr i64 %heap_start121 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr120, ptr %heap_to_ptr122, i64 4)
  store i64 0, ptr %index_alloca126, align 4
  store ptr %heap_to_ptr122, ptr %0, align 8
  br label %cond123

cond73:                                           ; preds = %body74, %body49
  %index_value77 = load i64, ptr %index_alloca76, align 4
  %loop_cond78 = icmp ult i64 %index_value77, %length65
  br i1 %loop_cond78, label %body74, label %done75

body74:                                           ; preds = %cond73
  %87 = load ptr, ptr %2, align 8
  %88 = ptrtoint ptr %name to i64
  %89 = add i64 %88, 1
  %vector_data79 = inttoptr i64 %89 to ptr
  %index_access80 = getelementptr i64, ptr %vector_data79, i64 %index_value77
  call void @set_storage(ptr %87, ptr %index_access80)
  %90 = getelementptr i64, ptr %87, i64 3
  %slot_value = load i64, ptr %90, align 4
  %91 = add i64 %slot_value, 1
  store i64 %91, ptr %2, align 4
  %next_index81 = add i64 %index_value77, 1
  store i64 %next_index81, ptr %index_alloca76, align 4
  br label %cond73

done75:                                           ; preds = %cond73
  store i64 %length65, ptr %index_alloca85, align 4
  store ptr %heap_to_ptr72, ptr %1, align 8
  br label %cond82

cond82:                                           ; preds = %body83, %done75
  %index_value86 = load i64, ptr %index_alloca85, align 4
  %loop_cond87 = icmp ult i64 %index_value86, %storage_value68
  br i1 %loop_cond87, label %body83, label %done84

body83:                                           ; preds = %cond82
  %92 = load ptr, ptr %1, align 8
  %93 = call i64 @vector_new(i64 4)
  %heap_start88 = sub i64 %93, 4
  %heap_to_ptr89 = inttoptr i64 %heap_start88 to ptr
  %storage_key_ptr = getelementptr i64, ptr %heap_to_ptr89, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr90 = getelementptr i64, ptr %heap_to_ptr89, i64 1
  store i64 0, ptr %storage_key_ptr90, align 4
  %storage_key_ptr91 = getelementptr i64, ptr %heap_to_ptr89, i64 2
  store i64 0, ptr %storage_key_ptr91, align 4
  %storage_key_ptr92 = getelementptr i64, ptr %heap_to_ptr89, i64 3
  store i64 0, ptr %storage_key_ptr92, align 4
  call void @set_storage(ptr %92, ptr %heap_to_ptr89)
  %94 = getelementptr i64, ptr %92, i64 3
  %slot_value93 = load i64, ptr %94, align 4
  %95 = add i64 %slot_value93, 1
  store i64 %95, ptr %1, align 4
  %next_index94 = add i64 %index_value86, 1
  store i64 %next_index94, ptr %index_alloca85, align 4
  br label %cond82

done84:                                           ; preds = %cond82
  %96 = getelementptr i64, ptr %heap_to_ptr58, i64 3
  %slot_value95 = load i64, ptr %96, align 4
  %97 = add i64 %slot_value95, 1
  %voteCount = getelementptr { ptr, i64 }, ptr %heap_to_ptr60, i64 1
  %98 = call i64 @vector_new(i64 4)
  %heap_start96 = sub i64 %98, 4
  %heap_to_ptr97 = inttoptr i64 %heap_start96 to ptr
  store i64 %97, ptr %heap_to_ptr97, align 4
  %99 = getelementptr i64, ptr %heap_to_ptr97, i64 1
  store i64 0, ptr %99, align 4
  %100 = getelementptr i64, ptr %heap_to_ptr97, i64 2
  store i64 0, ptr %100, align 4
  %101 = getelementptr i64, ptr %heap_to_ptr97, i64 3
  store i64 0, ptr %101, align 4
  call void @set_storage(ptr %heap_to_ptr97, ptr %voteCount)
  %new_length = add i64 %storage_value, 1
  %102 = call i64 @vector_new(i64 4)
  %heap_start98 = sub i64 %102, 4
  %heap_to_ptr99 = inttoptr i64 %heap_start98 to ptr
  store i64 2, ptr %heap_to_ptr99, align 4
  %103 = getelementptr i64, ptr %heap_to_ptr99, i64 1
  store i64 0, ptr %103, align 4
  %104 = getelementptr i64, ptr %heap_to_ptr99, i64 2
  store i64 0, ptr %104, align 4
  %105 = getelementptr i64, ptr %heap_to_ptr99, i64 3
  store i64 0, ptr %105, align 4
  %106 = call i64 @vector_new(i64 4)
  %heap_start100 = sub i64 %106, 4
  %heap_to_ptr101 = inttoptr i64 %heap_start100 to ptr
  store i64 %new_length, ptr %heap_to_ptr101, align 4
  %107 = getelementptr i64, ptr %heap_to_ptr101, i64 1
  store i64 0, ptr %107, align 4
  %108 = getelementptr i64, ptr %heap_to_ptr101, i64 2
  store i64 0, ptr %108, align 4
  %109 = getelementptr i64, ptr %heap_to_ptr101, i64 3
  store i64 0, ptr %109, align 4
  call void @set_storage(ptr %heap_to_ptr99, ptr %heap_to_ptr101)
  br label %next

cond123:                                          ; preds = %body124, %endfor
  %index_value127 = load i64, ptr %index_alloca126, align 4
  %loop_cond128 = icmp ult i64 %index_value127, %storage_value116
  br i1 %loop_cond128, label %body124, label %done125

body124:                                          ; preds = %cond123
  %110 = load ptr, ptr %0, align 8
  %111 = ptrtoint ptr %heap_to_ptr118 to i64
  %112 = add i64 %111, 1
  %vector_data129 = inttoptr i64 %112 to ptr
  %index_access130 = getelementptr i64, ptr %vector_data129, i64 %index_value127
  %113 = call i64 @vector_new(i64 4)
  %heap_start131 = sub i64 %113, 4
  %heap_to_ptr132 = inttoptr i64 %heap_start131 to ptr
  call void @get_storage(ptr %110, ptr %heap_to_ptr132)
  %storage_value133 = load i64, ptr %heap_to_ptr132, align 4
  store i64 %storage_value133, ptr %index_access130, align 4
  store ptr %110, ptr %0, align 8
  %next_index134 = add i64 %index_value127, 1
  store i64 %next_index134, ptr %index_alloca126, align 4
  br label %cond123

done125:                                          ; preds = %cond123
  %114 = ptrtoint ptr %heap_to_ptr118 to i64
  %115 = add i64 %114, 1
  %vector_data135 = inttoptr i64 %115 to ptr
  %length136 = load i64, ptr %heap_to_ptr118, align 4
  %116 = call i64 @vector_new(i64 11)
  %heap_start137 = sub i64 %116, 11
  %heap_to_ptr138 = inttoptr i64 %heap_start137 to ptr
  store i64 10, ptr %heap_to_ptr138, align 4
  %117 = ptrtoint ptr %heap_to_ptr138 to i64
  %118 = add i64 %117, 1
  %vector_data139 = inttoptr i64 %118 to ptr
  %index_access140 = getelementptr i64, ptr %vector_data139, i64 0
  store i64 80, ptr %index_access140, align 4
  %index_access141 = getelementptr i64, ptr %vector_data139, i64 1
  store i64 114, ptr %index_access141, align 4
  %index_access142 = getelementptr i64, ptr %vector_data139, i64 2
  store i64 111, ptr %index_access142, align 4
  %index_access143 = getelementptr i64, ptr %vector_data139, i64 3
  store i64 112, ptr %index_access143, align 4
  %index_access144 = getelementptr i64, ptr %vector_data139, i64 4
  store i64 111, ptr %index_access144, align 4
  %index_access145 = getelementptr i64, ptr %vector_data139, i64 5
  store i64 115, ptr %index_access145, align 4
  %index_access146 = getelementptr i64, ptr %vector_data139, i64 6
  store i64 97, ptr %index_access146, align 4
  %index_access147 = getelementptr i64, ptr %vector_data139, i64 7
  store i64 108, ptr %index_access147, align 4
  %index_access148 = getelementptr i64, ptr %vector_data139, i64 8
  store i64 95, ptr %index_access148, align 4
  %index_access149 = getelementptr i64, ptr %vector_data139, i64 9
  store i64 49, ptr %index_access149, align 4
  %119 = ptrtoint ptr %heap_to_ptr138 to i64
  %120 = add i64 %119, 1
  %vector_data150 = inttoptr i64 %120 to ptr
  %length151 = load i64, ptr %heap_to_ptr138, align 4
  %121 = icmp eq i64 %length136, %length151
  %122 = zext i1 %121 to i64
  call void @builtin_assert(i64 %122)
  store i64 0, ptr %index, align 4
  br label %cond152

cond152:                                          ; preds = %body153, %done125
  %index155 = load i64, ptr %index, align 4
  %123 = icmp ult i64 %index155, %length136
  br i1 %123, label %body153, label %done154

body153:                                          ; preds = %cond152
  %left_char_ptr = getelementptr i64, ptr %vector_data135, i64 %index155
  %right_char_ptr = getelementptr i64, ptr %vector_data150, i64 %index155
  %left_char = load i64, ptr %left_char_ptr, align 4
  %right_char = load i64, ptr %right_char_ptr, align 4
  %comparison = icmp eq i64 %left_char, %right_char
  %next_index156 = add i64 %index155, 1
  store i64 %next_index156, ptr %index, align 4
  br i1 %comparison, label %cond152, label %done154

done154:                                          ; preds = %body153, %cond152
  %equal = icmp eq i64 %index155, %length151
  %124 = zext i1 %equal to i64
  call void @builtin_assert(i64 %124)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %size_var = alloca i64, align 8
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 3920769769, label %func_0_dispatch
    i64 2791810083, label %func_1_dispatch
    i64 3186728800, label %func_2_dispatch
    i64 363199787, label %func_3_dispatch
    i64 69185575, label %func_4_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  store i64 0, ptr %size_var, align 4
  %length = load i64, ptr %3, align 4
  %4 = load i64, ptr %size_var, align 4
  %5 = add i64 %4, %length
  store i64 %5, ptr %size_var, align 4
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %length1 = load i64, ptr %3, align 4
  %6 = icmp ult i64 %index, %length1
  br i1 %6, label %body, label %end_for

next:                                             ; preds = %body
  %index4 = load i64, ptr %index_ptr, align 4
  %7 = add i64 %index4, 1
  store i64 %7, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %length2 = load i64, ptr %3, align 4
  %8 = sub i64 %length2, 1
  %9 = sub i64 %8, %index
  call void @builtin_range_check(i64 %9)
  %10 = ptrtoint ptr %3 to i64
  %11 = add i64 %10, 1
  %vector_data = inttoptr i64 %11 to ptr
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index
  %length3 = load i64, ptr %index_access, align 4
  %12 = add i64 %length3, 1
  %13 = load i64, ptr %size_var, align 4
  %14 = add i64 %13, %12
  store i64 %14, ptr %size_var, align 4
  br label %next

end_for:                                          ; preds = %cond
  %15 = load i64, ptr %size_var, align 4
  call void @contract_init(ptr %3)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start5 = ptrtoint ptr %input to i64
  %16 = inttoptr i64 %input_start5 to ptr
  %decode_value = load i64, ptr %16, align 4
  call void @vote_proposal(i64 %decode_value)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %17 = call i64 @winningProposal()
  %18 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %18, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %17, ptr %encode_value_ptr, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %encode_value_ptr6, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %19 = call ptr @getWinnerName()
  %length7 = load i64, ptr %19, align 4
  %20 = add i64 %length7, 1
  %heap_size = add i64 %20, 1
  %21 = call i64 @vector_new(i64 %heap_size)
  %heap_start8 = sub i64 %21, %heap_size
  %heap_to_ptr9 = inttoptr i64 %heap_start8 to ptr
  %length10 = load i64, ptr %19, align 4
  %22 = ptrtoint ptr %heap_to_ptr9 to i64
  %buffer_start = add i64 %22, 1
  %23 = inttoptr i64 %buffer_start to ptr
  %encode_value_ptr11 = getelementptr i64, ptr %23, i64 1
  store i64 %length10, ptr %encode_value_ptr11, align 4
  %24 = ptrtoint ptr %19 to i64
  %25 = add i64 %24, 1
  %vector_data12 = inttoptr i64 %25 to ptr
  call void @mempcy(ptr %vector_data12, ptr %23, i64 %length10)
  %26 = add i64 %length10, 1
  %encode_value_ptr13 = getelementptr i64, ptr %heap_to_ptr9, i64 %26
  store i64 %20, ptr %encode_value_ptr13, align 4
  call void @set_tape_data(i64 %heap_start8, i64 %heap_size)
  ret void

func_4_dispatch:                                  ; preds = %entry
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
