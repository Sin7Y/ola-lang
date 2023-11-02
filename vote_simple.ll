; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote_simple.ola"

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

declare void @prophet_printf(i64, i64)

define void @memcpy(ptr %0, ptr %1, i64 %2) {
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

define i64 @memcmp_eq(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %right_ptr_alloca = alloca ptr, align 8
  %left_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %left_ptr_alloca, align 8
  %left_ptr = load ptr, ptr %left_ptr_alloca, align 8
  store ptr %1, ptr %right_ptr_alloca, align 8
  %right_ptr = load ptr, ptr %right_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %len
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %left_ptr, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %right_ptr, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %compare = icmp eq i64 %left_elem, %right_elem
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @memcmp_ugt(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %right_ptr_alloca = alloca ptr, align 8
  %left_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %left_ptr_alloca, align 8
  %left_ptr = load ptr, ptr %left_ptr_alloca, align 8
  store ptr %1, ptr %right_ptr_alloca, align 8
  %right_ptr = load ptr, ptr %right_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %len
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %left_ptr, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %right_ptr, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %compare = icmp ugt i64 %left_elem, %right_elem
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @memcmp_uge(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %right_ptr_alloca = alloca ptr, align 8
  %left_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %left_ptr_alloca, align 8
  %left_ptr = load ptr, ptr %left_ptr_alloca, align 8
  store ptr %1, ptr %right_ptr_alloca, align 8
  %right_ptr = load ptr, ptr %right_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %len
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %left_ptr, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %right_ptr, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %compare = icmp uge i64 %left_elem, %right_elem
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

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
  %hash_value_low = load i64, ptr %14, align 4
  %15 = mul i64 %storage_value, 2
  %storage_array_offset = add i64 %hash_value_low, %15
  store i64 %storage_array_offset, ptr %14, align 4
  %16 = call i64 @vector_new(i64 2)
  %heap_start7 = sub i64 %16, 2
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  %struct_member = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr8, i32 0, i32 0
  %17 = load i64, ptr %i, align 4
  %length9 = load i64, ptr %1, align 4
  %18 = sub i64 %length9, 1
  %19 = sub i64 %18, %17
  call void @builtin_range_check(i64 %19)
  %20 = ptrtoint ptr %1 to i64
  %21 = add i64 %20, 1
  %vector_data = inttoptr i64 %21 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %17
  %22 = load i64, ptr %index_access, align 4
  store i64 %22, ptr %struct_member, align 4
  %struct_member10 = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr8, i32 0, i32 1
  store i64 0, ptr %struct_member10, align 4
  %name = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr8, i32 0, i32 0
  %23 = load i64, ptr %name, align 4
  %24 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %24, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 %23, ptr %heap_to_ptr12, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %27, align 4
  call void @set_storage(ptr %heap_to_ptr6, ptr %heap_to_ptr12)
  %28 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  %slot_value = load i64, ptr %28, align 4
  %slot_offset = add i64 %slot_value, 1
  %voteCount = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr8, i32 0, i32 1
  %29 = load i64, ptr %voteCount, align 4
  %30 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %30, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 %slot_offset, ptr %heap_to_ptr14, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %33, align 4
  %34 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %34, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  store i64 %29, ptr %heap_to_ptr16, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr16, i64 1
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr16, i64 2
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  store i64 0, ptr %37, align 4
  call void @set_storage(ptr %heap_to_ptr14, ptr %heap_to_ptr16)
  %new_length = add i64 %storage_value, 1
  %38 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %38, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  store i64 1, ptr %heap_to_ptr18, align 4
  %39 = getelementptr i64, ptr %heap_to_ptr18, i64 1
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr18, i64 2
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %heap_to_ptr18, i64 3
  store i64 0, ptr %41, align 4
  %42 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %42, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 %new_length, ptr %heap_to_ptr20, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %45, align 4
  call void @set_storage(ptr %heap_to_ptr18, ptr %heap_to_ptr20)
  br label %next

next:                                             ; preds = %body
  %46 = load i64, ptr %i, align 4
  %47 = add i64 %46, 1
  store i64 %47, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %48 = call i64 @vector_new(i64 4)
  %heap_start21 = sub i64 %48, 4
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  %49 = call i64 @vector_new(i64 4)
  %heap_start23 = sub i64 %49, 4
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  store i64 1, ptr %heap_to_ptr24, align 4
  %50 = getelementptr i64, ptr %heap_to_ptr24, i64 1
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %heap_to_ptr24, i64 2
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %heap_to_ptr24, i64 3
  store i64 0, ptr %52, align 4
  call void @get_storage(ptr %heap_to_ptr24, ptr %heap_to_ptr22)
  %storage_value25 = load i64, ptr %heap_to_ptr22, align 4
  %53 = sub i64 %storage_value25, 1
  %54 = sub i64 %53, 0
  call void @builtin_range_check(i64 %54)
  %55 = call i64 @vector_new(i64 4)
  %heap_start26 = sub i64 %55, 4
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  store i64 1, ptr %heap_to_ptr27, align 4
  %56 = getelementptr i64, ptr %heap_to_ptr27, i64 1
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %heap_to_ptr27, i64 2
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %heap_to_ptr27, i64 3
  store i64 0, ptr %58, align 4
  %59 = call i64 @vector_new(i64 4)
  %heap_start28 = sub i64 %59, 4
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr27, ptr %heap_to_ptr29, i64 4)
  %60 = getelementptr i64, ptr %heap_to_ptr29, i64 3
  %hash_value_low30 = load i64, ptr %60, align 4
  %storage_array_offset31 = add i64 %hash_value_low30, 0
  store i64 %storage_array_offset31, ptr %60, align 4
  %61 = getelementptr i64, ptr %heap_to_ptr29, i64 3
  %slot_value32 = load i64, ptr %61, align 4
  %slot_offset33 = add i64 %slot_value32, 0
  %62 = call i64 @vector_new(i64 4)
  %heap_start34 = sub i64 %62, 4
  %heap_to_ptr35 = inttoptr i64 %heap_start34 to ptr
  %63 = call i64 @vector_new(i64 4)
  %heap_start36 = sub i64 %63, 4
  %heap_to_ptr37 = inttoptr i64 %heap_start36 to ptr
  store i64 %slot_offset33, ptr %heap_to_ptr37, align 4
  %64 = getelementptr i64, ptr %heap_to_ptr37, i64 1
  store i64 0, ptr %64, align 4
  %65 = getelementptr i64, ptr %heap_to_ptr37, i64 2
  store i64 0, ptr %65, align 4
  %66 = getelementptr i64, ptr %heap_to_ptr37, i64 3
  store i64 0, ptr %66, align 4
  call void @get_storage(ptr %heap_to_ptr37, ptr %heap_to_ptr35)
  %storage_value38 = load i64, ptr %heap_to_ptr35, align 4
  %slot_offset39 = add i64 %slot_offset33, 1
  %67 = icmp eq i64 %storage_value38, 64
  %68 = zext i1 %67 to i64
  call void @builtin_assert(i64 %68)
  %69 = call i64 @vector_new(i64 4)
  %heap_start40 = sub i64 %69, 4
  %heap_to_ptr41 = inttoptr i64 %heap_start40 to ptr
  %70 = call i64 @vector_new(i64 4)
  %heap_start42 = sub i64 %70, 4
  %heap_to_ptr43 = inttoptr i64 %heap_start42 to ptr
  store i64 1, ptr %heap_to_ptr43, align 4
  %71 = getelementptr i64, ptr %heap_to_ptr43, i64 1
  store i64 0, ptr %71, align 4
  %72 = getelementptr i64, ptr %heap_to_ptr43, i64 2
  store i64 0, ptr %72, align 4
  %73 = getelementptr i64, ptr %heap_to_ptr43, i64 3
  store i64 0, ptr %73, align 4
  call void @get_storage(ptr %heap_to_ptr43, ptr %heap_to_ptr41)
  %storage_value44 = load i64, ptr %heap_to_ptr41, align 4
  %74 = sub i64 %storage_value44, 1
  %75 = sub i64 %74, 1
  call void @builtin_range_check(i64 %75)
  %76 = call i64 @vector_new(i64 4)
  %heap_start45 = sub i64 %76, 4
  %heap_to_ptr46 = inttoptr i64 %heap_start45 to ptr
  store i64 1, ptr %heap_to_ptr46, align 4
  %77 = getelementptr i64, ptr %heap_to_ptr46, i64 1
  store i64 0, ptr %77, align 4
  %78 = getelementptr i64, ptr %heap_to_ptr46, i64 2
  store i64 0, ptr %78, align 4
  %79 = getelementptr i64, ptr %heap_to_ptr46, i64 3
  store i64 0, ptr %79, align 4
  %80 = call i64 @vector_new(i64 4)
  %heap_start47 = sub i64 %80, 4
  %heap_to_ptr48 = inttoptr i64 %heap_start47 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr46, ptr %heap_to_ptr48, i64 4)
  %81 = getelementptr i64, ptr %heap_to_ptr48, i64 3
  %hash_value_low49 = load i64, ptr %81, align 4
  %storage_array_offset50 = add i64 %hash_value_low49, 2
  store i64 %storage_array_offset50, ptr %81, align 4
  %82 = getelementptr i64, ptr %heap_to_ptr48, i64 3
  %slot_value51 = load i64, ptr %82, align 4
  %slot_offset52 = add i64 %slot_value51, 0
  %83 = call i64 @vector_new(i64 4)
  %heap_start53 = sub i64 %83, 4
  %heap_to_ptr54 = inttoptr i64 %heap_start53 to ptr
  %84 = call i64 @vector_new(i64 4)
  %heap_start55 = sub i64 %84, 4
  %heap_to_ptr56 = inttoptr i64 %heap_start55 to ptr
  store i64 %slot_offset52, ptr %heap_to_ptr56, align 4
  %85 = getelementptr i64, ptr %heap_to_ptr56, i64 1
  store i64 0, ptr %85, align 4
  %86 = getelementptr i64, ptr %heap_to_ptr56, i64 2
  store i64 0, ptr %86, align 4
  %87 = getelementptr i64, ptr %heap_to_ptr56, i64 3
  store i64 0, ptr %87, align 4
  call void @get_storage(ptr %heap_to_ptr56, ptr %heap_to_ptr54)
  %storage_value57 = load i64, ptr %heap_to_ptr54, align 4
  %slot_offset58 = add i64 %slot_offset52, 1
  %88 = icmp eq i64 %storage_value57, 65
  %89 = zext i1 %88 to i64
  call void @builtin_assert(i64 %89)
  %90 = call i64 @vector_new(i64 4)
  %heap_start59 = sub i64 %90, 4
  %heap_to_ptr60 = inttoptr i64 %heap_start59 to ptr
  %91 = call i64 @vector_new(i64 4)
  %heap_start61 = sub i64 %91, 4
  %heap_to_ptr62 = inttoptr i64 %heap_start61 to ptr
  store i64 1, ptr %heap_to_ptr62, align 4
  %92 = getelementptr i64, ptr %heap_to_ptr62, i64 1
  store i64 0, ptr %92, align 4
  %93 = getelementptr i64, ptr %heap_to_ptr62, i64 2
  store i64 0, ptr %93, align 4
  %94 = getelementptr i64, ptr %heap_to_ptr62, i64 3
  store i64 0, ptr %94, align 4
  call void @get_storage(ptr %heap_to_ptr62, ptr %heap_to_ptr60)
  %storage_value63 = load i64, ptr %heap_to_ptr60, align 4
  %95 = sub i64 %storage_value63, 1
  %96 = sub i64 %95, 2
  call void @builtin_range_check(i64 %96)
  %97 = call i64 @vector_new(i64 4)
  %heap_start64 = sub i64 %97, 4
  %heap_to_ptr65 = inttoptr i64 %heap_start64 to ptr
  store i64 1, ptr %heap_to_ptr65, align 4
  %98 = getelementptr i64, ptr %heap_to_ptr65, i64 1
  store i64 0, ptr %98, align 4
  %99 = getelementptr i64, ptr %heap_to_ptr65, i64 2
  store i64 0, ptr %99, align 4
  %100 = getelementptr i64, ptr %heap_to_ptr65, i64 3
  store i64 0, ptr %100, align 4
  %101 = call i64 @vector_new(i64 4)
  %heap_start66 = sub i64 %101, 4
  %heap_to_ptr67 = inttoptr i64 %heap_start66 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr65, ptr %heap_to_ptr67, i64 4)
  %102 = getelementptr i64, ptr %heap_to_ptr67, i64 3
  %hash_value_low68 = load i64, ptr %102, align 4
  %storage_array_offset69 = add i64 %hash_value_low68, 4
  store i64 %storage_array_offset69, ptr %102, align 4
  %103 = getelementptr i64, ptr %heap_to_ptr67, i64 3
  %slot_value70 = load i64, ptr %103, align 4
  %slot_offset71 = add i64 %slot_value70, 0
  %104 = call i64 @vector_new(i64 4)
  %heap_start72 = sub i64 %104, 4
  %heap_to_ptr73 = inttoptr i64 %heap_start72 to ptr
  %105 = call i64 @vector_new(i64 4)
  %heap_start74 = sub i64 %105, 4
  %heap_to_ptr75 = inttoptr i64 %heap_start74 to ptr
  store i64 %slot_offset71, ptr %heap_to_ptr75, align 4
  %106 = getelementptr i64, ptr %heap_to_ptr75, i64 1
  store i64 0, ptr %106, align 4
  %107 = getelementptr i64, ptr %heap_to_ptr75, i64 2
  store i64 0, ptr %107, align 4
  %108 = getelementptr i64, ptr %heap_to_ptr75, i64 3
  store i64 0, ptr %108, align 4
  call void @get_storage(ptr %heap_to_ptr75, ptr %heap_to_ptr73)
  %storage_value76 = load i64, ptr %heap_to_ptr73, align 4
  %slot_offset77 = add i64 %slot_offset71, 1
  %109 = icmp eq i64 %storage_value76, 66
  %110 = zext i1 %109 to i64
  call void @builtin_assert(i64 %110)
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
  call void @memcpy(ptr %heap_to_ptr2, ptr %8, i64 4)
  %next_dest_offset = add i64 %heap_start3, 4
  %9 = inttoptr i64 %next_dest_offset to ptr
  call void @memcpy(ptr %2, ptr %9, i64 4)
  %10 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %10, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr4, ptr %heap_to_ptr6, i64 8)
  store ptr %heap_to_ptr6, ptr %sender, align 8
  %11 = load i64, ptr %sender, align 4
  %slot_offset = add i64 %11, 0
  %12 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %12, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  %13 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %13, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 %slot_offset, ptr %heap_to_ptr10, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %16, align 4
  call void @get_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr8)
  %storage_value = load i64, ptr %heap_to_ptr8, align 4
  %slot_offset11 = add i64 %slot_offset, 1
  %17 = icmp eq i64 %storage_value, 0
  %18 = zext i1 %17 to i64
  call void @builtin_assert(i64 %18)
  %19 = load i64, ptr %sender, align 4
  %slot_offset12 = add i64 %19, 0
  %20 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %20, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 %slot_offset12, ptr %heap_to_ptr14, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %23, align 4
  %24 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %24, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  store i64 1, ptr %heap_to_ptr16, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr16, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr16, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  store i64 0, ptr %27, align 4
  call void @set_storage(ptr %heap_to_ptr14, ptr %heap_to_ptr16)
  %28 = load i64, ptr %sender, align 4
  %slot_offset17 = add i64 %28, 1
  %29 = load i64, ptr %proposal_, align 4
  %30 = call i64 @vector_new(i64 4)
  %heap_start18 = sub i64 %30, 4
  %heap_to_ptr19 = inttoptr i64 %heap_start18 to ptr
  store i64 %slot_offset17, ptr %heap_to_ptr19, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr19, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr19, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr19, i64 3
  store i64 0, ptr %33, align 4
  %34 = call i64 @vector_new(i64 4)
  %heap_start20 = sub i64 %34, 4
  %heap_to_ptr21 = inttoptr i64 %heap_start20 to ptr
  store i64 %29, ptr %heap_to_ptr21, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr21, i64 1
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr21, i64 2
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr21, i64 3
  store i64 0, ptr %37, align 4
  call void @set_storage(ptr %heap_to_ptr19, ptr %heap_to_ptr21)
  %38 = load i64, ptr %proposal_, align 4
  %39 = call i64 @vector_new(i64 4)
  %heap_start22 = sub i64 %39, 4
  %heap_to_ptr23 = inttoptr i64 %heap_start22 to ptr
  %40 = call i64 @vector_new(i64 4)
  %heap_start24 = sub i64 %40, 4
  %heap_to_ptr25 = inttoptr i64 %heap_start24 to ptr
  store i64 1, ptr %heap_to_ptr25, align 4
  %41 = getelementptr i64, ptr %heap_to_ptr25, i64 1
  store i64 0, ptr %41, align 4
  %42 = getelementptr i64, ptr %heap_to_ptr25, i64 2
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr25, i64 3
  store i64 0, ptr %43, align 4
  call void @get_storage(ptr %heap_to_ptr25, ptr %heap_to_ptr23)
  %storage_value26 = load i64, ptr %heap_to_ptr23, align 4
  %44 = sub i64 %storage_value26, 1
  %45 = sub i64 %44, %38
  call void @builtin_range_check(i64 %45)
  %46 = call i64 @vector_new(i64 4)
  %heap_start27 = sub i64 %46, 4
  %heap_to_ptr28 = inttoptr i64 %heap_start27 to ptr
  store i64 1, ptr %heap_to_ptr28, align 4
  %47 = getelementptr i64, ptr %heap_to_ptr28, i64 1
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %heap_to_ptr28, i64 2
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %heap_to_ptr28, i64 3
  store i64 0, ptr %49, align 4
  %50 = call i64 @vector_new(i64 4)
  %heap_start29 = sub i64 %50, 4
  %heap_to_ptr30 = inttoptr i64 %heap_start29 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr28, ptr %heap_to_ptr30, i64 4)
  %51 = getelementptr i64, ptr %heap_to_ptr30, i64 3
  %hash_value_low = load i64, ptr %51, align 4
  %52 = mul i64 %38, 2
  %storage_array_offset = add i64 %hash_value_low, %52
  store i64 %storage_array_offset, ptr %51, align 4
  %53 = getelementptr i64, ptr %heap_to_ptr30, i64 3
  %slot_value = load i64, ptr %53, align 4
  %slot_offset31 = add i64 %slot_value, 0
  %54 = call i64 @vector_new(i64 4)
  %heap_start32 = sub i64 %54, 4
  %heap_to_ptr33 = inttoptr i64 %heap_start32 to ptr
  %55 = call i64 @vector_new(i64 4)
  %heap_start34 = sub i64 %55, 4
  %heap_to_ptr35 = inttoptr i64 %heap_start34 to ptr
  store i64 %slot_offset31, ptr %heap_to_ptr35, align 4
  %56 = getelementptr i64, ptr %heap_to_ptr35, i64 1
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %heap_to_ptr35, i64 2
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %heap_to_ptr35, i64 3
  store i64 0, ptr %58, align 4
  call void @get_storage(ptr %heap_to_ptr35, ptr %heap_to_ptr33)
  %storage_value36 = load i64, ptr %heap_to_ptr33, align 4
  %slot_offset37 = add i64 %slot_offset31, 1
  call void @prophet_printf(i64 %storage_value36, i64 3)
  %59 = load i64, ptr %proposal_, align 4
  %60 = call i64 @vector_new(i64 4)
  %heap_start38 = sub i64 %60, 4
  %heap_to_ptr39 = inttoptr i64 %heap_start38 to ptr
  %61 = call i64 @vector_new(i64 4)
  %heap_start40 = sub i64 %61, 4
  %heap_to_ptr41 = inttoptr i64 %heap_start40 to ptr
  store i64 1, ptr %heap_to_ptr41, align 4
  %62 = getelementptr i64, ptr %heap_to_ptr41, i64 1
  store i64 0, ptr %62, align 4
  %63 = getelementptr i64, ptr %heap_to_ptr41, i64 2
  store i64 0, ptr %63, align 4
  %64 = getelementptr i64, ptr %heap_to_ptr41, i64 3
  store i64 0, ptr %64, align 4
  call void @get_storage(ptr %heap_to_ptr41, ptr %heap_to_ptr39)
  %storage_value42 = load i64, ptr %heap_to_ptr39, align 4
  %65 = sub i64 %storage_value42, 1
  %66 = sub i64 %65, %59
  call void @builtin_range_check(i64 %66)
  %67 = call i64 @vector_new(i64 4)
  %heap_start43 = sub i64 %67, 4
  %heap_to_ptr44 = inttoptr i64 %heap_start43 to ptr
  store i64 1, ptr %heap_to_ptr44, align 4
  %68 = getelementptr i64, ptr %heap_to_ptr44, i64 1
  store i64 0, ptr %68, align 4
  %69 = getelementptr i64, ptr %heap_to_ptr44, i64 2
  store i64 0, ptr %69, align 4
  %70 = getelementptr i64, ptr %heap_to_ptr44, i64 3
  store i64 0, ptr %70, align 4
  %71 = call i64 @vector_new(i64 4)
  %heap_start45 = sub i64 %71, 4
  %heap_to_ptr46 = inttoptr i64 %heap_start45 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr44, ptr %heap_to_ptr46, i64 4)
  %72 = getelementptr i64, ptr %heap_to_ptr46, i64 3
  %hash_value_low47 = load i64, ptr %72, align 4
  %73 = mul i64 %59, 2
  %storage_array_offset48 = add i64 %hash_value_low47, %73
  store i64 %storage_array_offset48, ptr %72, align 4
  %74 = getelementptr i64, ptr %heap_to_ptr46, i64 3
  %slot_value49 = load i64, ptr %74, align 4
  %slot_offset50 = add i64 %slot_value49, 0
  %75 = call i64 @vector_new(i64 4)
  %heap_start51 = sub i64 %75, 4
  %heap_to_ptr52 = inttoptr i64 %heap_start51 to ptr
  %76 = call i64 @vector_new(i64 4)
  %heap_start53 = sub i64 %76, 4
  %heap_to_ptr54 = inttoptr i64 %heap_start53 to ptr
  store i64 %slot_offset50, ptr %heap_to_ptr54, align 4
  %77 = getelementptr i64, ptr %heap_to_ptr54, i64 1
  store i64 0, ptr %77, align 4
  %78 = getelementptr i64, ptr %heap_to_ptr54, i64 2
  store i64 0, ptr %78, align 4
  %79 = getelementptr i64, ptr %heap_to_ptr54, i64 3
  store i64 0, ptr %79, align 4
  call void @get_storage(ptr %heap_to_ptr54, ptr %heap_to_ptr52)
  %storage_value55 = load i64, ptr %heap_to_ptr52, align 4
  %slot_offset56 = add i64 %slot_offset50, 1
  %80 = icmp ne i64 %storage_value55, 0
  %81 = zext i1 %80 to i64
  call void @builtin_assert(i64 %81)
  %82 = load i64, ptr %proposal_, align 4
  %83 = call i64 @vector_new(i64 4)
  %heap_start57 = sub i64 %83, 4
  %heap_to_ptr58 = inttoptr i64 %heap_start57 to ptr
  %84 = call i64 @vector_new(i64 4)
  %heap_start59 = sub i64 %84, 4
  %heap_to_ptr60 = inttoptr i64 %heap_start59 to ptr
  store i64 1, ptr %heap_to_ptr60, align 4
  %85 = getelementptr i64, ptr %heap_to_ptr60, i64 1
  store i64 0, ptr %85, align 4
  %86 = getelementptr i64, ptr %heap_to_ptr60, i64 2
  store i64 0, ptr %86, align 4
  %87 = getelementptr i64, ptr %heap_to_ptr60, i64 3
  store i64 0, ptr %87, align 4
  call void @get_storage(ptr %heap_to_ptr60, ptr %heap_to_ptr58)
  %storage_value61 = load i64, ptr %heap_to_ptr58, align 4
  %88 = sub i64 %storage_value61, 1
  %89 = sub i64 %88, %82
  call void @builtin_range_check(i64 %89)
  %90 = call i64 @vector_new(i64 4)
  %heap_start62 = sub i64 %90, 4
  %heap_to_ptr63 = inttoptr i64 %heap_start62 to ptr
  store i64 1, ptr %heap_to_ptr63, align 4
  %91 = getelementptr i64, ptr %heap_to_ptr63, i64 1
  store i64 0, ptr %91, align 4
  %92 = getelementptr i64, ptr %heap_to_ptr63, i64 2
  store i64 0, ptr %92, align 4
  %93 = getelementptr i64, ptr %heap_to_ptr63, i64 3
  store i64 0, ptr %93, align 4
  %94 = call i64 @vector_new(i64 4)
  %heap_start64 = sub i64 %94, 4
  %heap_to_ptr65 = inttoptr i64 %heap_start64 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr63, ptr %heap_to_ptr65, i64 4)
  %95 = getelementptr i64, ptr %heap_to_ptr65, i64 3
  %hash_value_low66 = load i64, ptr %95, align 4
  %96 = mul i64 %82, 2
  %storage_array_offset67 = add i64 %hash_value_low66, %96
  store i64 %storage_array_offset67, ptr %95, align 4
  %97 = getelementptr i64, ptr %heap_to_ptr65, i64 3
  %slot_value68 = load i64, ptr %97, align 4
  %slot_offset69 = add i64 %slot_value68, 1
  %98 = load i64, ptr %proposal_, align 4
  %99 = call i64 @vector_new(i64 4)
  %heap_start70 = sub i64 %99, 4
  %heap_to_ptr71 = inttoptr i64 %heap_start70 to ptr
  %100 = call i64 @vector_new(i64 4)
  %heap_start72 = sub i64 %100, 4
  %heap_to_ptr73 = inttoptr i64 %heap_start72 to ptr
  store i64 1, ptr %heap_to_ptr73, align 4
  %101 = getelementptr i64, ptr %heap_to_ptr73, i64 1
  store i64 0, ptr %101, align 4
  %102 = getelementptr i64, ptr %heap_to_ptr73, i64 2
  store i64 0, ptr %102, align 4
  %103 = getelementptr i64, ptr %heap_to_ptr73, i64 3
  store i64 0, ptr %103, align 4
  call void @get_storage(ptr %heap_to_ptr73, ptr %heap_to_ptr71)
  %storage_value74 = load i64, ptr %heap_to_ptr71, align 4
  %104 = sub i64 %storage_value74, 1
  %105 = sub i64 %104, %98
  call void @builtin_range_check(i64 %105)
  %106 = call i64 @vector_new(i64 4)
  %heap_start75 = sub i64 %106, 4
  %heap_to_ptr76 = inttoptr i64 %heap_start75 to ptr
  store i64 1, ptr %heap_to_ptr76, align 4
  %107 = getelementptr i64, ptr %heap_to_ptr76, i64 1
  store i64 0, ptr %107, align 4
  %108 = getelementptr i64, ptr %heap_to_ptr76, i64 2
  store i64 0, ptr %108, align 4
  %109 = getelementptr i64, ptr %heap_to_ptr76, i64 3
  store i64 0, ptr %109, align 4
  %110 = call i64 @vector_new(i64 4)
  %heap_start77 = sub i64 %110, 4
  %heap_to_ptr78 = inttoptr i64 %heap_start77 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr76, ptr %heap_to_ptr78, i64 4)
  %111 = getelementptr i64, ptr %heap_to_ptr78, i64 3
  %hash_value_low79 = load i64, ptr %111, align 4
  %112 = mul i64 %98, 2
  %storage_array_offset80 = add i64 %hash_value_low79, %112
  store i64 %storage_array_offset80, ptr %111, align 4
  %113 = getelementptr i64, ptr %heap_to_ptr78, i64 3
  %slot_value81 = load i64, ptr %113, align 4
  %slot_offset82 = add i64 %slot_value81, 1
  %114 = call i64 @vector_new(i64 4)
  %heap_start83 = sub i64 %114, 4
  %heap_to_ptr84 = inttoptr i64 %heap_start83 to ptr
  %115 = call i64 @vector_new(i64 4)
  %heap_start85 = sub i64 %115, 4
  %heap_to_ptr86 = inttoptr i64 %heap_start85 to ptr
  store i64 %slot_offset82, ptr %heap_to_ptr86, align 4
  %116 = getelementptr i64, ptr %heap_to_ptr86, i64 1
  store i64 0, ptr %116, align 4
  %117 = getelementptr i64, ptr %heap_to_ptr86, i64 2
  store i64 0, ptr %117, align 4
  %118 = getelementptr i64, ptr %heap_to_ptr86, i64 3
  store i64 0, ptr %118, align 4
  call void @get_storage(ptr %heap_to_ptr86, ptr %heap_to_ptr84)
  %storage_value87 = load i64, ptr %heap_to_ptr84, align 4
  %slot_offset88 = add i64 %slot_offset82, 1
  %119 = add i64 %storage_value87, 1
  call void @builtin_range_check(i64 %119)
  %120 = call i64 @vector_new(i64 4)
  %heap_start89 = sub i64 %120, 4
  %heap_to_ptr90 = inttoptr i64 %heap_start89 to ptr
  store i64 %slot_offset69, ptr %heap_to_ptr90, align 4
  %121 = getelementptr i64, ptr %heap_to_ptr90, i64 1
  store i64 0, ptr %121, align 4
  %122 = getelementptr i64, ptr %heap_to_ptr90, i64 2
  store i64 0, ptr %122, align 4
  %123 = getelementptr i64, ptr %heap_to_ptr90, i64 3
  store i64 0, ptr %123, align 4
  %124 = call i64 @vector_new(i64 4)
  %heap_start91 = sub i64 %124, 4
  %heap_to_ptr92 = inttoptr i64 %heap_start91 to ptr
  store i64 %119, ptr %heap_to_ptr92, align 4
  %125 = getelementptr i64, ptr %heap_to_ptr92, i64 1
  store i64 0, ptr %125, align 4
  %126 = getelementptr i64, ptr %heap_to_ptr92, i64 2
  store i64 0, ptr %126, align 4
  %127 = getelementptr i64, ptr %heap_to_ptr92, i64 3
  store i64 0, ptr %127, align 4
  call void @set_storage(ptr %heap_to_ptr90, ptr %heap_to_ptr92)
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
  %hash_value_low = load i64, ptr %20, align 4
  %21 = mul i64 %7, 2
  %storage_array_offset = add i64 %hash_value_low, %21
  store i64 %storage_array_offset, ptr %20, align 4
  %22 = getelementptr i64, ptr %heap_to_ptr11, i64 3
  %slot_value = load i64, ptr %22, align 4
  %slot_offset = add i64 %slot_value, 1
  %23 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %23, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  %24 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %24, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 %slot_offset, ptr %heap_to_ptr15, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr15, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr15, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr15, i64 3
  store i64 0, ptr %27, align 4
  call void @get_storage(ptr %heap_to_ptr15, ptr %heap_to_ptr13)
  %storage_value16 = load i64, ptr %heap_to_ptr13, align 4
  %slot_offset17 = add i64 %slot_offset, 1
  %28 = load i64, ptr %winningVoteCount, align 4
  %29 = icmp ugt i64 %storage_value16, %28
  br i1 %29, label %then, label %enif

