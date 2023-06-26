; ModuleID = 'vote.ll'
source_filename = "examples/source/storage/vote.ola"

declare void @builtin_range_check(i64) local_unnamed_addr

declare ptr @vector_new(i64, ptr) local_unnamed_addr

declare [4 x i64] @get_storage([4 x i64]) local_unnamed_addr

declare void @set_storage([4 x i64], [4 x i64]) local_unnamed_addr

declare [4 x i64] @poseidon_hash([8 x i64]) local_unnamed_addr

define void @contract_init(ptr %0) local_unnamed_addr {
entry:
  %struct_alloca = alloca { ptr, i64 }, align 8
  %proposalNames_ = alloca ptr, align 8
  store ptr %0, ptr %proposalNames_, align 8
  tail call void @set_storage([4 x i64] zeroinitializer, [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938])
  %.not = icmp eq ptr %0, null
  br i1 %.not, label %endfor, label %body.lr.ph

body.lr.ph:                                       ; preds = %entry
  %data = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i64 0, i32 1
  %"struct member3" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i64 0, i32 1
  br label %body

body:                                             ; preds = %body.lr.ph, %done12
  %i.057 = phi i64 [ 0, %body.lr.ph ], [ %33, %done12 ]
  %1 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %2 = extractvalue [4 x i64] %1, 3
  %3 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %4 = extractvalue [4 x i64] %3, 3
  %5 = add i64 %4, %2
  %6 = insertvalue [4 x i64] %3, i64 %5, 3
  %index_access = getelementptr { i64, ptr }, ptr %data, i64 %i.057
  store ptr %index_access, ptr %struct_alloca, align 8
  store i64 0, ptr %"struct member3", align 8
  %length5.cast = ptrtoint ptr %index_access to i64
  %7 = call [4 x i64] @get_storage([4 x i64] %6)
  %8 = extractvalue [4 x i64] %7, 3
  %9 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length5.cast, 3
  call void @set_storage([4 x i64] %6, [4 x i64] %9)
  %10 = extractvalue [4 x i64] %3, 0
  %11 = extractvalue [4 x i64] %3, 1
  %12 = extractvalue [4 x i64] %3, 2
  %13 = insertvalue [8 x i64] undef, i64 %5, 7
  %14 = insertvalue [8 x i64] %13, i64 %12, 6
  %15 = insertvalue [8 x i64] %14, i64 %11, 5
  %16 = insertvalue [8 x i64] %15, i64 %10, 4
  %17 = insertvalue [8 x i64] %16, i64 0, 3
  %18 = insertvalue [8 x i64] %17, i64 0, 2
  %19 = insertvalue [8 x i64] %18, i64 0, 1
  %20 = insertvalue [8 x i64] %19, i64 0, 0
  %21 = call [4 x i64] @poseidon_hash([8 x i64] %20)
  %.elt9 = extractvalue [4 x i64] %21, 3
  %loop_cond47.not = icmp eq ptr %index_access, null
  br i1 %loop_cond47.not, label %done, label %body7

endfor:                                           ; preds = %done12, %entry
  ret void

body7:                                            ; preds = %body, %body7
  %next_index4648 = phi i64 [ %next_index, %body7 ], [ 0, %body ]
  %22 = phi i64 [ %26, %body7 ], [ %.elt9, %body ]
  %23 = insertvalue [4 x i64] %21, i64 %22, 3
  %index_access9 = getelementptr i64, ptr %"struct member3", i64 %next_index4648
  %24 = load i64, ptr %index_access9, align 8
  %25 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %24, 3
  call void @set_storage([4 x i64] %23, [4 x i64] %25)
  %26 = add i64 %22, 1
  %next_index = add nuw i64 %next_index4648, 1
  %loop_cond = icmp ult i64 %next_index, %length5.cast
  br i1 %loop_cond, label %body7, label %done

done:                                             ; preds = %body7, %body
  %loop_cond1552 = icmp ugt i64 %8, %length5.cast
  br i1 %loop_cond1552, label %body11, label %done12

body11:                                           ; preds = %done, %body11
  %next_index165053 = phi i64 [ %next_index16, %body11 ], [ %length5.cast, %done ]
  %27 = phi i64 [ %29, %body11 ], [ %.elt9, %done ]
  %28 = insertvalue [4 x i64] %21, i64 %27, 3
  call void @set_storage([4 x i64] %28, [4 x i64] zeroinitializer)
  %29 = add i64 %27, 1
  %next_index16 = add nuw i64 %next_index165053, 1
  %loop_cond15 = icmp ult i64 %next_index16, %8
  br i1 %loop_cond15, label %body11, label %done12

done12:                                           ; preds = %body11, %done
  %30 = add i64 %5, 1
  %31 = insertvalue [4 x i64] %6, i64 %30, 3
  call void @set_storage([4 x i64] %31, [4 x i64] zeroinitializer)
  %new_length = add i64 %2, 1
  %32 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 3], [4 x i64] %32)
  %33 = add nuw i64 %i.057, 1
  %length = load i64, ptr %proposalNames_, align 8
  %34 = icmp ult i64 %33, %length
  br i1 %34, label %body, label %endfor
}

