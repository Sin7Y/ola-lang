; ModuleID = 'StructArrayExample'
source_filename = "examples/source/array/dynamic_array_struct.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_call_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define ptr @createBooks() {
entry:
  %array_literal11 = alloca [5 x i64], align 8
  %struct_alloca7 = alloca { i64, i64, [5 x i64] }, align 8
  %array_literal3 = alloca [5 x i64], align 8
  %struct_alloca = alloca { i64, i64, [5 x i64] }, align 8
  %array_literal = alloca [2 x { i64, i64, [5 x i64] }], align 8
  %elemptr0 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %array_literal, i64 0, i64 0
  %"struct member" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca, i32 0, i32 0
  store i64 0, ptr %"struct member", align 4
  %"struct member1" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca, i32 0, i32 1
  store i64 111, ptr %"struct member1", align 4
  %"struct member2" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca, i32 0, i32 2
  %elemptr04 = getelementptr [5 x i64], ptr %array_literal3, i64 0, i64 0
  store i64 1, ptr %elemptr04, align 4
  %elemptr1 = getelementptr [5 x i64], ptr %array_literal3, i64 0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [5 x i64], ptr %array_literal3, i64 0, i64 2
  store i64 3, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [5 x i64], ptr %array_literal3, i64 0, i64 3
  store i64 4, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [5 x i64], ptr %array_literal3, i64 0, i64 4
  store i64 5, ptr %elemptr4, align 4
  %elem = load [5 x i64], ptr %array_literal3, align 4
  store [5 x i64] %elem, ptr %"struct member2", align 4
  %elem5 = load { i64, i64, [5 x i64] }, ptr %struct_alloca, align 4
  store { i64, i64, [5 x i64] } %elem5, ptr %elemptr0, align 4
  %elemptr16 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %array_literal, i64 0, i64 1
  %"struct member8" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca7, i32 0, i32 0
  store i64 0, ptr %"struct member8", align 4
  %"struct member9" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca7, i32 0, i32 1
  store i64 0, ptr %"struct member9", align 4
  %"struct member10" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca7, i32 0, i32 2
  %elemptr012 = getelementptr [5 x i64], ptr %array_literal11, i64 0, i64 0
  store i64 0, ptr %elemptr012, align 4
  %elemptr113 = getelementptr [5 x i64], ptr %array_literal11, i64 0, i64 1
  store i64 0, ptr %elemptr113, align 4
  %elemptr214 = getelementptr [5 x i64], ptr %array_literal11, i64 0, i64 2
  store i64 0, ptr %elemptr214, align 4
  %elemptr315 = getelementptr [5 x i64], ptr %array_literal11, i64 0, i64 3
  store i64 0, ptr %elemptr315, align 4
  %elemptr416 = getelementptr [5 x i64], ptr %array_literal11, i64 0, i64 4
  store i64 0, ptr %elemptr416, align 4
  %elem17 = load [5 x i64], ptr %array_literal11, align 4
  store [5 x i64] %elem17, ptr %"struct member10", align 4
  %elem18 = load { i64, i64, [5 x i64] }, ptr %struct_alloca7, align 4
  store { i64, i64, [5 x i64] } %elem18, ptr %elemptr16, align 4
  ret ptr %array_literal
}

