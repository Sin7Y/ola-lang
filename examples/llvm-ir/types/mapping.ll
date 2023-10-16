; ModuleID = 'NonceHolder'
source_filename = "examples/source/types/mapping.ola"

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

define void @setNonce(ptr %0, i64 %1) {
entry:
  %index_alloca131 = alloca i64, align 8
  %index_alloca122 = alloca i64, align 8
  %index_alloca107 = alloca i64, align 8
  %index_alloca98 = alloca i64, align 8
  %index_alloca81 = alloca i64, align 8
  %index_alloca72 = alloca i64, align 8
  %index_alloca57 = alloca i64, align 8
  %index_alloca48 = alloca i64, align 8
  %index_alloca31 = alloca i64, align 8
  %index_alloca22 = alloca i64, align 8
  %index_alloca7 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %_nonce = alloca i64, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  store i64 %1, ptr %_nonce, align 4
  %2 = load ptr, ptr %_address, align 8
  %3 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %3, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %6, align 4
  %7 = call i64 @vector_new(i64 8)
  %heap_start1 = sub i64 %7, 8
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 4
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 %index_value
  %8 = load i64, ptr %index_access, align 4
  %9 = add i64 0, %index_value
  %index_access3 = getelementptr i64, ptr %heap_to_ptr2, i64 %9
  store i64 %8, ptr %index_access3, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %index_alloca7, align 4
  br label %cond4

cond4:                                            ; preds = %body5, %done
  %index_value8 = load i64, ptr %index_alloca7, align 4
  %loop_cond9 = icmp ult i64 %index_value8, 4
  br i1 %loop_cond9, label %body5, label %done6

body5:                                            ; preds = %cond4
  %index_access10 = getelementptr i64, ptr %2, i64 %index_value8
  %10 = load i64, ptr %index_access10, align 4
  %11 = add i64 4, %index_value8
  %index_access11 = getelementptr i64, ptr %heap_to_ptr2, i64 %11
  store i64 %10, ptr %index_access11, align 4
  %next_index12 = add i64 %index_value8, 1
  store i64 %next_index12, ptr %index_alloca7, align 4
  br label %cond4

done6:                                            ; preds = %cond4
  %12 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %12, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr14, i64 8)
  %13 = load i64, ptr %_nonce, align 4
  %14 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %14, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  store i64 %13, ptr %heap_to_ptr16, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr16, i64 1
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr16, i64 2
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  store i64 0, ptr %17, align 4
  %18 = call i64 @vector_new(i64 8)
  %heap_start17 = sub i64 %18, 8
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  store i64 0, ptr %index_alloca22, align 4
  br label %cond19

cond19:                                           ; preds = %body20, %done6
  %index_value23 = load i64, ptr %index_alloca22, align 4
  %loop_cond24 = icmp ult i64 %index_value23, 4
  br i1 %loop_cond24, label %body20, label %done21

body20:                                           ; preds = %cond19
  %index_access25 = getelementptr i64, ptr %heap_to_ptr14, i64 %index_value23
  %19 = load i64, ptr %index_access25, align 4
  %20 = add i64 0, %index_value23
  %index_access26 = getelementptr i64, ptr %heap_to_ptr18, i64 %20
  store i64 %19, ptr %index_access26, align 4
  %next_index27 = add i64 %index_value23, 1
  store i64 %next_index27, ptr %index_alloca22, align 4
  br label %cond19

done21:                                           ; preds = %cond19
  store i64 0, ptr %index_alloca31, align 4
  br label %cond28

cond28:                                           ; preds = %body29, %done21
  %index_value32 = load i64, ptr %index_alloca31, align 4
  %loop_cond33 = icmp ult i64 %index_value32, 4
  br i1 %loop_cond33, label %body29, label %done30

body29:                                           ; preds = %cond28
  %index_access34 = getelementptr i64, ptr %heap_to_ptr16, i64 %index_value32
  %21 = load i64, ptr %index_access34, align 4
  %22 = add i64 4, %index_value32
  %index_access35 = getelementptr i64, ptr %heap_to_ptr18, i64 %22
  store i64 %21, ptr %index_access35, align 4
  %next_index36 = add i64 %index_value32, 1
  store i64 %next_index36, ptr %index_alloca31, align 4
  br label %cond28

