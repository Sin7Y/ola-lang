; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/array/array_dynamic/array_5.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define void @main() {
entry:
  %length1 = alloca i64, align 8
  %0 = call ptr @vector_new(i64 5, ptr null)
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 0
  store i64 1, ptr %index_access, align 4
  %1 = call i64 @array_call(ptr %0)
  store i64 %1, ptr %length1, align 4
  ret void
}

define i64 @array_call(ptr %0) {
entry:
  %i = alloca i64, align 8
  %source = alloca ptr, align 8
  store ptr %0, ptr %source, align 8
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %1 = load i64, ptr %i, align 4
  %2 = icmp ult i64 %1, 5
  br i1 %2, label %body, label %endfor

body:                                             ; preds = %cond
  %3 = load i64, ptr %i, align 4
  %4 = load i64, ptr %i, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %source, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %source, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 %4
  store i64 %3, ptr %index_access, align 4
  br label %next

next:                                             ; preds = %body
  %5 = load i64, ptr %i, align 4
  %6 = add i64 %5, 1
  call void @builtin_range_check(i64 %6)
  br label %cond

endfor:                                           ; preds = %cond
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %source, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  ret i64 %length2
}
