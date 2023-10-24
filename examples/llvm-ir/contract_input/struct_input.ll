; ModuleID = 'MultInputExample'
source_filename = "examples/source/contract_input/struct_input.ola"

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

define void @foo(ptr %0) {
entry:
  %index51 = alloca i64, align 8
  %index29 = alloca i64, align 8
  %index = alloca i64, align 8
  %"struct member" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 0
  %1 = load ptr, ptr %"struct member", align 8
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 1, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 2, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 3, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 4, ptr %index_access3, align 4
  %left_elem_0 = getelementptr i64, ptr %1, i64 0
  %3 = load i64, ptr %left_elem_0, align 4
  %right_elem_0 = getelementptr i64, ptr %heap_to_ptr, i64 0
  %4 = load i64, ptr %right_elem_0, align 4
  %compare_0 = icmp eq i64 %3, %4
  %5 = zext i1 %compare_0 to i64
  %result_0 = and i64 %5, 1
  %left_elem_1 = getelementptr i64, ptr %1, i64 1
  %6 = load i64, ptr %left_elem_1, align 4
  %right_elem_1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  %7 = load i64, ptr %right_elem_1, align 4
  %compare_1 = icmp eq i64 %6, %7
  %8 = zext i1 %compare_1 to i64
  %result_1 = and i64 %8, %result_0
  %left_elem_2 = getelementptr i64, ptr %1, i64 2
  %9 = load i64, ptr %left_elem_2, align 4
  %right_elem_2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  %10 = load i64, ptr %right_elem_2, align 4
  %compare_2 = icmp eq i64 %9, %10
  %11 = zext i1 %compare_2 to i64
  %result_2 = and i64 %11, %result_1
  %left_elem_3 = getelementptr i64, ptr %1, i64 3
  %12 = load i64, ptr %left_elem_3, align 4
  %right_elem_3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  %13 = load i64, ptr %right_elem_3, align 4
  %compare_3 = icmp eq i64 %12, %13
  %14 = zext i1 %compare_3 to i64
  %result_3 = and i64 %14, %result_2
  call void @builtin_assert(i64 %result_3)
  %"struct member4" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 1
  %15 = load i64, ptr %"struct member4", align 4
  %16 = icmp eq i64 %15, 5
  %17 = zext i1 %16 to i64
  call void @builtin_assert(i64 %17)
  %"struct member5" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 2
  %18 = load i64, ptr %"struct member5", align 4
  %19 = icmp eq i64 %18, 6
  %20 = zext i1 %19 to i64
  call void @builtin_assert(i64 %20)
  %"struct member6" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 3
  %21 = load i64, ptr %"struct member6", align 4
  %22 = icmp eq i64 %21, 1
  %23 = zext i1 %22 to i64
  call void @builtin_assert(i64 %23)
  %"struct member7" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 4
  %24 = load ptr, ptr %"struct member7", align 8
  %25 = ptrtoint ptr %24 to i64
  %26 = add i64 %25, 1
  %vector_data = inttoptr i64 %26 to ptr
  %length = load i64, ptr %24, align 4
  %27 = call i64 @vector_new(i64 3)
  %heap_start8 = sub i64 %27, 3
  %heap_to_ptr9 = inttoptr i64 %heap_start8 to ptr
  store i64 2, ptr %heap_to_ptr9, align 4
  %28 = ptrtoint ptr %heap_to_ptr9 to i64
  %29 = add i64 %28, 1
  %vector_data10 = inttoptr i64 %29 to ptr
  %index_access11 = getelementptr i64, ptr %vector_data10, i64 0
  store i64 49, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %vector_data10, i64 1
  store i64 50, ptr %index_access12, align 4
  %30 = ptrtoint ptr %heap_to_ptr9 to i64
  %31 = add i64 %30, 1
  %vector_data13 = inttoptr i64 %31 to ptr
  %length14 = load i64, ptr %heap_to_ptr9, align 4
  %32 = icmp eq i64 %length, %length14
  %33 = zext i1 %32 to i64
  call void @builtin_assert(i64 %33)
  store i64 0, ptr %index, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index15 = load i64, ptr %index, align 4
  %34 = icmp ult i64 %index15, %length
  br i1 %34, label %body, label %done

body:                                             ; preds = %cond
  %left_char_ptr = getelementptr i64, ptr %vector_data, i64 %index15
  %right_char_ptr = getelementptr i64, ptr %vector_data13, i64 %index15
  %left_char = load i64, ptr %left_char_ptr, align 4
  %right_char = load i64, ptr %right_char_ptr, align 4
  %comparison = icmp eq i64 %left_char, %right_char
  %next_index = add i64 %index15, 1
  store i64 %next_index, ptr %index, align 4
  br i1 %comparison, label %cond, label %done

done:                                             ; preds = %body, %cond
  %equal = icmp eq i64 %index15, %length14
  %35 = zext i1 %equal to i64
  call void @builtin_assert(i64 %35)
  %"struct member16" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 5
  %36 = load ptr, ptr %"struct member16", align 8
  %37 = ptrtoint ptr %36 to i64
  %38 = add i64 %37, 1
  %vector_data17 = inttoptr i64 %38 to ptr
  %length18 = load i64, ptr %36, align 4
  %39 = call i64 @vector_new(i64 3)
  %heap_start19 = sub i64 %39, 3
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 2, ptr %heap_to_ptr20, align 4
  %40 = ptrtoint ptr %heap_to_ptr20 to i64
  %41 = add i64 %40, 1
  %vector_data21 = inttoptr i64 %41 to ptr
  %index_access22 = getelementptr i64, ptr %vector_data21, i64 0
  store i64 51, ptr %index_access22, align 4
  %index_access23 = getelementptr i64, ptr %vector_data21, i64 1
  store i64 52, ptr %index_access23, align 4
  %42 = ptrtoint ptr %heap_to_ptr20 to i64
  %43 = add i64 %42, 1
  %vector_data24 = inttoptr i64 %43 to ptr
  %length25 = load i64, ptr %heap_to_ptr20, align 4
  %44 = icmp eq i64 %length18, %length25
  %45 = zext i1 %44 to i64
  call void @builtin_assert(i64 %45)
  store i64 0, ptr %index29, align 4
  br label %cond26

cond26:                                           ; preds = %body27, %done
  %index30 = load i64, ptr %index29, align 4
  %46 = icmp ult i64 %index30, %length18
  br i1 %46, label %body27, label %done28

body27:                                           ; preds = %cond26
  %left_char_ptr31 = getelementptr i64, ptr %vector_data17, i64 %index30
  %right_char_ptr32 = getelementptr i64, ptr %vector_data24, i64 %index30
  %left_char33 = load i64, ptr %left_char_ptr31, align 4
  %right_char34 = load i64, ptr %right_char_ptr32, align 4
  %comparison35 = icmp eq i64 %left_char33, %right_char34
  %next_index36 = add i64 %index30, 1
  store i64 %next_index36, ptr %index29, align 4
  br i1 %comparison35, label %cond26, label %done28

done28:                                           ; preds = %body27, %cond26
  %equal37 = icmp eq i64 %index30, %length25
  %47 = zext i1 %equal37 to i64
  call void @builtin_assert(i64 %47)
  %"struct member38" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 6
  %48 = load ptr, ptr %"struct member38", align 8
  %49 = ptrtoint ptr %48 to i64
  %50 = add i64 %49, 1
  %vector_data39 = inttoptr i64 %50 to ptr
  %length40 = load i64, ptr %48, align 4
  %51 = call i64 @vector_new(i64 3)
  %heap_start41 = sub i64 %51, 3
  %heap_to_ptr42 = inttoptr i64 %heap_start41 to ptr
  store i64 2, ptr %heap_to_ptr42, align 4
  %52 = ptrtoint ptr %heap_to_ptr42 to i64
  %53 = add i64 %52, 1
  %vector_data43 = inttoptr i64 %53 to ptr
  %index_access44 = getelementptr i64, ptr %vector_data43, i64 0
  store i64 53, ptr %index_access44, align 4
  %index_access45 = getelementptr i64, ptr %vector_data43, i64 1
  store i64 54, ptr %index_access45, align 4
  %54 = ptrtoint ptr %heap_to_ptr42 to i64
  %55 = add i64 %54, 1
  %vector_data46 = inttoptr i64 %55 to ptr
  %length47 = load i64, ptr %heap_to_ptr42, align 4
  %56 = icmp eq i64 %length40, %length47
  %57 = zext i1 %56 to i64
  call void @builtin_assert(i64 %57)
  store i64 0, ptr %index51, align 4
  br label %cond48

cond48:                                           ; preds = %body49, %done28
  %index52 = load i64, ptr %index51, align 4
  %58 = icmp ult i64 %index52, %length40
  br i1 %58, label %body49, label %done50

body49:                                           ; preds = %cond48
  %left_char_ptr53 = getelementptr i64, ptr %vector_data39, i64 %index52
  %right_char_ptr54 = getelementptr i64, ptr %vector_data46, i64 %index52
  %left_char55 = load i64, ptr %left_char_ptr53, align 4
  %right_char56 = load i64, ptr %right_char_ptr54, align 4
  %comparison57 = icmp eq i64 %left_char55, %right_char56
  %next_index58 = add i64 %index52, 1
  store i64 %next_index58, ptr %index51, align 4
  br i1 %comparison57, label %cond48, label %done50

done50:                                           ; preds = %body49, %cond48
  %equal59 = icmp eq i64 %index52, %length47
  %59 = zext i1 %equal59 to i64
  call void @builtin_assert(i64 %59)
  %"struct member60" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %0, i32 0, i32 7
  %60 = load ptr, ptr %"struct member60", align 8
  %61 = call i64 @vector_new(i64 4)
  %heap_start61 = sub i64 %61, 4
  %heap_to_ptr62 = inttoptr i64 %heap_start61 to ptr
  %index_access63 = getelementptr i64, ptr %heap_to_ptr62, i64 0
  store i64 6, ptr %index_access63, align 4
  %index_access64 = getelementptr i64, ptr %heap_to_ptr62, i64 1
  store i64 7, ptr %index_access64, align 4
  %index_access65 = getelementptr i64, ptr %heap_to_ptr62, i64 2
  store i64 8, ptr %index_access65, align 4
  %index_access66 = getelementptr i64, ptr %heap_to_ptr62, i64 3
  store i64 9, ptr %index_access66, align 4
  %left_elem_067 = getelementptr i64, ptr %60, i64 0
  %62 = load i64, ptr %left_elem_067, align 4
  %right_elem_068 = getelementptr i64, ptr %heap_to_ptr62, i64 0
  %63 = load i64, ptr %right_elem_068, align 4
  %compare_069 = icmp eq i64 %62, %63
  %64 = zext i1 %compare_069 to i64
  %result_070 = and i64 %64, 1
  %left_elem_171 = getelementptr i64, ptr %60, i64 1
  %65 = load i64, ptr %left_elem_171, align 4
  %right_elem_172 = getelementptr i64, ptr %heap_to_ptr62, i64 1
  %66 = load i64, ptr %right_elem_172, align 4
  %compare_173 = icmp eq i64 %65, %66
  %67 = zext i1 %compare_173 to i64
  %result_174 = and i64 %67, %result_070
  %left_elem_275 = getelementptr i64, ptr %60, i64 2
  %68 = load i64, ptr %left_elem_275, align 4
  %right_elem_276 = getelementptr i64, ptr %heap_to_ptr62, i64 2
  %69 = load i64, ptr %right_elem_276, align 4
  %compare_277 = icmp eq i64 %68, %69
  %70 = zext i1 %compare_277 to i64
  %result_278 = and i64 %70, %result_174
  %left_elem_379 = getelementptr i64, ptr %60, i64 3
  %71 = load i64, ptr %left_elem_379, align 4
  %right_elem_380 = getelementptr i64, ptr %heap_to_ptr62, i64 3
  %72 = load i64, ptr %right_elem_380, align 4
  %compare_381 = icmp eq i64 %71, %72
  %73 = zext i1 %compare_381 to i64
  %result_382 = and i64 %73, %result_278
  call void @builtin_assert(i64 %result_382)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %struct_alloca = alloca { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, align 8
  %offset_ptr68 = alloca i64, align 8
  %index_ptr67 = alloca i64, align 8
  %offset_ptr43 = alloca i64, align 8
  %index_ptr42 = alloca i64, align 8
  %offset_ptr = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 3469705383, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 7, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %4 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %4, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %element = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %value, ptr %element, align 4
  %start1 = getelementptr i64, ptr %2, i64 1
  %value2 = load i64, ptr %start1, align 4
  %element3 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %value2, ptr %element3, align 4
  %start4 = getelementptr i64, ptr %2, i64 2
  %value5 = load i64, ptr %start4, align 4
  %element6 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %value5, ptr %element6, align 4
  %start7 = getelementptr i64, ptr %2, i64 3
  %value8 = load i64, ptr %start7, align 4
  %element9 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %value8, ptr %element9, align 4
  %start10 = getelementptr i64, ptr %2, i64 4
  %value11 = load i64, ptr %start10, align 4
  %start12 = getelementptr i64, ptr %2, i64 5
  %value13 = load i64, ptr %start12, align 4
  %start14 = getelementptr i64, ptr %2, i64 6
  %value15 = load i64, ptr %start14, align 4
  %start16 = getelementptr i64, ptr %2, i64 7
  %value17 = load i64, ptr %start16, align 4
  %5 = add i64 1, %value17
  %6 = icmp ule i64 8, %1
  br i1 %6, label %inbounds18, label %out_of_bounds19

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

inbounds18:                                       ; preds = %inbounds
  %7 = add i64 7, %5
  %8 = icmp ule i64 %7, %1
  br i1 %8, label %inbounds20, label %out_of_bounds21

out_of_bounds19:                                  ; preds = %inbounds
  unreachable

inbounds20:                                       ; preds = %inbounds18
  %size = mul i64 %value17, 1
  %size_add_one = add i64 %size, 1
  %9 = call i64 @vector_new(i64 %size_add_one)
  %heap_start22 = sub i64 %9, %size_add_one
  %heap_to_ptr23 = inttoptr i64 %heap_start22 to ptr
  store i64 %size, ptr %heap_to_ptr23, align 4
  %10 = ptrtoint ptr %heap_to_ptr23 to i64
  %11 = add i64 %10, 1
  %vector_data = inttoptr i64 %11 to ptr
  store i64 0, ptr %index_ptr, align 4
  store i64 8, ptr %offset_ptr, align 4
  br label %loop_body

out_of_bounds21:                                  ; preds = %inbounds18
  unreachable

loop_body:                                        ; preds = %inbounds25, %inbounds20
  %index = load i64, ptr %index_ptr, align 4
  %element24 = getelementptr i64, ptr %vector_data, i64 %index
  %offset = load i64, ptr %offset_ptr, align 4
  %12 = add i64 %offset, 1
  %13 = icmp ule i64 %12, %1
  br i1 %13, label %inbounds25, label %out_of_bounds26

loop_end:                                         ; preds = %inbounds25
  %14 = add i64 7, %5
  %15 = add i64 7, %5
  %start29 = getelementptr i64, ptr %2, i64 %15
  %value30 = load i64, ptr %start29, align 4
  %16 = add i64 1, %value30
  %17 = add i64 %15, 1
  %18 = icmp ule i64 %17, %1
  br i1 %18, label %inbounds31, label %out_of_bounds32

inbounds25:                                       ; preds = %loop_body
  %start27 = getelementptr i64, ptr %2, i64 %offset
  %value28 = load i64, ptr %start27, align 4
  %next_offset = add i64 %offset, 1
  store i64 %next_offset, ptr %offset_ptr, align 4
  store i64 %value28, ptr %element24, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %value17
  br i1 %index_cond, label %loop_body, label %loop_end

out_of_bounds26:                                  ; preds = %loop_body
  unreachable

inbounds31:                                       ; preds = %loop_end
  %19 = add i64 %15, %16
  %20 = icmp ule i64 %19, %1
  br i1 %20, label %inbounds33, label %out_of_bounds34

out_of_bounds32:                                  ; preds = %loop_end
  unreachable

inbounds33:                                       ; preds = %inbounds31
  %size35 = mul i64 %value30, 1
  %size_add_one36 = add i64 %size35, 1
  %21 = call i64 @vector_new(i64 %size_add_one36)
  %heap_start37 = sub i64 %21, %size_add_one36
  %heap_to_ptr38 = inttoptr i64 %heap_start37 to ptr
  store i64 %size35, ptr %heap_to_ptr38, align 4
  %22 = ptrtoint ptr %heap_to_ptr38 to i64
  %23 = add i64 %22, 1
  %vector_data39 = inttoptr i64 %23 to ptr
  store i64 0, ptr %index_ptr42, align 4
  store i64 %17, ptr %offset_ptr43, align 4
  br label %loop_body40

out_of_bounds34:                                  ; preds = %inbounds31
  unreachable

loop_body40:                                      ; preds = %inbounds47, %inbounds33
  %index44 = load i64, ptr %index_ptr42, align 4
  %element45 = getelementptr i64, ptr %vector_data39, i64 %index44
  %offset46 = load i64, ptr %offset_ptr43, align 4
  %24 = add i64 %offset46, 1
  %25 = icmp ule i64 %24, %1
  br i1 %25, label %inbounds47, label %out_of_bounds48

loop_end41:                                       ; preds = %inbounds47
  %26 = add i64 %14, %16
  %27 = add i64 %15, %16
  %start54 = getelementptr i64, ptr %2, i64 %27
  %value55 = load i64, ptr %start54, align 4
  %28 = add i64 1, %value55
  %29 = add i64 %27, 1
  %30 = icmp ule i64 %29, %1
  br i1 %30, label %inbounds56, label %out_of_bounds57

inbounds47:                                       ; preds = %loop_body40
  %start49 = getelementptr i64, ptr %2, i64 %offset46
  %value50 = load i64, ptr %start49, align 4
  %next_offset51 = add i64 %offset46, 1
  store i64 %next_offset51, ptr %offset_ptr43, align 4
  store i64 %value50, ptr %element45, align 4
  %next_index52 = add i64 %index44, 1
  store i64 %next_index52, ptr %index_ptr42, align 4
  %index_cond53 = icmp ult i64 %next_index52, %value30
  br i1 %index_cond53, label %loop_body40, label %loop_end41

out_of_bounds48:                                  ; preds = %loop_body40
  unreachable

inbounds56:                                       ; preds = %loop_end41
  %31 = add i64 %27, %28
  %32 = icmp ule i64 %31, %1
  br i1 %32, label %inbounds58, label %out_of_bounds59

out_of_bounds57:                                  ; preds = %loop_end41
  unreachable

inbounds58:                                       ; preds = %inbounds56
  %size60 = mul i64 %value55, 1
  %size_add_one61 = add i64 %size60, 1
  %33 = call i64 @vector_new(i64 %size_add_one61)
  %heap_start62 = sub i64 %33, %size_add_one61
  %heap_to_ptr63 = inttoptr i64 %heap_start62 to ptr
  store i64 %size60, ptr %heap_to_ptr63, align 4
  %34 = ptrtoint ptr %heap_to_ptr63 to i64
  %35 = add i64 %34, 1
  %vector_data64 = inttoptr i64 %35 to ptr
  store i64 0, ptr %index_ptr67, align 4
  store i64 %29, ptr %offset_ptr68, align 4
  br label %loop_body65

out_of_bounds59:                                  ; preds = %inbounds56
  unreachable

loop_body65:                                      ; preds = %inbounds72, %inbounds58
  %index69 = load i64, ptr %index_ptr67, align 4
  %element70 = getelementptr i64, ptr %vector_data64, i64 %index69
  %offset71 = load i64, ptr %offset_ptr68, align 4
  %36 = add i64 %offset71, 1
  %37 = icmp ule i64 %36, %1
  br i1 %37, label %inbounds72, label %out_of_bounds73

loop_end66:                                       ; preds = %inbounds72
  %38 = add i64 %26, %28
  %39 = add i64 %27, %28
  %40 = add i64 %39, 4
  %41 = icmp ule i64 %40, %1
  br i1 %41, label %inbounds79, label %out_of_bounds80

inbounds72:                                       ; preds = %loop_body65
  %start74 = getelementptr i64, ptr %2, i64 %offset71
  %value75 = load i64, ptr %start74, align 4
  %next_offset76 = add i64 %offset71, 1
  store i64 %next_offset76, ptr %offset_ptr68, align 4
  store i64 %value75, ptr %element70, align 4
  %next_index77 = add i64 %index69, 1
  store i64 %next_index77, ptr %index_ptr67, align 4
  %index_cond78 = icmp ult i64 %next_index77, %value55
  br i1 %index_cond78, label %loop_body65, label %loop_end66

out_of_bounds73:                                  ; preds = %loop_body65
  unreachable

inbounds79:                                       ; preds = %loop_end66
  %42 = call i64 @vector_new(i64 4)
  %heap_start81 = sub i64 %42, 4
  %heap_to_ptr82 = inttoptr i64 %heap_start81 to ptr
  %start83 = getelementptr i64, ptr %2, i64 %39
  %value84 = load i64, ptr %start83, align 4
  %element85 = getelementptr i64, ptr %heap_to_ptr82, i64 0
  store i64 %value84, ptr %element85, align 4
  %43 = add i64 %39, 1
  %start86 = getelementptr i64, ptr %2, i64 %43
  %value87 = load i64, ptr %start86, align 4
  %element88 = getelementptr i64, ptr %heap_to_ptr82, i64 1
  store i64 %value87, ptr %element88, align 4
  %44 = add i64 %43, 1
  %start89 = getelementptr i64, ptr %2, i64 %44
  %value90 = load i64, ptr %start89, align 4
  %element91 = getelementptr i64, ptr %heap_to_ptr82, i64 2
  store i64 %value90, ptr %element91, align 4
  %45 = add i64 %44, 1
  %start92 = getelementptr i64, ptr %2, i64 %45
  %value93 = load i64, ptr %start92, align 4
  %element94 = getelementptr i64, ptr %heap_to_ptr82, i64 3
  store i64 %value93, ptr %element94, align 4
  %46 = add i64 %45, 1
  %47 = add i64 %38, 4
  %"struct member" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %struct_alloca, i32 0, i32 0
  store ptr %heap_to_ptr, ptr %"struct member", align 8
  %"struct member95" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %struct_alloca, i32 0, i32 1
  store i64 %value11, ptr %"struct member95", align 4
  %"struct member96" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %struct_alloca, i32 0, i32 2
  store i64 %value13, ptr %"struct member96", align 4
  %"struct member97" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %struct_alloca, i32 0, i32 3
  store i64 %value15, ptr %"struct member97", align 4
  %"struct member98" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %struct_alloca, i32 0, i32 4
  store ptr %heap_to_ptr23, ptr %"struct member98", align 8
  %"struct member99" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %struct_alloca, i32 0, i32 5
  store ptr %heap_to_ptr38, ptr %"struct member99", align 8
  %"struct member100" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %struct_alloca, i32 0, i32 6
  store ptr %heap_to_ptr63, ptr %"struct member100", align 8
  %"struct member101" = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %struct_alloca, i32 0, i32 7
  store ptr %heap_to_ptr82, ptr %"struct member101", align 8
  %48 = add i64 0, %47
  %49 = icmp ult i64 %48, %1
  br i1 %49, label %not_all_bytes_read, label %buffer_read

out_of_bounds80:                                  ; preds = %loop_end66
  unreachable

not_all_bytes_read:                               ; preds = %inbounds79
  unreachable

buffer_read:                                      ; preds = %inbounds79
  call void @foo(ptr %struct_alloca)
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
