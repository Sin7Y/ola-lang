define void @alloca_params_pattern() {
entry:
  %arg1 = alloca i64, align 8
  %arg2 = alloca i64, align 8
  br label %bb1

bb1:
  ; CHECK: add r2 r9 -4
  ; CHECK: add r1 r9 -3
  ; CHECK: call stack_args_func
  call void @stack_args_func(ptr %arg1, ptr %arg2)
  ret void
}