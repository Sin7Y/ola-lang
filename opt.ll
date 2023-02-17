; ModuleID = 'fib.ll'
source_filename = "examples/fib.ola"

; Function Attrs: nofree nosync nounwind readnone
define void @main() local_unnamed_addr #0 {
entry:
  %0 = tail call i32 @fib_recursive(i32 10)
  ret void
}

; Function Attrs: nofree nosync nounwind readnone
define i32 @fib_recursive(i32 %0) local_unnamed_addr #0 {
entry:
  %1 = add i32 %0, -1
  %2 = icmp ult i32 %1, 2
  br i1 %2, label %common.ret, label %enif2

common.ret.loopexit:                              ; preds = %enif2
  %phi.bo = add i32 %6, 1
  br label %common.ret

common.ret:                                       ; preds = %common.ret.loopexit, %entry
  %accumulator.tr.lcssa = phi i32 [ 1, %entry ], [ %phi.bo, %common.ret.loopexit ]
  ret i32 %accumulator.tr.lcssa

enif2:                                            ; preds = %entry, %enif2
  %3 = phi i32 [ %7, %enif2 ], [ %1, %entry ]
  %.tr6 = phi i32 [ %5, %enif2 ], [ %0, %entry ]
  %accumulator.tr5 = phi i32 [ %6, %enif2 ], [ 0, %entry ]
  %4 = tail call i32 @fib_recursive(i32 %3)
  %5 = add i32 %.tr6, -2
  %6 = add i32 %4, %accumulator.tr5
  %7 = add i32 %.tr6, -3
  %8 = icmp ult i32 %7, 2
  br i1 %8, label %common.ret.loopexit, label %enif2
}

; Function Attrs: nofree norecurse nosync nounwind readnone
define i32 @fib_non_recursive(i32 %0) local_unnamed_addr #1 {
entry:
  %1 = icmp ult i32 %0, 2
  br i1 %1, label %common.ret, label %cond.preheader

cond.preheader:                                   ; preds = %entry
  %2 = add i32 %0, -1
  %3 = icmp ugt i32 %2, 2
  br i1 %3, label %body, label %common.ret

common.ret:                                       ; preds = %cond.preheader, %endfor.loopexit, %entry
  %common.ret.op = phi i32 [ 1, %entry ], [ %7, %endfor.loopexit ], [ 2, %cond.preheader ]
  ret i32 %common.ret.op

body:                                             ; preds = %cond.preheader, %body
  %i.010 = phi i32 [ %5, %body ], [ 2, %cond.preheader ]
  %a.09 = phi i32 [ %b.08, %body ], [ 1, %cond.preheader ]
  %b.08 = phi i32 [ %4, %body ], [ 1, %cond.preheader ]
  %4 = add i32 %a.09, %b.08
  %5 = add nuw i32 %i.010, 1
  %6 = icmp ult i32 %5, %2
  br i1 %6, label %body, label %endfor.loopexit

endfor.loopexit:                                  ; preds = %body
  %7 = add i32 %b.08, %4
  br label %common.ret
}

attributes #0 = { nofree nosync nounwind readnone }
attributes #1 = { nofree norecurse nosync nounwind readnone }
