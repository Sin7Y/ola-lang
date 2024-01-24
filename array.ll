define void @processArray(ptr %array, i64 %length) {
entry:
  %0 = icmp eq i64 %length, 0
  br i1 %0, label %exit, label %loop

loop:                                             ; preds = %entry, %loop
  %i = phi i64 [ 0, %entry ], [ %next_i, %loop ]
  %ptr = phi ptr [ %array, %entry ], [ %next_ptr, %loop ]

  ; 假设的数组处理逻辑
  %value = load i64, ptr %ptr, align 8
  ; ... 对 %value 进行操作 ...

  %next_i = add i64 %i, 1
  %next_ptr = getelementptr i64, ptr %ptr, i64 1
  %loop_cond = icmp ult i64 %next_i, %length
  br i1 %loop_cond, label %loop, label %exit

exit:
  ret void
}
