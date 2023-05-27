; ModuleID = 'DynamicTwoDimensionalArrayInMemory'
source_filename = "examples/source/array/array_dynamic_2d.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

define ptr @initialize(i64 %0, i64 %1) {
entry:
  %i = alloca i64, align 8
  %columns = alloca i64, align 8
  %rows = alloca i64, align 8
  store i64 %0, ptr %rows, align 4
  store i64 %1, ptr %columns, align 4
  %2 = load i64, ptr %rows, align 4
  %3 = call ptr @vector_new(i64 %2, ptr null)
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %4 = load i64, ptr %i, align 4
  %5 = load i64, ptr %rows, align 4
  %6 = icmp ult i64 %4, %5
  br i1 %6, label %body, label %endfor

body:                                             ; preds = %cond
  %7 = load i64, ptr %columns, align 4
  %8 = call ptr @vector_new(i64 %7, ptr null)
  %9 = load i64, ptr %i, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 %9
  store ptr %8, ptr %index_access, align 8
  br label %next

next:                                             ; preds = %body
  %10 = load i64, ptr %i, align 4
  %11 = add i64 %10, 1
  store i64 %11, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret ptr %3
}

define void @setElement(ptr %0, i64 %1, i64 %2, i64 %3) {
entry:
  %struct_alloca8 = alloca { i64, ptr }, align 8
  %struct_alloca = alloca { i64, ptr }, align 8
  %value = alloca i64, align 8
  %column = alloca i64, align 8
  %row = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  store i64 %1, ptr %row, align 4
  store i64 %2, ptr %column, align 4
  store i64 %3, ptr %value, align 4
  %4 = load i64, ptr %value, align 4
  %5 = load i64, ptr %row, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 %5
  %6 = load ptr, ptr %index_access, align 8
  %allocation_needed = icmp eq ptr %6, null
  br i1 %allocation_needed, label %allocate, label %already_allocated

allocate:                                         ; preds = %entry
  store ptr %struct_alloca, ptr %index_access, align 8
  br label %already_allocated

already_allocated:                                ; preds = %allocate, %entry
  %"ptr_u32[]" = phi ptr [ %6, %entry ], [ %struct_alloca, %allocate ]
  %7 = load i64, ptr %column, align 4
  %8 = load i64, ptr %row, align 4
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %data3 = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 1
  %index_access4 = getelementptr ptr, ptr %data3, i64 %8
  %9 = load ptr, ptr %index_access4, align 8
  %allocation_needed5 = icmp eq ptr %9, null
  br i1 %allocation_needed5, label %allocate6, label %already_allocated7

allocate6:                                        ; preds = %already_allocated
  store ptr %struct_alloca8, ptr %index_access4, align 8
  br label %already_allocated7

already_allocated7:                               ; preds = %allocate6, %already_allocated
  %"ptr_u32[]9" = phi ptr [ %9, %already_allocated ], [ %struct_alloca8, %allocate6 ]
  %vector_len10 = getelementptr inbounds { i64, ptr }, ptr %"ptr_u32[]9", i32 0, i32 0
  %length11 = load i64, ptr %vector_len10, align 4
  %data12 = getelementptr inbounds { i64, ptr }, ptr %"ptr_u32[]", i32 0, i32 1
  %index_access13 = getelementptr ptr, ptr %data12, i64 %7
  store i64 %4, ptr %index_access13, align 4
  ret void
}

define i64 @getElement(ptr %0, i64 %1, i64 %2) {
entry:
  %struct_alloca8 = alloca { i64, ptr }, align 8
  %struct_alloca = alloca { i64, ptr }, align 8
  %column = alloca i64, align 8
  %row = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  store i64 %1, ptr %row, align 4
  store i64 %2, ptr %column, align 4
  %3 = load i64, ptr %row, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 %3
  %4 = load ptr, ptr %index_access, align 8
  %allocation_needed = icmp eq ptr %4, null
  br i1 %allocation_needed, label %allocate, label %already_allocated

allocate:                                         ; preds = %entry
  store ptr %struct_alloca, ptr %index_access, align 8
  br label %already_allocated

already_allocated:                                ; preds = %allocate, %entry
  %"ptr_u32[]" = phi ptr [ %4, %entry ], [ %struct_alloca, %allocate ]
  %5 = load i64, ptr %column, align 4
  %6 = load i64, ptr %row, align 4
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %data3 = getelementptr inbounds { i64, ptr }, ptr %array, i32 0, i32 1
  %index_access4 = getelementptr ptr, ptr %data3, i64 %6
  %7 = load ptr, ptr %index_access4, align 8
  %allocation_needed5 = icmp eq ptr %7, null
  br i1 %allocation_needed5, label %allocate6, label %already_allocated7

allocate6:                                        ; preds = %already_allocated
  store ptr %struct_alloca8, ptr %index_access4, align 8
  br label %already_allocated7

already_allocated7:                               ; preds = %allocate6, %already_allocated
  %"ptr_u32[]9" = phi ptr [ %7, %already_allocated ], [ %struct_alloca8, %allocate6 ]
  %vector_len10 = getelementptr inbounds { i64, ptr }, ptr %"ptr_u32[]9", i32 0, i32 0
  %length11 = load i64, ptr %vector_len10, align 4
  %data12 = getelementptr inbounds { i64, ptr }, ptr %"ptr_u32[]", i32 0, i32 1
  %index_access13 = getelementptr ptr, ptr %data12, i64 %5
  %8 = load i64, ptr %index_access13, align 4
  ret i64 %8
}
