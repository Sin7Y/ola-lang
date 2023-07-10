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
  %vector_alloca = alloca { i64, ptr }, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 3)
  %int_to_ptr = inttoptr i64 %0 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %int_to_ptr, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 3, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length = load i64, ptr %vector_len1, align 4
  %1 = sub i64 %length, 1
  %2 = sub i64 %1, 0
  call void @builtin_range_check(i64 %2)
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access2 = getelementptr i64, ptr %data, i64 0
  store i64 85, ptr %index_access2, align 4
  %vector_len3 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length4 = load i64, ptr %vector_len3, align 4
  %3 = sub i64 %length4, 1
  %4 = sub i64 %3, 1
  call void @builtin_range_check(i64 %4)
  %data5 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access6 = getelementptr i64, ptr %data5, i64 1
  store i64 90, ptr %index_access6, align 4
  %vector_len7 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length8 = load i64, ptr %vector_len7, align 4
  %5 = sub i64 %length8, 1
  %6 = sub i64 %5, 2
  call void @builtin_range_check(i64 %6)
  %data9 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access10 = getelementptr i64, ptr %data9, i64 2
  store i64 95, ptr %index_access10, align 4
  %"struct member" = getelementptr inbounds { i64, ptr }, ptr %struct_alloca, i32 0, i32 0
  store i64 20, ptr %"struct member", align 4
  %"struct member11" = getelementptr inbounds { i64, ptr }, ptr %struct_alloca, i32 0, i32 1
  store ptr %vector_alloca, ptr %"struct member11", align 8
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
  %1 = sub i64 %length, 1
  %2 = sub i64 %1, 0
  call void @builtin_range_check(i64 %2)
  %data = getelementptr inbounds { i64, ptr }, ptr %"struct member", i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 0
  %3 = load i64, ptr %index_access, align 4
  ret i64 %3
}
