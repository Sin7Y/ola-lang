; ModuleID = 'InputExample'
source_filename = "examples/source/contract_input/input_1.ola"

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

define i64 @foo() {
entry:
  ret i64 5
}

define void @main() {
entry:
  %y = alloca i64, align 8
  %x = alloca i64, align 8
  store i64 5, ptr %x, align 4
  %0 = call i64 @foo()
  store i64 %0, ptr %y, align 4
  ret void
}

define i64 @bar() {
entry:
  call void @builtin_range_check(i64 9)
  ret i64 9
}