next:                                             ; preds = %enif
  %30 = load i64, ptr %p, align 4
  %31 = add i64 %30, 1
  store i64 %31, ptr %p, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %32 = load i64, ptr %winningProposal_, align 4
  ret i64 %32

then:                                             ; preds = %body
  %33 = load i64, ptr %p, align 4
  %34 = call i64 @vector_new(i64 4)
  %heap_start18 = sub i64 %34, 4
  %heap_to_ptr19 = inttoptr i64 %heap_start18 to ptr
  %35 = call i64 @vector_new(i64 4)
  %heap_start20 = sub i64 %35, 4
  %heap_to_ptr21 = inttoptr i64 %heap_start20 to ptr
  store i64 1, ptr %heap_to_ptr21, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr21, i64 1
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr21, i64 2
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %heap_to_ptr21, i64 3
  store i64 0, ptr %38, align 4
  call void @get_storage(ptr %heap_to_ptr21, ptr %heap_to_ptr19)
  %storage_value22 = load i64, ptr %heap_to_ptr19, align 4
  %39 = sub i64 %storage_value22, 1
  %40 = sub i64 %39, %33
  call void @builtin_range_check(i64 %40)
  %41 = call i64 @vector_new(i64 4)
  %heap_start23 = sub i64 %41, 4
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  store i64 1, ptr %heap_to_ptr24, align 4
  %42 = getelementptr i64, ptr %heap_to_ptr24, i64 1
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr24, i64 2
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr24, i64 3
  store i64 0, ptr %44, align 4
  %45 = call i64 @vector_new(i64 4)
  %heap_start25 = sub i64 %45, 4
  %heap_to_ptr26 = inttoptr i64 %heap_start25 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr24, ptr %heap_to_ptr26, i64 4)
  %46 = getelementptr i64, ptr %heap_to_ptr26, i64 3
  %hash_value_low27 = load i64, ptr %46, align 4
  %47 = mul i64 %33, 2
  %storage_array_offset28 = add i64 %hash_value_low27, %47
  store i64 %storage_array_offset28, ptr %46, align 4
  %48 = getelementptr i64, ptr %heap_to_ptr26, i64 3
  %slot_value29 = load i64, ptr %48, align 4
  %slot_offset30 = add i64 %slot_value29, 1
  %49 = call i64 @vector_new(i64 4)
  %heap_start31 = sub i64 %49, 4
  %heap_to_ptr32 = inttoptr i64 %heap_start31 to ptr
  %50 = call i64 @vector_new(i64 4)
  %heap_start33 = sub i64 %50, 4
  %heap_to_ptr34 = inttoptr i64 %heap_start33 to ptr
  store i64 %slot_offset30, ptr %heap_to_ptr34, align 4
  %51 = getelementptr i64, ptr %heap_to_ptr34, i64 1
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %heap_to_ptr34, i64 2
  store i64 0, ptr %52, align 4
  %53 = getelementptr i64, ptr %heap_to_ptr34, i64 3
  store i64 0, ptr %53, align 4
  call void @get_storage(ptr %heap_to_ptr34, ptr %heap_to_ptr32)
  %storage_value35 = load i64, ptr %heap_to_ptr32, align 4
  %slot_offset36 = add i64 %slot_offset30, 1
  %54 = load i64, ptr %p, align 4
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
  %hash_value_low = load i64, ptr %17, align 4
  %18 = mul i64 %4, 2
  %storage_array_offset = add i64 %hash_value_low, %18
  store i64 %storage_array_offset, ptr %17, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  %slot_value = load i64, ptr %19, align 4
  %slot_offset = add i64 %slot_value, 0
  %20 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %20, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  %21 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %21, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 %slot_offset, ptr %heap_to_ptr10, align 4
  %22 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %24, align 4
  call void @get_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr8)
  %storage_value11 = load i64, ptr %heap_to_ptr8, align 4
  %slot_offset12 = add i64 %slot_offset, 1
  store i64 %storage_value11, ptr %winnerName, align 4
  %25 = load i64, ptr %winnerName, align 4
  %26 = icmp eq i64 %25, 66
  %27 = zext i1 %26 to i64
  call void @builtin_assert(i64 %27)
  %28 = load i64, ptr %winnerName, align 4
  ret i64 %28
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
