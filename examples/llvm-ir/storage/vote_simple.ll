; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote_simple.ola"

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
  %i = alloca i64, align 8
  %proposalNames_ = alloca ptr, align 8
  store ptr %0, ptr %proposalNames_, align 8
  %1 = load ptr, ptr %proposalNames_, align 8
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %2 = load i64, ptr %i, align 4
  %length = load i64, ptr %1, align 4
  %3 = icmp ult i64 %2, %length
  br i1 %3, label %body, label %endfor

body:                                             ; preds = %cond
  %4 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %4, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %5 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %5, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 1, ptr %heap_to_ptr2, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %8, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  %storage_value = load i64, ptr %heap_to_ptr, align 4
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
  %16 = mul i64 %storage_value, 2
  %17 = add i64 %15, %16
  store i64 %17, ptr %14, align 4
  %18 = call i64 @vector_new(i64 2)
  %heap_start7 = sub i64 %18, 2
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  %struct_member = getelementptr { i64, i64 }, ptr %heap_to_ptr8, i64 0
  %19 = load i64, ptr %i, align 4
  %length9 = load i64, ptr %1, align 4
  %20 = sub i64 %length9, 1
  %21 = sub i64 %20, %19
  call void @builtin_range_check(i64 %21)
  %22 = ptrtoint ptr %1 to i64
  %23 = add i64 %22, 1
  %vector_data = inttoptr i64 %23 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %19
  %24 = load i64, ptr %index_access, align 4
  store i64 %24, ptr %struct_member, align 4
  %struct_member10 = getelementptr { i64, i64 }, ptr %heap_to_ptr8, i64 1
  store i64 0, ptr %struct_member10, align 4
  %name = getelementptr { i64, i64 }, ptr %heap_to_ptr8, i64 0
  call void @set_storage(ptr %heap_to_ptr6, ptr %name)
  %25 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  %slot_value = load i64, ptr %25, align 4
  %26 = add i64 %slot_value, 1
  %voteCount = getelementptr { i64, i64 }, ptr %heap_to_ptr8, i64 1
  %27 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %27, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 %26, ptr %heap_to_ptr12, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %30, align 4
  call void @set_storage(ptr %heap_to_ptr12, ptr %voteCount)
  %new_length = add i64 %storage_value, 1
  %31 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %31, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 1, ptr %heap_to_ptr14, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %33, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %34, align 4
  %35 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %35, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  store i64 %new_length, ptr %heap_to_ptr16, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr16, i64 1
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr16, i64 2
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  store i64 0, ptr %38, align 4
  call void @set_storage(ptr %heap_to_ptr14, ptr %heap_to_ptr16)
  br label %next