done30:                                           ; preds = %cond28
  %23 = call i64 @vector_new(i64 4)
  %heap_start37 = sub i64 %23, 4
  %heap_to_ptr38 = inttoptr i64 %heap_start37 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr18, ptr %heap_to_ptr38, i64 8)
  %24 = call i64 @vector_new(i64 4)
  %heap_start39 = sub i64 %24, 4
  %heap_to_ptr40 = inttoptr i64 %heap_start39 to ptr
  call void @get_storage(ptr %heap_to_ptr38, ptr %heap_to_ptr40)
  %storage_value = load i64, ptr %heap_to_ptr40, align 4
  %25 = icmp eq i64 %storage_value, 0
  %26 = zext i1 %25 to i64
  call void @builtin_assert(i64 %26)
  %27 = load ptr, ptr %_address, align 8
  %28 = call i64 @vector_new(i64 4)
  %heap_start41 = sub i64 %28, 4
  %heap_to_ptr42 = inttoptr i64 %heap_start41 to ptr
  store i64 0, ptr %heap_to_ptr42, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr42, i64 1
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr42, i64 2
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr42, i64 3
  store i64 0, ptr %31, align 4
  %32 = call i64 @vector_new(i64 8)
  %heap_start43 = sub i64 %32, 8
  %heap_to_ptr44 = inttoptr i64 %heap_start43 to ptr
  store i64 0, ptr %index_alloca48, align 4
  br label %cond45

cond45:                                           ; preds = %body46, %done30
  %index_value49 = load i64, ptr %index_alloca48, align 4
  %loop_cond50 = icmp ult i64 %index_value49, 4
  br i1 %loop_cond50, label %body46, label %done47

body46:                                           ; preds = %cond45
  %index_access51 = getelementptr i64, ptr %heap_to_ptr42, i64 %index_value49
  %33 = load i64, ptr %index_access51, align 4
  %34 = add i64 0, %index_value49
  %index_access52 = getelementptr i64, ptr %heap_to_ptr44, i64 %34
  store i64 %33, ptr %index_access52, align 4
  %next_index53 = add i64 %index_value49, 1
  store i64 %next_index53, ptr %index_alloca48, align 4
  br label %cond45

done47:                                           ; preds = %cond45
  store i64 0, ptr %index_alloca57, align 4
  br label %cond54

cond54:                                           ; preds = %body55, %done47
  %index_value58 = load i64, ptr %index_alloca57, align 4
  %loop_cond59 = icmp ult i64 %index_value58, 4
  br i1 %loop_cond59, label %body55, label %done56

body55:                                           ; preds = %cond54
  %index_access60 = getelementptr i64, ptr %27, i64 %index_value58
  %35 = load i64, ptr %index_access60, align 4
  %36 = add i64 4, %index_value58
  %index_access61 = getelementptr i64, ptr %heap_to_ptr44, i64 %36
  store i64 %35, ptr %index_access61, align 4
  %next_index62 = add i64 %index_value58, 1
  store i64 %next_index62, ptr %index_alloca57, align 4
  br label %cond54

done56:                                           ; preds = %cond54
  %37 = call i64 @vector_new(i64 4)
  %heap_start63 = sub i64 %37, 4
  %heap_to_ptr64 = inttoptr i64 %heap_start63 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr44, ptr %heap_to_ptr64, i64 8)
  %38 = load i64, ptr %_nonce, align 4
  %39 = call i64 @vector_new(i64 4)
  %heap_start65 = sub i64 %39, 4
  %heap_to_ptr66 = inttoptr i64 %heap_start65 to ptr
  store i64 %38, ptr %heap_to_ptr66, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr66, i64 1
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %heap_to_ptr66, i64 2
  store i64 0, ptr %41, align 4
  %42 = getelementptr i64, ptr %heap_to_ptr66, i64 3
  store i64 0, ptr %42, align 4
  %43 = call i64 @vector_new(i64 8)
  %heap_start67 = sub i64 %43, 8
  %heap_to_ptr68 = inttoptr i64 %heap_start67 to ptr
  store i64 0, ptr %index_alloca72, align 4
  br label %cond69

cond69:                                           ; preds = %body70, %done56
  %index_value73 = load i64, ptr %index_alloca72, align 4
  %loop_cond74 = icmp ult i64 %index_value73, 4
  br i1 %loop_cond74, label %body70, label %done71

