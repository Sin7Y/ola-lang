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

define void @vote_proposal(i64 %0) {
entry:
  %sender = alloca i64, align 8
  %index_alloca35 = alloca i64, align 8
  %index_alloca26 = alloca i64, align 8
  %index_alloca7 = alloca i64, align 8
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
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 %index_value
  %8 = load i64, ptr %index_access, align 4
  %9 = add i64 0, %index_value
  %index_access3 = getelementptr i64, ptr %heap_to_ptr2, i64 %9
  store i64 %8, ptr %index_access3, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %index_alloca7, align 4
  br label %cond4

cond4:                                            ; preds = %body5, %done
  %index_value8 = load i64, ptr %index_alloca7, align 4
  %loop_cond9 = icmp ult i64 %index_value8, 4
  br i1 %loop_cond9, label %body5, label %done6

body5:                                            ; preds = %cond4
  %index_access10 = getelementptr i64, ptr %2, i64 %index_value8
  %10 = load i64, ptr %index_access10, align 4
  %11 = add i64 4, %index_value8
  %index_access11 = getelementptr i64, ptr %heap_to_ptr2, i64 %11
  store i64 %10, ptr %index_access11, align 4
  %next_index12 = add i64 %index_value8, 1
  store i64 %next_index12, ptr %index_alloca7, align 4
  br label %cond4

done6:                                            ; preds = %cond4
  %12 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %12, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr14, i64 8)
  %13 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  %slot_value = load i64, ptr %13, align 4
  %14 = add i64 %slot_value, 0
  %15 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %15, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  %16 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %16, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  store i64 %14, ptr %heap_to_ptr18, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr18, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr18, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr18, i64 3
  store i64 0, ptr %19, align 4
  call void @get_storage(ptr %heap_to_ptr18, ptr %heap_to_ptr16)
  %storage_value = load i64, ptr %heap_to_ptr16, align 4
  %20 = icmp eq i64 %storage_value, 0
  %21 = zext i1 %20 to i64
  call void @builtin_assert(i64 %21)
  %22 = load ptr, ptr %msgSender, align 8
  %23 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %23, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 0, ptr %heap_to_ptr20, align 4
  %24 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %26, align 4
  %27 = call i64 @vector_new(i64 8)
  %heap_start21 = sub i64 %27, 8
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  store i64 0, ptr %index_alloca26, align 4
  br label %cond23

cond23:                                           ; preds = %body24, %done6
  %index_value27 = load i64, ptr %index_alloca26, align 4
  %loop_cond28 = icmp ult i64 %index_value27, 4
  br i1 %loop_cond28, label %body24, label %done25

body24:                                           ; preds = %cond23
  %index_access29 = getelementptr i64, ptr %heap_to_ptr20, i64 %index_value27
  %28 = load i64, ptr %index_access29, align 4
  %29 = add i64 0, %index_value27
  %index_access30 = getelementptr i64, ptr %heap_to_ptr22, i64 %29
  store i64 %28, ptr %index_access30, align 4
  %next_index31 = add i64 %index_value27, 1
  store i64 %next_index31, ptr %index_alloca26, align 4
  br label %cond23

done25:                                           ; preds = %cond23
  store i64 0, ptr %index_alloca35, align 4
  br label %cond32

cond32:                                           ; preds = %body33, %done25
  %index_value36 = load i64, ptr %index_alloca35, align 4
  %loop_cond37 = icmp ult i64 %index_value36, 4
  br i1 %loop_cond37, label %body33, label %done34

body33:                                           ; preds = %cond32
  %index_access38 = getelementptr i64, ptr %22, i64 %index_value36
  %30 = load i64, ptr %index_access38, align 4
  %31 = add i64 4, %index_value36
  %index_access39 = getelementptr i64, ptr %heap_to_ptr22, i64 %31
  store i64 %30, ptr %index_access39, align 4
  %next_index40 = add i64 %index_value36, 1
  store i64 %next_index40, ptr %index_alloca35, align 4
  br label %cond32

