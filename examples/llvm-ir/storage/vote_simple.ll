; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote_simple.ola"

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
  %19 = call [4 x i64] @get_storage([4 x i64] %18)
  %20 = extractvalue [4 x i64] %19, 3
  %21 = icmp eq i64 %20, 0
  %22 = zext i1 %21 to i64
  call void @builtin_assert(i64 %22)
  %23 = load i64, ptr %sender, align 4
  %24 = add i64 %23, 0
  %25 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %24, 3
  call void @set_storage([4 x i64] %25, [4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %26 = load i64, ptr %sender, align 4
  %27 = add i64 %26, 1
  %28 = load i64, ptr %proposal_, align 4
  %29 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %27, 3
  %30 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %28, 3
  call void @set_storage([4 x i64] %29, [4 x i64] %30)
  %31 = load i64, ptr %proposal_, align 4
  %32 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %33 = extractvalue [4 x i64] %32, 3
  %34 = sub i64 %33, 1
  %35 = sub i64 %34, %31
  call void @builtin_range_check(i64 %35)
  %36 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %37 = extractvalue [4 x i64] %36, 3
  %38 = mul i64 %31, 2
  %39 = add i64 %37, %38
  %40 = insertvalue [4 x i64] %36, i64 %39, 3
  %41 = extractvalue [4 x i64] %40, 3
  %42 = add i64 %41, 1
  %43 = insertvalue [4 x i64] %40, i64 %42, 3
  %44 = load i64, ptr %proposal_, align 4
  %45 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %46 = extractvalue [4 x i64] %45, 3
  %47 = sub i64 %46, 1
  %48 = sub i64 %47, %44
  call void @builtin_range_check(i64 %48)
  %49 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %50 = extractvalue [4 x i64] %49, 3
  %51 = mul i64 %44, 2
  %52 = add i64 %50, %51
  %53 = insertvalue [4 x i64] %49, i64 %52, 3
  %54 = extractvalue [4 x i64] %53, 3
  %55 = add i64 %54, 1
  %56 = insertvalue [4 x i64] %53, i64 %55, 3
  %57 = call [4 x i64] @get_storage([4 x i64] %56)
  %58 = extractvalue [4 x i64] %57, 3
  %59 = add i64 %58, 1
  call void @builtin_range_check(i64 %59)
  %60 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %59, 3
  call void @set_storage([4 x i64] %43, [4 x i64] %60)
  ret void
}

define [4 x i64] @get_caller() {
entry:
  ret [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938]
}