; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote_simple.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

define ptr @vector_new_init(i64 %0, ptr %1) {
entry:
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %0, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %1, ptr %vector_data, align 8
  ret ptr %vector_alloca
}

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define void @contract_init(ptr %0) {
entry:
  %struct_alloca = alloca { i64, i64 }, align 8
  %i = alloca i64, align 8
  %proposalNames_ = alloca ptr, align 8
  store ptr %0, ptr %proposalNames_, align 8
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %1 = load i64, ptr %i, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %2 = icmp ult i64 %1, %length
  br i1 %2, label %body, label %endfor

body:                                             ; preds = %cond
  %3 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %4 = extractvalue [4 x i64] %3, 3
  %5 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %6 = extractvalue [4 x i64] %5, 3
  %7 = add i64 %6, %4
  %8 = insertvalue [4 x i64] %5, i64 %7, 3
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %9 = load i64, ptr %i, align 4
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %10 = sub i64 %length2, 1
  %11 = sub i64 %10, %9
  call void @builtin_range_check(i64 %11)
  %data = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 %9
  %12 = load i64, ptr %index_access, align 4
  store i64 %12, ptr %"struct member", align 4
  %"struct member3" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 0, ptr %"struct member3", align 4
  %name = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %13 = load i64, ptr %name, align 4
  %14 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %13, 3
  call void @set_storage([4 x i64] %8, [4 x i64] %14)
  %15 = extractvalue [4 x i64] %8, 3
  %16 = add i64 %15, 1
  %17 = insertvalue [4 x i64] %8, i64 %16, 3
  %voteCount = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  %18 = load i64, ptr %voteCount, align 4
  %19 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %18, 3
  call void @set_storage([4 x i64] %17, [4 x i64] %19)
  %new_length = add i64 %4, 1
  %20 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1], [4 x i64] %20)
  br label %next

next:                                             ; preds = %body
  %21 = load i64, ptr %i, align 4
  %22 = add i64 %21, 1
  store i64 %22, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void
}