body70:                                           ; preds = %cond69
  %index_access75 = getelementptr i64, ptr %heap_to_ptr64, i64 %index_value73
  %44 = load i64, ptr %index_access75, align 4
  %45 = add i64 0, %index_value73
  %index_access76 = getelementptr i64, ptr %heap_to_ptr68, i64 %45
  store i64 %44, ptr %index_access76, align 4
  %next_index77 = add i64 %index_value73, 1
  store i64 %next_index77, ptr %index_alloca72, align 4
  br label %cond69

done71:                                           ; preds = %cond69
  store i64 0, ptr %index_alloca81, align 4
  br label %cond78

cond78:                                           ; preds = %body79, %done71
  %index_value82 = load i64, ptr %index_alloca81, align 4
  %loop_cond83 = icmp ult i64 %index_value82, 4
  br i1 %loop_cond83, label %body79, label %done80

body79:                                           ; preds = %cond78
  %index_access84 = getelementptr i64, ptr %heap_to_ptr66, i64 %index_value82
  %46 = load i64, ptr %index_access84, align 4
  %47 = add i64 4, %index_value82
  %index_access85 = getelementptr i64, ptr %heap_to_ptr68, i64 %47
  store i64 %46, ptr %index_access85, align 4
  %next_index86 = add i64 %index_value82, 1
  store i64 %next_index86, ptr %index_alloca81, align 4
  br label %cond78

done80:                                           ; preds = %cond78
  %48 = call i64 @vector_new(i64 4)
  %heap_start87 = sub i64 %48, 4
  %heap_to_ptr88 = inttoptr i64 %heap_start87 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr68, ptr %heap_to_ptr88, i64 8)
  %49 = call i64 @vector_new(i64 4)
  %heap_start89 = sub i64 %49, 4
  %heap_to_ptr90 = inttoptr i64 %heap_start89 to ptr
  store i64 1, ptr %heap_to_ptr90, align 4
  %50 = getelementptr i64, ptr %heap_to_ptr90, i64 1
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %heap_to_ptr90, i64 2
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %heap_to_ptr90, i64 3
  store i64 0, ptr %52, align 4
  call void @set_storage(ptr %heap_to_ptr88, ptr %heap_to_ptr90)
  %53 = load ptr, ptr %_address, align 8
  %54 = call i64 @vector_new(i64 4)
  %heap_start91 = sub i64 %54, 4
  %heap_to_ptr92 = inttoptr i64 %heap_start91 to ptr
  store i64 0, ptr %heap_to_ptr92, align 4
  %55 = getelementptr i64, ptr %heap_to_ptr92, i64 1
  store i64 0, ptr %55, align 4
  %56 = getelementptr i64, ptr %heap_to_ptr92, i64 2
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %heap_to_ptr92, i64 3
  store i64 0, ptr %57, align 4
  %58 = call i64 @vector_new(i64 8)
  %heap_start93 = sub i64 %58, 8
  %heap_to_ptr94 = inttoptr i64 %heap_start93 to ptr
  store i64 0, ptr %index_alloca98, align 4
  br label %cond95

cond95:                                           ; preds = %body96, %done80
  %index_value99 = load i64, ptr %index_alloca98, align 4
  %loop_cond100 = icmp ult i64 %index_value99, 4
  br i1 %loop_cond100, label %body96, label %done97

body96:                                           ; preds = %cond95
  %index_access101 = getelementptr i64, ptr %heap_to_ptr92, i64 %index_value99
  %59 = load i64, ptr %index_access101, align 4
  %60 = add i64 0, %index_value99
  %index_access102 = getelementptr i64, ptr %heap_to_ptr94, i64 %60
  store i64 %59, ptr %index_access102, align 4
  %next_index103 = add i64 %index_value99, 1
  store i64 %next_index103, ptr %index_alloca98, align 4
  br label %cond95

done97:                                           ; preds = %cond95
  store i64 0, ptr %index_alloca107, align 4
  br label %cond104

cond104:                                          ; preds = %body105, %done97
  %index_value108 = load i64, ptr %index_alloca107, align 4
  %loop_cond109 = icmp ult i64 %index_value108, 4
  br i1 %loop_cond109, label %body105, label %done106