done34:                                           ; preds = %cond32
  %32 = call i64 @vector_new(i64 4)
  %heap_start41 = sub i64 %32, 4
  %heap_to_ptr42 = inttoptr i64 %heap_start41 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr22, ptr %heap_to_ptr42, i64 8)
  store ptr %heap_to_ptr42, ptr %sender, align 8
  %33 = load i64, ptr %sender, align 4
  %34 = add i64 %33, 0
  %35 = call i64 @vector_new(i64 4)
  %heap_start43 = sub i64 %35, 4
  %heap_to_ptr44 = inttoptr i64 %heap_start43 to ptr
  store i64 %34, ptr %heap_to_ptr44, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr44, i64 1
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr44, i64 2
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %heap_to_ptr44, i64 3
  store i64 0, ptr %38, align 4
  %39 = call i64 @vector_new(i64 4)
  %heap_start45 = sub i64 %39, 4
  %heap_to_ptr46 = inttoptr i64 %heap_start45 to ptr
  store i64 1, ptr %heap_to_ptr46, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr46, i64 1
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %heap_to_ptr46, i64 2
  store i64 0, ptr %41, align 4
  %42 = getelementptr i64, ptr %heap_to_ptr46, i64 3
  store i64 0, ptr %42, align 4
  call void @set_storage(ptr %heap_to_ptr44, ptr %heap_to_ptr46)
  %43 = load i64, ptr %sender, align 4
  %44 = add i64 %43, 1
  %45 = load i64, ptr %proposal_, align 4
  %46 = call i64 @vector_new(i64 4)
  %heap_start47 = sub i64 %46, 4
  %heap_to_ptr48 = inttoptr i64 %heap_start47 to ptr
  store i64 %44, ptr %heap_to_ptr48, align 4
  %47 = getelementptr i64, ptr %heap_to_ptr48, i64 1
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %heap_to_ptr48, i64 2
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %heap_to_ptr48, i64 3
  store i64 0, ptr %49, align 4
  %50 = call i64 @vector_new(i64 4)
  %heap_start49 = sub i64 %50, 4
  %heap_to_ptr50 = inttoptr i64 %heap_start49 to ptr
  store i64 %45, ptr %heap_to_ptr50, align 4
  %51 = getelementptr i64, ptr %heap_to_ptr50, i64 1
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %heap_to_ptr50, i64 2
  store i64 0, ptr %52, align 4
  %53 = getelementptr i64, ptr %heap_to_ptr50, i64 3
  store i64 0, ptr %53, align 4
  call void @set_storage(ptr %heap_to_ptr48, ptr %heap_to_ptr50)
  %54 = load i64, ptr %proposal_, align 4
  %55 = call i64 @vector_new(i64 4)
  %heap_start51 = sub i64 %55, 4
  %heap_to_ptr52 = inttoptr i64 %heap_start51 to ptr
  %56 = call i64 @vector_new(i64 4)
  %heap_start53 = sub i64 %56, 4
  %heap_to_ptr54 = inttoptr i64 %heap_start53 to ptr
  store i64 1, ptr %heap_to_ptr54, align 4
  %57 = getelementptr i64, ptr %heap_to_ptr54, i64 1
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %heap_to_ptr54, i64 2
  store i64 0, ptr %58, align 4
  %59 = getelementptr i64, ptr %heap_to_ptr54, i64 3
  store i64 0, ptr %59, align 4
  call void @get_storage(ptr %heap_to_ptr54, ptr %heap_to_ptr52)
  %storage_value55 = load i64, ptr %heap_to_ptr52, align 4
  %60 = sub i64 %storage_value55, 1
  %61 = sub i64 %60, %54
  call void @builtin_range_check(i64 %61)
  %62 = call i64 @vector_new(i64 4)
  %heap_start56 = sub i64 %62, 4
  %heap_to_ptr57 = inttoptr i64 %heap_start56 to ptr
  store i64 1, ptr %heap_to_ptr57, align 4
  %63 = getelementptr i64, ptr %heap_to_ptr57, i64 1
  store i64 0, ptr %63, align 4
  %64 = getelementptr i64, ptr %heap_to_ptr57, i64 2
  store i64 0, ptr %64, align 4
  %65 = getelementptr i64, ptr %heap_to_ptr57, i64 3
  store i64 0, ptr %65, align 4
  %66 = call i64 @vector_new(i64 4)
  %heap_start58 = sub i64 %66, 4
  %heap_to_ptr59 = inttoptr i64 %heap_start58 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr57, ptr %heap_to_ptr59, i64 4)
  %67 = getelementptr i64, ptr %heap_to_ptr59, i64 3
  %68 = load i64, ptr %67, align 4
  %69 = mul i64 %54, 2
  %70 = add i64 %68, %69
  store i64 %70, ptr %67, align 4
  %71 = getelementptr i64, ptr %heap_to_ptr59, i64 3
  %slot_value60 = load i64, ptr %71, align 4
  %72 = add i64 %slot_value60, 1
  %73 = load i64, ptr %proposal_, align 4
  %74 = call i64 @vector_new(i64 4)
  %heap_start61 = sub i64 %74, 4
  %heap_to_ptr62 = inttoptr i64 %heap_start61 to ptr
  %75 = call i64 @vector_new(i64 4)
  %heap_start63 = sub i64 %75, 4
  %heap_to_ptr64 = inttoptr i64 %heap_start63 to ptr
  store i64 1, ptr %heap_to_ptr64, align 4
  %76 = getelementptr i64, ptr %heap_to_ptr64, i64 1
  store i64 0, ptr %76, align 4
  %77 = getelementptr i64, ptr %heap_to_ptr64, i64 2
  store i64 0, ptr %77, align 4
  %78 = getelementptr i64, ptr %heap_to_ptr64, i64 3
  store i64 0, ptr %78, align 4
  call void @get_storage(ptr %heap_to_ptr64, ptr %heap_to_ptr62)
  %storage_value65 = load i64, ptr %heap_to_ptr62, align 4
  %79 = sub i64 %storage_value65, 1
  %80 = sub i64 %79, %73
  call void @builtin_range_check(i64 %80)
  %81 = call i64 @vector_new(i64 4)
  %heap_start66 = sub i64 %81, 4
  %heap_to_ptr67 = inttoptr i64 %heap_start66 to ptr
  store i64 1, ptr %heap_to_ptr67, align 4
  %82 = getelementptr i64, ptr %heap_to_ptr67, i64 1
  store i64 0, ptr %82, align 4
  %83 = getelementptr i64, ptr %heap_to_ptr67, i64 2
  store i64 0, ptr %83, align 4
  %84 = getelementptr i64, ptr %heap_to_ptr67, i64 3
  store i64 0, ptr %84, align 4
  %85 = call i64 @vector_new(i64 4)
  %heap_start68 = sub i64 %85, 4
  %heap_to_ptr69 = inttoptr i64 %heap_start68 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr67, ptr %heap_to_ptr69, i64 4)
  %86 = getelementptr i64, ptr %heap_to_ptr69, i64 3
  %87 = load i64, ptr %86, align 4
  %88 = mul i64 %73, 2
  %89 = add i64 %87, %88
  store i64 %89, ptr %86, align 4
  %90 = getelementptr i64, ptr %heap_to_ptr69, i64 3
  %slot_value70 = load i64, ptr %90, align 4
  %91 = add i64 %slot_value70, 1
  %92 = call i64 @vector_new(i64 4)
  %heap_start71 = sub i64 %92, 4
  %heap_to_ptr72 = inttoptr i64 %heap_start71 to ptr
  %93 = call i64 @vector_new(i64 4)
  %heap_start73 = sub i64 %93, 4
  %heap_to_ptr74 = inttoptr i64 %heap_start73 to ptr
  store i64 %91, ptr %heap_to_ptr74, align 4
  %94 = getelementptr i64, ptr %heap_to_ptr74, i64 1
  store i64 0, ptr %94, align 4
  %95 = getelementptr i64, ptr %heap_to_ptr74, i64 2
  store i64 0, ptr %95, align 4
  %96 = getelementptr i64, ptr %heap_to_ptr74, i64 3
  store i64 0, ptr %96, align 4
  call void @get_storage(ptr %heap_to_ptr74, ptr %heap_to_ptr72)
  %storage_value75 = load i64, ptr %heap_to_ptr72, align 4
  %97 = add i64 %storage_value75, 1
  call void @builtin_range_check(i64 %97)
  %98 = call i64 @vector_new(i64 4)
  %heap_start76 = sub i64 %98, 4
  %heap_to_ptr77 = inttoptr i64 %heap_start76 to ptr
  store i64 %72, ptr %heap_to_ptr77, align 4
  %99 = getelementptr i64, ptr %heap_to_ptr77, i64 1
  store i64 0, ptr %99, align 4
  %100 = getelementptr i64, ptr %heap_to_ptr77, i64 2
  store i64 0, ptr %100, align 4
  %101 = getelementptr i64, ptr %heap_to_ptr77, i64 3
  store i64 0, ptr %101, align 4
  %102 = call i64 @vector_new(i64 4)
  %heap_start78 = sub i64 %102, 4
  %heap_to_ptr79 = inttoptr i64 %heap_start78 to ptr
  store i64 %97, ptr %heap_to_ptr79, align 4
  %103 = getelementptr i64, ptr %heap_to_ptr79, i64 1
  store i64 0, ptr %103, align 4
  %104 = getelementptr i64, ptr %heap_to_ptr79, i64 2
  store i64 0, ptr %104, align 4
  %105 = getelementptr i64, ptr %heap_to_ptr79, i64 3
  store i64 0, ptr %105, align 4
  call void @set_storage(ptr %heap_to_ptr77, ptr %heap_to_ptr79)
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