define void @vote_proposal(i64 %0) {
entry:
  %sender = alloca i64, align 8
  %msgSender = alloca [4 x i64], align 8
  %proposal_ = alloca i64, align 8
  store i64 %0, ptr %proposal_, align 4
  %1 = call [4 x i64] @get_caller()
  store [4 x i64] %1, ptr %msgSender, align 4
  %2 = load [4 x i64], ptr %msgSender, align 4
  %3 = extractvalue [4 x i64] %2, 0
  %4 = extractvalue [4 x i64] %2, 1
  %5 = extractvalue [4 x i64] %2, 2
  %6 = extractvalue [4 x i64] %2, 3
  %7 = insertvalue [8 x i64] undef, i64 %6, 7
  %8 = insertvalue [8 x i64] %7, i64 %5, 6
  %9 = insertvalue [8 x i64] %8, i64 %4, 5
  %10 = insertvalue [8 x i64] %9, i64 %3, 4
  %11 = insertvalue [8 x i64] %10, i64 0, 3
  %12 = insertvalue [8 x i64] %11, i64 0, 2
  %13 = insertvalue [8 x i64] %12, i64 0, 1
  %14 = insertvalue [8 x i64] %13, i64 0, 0
  %15 = call [4 x i64] @poseidon_hash([8 x i64] %14)
  store [4 x i64] %15, ptr %sender, align 4
  %16 = load i64, ptr %sender, align 4
  %17 = add i64 %16, 0
  %18 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %17, 3
  call void @set_storage([4 x i64] %18, [4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %19 = load i64, ptr %sender, align 4
  %20 = add i64 %19, 1
  %21 = load i64, ptr %proposal_, align 4
  %22 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %20, 3
  %23 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %21, 3
  call void @set_storage([4 x i64] %22, [4 x i64] %23)
  %24 = load i64, ptr %proposal_, align 4
  %25 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %26 = extractvalue [4 x i64] %25, 3
  %27 = sub i64 %26, 1
  %28 = sub i64 %27, %24
  call void @builtin_range_check(i64 %28)
  %29 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %30 = extractvalue [4 x i64] %29, 3
  %31 = add i64 %30, %24
  %32 = insertvalue [4 x i64] %29, i64 %31, 3
  %33 = extractvalue [4 x i64] %32, 3
  %34 = add i64 %33, 1
  %35 = insertvalue [4 x i64] %32, i64 %34, 3
  %36 = load i64, ptr %proposal_, align 4
  %37 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %38 = extractvalue [4 x i64] %37, 3
  %39 = sub i64 %38, 1
  %40 = sub i64 %39, %36
  call void @builtin_range_check(i64 %40)
  %41 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %42 = extractvalue [4 x i64] %41, 3
  %43 = add i64 %42, %36
  %44 = insertvalue [4 x i64] %41, i64 %43, 3
  %45 = extractvalue [4 x i64] %44, 3
  %46 = add i64 %45, 1
  %47 = insertvalue [4 x i64] %44, i64 %46, 3
  %48 = call [4 x i64] @get_storage([4 x i64] %47)
  %49 = extractvalue [4 x i64] %48, 3
  %50 = add i64 %49, 1
  call void @builtin_range_check(i64 %50)
  %51 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %50, 3
  call void @set_storage([4 x i64] %35, [4 x i64] %51)
  ret void
}

define i64 @winningProposal() {
entry:
  %p = alloca i64, align 8
  %winningVoteCount = alloca i64, align 8
  %winningProposal_ = alloca i64, align 8
  store i64 0, ptr %winningProposal_, align 4
  store i64 0, ptr %winningVoteCount, align 4
  store i64 0, ptr %p, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %0 = load i64, ptr %p, align 4
  %1 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %2 = extractvalue [4 x i64] %1, 3
  %3 = icmp ult i64 %0, %2
  br i1 %3, label %body, label %endfor

body:                                             ; preds = %cond
  %4 = load i64, ptr %p, align 4
  %5 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %6 = extractvalue [4 x i64] %5, 3
  %7 = sub i64 %6, 1
  %8 = sub i64 %7, %4
  call void @builtin_range_check(i64 %8)
  %9 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %10 = extractvalue [4 x i64] %9, 3
  %11 = add i64 %10, %4
  %12 = insertvalue [4 x i64] %9, i64 %11, 3
  %13 = extractvalue [4 x i64] %12, 3
  %14 = add i64 %13, 1
  %15 = insertvalue [4 x i64] %12, i64 %14, 3
  %16 = call [4 x i64] @get_storage([4 x i64] %15)
  %17 = extractvalue [4 x i64] %16, 3
  %18 = load i64, ptr %winningVoteCount, align 4
  %19 = icmp ugt i64 %17, %18
  br i1 %19, label %then, label %enif

next:                                             ; preds = %enif
  %20 = load i64, ptr %p, align 4
  %21 = add i64 %20, 1
  store i64 %21, ptr %p, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %22 = load i64, ptr %winningProposal_, align 4
  ret i64 %22

then:                                             ; preds = %body
  %23 = load i64, ptr %p, align 4
  %24 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %25 = extractvalue [4 x i64] %24, 3
  %26 = sub i64 %25, 1
  %27 = sub i64 %26, %23
  call void @builtin_range_check(i64 %27)
  %28 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %29 = extractvalue [4 x i64] %28, 3
  %30 = add i64 %29, %23
  %31 = insertvalue [4 x i64] %28, i64 %30, 3
  %32 = extractvalue [4 x i64] %31, 3
  %33 = add i64 %32, 1
  %34 = insertvalue [4 x i64] %31, i64 %33, 3
  %35 = call [4 x i64] @get_storage([4 x i64] %34)
  %36 = extractvalue [4 x i64] %35, 3
  %37 = load i64, ptr %p, align 4
  br label %enif

enif:                                             ; preds = %then, %body
  br label %next
}

define i64 @getWinnerName() {
entry:
  %winnerName = alloca i64, align 8
  %0 = call i64 @winningProposal()
  %1 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %2 = extractvalue [4 x i64] %1, 3
  %3 = sub i64 %2, 1
  %4 = sub i64 %3, %0
  call void @builtin_range_check(i64 %4)
  %5 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %6 = extractvalue [4 x i64] %5, 3
  %7 = add i64 %6, %0
  %8 = insertvalue [4 x i64] %5, i64 %7, 3
  %9 = extractvalue [4 x i64] %8, 3
  %10 = add i64 %9, 0
  %11 = insertvalue [4 x i64] %8, i64 %10, 3
  %12 = call [4 x i64] @get_storage([4 x i64] %11)
  %13 = extractvalue [4 x i64] %12, 3
  store i64 %13, ptr %winnerName, align 4
  %14 = load i64, ptr %winnerName, align 4
  ret i64 %14
}

define [4 x i64] @get_caller() {
entry:
  ret [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938]
}

define void @function_dispatch(i64 %0, i64 %1, i64 %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 2817135588, label %func_0_dispatch
    i64 2791810083, label %func_1_dispatch
    i64 3186728800, label %func_2_dispatch
    i64 363199787, label %func_3_dispatch
    i64 2868727644, label %func_4_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call i64 @tape_load(i64 %2, i64 0)
  %4 = add i64 1, %3
  %5 = icmp ule i64 1, %1
  br i1 %5, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %size = mul i64 %3, 1
  %6 = call i64 @vector_new(i64 %size)
  %heap_ptr = sub i64 %6, %size
  %int_to_ptr = inttoptr i64 %heap_ptr to ptr
  %7 = call ptr @vector_new_init(i64 %size, ptr %int_to_ptr)
  %data = getelementptr inbounds { i64, ptr }, ptr %7, i32 0, i32 1
  %array_elem_num = mul i64 %3, 1
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

loop_body:                                        ; preds = %inbounds1, %inbounds
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr i64, ptr %data, i64 %index
  %8 = icmp ule i64 2, %1
  br i1 %8, label %inbounds1, label %out_of_bounds2

loop_end:                                         ; preds = %inbounds1
  %9 = add i64 0, %array_elem_num
  %10 = icmp ule i64 %9, %1
  br i1 %10, label %inbounds3, label %out_of_bounds4

inbounds1:                                        ; preds = %loop_body
  %11 = call i64 @tape_load(i64 %2, i64 1)
  store i64 %11, ptr %element, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %3
  br i1 %index_cond, label %loop_body, label %loop_end

out_of_bounds2:                                   ; preds = %loop_body
  unreachable

inbounds3:                                        ; preds = %loop_end
  %12 = add i64 0, %4
  %13 = icmp ule i64 %12, %1
  br i1 %13, label %inbounds5, label %out_of_bounds6

out_of_bounds4:                                   ; preds = %loop_end
  unreachable

inbounds5:                                        ; preds = %inbounds3
  %14 = add i64 0, %4
  %15 = icmp ult i64 %14, %1
  br i1 %15, label %not_all_bytes_read, label %buffer_read

out_of_bounds6:                                   ; preds = %inbounds3
  unreachable

not_all_bytes_read:                               ; preds = %inbounds5
  unreachable

buffer_read:                                      ; preds = %inbounds5
  call void @contract_init(ptr %7)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %16 = icmp ule i64 1, %1
  br i1 %16, label %inbounds7, label %out_of_bounds8

inbounds7:                                        ; preds = %func_1_dispatch
  %17 = call i64 @tape_load(i64 %2, i64 0)
  %18 = icmp ult i64 1, %1
  br i1 %18, label %not_all_bytes_read9, label %buffer_read10

out_of_bounds8:                                   ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read9:                              ; preds = %inbounds7
  unreachable

buffer_read10:                                    ; preds = %inbounds7
  call void @vote_proposal(i64 %17)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %19 = call i64 @winningProposal()
  call void @tape_store(i64 0, i64 %19)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %20 = call i64 @getWinnerName()
  call void @tape_store(i64 0, i64 %20)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %21 = call [4 x i64] @get_caller()
  %22 = extractvalue [4 x i64] %21, 0
  call void @tape_store(i64 0, i64 %22)
  %23 = extractvalue [4 x i64] %21, 1
  call void @tape_store(i64 1, i64 %23)
  %24 = extractvalue [4 x i64] %21, 2
  call void @tape_store(i64 2, i64 %24)
  %25 = extractvalue [4 x i64] %21, 3
  call void @tape_store(i64 3, i64 %25)
  ret void
}

define void @call() {
entry:
  %0 = call ptr @contract_input()
  %input_selector = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 0
  %selector = load i64, ptr %input_selector, align 4
  %input_len = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 1
  %len = load i64, ptr %input_len, align 4
  %input_data = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 2
  %data = load i64, ptr %input_data, align 4
  call void @function_dispatch(i64 %selector, i64 %len, i64 %data)
  unreachable
}