define void @vote_proposal(i64 %0) local_unnamed_addr {
entry:
  %1 = tail call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 1, i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938])
  %.fca.0.extract7 = extractvalue [4 x i64] %1, 0
  %2 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %.fca.0.extract7, 3
  tail call void @set_storage([4 x i64] %2, [4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %3 = add i64 %.fca.0.extract7, 1
  %4 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %3, 3
  %5 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %0, 3
  tail call void @set_storage([4 x i64] %4, [4 x i64] %5)
  %6 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %7 = tail call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %8 = add i64 %0, 1
  %9 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %8, 3
  %10 = tail call [4 x i64] @get_storage([4 x i64] %9)
  %11 = extractvalue [4 x i64] %10, 3
  %12 = add i64 %11, 1
  tail call void @builtin_range_check(i64 %12)
  %13 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %14 = tail call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %15 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %12, 3
  tail call void @set_storage([4 x i64] %9, [4 x i64] %15)
  ret void
}

define i64 @winningProposal() local_unnamed_addr {
entry:
  %0 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %1 = extractvalue [4 x i64] %0, 3
  %.not7 = icmp eq i64 %1, 0
  br i1 %.not7, label %endfor, label %body

body:                                             ; preds = %entry, %enif
  %p.06 = phi i64 [ %4, %enif ], [ 0, %entry ]
  %2 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %3 = tail call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %4 = add nuw i64 %p.06, 1
  %5 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %4, 3
  %6 = tail call [4 x i64] @get_storage([4 x i64] %5)
  %7 = extractvalue [4 x i64] %6, 3
  %.not = icmp eq i64 %7, 0
  br i1 %.not, label %enif, label %then

endfor:                                           ; preds = %enif, %entry
  ret i64 0

then:                                             ; preds = %body
  %8 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %9 = tail call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %10 = tail call [4 x i64] @get_storage([4 x i64] %5)
  br label %enif

enif:                                             ; preds = %then, %body
  %11 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %12 = extractvalue [4 x i64] %11, 3
  %13 = icmp ult i64 %4, %12
  br i1 %13, label %body, label %endfor
}

define ptr @getWinnerName() local_unnamed_addr {
entry:
  %0 = tail call i64 @winningProposal()
  %1 = tail call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %2 = tail call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 3])
  %3 = tail call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %4 = extractvalue [4 x i64] %3, 3
  %5 = tail call ptr @vector_new(i64 %4, ptr null)
  %6 = tail call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %loop_cond5.not = icmp eq i64 %4, 0
  br i1 %loop_cond5.not, label %done, label %body.lr.ph

body.lr.ph:                                       ; preds = %entry
  %data = getelementptr inbounds { i64, ptr }, ptr %5, i64 0, i32 1
  br label %body

body:                                             ; preds = %body.lr.ph, %body
  %index_alloca.06 = phi i64 [ 0, %body.lr.ph ], [ %next_index, %body ]
  %index_access = getelementptr i64, ptr %data, i64 %index_alloca.06
  %7 = tail call [4 x i64] @get_storage([4 x i64] %6)
  %8 = extractvalue [4 x i64] %7, 3
  store i64 %8, ptr %index_access, align 4
  %next_index = add nuw i64 %index_alloca.06, 1
  %loop_cond = icmp ult i64 %next_index, %4
  br i1 %loop_cond, label %body, label %done

done:                                             ; preds = %body, %entry
  ret ptr %5
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind readnone willreturn
define [4 x i64] @get_caller() local_unnamed_addr #0 {
entry:
  ret [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938]
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind readnone willreturn }