body105:                                          ; preds = %cond104
  %index_access110 = getelementptr i64, ptr %53, i64 %index_value108
  %61 = load i64, ptr %index_access110, align 4
  %62 = add i64 4, %index_value108
  %index_access111 = getelementptr i64, ptr %heap_to_ptr94, i64 %62
  store i64 %61, ptr %index_access111, align 4
  %next_index112 = add i64 %index_value108, 1
  store i64 %next_index112, ptr %index_alloca107, align 4
  br label %cond104

done106:                                          ; preds = %cond104
  %63 = call i64 @vector_new(i64 4)
  %heap_start113 = sub i64 %63, 4
  %heap_to_ptr114 = inttoptr i64 %heap_start113 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr94, ptr %heap_to_ptr114, i64 8)
  %64 = load i64, ptr %_nonce, align 4
  %65 = call i64 @vector_new(i64 4)
  %heap_start115 = sub i64 %65, 4
  %heap_to_ptr116 = inttoptr i64 %heap_start115 to ptr
  store i64 %64, ptr %heap_to_ptr116, align 4
  %66 = getelementptr i64, ptr %heap_to_ptr116, i64 1
  store i64 0, ptr %66, align 4
  %67 = getelementptr i64, ptr %heap_to_ptr116, i64 2
  store i64 0, ptr %67, align 4
  %68 = getelementptr i64, ptr %heap_to_ptr116, i64 3
  store i64 0, ptr %68, align 4
  %69 = call i64 @vector_new(i64 8)
  %heap_start117 = sub i64 %69, 8
  %heap_to_ptr118 = inttoptr i64 %heap_start117 to ptr
  store i64 0, ptr %index_alloca122, align 4
  br label %cond119

cond119:                                          ; preds = %body120, %done106
  %index_value123 = load i64, ptr %index_alloca122, align 4
  %loop_cond124 = icmp ult i64 %index_value123, 4
  br i1 %loop_cond124, label %body120, label %done121

body120:                                          ; preds = %cond119
  %index_access125 = getelementptr i64, ptr %heap_to_ptr114, i64 %index_value123
  %70 = load i64, ptr %index_access125, align 4
  %71 = add i64 0, %index_value123
  %index_access126 = getelementptr i64, ptr %heap_to_ptr118, i64 %71
  store i64 %70, ptr %index_access126, align 4
  %next_index127 = add i64 %index_value123, 1
  store i64 %next_index127, ptr %index_alloca122, align 4
  br label %cond119

done121:                                          ; preds = %cond119
  store i64 0, ptr %index_alloca131, align 4
  br label %cond128

cond128:                                          ; preds = %body129, %done121
  %index_value132 = load i64, ptr %index_alloca131, align 4
  %loop_cond133 = icmp ult i64 %index_value132, 4
  br i1 %loop_cond133, label %body129, label %done130

body129:                                          ; preds = %cond128
  %index_access134 = getelementptr i64, ptr %heap_to_ptr116, i64 %index_value132
  %72 = load i64, ptr %index_access134, align 4
  %73 = add i64 4, %index_value132
  %index_access135 = getelementptr i64, ptr %heap_to_ptr118, i64 %73
  store i64 %72, ptr %index_access135, align 4
  %next_index136 = add i64 %index_value132, 1
  store i64 %next_index136, ptr %index_alloca131, align 4
  br label %cond128

done130:                                          ; preds = %cond128
  %74 = call i64 @vector_new(i64 4)
  %heap_start137 = sub i64 %74, 4
  %heap_to_ptr138 = inttoptr i64 %heap_start137 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr118, ptr %heap_to_ptr138, i64 8)
  %75 = call i64 @vector_new(i64 4)
  %heap_start139 = sub i64 %75, 4
  %heap_to_ptr140 = inttoptr i64 %heap_start139 to ptr
  call void @get_storage(ptr %heap_to_ptr138, ptr %heap_to_ptr140)
  %storage_value141 = load i64, ptr %heap_to_ptr140, align 4
  call void @builtin_assert(i64 %storage_value141)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3694669121, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 5, %1
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
  %5 = icmp ult i64 5, %1
  br i1 %5, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @setNonce(ptr %heap_to_ptr, i64 %value11)
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
