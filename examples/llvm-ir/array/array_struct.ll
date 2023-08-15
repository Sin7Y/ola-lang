; ModuleID = 'StructArrayExample'
source_filename = "examples/source/array/array_struct.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

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

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define ptr @createBooks() {
entry:
  %struct_alloca3 = alloca { i64, i64 }, align 8
  %struct_alloca = alloca { i64, i64 }, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 3)
  %heap_start = sub i64 %0, 3
  %heap_start_ptr = inttoptr i64 %heap_start to ptr
  store i64 1, ptr %heap_start_ptr, align 4
  %1 = ptrtoint ptr %heap_start_ptr to i64
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 1
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr { i64, i64 }, ptr %vector_data, i64 %index_value
  store ptr %struct_alloca, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %length = load i64, ptr %heap_start_ptr, align 4
  %3 = sub i64 %length, 1
  %4 = sub i64 %3, 0
  call void @builtin_range_check(i64 %4)
  %5 = ptrtoint ptr %heap_start_ptr to i64
  %6 = add i64 %5, 1
  %vector_data1 = inttoptr i64 %6 to ptr
  %index_access2 = getelementptr ptr, ptr %vector_data1, i64 0
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca3, i32 0, i32 0
  store i64 99, ptr %"struct member", align 4
  %"struct member4" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca3, i32 0, i32 1
  store i64 100, ptr %"struct member4", align 4
  %7 = load { i64, i64 }, ptr %struct_alloca3, align 4
  store { i64, i64 } %7, ptr %index_access2, align 4
  ret ptr %heap_start_ptr
}
