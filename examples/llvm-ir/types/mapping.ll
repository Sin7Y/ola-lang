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
  %index_alloca130 = alloca i64, align 8
  %index_alloca121 = alloca i64, align 8
  %index_alloca106 = alloca i64, align 8
  %index_alloca97 = alloca i64, align 8
  %index_alloca80 = alloca i64, align 8
  %index_alloca71 = alloca i64, align 8
  %index_alloca56 = alloca i64, align 8
  %index_alloca47 = alloca i64, align 8
  %index_alloca30 = alloca i64, align 8
  %index_alloca21 = alloca i64, align 8
  %index_alloca6 = alloca i64, align 8
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
  %8 = add i64 0, %index_value
  %src_index_access = getelementptr i64, ptr %heap_to_ptr, i64 %8
  %9 = load i64, ptr %src_index_access, align 4
  %10 = add i64 0, %index_value
  %dest_index_access = getelementptr i64, ptr %heap_to_ptr2, i64 %10
  store i64 %9, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %index_alloca6, align 4
  br label %cond3

cond3:                                            ; preds = %body4, %done
  %index_value7 = load i64, ptr %index_alloca6, align 4
  %loop_cond8 = icmp ult i64 %index_value7, 4
  br i1 %loop_cond8, label %body4, label %done5

body4:                                            ; preds = %cond3
  %11 = add i64 0, %index_value7
  %src_index_access9 = getelementptr i64, ptr %2, i64 %11
  %12 = load i64, ptr %src_index_access9, align 4
  %13 = add i64 4, %index_value7
  %dest_index_access10 = getelementptr i64, ptr %heap_to_ptr2, i64 %13
  store i64 %12, ptr %dest_index_access10, align 4
  %next_index11 = add i64 %index_value7, 1
  store i64 %next_index11, ptr %index_alloca6, align 4
  br label %cond3

done5:                                            ; preds = %cond3
  %14 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %14, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr13, i64 8)
  %15 = load i64, ptr %_nonce, align 4
  %16 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %16, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 %15, ptr %heap_to_ptr15, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr15, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr15, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr15, i64 3
  store i64 0, ptr %19, align 4
  %20 = call i64 @vector_new(i64 8)
  %heap_start16 = sub i64 %20, 8
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  store i64 0, ptr %index_alloca21, align 4
  br label %cond18

cond18:                                           ; preds = %body19, %done5
  %index_value22 = load i64, ptr %index_alloca21, align 4
  %loop_cond23 = icmp ult i64 %index_value22, 4
  br i1 %loop_cond23, label %body19, label %done20

body19:                                           ; preds = %cond18
  %21 = add i64 0, %index_value22
  %src_index_access24 = getelementptr i64, ptr %heap_to_ptr13, i64 %21
  %22 = load i64, ptr %src_index_access24, align 4
  %23 = add i64 0, %index_value22
  %dest_index_access25 = getelementptr i64, ptr %heap_to_ptr17, i64 %23
  store i64 %22, ptr %dest_index_access25, align 4
  %next_index26 = add i64 %index_value22, 1
  store i64 %next_index26, ptr %index_alloca21, align 4
  br label %cond18

done20:                                           ; preds = %cond18
  store i64 0, ptr %index_alloca30, align 4
  br label %cond27

cond27:                                           ; preds = %body28, %done20
  %index_value31 = load i64, ptr %index_alloca30, align 4
  %loop_cond32 = icmp ult i64 %index_value31, 4
  br i1 %loop_cond32, label %body28, label %done29

body28:                                           ; preds = %cond27
  %24 = add i64 0, %index_value31
  %src_index_access33 = getelementptr i64, ptr %heap_to_ptr15, i64 %24
  %25 = load i64, ptr %src_index_access33, align 4
  %26 = add i64 4, %index_value31
  %dest_index_access34 = getelementptr i64, ptr %heap_to_ptr17, i64 %26
  store i64 %25, ptr %dest_index_access34, align 4
  %next_index35 = add i64 %index_value31, 1
  store i64 %next_index35, ptr %index_alloca30, align 4
  br label %cond27