next:                                             ; preds = %body
  %39 = load i64, ptr %i, align 4
  %40 = add i64 %39, 1
  store i64 %40, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void
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
  store i64 0, ptr %heap_to_ptr2, align 4
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
  %14 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %14, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 %12, ptr %heap_to_ptr10, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %17, align 4
  call void @get_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr8)
  %storage_value = load i64, ptr %heap_to_ptr8, align 4
  %18 = icmp eq i64 %storage_value, 0
  %19 = zext i1 %18 to i64
  call void @builtin_assert(i64 %19)
  %20 = load i64, ptr %sender, align 4
  %21 = add i64 %20, 0
  %22 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %22, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 %21, ptr %heap_to_ptr12, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %25, align 4
  %26 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %26, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 1, ptr %heap_to_ptr14, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %29, align 4
  call void @set_storage(ptr %heap_to_ptr12, ptr %heap_to_ptr14)
  %30 = load i64, ptr %sender, align 4
  %31 = add i64 %30, 1
  %32 = load i64, ptr %proposal_, align 4
  %33 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %33, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  store i64 %31, ptr %heap_to_ptr16, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr16, i64 1
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr16, i64 2
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  store i64 0, ptr %36, align 4
  %37 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %37, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  store i64 %32, ptr %heap_to_ptr18, align 4
  %38 = getelementptr i64, ptr %heap_to_ptr18, i64 1
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %heap_to_ptr18, i64 2
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr18, i64 3
  store i64 0, ptr %40, align 4
  call void @set_storage(ptr %heap_to_ptr16, ptr %heap_to_ptr18)
  %41 = load i64, ptr %proposal_, align 4
  %42 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %42, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  %43 = call i64 @vector_new(i64 4)
  %heap_start21 = sub i64 %43, 4
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  store i64 1, ptr %heap_to_ptr22, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr22, i64 1
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %heap_to_ptr22, i64 2
  store i64 0, ptr %45, align 4
  %46 = getelementptr i64, ptr %heap_to_ptr22, i64 3
  store i64 0, ptr %46, align 4
  call void @get_storage(ptr %heap_to_ptr22, ptr %heap_to_ptr20)
  %storage_value23 = load i64, ptr %heap_to_ptr20, align 4
  %47 = sub i64 %storage_value23, 1
  %48 = sub i64 %47, %41
  call void @builtin_range_check(i64 %48)
  %49 = call i64 @vector_new(i64 4)
  %heap_start24 = sub i64 %49, 4
  %heap_to_ptr25 = inttoptr i64 %heap_start24 to ptr
  store i64 1, ptr %heap_to_ptr25, align 4
  %50 = getelementptr i64, ptr %heap_to_ptr25, i64 1
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %heap_to_ptr25, i64 2
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %heap_to_ptr25, i64 3
  store i64 0, ptr %52, align 4
  %53 = call i64 @vector_new(i64 4)
  %heap_start26 = sub i64 %53, 4
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr25, ptr %heap_to_ptr27, i64 4)
  %54 = getelementptr i64, ptr %heap_to_ptr27, i64 3
  %55 = load i64, ptr %54, align 4
  %56 = mul i64 %41, 2
  %57 = add i64 %55, %56
  store i64 %57, ptr %54, align 4
  %58 = getelementptr i64, ptr %heap_to_ptr27, i64 3
  %slot_value = load i64, ptr %58, align 4
  %59 = add i64 %slot_value, 1
  %60 = load i64, ptr %proposal_, align 4
  %61 = call i64 @vector_new(i64 4)
  %heap_start28 = sub i64 %61, 4
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  %62 = call i64 @vector_new(i64 4)
  %heap_start30 = sub i64 %62, 4
  %heap_to_ptr31 = inttoptr i64 %heap_start30 to ptr
  store i64 1, ptr %heap_to_ptr31, align 4
  %63 = getelementptr i64, ptr %heap_to_ptr31, i64 1
  store i64 0, ptr %63, align 4
  %64 = getelementptr i64, ptr %heap_to_ptr31, i64 2
  store i64 0, ptr %64, align 4
  %65 = getelementptr i64, ptr %heap_to_ptr31, i64 3
  store i64 0, ptr %65, align 4
  call void @get_storage(ptr %heap_to_ptr31, ptr %heap_to_ptr29)
  %storage_value32 = load i64, ptr %heap_to_ptr29, align 4
  %66 = sub i64 %storage_value32, 1
  %67 = sub i64 %66, %60
  call void @builtin_range_check(i64 %67)
  %68 = call i64 @vector_new(i64 4)
  %heap_start33 = sub i64 %68, 4
  %heap_to_ptr34 = inttoptr i64 %heap_start33 to ptr
  store i64 1, ptr %heap_to_ptr34, align 4
  %69 = getelementptr i64, ptr %heap_to_ptr34, i64 1
  store i64 0, ptr %69, align 4
  %70 = getelementptr i64, ptr %heap_to_ptr34, i64 2
  store i64 0, ptr %70, align 4
  %71 = getelementptr i64, ptr %heap_to_ptr34, i64 3
  store i64 0, ptr %71, align 4
  %72 = call i64 @vector_new(i64 4)
  %heap_start35 = sub i64 %72, 4
  %heap_to_ptr36 = inttoptr i64 %heap_start35 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr34, ptr %heap_to_ptr36, i64 4)
  %73 = getelementptr i64, ptr %heap_to_ptr36, i64 3
  %74 = load i64, ptr %73, align 4
  %75 = mul i64 %60, 2
  %76 = add i64 %74, %75
  store i64 %76, ptr %73, align 4
  %77 = getelementptr i64, ptr %heap_to_ptr36, i64 3
  %slot_value37 = load i64, ptr %77, align 4
  %78 = add i64 %slot_value37, 1
  %79 = call i64 @vector_new(i64 4)
  %heap_start38 = sub i64 %79, 4
  %heap_to_ptr39 = inttoptr i64 %heap_start38 to ptr
  %80 = call i64 @vector_new(i64 4)
  %heap_start40 = sub i64 %80, 4
  %heap_to_ptr41 = inttoptr i64 %heap_start40 to ptr
  store i64 %78, ptr %heap_to_ptr41, align 4
  %81 = getelementptr i64, ptr %heap_to_ptr41, i64 1
  store i64 0, ptr %81, align 4
  %82 = getelementptr i64, ptr %heap_to_ptr41, i64 2
  store i64 0, ptr %82, align 4
  %83 = getelementptr i64, ptr %heap_to_ptr41, i64 3
  store i64 0, ptr %83, align 4
  call void @get_storage(ptr %heap_to_ptr41, ptr %heap_to_ptr39)
  %storage_value42 = load i64, ptr %heap_to_ptr39, align 4
  %84 = add i64 %storage_value42, 1
  call void @builtin_range_check(i64 %84)
  %85 = call i64 @vector_new(i64 4)
  %heap_start43 = sub i64 %85, 4
  %heap_to_ptr44 = inttoptr i64 %heap_start43 to ptr
  store i64 %59, ptr %heap_to_ptr44, align 4
  %86 = getelementptr i64, ptr %heap_to_ptr44, i64 1
  store i64 0, ptr %86, align 4
  %87 = getelementptr i64, ptr %heap_to_ptr44, i64 2
  store i64 0, ptr %87, align 4
  %88 = getelementptr i64, ptr %heap_to_ptr44, i64 3
  store i64 0, ptr %88, align 4
  %89 = call i64 @vector_new(i64 4)
  %heap_start45 = sub i64 %89, 4
  %heap_to_ptr46 = inttoptr i64 %heap_start45 to ptr
  store i64 %84, ptr %heap_to_ptr46, align 4
  %90 = getelementptr i64, ptr %heap_to_ptr46, i64 1
  store i64 0, ptr %90, align 4
  %91 = getelementptr i64, ptr %heap_to_ptr46, i64 2
  store i64 0, ptr %91, align 4
  %92 = getelementptr i64, ptr %heap_to_ptr46, i64 3
  store i64 0, ptr %92, align 4
  call void @set_storage(ptr %heap_to_ptr44, ptr %heap_to_ptr46)
  %93 = call i64 @vector_new(i64 4)
  %heap_start47 = sub i64 %93, 4
  %heap_to_ptr48 = inttoptr i64 %heap_start47 to ptr
  %94 = call i64 @vector_new(i64 4)
  %heap_start49 = sub i64 %94, 4
  %heap_to_ptr50 = inttoptr i64 %heap_start49 to ptr
  store i64 1, ptr %heap_to_ptr50, align 4
  %95 = getelementptr i64, ptr %heap_to_ptr50, i64 1
  store i64 0, ptr %95, align 4
  %96 = getelementptr i64, ptr %heap_to_ptr50, i64 2
  store i64 0, ptr %96, align 4
  %97 = getelementptr i64, ptr %heap_to_ptr50, i64 3
  store i64 0, ptr %97, align 4
  call void @get_storage(ptr %heap_to_ptr50, ptr %heap_to_ptr48)
  %storage_value51 = load i64, ptr %heap_to_ptr48, align 4
  %98 = sub i64 %storage_value51, 1
  %99 = sub i64 %98, 2
  call void @builtin_range_check(i64 %99)
  %100 = call i64 @vector_new(i64 4)
  %heap_start52 = sub i64 %100, 4
  %heap_to_ptr53 = inttoptr i64 %heap_start52 to ptr
  store i64 1, ptr %heap_to_ptr53, align 4
  %101 = getelementptr i64, ptr %heap_to_ptr53, i64 1
  store i64 0, ptr %101, align 4
  %102 = getelementptr i64, ptr %heap_to_ptr53, i64 2
  store i64 0, ptr %102, align 4
  %103 = getelementptr i64, ptr %heap_to_ptr53, i64 3
  store i64 0, ptr %103, align 4
  %104 = call i64 @vector_new(i64 4)
  %heap_start54 = sub i64 %104, 4
  %heap_to_ptr55 = inttoptr i64 %heap_start54 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr53, ptr %heap_to_ptr55, i64 4)
  %105 = getelementptr i64, ptr %heap_to_ptr55, i64 3
  %106 = load i64, ptr %105, align 4
  %107 = add i64 %106, 4
  store i64 %107, ptr %105, align 4
  %108 = getelementptr i64, ptr %heap_to_ptr55, i64 3
  %slot_value56 = load i64, ptr %108, align 4
  %109 = add i64 %slot_value56, 1
  %110 = call i64 @vector_new(i64 4)
  %heap_start57 = sub i64 %110, 4
  %heap_to_ptr58 = inttoptr i64 %heap_start57 to ptr
  %111 = call i64 @vector_new(i64 4)
  %heap_start59 = sub i64 %111, 4
  %heap_to_ptr60 = inttoptr i64 %heap_start59 to ptr
  store i64 %109, ptr %heap_to_ptr60, align 4
  %112 = getelementptr i64, ptr %heap_to_ptr60, i64 1
  store i64 0, ptr %112, align 4
  %113 = getelementptr i64, ptr %heap_to_ptr60, i64 2
  store i64 0, ptr %113, align 4
  %114 = getelementptr i64, ptr %heap_to_ptr60, i64 3
  store i64 0, ptr %114, align 4
  call void @get_storage(ptr %heap_to_ptr60, ptr %heap_to_ptr58)
  %storage_value61 = load i64, ptr %heap_to_ptr58, align 4
  %115 = icmp eq i64 %storage_value61, 2
  %116 = zext i1 %115 to i64
  call void @builtin_assert(i64 %116)
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
  %winnerP = alloca i64, align 8
  %0 = call i64 @winningProposal()
  store i64 %0, ptr %winnerP, align 4
  %1 = load i64, ptr %winnerP, align 4
  %2 = icmp eq i64 %1, 2
  %3 = zext i1 %2 to i64
  call void @builtin_assert(i64 %3)
  %4 = load i64, ptr %winnerP, align 4
  %5 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %5, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %6 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %6, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 1, ptr %heap_to_ptr2, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %9, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  %storage_value = load i64, ptr %heap_to_ptr, align 4
  %10 = sub i64 %storage_value, 1
  %11 = sub i64 %10, %4
  call void @builtin_range_check(i64 %11)
  %12 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %12, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 1, ptr %heap_to_ptr4, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr4, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr4, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr4, i64 3
  store i64 0, ptr %15, align 4
  %16 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %16, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr4, ptr %heap_to_ptr6, i64 4)
  %17 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  %18 = load i64, ptr %17, align 4
  %19 = mul i64 %4, 2
  %20 = add i64 %18, %19
  store i64 %20, ptr %17, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  %slot_value = load i64, ptr %21, align 4
  %22 = add i64 %slot_value, 0
  %23 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %23, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  %24 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %24, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 %22, ptr %heap_to_ptr10, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %27, align 4
  call void @get_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr8)
  %storage_value11 = load i64, ptr %heap_to_ptr8, align 4
  store i64 %storage_value11, ptr %winnerName, align 4
  %28 = load i64, ptr %winnerName, align 4
  %29 = icmp eq i64 %28, 66
  %30 = zext i1 %29 to i64
  call void @builtin_assert(i64 %30)
  %31 = load i64, ptr %winnerName, align 4
  ret i64 %31
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 2817135588, label %func_0_dispatch
    i64 2791810083, label %func_1_dispatch
    i64 3186728800, label %func_2_dispatch
    i64 363199787, label %func_3_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %length = load i64, ptr %3, align 4
  %4 = mul i64 %length, 1
  %5 = add i64 %4, 1
  call void @contract_init(ptr %3)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start1 = ptrtoint ptr %input to i64
  %6 = inttoptr i64 %input_start1 to ptr
  %decode_value = load i64, ptr %6, align 4
  call void @vote_proposal(i64 %decode_value)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %7 = call i64 @winningProposal()
  %8 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %8, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %7, ptr %encode_value_ptr, align 4
  %encode_value_ptr2 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %encode_value_ptr2, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %9 = call i64 @getWinnerName()
  %10 = call i64 @vector_new(i64 2)
  %heap_start3 = sub i64 %10, 2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  %encode_value_ptr5 = getelementptr i64, ptr %heap_to_ptr4, i64 0
  store i64 %9, ptr %encode_value_ptr5, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %heap_to_ptr4, i64 1
  store i64 1, ptr %encode_value_ptr6, align 4
  call void @set_tape_data(i64 %heap_start3, i64 2)
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
