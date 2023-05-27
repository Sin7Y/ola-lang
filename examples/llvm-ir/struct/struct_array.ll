; ModuleID = 'StructWithArrayExample'
source_filename = "examples/source/struct/struct_array.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

define ptr @createStudent() {
entry:
  %struct_alloca = alloca { i64, ptr }, align 8
  %0 = call ptr @vector_new(i64 3, ptr null)
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 0
  store i64 85, ptr %index_access, align 4
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %data3 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access4 = getelementptr ptr, ptr %data3, i64 1
  store i64 90, ptr %index_access4, align 4
  %vector_len5 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length6 = load i64, ptr %vector_len5, align 4
  %data7 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access8 = getelementptr ptr, ptr %data7, i64 2
  store i64 95, ptr %index_access8, align 4
  %"struct member" = getelementptr inbounds { i64, ptr }, ptr %struct_alloca, i32 0, i32 0
  store i64 20, ptr %"struct member", align 4
  %"struct member9" = getelementptr inbounds { i64, ptr }, ptr %struct_alloca, i32 0, i32 1
  store ptr %0, ptr %"struct member9", align 8
  ret ptr %struct_alloca
}

define i64 @getFirstGrade(ptr %0) {
entry:
  %struct_alloca5 = alloca { i64, ptr }, align 8
  %struct_alloca = alloca { i64, ptr }, align 8
  %_student = alloca ptr, align 8
  store ptr %0, ptr %_student, align 8
  %"struct member" = getelementptr inbounds { i64, ptr }, ptr %_student, i32 0, i32 1
  %1 = load ptr, ptr %"struct member", align 8
  %allocation_needed = icmp eq ptr %1, null
  br i1 %allocation_needed, label %allocate, label %already_allocated

allocate:                                         ; preds = %entry
  store ptr %struct_alloca, ptr %"struct member", align 8
  br label %already_allocated

already_allocated:                                ; preds = %allocate, %entry
  %"ptr_u32[]" = phi ptr [ %1, %entry ], [ %struct_alloca, %allocate ]
  %"struct member1" = getelementptr inbounds { i64, ptr }, ptr %_student, i32 0, i32 1
  %2 = load ptr, ptr %"struct member1", align 8
  %allocation_needed2 = icmp eq ptr %2, null
  br i1 %allocation_needed2, label %allocate3, label %already_allocated4

allocate3:                                        ; preds = %already_allocated
  store ptr %struct_alloca5, ptr %"struct member1", align 8
  br label %already_allocated4

already_allocated4:                               ; preds = %allocate3, %already_allocated
  %"ptr_u32[]6" = phi ptr [ %2, %already_allocated ], [ %struct_alloca5, %allocate3 ]
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %"ptr_u32[]6", i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %"ptr_u32[]", i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 0
  %3 = load i64, ptr %index_access, align 4
  ret i64 %3
}