done29:                                           ; preds = %cond27
  %27 = call i64 @vector_new(i64 4)
  %heap_start36 = sub i64 %27, 4
  %heap_to_ptr37 = inttoptr i64 %heap_start36 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr17, ptr %heap_to_ptr37, i64 8)
  %28 = call i64 @vector_new(i64 4)
  %heap_start38 = sub i64 %28, 4
  %heap_to_ptr39 = inttoptr i64 %heap_start38 to ptr
  call void @get_storage(ptr %heap_to_ptr37, ptr %heap_to_ptr39)
  %storage_value = load i64, ptr %heap_to_ptr39, align 4
  %29 = icmp eq i64 %storage_value, 0
  %30 = zext i1 %29 to i64
  call void @builtin_assert(i64 %30)
  %31 = load ptr, ptr %_address, align 8
  %32 = call i64 @vector_new(i64 4)
  %heap_start40 = sub i64 %32, 4
  %heap_to_ptr41 = inttoptr i64 %heap_start40 to ptr
  store i64 0, ptr %heap_to_ptr41, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr41, i64 1
  store i64 0, ptr %33, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr41, i64 2
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr41, i64 3
  store i64 0, ptr %35, align 4
  %36 = call i64 @vector_new(i64 8)
  %heap_start42 = sub i64 %36, 8
  %heap_to_ptr43 = inttoptr i64 %heap_start42 to ptr
  store i64 0, ptr %index_alloca47, align 4
  br label %cond44

cond44:                                           ; preds = %body45, %done29
  %index_value48 = load i64, ptr %index_alloca47, align 4
  %loop_cond49 = icmp ult i64 %index_value48, 4
  br i1 %loop_cond49, label %body45, label %done46

body45:                                           ; preds = %cond44
  %37 = add i64 0, %index_value48
  %src_index_access50 = getelementptr i64, ptr %heap_to_ptr41, i64 %37
  %38 = load i64, ptr %src_index_access50, align 4
  %39 = add i64 0, %index_value48
  %dest_index_access51 = getelementptr i64, ptr %heap_to_ptr43, i64 %39
  store i64 %38, ptr %dest_index_access51, align 4
  %next_index52 = add i64 %index_value48, 1
  store i64 %next_index52, ptr %index_alloca47, align 4
  br label %cond44

done46:                                           ; preds = %cond44
  store i64 0, ptr %index_alloca56, align 4
  br label %cond53

cond53:                                           ; preds = %body54, %done46
  %index_value57 = load i64, ptr %index_alloca56, align 4
  %loop_cond58 = icmp ult i64 %index_value57, 4
  br i1 %loop_cond58, label %body54, label %done55

body54:                                           ; preds = %cond53
  %40 = add i64 0, %index_value57
  %src_index_access59 = getelementptr i64, ptr %31, i64 %40
  %41 = load i64, ptr %src_index_access59, align 4
  %42 = add i64 4, %index_value57
  %dest_index_access60 = getelementptr i64, ptr %heap_to_ptr43, i64 %42
  store i64 %41, ptr %dest_index_access60, align 4
  %next_index61 = add i64 %index_value57, 1
  store i64 %next_index61, ptr %index_alloca56, align 4
  br label %cond53

done55:                                           ; preds = %cond53
  %43 = call i64 @vector_new(i64 4)
  %heap_start62 = sub i64 %43, 4
  %heap_to_ptr63 = inttoptr i64 %heap_start62 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr43, ptr %heap_to_ptr63, i64 8)
  %44 = load i64, ptr %_nonce, align 4
  %45 = call i64 @vector_new(i64 4)
  %heap_start64 = sub i64 %45, 4
  %heap_to_ptr65 = inttoptr i64 %heap_start64 to ptr
  store i64 %44, ptr %heap_to_ptr65, align 4
  %46 = getelementptr i64, ptr %heap_to_ptr65, i64 1
  store i64 0, ptr %46, align 4
  %47 = getelementptr i64, ptr %heap_to_ptr65, i64 2
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %heap_to_ptr65, i64 3
  store i64 0, ptr %48, align 4
  %49 = call i64 @vector_new(i64 8)
  %heap_start66 = sub i64 %49, 8
  %heap_to_ptr67 = inttoptr i64 %heap_start66 to ptr
  store i64 0, ptr %index_alloca71, align 4
  br label %cond68

cond68:                                           ; preds = %body69, %done55
  %index_value72 = load i64, ptr %index_alloca71, align 4
  %loop_cond73 = icmp ult i64 %index_value72, 4
  br i1 %loop_cond73, label %body69, label %done70