define void @main() {
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
    i64 2791810083, label %func_1_dispatch
    i64 2868727644, label %func_2_dispatch
    i64 3501063903, label %func_3_dispatch
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
  %15 = icmp ule i64 1, %1
  br i1 %15, label %inbounds9, label %out_of_bounds10

inbounds9:                                        ; preds = %func_1_dispatch
  %start11 = getelementptr i64, ptr %2, i64 0
  %value12 = load i64, ptr %start11, align 4
  %16 = icmp ult i64 1, %1
  br i1 %16, label %not_all_bytes_read13, label %buffer_read14

out_of_bounds10:                                  ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read13:                             ; preds = %inbounds9
  unreachable

buffer_read14:                                    ; preds = %inbounds9
  call void @vote_proposal(i64 %value12)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %17 = call ptr @get_caller()
  %18 = call i64 @vector_new(i64 5)
  %heap_start15 = sub i64 %18, 5
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  %19 = getelementptr i64, ptr %17, i64 0
  %20 = load i64, ptr %19, align 4
  %start17 = getelementptr i64, ptr %heap_to_ptr16, i64 0
  store i64 %20, ptr %start17, align 4
  %21 = getelementptr i64, ptr %17, i64 1
  %22 = load i64, ptr %21, align 4
  %start18 = getelementptr i64, ptr %heap_to_ptr16, i64 1
  store i64 %22, ptr %start18, align 4
  %23 = getelementptr i64, ptr %17, i64 2
  %24 = load i64, ptr %23, align 4
  %start19 = getelementptr i64, ptr %heap_to_ptr16, i64 2
  store i64 %24, ptr %start19, align 4
  %25 = getelementptr i64, ptr %17, i64 3
  %26 = load i64, ptr %25, align 4
  %start20 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  store i64 %26, ptr %start20, align 4
  %start21 = getelementptr i64, ptr %heap_to_ptr16, i64 4
  store i64 4, ptr %start21, align 4
  call void @set_tape_data(i64 %heap_start15, i64 5)
  ret void

func_3_dispatch:                                  ; preds = %entry
  call void @main()
  ret void
}

define void @call() {
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
