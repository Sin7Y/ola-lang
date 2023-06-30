; ModuleID = 'StructWithArrayExample'
source_filename = "examples/source/struct/struct_array.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define ptr @createStudent() {
entry:
  %struct_alloca = alloca { i64, ptr }, align 8
  %0 = call i64 @vector_new(i64 3)
  %1 = load i64, ptr @heap_address, align 4
  %allocated_size = sub i64 %1, %0
  call void @builtin_assert(i64 %allocated_size, i64 3)
  store i64 %0, ptr @heap_address, align 4
  %int_to_ptr = inttoptr i64 %0 to ptr
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 3, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length = load i64, ptr %vector_len1, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 0
  store i64 85, ptr %index_access, align 4
  %vector_len2 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length3 = load i64, ptr %vector_len2, align 4
  %data4 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access5 = getelementptr i64, ptr %data4, i64 1
  store i64 90, ptr %index_access5, align 4
  %vector_len6 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length7 = load i64, ptr %vector_len6, align 4
  %data8 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access9 = getelementptr i64, ptr %data8, i64 2
  store i64 95, ptr %index_access9, align 4
  %"struct member" = getelementptr inbounds { i64, ptr }, ptr %struct_alloca, i32 0, i32 0
  store i64 20, ptr %"struct member", align 4
  %"struct member10" = getelementptr inbounds { i64, ptr }, ptr %struct_alloca, i32 0, i32 1
  store ptr %vector_alloca, ptr %"struct member10", align 8
  ret ptr %struct_alloca
}

define i64 @getFirstGrade(ptr %0) {
entry:
  %_student = alloca ptr, align 8
  store ptr %0, ptr %_student, align 8
  %"struct member" = getelementptr inbounds { i64, ptr }, ptr %_student, i32 0, i32 1
  %"struct member1" = getelementptr inbounds { i64, ptr }, ptr %_student, i32 0, i32 1
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %"struct member1", i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %"struct member", i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 0
  %1 = load i64, ptr %index_access, align 4
  ret i64 %1
}