body69:                                           ; preds = %cond68
  %50 = add i64 0, %index_value72
  %src_index_access74 = getelementptr i64, ptr %heap_to_ptr63, i64 %50
  %51 = load i64, ptr %src_index_access74, align 4
  %52 = add i64 0, %index_value72
  %dest_index_access75 = getelementptr i64, ptr %heap_to_ptr67, i64 %52
  store i64 %51, ptr %dest_index_access75, align 4
  %next_index76 = add i64 %index_value72, 1
  store i64 %next_index76, ptr %index_alloca71, align 4
  br label %cond68

done70:                                           ; preds = %cond68
  store i64 0, ptr %index_alloca80, align 4
  br label %cond77

cond77:                                           ; preds = %body78, %done70
  %index_value81 = load i64, ptr %index_alloca80, align 4
  %loop_cond82 = icmp ult i64 %index_value81, 4
  br i1 %loop_cond82, label %body78, label %done79

body78:                                           ; preds = %cond77
  %53 = add i64 0, %index_value81
  %src_index_access83 = getelementptr i64, ptr %heap_to_ptr65, i64 %53
  %54 = load i64, ptr %src_index_access83, align 4
  %55 = add i64 4, %index_value81
  %dest_index_access84 = getelementptr i64, ptr %heap_to_ptr67, i64 %55
  store i64 %54, ptr %dest_index_access84, align 4
  %next_index85 = add i64 %index_value81, 1
  store i64 %next_index85, ptr %index_alloca80, align 4
  br label %cond77

done79:                                           ; preds = %cond77
  %56 = call i64 @vector_new(i64 4)
  %heap_start86 = sub i64 %56, 4
  %heap_to_ptr87 = inttoptr i64 %heap_start86 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr67, ptr %heap_to_ptr87, i64 8)
  %57 = call i64 @vector_new(i64 4)
  %heap_start88 = sub i64 %57, 4
  %heap_to_ptr89 = inttoptr i64 %heap_start88 to ptr
  store i64 1, ptr %heap_to_ptr89, align 4
  %58 = getelementptr i64, ptr %heap_to_ptr89, i64 1
  store i64 0, ptr %58, align 4
  %59 = getelementptr i64, ptr %heap_to_ptr89, i64 2
  store i64 0, ptr %59, align 4
  %60 = getelementptr i64, ptr %heap_to_ptr89, i64 3
  store i64 0, ptr %60, align 4
  call void @set_storage(ptr %heap_to_ptr87, ptr %heap_to_ptr89)
  %61 = load ptr, ptr %_address, align 8
  %62 = call i64 @vector_new(i64 4)
  %heap_start90 = sub i64 %62, 4
  %heap_to_ptr91 = inttoptr i64 %heap_start90 to ptr
  store i64 0, ptr %heap_to_ptr91, align 4
  %63 = getelementptr i64, ptr %heap_to_ptr91, i64 1
  store i64 0, ptr %63, align 4
  %64 = getelementptr i64, ptr %heap_to_ptr91, i64 2
  store i64 0, ptr %64, align 4
  %65 = getelementptr i64, ptr %heap_to_ptr91, i64 3
  store i64 0, ptr %65, align 4
  %66 = call i64 @vector_new(i64 8)
  %heap_start92 = sub i64 %66, 8
  %heap_to_ptr93 = inttoptr i64 %heap_start92 to ptr
  store i64 0, ptr %index_alloca97, align 4
  br label %cond94

cond94:                                           ; preds = %body95, %done79
  %index_value98 = load i64, ptr %index_alloca97, align 4
  %loop_cond99 = icmp ult i64 %index_value98, 4
  br i1 %loop_cond99, label %body95, label %done96

body95:                                           ; preds = %cond94
  %67 = add i64 0, %index_value98
  %src_index_access100 = getelementptr i64, ptr %heap_to_ptr91, i64 %67
  %68 = load i64, ptr %src_index_access100, align 4
  %69 = add i64 0, %index_value98
  %dest_index_access101 = getelementptr i64, ptr %heap_to_ptr93, i64 %69
  store i64 %68, ptr %dest_index_access101, align 4
  %next_index102 = add i64 %index_value98, 1
  store i64 %next_index102, ptr %index_alloca97, align 4
  br label %cond94

done96:                                           ; preds = %cond94
  store i64 0, ptr %index_alloca106, align 4
  br label %cond103

