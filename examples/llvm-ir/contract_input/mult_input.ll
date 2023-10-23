; ModuleID = 'MultInputExample'
source_filename = "examples/source/contract_input/mult_input.ola"

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

define void @memory_copy(ptr %0, i64 %1, ptr %2, i64 %3, i64 %4) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %4
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %5 = add i64 %1, %index_value
  %src_index_access = getelementptr i64, ptr %0, i64 %5
  %6 = load i64, ptr %src_index_access, align 4
  %7 = add i64 %3, %index_value
  %dest_index_access = getelementptr i64, ptr %2, i64 %7
  store i64 %6, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
}

define void @foo(ptr %0, ptr %1, ptr %2, ptr %3, i64 %4, i64 %5, i64 %6) {
entry:
  %index18 = alloca i64, align 8
  %index = alloca i64, align 8
  %b = alloca i64, align 8
  %fe = alloca i64, align 8
  %a = alloca i64, align 8
  %h = alloca ptr, align 8
  %addr = alloca ptr, align 8
  store ptr %2, ptr %addr, align 8
  store ptr %3, ptr %h, align 8
  store i64 %4, ptr %a, align 4
  store i64 %5, ptr %fe, align 4
  store i64 %6, ptr %b, align 4
  %7 = ptrtoint ptr %0 to i64
  %8 = add i64 %7, 1
  %vector_data = inttoptr i64 %8 to ptr
  %length = load i64, ptr %0, align 4
  %9 = call i64 @vector_new(i64 3)
  %heap_start = sub i64 %9, 3
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 2, ptr %heap_to_ptr, align 4
  %10 = ptrtoint ptr %heap_to_ptr to i64
  %11 = add i64 %10, 1
  %vector_data1 = inttoptr i64 %11 to ptr
  %index_access = getelementptr i64, ptr %vector_data1, i64 0
  store i64 49, ptr %index_access, align 4
  %index_access2 = getelementptr i64, ptr %vector_data1, i64 1
  store i64 50, ptr %index_access2, align 4
  %12 = ptrtoint ptr %heap_to_ptr to i64
  %13 = add i64 %12, 1
  %vector_data3 = inttoptr i64 %13 to ptr
  %length4 = load i64, ptr %heap_to_ptr, align 4
  %14 = icmp eq i64 %length, %length4
  %15 = zext i1 %14 to i64
  call void @builtin_assert(i64 %15)
  store i64 0, ptr %index, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index5 = load i64, ptr %index, align 4
  %16 = icmp ult i64 %index5, %length
  br i1 %16, label %body, label %done

body:                                             ; preds = %cond
  %left_char_ptr = getelementptr i64, ptr %vector_data, i64 %index5
  %right_char_ptr = getelementptr i64, ptr %vector_data3, i64 %index5
  %left_char = load i64, ptr %left_char_ptr, align 4
  %right_char = load i64, ptr %right_char_ptr, align 4
  %comparison = icmp eq i64 %left_char, %right_char
  %next_index = add i64 %index5, 1
  store i64 %next_index, ptr %index, align 4
  br i1 %comparison, label %cond, label %done

done:                                             ; preds = %body, %cond
  %equal = icmp eq i64 %index5, %length4
  %17 = zext i1 %equal to i64
  call void @builtin_assert(i64 %17)
  %18 = ptrtoint ptr %1 to i64
  %19 = add i64 %18, 1
  %vector_data6 = inttoptr i64 %19 to ptr
  %length7 = load i64, ptr %1, align 4
  %20 = call i64 @vector_new(i64 3)
  %heap_start8 = sub i64 %20, 3
  %heap_to_ptr9 = inttoptr i64 %heap_start8 to ptr
  store i64 2, ptr %heap_to_ptr9, align 4
  %21 = ptrtoint ptr %heap_to_ptr9 to i64
  %22 = add i64 %21, 1
  %vector_data10 = inttoptr i64 %22 to ptr
  %index_access11 = getelementptr i64, ptr %vector_data10, i64 0
  store i64 51, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %vector_data10, i64 1
  store i64 52, ptr %index_access12, align 4
  %23 = ptrtoint ptr %heap_to_ptr9 to i64
  %24 = add i64 %23, 1
  %vector_data13 = inttoptr i64 %24 to ptr
  %length14 = load i64, ptr %heap_to_ptr9, align 4
  %25 = icmp eq i64 %length7, %length14
  %26 = zext i1 %25 to i64
  call void @builtin_assert(i64 %26)
  store i64 0, ptr %index18, align 4
  br label %cond15

cond15:                                           ; preds = %body16, %done
  %index19 = load i64, ptr %index18, align 4
  %27 = icmp ult i64 %index19, %length7
  br i1 %27, label %body16, label %done17

body16:                                           ; preds = %cond15
  %left_char_ptr20 = getelementptr i64, ptr %vector_data6, i64 %index19
  %right_char_ptr21 = getelementptr i64, ptr %vector_data13, i64 %index19
  %left_char22 = load i64, ptr %left_char_ptr20, align 4
  %right_char23 = load i64, ptr %right_char_ptr21, align 4
  %comparison24 = icmp eq i64 %left_char22, %right_char23
  %next_index25 = add i64 %index19, 1
  store i64 %next_index25, ptr %index18, align 4
  br i1 %comparison24, label %cond15, label %done17

done17:                                           ; preds = %body16, %cond15
  %equal26 = icmp eq i64 %index19, %length14
  %28 = zext i1 %equal26 to i64
  call void @builtin_assert(i64 %28)
  %29 = load ptr, ptr %addr, align 8
  %30 = call i64 @vector_new(i64 4)
  %heap_start27 = sub i64 %30, 4
  %heap_to_ptr28 = inttoptr i64 %heap_start27 to ptr
  %index_access29 = getelementptr i64, ptr %heap_to_ptr28, i64 0
  store i64 5, ptr %index_access29, align 4
  %index_access30 = getelementptr i64, ptr %heap_to_ptr28, i64 1
  store i64 6, ptr %index_access30, align 4
  %index_access31 = getelementptr i64, ptr %heap_to_ptr28, i64 2
  store i64 7, ptr %index_access31, align 4
  %index_access32 = getelementptr i64, ptr %heap_to_ptr28, i64 3
  store i64 8, ptr %index_access32, align 4
  %left_elem_0 = getelementptr i64, ptr %29, i64 0
  %31 = load i64, ptr %left_elem_0, align 4
  %right_elem_0 = getelementptr i64, ptr %heap_to_ptr28, i64 0
  %32 = load i64, ptr %right_elem_0, align 4
  %compare_0 = icmp eq i64 %31, %32
  %33 = zext i1 %compare_0 to i64
  %result_0 = and i64 %33, 1
  %left_elem_1 = getelementptr i64, ptr %29, i64 1
  %34 = load i64, ptr %left_elem_1, align 4
  %right_elem_1 = getelementptr i64, ptr %heap_to_ptr28, i64 1
  %35 = load i64, ptr %right_elem_1, align 4
  %compare_1 = icmp eq i64 %34, %35
  %36 = zext i1 %compare_1 to i64
  %result_1 = and i64 %36, %result_0
  %left_elem_2 = getelementptr i64, ptr %29, i64 2
  %37 = load i64, ptr %left_elem_2, align 4
  %right_elem_2 = getelementptr i64, ptr %heap_to_ptr28, i64 2
  %38 = load i64, ptr %right_elem_2, align 4
  %compare_2 = icmp eq i64 %37, %38
  %39 = zext i1 %compare_2 to i64
  %result_2 = and i64 %39, %result_1
  %left_elem_3 = getelementptr i64, ptr %29, i64 3
  %40 = load i64, ptr %left_elem_3, align 4
  %right_elem_3 = getelementptr i64, ptr %heap_to_ptr28, i64 3
  %41 = load i64, ptr %right_elem_3, align 4
  %compare_3 = icmp eq i64 %40, %41
  %42 = zext i1 %compare_3 to i64
  %result_3 = and i64 %42, %result_2
  call void @builtin_assert(i64 %result_3)
  %43 = load ptr, ptr %h, align 8
  %44 = call i64 @vector_new(i64 4)
  %heap_start33 = sub i64 %44, 4
  %heap_to_ptr34 = inttoptr i64 %heap_start33 to ptr
  %index_access35 = getelementptr i64, ptr %heap_to_ptr34, i64 0
  store i64 6, ptr %index_access35, align 4
  %index_access36 = getelementptr i64, ptr %heap_to_ptr34, i64 1
  store i64 7, ptr %index_access36, align 4
  %index_access37 = getelementptr i64, ptr %heap_to_ptr34, i64 2
  store i64 8, ptr %index_access37, align 4
  %index_access38 = getelementptr i64, ptr %heap_to_ptr34, i64 3
  store i64 9, ptr %index_access38, align 4
  %left_elem_039 = getelementptr i64, ptr %43, i64 0
  %45 = load i64, ptr %left_elem_039, align 4
  %right_elem_040 = getelementptr i64, ptr %heap_to_ptr34, i64 0
  %46 = load i64, ptr %right_elem_040, align 4
  %compare_041 = icmp eq i64 %45, %46
  %47 = zext i1 %compare_041 to i64
  %result_042 = and i64 %47, 1
  %left_elem_143 = getelementptr i64, ptr %43, i64 1
  %48 = load i64, ptr %left_elem_143, align 4
  %right_elem_144 = getelementptr i64, ptr %heap_to_ptr34, i64 1
  %49 = load i64, ptr %right_elem_144, align 4
  %compare_145 = icmp eq i64 %48, %49
  %50 = zext i1 %compare_145 to i64
  %result_146 = and i64 %50, %result_042
  %left_elem_247 = getelementptr i64, ptr %43, i64 2
  %51 = load i64, ptr %left_elem_247, align 4
  %right_elem_248 = getelementptr i64, ptr %heap_to_ptr34, i64 2
  %52 = load i64, ptr %right_elem_248, align 4
  %compare_249 = icmp eq i64 %51, %52
  %53 = zext i1 %compare_249 to i64
  %result_250 = and i64 %53, %result_146
  %left_elem_351 = getelementptr i64, ptr %43, i64 3
  %54 = load i64, ptr %left_elem_351, align 4
  %right_elem_352 = getelementptr i64, ptr %heap_to_ptr34, i64 3
  %55 = load i64, ptr %right_elem_352, align 4
  %compare_353 = icmp eq i64 %54, %55
  %56 = zext i1 %compare_353 to i64
  %result_354 = and i64 %56, %result_250
  call void @builtin_assert(i64 %result_354)
  %57 = load i64, ptr %a, align 4
  %58 = icmp eq i64 %57, 10
  %59 = zext i1 %58 to i64
  call void @builtin_assert(i64 %59)
  %60 = load i64, ptr %fe, align 4
  %61 = icmp eq i64 %60, 11
  %62 = zext i1 %61 to i64
  call void @builtin_assert(i64 %62)
  %63 = load i64, ptr %b, align 4
  %64 = icmp eq i64 %63, 1
  %65 = zext i1 %64 to i64
  call void @builtin_assert(i64 %65)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %index_ptr20 = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 3133092977, label %func_0_dispatch
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
  %5 = add i64 0, %3
  %6 = icmp ule i64 %5, %1
  br i1 %6, label %inbounds1, label %out_of_bounds2

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

inbounds1:                                        ; preds = %inbounds
  %size = mul i64 %value, 1
  %size_add_one = add i64 %size, 1
  %7 = call i64 @vector_new(i64 %size_add_one)
  %heap_start = sub i64 %7, %size_add_one
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 %size, ptr %heap_to_ptr, align 4
  %8 = ptrtoint ptr %heap_to_ptr to i64
  %9 = add i64 %8, 1
  %vector_data = inttoptr i64 %9 to ptr
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

out_of_bounds2:                                   ; preds = %inbounds
  unreachable

loop_body:                                        ; preds = %inbounds3, %inbounds1
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr i64, ptr %vector_data, i64 %index
  %10 = icmp ule i64 2, %1
  br i1 %10, label %inbounds3, label %out_of_bounds4

loop_end:                                         ; preds = %inbounds3
  %11 = add i64 0, %3
  %start7 = getelementptr i64, ptr %2, i64 %11
  %value8 = load i64, ptr %start7, align 4
  %12 = add i64 1, %value8
  %13 = add i64 %11, 1
  %14 = icmp ule i64 %13, %1
  br i1 %14, label %inbounds9, label %out_of_bounds10

inbounds3:                                        ; preds = %loop_body
  %start5 = getelementptr i64, ptr %2, i64 1
  %value6 = load i64, ptr %start5, align 4
  store i64 %value6, ptr %element, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %value
  br i1 %index_cond, label %loop_body, label %loop_end

out_of_bounds4:                                   ; preds = %loop_body
  unreachable

inbounds9:                                        ; preds = %loop_end
  %15 = add i64 %11, %12
  %16 = icmp ule i64 %15, %1
  br i1 %16, label %inbounds11, label %out_of_bounds12

out_of_bounds10:                                  ; preds = %loop_end
  unreachable

inbounds11:                                       ; preds = %inbounds9
  %size13 = mul i64 %value8, 1
  %size_add_one14 = add i64 %size13, 1
  %17 = call i64 @vector_new(i64 %size_add_one14)
  %heap_start15 = sub i64 %17, %size_add_one14
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  store i64 %size13, ptr %heap_to_ptr16, align 4
  %18 = ptrtoint ptr %heap_to_ptr16 to i64
  %19 = add i64 %18, 1
  %vector_data17 = inttoptr i64 %19 to ptr
  store i64 0, ptr %index_ptr20, align 4
  br label %loop_body18

out_of_bounds12:                                  ; preds = %inbounds9
  unreachable

loop_body18:                                      ; preds = %inbounds23, %inbounds11
  %index21 = load i64, ptr %index_ptr20, align 4
  %element22 = getelementptr i64, ptr %vector_data17, i64 %index21
  %20 = add i64 %13, 1
  %21 = icmp ule i64 %20, %1
  br i1 %21, label %inbounds23, label %out_of_bounds24

loop_end19:                                       ; preds = %inbounds23
  %22 = add i64 %11, %12
  %23 = add i64 %22, 11
  %24 = icmp ule i64 %23, %1
  br i1 %24, label %inbounds29, label %out_of_bounds30

inbounds23:                                       ; preds = %loop_body18
  %start25 = getelementptr i64, ptr %2, i64 %13
  %value26 = load i64, ptr %start25, align 4
  %offset = add i64 %13, 1
  store i64 %value26, ptr %element22, align 4
  %next_index27 = add i64 %index21, 1
  store i64 %next_index27, ptr %index_ptr20, align 4
  %index_cond28 = icmp ult i64 %next_index27, %value8
  br i1 %index_cond28, label %loop_body18, label %loop_end19

out_of_bounds24:                                  ; preds = %loop_body18
  unreachable

inbounds29:                                       ; preds = %loop_end19
  %25 = call i64 @vector_new(i64 4)
  %heap_start31 = sub i64 %25, 4
  %heap_to_ptr32 = inttoptr i64 %heap_start31 to ptr
  %start33 = getelementptr i64, ptr %2, i64 %22
  %value34 = load i64, ptr %start33, align 4
  %element35 = getelementptr i64, ptr %heap_to_ptr32, i64 0
  store i64 %value34, ptr %element35, align 4
  %26 = add i64 %22, 1
  %start36 = getelementptr i64, ptr %2, i64 %26
  %value37 = load i64, ptr %start36, align 4
  %element38 = getelementptr i64, ptr %heap_to_ptr32, i64 1
  store i64 %value37, ptr %element38, align 4
  %27 = add i64 %26, 1
  %start39 = getelementptr i64, ptr %2, i64 %27
  %value40 = load i64, ptr %start39, align 4
  %element41 = getelementptr i64, ptr %heap_to_ptr32, i64 2
  store i64 %value40, ptr %element41, align 4
  %28 = add i64 %27, 1
  %start42 = getelementptr i64, ptr %2, i64 %28
  %value43 = load i64, ptr %start42, align 4
  %element44 = getelementptr i64, ptr %heap_to_ptr32, i64 3
  store i64 %value43, ptr %element44, align 4
  %29 = add i64 %28, 1
  %30 = add i64 %22, 4
  %31 = call i64 @vector_new(i64 4)
  %heap_start45 = sub i64 %31, 4
  %heap_to_ptr46 = inttoptr i64 %heap_start45 to ptr
  %start47 = getelementptr i64, ptr %2, i64 %30
  %value48 = load i64, ptr %start47, align 4
  %element49 = getelementptr i64, ptr %heap_to_ptr46, i64 0
  store i64 %value48, ptr %element49, align 4
  %32 = add i64 %30, 1
  %start50 = getelementptr i64, ptr %2, i64 %32
  %value51 = load i64, ptr %start50, align 4
  %element52 = getelementptr i64, ptr %heap_to_ptr46, i64 1
  store i64 %value51, ptr %element52, align 4
  %33 = add i64 %32, 1
  %start53 = getelementptr i64, ptr %2, i64 %33
  %value54 = load i64, ptr %start53, align 4
  %element55 = getelementptr i64, ptr %heap_to_ptr46, i64 2
  store i64 %value54, ptr %element55, align 4
  %34 = add i64 %33, 1
  %start56 = getelementptr i64, ptr %2, i64 %34
  %value57 = load i64, ptr %start56, align 4
  %element58 = getelementptr i64, ptr %heap_to_ptr46, i64 3
  store i64 %value57, ptr %element58, align 4
  %35 = add i64 %34, 1
  %36 = add i64 %30, 4
  %start59 = getelementptr i64, ptr %2, i64 %36
  %value60 = load i64, ptr %start59, align 4
  %37 = add i64 %36, 1
  %start61 = getelementptr i64, ptr %2, i64 %37
  %value62 = load i64, ptr %start61, align 4
  %38 = add i64 %37, 1
  %start63 = getelementptr i64, ptr %2, i64 %38
  %value64 = load i64, ptr %start63, align 4
  %39 = add i64 %38, 1
  %40 = icmp ult i64 %39, %1
  br i1 %40, label %not_all_bytes_read, label %buffer_read

out_of_bounds30:                                  ; preds = %loop_end19
  unreachable

not_all_bytes_read:                               ; preds = %inbounds29
  unreachable

buffer_read:                                      ; preds = %inbounds29
  call void @foo(ptr %heap_to_ptr, ptr %heap_to_ptr16, ptr %heap_to_ptr32, ptr %heap_to_ptr46, i64 %value60, i64 %value62, i64 %value64)
  ret void
}

define void @main() {
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