define i64 @getFirstBookID(ptr %0) {
entry:
  call void @builtin_range_check(i64 1)
  %index_access = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %0, i64 0, i64 0
  %"struct member" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 2
  call void @builtin_range_check(i64 3)
  %index_access1 = getelementptr [5 x i64], ptr %"struct member", i64 0, i64 1
  %1 = load i64, ptr %index_access1, align 4
  ret i64 %1
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %struct_alloca = alloca { i64, i64, [5 x i64] }, align 8
  %array_literal39 = alloca [5 x i64], align 8
  %array_literal = alloca [2 x { i64, i64, [5 x i64] }], align 8
  switch i64 %0, label %missing_function [
    i64 2736305406, label %func_0_dispatch
    i64 4212406781, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @createBooks()
  %size_var = alloca i64, align 8
  store i64 0, ptr %size_var, align 4
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %4 = icmp ult i64 %index, 2
  br i1 %4, label %body, label %end_for

next:                                             ; preds = %body
  %index4 = load i64, ptr %index_ptr, align 4
  %5 = add i64 %index4, 1
  store i64 %5, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %6 = sub i64 1, %index
  call void @builtin_range_check(i64 %6)
  %index_access = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %3, i64 0, i64 %index
  %"struct member" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 0
  %elem = load i64, ptr %"struct member", align 4
  %"struct member1" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 1
  %elem2 = load i64, ptr %"struct member1", align 4
  %"struct member3" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 2
  %7 = load i64, ptr %size_var, align 4
  %8 = add i64 %7, 7
  store i64 %8, ptr %size_var, align 4
  br label %next

end_for:                                          ; preds = %cond
  %9 = load i64, ptr %size_var, align 4
  %10 = call i64 @vector_new(i64 %9)
  %heap_start = sub i64 %10, %9
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %offset_var_no = alloca i64, align 8
  store i64 0, ptr %offset_var_no, align 4
  %index_ptr5 = alloca i64, align 8
  store i64 0, ptr %index_ptr5, align 4
  %index6 = load i64, ptr %index_ptr5, align 4
  br label %cond7

cond7:                                            ; preds = %next8, %end_for
  %11 = icmp ult i64 %index6, 2
  br i1 %11, label %body9, label %end_for10

next8:                                            ; preds = %body9
  %index27 = load i64, ptr %index_ptr5, align 4
  %12 = add i64 %index27, 1
  store i64 %12, ptr %index_ptr5, align 4
  br label %cond7

body9:                                            ; preds = %cond7
  %13 = sub i64 1, %index6
  call void @builtin_range_check(i64 %13)
  %index_access11 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %3, i64 0, i64 %index6
  %14 = load i64, ptr %offset_var_no, align 4
  %"struct member12" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access11, i32 0, i32 0
  %elem13 = load i64, ptr %"struct member12", align 4
  %start = getelementptr i64, ptr %heap_to_ptr, i64 %14
  store i64 %elem13, ptr %start, align 4
  %15 = add i64 %14, 1
  %"struct member14" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access11, i32 0, i32 1
  %elem15 = load i64, ptr %"struct member14", align 4
  %start16 = getelementptr i64, ptr %heap_to_ptr, i64 %15
  store i64 %elem15, ptr %start16, align 4
  %16 = add i64 %15, 1
  %"struct member17" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access11, i32 0, i32 2
  %elemptr0 = getelementptr [5 x i64], ptr %"struct member17", i64 0, i64 0
  %17 = load i64, ptr %elemptr0, align 4
  %start18 = getelementptr i64, ptr %heap_to_ptr, i64 %16
  store i64 %17, ptr %start18, align 4
  %offset = add i64 %16, 1
  %elemptr1 = getelementptr [5 x i64], ptr %"struct member17", i64 0, i64 1
  %18 = load i64, ptr %elemptr1, align 4
  %start19 = getelementptr i64, ptr %heap_to_ptr, i64 %offset
  store i64 %18, ptr %start19, align 4
  %offset20 = add i64 %offset, 1
  %elemptr2 = getelementptr [5 x i64], ptr %"struct member17", i64 0, i64 2
  %19 = load i64, ptr %elemptr2, align 4
  %start21 = getelementptr i64, ptr %heap_to_ptr, i64 %offset20
  store i64 %19, ptr %start21, align 4
  %offset22 = add i64 %offset20, 1
  %elemptr3 = getelementptr [5 x i64], ptr %"struct member17", i64 0, i64 3
  %20 = load i64, ptr %elemptr3, align 4
  %start23 = getelementptr i64, ptr %heap_to_ptr, i64 %offset22
  store i64 %20, ptr %start23, align 4
  %offset24 = add i64 %offset22, 1
  %elemptr4 = getelementptr [5 x i64], ptr %"struct member17", i64 0, i64 4
  %21 = load i64, ptr %elemptr4, align 4
  %start25 = getelementptr i64, ptr %heap_to_ptr, i64 %offset24
  store i64 %21, ptr %start25, align 4
  %offset26 = add i64 %offset24, 1
  %22 = add i64 %14, 7
  store i64 %22, ptr %offset_var_no, align 4
  br label %next8

end_for10:                                        ; preds = %cond7
  %23 = load i64, ptr %offset_var_no, align 4
  %24 = sub i64 %23, 0
  %25 = add i64 0, %24
  call void @set_tape_data(i64 %heap_start, i64 %9)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %elemptr028 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %array_literal, i64 0, i64 0
  store i64 0, ptr %elemptr028, align 4
  %elemptr129 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %array_literal, i64 0, i64 1
  store i64 0, ptr %elemptr129, align 4
  store ptr %array_literal, ptr null, align 8
  %offset_var = alloca i64, align 8
  store i64 0, ptr %offset_var, align 4
  %26 = load i64, ptr %offset_var, align 4
  %27 = add i64 %26, 14
  %28 = icmp ule i64 %27, %1
  br i1 %28, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_1_dispatch
  %index_ptr30 = alloca i64, align 8
  store i64 0, ptr %index_ptr30, align 4
  %index31 = load i64, ptr %index_ptr30, align 4
  br label %cond32

out_of_bounds:                                    ; preds = %func_1_dispatch
  unreachable

cond32:                                           ; preds = %next33, %inbounds
  %29 = icmp ult i64 %index31, 2
  br i1 %29, label %body34, label %end_for35

next33:                                           ; preds = %body34
  %index64 = load i64, ptr %index_ptr30, align 4
  %30 = add i64 %index64, 1
  store i64 %30, ptr %index_ptr30, align 4
  br label %cond32

body34:                                           ; preds = %cond32
  %start36 = getelementptr i64, ptr %2, i64 %26
  %value = load i64, ptr %start36, align 4
  %31 = add i64 %26, 1
  %start37 = getelementptr i64, ptr %2, i64 %31
  %value38 = load i64, ptr %start37, align 4
  %32 = add i64 %31, 1
  %elemptr040 = getelementptr [5 x i64], ptr %array_literal39, i64 0, i64 0
  %start41 = getelementptr i64, ptr %2, i64 %32
  %value42 = load i64, ptr %start41, align 4
  %offset43 = add i64 %32, 1
  store i64 %value42, ptr %elemptr040, align 4
  %elemptr144 = getelementptr [5 x i64], ptr %array_literal39, i64 0, i64 1
  %start45 = getelementptr i64, ptr %2, i64 %offset43
  %value46 = load i64, ptr %start45, align 4
  %offset47 = add i64 %offset43, 1
  store i64 %value46, ptr %elemptr144, align 4
  %elemptr248 = getelementptr [5 x i64], ptr %array_literal39, i64 0, i64 2
  %start49 = getelementptr i64, ptr %2, i64 %offset47
  %value50 = load i64, ptr %start49, align 4
  %offset51 = add i64 %offset47, 1
  store i64 %value50, ptr %elemptr248, align 4
  %elemptr352 = getelementptr [5 x i64], ptr %array_literal39, i64 0, i64 3
  %start53 = getelementptr i64, ptr %2, i64 %offset51
  %value54 = load i64, ptr %start53, align 4
  %offset55 = add i64 %offset51, 1
  store i64 %value54, ptr %elemptr352, align 4
  %elemptr456 = getelementptr [5 x i64], ptr %array_literal39, i64 0, i64 4
  %start57 = getelementptr i64, ptr %2, i64 %offset55
  %value58 = load i64, ptr %start57, align 4
  %offset59 = add i64 %offset55, 1
  store i64 %value58, ptr %elemptr456, align 4
  %"struct member60" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca, i32 0, i32 0
  store i64 %value, ptr %"struct member60", align 4
  %"struct member61" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca, i32 0, i32 1
  store i64 %value38, ptr %"struct member61", align 4
  %"struct member62" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca, i32 0, i32 2
  store ptr %array_literal39, ptr %"struct member62", align 8
  %33 = load ptr, ptr null, align 8
  %34 = sub i64 1, %index31
  call void @builtin_range_check(i64 %34)
  %index_access63 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %33, i64 0, i64 %index31
  store ptr %struct_alloca, ptr %index_access63, align 8
  %35 = add i64 %26, 7
  store i64 %35, ptr %offset_var, align 4
  br label %next33

end_for35:                                        ; preds = %cond32
  %36 = load ptr, ptr null, align 8
  %37 = load i64, ptr %offset_var, align 4
  %38 = sub i64 %37, 0
  %39 = add i64 0, %38
  %40 = icmp ult i64 %39, %1
  br i1 %40, label %not_all_bytes_read, label %buffer_read

not_all_bytes_read:                               ; preds = %end_for35
  unreachable

buffer_read:                                      ; preds = %end_for35
  %41 = call i64 @getFirstBookID(ptr %36)
  %42 = call i64 @vector_new(i64 1)
  %heap_start65 = sub i64 %42, 1
  %heap_to_ptr66 = inttoptr i64 %heap_start65 to ptr
  %start67 = getelementptr i64, ptr %heap_to_ptr66, i64 0
  store i64 %41, ptr %start67, align 4
  call void @set_tape_data(i64 %heap_start65, i64 1)
  ret void
}

define void @call() {
entry:
  %0 = call i64 @vector_new(i64 1)
  %heap_start = sub i64 %0, 1
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_call_data(i64 %heap_start, i64 0)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 1)
  %heap_start1 = sub i64 %1, 1
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_call_data(i64 %heap_start1, i64 1)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = call i64 @vector_new(i64 %input_length)
  %heap_start3 = sub i64 %2, %input_length
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_call_data(i64 %heap_start3, i64 2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  unreachable
}
