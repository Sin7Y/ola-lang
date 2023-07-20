; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote.ola"

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

define void @main() {
entry:
  %vector_alloca5 = alloca { i64, ptr }, align 8
  %i = alloca i64, align 8
  %vector_alloca = alloca { i64, ptr }, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 5)
  %int_to_ptr = inttoptr i64 %0 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 5
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %int_to_ptr, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 5, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  store i64 0, ptr %i, align 4
  br label %cond1

cond1:                                            ; preds = %next, %done
  %1 = load i64, ptr %i, align 4
  %2 = icmp ult i64 %1, 5
  br i1 %2, label %body2, label %endfor

body2:                                            ; preds = %cond1
  %3 = call i64 @vector_new(i64 1)
  %int_to_ptr3 = inttoptr i64 %3 to ptr
  %index_access4 = getelementptr i64, ptr %int_to_ptr3, i64 0
  store i64 49, ptr %index_access4, align 4
  %vector_len6 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca5, i32 0, i32 0
  store i64 1, ptr %vector_len6, align 4
  %vector_data7 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca5, i32 0, i32 1
  store ptr %int_to_ptr3, ptr %vector_data7, align 8
  %4 = load i64, ptr %i, align 4
  %vector_len8 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length = load i64, ptr %vector_len8, align 4
  %5 = sub i64 %length, 1
  %6 = sub i64 %5, %4
  call void @builtin_range_check(i64 %6)
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access9 = getelementptr { i64, ptr }, ptr %data, i64 %4
  store ptr %vector_alloca5, ptr %index_access9, align 8
  br label %next

next:                                             ; preds = %body2
  %7 = load i64, ptr %i, align 4
  %8 = add i64 %7, 1
  store i64 %8, ptr %i, align 4
  br label %cond1

endfor:                                           ; preds = %cond1
  ret void
}
