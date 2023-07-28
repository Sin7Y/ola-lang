; ModuleID = 'StructArrayExample'
source_filename = "examples/source/array/dynamic_array_struct.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

define ptr @vector_new_init(i64 %0, ptr %1) {
entry:
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %0, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %1, ptr %vector_data, align 8
  ret ptr %vector_alloca
}

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

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
  %_books = alloca ptr, align 8
  store ptr %0, ptr %_books, align 8
  call void @builtin_range_check(i64 1)
  %index_access = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %_books, i64 0, i64 0
  %"struct member" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 2
  call void @builtin_range_check(i64 3)
  %index_access1 = getelementptr [5 x i64], ptr %"struct member", i64 0, i64 1
  %1 = load i64, ptr %index_access1, align 4
  ret i64 %1
}

define void @function_dispatch(i64 %0, i64 %1, i64 %2) {
entry:
  %struct_alloca = alloca { i64, i64, [5 x i64] }, align 8
  %array_literal17 = alloca [5 x i64], align 8
  %array_literal = alloca [2 x { i64, i64, [5 x i64] }], align 8
  switch i64 %0, label %missing_function [
    i64 2736305406, label %func_0_dispatch
    i64 4212406781, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @createBooks()
  %offset_var_no = alloca i64, align 8
  store i64 0, ptr %offset_var_no, align 4
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %4 = icmp ult i64 %index, 2
  br i1 %4, label %body, label %end_for

next:                                             ; preds = %body
  %index8 = load i64, ptr %index_ptr, align 4
  %5 = add i64 %index8, 1
  store i64 %5, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %6 = sub i64 1, %index
  call void @builtin_range_check(i64 %6)
  %index_access = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %3, i64 0, i64 %index
  %7 = load i64, ptr %offset_var_no, align 4
  %"struct member" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 0
  %elem = load i64, ptr %"struct member", align 4
  call void @tape_store(i64 %7, i64 %elem)
  %8 = add i64 %7, 1
  %"struct member1" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 1
  %elem2 = load i64, ptr %"struct member1", align 4
  call void @tape_store(i64 %8, i64 %elem2)
  %9 = add i64 %8, 1
  %"struct member3" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 2
  %elemptr0 = getelementptr [5 x i64], ptr %"struct member3", i64 0, i64 0
  %10 = load i64, ptr %elemptr0, align 4
  call void @tape_store(i64 %9, i64 %10)
  %offset = add i64 %9, 1
  %elemptr1 = getelementptr [5 x i64], ptr %"struct member3", i64 0, i64 1
  %11 = load i64, ptr %elemptr1, align 4
  call void @tape_store(i64 %offset, i64 %11)
  %offset4 = add i64 %offset, 1
  %elemptr2 = getelementptr [5 x i64], ptr %"struct member3", i64 0, i64 2
  %12 = load i64, ptr %elemptr2, align 4
  call void @tape_store(i64 %offset4, i64 %12)
  %offset5 = add i64 %offset4, 1
  %elemptr3 = getelementptr [5 x i64], ptr %"struct member3", i64 0, i64 3
  %13 = load i64, ptr %elemptr3, align 4
  call void @tape_store(i64 %offset5, i64 %13)
  %offset6 = add i64 %offset5, 1
  %elemptr4 = getelementptr [5 x i64], ptr %"struct member3", i64 0, i64 4
  %14 = load i64, ptr %elemptr4, align 4
  call void @tape_store(i64 %offset6, i64 %14)
  %offset7 = add i64 %offset6, 1
  %15 = add i64 %7, 7
  store i64 %15, ptr %offset_var_no, align 4
  br label %next

end_for:                                          ; preds = %cond
  %16 = load i64, ptr %offset_var_no, align 4
  %17 = sub i64 %16, 0
  %18 = add i64 0, %17
  ret void

func_1_dispatch:                                  ; preds = %entry
  %elemptr09 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %array_literal, i64 0, i64 0
  store i64 0, ptr %elemptr09, align 4
  %elemptr110 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %array_literal, i64 0, i64 1
  store i64 0, ptr %elemptr110, align 4
  store ptr %array_literal, ptr null, align 8
  %offset_var = alloca i64, align 8
  store i64 0, ptr %offset_var, align 4
  %19 = load i64, ptr %offset_var, align 4
  %20 = add i64 %19, 14
  %21 = icmp ule i64 %20, %1
  br i1 %21, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_1_dispatch
  %index_ptr11 = alloca i64, align 8
  store i64 0, ptr %index_ptr11, align 4
  %index12 = load i64, ptr %index_ptr11, align 4
  br label %cond13

out_of_bounds:                                    ; preds = %func_1_dispatch
  unreachable

cond13:                                           ; preds = %next14, %inbounds
  %22 = icmp ult i64 %index12, 2
  br i1 %22, label %body15, label %end_for16

next14:                                           ; preds = %body15
  %index32 = load i64, ptr %index_ptr11, align 4
  %23 = add i64 %index32, 1
  store i64 %23, ptr %index_ptr11, align 4
  br label %cond13

body15:                                           ; preds = %cond13
  %24 = call i64 @tape_load(i64 %2, i64 %19)
  %25 = add i64 %19, 1
  %26 = call i64 @tape_load(i64 %2, i64 %25)
  %27 = add i64 %25, 1
  %elemptr018 = getelementptr [5 x i64], ptr %array_literal17, i64 0, i64 0
  %28 = call i64 @tape_load(i64 %2, i64 %27)
  %offset19 = add i64 %27, 1
  store i64 %28, ptr %elemptr018, align 4
  %elemptr120 = getelementptr [5 x i64], ptr %array_literal17, i64 0, i64 1
  %29 = call i64 @tape_load(i64 %2, i64 %offset19)
  %offset21 = add i64 %offset19, 1
  store i64 %29, ptr %elemptr120, align 4
  %elemptr222 = getelementptr [5 x i64], ptr %array_literal17, i64 0, i64 2
  %30 = call i64 @tape_load(i64 %2, i64 %offset21)
  %offset23 = add i64 %offset21, 1
  store i64 %30, ptr %elemptr222, align 4
  %elemptr324 = getelementptr [5 x i64], ptr %array_literal17, i64 0, i64 3
  %31 = call i64 @tape_load(i64 %2, i64 %offset23)
  %offset25 = add i64 %offset23, 1
  store i64 %31, ptr %elemptr324, align 4
  %elemptr426 = getelementptr [5 x i64], ptr %array_literal17, i64 0, i64 4
  %32 = call i64 @tape_load(i64 %2, i64 %offset25)
  %offset27 = add i64 %offset25, 1
  store i64 %32, ptr %elemptr426, align 4
  %"struct member28" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca, i32 0, i32 0
  store i64 %24, ptr %"struct member28", align 4
  %"struct member29" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca, i32 0, i32 1
  store i64 %26, ptr %"struct member29", align 4
  %"struct member30" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca, i32 0, i32 2
  store ptr %array_literal17, ptr %"struct member30", align 8
  %33 = load ptr, ptr null, align 8
  %34 = sub i64 1, %index12
  call void @builtin_range_check(i64 %34)
  %index_access31 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %33, i64 0, i64 %index12
  store ptr %struct_alloca, ptr %index_access31, align 8
  %35 = add i64 %19, 7
  store i64 %35, ptr %offset_var, align 4
  br label %next14

end_for16:                                        ; preds = %cond13
  %36 = load ptr, ptr null, align 8
  %37 = load i64, ptr %offset_var, align 4
  %38 = sub i64 %37, 0
  %39 = add i64 0, %38
  %40 = icmp ult i64 %39, %1
  br i1 %40, label %not_all_bytes_read, label %buffer_read

not_all_bytes_read:                               ; preds = %end_for16
  unreachable

buffer_read:                                      ; preds = %end_for16
  %41 = call i64 @getFirstBookID(ptr %36)
  call void @tape_store(i64 0, i64 %41)
  ret void
}

define void @call() {
entry:
  %0 = call ptr @contract_input()
  %input_selector = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 0
  %selector = load i64, ptr %input_selector, align 4
  %input_len = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 1
  %len = load i64, ptr %input_len, align 4
  %input_data = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 2
  %data = load i64, ptr %input_data, align 4
  call void @function_dispatch(i64 %selector, i64 %len, i64 %data)
  unreachable
}