cond103:                                          ; preds = %body104, %done96
  %index_value107 = load i64, ptr %index_alloca106, align 4
  %loop_cond108 = icmp ult i64 %index_value107, 4
  br i1 %loop_cond108, label %body104, label %done105

body104:                                          ; preds = %cond103
  %70 = add i64 0, %index_value107
  %src_index_access109 = getelementptr i64, ptr %61, i64 %70
  %71 = load i64, ptr %src_index_access109, align 4
  %72 = add i64 4, %index_value107
  %dest_index_access110 = getelementptr i64, ptr %heap_to_ptr93, i64 %72
  store i64 %71, ptr %dest_index_access110, align 4
  %next_index111 = add i64 %index_value107, 1
  store i64 %next_index111, ptr %index_alloca106, align 4
  br label %cond103

done105:                                          ; preds = %cond103
  %73 = call i64 @vector_new(i64 4)
  %heap_start112 = sub i64 %73, 4
  %heap_to_ptr113 = inttoptr i64 %heap_start112 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr93, ptr %heap_to_ptr113, i64 8)
  %74 = load i64, ptr %_nonce, align 4
  %75 = call i64 @vector_new(i64 4)
  %heap_start114 = sub i64 %75, 4
  %heap_to_ptr115 = inttoptr i64 %heap_start114 to ptr
  store i64 %74, ptr %heap_to_ptr115, align 4
  %76 = getelementptr i64, ptr %heap_to_ptr115, i64 1
  store i64 0, ptr %76, align 4
  %77 = getelementptr i64, ptr %heap_to_ptr115, i64 2
  store i64 0, ptr %77, align 4
  %78 = getelementptr i64, ptr %heap_to_ptr115, i64 3
  store i64 0, ptr %78, align 4
  %79 = call i64 @vector_new(i64 8)
  %heap_start116 = sub i64 %79, 8
  %heap_to_ptr117 = inttoptr i64 %heap_start116 to ptr
  store i64 0, ptr %index_alloca121, align 4
  br label %cond118

cond118:                                          ; preds = %body119, %done105
  %index_value122 = load i64, ptr %index_alloca121, align 4
  %loop_cond123 = icmp ult i64 %index_value122, 4
  br i1 %loop_cond123, label %body119, label %done120

body119:                                          ; preds = %cond118
  %80 = add i64 0, %index_value122
  %src_index_access124 = getelementptr i64, ptr %heap_to_ptr113, i64 %80
  %81 = load i64, ptr %src_index_access124, align 4
  %82 = add i64 0, %index_value122
  %dest_index_access125 = getelementptr i64, ptr %heap_to_ptr117, i64 %82
  store i64 %81, ptr %dest_index_access125, align 4
  %next_index126 = add i64 %index_value122, 1
  store i64 %next_index126, ptr %index_alloca121, align 4
  br label %cond118

done120:                                          ; preds = %cond118
  store i64 0, ptr %index_alloca130, align 4
  br label %cond127

cond127:                                          ; preds = %body128, %done120
  %index_value131 = load i64, ptr %index_alloca130, align 4
  %loop_cond132 = icmp ult i64 %index_value131, 4
  br i1 %loop_cond132, label %body128, label %done129

body128:                                          ; preds = %cond127
  %83 = add i64 0, %index_value131
  %src_index_access133 = getelementptr i64, ptr %heap_to_ptr115, i64 %83
  %84 = load i64, ptr %src_index_access133, align 4
  %85 = add i64 4, %index_value131
  %dest_index_access134 = getelementptr i64, ptr %heap_to_ptr117, i64 %85
  store i64 %84, ptr %dest_index_access134, align 4
  %next_index135 = add i64 %index_value131, 1
  store i64 %next_index135, ptr %index_alloca130, align 4
  br label %cond127

done129:                                          ; preds = %cond127
  %86 = call i64 @vector_new(i64 4)
  %heap_start136 = sub i64 %86, 4
  %heap_to_ptr137 = inttoptr i64 %heap_start136 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr117, ptr %heap_to_ptr137, i64 8)
  %87 = call i64 @vector_new(i64 4)
  %heap_start138 = sub i64 %87, 4
  %heap_to_ptr139 = inttoptr i64 %heap_start138 to ptr
  call void @get_storage(ptr %heap_to_ptr137, ptr %heap_to_ptr139)
  %storage_value140 = load i64, ptr %heap_to_ptr139, align 4
  call void @builtin_assert(i64 %storage_value140)
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
