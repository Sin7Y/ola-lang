; ModuleID = 'vote_simple.ll'
source_filename = "examples/source/storage/vote_simple.ola"

declare void @builtin_range_check(i64) local_unnamed_addr

declare [4 x i64] @get_storage([4 x i64]) local_unnamed_addr

declare void @set_storage([4 x i64], [4 x i64]) local_unnamed_addr

declare [4 x i64] @poseidon_hash([8 x i64]) local_unnamed_addr

define void @contract_init(ptr %0) local_unnamed_addr {
entry:
  %proposalNames_ = alloca ptr, align 8
  store ptr %0, ptr %proposalNames_, align 8
  %length.cast = ptrtoint ptr %0 to i64
  %.not = icmp eq ptr %0, null
  br i1 %.not, label %endfor, label %body.lr.ph

body.lr.ph:                                       ; preds = %entry
  %data = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i64 0, i32 1
  br label %body

body:                                             ; preds = %body.lr.ph, %body
  %i.03 = phi i64 [ 0, %body.lr.ph ], [ %12, %body ]
  %1 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %2 = extractvalue [4 x i64] %1, 3
  %3 = tail call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %4 = extractvalue [4 x i64] %3, 3
  %5 = add i64 %4, %2
  %6 = insertvalue [4 x i64] %3, i64 %5, 3
  %index_access = getelementptr i64, ptr %data, i64 %i.03
  %7 = load i64, ptr %index_access, align 8
  %8 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %7, 3
  tail call void @set_storage([4 x i64] %6, [4 x i64] %8)
  %9 = add i64 %5, 1
  %10 = insertvalue [4 x i64] %6, i64 %9, 3
  tail call void @set_storage([4 x i64] %10, [4 x i64] zeroinitializer)
  %new_length = add i64 %2, 1
  %11 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  tail call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1], [4 x i64] %11)
  %12 = add nuw i64 %i.03, 1
  %13 = icmp ult i64 %12, %length.cast
  br i1 %13, label %body, label %endfor

endfor:                                           ; preds = %body, %entry
  ret void
}

define void @vote_proposal(i64 %0) local_unnamed_addr {
entry:
  %1 = tail call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938])
  %.fca.0.extract15 = extractvalue [4 x i64] %1, 0
  %2 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %.fca.0.extract15, 3
  tail call void @set_storage([4 x i64] %2, [4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %3 = add i64 %.fca.0.extract15, 1
  %4 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %3, 3
  %5 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %0, 3
  tail call void @set_storage([4 x i64] %4, [4 x i64] %5)
  %6 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %7 = tail call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %8 = extractvalue [4 x i64] %7, 3
  %9 = add i64 %0, 1
  %10 = add i64 %9, %8
  %11 = insertvalue [4 x i64] %7, i64 %10, 3
  %12 = tail call [4 x i64] @get_storage([4 x i64] %11)
  %13 = extractvalue [4 x i64] %12, 3
  %14 = add i64 %13, 1
  tail call void @builtin_range_check(i64 %14)
  %15 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %16 = tail call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %17 = extractvalue [4 x i64] %16, 3
  %18 = add i64 %9, %17
  %19 = insertvalue [4 x i64] %16, i64 %18, 3
  %20 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %14, 3
  tail call void @set_storage([4 x i64] %19, [4 x i64] %20)
  ret void
}

define i64 @winningProposal() local_unnamed_addr {
entry:
  %0 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %1 = extractvalue [4 x i64] %0, 3
  %.not6 = icmp eq i64 %1, 0
  br i1 %.not6, label %endfor, label %body

body:                                             ; preds = %entry, %enif
  %p.05 = phi i64 [ %5, %enif ], [ 0, %entry ]
  %2 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %3 = tail call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %4 = extractvalue [4 x i64] %3, 3
  %5 = add nuw i64 %p.05, 1
  %6 = add i64 %5, %4
  %7 = insertvalue [4 x i64] %3, i64 %6, 3
  %8 = tail call [4 x i64] @get_storage([4 x i64] %7)
  %9 = extractvalue [4 x i64] %8, 3
  %.not = icmp eq i64 %9, 0
  br i1 %.not, label %enif, label %then

endfor:                                           ; preds = %enif, %entry
  ret i64 0

then:                                             ; preds = %body
  %10 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %11 = tail call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %12 = extractvalue [4 x i64] %11, 3
  %13 = add i64 %5, %12
  %14 = insertvalue [4 x i64] %11, i64 %13, 3
  %15 = tail call [4 x i64] @get_storage([4 x i64] %14)
  br label %enif

enif:                                             ; preds = %then, %body
  %16 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %17 = extractvalue [4 x i64] %16, 3
  %18 = icmp ult i64 %5, %17
  br i1 %18, label %body, label %endfor
}

define i64 @getWinnerName() local_unnamed_addr {
entry:
  %0 = tail call i64 @winningProposal()
  %1 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %2 = tail call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %3 = tail call [4 x i64] @get_storage([4 x i64] %2)
  %4 = extractvalue [4 x i64] %3, 3
  ret i64 %4
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind readnone willreturn
define [4 x i64] @get_caller() local_unnamed_addr #0 {
entry:
  ret [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938]
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind readnone willreturn }
