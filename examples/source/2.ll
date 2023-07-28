; ModuleID = '1.1142b1c3e997ee03-cgu.0'
source_filename = "1.1142b1c3e997ee03-cgu.0"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.0"

%"alloc::string::String" = type { %"alloc::vec::Vec<u8>" }
%"alloc::vec::Vec<u8>" = type { { ptr, i64 }, i64 }
%"core::result::Result<core::alloc::layout::Layout, alloc::collections::TryReserveErrorKind>" = type { i64, [2 x i64] }
%"core::result::Result<core::alloc::layout::Layout, alloc::collections::TryReserveErrorKind>::Ok" = type { [1 x i64], { i64, i64 } }
%"core::result::Result<core::alloc::layout::Layout, alloc::collections::TryReserveErrorKind>::Err" = type { [1 x i64], { i64, i64 } }
%"core::result::Result<core::ptr::non_null::NonNull<[u8]>, alloc::collections::TryReserveError>" = type { i64, [2 x i64] }
%"core::result::Result<core::ptr::non_null::NonNull<[u8]>, alloc::collections::TryReserveError>::Ok" = type { [1 x i64], { ptr, i64 } }
%"core::result::Result<core::ptr::non_null::NonNull<[u8]>, alloc::collections::TryReserveError>::Err" = type { [1 x i64], { i64, i64 } }
%"alloc::vec::ExtendElement<alloc::string::String>" = type { %"alloc::string::String" }
%"alloc::vec::Vec<alloc::string::String>" = type { { ptr, i64 }, i64 }
%"core::ptr::metadata::PtrRepr<[u8]>" = type { [2 x i64] }
%"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveErrorKind>, core::alloc::layout::Layout>" = type { i64, [2 x i64] }
%"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveErrorKind>, core::alloc::layout::Layout>::Continue" = type { [1 x i64], { i64, i64 } }
%"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveErrorKind>, core::alloc::layout::Layout>::Break" = type { [1 x i64], { i64, i64 } }
%"core::option::Option<(core::ptr::non_null::NonNull<u8>, core::alloc::layout::Layout)>" = type { [1 x i64], i64, [1 x i64] }
%"alloc::alloc::Global" = type {}
%"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveError>, core::ptr::non_null::NonNull<[u8]>>" = type { i64, [2 x i64] }
%"core::result::Result<usize, alloc::collections::TryReserveErrorKind>" = type { i64, [1 x i64] }
%"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveErrorKind>, usize>" = type { i64, [1 x i64] }
%"core::result::Result<usize, alloc::collections::TryReserveErrorKind>::Ok" = type { [1 x i64], i64 }
%"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveErrorKind>, usize>::Continue" = type { [1 x i64], i64 }
%"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveError>, core::ptr::non_null::NonNull<[u8]>>::Continue" = type { [1 x i64], { ptr, i64 } }
%"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveError>, core::ptr::non_null::NonNull<[u8]>>::Break" = type { [1 x i64], { i64, i64 } }
%"core::ptr::metadata::PtrRepr<[alloc::string::String]>" = type { [2 x i64] }

@vtable.0 = private unnamed_addr constant <{ ptr, [16 x i8], ptr, ptr, ptr }> <{ ptr @"_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17hc8602fbf372112e5E", [16 x i8] c"\08\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00", ptr @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17hcf350ab568a5f1e2E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h0394e9abce59b207E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h0394e9abce59b207E" }>, align 8
@alloc_9a5e4f1a9f41e357489e70802f5bde39 = private unnamed_addr constant <{ [80 x i8] }> <{ [80 x i8] c"/rustc/74c4821045c68d42bb8b8a7c998bdb5c2a72bd0d/library/core/src/alloc/layout.rs" }>, align 1
@alloc_f67711e3bebe67d0f354d96d1ab6f3ce = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_9a5e4f1a9f41e357489e70802f5bde39, [16 x i8] c"P\00\00\00\00\00\00\00\BF\01\00\00)\00\00\00" }>, align 8
@str.1 = internal constant [25 x i8] c"attempt to divide by zero"
@alloc_2a62ba4d4fa46537b277796d74f8c568 = private unnamed_addr constant <{}> zeroinitializer, align 1
@alloc_26f643e647dbf77f42e670b3488e8932 = private unnamed_addr constant <{ [1 x i8] }> <{ [1 x i8] c"1" }>, align 1
@alloc_7647ff07ee186800756c11bbd5340cc8 = private unnamed_addr constant <{ [4 x i8] }> <{ [4 x i8] c"1.rs" }>, align 1
@alloc_65f172eb7f5878b54a07b1d35e6af17d = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_7647ff07ee186800756c11bbd5340cc8, [16 x i8] c"\04\00\00\00\00\00\00\00\05\00\00\00\09\00\00\00" }>, align 8

; std::sys_common::backtrace::__rust_begin_short_backtrace
; Function Attrs: noinline uwtable
define internal void @_ZN3std10sys_common9backtrace28__rust_begin_short_backtrace17h57a7b091b59736feE(ptr %f) unnamed_addr #0 {
start:
; call core::ops::function::FnOnce::call_once
  call void @_ZN4core3ops8function6FnOnce9call_once17hc9b51fb028fc1e71E(ptr %f)
  call void asm sideeffect "", "~{memory}"(), !srcloc !2
  ret void
}

; std::rt::lang_start
; Function Attrs: uwtable
define hidden i64 @_ZN3std2rt10lang_start17h442e628b9232b4b1E(ptr %main, i64 %argc, ptr %argv, i8 %sigpipe) unnamed_addr #1 {
start:
  %_8 = alloca ptr, align 8
  %_5 = alloca i64, align 8
  store ptr %main, ptr %_8, align 8
; call std::rt::lang_start_internal
  %0 = call i64 @_ZN3std2rt19lang_start_internal17h2b22f0f26affdef7E(ptr align 1 %_8, ptr align 8 @vtable.0, i64 %argc, ptr %argv, i8 %sigpipe)
  store i64 %0, ptr %_5, align 8
  %1 = load i64, ptr %_5, align 8, !noundef !3
  ret i64 %1
}

; std::rt::lang_start::{{closure}}
; Function Attrs: inlinehint uwtable
define internal i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h0394e9abce59b207E"(ptr align 8 %_1) unnamed_addr #2 {
start:
  %self = alloca i8, align 1
  %_4 = load ptr, ptr %_1, align 8, !nonnull !3, !noundef !3
; call std::sys_common::backtrace::__rust_begin_short_backtrace
  call void @_ZN3std10sys_common9backtrace28__rust_begin_short_backtrace17h57a7b091b59736feE(ptr %_4)
; call <() as std::process::Termination>::report
  %0 = call i8 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h615134f8c08cc0f9E"()
  store i8 %0, ptr %self, align 1
  %_6 = load i8, ptr %self, align 1, !noundef !3
  %1 = zext i8 %_6 to i32
  ret i32 %1
}

; <str as alloc::string::ToString>::to_string
; Function Attrs: inlinehint uwtable
define internal void @"_ZN47_$LT$str$u20$as$u20$alloc..string..ToString$GT$9to_string17h9e2f8b322631240bE"(ptr sret(%"alloc::string::String") %0, ptr align 1 %self.0, i64 %self.1) unnamed_addr #2 {
start:
  %bytes = alloca %"alloc::vec::Vec<u8>", align 8
; call <T as alloc::slice::hack::ConvertVec>::to_vec
  call void @"_ZN52_$LT$T$u20$as$u20$alloc..slice..hack..ConvertVec$GT$6to_vec17h8a9bfeef5ba2bf3fE"(ptr sret(%"alloc::vec::Vec<u8>") %bytes, ptr align 1 %self.0, i64 %self.1)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %0, ptr align 8 %bytes, i64 24, i1 false)
  ret void
}

; <usize as core::iter::range::Step>::forward_unchecked
; Function Attrs: inlinehint uwtable
define internal i64 @"_ZN49_$LT$usize$u20$as$u20$core..iter..range..Step$GT$17forward_unchecked17h2bced64cca0edf6dE"(i64 %start1, i64 %n) unnamed_addr #2 {
start:
  %0 = alloca i64, align 8
  %1 = add nuw i64 %start1, %n
  store i64 %1, ptr %0, align 8
  %2 = load i64, ptr %0, align 8, !noundef !3
  ret i64 %2
}

; core::cmp::impls::<impl core::cmp::Ord for usize>::cmp
; Function Attrs: inlinehint uwtable
define internal i8 @"_ZN4core3cmp5impls50_$LT$impl$u20$core..cmp..Ord$u20$for$u20$usize$GT$3cmp17hddbdb1ff9830cf98E"(ptr align 8 %self, ptr align 8 %other) unnamed_addr #2 {
start:
  %0 = alloca i8, align 1
  %_4 = load i64, ptr %self, align 8, !noundef !3
  %_5 = load i64, ptr %other, align 8, !noundef !3
  %_3 = icmp ult i64 %_4, %_5
  br i1 %_3, label %bb1, label %bb2

bb2:                                              ; preds = %start
  %_7 = load i64, ptr %self, align 8, !noundef !3
  %_8 = load i64, ptr %other, align 8, !noundef !3
  %_6 = icmp eq i64 %_7, %_8
  br i1 %_6, label %bb3, label %bb4

bb1:                                              ; preds = %start
  store i8 -1, ptr %0, align 1
  br label %bb6

bb6:                                              ; preds = %bb5, %bb1
  %1 = load i8, ptr %0, align 1, !range !4, !noundef !3
  ret i8 %1

bb4:                                              ; preds = %bb2
  store i8 1, ptr %0, align 1
  br label %bb5

bb3:                                              ; preds = %bb2
  store i8 0, ptr %0, align 1
  br label %bb5

bb5:                                              ; preds = %bb4, %bb3
  br label %bb6
}

; core::cmp::max_by
; Function Attrs: inlinehint uwtable
define internal i64 @_ZN4core3cmp6max_by17h34c1161a8cbd3c60E(i64 %0, i64 %1) unnamed_addr #2 personality ptr @rust_eh_personality {
start:
  %2 = alloca { ptr, i32 }, align 8
  %_10 = alloca i8, align 1
  %_9 = alloca i8, align 1
  %_5 = alloca { ptr, ptr }, align 8
  %_4 = alloca i8, align 1
  %3 = alloca i64, align 8
  %v2 = alloca i64, align 8
  %v1 = alloca i64, align 8
  store i64 %0, ptr %v1, align 8
  store i64 %1, ptr %v2, align 8
  store i8 1, ptr %_10, align 1
  store i8 1, ptr %_9, align 1
  store ptr %v1, ptr %_5, align 8
  %4 = getelementptr inbounds { ptr, ptr }, ptr %_5, i32 0, i32 1
  store ptr %v2, ptr %4, align 8
  %5 = getelementptr inbounds { ptr, ptr }, ptr %_5, i32 0, i32 0
  %6 = load ptr, ptr %5, align 8, !nonnull !3, !align !5, !noundef !3
  %7 = getelementptr inbounds { ptr, ptr }, ptr %_5, i32 0, i32 1
  %8 = load ptr, ptr %7, align 8, !nonnull !3, !align !5, !noundef !3
; invoke core::ops::function::FnOnce::call_once
  %9 = invoke i8 @_ZN4core3ops8function6FnOnce9call_once17hef8e8785890a4b26E(ptr align 8 %6, ptr align 8 %8)
          to label %bb1 unwind label %cleanup, !range !4

bb8:                                              ; preds = %cleanup
  br label %bb13

cleanup:                                          ; preds = %start
  %10 = landingpad { ptr, i32 }
          cleanup
  %11 = extractvalue { ptr, i32 } %10, 0
  %12 = extractvalue { ptr, i32 } %10, 1
  %13 = getelementptr inbounds { ptr, i32 }, ptr %2, i32 0, i32 0
  store ptr %11, ptr %13, align 8
  %14 = getelementptr inbounds { ptr, i32 }, ptr %2, i32 0, i32 1
  store i32 %12, ptr %14, align 8
  br label %bb8

bb1:                                              ; preds = %start
  store i8 %9, ptr %_4, align 1
  %_8 = load i8, ptr %_4, align 1, !range !4, !noundef !3
  switch i8 %_8, label %bb3 [
    i8 -1, label %bb4
    i8 0, label %bb4
    i8 1, label %bb2
  ]

bb13:                                             ; preds = %bb8
  %15 = load i8, ptr %_10, align 1, !range !6, !noundef !3
  %16 = trunc i8 %15 to i1
  br i1 %16, label %bb12, label %bb9

bb3:                                              ; preds = %bb1
  unreachable

bb4:                                              ; preds = %bb1, %bb1
  store i8 0, ptr %_9, align 1
  %17 = load i64, ptr %v2, align 8, !noundef !3
  store i64 %17, ptr %3, align 8
  br label %bb5

bb2:                                              ; preds = %bb1
  store i8 0, ptr %_10, align 1
  %18 = load i64, ptr %v1, align 8, !noundef !3
  store i64 %18, ptr %3, align 8
  br label %bb5

bb5:                                              ; preds = %bb4, %bb2
  %19 = load i8, ptr %_9, align 1, !range !6, !noundef !3
  %20 = trunc i8 %19 to i1
  br i1 %20, label %bb10, label %bb6

bb6:                                              ; preds = %bb10, %bb5
  %21 = load i8, ptr %_10, align 1, !range !6, !noundef !3
  %22 = trunc i8 %21 to i1
  br i1 %22, label %bb11, label %bb7

bb10:                                             ; preds = %bb5
  br label %bb6

bb9:                                              ; preds = %bb12, %bb13
  %23 = load ptr, ptr %2, align 8, !noundef !3
  %24 = getelementptr inbounds { ptr, i32 }, ptr %2, i32 0, i32 1
  %25 = load i32, ptr %24, align 8, !noundef !3
  %26 = insertvalue { ptr, i32 } poison, ptr %23, 0
  %27 = insertvalue { ptr, i32 } %26, i32 %25, 1
  resume { ptr, i32 } %27

bb12:                                             ; preds = %bb13
  br label %bb9

bb7:                                              ; preds = %bb11, %bb6
  %28 = load i64, ptr %3, align 8, !noundef !3
  ret i64 %28

bb11:                                             ; preds = %bb6
  br label %bb7
}

; core::ops::function::FnOnce::call_once{{vtable.shim}}
; Function Attrs: inlinehint uwtable
define internal i32 @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17hcf350ab568a5f1e2E"(ptr %_1) unnamed_addr #2 {
start:
  %_2 = alloca {}, align 1
  %0 = load ptr, ptr %_1, align 8, !nonnull !3, !noundef !3
; call core::ops::function::FnOnce::call_once
  %1 = call i32 @_ZN4core3ops8function6FnOnce9call_once17h21a76de9e4d90abbE(ptr %0)
  ret i32 %1
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal i32 @_ZN4core3ops8function6FnOnce9call_once17h21a76de9e4d90abbE(ptr %0) unnamed_addr #2 personality ptr @rust_eh_personality {
start:
  %1 = alloca { ptr, i32 }, align 8
  %_2 = alloca {}, align 1
  %_1 = alloca ptr, align 8
  store ptr %0, ptr %_1, align 8
; invoke std::rt::lang_start::{{closure}}
  %2 = invoke i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h0394e9abce59b207E"(ptr align 8 %_1)
          to label %bb1 unwind label %cleanup

bb3:                                              ; preds = %cleanup
  %3 = load ptr, ptr %1, align 8, !noundef !3
  %4 = getelementptr inbounds { ptr, i32 }, ptr %1, i32 0, i32 1
  %5 = load i32, ptr %4, align 8, !noundef !3
  %6 = insertvalue { ptr, i32 } poison, ptr %3, 0
  %7 = insertvalue { ptr, i32 } %6, i32 %5, 1
  resume { ptr, i32 } %7

cleanup:                                          ; preds = %start
  %8 = landingpad { ptr, i32 }
          cleanup
  %9 = extractvalue { ptr, i32 } %8, 0
  %10 = extractvalue { ptr, i32 } %8, 1
  %11 = getelementptr inbounds { ptr, i32 }, ptr %1, i32 0, i32 0
  store ptr %9, ptr %11, align 8
  %12 = getelementptr inbounds { ptr, i32 }, ptr %1, i32 0, i32 1
  store i32 %10, ptr %12, align 8
  br label %bb3

bb1:                                              ; preds = %start
  ret i32 %2
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3ops8function6FnOnce9call_once17hc9b51fb028fc1e71E(ptr %_1) unnamed_addr #2 {
start:
  %_2 = alloca {}, align 1
  call void %_1()
  ret void
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal i8 @_ZN4core3ops8function6FnOnce9call_once17hef8e8785890a4b26E(ptr align 8 %0, ptr align 8 %1) unnamed_addr #2 {
start:
  %_2 = alloca { ptr, ptr }, align 8
  store ptr %0, ptr %_2, align 8
  %2 = getelementptr inbounds { ptr, ptr }, ptr %_2, i32 0, i32 1
  store ptr %1, ptr %2, align 8
  %3 = load ptr, ptr %_2, align 8, !nonnull !3, !align !5, !noundef !3
  %4 = getelementptr inbounds { ptr, ptr }, ptr %_2, i32 0, i32 1
  %5 = load ptr, ptr %4, align 8, !nonnull !3, !align !5, !noundef !3
; call core::cmp::impls::<impl core::cmp::Ord for usize>::cmp
  %6 = call i8 @"_ZN4core3cmp5impls50_$LT$impl$u20$core..cmp..Ord$u20$for$u20$usize$GT$3cmp17hddbdb1ff9830cf98E"(ptr align 8 %3, ptr align 8 %5), !range !4
  ret i8 %6
}

; core::ptr::drop_in_place<alloc::string::String>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr42drop_in_place$LT$alloc..string..String$GT$17h6cd7d71abe930a69E"(ptr %_1) unnamed_addr #1 {
start:
; call core::ptr::drop_in_place<alloc::vec::Vec<u8>>
  call void @"_ZN4core3ptr46drop_in_place$LT$alloc..vec..Vec$LT$u8$GT$$GT$17hc5e5e91706219037E"(ptr %_1)
  ret void
}

; core::ptr::drop_in_place<alloc::vec::Vec<u8>>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr46drop_in_place$LT$alloc..vec..Vec$LT$u8$GT$$GT$17hc5e5e91706219037E"(ptr %_1) unnamed_addr #1 personality ptr @rust_eh_personality {
start:
  %0 = alloca { ptr, i32 }, align 8
; invoke <alloc::vec::Vec<T,A> as core::ops::drop::Drop>::drop
  invoke void @"_ZN70_$LT$alloc..vec..Vec$LT$T$C$A$GT$$u20$as$u20$core..ops..drop..Drop$GT$4drop17ha8dcd1046e4ff4ecE"(ptr align 8 %_1)
          to label %bb4 unwind label %cleanup

bb3:                                              ; preds = %cleanup
; invoke core::ptr::drop_in_place<alloc::raw_vec::RawVec<u8>>
  invoke void @"_ZN4core3ptr53drop_in_place$LT$alloc..raw_vec..RawVec$LT$u8$GT$$GT$17h33edb452fa940c71E"(ptr %_1) #18
          to label %bb1 unwind label %terminate

cleanup:                                          ; preds = %start
  %1 = landingpad { ptr, i32 }
          cleanup
  %2 = extractvalue { ptr, i32 } %1, 0
  %3 = extractvalue { ptr, i32 } %1, 1
  %4 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 0
  store ptr %2, ptr %4, align 8
  %5 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  store i32 %3, ptr %5, align 8
  br label %bb3

bb4:                                              ; preds = %start
; call core::ptr::drop_in_place<alloc::raw_vec::RawVec<u8>>
  call void @"_ZN4core3ptr53drop_in_place$LT$alloc..raw_vec..RawVec$LT$u8$GT$$GT$17h33edb452fa940c71E"(ptr %_1)
  ret void

terminate:                                        ; preds = %bb3
  %6 = landingpad { ptr, i32 }
          cleanup
  %7 = extractvalue { ptr, i32 } %6, 0
  %8 = extractvalue { ptr, i32 } %6, 1
; call core::panicking::panic_cannot_unwind
  call void @_ZN4core9panicking19panic_cannot_unwind17hc1edb5342d68b13dE() #19
  unreachable

bb1:                                              ; preds = %bb3
  %9 = load ptr, ptr %0, align 8, !noundef !3
  %10 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  %11 = load i32, ptr %10, align 8, !noundef !3
  %12 = insertvalue { ptr, i32 } poison, ptr %9, 0
  %13 = insertvalue { ptr, i32 } %12, i32 %11, 1
  resume { ptr, i32 } %13
}

; core::ptr::drop_in_place<[alloc::string::String]>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr52drop_in_place$LT$$u5b$alloc..string..String$u5d$$GT$17h2cf5df410a98099bE"(ptr %_1.0, i64 %_1.1) unnamed_addr #1 personality ptr @rust_eh_personality {
start:
  %0 = alloca { ptr, i32 }, align 8
  %_3 = alloca i64, align 8
  store i64 0, ptr %_3, align 8
  br label %bb6

bb6:                                              ; preds = %bb5, %start
  %1 = load i64, ptr %_3, align 8, !noundef !3
  %_7 = icmp eq i64 %1, %_1.1
  br i1 %_7, label %bb1, label %bb5

bb5:                                              ; preds = %bb6
  %2 = load i64, ptr %_3, align 8, !noundef !3
  %_6 = getelementptr inbounds [0 x %"alloc::string::String"], ptr %_1.0, i64 0, i64 %2
  %3 = load i64, ptr %_3, align 8, !noundef !3
  %4 = add i64 %3, 1
  store i64 %4, ptr %_3, align 8
; invoke core::ptr::drop_in_place<alloc::string::String>
  invoke void @"_ZN4core3ptr42drop_in_place$LT$alloc..string..String$GT$17h6cd7d71abe930a69E"(ptr %_6)
          to label %bb6 unwind label %cleanup

bb1:                                              ; preds = %bb6
  ret void

bb4:                                              ; preds = %bb3, %cleanup
  %5 = load i64, ptr %_3, align 8, !noundef !3
  %_5 = icmp eq i64 %5, %_1.1
  br i1 %_5, label %bb2, label %bb3

cleanup:                                          ; preds = %bb5
  %6 = landingpad { ptr, i32 }
          cleanup
  %7 = extractvalue { ptr, i32 } %6, 0
  %8 = extractvalue { ptr, i32 } %6, 1
  %9 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 0
  store ptr %7, ptr %9, align 8
  %10 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  store i32 %8, ptr %10, align 8
  br label %bb4

bb3:                                              ; preds = %bb4
  %11 = load i64, ptr %_3, align 8, !noundef !3
  %_4 = getelementptr inbounds [0 x %"alloc::string::String"], ptr %_1.0, i64 0, i64 %11
  %12 = load i64, ptr %_3, align 8, !noundef !3
  %13 = add i64 %12, 1
  store i64 %13, ptr %_3, align 8
; invoke core::ptr::drop_in_place<alloc::string::String>
  invoke void @"_ZN4core3ptr42drop_in_place$LT$alloc..string..String$GT$17h6cd7d71abe930a69E"(ptr %_4) #18
          to label %bb4 unwind label %terminate

bb2:                                              ; preds = %bb4
  %14 = load ptr, ptr %0, align 8, !noundef !3
  %15 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  %16 = load i32, ptr %15, align 8, !noundef !3
  %17 = insertvalue { ptr, i32 } poison, ptr %14, 0
  %18 = insertvalue { ptr, i32 } %17, i32 %16, 1
  resume { ptr, i32 } %18

terminate:                                        ; preds = %bb3
  %19 = landingpad { ptr, i32 }
          cleanup
  %20 = extractvalue { ptr, i32 } %19, 0
  %21 = extractvalue { ptr, i32 } %19, 1
; call core::panicking::panic_cannot_unwind
  call void @_ZN4core9panicking19panic_cannot_unwind17hc1edb5342d68b13dE() #19
  unreachable
}

; core::ptr::drop_in_place<alloc::raw_vec::RawVec<u8>>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr53drop_in_place$LT$alloc..raw_vec..RawVec$LT$u8$GT$$GT$17h33edb452fa940c71E"(ptr %_1) unnamed_addr #1 {
start:
; call <alloc::raw_vec::RawVec<T,A> as core::ops::drop::Drop>::drop
  call void @"_ZN77_$LT$alloc..raw_vec..RawVec$LT$T$C$A$GT$$u20$as$u20$core..ops..drop..Drop$GT$4drop17hce55bb6abaf3b60cE"(ptr align 8 %_1)
  ret void
}

; core::ptr::drop_in_place<alloc::vec::set_len_on_drop::SetLenOnDrop>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr62drop_in_place$LT$alloc..vec..set_len_on_drop..SetLenOnDrop$GT$17hfb3b02acb50c3d80E"(ptr %_1) unnamed_addr #1 {
start:
; call <alloc::vec::set_len_on_drop::SetLenOnDrop as core::ops::drop::Drop>::drop
  call void @"_ZN83_$LT$alloc..vec..set_len_on_drop..SetLenOnDrop$u20$as$u20$core..ops..drop..Drop$GT$4drop17hda9301cf823657f8E"(ptr align 8 %_1)
  ret void
}

; core::ptr::drop_in_place<alloc::vec::Vec<alloc::string::String>>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr65drop_in_place$LT$alloc..vec..Vec$LT$alloc..string..String$GT$$GT$17h04a4d05f7ef5ed5bE"(ptr %_1) unnamed_addr #1 personality ptr @rust_eh_personality {
start:
  %0 = alloca { ptr, i32 }, align 8
; invoke <alloc::vec::Vec<T,A> as core::ops::drop::Drop>::drop
  invoke void @"_ZN70_$LT$alloc..vec..Vec$LT$T$C$A$GT$$u20$as$u20$core..ops..drop..Drop$GT$4drop17h01b3817a5b2d5d93E"(ptr align 8 %_1)
          to label %bb4 unwind label %cleanup

bb3:                                              ; preds = %cleanup
; invoke core::ptr::drop_in_place<alloc::raw_vec::RawVec<alloc::string::String>>
  invoke void @"_ZN4core3ptr72drop_in_place$LT$alloc..raw_vec..RawVec$LT$alloc..string..String$GT$$GT$17h9d5dbfc761ef3938E"(ptr %_1) #18
          to label %bb1 unwind label %terminate

cleanup:                                          ; preds = %start
  %1 = landingpad { ptr, i32 }
          cleanup
  %2 = extractvalue { ptr, i32 } %1, 0
  %3 = extractvalue { ptr, i32 } %1, 1
  %4 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 0
  store ptr %2, ptr %4, align 8
  %5 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  store i32 %3, ptr %5, align 8
  br label %bb3

bb4:                                              ; preds = %start
; call core::ptr::drop_in_place<alloc::raw_vec::RawVec<alloc::string::String>>
  call void @"_ZN4core3ptr72drop_in_place$LT$alloc..raw_vec..RawVec$LT$alloc..string..String$GT$$GT$17h9d5dbfc761ef3938E"(ptr %_1)
  ret void

terminate:                                        ; preds = %bb3
  %6 = landingpad { ptr, i32 }
          cleanup
  %7 = extractvalue { ptr, i32 } %6, 0
  %8 = extractvalue { ptr, i32 } %6, 1
; call core::panicking::panic_cannot_unwind
  call void @_ZN4core9panicking19panic_cannot_unwind17hc1edb5342d68b13dE() #19
  unreachable

bb1:                                              ; preds = %bb3
  %9 = load ptr, ptr %0, align 8, !noundef !3
  %10 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  %11 = load i32, ptr %10, align 8, !noundef !3
  %12 = insertvalue { ptr, i32 } poison, ptr %9, 0
  %13 = insertvalue { ptr, i32 } %12, i32 %11, 1
  resume { ptr, i32 } %13
}

; core::ptr::drop_in_place<alloc::raw_vec::RawVec<alloc::string::String>>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr72drop_in_place$LT$alloc..raw_vec..RawVec$LT$alloc..string..String$GT$$GT$17h9d5dbfc761ef3938E"(ptr %_1) unnamed_addr #1 {
start:
; call <alloc::raw_vec::RawVec<T,A> as core::ops::drop::Drop>::drop
  call void @"_ZN77_$LT$alloc..raw_vec..RawVec$LT$T$C$A$GT$$u20$as$u20$core..ops..drop..Drop$GT$4drop17h2af0c9e6441e23c0E"(ptr align 8 %_1)
  ret void
}

; core::ptr::drop_in_place<alloc::vec::ExtendElement<alloc::string::String>>
; Function Attrs: uwtable
define internal void @"_ZN4core3ptr75drop_in_place$LT$alloc..vec..ExtendElement$LT$alloc..string..String$GT$$GT$17ha722e51a5cd1fa61E"(ptr %_1) unnamed_addr #1 {
start:
; call core::ptr::drop_in_place<alloc::string::String>
  call void @"_ZN4core3ptr42drop_in_place$LT$alloc..string..String$GT$17h6cd7d71abe930a69E"(ptr %_1)
  ret void
}

; core::ptr::drop_in_place<std::rt::lang_start<()>::{{closure}}>
; Function Attrs: inlinehint uwtable
define internal void @"_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17hc8602fbf372112e5E"(ptr %_1) unnamed_addr #2 {
start:
  ret void
}

; core::iter::range::<impl core::iter::traits::iterator::Iterator for core::ops::range::Range<A>>::next
; Function Attrs: inlinehint uwtable
define internal { i64, i64 } @"_ZN4core4iter5range101_$LT$impl$u20$core..iter..traits..iterator..Iterator$u20$for$u20$core..ops..range..Range$LT$A$GT$$GT$4next17hc6194987ce1a122fE"(ptr align 8 %self) unnamed_addr #2 {
start:
; call <core::ops::range::Range<T> as core::iter::range::RangeIteratorImpl>::spec_next
  %0 = call { i64, i64 } @"_ZN89_$LT$core..ops..range..Range$LT$T$GT$$u20$as$u20$core..iter..range..RangeIteratorImpl$GT$9spec_next17h09dd22fcc6c9c473E"(ptr align 8 %self)
  %1 = extractvalue { i64, i64 } %0, 0
  %2 = extractvalue { i64, i64 } %0, 1
  %3 = insertvalue { i64, i64 } poison, i64 %1, 0
  %4 = insertvalue { i64, i64 } %3, i64 %2, 1
  ret { i64, i64 } %4
}

; core::alloc::layout::Layout::array::inner
; Function Attrs: inlinehint uwtable
define internal { i64, i64 } @_ZN4core5alloc6layout6Layout5array5inner17h4877887aa62141d7E(i64 %element_size, i64 %align, i64 %n) unnamed_addr #2 {
start:
  %_19 = alloca i64, align 8
  %_15 = alloca i64, align 8
  %_10 = alloca { i64, i64 }, align 8
  %_4 = alloca i8, align 1
  %0 = alloca { i64, i64 }, align 8
  %1 = icmp eq i64 %element_size, 0
  br i1 %1, label %bb1, label %bb2

bb1:                                              ; preds = %start
  store i8 0, ptr %_4, align 1
  br label %bb3

bb2:                                              ; preds = %start
  store i64 %align, ptr %_15, align 8
  %_16 = load i64, ptr %_15, align 8, !range !7, !noundef !3
  %_17 = icmp uge i64 -9223372036854775808, %_16
  call void @llvm.assume(i1 %_17)
  %_18 = icmp ule i64 1, %_16
  call void @llvm.assume(i1 %_18)
  %_13 = sub i64 %_16, 1
  %_7 = sub i64 9223372036854775807, %_13
  %_8 = icmp eq i64 %element_size, 0
  %2 = call i1 @llvm.expect.i1(i1 %_8, i1 false)
  br i1 %2, label %panic, label %bb4

bb4:                                              ; preds = %bb2
  %_6 = udiv i64 %_7, %element_size
  %_5 = icmp ugt i64 %n, %_6
  %3 = zext i1 %_5 to i8
  store i8 %3, ptr %_4, align 1
  br label %bb3

panic:                                            ; preds = %bb2
; call core::panicking::panic
  call void @_ZN4core9panicking5panic17h593487776db43352E(ptr align 1 @str.1, i64 25, ptr align 8 @alloc_f67711e3bebe67d0f354d96d1ab6f3ce) #20
  unreachable

bb3:                                              ; preds = %bb1, %bb4
  %4 = load i8, ptr %_4, align 1, !range !6, !noundef !3
  %5 = trunc i8 %4 to i1
  br i1 %5, label %bb5, label %bb6

bb6:                                              ; preds = %bb3
  %array_size = mul i64 %element_size, %n
  store i64 %align, ptr %_19, align 8
  %_20 = load i64, ptr %_19, align 8, !range !7, !noundef !3
  %_21 = icmp uge i64 -9223372036854775808, %_20
  call void @llvm.assume(i1 %_21)
  %_22 = icmp ule i64 1, %_20
  call void @llvm.assume(i1 %_22)
  %6 = getelementptr inbounds { i64, i64 }, ptr %_10, i32 0, i32 1
  store i64 %array_size, ptr %6, align 8
  store i64 %_20, ptr %_10, align 8
  %7 = getelementptr inbounds { i64, i64 }, ptr %_10, i32 0, i32 0
  %8 = load i64, ptr %7, align 8, !range !7, !noundef !3
  %9 = getelementptr inbounds { i64, i64 }, ptr %_10, i32 0, i32 1
  %10 = load i64, ptr %9, align 8, !noundef !3
  %11 = getelementptr inbounds { i64, i64 }, ptr %0, i32 0, i32 0
  store i64 %8, ptr %11, align 8
  %12 = getelementptr inbounds { i64, i64 }, ptr %0, i32 0, i32 1
  store i64 %10, ptr %12, align 8
  br label %bb7

bb5:                                              ; preds = %bb3
  store i64 0, ptr %0, align 8
  br label %bb7

bb7:                                              ; preds = %bb6, %bb5
  %13 = getelementptr inbounds { i64, i64 }, ptr %0, i32 0, i32 0
  %14 = load i64, ptr %13, align 8, !range !8, !noundef !3
  %15 = getelementptr inbounds { i64, i64 }, ptr %0, i32 0, i32 1
  %16 = load i64, ptr %15, align 8
  %17 = insertvalue { i64, i64 } poison, i64 %14, 0
  %18 = insertvalue { i64, i64 } %17, i64 %16, 1
  ret { i64, i64 } %18
}

; core::result::Result<T,E>::map_err
; Function Attrs: inlinehint uwtable
define internal { i64, i64 } @"_ZN4core6result19Result$LT$T$C$E$GT$7map_err17h350a30cab275b65eE"(i64 %0, i64 %1) unnamed_addr #2 {
start:
  %_9 = alloca i8, align 1
  %_8 = alloca { i64, i64 }, align 8
  %2 = alloca { i64, i64 }, align 8
  %self = alloca { i64, i64 }, align 8
  %3 = getelementptr inbounds { i64, i64 }, ptr %self, i32 0, i32 0
  store i64 %0, ptr %3, align 8
  %4 = getelementptr inbounds { i64, i64 }, ptr %self, i32 0, i32 1
  store i64 %1, ptr %4, align 8
  store i8 1, ptr %_9, align 1
  %5 = load i64, ptr %self, align 8, !range !9, !noundef !3
  %6 = icmp eq i64 %5, -9223372036854775807
  %_3 = select i1 %6, i64 0, i64 1
  %7 = icmp eq i64 %_3, 0
  br i1 %7, label %bb3, label %bb1

bb3:                                              ; preds = %start
  store i64 -9223372036854775807, ptr %2, align 8
  br label %bb7

bb1:                                              ; preds = %start
  %8 = getelementptr inbounds { i64, i64 }, ptr %self, i32 0, i32 0
  %e.0 = load i64, ptr %8, align 8, !range !8, !noundef !3
  %9 = getelementptr inbounds { i64, i64 }, ptr %self, i32 0, i32 1
  %e.1 = load i64, ptr %9, align 8
  store i8 0, ptr %_9, align 1
  %10 = getelementptr inbounds { i64, i64 }, ptr %_8, i32 0, i32 0
  store i64 %e.0, ptr %10, align 8
  %11 = getelementptr inbounds { i64, i64 }, ptr %_8, i32 0, i32 1
  store i64 %e.1, ptr %11, align 8
  %12 = getelementptr inbounds { i64, i64 }, ptr %_8, i32 0, i32 0
  %13 = load i64, ptr %12, align 8, !range !8, !noundef !3
  %14 = getelementptr inbounds { i64, i64 }, ptr %_8, i32 0, i32 1
  %15 = load i64, ptr %14, align 8
; call alloc::raw_vec::handle_reserve::{{closure}}
  %16 = call { i64, i64 } @"_ZN5alloc7raw_vec14handle_reserve28_$u7b$$u7b$closure$u7d$$u7d$17h35f431cd41dce296E"(i64 %13, i64 %15)
  %_6.0 = extractvalue { i64, i64 } %16, 0
  %_6.1 = extractvalue { i64, i64 } %16, 1
  %17 = getelementptr inbounds { i64, i64 }, ptr %2, i32 0, i32 0
  store i64 %_6.0, ptr %17, align 8
  %18 = getelementptr inbounds { i64, i64 }, ptr %2, i32 0, i32 1
  store i64 %_6.1, ptr %18, align 8
  br label %bb7

bb2:                                              ; No predecessors!
  unreachable

bb7:                                              ; preds = %bb3, %bb1
  %19 = load i8, ptr %_9, align 1, !range !6, !noundef !3
  %20 = trunc i8 %19 to i1
  br i1 %20, label %bb6, label %bb5

bb5:                                              ; preds = %bb6, %bb7
  %21 = getelementptr inbounds { i64, i64 }, ptr %2, i32 0, i32 0
  %22 = load i64, ptr %21, align 8, !range !9, !noundef !3
  %23 = getelementptr inbounds { i64, i64 }, ptr %2, i32 0, i32 1
  %24 = load i64, ptr %23, align 8
  %25 = insertvalue { i64, i64 } poison, i64 %22, 0
  %26 = insertvalue { i64, i64 } %25, i64 %24, 1
  ret { i64, i64 } %26

bb6:                                              ; preds = %bb7
  br label %bb5
}

; core::result::Result<T,E>::map_err
; Function Attrs: inlinehint uwtable
define internal void @"_ZN4core6result19Result$LT$T$C$E$GT$7map_err17hb1559c0119ab9b83E"(ptr sret(%"core::result::Result<core::alloc::layout::Layout, alloc::collections::TryReserveErrorKind>") %0, i64 %1, i64 %2) unnamed_addr #2 {
start:
  %_9 = alloca i8, align 1
  %self = alloca { i64, i64 }, align 8
  %3 = getelementptr inbounds { i64, i64 }, ptr %self, i32 0, i32 0
  store i64 %1, ptr %3, align 8
  %4 = getelementptr inbounds { i64, i64 }, ptr %self, i32 0, i32 1
  store i64 %2, ptr %4, align 8
  store i8 1, ptr %_9, align 1
  %5 = load i64, ptr %self, align 8, !range !8, !noundef !3
  %6 = icmp eq i64 %5, 0
  %_3 = select i1 %6, i64 1, i64 0
  %7 = icmp eq i64 %_3, 0
  br i1 %7, label %bb3, label %bb1

bb3:                                              ; preds = %start
  %8 = getelementptr inbounds { i64, i64 }, ptr %self, i32 0, i32 0
  %t.0 = load i64, ptr %8, align 8, !range !7, !noundef !3
  %9 = getelementptr inbounds { i64, i64 }, ptr %self, i32 0, i32 1
  %t.1 = load i64, ptr %9, align 8, !noundef !3
  %10 = getelementptr inbounds %"core::result::Result<core::alloc::layout::Layout, alloc::collections::TryReserveErrorKind>::Ok", ptr %0, i32 0, i32 1
  %11 = getelementptr inbounds { i64, i64 }, ptr %10, i32 0, i32 0
  store i64 %t.0, ptr %11, align 8
  %12 = getelementptr inbounds { i64, i64 }, ptr %10, i32 0, i32 1
  store i64 %t.1, ptr %12, align 8
  store i64 0, ptr %0, align 8
  br label %bb7

bb1:                                              ; preds = %start
  store i8 0, ptr %_9, align 1
; call alloc::raw_vec::finish_grow::{{closure}}
  %13 = call { i64, i64 } @"_ZN5alloc7raw_vec11finish_grow28_$u7b$$u7b$closure$u7d$$u7d$17hb46065166eac7538E"()
  %_6.0 = extractvalue { i64, i64 } %13, 0
  %_6.1 = extractvalue { i64, i64 } %13, 1
  %14 = getelementptr inbounds %"core::result::Result<core::alloc::layout::Layout, alloc::collections::TryReserveErrorKind>::Err", ptr %0, i32 0, i32 1
  %15 = getelementptr inbounds { i64, i64 }, ptr %14, i32 0, i32 0
  store i64 %_6.0, ptr %15, align 8
  %16 = getelementptr inbounds { i64, i64 }, ptr %14, i32 0, i32 1
  store i64 %_6.1, ptr %16, align 8
  store i64 1, ptr %0, align 8
  br label %bb7

bb2:                                              ; No predecessors!
  unreachable

bb7:                                              ; preds = %bb3, %bb1
  %17 = load i8, ptr %_9, align 1, !range !6, !noundef !3
  %18 = trunc i8 %17 to i1
  br i1 %18, label %bb6, label %bb5

bb5:                                              ; preds = %bb6, %bb7
  ret void

bb6:                                              ; preds = %bb7
  br label %bb5
}

; core::result::Result<T,E>::map_err
; Function Attrs: inlinehint uwtable
define internal void @"_ZN4core6result19Result$LT$T$C$E$GT$7map_err17hc5becffe366b3a8dE"(ptr sret(%"core::result::Result<core::ptr::non_null::NonNull<[u8]>, alloc::collections::TryReserveError>") %0, ptr %1, i64 %2, ptr align 8 %op) unnamed_addr #2 {
start:
  %_9 = alloca i8, align 1
  %self = alloca { ptr, i64 }, align 8
  %3 = getelementptr inbounds { ptr, i64 }, ptr %self, i32 0, i32 0
  store ptr %1, ptr %3, align 8
  %4 = getelementptr inbounds { ptr, i64 }, ptr %self, i32 0, i32 1
  store i64 %2, ptr %4, align 8
  store i8 1, ptr %_9, align 1
  %5 = load ptr, ptr %self, align 8, !noundef !3
  %6 = ptrtoint ptr %5 to i64
  %7 = icmp eq i64 %6, 0
  %_3 = select i1 %7, i64 1, i64 0
  %8 = icmp eq i64 %_3, 0
  br i1 %8, label %bb3, label %bb1

bb3:                                              ; preds = %start
  %9 = getelementptr inbounds { ptr, i64 }, ptr %self, i32 0, i32 0
  %t.0 = load ptr, ptr %9, align 8, !nonnull !3, !noundef !3
  %10 = getelementptr inbounds { ptr, i64 }, ptr %self, i32 0, i32 1
  %t.1 = load i64, ptr %10, align 8, !noundef !3
  %11 = getelementptr inbounds %"core::result::Result<core::ptr::non_null::NonNull<[u8]>, alloc::collections::TryReserveError>::Ok", ptr %0, i32 0, i32 1
  %12 = getelementptr inbounds { ptr, i64 }, ptr %11, i32 0, i32 0
  store ptr %t.0, ptr %12, align 8
  %13 = getelementptr inbounds { ptr, i64 }, ptr %11, i32 0, i32 1
  store i64 %t.1, ptr %13, align 8
  store i64 0, ptr %0, align 8
  br label %bb7

bb1:                                              ; preds = %start
  store i8 0, ptr %_9, align 1
; call alloc::raw_vec::finish_grow::{{closure}}
  %14 = call { i64, i64 } @"_ZN5alloc7raw_vec11finish_grow28_$u7b$$u7b$closure$u7d$$u7d$17h8c2b1074a6dbf68aE"(ptr align 8 %op)
  %_6.0 = extractvalue { i64, i64 } %14, 0
  %_6.1 = extractvalue { i64, i64 } %14, 1
  %15 = getelementptr inbounds %"core::result::Result<core::ptr::non_null::NonNull<[u8]>, alloc::collections::TryReserveError>::Err", ptr %0, i32 0, i32 1
  %16 = getelementptr inbounds { i64, i64 }, ptr %15, i32 0, i32 0
  store i64 %_6.0, ptr %16, align 8
  %17 = getelementptr inbounds { i64, i64 }, ptr %15, i32 0, i32 1
  store i64 %_6.1, ptr %17, align 8
  store i64 1, ptr %0, align 8
  br label %bb7

bb2:                                              ; No predecessors!
  unreachable

bb7:                                              ; preds = %bb3, %bb1
  %18 = load i8, ptr %_9, align 1, !range !6, !noundef !3
  %19 = trunc i8 %18 to i1
  br i1 %19, label %bb6, label %bb5

bb5:                                              ; preds = %bb6, %bb7
  ret void

bb6:                                              ; preds = %bb7
  br label %bb5
}

; <T as alloc::slice::hack::ConvertVec>::to_vec
; Function Attrs: inlinehint uwtable
define internal void @"_ZN52_$LT$T$u20$as$u20$alloc..slice..hack..ConvertVec$GT$6to_vec17h8a9bfeef5ba2bf3fE"(ptr sret(%"alloc::vec::Vec<u8>") %self, ptr align 1 %s.0, i64 %s.1) unnamed_addr #2 personality ptr @rust_eh_personality {
start:
  %0 = alloca { ptr, i32 }, align 8
; invoke alloc::raw_vec::RawVec<T,A>::allocate_in
  %1 = invoke { ptr, i64 } @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$11allocate_in17h038c6f921a05b86fE"(i64 %s.1, i1 zeroext false)
          to label %bb4 unwind label %cleanup

bb3:                                              ; preds = %cleanup
  br i1 false, label %bb2, label %bb1

cleanup:                                          ; preds = %start
  %2 = landingpad { ptr, i32 }
          cleanup
  %3 = extractvalue { ptr, i32 } %2, 0
  %4 = extractvalue { ptr, i32 } %2, 1
  %5 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 0
  store ptr %3, ptr %5, align 8
  %6 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  store i32 %4, ptr %6, align 8
  br label %bb3

bb4:                                              ; preds = %start
  %_12.0 = extractvalue { ptr, i64 } %1, 0
  %_12.1 = extractvalue { ptr, i64 } %1, 1
  %7 = getelementptr inbounds { ptr, i64 }, ptr %self, i32 0, i32 0
  store ptr %_12.0, ptr %7, align 8
  %8 = getelementptr inbounds { ptr, i64 }, ptr %self, i32 0, i32 1
  store i64 %_12.1, ptr %8, align 8
  %9 = getelementptr inbounds %"alloc::vec::Vec<u8>", ptr %self, i32 0, i32 1
  store i64 0, ptr %9, align 8
  %self1 = load ptr, ptr %self, align 8, !nonnull !3, !noundef !3
  %10 = mul i64 %s.1, 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %self1, ptr align 1 %s.0, i64 %10, i1 false)
  %11 = getelementptr inbounds %"alloc::vec::Vec<u8>", ptr %self, i32 0, i32 1
  store i64 %s.1, ptr %11, align 8
  ret void

bb1:                                              ; preds = %bb2, %bb3
  %12 = load ptr, ptr %0, align 8, !noundef !3
  %13 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  %14 = load i32, ptr %13, align 8, !noundef !3
  %15 = insertvalue { ptr, i32 } poison, ptr %12, 0
  %16 = insertvalue { ptr, i32 } %15, i32 %14, 1
  resume { ptr, i32 } %16

bb2:                                              ; preds = %bb3
  br label %bb1
}

; <() as std::process::Termination>::report
; Function Attrs: inlinehint uwtable
define internal i8 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h615134f8c08cc0f9E"() unnamed_addr #2 {
start:
  ret i8 0
}

; alloc::vec::Vec<T,A>::extend_with
; Function Attrs: uwtable
define internal void @"_ZN5alloc3vec16Vec$LT$T$C$A$GT$11extend_with17he633fa170593b74fE"(ptr align 8 %self, i64 %n, ptr %value) unnamed_addr #1 personality ptr @rust_eh_personality {
start:
  %0 = alloca { ptr, i32 }, align 8
  %_37 = alloca %"alloc::string::String", align 8
  %_33 = alloca %"alloc::string::String", align 8
  %_27 = alloca i8, align 1
  %_25 = alloca %"alloc::vec::ExtendElement<alloc::string::String>", align 8
  %src2 = alloca %"alloc::string::String", align 8
  %src = alloca %"alloc::string::String", align 8
  %_13 = alloca { i64, i64 }, align 8
  %iter = alloca { i64, i64 }, align 8
  %self1 = alloca { i64, i64 }, align 8
  %local_len = alloca { ptr, i64 }, align 8
  %ptr = alloca ptr, align 8
  store i8 1, ptr %_27, align 1
; invoke alloc::vec::Vec<T,A>::reserve
  invoke void @"_ZN5alloc3vec16Vec$LT$T$C$A$GT$7reserve17hf5d16d545a275a31E"(ptr align 8 %self, i64 %n)
          to label %bb1 unwind label %cleanup

bb16:                                             ; preds = %bb12, %cleanup
  %1 = load i8, ptr %_27, align 1, !range !6, !noundef !3
  %2 = trunc i8 %1 to i1
  br i1 %2, label %bb15, label %bb13

cleanup:                                          ; preds = %bb9, %start
  %3 = landingpad { ptr, i32 }
          cleanup
  %4 = extractvalue { ptr, i32 } %3, 0
  %5 = extractvalue { ptr, i32 } %3, 1
  %6 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 0
  store ptr %4, ptr %6, align 8
  %7 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  store i32 %5, ptr %7, align 8
  br label %bb16

bb1:                                              ; preds = %start
  %self3 = load ptr, ptr %self, align 8, !nonnull !3, !noundef !3
  %8 = getelementptr inbounds %"alloc::vec::Vec<alloc::string::String>", ptr %self, i32 0, i32 1
  %count = load i64, ptr %8, align 8, !noundef !3
  %9 = getelementptr inbounds %"alloc::string::String", ptr %self3, i64 %count
  store ptr %9, ptr %ptr, align 8
  %len = getelementptr inbounds %"alloc::vec::Vec<alloc::string::String>", ptr %self, i32 0, i32 1
  %_32 = load i64, ptr %len, align 8, !noundef !3
  store ptr %len, ptr %local_len, align 8
  %10 = getelementptr inbounds { ptr, i64 }, ptr %local_len, i32 0, i32 1
  store i64 %_32, ptr %10, align 8
  store i64 1, ptr %self1, align 8
  %11 = getelementptr inbounds { i64, i64 }, ptr %self1, i32 0, i32 1
  store i64 %n, ptr %11, align 8
  %12 = getelementptr inbounds { i64, i64 }, ptr %self1, i32 0, i32 0
  %13 = load i64, ptr %12, align 8, !noundef !3
  %14 = getelementptr inbounds { i64, i64 }, ptr %self1, i32 0, i32 1
  %15 = load i64, ptr %14, align 8, !noundef !3
  %16 = getelementptr inbounds { i64, i64 }, ptr %iter, i32 0, i32 0
  store i64 %13, ptr %16, align 8
  %17 = getelementptr inbounds { i64, i64 }, ptr %iter, i32 0, i32 1
  store i64 %15, ptr %17, align 8
  br label %bb2

bb2:                                              ; preds = %bb6, %bb1
; invoke <core::ops::range::Range<T> as core::iter::range::RangeIteratorImpl>::spec_next
  %18 = invoke { i64, i64 } @"_ZN89_$LT$core..ops..range..Range$LT$T$GT$$u20$as$u20$core..iter..range..RangeIteratorImpl$GT$9spec_next17h09dd22fcc6c9c473E"(ptr align 8 %iter)
          to label %bb17 unwind label %cleanup4

bb12:                                             ; preds = %cleanup4
; invoke core::ptr::drop_in_place<alloc::vec::set_len_on_drop::SetLenOnDrop>
  invoke void @"_ZN4core3ptr62drop_in_place$LT$alloc..vec..set_len_on_drop..SetLenOnDrop$GT$17hfb3b02acb50c3d80E"(ptr %local_len) #18
          to label %bb16 unwind label %terminate

cleanup4:                                         ; preds = %bb7, %bb3, %bb2
  %19 = landingpad { ptr, i32 }
          cleanup
  %20 = extractvalue { ptr, i32 } %19, 0
  %21 = extractvalue { ptr, i32 } %19, 1
  %22 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 0
  store ptr %20, ptr %22, align 8
  %23 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  store i32 %21, ptr %23, align 8
  br label %bb12

bb17:                                             ; preds = %bb2
  store { i64, i64 } %18, ptr %_13, align 8
  %_15 = load i64, ptr %_13, align 8, !range !10, !noundef !3
  %24 = icmp eq i64 %_15, 0
  br i1 %24, label %bb5, label %bb3

bb5:                                              ; preds = %bb17
  %_22 = icmp ugt i64 %n, 0
  br i1 %_22, label %bb7, label %bb9

bb3:                                              ; preds = %bb17
  %dst = load ptr, ptr %ptr, align 8, !noundef !3
; invoke <alloc::vec::ExtendElement<T> as alloc::vec::ExtendWith<T>>::next
  invoke void @"_ZN86_$LT$alloc..vec..ExtendElement$LT$T$GT$$u20$as$u20$alloc..vec..ExtendWith$LT$T$GT$$GT$4next17hc325537dc3a4dbf3E"(ptr sret(%"alloc::string::String") %src, ptr align 8 %value)
          to label %bb6 unwind label %cleanup4

bb4:                                              ; No predecessors!
  unreachable

bb6:                                              ; preds = %bb3
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_33, ptr align 8 %src, i64 24, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %dst, ptr align 8 %_33, i64 24, i1 false)
  %self5 = load ptr, ptr %ptr, align 8, !noundef !3
  %_19 = getelementptr inbounds %"alloc::string::String", ptr %self5, i64 1
  store ptr %_19, ptr %ptr, align 8
  %25 = getelementptr inbounds { ptr, i64 }, ptr %local_len, i32 0, i32 1
  %26 = getelementptr inbounds { ptr, i64 }, ptr %local_len, i32 0, i32 1
  %27 = load i64, ptr %26, align 8, !noundef !3
  %28 = add i64 %27, 1
  store i64 %28, ptr %25, align 8
  br label %bb2

bb9:                                              ; preds = %bb8, %bb5
; invoke core::ptr::drop_in_place<alloc::vec::set_len_on_drop::SetLenOnDrop>
  invoke void @"_ZN4core3ptr62drop_in_place$LT$alloc..vec..set_len_on_drop..SetLenOnDrop$GT$17hfb3b02acb50c3d80E"(ptr %local_len)
          to label %bb10 unwind label %cleanup

bb7:                                              ; preds = %bb5
  %dst6 = load ptr, ptr %ptr, align 8, !noundef !3
  store i8 0, ptr %_27, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_25, ptr align 8 %value, i64 24, i1 false)
; invoke <alloc::vec::ExtendElement<T> as alloc::vec::ExtendWith<T>>::last
  invoke void @"_ZN86_$LT$alloc..vec..ExtendElement$LT$T$GT$$u20$as$u20$alloc..vec..ExtendWith$LT$T$GT$$GT$4last17hfbc8a84d4fb4ec8aE"(ptr sret(%"alloc::string::String") %src2, ptr %_25)
          to label %bb8 unwind label %cleanup4

bb8:                                              ; preds = %bb7
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_37, ptr align 8 %src2, i64 24, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %dst6, ptr align 8 %_37, i64 24, i1 false)
  %29 = getelementptr inbounds { ptr, i64 }, ptr %local_len, i32 0, i32 1
  %30 = getelementptr inbounds { ptr, i64 }, ptr %local_len, i32 0, i32 1
  %31 = load i64, ptr %30, align 8, !noundef !3
  %32 = add i64 %31, 1
  store i64 %32, ptr %29, align 8
  br label %bb9

terminate:                                        ; preds = %bb15, %bb12
  %33 = landingpad { ptr, i32 }
          cleanup
  %34 = extractvalue { ptr, i32 } %33, 0
  %35 = extractvalue { ptr, i32 } %33, 1
; call core::panicking::panic_cannot_unwind
  call void @_ZN4core9panicking19panic_cannot_unwind17hc1edb5342d68b13dE() #19
  unreachable

bb10:                                             ; preds = %bb9
  %36 = load i8, ptr %_27, align 1, !range !6, !noundef !3
  %37 = trunc i8 %36 to i1
  br i1 %37, label %bb14, label %bb11

bb13:                                             ; preds = %bb15, %bb16
  %38 = load ptr, ptr %0, align 8, !noundef !3
  %39 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  %40 = load i32, ptr %39, align 8, !noundef !3
  %41 = insertvalue { ptr, i32 } poison, ptr %38, 0
  %42 = insertvalue { ptr, i32 } %41, i32 %40, 1
  resume { ptr, i32 } %42

bb15:                                             ; preds = %bb16
; invoke core::ptr::drop_in_place<alloc::vec::ExtendElement<alloc::string::String>>
  invoke void @"_ZN4core3ptr75drop_in_place$LT$alloc..vec..ExtendElement$LT$alloc..string..String$GT$$GT$17ha722e51a5cd1fa61E"(ptr %value) #18
          to label %bb13 unwind label %terminate

bb11:                                             ; preds = %bb14, %bb10
  ret void

bb14:                                             ; preds = %bb10
; call core::ptr::drop_in_place<alloc::vec::ExtendElement<alloc::string::String>>
  call void @"_ZN4core3ptr75drop_in_place$LT$alloc..vec..ExtendElement$LT$alloc..string..String$GT$$GT$17ha722e51a5cd1fa61E"(ptr %value)
  br label %bb11
}

; alloc::vec::Vec<T,A>::reserve
; Function Attrs: uwtable
define internal void @"_ZN5alloc3vec16Vec$LT$T$C$A$GT$7reserve17hf5d16d545a275a31E"(ptr align 8 %self, i64 %additional) unnamed_addr #1 {
start:
  %self1 = alloca i64, align 8
  %0 = getelementptr inbounds %"alloc::vec::Vec<alloc::string::String>", ptr %self, i32 0, i32 1
  %len = load i64, ptr %0, align 8, !noundef !3
  br i1 false, label %bb3, label %bb4

bb4:                                              ; preds = %start
  %1 = getelementptr inbounds { ptr, i64 }, ptr %self, i32 0, i32 1
  %2 = load i64, ptr %1, align 8, !noundef !3
  store i64 %2, ptr %self1, align 8
  br label %bb5

bb3:                                              ; preds = %start
  store i64 -1, ptr %self1, align 8
  br label %bb5

bb5:                                              ; preds = %bb4, %bb3
  %3 = load i64, ptr %self1, align 8, !noundef !3
  %_8 = sub i64 %3, %len
  %_5 = icmp ugt i64 %additional, %_8
  br i1 %_5, label %bb1, label %bb2

bb2:                                              ; preds = %bb1, %bb5
  ret void

bb1:                                              ; preds = %bb5
; call alloc::raw_vec::RawVec<T,A>::reserve::do_reserve_and_handle
  call void @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$7reserve21do_reserve_and_handle17hf46bc6cfeb374978E"(ptr align 8 %self, i64 %len, i64 %additional)
  br label %bb2
}

; alloc::vec::from_elem
; Function Attrs: uwtable
define internal void @_ZN5alloc3vec9from_elem17h2cd305980e7ee4b4E(ptr sret(%"alloc::vec::Vec<alloc::string::String>") %0, ptr %elem, i64 %n) unnamed_addr #1 {
start:
; call <T as alloc::vec::spec_from_elem::SpecFromElem>::from_elem
  call void @"_ZN62_$LT$T$u20$as$u20$alloc..vec..spec_from_elem..SpecFromElem$GT$9from_elem17h45fe81c983382a83E"(ptr sret(%"alloc::vec::Vec<alloc::string::String>") %0, ptr %elem, i64 %n)
  ret void
}

; alloc::alloc::Global::alloc_impl
; Function Attrs: inlinehint uwtable
define internal { ptr, i64 } @_ZN5alloc5alloc6Global10alloc_impl17h6dcd190f2502bf97E(ptr align 1 %self, i64 %0, i64 %1, i1 zeroext %zeroed) unnamed_addr #2 {
start:
  %_77 = alloca { ptr, i64 }, align 8
  %_76 = alloca %"core::ptr::metadata::PtrRepr<[u8]>", align 8
  %_61 = alloca ptr, align 8
  %_60 = alloca ptr, align 8
  %_54 = alloca i64, align 8
  %_45 = alloca i64, align 8
  %_35 = alloca { ptr, i64 }, align 8
  %_34 = alloca %"core::ptr::metadata::PtrRepr<[u8]>", align 8
  %_22 = alloca i64, align 8
  %_18 = alloca { ptr, i64 }, align 8
  %self4 = alloca ptr, align 8
  %self3 = alloca ptr, align 8
  %_12 = alloca ptr, align 8
  %layout2 = alloca { i64, i64 }, align 8
  %layout1 = alloca { i64, i64 }, align 8
  %raw_ptr = alloca ptr, align 8
  %data = alloca ptr, align 8
  %_6 = alloca { ptr, i64 }, align 8
  %2 = alloca { ptr, i64 }, align 8
  %layout = alloca { i64, i64 }, align 8
  %3 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 0
  store i64 %0, ptr %3, align 8
  %4 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 1
  store i64 %1, ptr %4, align 8
  %5 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 1
  %size = load i64, ptr %5, align 8, !noundef !3
  %6 = icmp eq i64 %size, 0
  br i1 %6, label %bb2, label %bb1

bb2:                                              ; preds = %start
  %self10 = load i64, ptr %layout, align 8, !range !7, !noundef !3
  store i64 %self10, ptr %_22, align 8
  %_23 = load i64, ptr %_22, align 8, !range !7, !noundef !3
  %_24 = icmp uge i64 -9223372036854775808, %_23
  call void @llvm.assume(i1 %_24)
  %_25 = icmp ule i64 1, %_23
  call void @llvm.assume(i1 %_25)
  %ptr11 = inttoptr i64 %_23 to ptr
  store ptr %ptr11, ptr %data, align 8
  %_32 = load ptr, ptr %data, align 8, !noundef !3
  store ptr %_32, ptr %_35, align 8
  %7 = getelementptr inbounds { ptr, i64 }, ptr %_35, i32 0, i32 1
  store i64 0, ptr %7, align 8
  %8 = getelementptr inbounds { ptr, i64 }, ptr %_35, i32 0, i32 0
  %9 = load ptr, ptr %8, align 8, !noundef !3
  %10 = getelementptr inbounds { ptr, i64 }, ptr %_35, i32 0, i32 1
  %11 = load i64, ptr %10, align 8, !noundef !3
  %12 = getelementptr inbounds { ptr, i64 }, ptr %_34, i32 0, i32 0
  store ptr %9, ptr %12, align 8
  %13 = getelementptr inbounds { ptr, i64 }, ptr %_34, i32 0, i32 1
  store i64 %11, ptr %13, align 8
  %14 = getelementptr inbounds { ptr, i64 }, ptr %_34, i32 0, i32 0
  %ptr.012 = load ptr, ptr %14, align 8, !noundef !3
  %15 = getelementptr inbounds { ptr, i64 }, ptr %_34, i32 0, i32 1
  %ptr.113 = load i64, ptr %15, align 8, !noundef !3
  %16 = getelementptr inbounds { ptr, i64 }, ptr %_6, i32 0, i32 0
  store ptr %ptr.012, ptr %16, align 8
  %17 = getelementptr inbounds { ptr, i64 }, ptr %_6, i32 0, i32 1
  store i64 %ptr.113, ptr %17, align 8
  %18 = getelementptr inbounds { ptr, i64 }, ptr %_6, i32 0, i32 0
  %19 = load ptr, ptr %18, align 8, !nonnull !3, !noundef !3
  %20 = getelementptr inbounds { ptr, i64 }, ptr %_6, i32 0, i32 1
  %21 = load i64, ptr %20, align 8, !noundef !3
  %22 = getelementptr inbounds { ptr, i64 }, ptr %2, i32 0, i32 0
  store ptr %19, ptr %22, align 8
  %23 = getelementptr inbounds { ptr, i64 }, ptr %2, i32 0, i32 1
  store i64 %21, ptr %23, align 8
  br label %bb10

bb1:                                              ; preds = %start
  br i1 %zeroed, label %bb3, label %bb4

bb4:                                              ; preds = %bb1
  %24 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 0
  %25 = load i64, ptr %24, align 8, !range !7, !noundef !3
  %26 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 1
  %27 = load i64, ptr %26, align 8, !noundef !3
  %28 = getelementptr inbounds { i64, i64 }, ptr %layout2, i32 0, i32 0
  store i64 %25, ptr %28, align 8
  %29 = getelementptr inbounds { i64, i64 }, ptr %layout2, i32 0, i32 1
  store i64 %27, ptr %29, align 8
  %30 = getelementptr inbounds { i64, i64 }, ptr %layout2, i32 0, i32 1
  %_49 = load i64, ptr %30, align 8, !noundef !3
  %self6 = load i64, ptr %layout2, align 8, !range !7, !noundef !3
  store i64 %self6, ptr %_54, align 8
  %_55 = load i64, ptr %_54, align 8, !range !7, !noundef !3
  %_56 = icmp uge i64 -9223372036854775808, %_55
  call void @llvm.assume(i1 %_56)
  %_57 = icmp ule i64 1, %_55
  call void @llvm.assume(i1 %_57)
  %31 = call ptr @__rust_alloc(i64 %_49, i64 %_55) #21
  store ptr %31, ptr %raw_ptr, align 8
  br label %bb5

bb3:                                              ; preds = %bb1
  %32 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 0
  %33 = load i64, ptr %32, align 8, !range !7, !noundef !3
  %34 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 1
  %35 = load i64, ptr %34, align 8, !noundef !3
  %36 = getelementptr inbounds { i64, i64 }, ptr %layout1, i32 0, i32 0
  store i64 %33, ptr %36, align 8
  %37 = getelementptr inbounds { i64, i64 }, ptr %layout1, i32 0, i32 1
  store i64 %35, ptr %37, align 8
  %38 = getelementptr inbounds { i64, i64 }, ptr %layout1, i32 0, i32 1
  %_40 = load i64, ptr %38, align 8, !noundef !3
  %self5 = load i64, ptr %layout1, align 8, !range !7, !noundef !3
  store i64 %self5, ptr %_45, align 8
  %_46 = load i64, ptr %_45, align 8, !range !7, !noundef !3
  %_47 = icmp uge i64 -9223372036854775808, %_46
  call void @llvm.assume(i1 %_47)
  %_48 = icmp ule i64 1, %_46
  call void @llvm.assume(i1 %_48)
  %39 = call ptr @__rust_alloc_zeroed(i64 %_40, i64 %_46) #21
  store ptr %39, ptr %raw_ptr, align 8
  br label %bb5

bb5:                                              ; preds = %bb4, %bb3
  %ptr = load ptr, ptr %raw_ptr, align 8, !noundef !3
  store ptr %ptr, ptr %_61, align 8
  %ptr7 = load ptr, ptr %_61, align 8, !noundef !3
  %_63 = ptrtoint ptr %ptr7 to i64
  %_59 = icmp eq i64 %_63, 0
  %_58 = xor i1 %_59, true
  br i1 %_58, label %bb13, label %bb14

bb14:                                             ; preds = %bb5
  store ptr null, ptr %self4, align 8
  br label %bb15

bb13:                                             ; preds = %bb5
  store ptr %ptr, ptr %_60, align 8
  %40 = load ptr, ptr %_60, align 8, !nonnull !3, !noundef !3
  store ptr %40, ptr %self4, align 8
  br label %bb15

bb15:                                             ; preds = %bb14, %bb13
  %41 = load ptr, ptr %self4, align 8, !noundef !3
  %42 = ptrtoint ptr %41 to i64
  %43 = icmp eq i64 %42, 0
  %_68 = select i1 %43, i64 0, i64 1
  %44 = icmp eq i64 %_68, 0
  br i1 %44, label %bb16, label %bb17

bb16:                                             ; preds = %bb15
  store ptr null, ptr %self3, align 8
  br label %bb18

bb17:                                             ; preds = %bb15
  %v = load ptr, ptr %self4, align 8, !nonnull !3, !noundef !3
  store ptr %v, ptr %self3, align 8
  br label %bb18

bb18:                                             ; preds = %bb16, %bb17
  %45 = load ptr, ptr %self3, align 8, !noundef !3
  %46 = ptrtoint ptr %45 to i64
  %47 = icmp eq i64 %46, 0
  %_70 = select i1 %47, i64 1, i64 0
  %48 = icmp eq i64 %_70, 0
  br i1 %48, label %bb20, label %bb19

bb20:                                             ; preds = %bb18
  %v8 = load ptr, ptr %self3, align 8, !nonnull !3, !noundef !3
  store ptr %v8, ptr %_12, align 8
  br label %bb6

bb19:                                             ; preds = %bb18
  store ptr null, ptr %_12, align 8
  br label %bb6

bb6:                                              ; preds = %bb20, %bb19
  %49 = load ptr, ptr %_12, align 8, !noundef !3
  %50 = ptrtoint ptr %49 to i64
  %51 = icmp eq i64 %50, 0
  %_16 = select i1 %51, i64 1, i64 0
  %52 = icmp eq i64 %_16, 0
  br i1 %52, label %bb7, label %bb9

bb7:                                              ; preds = %bb6
  %ptr9 = load ptr, ptr %_12, align 8, !nonnull !3, !noundef !3
  store ptr %ptr9, ptr %_77, align 8
  %53 = getelementptr inbounds { ptr, i64 }, ptr %_77, i32 0, i32 1
  store i64 %size, ptr %53, align 8
  %54 = getelementptr inbounds { ptr, i64 }, ptr %_77, i32 0, i32 0
  %55 = load ptr, ptr %54, align 8, !noundef !3
  %56 = getelementptr inbounds { ptr, i64 }, ptr %_77, i32 0, i32 1
  %57 = load i64, ptr %56, align 8, !noundef !3
  %58 = getelementptr inbounds { ptr, i64 }, ptr %_76, i32 0, i32 0
  store ptr %55, ptr %58, align 8
  %59 = getelementptr inbounds { ptr, i64 }, ptr %_76, i32 0, i32 1
  store i64 %57, ptr %59, align 8
  %60 = getelementptr inbounds { ptr, i64 }, ptr %_76, i32 0, i32 0
  %ptr.0 = load ptr, ptr %60, align 8, !noundef !3
  %61 = getelementptr inbounds { ptr, i64 }, ptr %_76, i32 0, i32 1
  %ptr.1 = load i64, ptr %61, align 8, !noundef !3
  %62 = getelementptr inbounds { ptr, i64 }, ptr %_18, i32 0, i32 0
  store ptr %ptr.0, ptr %62, align 8
  %63 = getelementptr inbounds { ptr, i64 }, ptr %_18, i32 0, i32 1
  store i64 %ptr.1, ptr %63, align 8
  %64 = getelementptr inbounds { ptr, i64 }, ptr %_18, i32 0, i32 0
  %65 = load ptr, ptr %64, align 8, !nonnull !3, !noundef !3
  %66 = getelementptr inbounds { ptr, i64 }, ptr %_18, i32 0, i32 1
  %67 = load i64, ptr %66, align 8, !noundef !3
  %68 = getelementptr inbounds { ptr, i64 }, ptr %2, i32 0, i32 0
  store ptr %65, ptr %68, align 8
  %69 = getelementptr inbounds { ptr, i64 }, ptr %2, i32 0, i32 1
  store i64 %67, ptr %69, align 8
  br label %bb10

bb9:                                              ; preds = %bb6
  store ptr null, ptr %2, align 8
  br label %bb10

bb8:                                              ; No predecessors!
  unreachable

bb10:                                             ; preds = %bb2, %bb7, %bb9
  %70 = getelementptr inbounds { ptr, i64 }, ptr %2, i32 0, i32 0
  %71 = load ptr, ptr %70, align 8, !noundef !3
  %72 = getelementptr inbounds { ptr, i64 }, ptr %2, i32 0, i32 1
  %73 = load i64, ptr %72, align 8
  %74 = insertvalue { ptr, i64 } poison, ptr %71, 0
  %75 = insertvalue { ptr, i64 } %74, i64 %73, 1
  ret { ptr, i64 } %75
}

; alloc::alloc::Global::grow_impl
; Function Attrs: inlinehint uwtable
define internal { ptr, i64 } @_ZN5alloc5alloc6Global9grow_impl17ha90560a021c25a9bE(ptr align 1 %self, ptr %ptr, i64 %0, i64 %1, i64 %2, i64 %3, i1 zeroext %zeroed) unnamed_addr #2 {
start:
  %self4 = alloca ptr, align 8
  %_85 = alloca { ptr, i64 }, align 8
  %_84 = alloca %"core::ptr::metadata::PtrRepr<[u8]>", align 8
  %_67 = alloca ptr, align 8
  %_66 = alloca ptr, align 8
  %_60 = alloca i64, align 8
  %_50 = alloca i64, align 8
  %_45 = alloca i64, align 8
  %self3 = alloca { ptr, i64 }, align 8
  %_36 = alloca { ptr, i64 }, align 8
  %_35 = alloca { ptr, i64 }, align 8
  %self2 = alloca ptr, align 8
  %self1 = alloca ptr, align 8
  %_25 = alloca ptr, align 8
  %layout = alloca { i64, i64 }, align 8
  %4 = alloca { ptr, i64 }, align 8
  %new_layout = alloca { i64, i64 }, align 8
  %old_layout = alloca { i64, i64 }, align 8
  %5 = getelementptr inbounds { i64, i64 }, ptr %old_layout, i32 0, i32 0
  store i64 %0, ptr %5, align 8
  %6 = getelementptr inbounds { i64, i64 }, ptr %old_layout, i32 0, i32 1
  store i64 %1, ptr %6, align 8
  %7 = getelementptr inbounds { i64, i64 }, ptr %new_layout, i32 0, i32 0
  store i64 %2, ptr %7, align 8
  %8 = getelementptr inbounds { i64, i64 }, ptr %new_layout, i32 0, i32 1
  store i64 %3, ptr %8, align 8
  %9 = getelementptr inbounds { i64, i64 }, ptr %old_layout, i32 0, i32 1
  %old_size = load i64, ptr %9, align 8, !noundef !3
  %10 = icmp eq i64 %old_size, 0
  br i1 %10, label %bb1, label %bb2

bb1:                                              ; preds = %start
  %11 = getelementptr inbounds { i64, i64 }, ptr %new_layout, i32 0, i32 0
  %12 = load i64, ptr %11, align 8, !range !7, !noundef !3
  %13 = getelementptr inbounds { i64, i64 }, ptr %new_layout, i32 0, i32 1
  %14 = load i64, ptr %13, align 8, !noundef !3
; call alloc::alloc::Global::alloc_impl
  %15 = call { ptr, i64 } @_ZN5alloc5alloc6Global10alloc_impl17h6dcd190f2502bf97E(ptr align 1 %self, i64 %12, i64 %14, i1 zeroext %zeroed)
  store { ptr, i64 } %15, ptr %4, align 8
  br label %bb16

bb2:                                              ; preds = %start
  %self5 = load i64, ptr %old_layout, align 8, !range !7, !noundef !3
  store i64 %self5, ptr %_45, align 8
  %_46 = load i64, ptr %_45, align 8, !range !7, !noundef !3
  %_47 = icmp uge i64 -9223372036854775808, %_46
  call void @llvm.assume(i1 %_47)
  %_48 = icmp ule i64 1, %_46
  call void @llvm.assume(i1 %_48)
  %self6 = load i64, ptr %new_layout, align 8, !range !7, !noundef !3
  store i64 %self6, ptr %_50, align 8
  %_51 = load i64, ptr %_50, align 8, !range !7, !noundef !3
  %_52 = icmp uge i64 -9223372036854775808, %_51
  call void @llvm.assume(i1 %_52)
  %_53 = icmp ule i64 1, %_51
  call void @llvm.assume(i1 %_53)
  %_12 = icmp eq i64 %_46, %_51
  br i1 %_12, label %bb3, label %bb4

bb4:                                              ; preds = %bb2
  %16 = getelementptr inbounds { i64, i64 }, ptr %new_layout, i32 0, i32 0
  %17 = load i64, ptr %16, align 8, !range !7, !noundef !3
  %18 = getelementptr inbounds { i64, i64 }, ptr %new_layout, i32 0, i32 1
  %19 = load i64, ptr %18, align 8, !noundef !3
; call alloc::alloc::Global::alloc_impl
  %20 = call { ptr, i64 } @_ZN5alloc5alloc6Global10alloc_impl17h6dcd190f2502bf97E(ptr align 1 %self, i64 %17, i64 %19, i1 zeroext %zeroed)
  store { ptr, i64 } %20, ptr %self3, align 8
  %21 = load ptr, ptr %self3, align 8, !noundef !3
  %22 = ptrtoint ptr %21 to i64
  %23 = icmp eq i64 %22, 0
  %_90 = select i1 %23, i64 1, i64 0
  %24 = icmp eq i64 %_90, 0
  br i1 %24, label %bb28, label %bb27

bb3:                                              ; preds = %bb2
  %25 = getelementptr inbounds { i64, i64 }, ptr %new_layout, i32 0, i32 1
  %new_size = load i64, ptr %25, align 8, !noundef !3
  %26 = getelementptr inbounds { i64, i64 }, ptr %old_layout, i32 0, i32 1
  %_20 = load i64, ptr %26, align 8, !noundef !3
  %_19 = icmp uge i64 %new_size, %_20
  call void @llvm.assume(i1 %_19)
  %27 = getelementptr inbounds { i64, i64 }, ptr %old_layout, i32 0, i32 0
  %28 = load i64, ptr %27, align 8, !range !7, !noundef !3
  %29 = getelementptr inbounds { i64, i64 }, ptr %old_layout, i32 0, i32 1
  %30 = load i64, ptr %29, align 8, !noundef !3
  %31 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 0
  store i64 %28, ptr %31, align 8
  %32 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 1
  store i64 %30, ptr %32, align 8
  %33 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 1
  %_55 = load i64, ptr %33, align 8, !noundef !3
  %self7 = load i64, ptr %layout, align 8, !range !7, !noundef !3
  store i64 %self7, ptr %_60, align 8
  %_61 = load i64, ptr %_60, align 8, !range !7, !noundef !3
  %_62 = icmp uge i64 -9223372036854775808, %_61
  call void @llvm.assume(i1 %_62)
  %_63 = icmp ule i64 1, %_61
  call void @llvm.assume(i1 %_63)
  %raw_ptr = call ptr @__rust_realloc(ptr %ptr, i64 %_55, i64 %_61, i64 %new_size) #21
  store ptr %raw_ptr, ptr %_67, align 8
  %ptr8 = load ptr, ptr %_67, align 8, !noundef !3
  %_69 = ptrtoint ptr %ptr8 to i64
  %_65 = icmp eq i64 %_69, 0
  %_64 = xor i1 %_65, true
  br i1 %_64, label %bb18, label %bb19

bb19:                                             ; preds = %bb3
  store ptr null, ptr %self2, align 8
  br label %bb20

bb18:                                             ; preds = %bb3
  store ptr %raw_ptr, ptr %_66, align 8
  %34 = load ptr, ptr %_66, align 8, !nonnull !3, !noundef !3
  store ptr %34, ptr %self2, align 8
  br label %bb20

bb20:                                             ; preds = %bb19, %bb18
  %35 = load ptr, ptr %self2, align 8, !noundef !3
  %36 = ptrtoint ptr %35 to i64
  %37 = icmp eq i64 %36, 0
  %_74 = select i1 %37, i64 0, i64 1
  %38 = icmp eq i64 %_74, 0
  br i1 %38, label %bb21, label %bb22

bb21:                                             ; preds = %bb20
  store ptr null, ptr %self1, align 8
  br label %bb23

bb22:                                             ; preds = %bb20
  %v = load ptr, ptr %self2, align 8, !nonnull !3, !noundef !3
  store ptr %v, ptr %self1, align 8
  br label %bb23

bb23:                                             ; preds = %bb21, %bb22
  %39 = load ptr, ptr %self1, align 8, !noundef !3
  %40 = ptrtoint ptr %39 to i64
  %41 = icmp eq i64 %40, 0
  %_76 = select i1 %41, i64 1, i64 0
  %42 = icmp eq i64 %_76, 0
  br i1 %42, label %bb25, label %bb24

bb25:                                             ; preds = %bb23
  %v9 = load ptr, ptr %self1, align 8, !nonnull !3, !noundef !3
  store ptr %v9, ptr %_25, align 8
  br label %bb5

bb24:                                             ; preds = %bb23
  store ptr null, ptr %_25, align 8
  br label %bb5

bb5:                                              ; preds = %bb25, %bb24
  %43 = load ptr, ptr %_25, align 8, !noundef !3
  %44 = ptrtoint ptr %43 to i64
  %45 = icmp eq i64 %44, 0
  %_29 = select i1 %45, i64 1, i64 0
  %46 = icmp eq i64 %_29, 0
  br i1 %46, label %bb6, label %bb8

bb6:                                              ; preds = %bb5
  %ptr10 = load ptr, ptr %_25, align 8, !nonnull !3, !noundef !3
  br i1 %zeroed, label %bb9, label %bb10

bb8:                                              ; preds = %bb5
  store ptr null, ptr %4, align 8
  br label %bb16

bb16:                                             ; preds = %bb1, %bb13, %bb14, %bb10, %bb8
  %47 = getelementptr inbounds { ptr, i64 }, ptr %4, i32 0, i32 0
  %48 = load ptr, ptr %47, align 8, !noundef !3
  %49 = getelementptr inbounds { ptr, i64 }, ptr %4, i32 0, i32 1
  %50 = load i64, ptr %49, align 8
  %51 = insertvalue { ptr, i64 } poison, ptr %48, 0
  %52 = insertvalue { ptr, i64 } %51, i64 %50, 1
  ret { ptr, i64 } %52

bb10:                                             ; preds = %bb9, %bb6
  store ptr %ptr10, ptr %_85, align 8
  %53 = getelementptr inbounds { ptr, i64 }, ptr %_85, i32 0, i32 1
  store i64 %new_size, ptr %53, align 8
  %54 = getelementptr inbounds { ptr, i64 }, ptr %_85, i32 0, i32 0
  %55 = load ptr, ptr %54, align 8, !noundef !3
  %56 = getelementptr inbounds { ptr, i64 }, ptr %_85, i32 0, i32 1
  %57 = load i64, ptr %56, align 8, !noundef !3
  %58 = getelementptr inbounds { ptr, i64 }, ptr %_84, i32 0, i32 0
  store ptr %55, ptr %58, align 8
  %59 = getelementptr inbounds { ptr, i64 }, ptr %_84, i32 0, i32 1
  store i64 %57, ptr %59, align 8
  %60 = getelementptr inbounds { ptr, i64 }, ptr %_84, i32 0, i32 0
  %ptr.0 = load ptr, ptr %60, align 8, !noundef !3
  %61 = getelementptr inbounds { ptr, i64 }, ptr %_84, i32 0, i32 1
  %ptr.1 = load i64, ptr %61, align 8, !noundef !3
  %62 = getelementptr inbounds { ptr, i64 }, ptr %_35, i32 0, i32 0
  store ptr %ptr.0, ptr %62, align 8
  %63 = getelementptr inbounds { ptr, i64 }, ptr %_35, i32 0, i32 1
  store i64 %ptr.1, ptr %63, align 8
  %64 = getelementptr inbounds { ptr, i64 }, ptr %_35, i32 0, i32 0
  %65 = load ptr, ptr %64, align 8, !nonnull !3, !noundef !3
  %66 = getelementptr inbounds { ptr, i64 }, ptr %_35, i32 0, i32 1
  %67 = load i64, ptr %66, align 8, !noundef !3
  %68 = getelementptr inbounds { ptr, i64 }, ptr %4, i32 0, i32 0
  store ptr %65, ptr %68, align 8
  %69 = getelementptr inbounds { ptr, i64 }, ptr %4, i32 0, i32 1
  store i64 %67, ptr %69, align 8
  br label %bb16

bb9:                                              ; preds = %bb6
  %self11 = getelementptr inbounds i8, ptr %raw_ptr, i64 %old_size
  %count = sub i64 %new_size, %old_size
  %70 = mul i64 1, %count
  call void @llvm.memset.p0.i64(ptr align 1 %self11, i8 0, i64 %70, i1 false)
  br label %bb10

bb28:                                             ; preds = %bb4
  %71 = getelementptr inbounds { ptr, i64 }, ptr %self3, i32 0, i32 0
  %v.0 = load ptr, ptr %71, align 8, !nonnull !3, !noundef !3
  %72 = getelementptr inbounds { ptr, i64 }, ptr %self3, i32 0, i32 1
  %v.1 = load i64, ptr %72, align 8, !noundef !3
  %73 = getelementptr inbounds { ptr, i64 }, ptr %_36, i32 0, i32 0
  store ptr %v.0, ptr %73, align 8
  %74 = getelementptr inbounds { ptr, i64 }, ptr %_36, i32 0, i32 1
  store i64 %v.1, ptr %74, align 8
  br label %bb12

bb27:                                             ; preds = %bb4
  store ptr null, ptr %_36, align 8
  br label %bb12

bb12:                                             ; preds = %bb28, %bb27
  %75 = load ptr, ptr %_36, align 8, !noundef !3
  %76 = ptrtoint ptr %75 to i64
  %77 = icmp eq i64 %76, 0
  %_38 = select i1 %77, i64 1, i64 0
  %78 = icmp eq i64 %_38, 0
  br i1 %78, label %bb13, label %bb14

bb13:                                             ; preds = %bb12
  %79 = getelementptr inbounds { ptr, i64 }, ptr %_36, i32 0, i32 0
  %new_ptr.0 = load ptr, ptr %79, align 8, !nonnull !3, !noundef !3
  %80 = getelementptr inbounds { ptr, i64 }, ptr %_36, i32 0, i32 1
  %new_ptr.1 = load i64, ptr %80, align 8, !noundef !3
  store ptr %new_ptr.0, ptr %self4, align 8
  %_100 = load ptr, ptr %self4, align 8, !noundef !3
  %81 = mul i64 %old_size, 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %_100, ptr align 1 %ptr, i64 %81, i1 false)
  %82 = getelementptr inbounds { i64, i64 }, ptr %old_layout, i32 0, i32 0
  %83 = load i64, ptr %82, align 8, !range !7, !noundef !3
  %84 = getelementptr inbounds { i64, i64 }, ptr %old_layout, i32 0, i32 1
  %85 = load i64, ptr %84, align 8, !noundef !3
; call <alloc::alloc::Global as core::alloc::Allocator>::deallocate
  call void @"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$10deallocate17hb30a2b118e628153E"(ptr align 1 %self, ptr %ptr, i64 %83, i64 %85)
  %86 = getelementptr inbounds { ptr, i64 }, ptr %4, i32 0, i32 0
  store ptr %new_ptr.0, ptr %86, align 8
  %87 = getelementptr inbounds { ptr, i64 }, ptr %4, i32 0, i32 1
  store i64 %new_ptr.1, ptr %87, align 8
  br label %bb16

bb14:                                             ; preds = %bb12
  store ptr null, ptr %4, align 8
  br label %bb16

bb7:                                              ; No predecessors!
  unreachable
}

; alloc::raw_vec::finish_grow
; Function Attrs: noinline uwtable
define internal void @_ZN5alloc7raw_vec11finish_grow17h5a3577b705c185f7E(ptr sret(%"core::result::Result<core::ptr::non_null::NonNull<[u8]>, alloc::collections::TryReserveError>") %0, i64 %new_layout.0, i64 %new_layout.1, ptr %current_memory, ptr align 1 %alloc) unnamed_addr #0 {
start:
  %_53 = alloca i64, align 8
  %_48 = alloca i64, align 8
  %_43 = alloca { i64, i64 }, align 8
  %_39 = alloca { i64, i64 }, align 8
  %_37 = alloca { i64, i64 }, align 8
  %_32 = alloca ptr, align 8
  %old_layout = alloca { i64, i64 }, align 8
  %memory = alloca { ptr, i64 }, align 8
  %residual2 = alloca { i64, i64 }, align 8
  %self1 = alloca { i64, i64 }, align 8
  %_10 = alloca { i64, i64 }, align 8
  %residual = alloca { i64, i64 }, align 8
  %self = alloca %"core::result::Result<core::alloc::layout::Layout, alloc::collections::TryReserveErrorKind>", align 8
  %_5 = alloca %"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveErrorKind>, core::alloc::layout::Layout>", align 8
  %new_layout = alloca { i64, i64 }, align 8
; call core::result::Result<T,E>::map_err
  call void @"_ZN4core6result19Result$LT$T$C$E$GT$7map_err17hb1559c0119ab9b83E"(ptr sret(%"core::result::Result<core::alloc::layout::Layout, alloc::collections::TryReserveErrorKind>") %self, i64 %new_layout.0, i64 %new_layout.1)
  %_34 = load i64, ptr %self, align 8, !range !10, !noundef !3
  %1 = icmp eq i64 %_34, 0
  br i1 %1, label %bb18, label %bb17

bb18:                                             ; preds = %start
  %2 = getelementptr inbounds %"core::result::Result<core::alloc::layout::Layout, alloc::collections::TryReserveErrorKind>::Ok", ptr %self, i32 0, i32 1
  %3 = getelementptr inbounds { i64, i64 }, ptr %2, i32 0, i32 0
  %v.0 = load i64, ptr %3, align 8, !range !7, !noundef !3
  %4 = getelementptr inbounds { i64, i64 }, ptr %2, i32 0, i32 1
  %v.1 = load i64, ptr %4, align 8, !noundef !3
  %5 = getelementptr inbounds %"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveErrorKind>, core::alloc::layout::Layout>::Continue", ptr %_5, i32 0, i32 1
  %6 = getelementptr inbounds { i64, i64 }, ptr %5, i32 0, i32 0
  store i64 %v.0, ptr %6, align 8
  %7 = getelementptr inbounds { i64, i64 }, ptr %5, i32 0, i32 1
  store i64 %v.1, ptr %7, align 8
  store i64 0, ptr %_5, align 8
  br label %bb2

bb17:                                             ; preds = %start
  %8 = getelementptr inbounds %"core::result::Result<core::alloc::layout::Layout, alloc::collections::TryReserveErrorKind>::Err", ptr %self, i32 0, i32 1
  %9 = getelementptr inbounds { i64, i64 }, ptr %8, i32 0, i32 0
  %e.0 = load i64, ptr %9, align 8, !range !8, !noundef !3
  %10 = getelementptr inbounds { i64, i64 }, ptr %8, i32 0, i32 1
  %e.1 = load i64, ptr %10, align 8
  %11 = getelementptr inbounds { i64, i64 }, ptr %_37, i32 0, i32 0
  store i64 %e.0, ptr %11, align 8
  %12 = getelementptr inbounds { i64, i64 }, ptr %_37, i32 0, i32 1
  store i64 %e.1, ptr %12, align 8
  %13 = getelementptr inbounds { i64, i64 }, ptr %_37, i32 0, i32 0
  %14 = load i64, ptr %13, align 8, !range !8, !noundef !3
  %15 = getelementptr inbounds { i64, i64 }, ptr %_37, i32 0, i32 1
  %16 = load i64, ptr %15, align 8
  %17 = getelementptr inbounds %"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveErrorKind>, core::alloc::layout::Layout>::Break", ptr %_5, i32 0, i32 1
  %18 = getelementptr inbounds { i64, i64 }, ptr %17, i32 0, i32 0
  store i64 %14, ptr %18, align 8
  %19 = getelementptr inbounds { i64, i64 }, ptr %17, i32 0, i32 1
  store i64 %16, ptr %19, align 8
  store i64 1, ptr %_5, align 8
  br label %bb2

bb2:                                              ; preds = %bb18, %bb17
  %_7 = load i64, ptr %_5, align 8, !range !10, !noundef !3
  %20 = icmp eq i64 %_7, 0
  br i1 %20, label %bb3, label %bb5

bb3:                                              ; preds = %bb2
  %21 = getelementptr inbounds %"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveErrorKind>, core::alloc::layout::Layout>::Continue", ptr %_5, i32 0, i32 1
  %22 = getelementptr inbounds { i64, i64 }, ptr %21, i32 0, i32 0
  %val.0 = load i64, ptr %22, align 8, !range !7, !noundef !3
  %23 = getelementptr inbounds { i64, i64 }, ptr %21, i32 0, i32 1
  %val.1 = load i64, ptr %23, align 8, !noundef !3
  %24 = getelementptr inbounds { i64, i64 }, ptr %new_layout, i32 0, i32 0
  store i64 %val.0, ptr %24, align 8
  %25 = getelementptr inbounds { i64, i64 }, ptr %new_layout, i32 0, i32 1
  store i64 %val.1, ptr %25, align 8
  store i64 -9223372036854775807, ptr %self1, align 8
  %26 = load i64, ptr %self1, align 8, !range !9, !noundef !3
  %27 = icmp eq i64 %26, -9223372036854775807
  %_41 = select i1 %27, i64 0, i64 1
  %28 = icmp eq i64 %_41, 0
  br i1 %28, label %bb20, label %bb19

bb5:                                              ; preds = %bb2
  %29 = getelementptr inbounds %"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveErrorKind>, core::alloc::layout::Layout>::Break", ptr %_5, i32 0, i32 1
  %30 = getelementptr inbounds { i64, i64 }, ptr %29, i32 0, i32 0
  %31 = load i64, ptr %30, align 8, !range !8, !noundef !3
  %32 = getelementptr inbounds { i64, i64 }, ptr %29, i32 0, i32 1
  %33 = load i64, ptr %32, align 8
  %34 = getelementptr inbounds { i64, i64 }, ptr %residual, i32 0, i32 0
  store i64 %31, ptr %34, align 8
  %35 = getelementptr inbounds { i64, i64 }, ptr %residual, i32 0, i32 1
  store i64 %33, ptr %35, align 8
  %36 = getelementptr inbounds { i64, i64 }, ptr %residual, i32 0, i32 0
  %e.03 = load i64, ptr %36, align 8, !range !8, !noundef !3
  %37 = getelementptr inbounds { i64, i64 }, ptr %residual, i32 0, i32 1
  %e.14 = load i64, ptr %37, align 8
  %38 = getelementptr inbounds { i64, i64 }, ptr %_39, i32 0, i32 0
  store i64 %e.03, ptr %38, align 8
  %39 = getelementptr inbounds { i64, i64 }, ptr %_39, i32 0, i32 1
  store i64 %e.14, ptr %39, align 8
  %40 = getelementptr inbounds { i64, i64 }, ptr %_39, i32 0, i32 0
  %41 = load i64, ptr %40, align 8, !range !8, !noundef !3
  %42 = getelementptr inbounds { i64, i64 }, ptr %_39, i32 0, i32 1
  %43 = load i64, ptr %42, align 8
  %44 = getelementptr inbounds %"core::result::Result<core::ptr::non_null::NonNull<[u8]>, alloc::collections::TryReserveError>::Err", ptr %0, i32 0, i32 1
  %45 = getelementptr inbounds { i64, i64 }, ptr %44, i32 0, i32 0
  store i64 %41, ptr %45, align 8
  %46 = getelementptr inbounds { i64, i64 }, ptr %44, i32 0, i32 1
  store i64 %43, ptr %46, align 8
  store i64 1, ptr %0, align 8
  br label %bb15

bb15:                                             ; preds = %bb8, %bb5
  br label %bb16

bb20:                                             ; preds = %bb3
  store i64 -9223372036854775807, ptr %_10, align 8
  br label %bb6

bb19:                                             ; preds = %bb3
  %47 = getelementptr inbounds { i64, i64 }, ptr %self1, i32 0, i32 0
  %e.05 = load i64, ptr %47, align 8, !range !8, !noundef !3
  %48 = getelementptr inbounds { i64, i64 }, ptr %self1, i32 0, i32 1
  %e.16 = load i64, ptr %48, align 8
  %49 = getelementptr inbounds { i64, i64 }, ptr %_43, i32 0, i32 0
  store i64 %e.05, ptr %49, align 8
  %50 = getelementptr inbounds { i64, i64 }, ptr %_43, i32 0, i32 1
  store i64 %e.16, ptr %50, align 8
  %51 = getelementptr inbounds { i64, i64 }, ptr %_43, i32 0, i32 0
  %52 = load i64, ptr %51, align 8, !range !8, !noundef !3
  %53 = getelementptr inbounds { i64, i64 }, ptr %_43, i32 0, i32 1
  %54 = load i64, ptr %53, align 8
  %55 = getelementptr inbounds { i64, i64 }, ptr %_10, i32 0, i32 0
  store i64 %52, ptr %55, align 8
  %56 = getelementptr inbounds { i64, i64 }, ptr %_10, i32 0, i32 1
  store i64 %54, ptr %56, align 8
  br label %bb6

bb6:                                              ; preds = %bb20, %bb19
  %57 = load i64, ptr %_10, align 8, !range !9, !noundef !3
  %58 = icmp eq i64 %57, -9223372036854775807
  %_14 = select i1 %58, i64 0, i64 1
  %59 = icmp eq i64 %_14, 0
  br i1 %59, label %bb7, label %bb8

bb7:                                              ; preds = %bb6
  %60 = getelementptr inbounds %"core::option::Option<(core::ptr::non_null::NonNull<u8>, core::alloc::layout::Layout)>", ptr %current_memory, i32 0, i32 1
  %61 = load i64, ptr %60, align 8, !range !8, !noundef !3
  %62 = icmp eq i64 %61, 0
  %_17 = select i1 %62, i64 0, i64 1
  %63 = icmp eq i64 %_17, 1
  br i1 %63, label %bb10, label %bb9

bb8:                                              ; preds = %bb6
  %64 = getelementptr inbounds { i64, i64 }, ptr %_10, i32 0, i32 0
  %65 = load i64, ptr %64, align 8, !range !8, !noundef !3
  %66 = getelementptr inbounds { i64, i64 }, ptr %_10, i32 0, i32 1
  %67 = load i64, ptr %66, align 8
  %68 = getelementptr inbounds { i64, i64 }, ptr %residual2, i32 0, i32 0
  store i64 %65, ptr %68, align 8
  %69 = getelementptr inbounds { i64, i64 }, ptr %residual2, i32 0, i32 1
  store i64 %67, ptr %69, align 8
  %70 = getelementptr inbounds { i64, i64 }, ptr %residual2, i32 0, i32 0
  %e.07 = load i64, ptr %70, align 8, !range !8, !noundef !3
  %71 = getelementptr inbounds { i64, i64 }, ptr %residual2, i32 0, i32 1
  %e.18 = load i64, ptr %71, align 8
  %72 = getelementptr inbounds %"core::result::Result<core::ptr::non_null::NonNull<[u8]>, alloc::collections::TryReserveError>::Err", ptr %0, i32 0, i32 1
  %73 = getelementptr inbounds { i64, i64 }, ptr %72, i32 0, i32 0
  store i64 %e.07, ptr %73, align 8
  %74 = getelementptr inbounds { i64, i64 }, ptr %72, i32 0, i32 1
  store i64 %e.18, ptr %74, align 8
  store i64 1, ptr %0, align 8
  br label %bb15

bb4:                                              ; No predecessors!
  unreachable

bb16:                                             ; preds = %bb13, %bb15
  ret void

bb10:                                             ; preds = %bb7
  %ptr = load ptr, ptr %current_memory, align 8, !nonnull !3, !noundef !3
  %75 = getelementptr inbounds { ptr, { i64, i64 } }, ptr %current_memory, i32 0, i32 1
  %76 = getelementptr inbounds { i64, i64 }, ptr %75, i32 0, i32 0
  %77 = load i64, ptr %76, align 8, !range !7, !noundef !3
  %78 = getelementptr inbounds { i64, i64 }, ptr %75, i32 0, i32 1
  %79 = load i64, ptr %78, align 8, !noundef !3
  %80 = getelementptr inbounds { i64, i64 }, ptr %old_layout, i32 0, i32 0
  store i64 %77, ptr %80, align 8
  %81 = getelementptr inbounds { i64, i64 }, ptr %old_layout, i32 0, i32 1
  store i64 %79, ptr %81, align 8
  %self9 = load i64, ptr %old_layout, align 8, !range !7, !noundef !3
  store i64 %self9, ptr %_48, align 8
  %_49 = load i64, ptr %_48, align 8, !range !7, !noundef !3
  %_50 = icmp uge i64 -9223372036854775808, %_49
  call void @llvm.assume(i1 %_50)
  %_51 = icmp ule i64 1, %_49
  call void @llvm.assume(i1 %_51)
  %self10 = load i64, ptr %new_layout, align 8, !range !7, !noundef !3
  store i64 %self10, ptr %_53, align 8
  %_54 = load i64, ptr %_53, align 8, !range !7, !noundef !3
  %_55 = icmp uge i64 -9223372036854775808, %_54
  call void @llvm.assume(i1 %_55)
  %_56 = icmp ule i64 1, %_54
  call void @llvm.assume(i1 %_56)
  %_24 = icmp eq i64 %_49, %_54
  call void @llvm.assume(i1 %_24)
  %82 = getelementptr inbounds { i64, i64 }, ptr %old_layout, i32 0, i32 0
  %83 = load i64, ptr %82, align 8, !range !7, !noundef !3
  %84 = getelementptr inbounds { i64, i64 }, ptr %old_layout, i32 0, i32 1
  %85 = load i64, ptr %84, align 8, !noundef !3
; call <alloc::alloc::Global as core::alloc::Allocator>::grow
  %86 = call { ptr, i64 } @"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$4grow17hce6fd187504b5622E"(ptr align 1 %alloc, ptr %ptr, i64 %83, i64 %85, i64 %val.0, i64 %val.1)
  store { ptr, i64 } %86, ptr %memory, align 8
  br label %bb13

bb9:                                              ; preds = %bb7
; call <alloc::alloc::Global as core::alloc::Allocator>::allocate
  %87 = call { ptr, i64 } @"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$8allocate17he12ead4265c5f747E"(ptr align 1 %alloc, i64 %val.0, i64 %val.1)
  store { ptr, i64 } %87, ptr %memory, align 8
  br label %bb13

bb13:                                             ; preds = %bb10, %bb9
  %88 = getelementptr inbounds { ptr, i64 }, ptr %memory, i32 0, i32 0
  %_31.0 = load ptr, ptr %88, align 8, !noundef !3
  %89 = getelementptr inbounds { ptr, i64 }, ptr %memory, i32 0, i32 1
  %_31.1 = load i64, ptr %89, align 8
  store ptr %new_layout, ptr %_32, align 8
  %90 = load ptr, ptr %_32, align 8, !nonnull !3, !align !5, !noundef !3
; call core::result::Result<T,E>::map_err
  call void @"_ZN4core6result19Result$LT$T$C$E$GT$7map_err17hc5becffe366b3a8dE"(ptr sret(%"core::result::Result<core::ptr::non_null::NonNull<[u8]>, alloc::collections::TryReserveError>") %0, ptr %_31.0, i64 %_31.1, ptr align 8 %90)
  br label %bb16
}

; alloc::raw_vec::finish_grow::{{closure}}
; Function Attrs: inlinehint uwtable
define internal { i64, i64 } @"_ZN5alloc7raw_vec11finish_grow28_$u7b$$u7b$closure$u7d$$u7d$17h8c2b1074a6dbf68aE"(ptr align 8 %0) unnamed_addr #2 {
start:
  %self = alloca { i64, i64 }, align 8
  %1 = alloca { i64, i64 }, align 8
  %_1 = alloca ptr, align 8
  store ptr %0, ptr %_1, align 8
  %_5 = load ptr, ptr %_1, align 8, !nonnull !3, !align !5, !noundef !3
  %2 = getelementptr inbounds { i64, i64 }, ptr %_5, i32 0, i32 0
  %_4.0 = load i64, ptr %2, align 8, !range !7, !noundef !3
  %3 = getelementptr inbounds { i64, i64 }, ptr %_5, i32 0, i32 1
  %_4.1 = load i64, ptr %3, align 8, !noundef !3
  %4 = getelementptr inbounds { i64, i64 }, ptr %self, i32 0, i32 0
  store i64 %_4.0, ptr %4, align 8
  %5 = getelementptr inbounds { i64, i64 }, ptr %self, i32 0, i32 1
  store i64 %_4.1, ptr %5, align 8
  %6 = getelementptr inbounds { i64, i64 }, ptr %self, i32 0, i32 0
  %7 = load i64, ptr %6, align 8, !range !8, !noundef !3
  %8 = getelementptr inbounds { i64, i64 }, ptr %self, i32 0, i32 1
  %9 = load i64, ptr %8, align 8
  %10 = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 0
  store i64 %7, ptr %10, align 8
  %11 = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 1
  store i64 %9, ptr %11, align 8
  %12 = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 0
  %13 = load i64, ptr %12, align 8, !range !8, !noundef !3
  %14 = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 1
  %15 = load i64, ptr %14, align 8
  %16 = insertvalue { i64, i64 } poison, i64 %13, 0
  %17 = insertvalue { i64, i64 } %16, i64 %15, 1
  ret { i64, i64 } %17
}

; alloc::raw_vec::finish_grow::{{closure}}
; Function Attrs: inlinehint uwtable
define internal { i64, i64 } @"_ZN5alloc7raw_vec11finish_grow28_$u7b$$u7b$closure$u7d$$u7d$17hb46065166eac7538E"() unnamed_addr #2 {
start:
  %0 = alloca { i64, i64 }, align 8
  store i64 0, ptr %0, align 8
  %1 = getelementptr inbounds { i64, i64 }, ptr %0, i32 0, i32 0
  %2 = load i64, ptr %1, align 8, !range !8, !noundef !3
  %3 = getelementptr inbounds { i64, i64 }, ptr %0, i32 0, i32 1
  %4 = load i64, ptr %3, align 8
  %5 = insertvalue { i64, i64 } poison, i64 %2, 0
  %6 = insertvalue { i64, i64 } %5, i64 %4, 1
  ret { i64, i64 } %6
}

; alloc::raw_vec::handle_reserve
; Function Attrs: inlinehint uwtable
define internal void @_ZN5alloc7raw_vec14handle_reserve17h6950c74cc92b3b4fE(i64 %result.0, i64 %result.1) unnamed_addr #2 {
start:
  %_2 = alloca { i64, i64 }, align 8
; call core::result::Result<T,E>::map_err
  %0 = call { i64, i64 } @"_ZN4core6result19Result$LT$T$C$E$GT$7map_err17h350a30cab275b65eE"(i64 %result.0, i64 %result.1)
  store { i64, i64 } %0, ptr %_2, align 8
  %1 = load i64, ptr %_2, align 8, !range !9, !noundef !3
  %2 = icmp eq i64 %1, -9223372036854775807
  %_4 = select i1 %2, i64 0, i64 1
  %3 = icmp eq i64 %_4, 0
  br i1 %3, label %bb2, label %bb3

bb2:                                              ; preds = %start
  ret void

bb3:                                              ; preds = %start
  %4 = load i64, ptr %_2, align 8, !range !8, !noundef !3
  %5 = icmp eq i64 %4, 0
  %_3 = select i1 %5, i64 0, i64 1
  %6 = icmp eq i64 %_3, 0
  br i1 %6, label %bb5, label %bb6

bb5:                                              ; preds = %bb3
; call alloc::raw_vec::capacity_overflow
  call void @_ZN5alloc7raw_vec17capacity_overflow17hd5f837b05ce19c95E() #20
  unreachable

bb6:                                              ; preds = %bb3
  %7 = getelementptr inbounds { i64, i64 }, ptr %_2, i32 0, i32 0
  %layout.0 = load i64, ptr %7, align 8, !range !7, !noundef !3
  %8 = getelementptr inbounds { i64, i64 }, ptr %_2, i32 0, i32 1
  %layout.1 = load i64, ptr %8, align 8, !noundef !3
; call alloc::alloc::handle_alloc_error
  call void @_ZN5alloc5alloc18handle_alloc_error17h1202a93345cedb79E(i64 %layout.0, i64 %layout.1) #20
  unreachable

bb4:                                              ; No predecessors!
  unreachable
}

; alloc::raw_vec::handle_reserve::{{closure}}
; Function Attrs: inlinehint uwtable
define internal { i64, i64 } @"_ZN5alloc7raw_vec14handle_reserve28_$u7b$$u7b$closure$u7d$$u7d$17h35f431cd41dce296E"(i64 %0, i64 %1) unnamed_addr #2 {
start:
  %2 = alloca { i64, i64 }, align 8
  %e = alloca { i64, i64 }, align 8
  %3 = getelementptr inbounds { i64, i64 }, ptr %e, i32 0, i32 0
  store i64 %0, ptr %3, align 8
  %4 = getelementptr inbounds { i64, i64 }, ptr %e, i32 0, i32 1
  store i64 %1, ptr %4, align 8
  %5 = load i64, ptr %e, align 8, !range !8, !noundef !3
  %6 = icmp eq i64 %5, 0
  %_5 = select i1 %6, i64 0, i64 1
  %7 = icmp eq i64 %_5, 0
  br i1 %7, label %bb4, label %bb2

bb4:                                              ; preds = %start
  store i64 0, ptr %2, align 8
  br label %bb1

bb2:                                              ; preds = %start
  %8 = getelementptr inbounds { i64, i64 }, ptr %e, i32 0, i32 0
  %_8.0 = load i64, ptr %8, align 8, !range !7, !noundef !3
  %9 = getelementptr inbounds { i64, i64 }, ptr %e, i32 0, i32 1
  %_8.1 = load i64, ptr %9, align 8, !noundef !3
  %10 = getelementptr inbounds { i64, i64 }, ptr %2, i32 0, i32 0
  store i64 %_8.0, ptr %10, align 8
  %11 = getelementptr inbounds { i64, i64 }, ptr %2, i32 0, i32 1
  store i64 %_8.1, ptr %11, align 8
  br label %bb1

bb3:                                              ; No predecessors!
  unreachable

bb1:                                              ; preds = %bb4, %bb2
  %12 = getelementptr inbounds { i64, i64 }, ptr %2, i32 0, i32 0
  %13 = load i64, ptr %12, align 8, !range !8, !noundef !3
  %14 = getelementptr inbounds { i64, i64 }, ptr %2, i32 0, i32 1
  %15 = load i64, ptr %14, align 8
  %16 = insertvalue { i64, i64 } poison, i64 %13, 0
  %17 = insertvalue { i64, i64 } %16, i64 %15, 1
  ret { i64, i64 } %17
}

; alloc::raw_vec::RawVec<T,A>::allocate_in
; Function Attrs: uwtable
define internal { ptr, i64 } @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$11allocate_in17h038c6f921a05b86fE"(i64 %capacity, i1 zeroext %0) unnamed_addr #1 personality ptr @rust_eh_personality {
start:
  %1 = alloca { ptr, i32 }, align 8
  %_48 = alloca ptr, align 8
  %_30 = alloca ptr, align 8
  %_29 = alloca ptr, align 8
  %self = alloca ptr, align 8
  %_24 = alloca ptr, align 8
  %result = alloca { ptr, i64 }, align 8
  %_12 = alloca { i64, i64 }, align 8
  %_8 = alloca { i64, i64 }, align 8
  %_4 = alloca i8, align 1
  %2 = alloca { ptr, i64 }, align 8
  %alloc = alloca %"alloc::alloc::Global", align 1
  %init = alloca i8, align 1
  %3 = zext i1 %0 to i8
  store i8 %3, ptr %init, align 1
  br i1 false, label %bb1, label %bb2

bb2:                                              ; preds = %start
  %_5 = icmp eq i64 %capacity, 0
  %4 = zext i1 %_5 to i8
  store i8 %4, ptr %_4, align 1
  br label %bb3

bb1:                                              ; preds = %start
  store i8 1, ptr %_4, align 1
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %5 = load i8, ptr %_4, align 1, !range !6, !noundef !3
  %6 = trunc i8 %5 to i1
  br i1 %6, label %bb4, label %bb5

bb5:                                              ; preds = %bb3
; invoke core::alloc::layout::Layout::array::inner
  %7 = invoke { i64, i64 } @_ZN4core5alloc6layout6Layout5array5inner17h4877887aa62141d7E(i64 1, i64 1, i64 %capacity)
          to label %bb22 unwind label %cleanup

bb4:                                              ; preds = %bb3
  store ptr inttoptr (i64 1 to ptr), ptr %_30, align 8
  %8 = load ptr, ptr %_30, align 8, !nonnull !3, !noundef !3
  store ptr %8, ptr %_29, align 8
  %9 = load ptr, ptr %_29, align 8, !nonnull !3, !noundef !3
  store ptr %9, ptr %2, align 8
  %10 = getelementptr inbounds { ptr, i64 }, ptr %2, i32 0, i32 1
  store i64 0, ptr %10, align 8
  br label %bb18

bb18:                                             ; preds = %bb17, %bb4
  %11 = getelementptr inbounds { ptr, i64 }, ptr %2, i32 0, i32 0
  %12 = load ptr, ptr %11, align 8, !nonnull !3, !noundef !3
  %13 = getelementptr inbounds { ptr, i64 }, ptr %2, i32 0, i32 1
  %14 = load i64, ptr %13, align 8, !noundef !3
  %15 = insertvalue { ptr, i64 } poison, ptr %12, 0
  %16 = insertvalue { ptr, i64 } %15, i64 %14, 1
  ret { ptr, i64 } %16

bb21:                                             ; preds = %cleanup
  br i1 true, label %bb20, label %bb19

cleanup:                                          ; preds = %bb16, %bb12, %bb11, %bb9, %bb6, %bb5
  %17 = landingpad { ptr, i32 }
          cleanup
  %18 = extractvalue { ptr, i32 } %17, 0
  %19 = extractvalue { ptr, i32 } %17, 1
  %20 = getelementptr inbounds { ptr, i32 }, ptr %1, i32 0, i32 0
  store ptr %18, ptr %20, align 8
  %21 = getelementptr inbounds { ptr, i32 }, ptr %1, i32 0, i32 1
  store i32 %19, ptr %21, align 8
  br label %bb21

bb22:                                             ; preds = %bb5
  store { i64, i64 } %7, ptr %_8, align 8
  %22 = load i64, ptr %_8, align 8, !range !8, !noundef !3
  %23 = icmp eq i64 %22, 0
  %_9 = select i1 %23, i64 1, i64 0
  %24 = icmp eq i64 %_9, 0
  br i1 %24, label %bb8, label %bb6

bb8:                                              ; preds = %bb22
  %25 = getelementptr inbounds { i64, i64 }, ptr %_8, i32 0, i32 0
  %layout.0 = load i64, ptr %25, align 8, !range !7, !noundef !3
  %26 = getelementptr inbounds { i64, i64 }, ptr %_8, i32 0, i32 1
  %layout.1 = load i64, ptr %26, align 8, !noundef !3
  store i64 -9223372036854775807, ptr %_12, align 8
  %27 = load i64, ptr %_12, align 8, !range !9, !noundef !3
  %28 = icmp eq i64 %27, -9223372036854775807
  %_15 = select i1 %28, i64 0, i64 1
  %29 = icmp eq i64 %_15, 0
  br i1 %29, label %bb10, label %bb9

bb6:                                              ; preds = %bb22
; invoke alloc::raw_vec::capacity_overflow
  invoke void @_ZN5alloc7raw_vec17capacity_overflow17hd5f837b05ce19c95E() #20
          to label %unreachable unwind label %cleanup

unreachable:                                      ; preds = %bb16, %bb9, %bb6
  unreachable

bb10:                                             ; preds = %bb8
  %30 = load i8, ptr %init, align 1, !range !6, !noundef !3
  %31 = trunc i8 %30 to i1
  %_18 = zext i1 %31 to i64
  %32 = icmp eq i64 %_18, 0
  br i1 %32, label %bb12, label %bb11

bb9:                                              ; preds = %bb8
; invoke alloc::raw_vec::capacity_overflow
  invoke void @_ZN5alloc7raw_vec17capacity_overflow17hd5f837b05ce19c95E() #20
          to label %unreachable unwind label %cleanup

bb12:                                             ; preds = %bb10
; invoke <alloc::alloc::Global as core::alloc::Allocator>::allocate
  %33 = invoke { ptr, i64 } @"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$8allocate17he12ead4265c5f747E"(ptr align 1 %alloc, i64 %layout.0, i64 %layout.1)
          to label %bb13 unwind label %cleanup

bb11:                                             ; preds = %bb10
; invoke <alloc::alloc::Global as core::alloc::Allocator>::allocate_zeroed
  %34 = invoke { ptr, i64 } @"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$15allocate_zeroed17hc5282feef52ff2b4E"(ptr align 1 %alloc, i64 %layout.0, i64 %layout.1)
          to label %bb14 unwind label %cleanup

bb14:                                             ; preds = %bb11
  store { ptr, i64 } %34, ptr %result, align 8
  br label %bb15

bb15:                                             ; preds = %bb13, %bb14
  %35 = load ptr, ptr %result, align 8, !noundef !3
  %36 = ptrtoint ptr %35 to i64
  %37 = icmp eq i64 %36, 0
  %_21 = select i1 %37, i64 1, i64 0
  %38 = icmp eq i64 %_21, 0
  br i1 %38, label %bb17, label %bb16

bb13:                                             ; preds = %bb12
  store { ptr, i64 } %33, ptr %result, align 8
  br label %bb15

bb17:                                             ; preds = %bb15
  %39 = getelementptr inbounds { ptr, i64 }, ptr %result, i32 0, i32 0
  %ptr.0 = load ptr, ptr %39, align 8, !nonnull !3, !noundef !3
  %40 = getelementptr inbounds { ptr, i64 }, ptr %result, i32 0, i32 1
  %ptr.1 = load i64, ptr %40, align 8, !noundef !3
  store ptr %ptr.0, ptr %self, align 8
  %_47 = load ptr, ptr %self, align 8, !noundef !3
  store ptr %_47, ptr %_48, align 8
  %41 = load ptr, ptr %_48, align 8, !nonnull !3, !noundef !3
  store ptr %41, ptr %_24, align 8
  %42 = load ptr, ptr %_24, align 8, !nonnull !3, !noundef !3
  store ptr %42, ptr %2, align 8
  %43 = getelementptr inbounds { ptr, i64 }, ptr %2, i32 0, i32 1
  store i64 %capacity, ptr %43, align 8
  br label %bb18

bb16:                                             ; preds = %bb15
; invoke alloc::alloc::handle_alloc_error
  invoke void @_ZN5alloc5alloc18handle_alloc_error17h1202a93345cedb79E(i64 %layout.0, i64 %layout.1) #20
          to label %unreachable unwind label %cleanup

bb7:                                              ; No predecessors!
  unreachable

bb19:                                             ; preds = %bb20, %bb21
  %44 = load ptr, ptr %1, align 8, !noundef !3
  %45 = getelementptr inbounds { ptr, i32 }, ptr %1, i32 0, i32 1
  %46 = load i32, ptr %45, align 8, !noundef !3
  %47 = insertvalue { ptr, i32 } poison, ptr %44, 0
  %48 = insertvalue { ptr, i32 } %47, i32 %46, 1
  resume { ptr, i32 } %48

bb20:                                             ; preds = %bb21
  br label %bb19
}

; alloc::raw_vec::RawVec<T,A>::allocate_in
; Function Attrs: uwtable
define internal { ptr, i64 } @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$11allocate_in17h8a28efdab34a28b2E"(i64 %capacity, i1 zeroext %0) unnamed_addr #1 personality ptr @rust_eh_personality {
start:
  %1 = alloca { ptr, i32 }, align 8
  %_48 = alloca ptr, align 8
  %_30 = alloca ptr, align 8
  %_29 = alloca ptr, align 8
  %self = alloca ptr, align 8
  %_24 = alloca ptr, align 8
  %result = alloca { ptr, i64 }, align 8
  %_12 = alloca { i64, i64 }, align 8
  %_8 = alloca { i64, i64 }, align 8
  %_4 = alloca i8, align 1
  %2 = alloca { ptr, i64 }, align 8
  %alloc = alloca %"alloc::alloc::Global", align 1
  %init = alloca i8, align 1
  %3 = zext i1 %0 to i8
  store i8 %3, ptr %init, align 1
  br i1 false, label %bb1, label %bb2

bb2:                                              ; preds = %start
  %_5 = icmp eq i64 %capacity, 0
  %4 = zext i1 %_5 to i8
  store i8 %4, ptr %_4, align 1
  br label %bb3

bb1:                                              ; preds = %start
  store i8 1, ptr %_4, align 1
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %5 = load i8, ptr %_4, align 1, !range !6, !noundef !3
  %6 = trunc i8 %5 to i1
  br i1 %6, label %bb4, label %bb5

bb5:                                              ; preds = %bb3
; invoke core::alloc::layout::Layout::array::inner
  %7 = invoke { i64, i64 } @_ZN4core5alloc6layout6Layout5array5inner17h4877887aa62141d7E(i64 24, i64 8, i64 %capacity)
          to label %bb22 unwind label %cleanup

bb4:                                              ; preds = %bb3
  store ptr inttoptr (i64 8 to ptr), ptr %_30, align 8
  %8 = load ptr, ptr %_30, align 8, !nonnull !3, !noundef !3
  store ptr %8, ptr %_29, align 8
  %9 = load ptr, ptr %_29, align 8, !nonnull !3, !noundef !3
  store ptr %9, ptr %2, align 8
  %10 = getelementptr inbounds { ptr, i64 }, ptr %2, i32 0, i32 1
  store i64 0, ptr %10, align 8
  br label %bb18

bb18:                                             ; preds = %bb17, %bb4
  %11 = getelementptr inbounds { ptr, i64 }, ptr %2, i32 0, i32 0
  %12 = load ptr, ptr %11, align 8, !nonnull !3, !noundef !3
  %13 = getelementptr inbounds { ptr, i64 }, ptr %2, i32 0, i32 1
  %14 = load i64, ptr %13, align 8, !noundef !3
  %15 = insertvalue { ptr, i64 } poison, ptr %12, 0
  %16 = insertvalue { ptr, i64 } %15, i64 %14, 1
  ret { ptr, i64 } %16

bb21:                                             ; preds = %cleanup
  br i1 true, label %bb20, label %bb19

cleanup:                                          ; preds = %bb16, %bb12, %bb11, %bb9, %bb6, %bb5
  %17 = landingpad { ptr, i32 }
          cleanup
  %18 = extractvalue { ptr, i32 } %17, 0
  %19 = extractvalue { ptr, i32 } %17, 1
  %20 = getelementptr inbounds { ptr, i32 }, ptr %1, i32 0, i32 0
  store ptr %18, ptr %20, align 8
  %21 = getelementptr inbounds { ptr, i32 }, ptr %1, i32 0, i32 1
  store i32 %19, ptr %21, align 8
  br label %bb21

bb22:                                             ; preds = %bb5
  store { i64, i64 } %7, ptr %_8, align 8
  %22 = load i64, ptr %_8, align 8, !range !8, !noundef !3
  %23 = icmp eq i64 %22, 0
  %_9 = select i1 %23, i64 1, i64 0
  %24 = icmp eq i64 %_9, 0
  br i1 %24, label %bb8, label %bb6

bb8:                                              ; preds = %bb22
  %25 = getelementptr inbounds { i64, i64 }, ptr %_8, i32 0, i32 0
  %layout.0 = load i64, ptr %25, align 8, !range !7, !noundef !3
  %26 = getelementptr inbounds { i64, i64 }, ptr %_8, i32 0, i32 1
  %layout.1 = load i64, ptr %26, align 8, !noundef !3
  store i64 -9223372036854775807, ptr %_12, align 8
  %27 = load i64, ptr %_12, align 8, !range !9, !noundef !3
  %28 = icmp eq i64 %27, -9223372036854775807
  %_15 = select i1 %28, i64 0, i64 1
  %29 = icmp eq i64 %_15, 0
  br i1 %29, label %bb10, label %bb9

bb6:                                              ; preds = %bb22
; invoke alloc::raw_vec::capacity_overflow
  invoke void @_ZN5alloc7raw_vec17capacity_overflow17hd5f837b05ce19c95E() #20
          to label %unreachable unwind label %cleanup

unreachable:                                      ; preds = %bb16, %bb9, %bb6
  unreachable

bb10:                                             ; preds = %bb8
  %30 = load i8, ptr %init, align 1, !range !6, !noundef !3
  %31 = trunc i8 %30 to i1
  %_18 = zext i1 %31 to i64
  %32 = icmp eq i64 %_18, 0
  br i1 %32, label %bb12, label %bb11

bb9:                                              ; preds = %bb8
; invoke alloc::raw_vec::capacity_overflow
  invoke void @_ZN5alloc7raw_vec17capacity_overflow17hd5f837b05ce19c95E() #20
          to label %unreachable unwind label %cleanup

bb12:                                             ; preds = %bb10
; invoke <alloc::alloc::Global as core::alloc::Allocator>::allocate
  %33 = invoke { ptr, i64 } @"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$8allocate17he12ead4265c5f747E"(ptr align 1 %alloc, i64 %layout.0, i64 %layout.1)
          to label %bb13 unwind label %cleanup

bb11:                                             ; preds = %bb10
; invoke <alloc::alloc::Global as core::alloc::Allocator>::allocate_zeroed
  %34 = invoke { ptr, i64 } @"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$15allocate_zeroed17hc5282feef52ff2b4E"(ptr align 1 %alloc, i64 %layout.0, i64 %layout.1)
          to label %bb14 unwind label %cleanup

bb14:                                             ; preds = %bb11
  store { ptr, i64 } %34, ptr %result, align 8
  br label %bb15

bb15:                                             ; preds = %bb13, %bb14
  %35 = load ptr, ptr %result, align 8, !noundef !3
  %36 = ptrtoint ptr %35 to i64
  %37 = icmp eq i64 %36, 0
  %_21 = select i1 %37, i64 1, i64 0
  %38 = icmp eq i64 %_21, 0
  br i1 %38, label %bb17, label %bb16

bb13:                                             ; preds = %bb12
  store { ptr, i64 } %33, ptr %result, align 8
  br label %bb15

bb17:                                             ; preds = %bb15
  %39 = getelementptr inbounds { ptr, i64 }, ptr %result, i32 0, i32 0
  %ptr.0 = load ptr, ptr %39, align 8, !nonnull !3, !noundef !3
  %40 = getelementptr inbounds { ptr, i64 }, ptr %result, i32 0, i32 1
  %ptr.1 = load i64, ptr %40, align 8, !noundef !3
  store ptr %ptr.0, ptr %self, align 8
  %_47 = load ptr, ptr %self, align 8, !noundef !3
  store ptr %_47, ptr %_48, align 8
  %41 = load ptr, ptr %_48, align 8, !nonnull !3, !noundef !3
  store ptr %41, ptr %_24, align 8
  %42 = load ptr, ptr %_24, align 8, !nonnull !3, !noundef !3
  store ptr %42, ptr %2, align 8
  %43 = getelementptr inbounds { ptr, i64 }, ptr %2, i32 0, i32 1
  store i64 %capacity, ptr %43, align 8
  br label %bb18

bb16:                                             ; preds = %bb15
; invoke alloc::alloc::handle_alloc_error
  invoke void @_ZN5alloc5alloc18handle_alloc_error17h1202a93345cedb79E(i64 %layout.0, i64 %layout.1) #20
          to label %unreachable unwind label %cleanup

bb7:                                              ; No predecessors!
  unreachable

bb19:                                             ; preds = %bb20, %bb21
  %44 = load ptr, ptr %1, align 8, !noundef !3
  %45 = getelementptr inbounds { ptr, i32 }, ptr %1, i32 0, i32 1
  %46 = load i32, ptr %45, align 8, !noundef !3
  %47 = insertvalue { ptr, i32 } poison, ptr %44, 0
  %48 = insertvalue { ptr, i32 } %47, i32 %46, 1
  resume { ptr, i32 } %48

bb20:                                             ; preds = %bb21
  br label %bb19
}

; alloc::raw_vec::RawVec<T,A>::current_memory
; Function Attrs: uwtable
define internal void @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$14current_memory17haa45c820b2ded979E"(ptr sret(%"core::option::Option<(core::ptr::non_null::NonNull<u8>, core::alloc::layout::Layout)>") %0, ptr align 8 %self) unnamed_addr #1 {
start:
  %1 = alloca i64, align 8
  %_27 = alloca ptr, align 8
  %self2 = alloca ptr, align 8
  %self1 = alloca ptr, align 8
  %_12 = alloca ptr, align 8
  %_11 = alloca { ptr, { i64, i64 } }, align 8
  %layout = alloca { i64, i64 }, align 8
  %_2 = alloca i8, align 1
  br i1 false, label %bb1, label %bb2

bb2:                                              ; preds = %start
  %2 = getelementptr inbounds { ptr, i64 }, ptr %self, i32 0, i32 1
  %_4 = load i64, ptr %2, align 8, !noundef !3
  %_3 = icmp eq i64 %_4, 0
  %3 = zext i1 %_3 to i8
  store i8 %3, ptr %_2, align 1
  br label %bb3

bb1:                                              ; preds = %start
  store i8 1, ptr %_2, align 1
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %4 = load i8, ptr %_2, align 1, !range !6, !noundef !3
  %5 = trunc i8 %4 to i1
  br i1 %5, label %bb4, label %bb5

bb5:                                              ; preds = %bb3
  %6 = getelementptr inbounds { ptr, i64 }, ptr %self, i32 0, i32 1
  %rhs = load i64, ptr %6, align 8, !noundef !3
  %7 = mul nuw i64 1, %rhs
  store i64 %7, ptr %1, align 8
  %size = load i64, ptr %1, align 8, !noundef !3
  %8 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 1
  store i64 %size, ptr %8, align 8
  store i64 1, ptr %layout, align 8
  %self3 = load ptr, ptr %self, align 8, !nonnull !3, !noundef !3
  store ptr %self3, ptr %self2, align 8
  %_26 = load ptr, ptr %self2, align 8, !noundef !3
  store ptr %_26, ptr %_27, align 8
  %9 = load ptr, ptr %_27, align 8, !nonnull !3, !noundef !3
  store ptr %9, ptr %self1, align 8
  %self4 = load ptr, ptr %self1, align 8, !nonnull !3, !noundef !3
  store ptr %self4, ptr %_12, align 8
  %10 = load ptr, ptr %_12, align 8, !nonnull !3, !noundef !3
  store ptr %10, ptr %_11, align 8
  %11 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 0
  %12 = load i64, ptr %11, align 8, !range !7, !noundef !3
  %13 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 1
  %14 = load i64, ptr %13, align 8, !noundef !3
  %15 = getelementptr inbounds { ptr, { i64, i64 } }, ptr %_11, i32 0, i32 1
  %16 = getelementptr inbounds { i64, i64 }, ptr %15, i32 0, i32 0
  store i64 %12, ptr %16, align 8
  %17 = getelementptr inbounds { i64, i64 }, ptr %15, i32 0, i32 1
  store i64 %14, ptr %17, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %0, ptr align 8 %_11, i64 24, i1 false)
  br label %bb6

bb4:                                              ; preds = %bb3
  %18 = getelementptr inbounds %"core::option::Option<(core::ptr::non_null::NonNull<u8>, core::alloc::layout::Layout)>", ptr %0, i32 0, i32 1
  store i64 0, ptr %18, align 8
  br label %bb6

bb6:                                              ; preds = %bb5, %bb4
  ret void
}

; alloc::raw_vec::RawVec<T,A>::current_memory
; Function Attrs: uwtable
define internal void @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$14current_memory17hc85a3ae35d8850e2E"(ptr sret(%"core::option::Option<(core::ptr::non_null::NonNull<u8>, core::alloc::layout::Layout)>") %0, ptr align 8 %self) unnamed_addr #1 {
start:
  %1 = alloca i64, align 8
  %_27 = alloca ptr, align 8
  %self2 = alloca ptr, align 8
  %self1 = alloca ptr, align 8
  %_12 = alloca ptr, align 8
  %_11 = alloca { ptr, { i64, i64 } }, align 8
  %layout = alloca { i64, i64 }, align 8
  %_2 = alloca i8, align 1
  br i1 false, label %bb1, label %bb2

bb2:                                              ; preds = %start
  %2 = getelementptr inbounds { ptr, i64 }, ptr %self, i32 0, i32 1
  %_4 = load i64, ptr %2, align 8, !noundef !3
  %_3 = icmp eq i64 %_4, 0
  %3 = zext i1 %_3 to i8
  store i8 %3, ptr %_2, align 1
  br label %bb3

bb1:                                              ; preds = %start
  store i8 1, ptr %_2, align 1
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %4 = load i8, ptr %_2, align 1, !range !6, !noundef !3
  %5 = trunc i8 %4 to i1
  br i1 %5, label %bb4, label %bb5

bb5:                                              ; preds = %bb3
  %6 = getelementptr inbounds { ptr, i64 }, ptr %self, i32 0, i32 1
  %rhs = load i64, ptr %6, align 8, !noundef !3
  %7 = mul nuw i64 24, %rhs
  store i64 %7, ptr %1, align 8
  %size = load i64, ptr %1, align 8, !noundef !3
  %8 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 1
  store i64 %size, ptr %8, align 8
  store i64 8, ptr %layout, align 8
  %self3 = load ptr, ptr %self, align 8, !nonnull !3, !noundef !3
  store ptr %self3, ptr %self2, align 8
  %_26 = load ptr, ptr %self2, align 8, !noundef !3
  store ptr %_26, ptr %_27, align 8
  %9 = load ptr, ptr %_27, align 8, !nonnull !3, !noundef !3
  store ptr %9, ptr %self1, align 8
  %self4 = load ptr, ptr %self1, align 8, !nonnull !3, !noundef !3
  store ptr %self4, ptr %_12, align 8
  %10 = load ptr, ptr %_12, align 8, !nonnull !3, !noundef !3
  store ptr %10, ptr %_11, align 8
  %11 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 0
  %12 = load i64, ptr %11, align 8, !range !7, !noundef !3
  %13 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 1
  %14 = load i64, ptr %13, align 8, !noundef !3
  %15 = getelementptr inbounds { ptr, { i64, i64 } }, ptr %_11, i32 0, i32 1
  %16 = getelementptr inbounds { i64, i64 }, ptr %15, i32 0, i32 0
  store i64 %12, ptr %16, align 8
  %17 = getelementptr inbounds { i64, i64 }, ptr %15, i32 0, i32 1
  store i64 %14, ptr %17, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %0, ptr align 8 %_11, i64 24, i1 false)
  br label %bb6

bb4:                                              ; preds = %bb3
  %18 = getelementptr inbounds %"core::option::Option<(core::ptr::non_null::NonNull<u8>, core::alloc::layout::Layout)>", ptr %0, i32 0, i32 1
  store i64 0, ptr %18, align 8
  br label %bb6

bb6:                                              ; preds = %bb5, %bb4
  ret void
}

; alloc::raw_vec::RawVec<T,A>::grow_amortized
; Function Attrs: uwtable
define internal { i64, i64 } @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$14grow_amortized17hce10101221581c1aE"(ptr align 8 %self, i64 %len, i64 %additional) unnamed_addr #1 {
start:
  %0 = alloca i8, align 1
  %_58 = alloca { i64, i64 }, align 8
  %_49 = alloca { i64, i64 }, align 8
  %_47 = alloca { i64, i64 }, align 8
  %_34 = alloca { i64, i8 }, align 8
  %residual5 = alloca { i64, i64 }, align 8
  %_24 = alloca %"core::option::Option<(core::ptr::non_null::NonNull<u8>, core::alloc::layout::Layout)>", align 8
  %self4 = alloca %"core::result::Result<core::ptr::non_null::NonNull<[u8]>, alloc::collections::TryReserveError>", align 8
  %_21 = alloca %"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveError>, core::ptr::non_null::NonNull<[u8]>>", align 8
  %residual = alloca { i64, i64 }, align 8
  %err = alloca { i64, i64 }, align 8
  %self3 = alloca { i64, i64 }, align 8
  %self2 = alloca %"core::result::Result<usize, alloc::collections::TryReserveErrorKind>", align 8
  %_7 = alloca %"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveErrorKind>, usize>", align 8
  %self1 = alloca { i64, i64 }, align 8
  %_5 = alloca { i64, i64 }, align 8
  %1 = alloca { i64, i64 }, align 8
  br i1 false, label %bb1, label %bb3

bb3:                                              ; preds = %start
  %2 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %len, i64 %additional)
  %_38.0 = extractvalue { i64, i1 } %2, 0
  %_38.1 = extractvalue { i64, i1 } %2, 1
  store i64 %_38.0, ptr %_34, align 8
  %3 = getelementptr inbounds { i64, i8 }, ptr %_34, i32 0, i32 1
  %4 = zext i1 %_38.1 to i8
  store i8 %4, ptr %3, align 8
  %a = load i64, ptr %_34, align 8, !noundef !3
  %5 = getelementptr inbounds { i64, i8 }, ptr %_34, i32 0, i32 1
  %6 = load i8, ptr %5, align 8, !range !6, !noundef !3
  %b = trunc i8 %6 to i1
  %7 = call i1 @llvm.expect.i1(i1 %b, i1 false)
  %8 = zext i1 %7 to i8
  store i8 %8, ptr %0, align 1
  %9 = load i8, ptr %0, align 1, !range !6, !noundef !3
  %_35 = trunc i8 %9 to i1
  br i1 %_35, label %bb15, label %bb16

bb1:                                              ; preds = %start
  store i64 0, ptr %self1, align 8
  %10 = getelementptr inbounds { i64, i64 }, ptr %self1, i32 0, i32 0
  %11 = load i64, ptr %10, align 8, !range !8, !noundef !3
  %12 = getelementptr inbounds { i64, i64 }, ptr %self1, i32 0, i32 1
  %13 = load i64, ptr %12, align 8
  %14 = getelementptr inbounds { i64, i64 }, ptr %_5, i32 0, i32 0
  store i64 %11, ptr %14, align 8
  %15 = getelementptr inbounds { i64, i64 }, ptr %_5, i32 0, i32 1
  store i64 %13, ptr %15, align 8
  %16 = getelementptr inbounds { i64, i64 }, ptr %_5, i32 0, i32 0
  %17 = load i64, ptr %16, align 8, !range !8, !noundef !3
  %18 = getelementptr inbounds { i64, i64 }, ptr %_5, i32 0, i32 1
  %19 = load i64, ptr %18, align 8
  %20 = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 0
  store i64 %17, ptr %20, align 8
  %21 = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 1
  store i64 %19, ptr %21, align 8
  br label %bb13

bb13:                                             ; preds = %bb10, %bb11, %bb6, %bb1
  %22 = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 0
  %23 = load i64, ptr %22, align 8, !range !9, !noundef !3
  %24 = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 1
  %25 = load i64, ptr %24, align 8
  %26 = insertvalue { i64, i64 } poison, i64 %23, 0
  %27 = insertvalue { i64, i64 } %26, i64 %25, 1
  ret { i64, i64 } %27

bb16:                                             ; preds = %bb3
  %28 = getelementptr inbounds { i64, i64 }, ptr %self3, i32 0, i32 1
  store i64 %a, ptr %28, align 8
  store i64 1, ptr %self3, align 8
  br label %bb17

bb15:                                             ; preds = %bb3
  store i64 0, ptr %self3, align 8
  br label %bb17

bb17:                                             ; preds = %bb16, %bb15
  store i64 0, ptr %err, align 8
  %_42 = load i64, ptr %self3, align 8, !range !10, !noundef !3
  %29 = icmp eq i64 %_42, 0
  br i1 %29, label %bb18, label %bb19

bb18:                                             ; preds = %bb17
  %30 = getelementptr inbounds { i64, i64 }, ptr %err, i32 0, i32 0
  %31 = load i64, ptr %30, align 8, !range !8, !noundef !3
  %32 = getelementptr inbounds { i64, i64 }, ptr %err, i32 0, i32 1
  %33 = load i64, ptr %32, align 8
  %34 = getelementptr inbounds { i64, i64 }, ptr %self2, i32 0, i32 0
  store i64 %31, ptr %34, align 8
  %35 = getelementptr inbounds { i64, i64 }, ptr %self2, i32 0, i32 1
  store i64 %33, ptr %35, align 8
  br label %bb20

bb19:                                             ; preds = %bb17
  %36 = getelementptr inbounds { i64, i64 }, ptr %self3, i32 0, i32 1
  %v = load i64, ptr %36, align 8, !noundef !3
  %37 = getelementptr inbounds %"core::result::Result<usize, alloc::collections::TryReserveErrorKind>::Ok", ptr %self2, i32 0, i32 1
  store i64 %v, ptr %37, align 8
  store i64 -9223372036854775807, ptr %self2, align 8
  br label %bb20

bb20:                                             ; preds = %bb18, %bb19
  %38 = load i64, ptr %self2, align 8, !range !9, !noundef !3
  %39 = icmp eq i64 %38, -9223372036854775807
  %_44 = select i1 %39, i64 0, i64 1
  %40 = icmp eq i64 %_44, 0
  br i1 %40, label %bb22, label %bb21

bb22:                                             ; preds = %bb20
  %41 = getelementptr inbounds %"core::result::Result<usize, alloc::collections::TryReserveErrorKind>::Ok", ptr %self2, i32 0, i32 1
  %v6 = load i64, ptr %41, align 8, !noundef !3
  %42 = getelementptr inbounds %"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveErrorKind>, usize>::Continue", ptr %_7, i32 0, i32 1
  store i64 %v6, ptr %42, align 8
  store i64 -9223372036854775807, ptr %_7, align 8
  br label %bb4

bb21:                                             ; preds = %bb20
  %43 = getelementptr inbounds { i64, i64 }, ptr %self2, i32 0, i32 0
  %e.0 = load i64, ptr %43, align 8, !range !8, !noundef !3
  %44 = getelementptr inbounds { i64, i64 }, ptr %self2, i32 0, i32 1
  %e.1 = load i64, ptr %44, align 8
  %45 = getelementptr inbounds { i64, i64 }, ptr %_47, i32 0, i32 0
  store i64 %e.0, ptr %45, align 8
  %46 = getelementptr inbounds { i64, i64 }, ptr %_47, i32 0, i32 1
  store i64 %e.1, ptr %46, align 8
  %47 = getelementptr inbounds { i64, i64 }, ptr %_47, i32 0, i32 0
  %48 = load i64, ptr %47, align 8, !range !8, !noundef !3
  %49 = getelementptr inbounds { i64, i64 }, ptr %_47, i32 0, i32 1
  %50 = load i64, ptr %49, align 8
  %51 = getelementptr inbounds { i64, i64 }, ptr %_7, i32 0, i32 0
  store i64 %48, ptr %51, align 8
  %52 = getelementptr inbounds { i64, i64 }, ptr %_7, i32 0, i32 1
  store i64 %50, ptr %52, align 8
  br label %bb4

bb4:                                              ; preds = %bb22, %bb21
  %53 = load i64, ptr %_7, align 8, !range !9, !noundef !3
  %54 = icmp eq i64 %53, -9223372036854775807
  %_11 = select i1 %54, i64 0, i64 1
  %55 = icmp eq i64 %_11, 0
  br i1 %55, label %bb5, label %bb6

bb5:                                              ; preds = %bb4
  %56 = getelementptr inbounds %"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveErrorKind>, usize>::Continue", ptr %_7, i32 0, i32 1
  %required_cap = load i64, ptr %56, align 8, !noundef !3
  %57 = getelementptr inbounds { ptr, i64 }, ptr %self, i32 0, i32 1
  %_16 = load i64, ptr %57, align 8, !noundef !3
  %v1 = mul i64 %_16, 2
; call core::cmp::max_by
  %cap = call i64 @_ZN4core3cmp6max_by17h34c1161a8cbd3c60E(i64 %v1, i64 %required_cap)
; call core::cmp::max_by
  %cap9 = call i64 @_ZN4core3cmp6max_by17h34c1161a8cbd3c60E(i64 4, i64 %cap)
; call core::alloc::layout::Layout::array::inner
  %58 = call { i64, i64 } @_ZN4core5alloc6layout6Layout5array5inner17h4877887aa62141d7E(i64 24, i64 8, i64 %cap9)
  %new_layout.0 = extractvalue { i64, i64 } %58, 0
  %new_layout.1 = extractvalue { i64, i64 } %58, 1
; call alloc::raw_vec::RawVec<T,A>::current_memory
  call void @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$14current_memory17hc85a3ae35d8850e2E"(ptr sret(%"core::option::Option<(core::ptr::non_null::NonNull<u8>, core::alloc::layout::Layout)>") %_24, ptr align 8 %self)
; call alloc::raw_vec::finish_grow
  call void @_ZN5alloc7raw_vec11finish_grow17h5a3577b705c185f7E(ptr sret(%"core::result::Result<core::ptr::non_null::NonNull<[u8]>, alloc::collections::TryReserveError>") %self4, i64 %new_layout.0, i64 %new_layout.1, ptr %_24, ptr align 1 %self)
  %_55 = load i64, ptr %self4, align 8, !range !10, !noundef !3
  %59 = icmp eq i64 %_55, 0
  br i1 %59, label %bb27, label %bb26

bb6:                                              ; preds = %bb4
  %60 = getelementptr inbounds { i64, i64 }, ptr %_7, i32 0, i32 0
  %61 = load i64, ptr %60, align 8, !range !8, !noundef !3
  %62 = getelementptr inbounds { i64, i64 }, ptr %_7, i32 0, i32 1
  %63 = load i64, ptr %62, align 8
  %64 = getelementptr inbounds { i64, i64 }, ptr %residual, i32 0, i32 0
  store i64 %61, ptr %64, align 8
  %65 = getelementptr inbounds { i64, i64 }, ptr %residual, i32 0, i32 1
  store i64 %63, ptr %65, align 8
  %66 = getelementptr inbounds { i64, i64 }, ptr %residual, i32 0, i32 0
  %e.07 = load i64, ptr %66, align 8, !range !8, !noundef !3
  %67 = getelementptr inbounds { i64, i64 }, ptr %residual, i32 0, i32 1
  %e.18 = load i64, ptr %67, align 8
  %68 = getelementptr inbounds { i64, i64 }, ptr %_49, i32 0, i32 0
  store i64 %e.07, ptr %68, align 8
  %69 = getelementptr inbounds { i64, i64 }, ptr %_49, i32 0, i32 1
  store i64 %e.18, ptr %69, align 8
  %70 = getelementptr inbounds { i64, i64 }, ptr %_49, i32 0, i32 0
  %71 = load i64, ptr %70, align 8, !range !8, !noundef !3
  %72 = getelementptr inbounds { i64, i64 }, ptr %_49, i32 0, i32 1
  %73 = load i64, ptr %72, align 8
  %74 = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 0
  store i64 %71, ptr %74, align 8
  %75 = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 1
  store i64 %73, ptr %75, align 8
  br label %bb13

bb27:                                             ; preds = %bb5
  %76 = getelementptr inbounds %"core::result::Result<core::ptr::non_null::NonNull<[u8]>, alloc::collections::TryReserveError>::Ok", ptr %self4, i32 0, i32 1
  %77 = getelementptr inbounds { ptr, i64 }, ptr %76, i32 0, i32 0
  %v.0 = load ptr, ptr %77, align 8, !nonnull !3, !noundef !3
  %78 = getelementptr inbounds { ptr, i64 }, ptr %76, i32 0, i32 1
  %v.1 = load i64, ptr %78, align 8, !noundef !3
  %79 = getelementptr inbounds %"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveError>, core::ptr::non_null::NonNull<[u8]>>::Continue", ptr %_21, i32 0, i32 1
  %80 = getelementptr inbounds { ptr, i64 }, ptr %79, i32 0, i32 0
  store ptr %v.0, ptr %80, align 8
  %81 = getelementptr inbounds { ptr, i64 }, ptr %79, i32 0, i32 1
  store i64 %v.1, ptr %81, align 8
  store i64 0, ptr %_21, align 8
  br label %bb9

bb26:                                             ; preds = %bb5
  %82 = getelementptr inbounds %"core::result::Result<core::ptr::non_null::NonNull<[u8]>, alloc::collections::TryReserveError>::Err", ptr %self4, i32 0, i32 1
  %83 = getelementptr inbounds { i64, i64 }, ptr %82, i32 0, i32 0
  %e.010 = load i64, ptr %83, align 8, !range !8, !noundef !3
  %84 = getelementptr inbounds { i64, i64 }, ptr %82, i32 0, i32 1
  %e.111 = load i64, ptr %84, align 8
  %85 = getelementptr inbounds { i64, i64 }, ptr %_58, i32 0, i32 0
  store i64 %e.010, ptr %85, align 8
  %86 = getelementptr inbounds { i64, i64 }, ptr %_58, i32 0, i32 1
  store i64 %e.111, ptr %86, align 8
  %87 = getelementptr inbounds { i64, i64 }, ptr %_58, i32 0, i32 0
  %88 = load i64, ptr %87, align 8, !range !8, !noundef !3
  %89 = getelementptr inbounds { i64, i64 }, ptr %_58, i32 0, i32 1
  %90 = load i64, ptr %89, align 8
  %91 = getelementptr inbounds %"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveError>, core::ptr::non_null::NonNull<[u8]>>::Break", ptr %_21, i32 0, i32 1
  %92 = getelementptr inbounds { i64, i64 }, ptr %91, i32 0, i32 0
  store i64 %88, ptr %92, align 8
  %93 = getelementptr inbounds { i64, i64 }, ptr %91, i32 0, i32 1
  store i64 %90, ptr %93, align 8
  store i64 1, ptr %_21, align 8
  br label %bb9

bb9:                                              ; preds = %bb27, %bb26
  %_27 = load i64, ptr %_21, align 8, !range !10, !noundef !3
  %94 = icmp eq i64 %_27, 0
  br i1 %94, label %bb10, label %bb11

bb10:                                             ; preds = %bb9
  %95 = getelementptr inbounds %"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveError>, core::ptr::non_null::NonNull<[u8]>>::Continue", ptr %_21, i32 0, i32 1
  %96 = getelementptr inbounds { ptr, i64 }, ptr %95, i32 0, i32 0
  %ptr.0 = load ptr, ptr %96, align 8, !nonnull !3, !noundef !3
  %97 = getelementptr inbounds { ptr, i64 }, ptr %95, i32 0, i32 1
  %ptr.1 = load i64, ptr %97, align 8, !noundef !3
; call alloc::raw_vec::RawVec<T,A>::set_ptr_and_cap
  call void @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$15set_ptr_and_cap17h4083e308b1febc78E"(ptr align 8 %self, ptr %ptr.0, i64 %ptr.1, i64 %cap9)
  store i64 -9223372036854775807, ptr %1, align 8
  br label %bb13

bb11:                                             ; preds = %bb9
  %98 = getelementptr inbounds %"core::ops::control_flow::ControlFlow<core::result::Result<core::convert::Infallible, alloc::collections::TryReserveError>, core::ptr::non_null::NonNull<[u8]>>::Break", ptr %_21, i32 0, i32 1
  %99 = getelementptr inbounds { i64, i64 }, ptr %98, i32 0, i32 0
  %100 = load i64, ptr %99, align 8, !range !8, !noundef !3
  %101 = getelementptr inbounds { i64, i64 }, ptr %98, i32 0, i32 1
  %102 = load i64, ptr %101, align 8
  %103 = getelementptr inbounds { i64, i64 }, ptr %residual5, i32 0, i32 0
  store i64 %100, ptr %103, align 8
  %104 = getelementptr inbounds { i64, i64 }, ptr %residual5, i32 0, i32 1
  store i64 %102, ptr %104, align 8
  %105 = getelementptr inbounds { i64, i64 }, ptr %residual5, i32 0, i32 0
  %e.012 = load i64, ptr %105, align 8, !range !8, !noundef !3
  %106 = getelementptr inbounds { i64, i64 }, ptr %residual5, i32 0, i32 1
  %e.113 = load i64, ptr %106, align 8
  %107 = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 0
  store i64 %e.012, ptr %107, align 8
  %108 = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 1
  store i64 %e.113, ptr %108, align 8
  br label %bb13

bb2:                                              ; No predecessors!
  unreachable
}

; alloc::raw_vec::RawVec<T,A>::set_ptr_and_cap
; Function Attrs: uwtable
define internal void @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$15set_ptr_and_cap17h4083e308b1febc78E"(ptr align 8 %self, ptr %ptr.0, i64 %ptr.1, i64 %cap) unnamed_addr #1 {
start:
  %_14 = alloca ptr, align 8
  %self1 = alloca ptr, align 8
  %_4 = alloca ptr, align 8
  store ptr %ptr.0, ptr %self1, align 8
  %_13 = load ptr, ptr %self1, align 8, !noundef !3
  store ptr %_13, ptr %_14, align 8
  %0 = load ptr, ptr %_14, align 8, !nonnull !3, !noundef !3
  store ptr %0, ptr %_4, align 8
  %1 = load ptr, ptr %_4, align 8, !nonnull !3, !noundef !3
  store ptr %1, ptr %self, align 8
  %2 = getelementptr inbounds { ptr, i64 }, ptr %self, i32 0, i32 1
  store i64 %cap, ptr %2, align 8
  ret void
}

; alloc::raw_vec::RawVec<T,A>::reserve::do_reserve_and_handle
; Function Attrs: cold uwtable
define internal void @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$7reserve21do_reserve_and_handle17hf46bc6cfeb374978E"(ptr align 8 %slf, i64 %len, i64 %additional) unnamed_addr #3 {
start:
; call alloc::raw_vec::RawVec<T,A>::grow_amortized
  %0 = call { i64, i64 } @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$14grow_amortized17hce10101221581c1aE"(ptr align 8 %slf, i64 %len, i64 %additional)
  %_5.0 = extractvalue { i64, i64 } %0, 0
  %_5.1 = extractvalue { i64, i64 } %0, 1
; call alloc::raw_vec::handle_reserve
  call void @_ZN5alloc7raw_vec14handle_reserve17h6950c74cc92b3b4fE(i64 %_5.0, i64 %_5.1)
  ret void
}

; <T as alloc::vec::spec_from_elem::SpecFromElem>::from_elem
; Function Attrs: uwtable
define internal void @"_ZN62_$LT$T$u20$as$u20$alloc..vec..spec_from_elem..SpecFromElem$GT$9from_elem17h45fe81c983382a83E"(ptr sret(%"alloc::vec::Vec<alloc::string::String>") %_5, ptr %elem, i64 %n) unnamed_addr #1 personality ptr @rust_eh_personality {
start:
  %0 = alloca { ptr, i32 }, align 8
  %_8 = alloca i8, align 1
  %_7 = alloca %"alloc::string::String", align 8
  %_6 = alloca %"alloc::vec::ExtendElement<alloc::string::String>", align 8
  store i8 1, ptr %_8, align 1
; invoke alloc::raw_vec::RawVec<T,A>::allocate_in
  %1 = invoke { ptr, i64 } @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$11allocate_in17h8a28efdab34a28b2E"(i64 %n, i1 zeroext false)
          to label %bb6 unwind label %cleanup

bb5:                                              ; preds = %bb2, %cleanup
  %2 = load i8, ptr %_8, align 1, !range !6, !noundef !3
  %3 = trunc i8 %2 to i1
  br i1 %3, label %bb4, label %bb3

cleanup:                                          ; preds = %start
  %4 = landingpad { ptr, i32 }
          cleanup
  %5 = extractvalue { ptr, i32 } %4, 0
  %6 = extractvalue { ptr, i32 } %4, 1
  %7 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 0
  store ptr %5, ptr %7, align 8
  %8 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  store i32 %6, ptr %8, align 8
  br label %bb5

bb6:                                              ; preds = %start
  %_9.0 = extractvalue { ptr, i64 } %1, 0
  %_9.1 = extractvalue { ptr, i64 } %1, 1
  %9 = getelementptr inbounds { ptr, i64 }, ptr %_5, i32 0, i32 0
  store ptr %_9.0, ptr %9, align 8
  %10 = getelementptr inbounds { ptr, i64 }, ptr %_5, i32 0, i32 1
  store i64 %_9.1, ptr %10, align 8
  %11 = getelementptr inbounds %"alloc::vec::Vec<alloc::string::String>", ptr %_5, i32 0, i32 1
  store i64 0, ptr %11, align 8
  store i8 0, ptr %_8, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_7, ptr align 8 %elem, i64 24, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_6, ptr align 8 %_7, i64 24, i1 false)
; invoke alloc::vec::Vec<T,A>::extend_with
  invoke void @"_ZN5alloc3vec16Vec$LT$T$C$A$GT$11extend_with17he633fa170593b74fE"(ptr align 8 %_5, i64 %n, ptr %_6)
          to label %bb1 unwind label %cleanup1

bb2:                                              ; preds = %cleanup1
; invoke core::ptr::drop_in_place<alloc::vec::Vec<alloc::string::String>>
  invoke void @"_ZN4core3ptr65drop_in_place$LT$alloc..vec..Vec$LT$alloc..string..String$GT$$GT$17h04a4d05f7ef5ed5bE"(ptr %_5) #18
          to label %bb5 unwind label %terminate

cleanup1:                                         ; preds = %bb6
  %12 = landingpad { ptr, i32 }
          cleanup
  %13 = extractvalue { ptr, i32 } %12, 0
  %14 = extractvalue { ptr, i32 } %12, 1
  %15 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 0
  store ptr %13, ptr %15, align 8
  %16 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  store i32 %14, ptr %16, align 8
  br label %bb2

bb1:                                              ; preds = %bb6
  ret void

terminate:                                        ; preds = %bb4, %bb2
  %17 = landingpad { ptr, i32 }
          cleanup
  %18 = extractvalue { ptr, i32 } %17, 0
  %19 = extractvalue { ptr, i32 } %17, 1
; call core::panicking::panic_cannot_unwind
  call void @_ZN4core9panicking19panic_cannot_unwind17hc1edb5342d68b13dE() #19
  unreachable

bb3:                                              ; preds = %bb4, %bb5
  %20 = load ptr, ptr %0, align 8, !noundef !3
  %21 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  %22 = load i32, ptr %21, align 8, !noundef !3
  %23 = insertvalue { ptr, i32 } poison, ptr %20, 0
  %24 = insertvalue { ptr, i32 } %23, i32 %22, 1
  resume { ptr, i32 } %24

bb4:                                              ; preds = %bb5
; invoke core::ptr::drop_in_place<alloc::string::String>
  invoke void @"_ZN4core3ptr42drop_in_place$LT$alloc..string..String$GT$17h6cd7d71abe930a69E"(ptr %elem) #18
          to label %bb3 unwind label %terminate
}

; <I as core::iter::traits::collect::IntoIterator>::into_iter
; Function Attrs: inlinehint uwtable
define internal { i64, i64 } @"_ZN63_$LT$I$u20$as$u20$core..iter..traits..collect..IntoIterator$GT$9into_iter17h411f8ab9df8a6246E"(i64 %self.0, i64 %self.1) unnamed_addr #2 {
start:
  %0 = insertvalue { i64, i64 } poison, i64 %self.0, 0
  %1 = insertvalue { i64, i64 } %0, i64 %self.1, 1
  ret { i64, i64 } %1
}

; <alloc::alloc::Global as core::alloc::Allocator>::deallocate
; Function Attrs: inlinehint uwtable
define internal void @"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$10deallocate17hb30a2b118e628153E"(ptr align 1 %self, ptr %ptr, i64 %0, i64 %1) unnamed_addr #2 {
start:
  %_14 = alloca i64, align 8
  %layout1 = alloca { i64, i64 }, align 8
  %layout = alloca { i64, i64 }, align 8
  %2 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 0
  store i64 %0, ptr %2, align 8
  %3 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 1
  store i64 %1, ptr %3, align 8
  %4 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 1
  %_4 = load i64, ptr %4, align 8, !noundef !3
  %5 = icmp eq i64 %_4, 0
  br i1 %5, label %bb2, label %bb1

bb2:                                              ; preds = %start
  br label %bb3

bb1:                                              ; preds = %start
  %6 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 0
  %7 = load i64, ptr %6, align 8, !range !7, !noundef !3
  %8 = getelementptr inbounds { i64, i64 }, ptr %layout, i32 0, i32 1
  %9 = load i64, ptr %8, align 8, !noundef !3
  %10 = getelementptr inbounds { i64, i64 }, ptr %layout1, i32 0, i32 0
  store i64 %7, ptr %10, align 8
  %11 = getelementptr inbounds { i64, i64 }, ptr %layout1, i32 0, i32 1
  store i64 %9, ptr %11, align 8
  %12 = getelementptr inbounds { i64, i64 }, ptr %layout1, i32 0, i32 1
  %_9 = load i64, ptr %12, align 8, !noundef !3
  %self2 = load i64, ptr %layout1, align 8, !range !7, !noundef !3
  store i64 %self2, ptr %_14, align 8
  %_15 = load i64, ptr %_14, align 8, !range !7, !noundef !3
  %_16 = icmp uge i64 -9223372036854775808, %_15
  call void @llvm.assume(i1 %_16)
  %_17 = icmp ule i64 1, %_15
  call void @llvm.assume(i1 %_17)
  call void @__rust_dealloc(ptr %ptr, i64 %_9, i64 %_15) #21
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  ret void
}

; <alloc::alloc::Global as core::alloc::Allocator>::allocate_zeroed
; Function Attrs: inlinehint uwtable
define internal { ptr, i64 } @"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$15allocate_zeroed17hc5282feef52ff2b4E"(ptr align 1 %self, i64 %layout.0, i64 %layout.1) unnamed_addr #2 {
start:
; call alloc::alloc::Global::alloc_impl
  %0 = call { ptr, i64 } @_ZN5alloc5alloc6Global10alloc_impl17h6dcd190f2502bf97E(ptr align 1 %self, i64 %layout.0, i64 %layout.1, i1 zeroext true)
  %1 = extractvalue { ptr, i64 } %0, 0
  %2 = extractvalue { ptr, i64 } %0, 1
  %3 = insertvalue { ptr, i64 } poison, ptr %1, 0
  %4 = insertvalue { ptr, i64 } %3, i64 %2, 1
  ret { ptr, i64 } %4
}

; <alloc::alloc::Global as core::alloc::Allocator>::grow
; Function Attrs: inlinehint uwtable
define internal { ptr, i64 } @"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$4grow17hce6fd187504b5622E"(ptr align 1 %self, ptr %ptr, i64 %old_layout.0, i64 %old_layout.1, i64 %new_layout.0, i64 %new_layout.1) unnamed_addr #2 {
start:
; call alloc::alloc::Global::grow_impl
  %0 = call { ptr, i64 } @_ZN5alloc5alloc6Global9grow_impl17ha90560a021c25a9bE(ptr align 1 %self, ptr %ptr, i64 %old_layout.0, i64 %old_layout.1, i64 %new_layout.0, i64 %new_layout.1, i1 zeroext false)
  %1 = extractvalue { ptr, i64 } %0, 0
  %2 = extractvalue { ptr, i64 } %0, 1
  %3 = insertvalue { ptr, i64 } poison, ptr %1, 0
  %4 = insertvalue { ptr, i64 } %3, i64 %2, 1
  ret { ptr, i64 } %4
}

; <alloc::alloc::Global as core::alloc::Allocator>::allocate
; Function Attrs: inlinehint uwtable
define internal { ptr, i64 } @"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$8allocate17he12ead4265c5f747E"(ptr align 1 %self, i64 %layout.0, i64 %layout.1) unnamed_addr #2 {
start:
; call alloc::alloc::Global::alloc_impl
  %0 = call { ptr, i64 } @_ZN5alloc5alloc6Global10alloc_impl17h6dcd190f2502bf97E(ptr align 1 %self, i64 %layout.0, i64 %layout.1, i1 zeroext false)
  %1 = extractvalue { ptr, i64 } %0, 0
  %2 = extractvalue { ptr, i64 } %0, 1
  %3 = insertvalue { ptr, i64 } poison, ptr %1, 0
  %4 = insertvalue { ptr, i64 } %3, i64 %2, 1
  ret { ptr, i64 } %4
}

; <alloc::vec::Vec<T,A> as core::ops::drop::Drop>::drop
; Function Attrs: uwtable
define internal void @"_ZN70_$LT$alloc..vec..Vec$LT$T$C$A$GT$$u20$as$u20$core..ops..drop..Drop$GT$4drop17h01b3817a5b2d5d93E"(ptr align 8 %self) unnamed_addr #1 {
start:
  %_11 = alloca { ptr, i64 }, align 8
  %_10 = alloca %"core::ptr::metadata::PtrRepr<[alloc::string::String]>", align 8
  %self1 = load ptr, ptr %self, align 8, !nonnull !3, !noundef !3
  %0 = getelementptr inbounds %"alloc::vec::Vec<alloc::string::String>", ptr %self, i32 0, i32 1
  %len = load i64, ptr %0, align 8, !noundef !3
  store ptr %self1, ptr %_11, align 8
  %1 = getelementptr inbounds { ptr, i64 }, ptr %_11, i32 0, i32 1
  store i64 %len, ptr %1, align 8
  %2 = getelementptr inbounds { ptr, i64 }, ptr %_11, i32 0, i32 0
  %3 = load ptr, ptr %2, align 8, !noundef !3
  %4 = getelementptr inbounds { ptr, i64 }, ptr %_11, i32 0, i32 1
  %5 = load i64, ptr %4, align 8, !noundef !3
  %6 = getelementptr inbounds { ptr, i64 }, ptr %_10, i32 0, i32 0
  store ptr %3, ptr %6, align 8
  %7 = getelementptr inbounds { ptr, i64 }, ptr %_10, i32 0, i32 1
  store i64 %5, ptr %7, align 8
  %8 = getelementptr inbounds { ptr, i64 }, ptr %_10, i32 0, i32 0
  %_2.0 = load ptr, ptr %8, align 8, !noundef !3
  %9 = getelementptr inbounds { ptr, i64 }, ptr %_10, i32 0, i32 1
  %_2.1 = load i64, ptr %9, align 8, !noundef !3
; call core::ptr::drop_in_place<[alloc::string::String]>
  call void @"_ZN4core3ptr52drop_in_place$LT$$u5b$alloc..string..String$u5d$$GT$17h2cf5df410a98099bE"(ptr %_2.0, i64 %_2.1)
  ret void
}

; <alloc::vec::Vec<T,A> as core::ops::drop::Drop>::drop
; Function Attrs: uwtable
define internal void @"_ZN70_$LT$alloc..vec..Vec$LT$T$C$A$GT$$u20$as$u20$core..ops..drop..Drop$GT$4drop17ha8dcd1046e4ff4ecE"(ptr align 8 %self) unnamed_addr #1 {
start:
  %_11 = alloca { ptr, i64 }, align 8
  %_10 = alloca %"core::ptr::metadata::PtrRepr<[u8]>", align 8
  %self1 = load ptr, ptr %self, align 8, !nonnull !3, !noundef !3
  %0 = getelementptr inbounds %"alloc::vec::Vec<u8>", ptr %self, i32 0, i32 1
  %len = load i64, ptr %0, align 8, !noundef !3
  store ptr %self1, ptr %_11, align 8
  %1 = getelementptr inbounds { ptr, i64 }, ptr %_11, i32 0, i32 1
  store i64 %len, ptr %1, align 8
  %2 = getelementptr inbounds { ptr, i64 }, ptr %_11, i32 0, i32 0
  %3 = load ptr, ptr %2, align 8, !noundef !3
  %4 = getelementptr inbounds { ptr, i64 }, ptr %_11, i32 0, i32 1
  %5 = load i64, ptr %4, align 8, !noundef !3
  %6 = getelementptr inbounds { ptr, i64 }, ptr %_10, i32 0, i32 0
  store ptr %3, ptr %6, align 8
  %7 = getelementptr inbounds { ptr, i64 }, ptr %_10, i32 0, i32 1
  store i64 %5, ptr %7, align 8
  %8 = getelementptr inbounds { ptr, i64 }, ptr %_10, i32 0, i32 0
  %_2.0 = load ptr, ptr %8, align 8, !noundef !3
  %9 = getelementptr inbounds { ptr, i64 }, ptr %_10, i32 0, i32 1
  %_2.1 = load i64, ptr %9, align 8, !noundef !3
  ret void
}

; <usize as core::slice::index::SliceIndex<[T]>>::index_mut
; Function Attrs: inlinehint uwtable
define internal align 8 ptr @"_ZN75_$LT$usize$u20$as$u20$core..slice..index..SliceIndex$LT$$u5b$T$u5d$$GT$$GT$9index_mut17h65266e76a6e9efd9E"(i64 %self, ptr align 8 %slice.0, i64 %slice.1, ptr align 8 %0) unnamed_addr #2 {
start:
  %_4 = icmp ult i64 %self, %slice.1
  %1 = call i1 @llvm.expect.i1(i1 %_4, i1 true)
  br i1 %1, label %bb1, label %panic

bb1:                                              ; preds = %start
  %2 = getelementptr inbounds [0 x %"alloc::string::String"], ptr %slice.0, i64 0, i64 %self
  ret ptr %2

panic:                                            ; preds = %start
; call core::panicking::panic_bounds_check
  call void @_ZN4core9panicking18panic_bounds_check17h2cb4edcf4f6d0db4E(i64 %self, i64 %slice.1, ptr align 8 %0) #20
  unreachable
}

; <alloc::raw_vec::RawVec<T,A> as core::ops::drop::Drop>::drop
; Function Attrs: uwtable
define internal void @"_ZN77_$LT$alloc..raw_vec..RawVec$LT$T$C$A$GT$$u20$as$u20$core..ops..drop..Drop$GT$4drop17h2af0c9e6441e23c0E"(ptr align 8 %self) unnamed_addr #1 {
start:
  %_2 = alloca %"core::option::Option<(core::ptr::non_null::NonNull<u8>, core::alloc::layout::Layout)>", align 8
; call alloc::raw_vec::RawVec<T,A>::current_memory
  call void @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$14current_memory17hc85a3ae35d8850e2E"(ptr sret(%"core::option::Option<(core::ptr::non_null::NonNull<u8>, core::alloc::layout::Layout)>") %_2, ptr align 8 %self)
  %0 = getelementptr inbounds %"core::option::Option<(core::ptr::non_null::NonNull<u8>, core::alloc::layout::Layout)>", ptr %_2, i32 0, i32 1
  %1 = load i64, ptr %0, align 8, !range !8, !noundef !3
  %2 = icmp eq i64 %1, 0
  %_4 = select i1 %2, i64 0, i64 1
  %3 = icmp eq i64 %_4, 1
  br i1 %3, label %bb2, label %bb4

bb2:                                              ; preds = %start
  %ptr = load ptr, ptr %_2, align 8, !nonnull !3, !noundef !3
  %4 = getelementptr inbounds { ptr, { i64, i64 } }, ptr %_2, i32 0, i32 1
  %5 = getelementptr inbounds { i64, i64 }, ptr %4, i32 0, i32 0
  %layout.0 = load i64, ptr %5, align 8, !range !7, !noundef !3
  %6 = getelementptr inbounds { i64, i64 }, ptr %4, i32 0, i32 1
  %layout.1 = load i64, ptr %6, align 8, !noundef !3
; call <alloc::alloc::Global as core::alloc::Allocator>::deallocate
  call void @"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$10deallocate17hb30a2b118e628153E"(ptr align 1 %self, ptr %ptr, i64 %layout.0, i64 %layout.1)
  br label %bb4

bb4:                                              ; preds = %bb2, %start
  ret void
}

; <alloc::raw_vec::RawVec<T,A> as core::ops::drop::Drop>::drop
; Function Attrs: uwtable
define internal void @"_ZN77_$LT$alloc..raw_vec..RawVec$LT$T$C$A$GT$$u20$as$u20$core..ops..drop..Drop$GT$4drop17hce55bb6abaf3b60cE"(ptr align 8 %self) unnamed_addr #1 {
start:
  %_2 = alloca %"core::option::Option<(core::ptr::non_null::NonNull<u8>, core::alloc::layout::Layout)>", align 8
; call alloc::raw_vec::RawVec<T,A>::current_memory
  call void @"_ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$14current_memory17haa45c820b2ded979E"(ptr sret(%"core::option::Option<(core::ptr::non_null::NonNull<u8>, core::alloc::layout::Layout)>") %_2, ptr align 8 %self)
  %0 = getelementptr inbounds %"core::option::Option<(core::ptr::non_null::NonNull<u8>, core::alloc::layout::Layout)>", ptr %_2, i32 0, i32 1
  %1 = load i64, ptr %0, align 8, !range !8, !noundef !3
  %2 = icmp eq i64 %1, 0
  %_4 = select i1 %2, i64 0, i64 1
  %3 = icmp eq i64 %_4, 1
  br i1 %3, label %bb2, label %bb4

bb2:                                              ; preds = %start
  %ptr = load ptr, ptr %_2, align 8, !nonnull !3, !noundef !3
  %4 = getelementptr inbounds { ptr, { i64, i64 } }, ptr %_2, i32 0, i32 1
  %5 = getelementptr inbounds { i64, i64 }, ptr %4, i32 0, i32 0
  %layout.0 = load i64, ptr %5, align 8, !range !7, !noundef !3
  %6 = getelementptr inbounds { i64, i64 }, ptr %4, i32 0, i32 1
  %layout.1 = load i64, ptr %6, align 8, !noundef !3
; call <alloc::alloc::Global as core::alloc::Allocator>::deallocate
  call void @"_ZN63_$LT$alloc..alloc..Global$u20$as$u20$core..alloc..Allocator$GT$10deallocate17hb30a2b118e628153E"(ptr align 1 %self, ptr %ptr, i64 %layout.0, i64 %layout.1)
  br label %bb4

bb4:                                              ; preds = %bb2, %start
  ret void
}

; <alloc::vec::set_len_on_drop::SetLenOnDrop as core::ops::drop::Drop>::drop
; Function Attrs: inlinehint uwtable
define internal void @"_ZN83_$LT$alloc..vec..set_len_on_drop..SetLenOnDrop$u20$as$u20$core..ops..drop..Drop$GT$4drop17hda9301cf823657f8E"(ptr align 8 %self) unnamed_addr #2 {
start:
  %0 = getelementptr inbounds { ptr, i64 }, ptr %self, i32 0, i32 1
  %_2 = load i64, ptr %0, align 8, !noundef !3
  %_3 = load ptr, ptr %self, align 8, !nonnull !3, !align !5, !noundef !3
  store i64 %_2, ptr %_3, align 8
  ret void
}

; <alloc::vec::Vec<T,A> as core::ops::index::IndexMut<I>>::index_mut
; Function Attrs: inlinehint uwtable
define internal align 8 ptr @"_ZN84_$LT$alloc..vec..Vec$LT$T$C$A$GT$$u20$as$u20$core..ops..index..IndexMut$LT$I$GT$$GT$9index_mut17hbca8c0e142cc41f6E"(ptr align 8 %self, i64 %index, ptr align 8 %0) unnamed_addr #2 personality ptr @rust_eh_personality {
start:
  %1 = alloca { ptr, i32 }, align 8
  %_17 = alloca { ptr, i64 }, align 8
  %_16 = alloca %"core::ptr::metadata::PtrRepr<[alloc::string::String]>", align 8
  %self1 = load ptr, ptr %self, align 8, !nonnull !3, !noundef !3
  %2 = getelementptr inbounds %"alloc::vec::Vec<alloc::string::String>", ptr %self, i32 0, i32 1
  %len = load i64, ptr %2, align 8, !noundef !3
  store ptr %self1, ptr %_17, align 8
  %3 = getelementptr inbounds { ptr, i64 }, ptr %_17, i32 0, i32 1
  store i64 %len, ptr %3, align 8
  %4 = getelementptr inbounds { ptr, i64 }, ptr %_17, i32 0, i32 0
  %5 = load ptr, ptr %4, align 8, !noundef !3
  %6 = getelementptr inbounds { ptr, i64 }, ptr %_17, i32 0, i32 1
  %7 = load i64, ptr %6, align 8, !noundef !3
  %8 = getelementptr inbounds { ptr, i64 }, ptr %_16, i32 0, i32 0
  store ptr %5, ptr %8, align 8
  %9 = getelementptr inbounds { ptr, i64 }, ptr %_16, i32 0, i32 1
  store i64 %7, ptr %9, align 8
  %10 = getelementptr inbounds { ptr, i64 }, ptr %_16, i32 0, i32 0
  %_12.0 = load ptr, ptr %10, align 8, !noundef !3
  %11 = getelementptr inbounds { ptr, i64 }, ptr %_16, i32 0, i32 1
  %_12.1 = load i64, ptr %11, align 8, !noundef !3
; invoke <usize as core::slice::index::SliceIndex<[T]>>::index_mut
  %_19 = invoke align 8 ptr @"_ZN75_$LT$usize$u20$as$u20$core..slice..index..SliceIndex$LT$$u5b$T$u5d$$GT$$GT$9index_mut17h65266e76a6e9efd9E"(i64 %index, ptr align 8 %_12.0, i64 %_12.1, ptr align 8 %0)
          to label %bb4 unwind label %cleanup

bb3:                                              ; preds = %cleanup
  br i1 false, label %bb2, label %bb1

cleanup:                                          ; preds = %start
  %12 = landingpad { ptr, i32 }
          cleanup
  %13 = extractvalue { ptr, i32 } %12, 0
  %14 = extractvalue { ptr, i32 } %12, 1
  %15 = getelementptr inbounds { ptr, i32 }, ptr %1, i32 0, i32 0
  store ptr %13, ptr %15, align 8
  %16 = getelementptr inbounds { ptr, i32 }, ptr %1, i32 0, i32 1
  store i32 %14, ptr %16, align 8
  br label %bb3

bb4:                                              ; preds = %start
  ret ptr %_19

bb1:                                              ; preds = %bb2, %bb3
  %17 = load ptr, ptr %1, align 8, !noundef !3
  %18 = getelementptr inbounds { ptr, i32 }, ptr %1, i32 0, i32 1
  %19 = load i32, ptr %18, align 8, !noundef !3
  %20 = insertvalue { ptr, i32 } poison, ptr %17, 0
  %21 = insertvalue { ptr, i32 } %20, i32 %19, 1
  resume { ptr, i32 } %21

bb2:                                              ; preds = %bb3
  br label %bb1
}

; <alloc::vec::ExtendElement<T> as alloc::vec::ExtendWith<T>>::last
; Function Attrs: uwtable
define internal void @"_ZN86_$LT$alloc..vec..ExtendElement$LT$T$GT$$u20$as$u20$alloc..vec..ExtendWith$LT$T$GT$$GT$4last17hfbc8a84d4fb4ec8aE"(ptr sret(%"alloc::string::String") %0, ptr %self) unnamed_addr #1 {
start:
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %0, ptr align 8 %self, i64 24, i1 false)
  ret void
}

; <alloc::vec::ExtendElement<T> as alloc::vec::ExtendWith<T>>::next
; Function Attrs: uwtable
define internal void @"_ZN86_$LT$alloc..vec..ExtendElement$LT$T$GT$$u20$as$u20$alloc..vec..ExtendWith$LT$T$GT$$GT$4next17hc325537dc3a4dbf3E"(ptr sret(%"alloc::string::String") %0, ptr align 8 %self) unnamed_addr #1 {
start:
; call <alloc::string::String as core::clone::Clone>::clone
  call void @"_ZN60_$LT$alloc..string..String$u20$as$u20$core..clone..Clone$GT$5clone17h9cb5416e4602032dE"(ptr sret(%"alloc::string::String") %0, ptr align 8 %self)
  ret void
}

; <core::ops::range::Range<T> as core::iter::range::RangeIteratorImpl>::spec_next
; Function Attrs: inlinehint uwtable
define internal { i64, i64 } @"_ZN89_$LT$core..ops..range..Range$LT$T$GT$$u20$as$u20$core..iter..range..RangeIteratorImpl$GT$9spec_next17h09dd22fcc6c9c473E"(ptr align 8 %self) unnamed_addr #2 {
start:
  %0 = alloca { i64, i64 }, align 8
  %_4 = getelementptr inbounds { i64, i64 }, ptr %self, i32 0, i32 1
  %_3.i = load i64, ptr %self, align 8, !noundef !3
  %_4.i = load i64, ptr %_4, align 8, !noundef !3
  %1 = icmp ult i64 %_3.i, %_4.i
  br i1 %1, label %bb2, label %bb5

bb5:                                              ; preds = %start
  store i64 0, ptr %0, align 8
  br label %bb6

bb2:                                              ; preds = %start
  %2 = load i64, ptr %self, align 8, !noundef !3
; call <usize as core::iter::range::Step>::forward_unchecked
  %n = call i64 @"_ZN49_$LT$usize$u20$as$u20$core..iter..range..Step$GT$17forward_unchecked17h2bced64cca0edf6dE"(i64 %2, i64 1)
  %result = load i64, ptr %self, align 8, !noundef !3
  store i64 %n, ptr %self, align 8
  %3 = getelementptr inbounds { i64, i64 }, ptr %0, i32 0, i32 1
  store i64 %result, ptr %3, align 8
  store i64 1, ptr %0, align 8
  br label %bb6

bb6:                                              ; preds = %bb5, %bb2
  %4 = getelementptr inbounds { i64, i64 }, ptr %0, i32 0, i32 0
  %5 = load i64, ptr %4, align 8, !range !10, !noundef !3
  %6 = getelementptr inbounds { i64, i64 }, ptr %0, i32 0, i32 1
  %7 = load i64, ptr %6, align 8
  %8 = insertvalue { i64, i64 } poison, i64 %5, 0
  %9 = insertvalue { i64, i64 } %8, i64 %7, 1
  ret { i64, i64 } %9
}

; _1::main
; Function Attrs: uwtable
define internal void @_ZN2_14main17h64474c559b14522dE() unnamed_addr #1 personality ptr @rust_eh_personality {
start:
  %0 = alloca { ptr, i32 }, align 8
  %_15 = alloca i8, align 1
  %_11 = alloca %"alloc::string::String", align 8
  %_7 = alloca { i64, i64 }, align 8
  %iter = alloca { i64, i64 }, align 8
  %_5 = alloca { i64, i64 }, align 8
  %_2 = alloca %"alloc::string::String", align 8
  %proposals = alloca %"alloc::vec::Vec<alloc::string::String>", align 8
  store i8 0, ptr %_15, align 1
; call <str as alloc::string::ToString>::to_string
  call void @"_ZN47_$LT$str$u20$as$u20$alloc..string..ToString$GT$9to_string17h9e2f8b322631240bE"(ptr sret(%"alloc::string::String") %_2, ptr align 1 @alloc_2a62ba4d4fa46537b277796d74f8c568, i64 0)
; call alloc::vec::from_elem
  call void @_ZN5alloc3vec9from_elem17h2cd305980e7ee4b4E(ptr sret(%"alloc::vec::Vec<alloc::string::String>") %proposals, ptr %_2, i64 5)
  store i64 0, ptr %_5, align 8
  %1 = getelementptr inbounds { i64, i64 }, ptr %_5, i32 0, i32 1
  store i64 5, ptr %1, align 8
  %2 = getelementptr inbounds { i64, i64 }, ptr %_5, i32 0, i32 0
  %3 = load i64, ptr %2, align 8, !noundef !3
  %4 = getelementptr inbounds { i64, i64 }, ptr %_5, i32 0, i32 1
  %5 = load i64, ptr %4, align 8, !noundef !3
; invoke <I as core::iter::traits::collect::IntoIterator>::into_iter
  %6 = invoke { i64, i64 } @"_ZN63_$LT$I$u20$as$u20$core..iter..traits..collect..IntoIterator$GT$9into_iter17h411f8ab9df8a6246E"(i64 %3, i64 %5)
          to label %bb3 unwind label %cleanup

bb14:                                             ; preds = %bb16, %bb17, %cleanup
; invoke core::ptr::drop_in_place<alloc::vec::Vec<alloc::string::String>>
  invoke void @"_ZN4core3ptr65drop_in_place$LT$alloc..vec..Vec$LT$alloc..string..String$GT$$GT$17h04a4d05f7ef5ed5bE"(ptr %proposals) #18
          to label %bb15 unwind label %terminate

cleanup:                                          ; preds = %bb6, %bb4, %start
  %7 = landingpad { ptr, i32 }
          cleanup
  %8 = extractvalue { ptr, i32 } %7, 0
  %9 = extractvalue { ptr, i32 } %7, 1
  %10 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 0
  store ptr %8, ptr %10, align 8
  %11 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  store i32 %9, ptr %11, align 8
  br label %bb14

bb3:                                              ; preds = %start
  %_4.0 = extractvalue { i64, i64 } %6, 0
  %_4.1 = extractvalue { i64, i64 } %6, 1
  %12 = getelementptr inbounds { i64, i64 }, ptr %iter, i32 0, i32 0
  store i64 %_4.0, ptr %12, align 8
  %13 = getelementptr inbounds { i64, i64 }, ptr %iter, i32 0, i32 1
  store i64 %_4.1, ptr %13, align 8
  br label %bb4

bb4:                                              ; preds = %bb11, %bb3
; invoke core::iter::range::<impl core::iter::traits::iterator::Iterator for core::ops::range::Range<A>>::next
  %14 = invoke { i64, i64 } @"_ZN4core4iter5range101_$LT$impl$u20$core..iter..traits..iterator..Iterator$u20$for$u20$core..ops..range..Range$LT$A$GT$$GT$4next17hc6194987ce1a122fE"(ptr align 8 %iter)
          to label %bb5 unwind label %cleanup

bb5:                                              ; preds = %bb4
  store { i64, i64 } %14, ptr %_7, align 8
  %_9 = load i64, ptr %_7, align 8, !range !10, !noundef !3
  %15 = icmp eq i64 %_9, 0
  br i1 %15, label %bb8, label %bb6

bb8:                                              ; preds = %bb5
; call core::ptr::drop_in_place<alloc::vec::Vec<alloc::string::String>>
  call void @"_ZN4core3ptr65drop_in_place$LT$alloc..vec..Vec$LT$alloc..string..String$GT$$GT$17h04a4d05f7ef5ed5bE"(ptr %proposals)
  ret void

bb6:                                              ; preds = %bb5
  %16 = getelementptr inbounds { i64, i64 }, ptr %_7, i32 0, i32 1
  %i = load i64, ptr %16, align 8, !noundef !3
; invoke <str as alloc::string::ToString>::to_string
  invoke void @"_ZN47_$LT$str$u20$as$u20$alloc..string..ToString$GT$9to_string17h9e2f8b322631240bE"(ptr sret(%"alloc::string::String") %_11, ptr align 1 @alloc_26f643e647dbf77f42e670b3488e8932, i64 1)
          to label %bb9 unwind label %cleanup

bb7:                                              ; No predecessors!
  unreachable

bb9:                                              ; preds = %bb6
  store i8 1, ptr %_15, align 1
; invoke <alloc::vec::Vec<T,A> as core::ops::index::IndexMut<I>>::index_mut
  %_13 = invoke align 8 ptr @"_ZN84_$LT$alloc..vec..Vec$LT$T$C$A$GT$$u20$as$u20$core..ops..index..IndexMut$LT$I$GT$$GT$9index_mut17hbca8c0e142cc41f6E"(ptr align 8 %proposals, i64 %i, ptr align 8 @alloc_65f172eb7f5878b54a07b1d35e6af17d)
          to label %bb10 unwind label %cleanup1

bb17:                                             ; preds = %bb12, %cleanup1
  %17 = load i8, ptr %_15, align 1, !range !6, !noundef !3
  %18 = trunc i8 %17 to i1
  br i1 %18, label %bb16, label %bb14

cleanup1:                                         ; preds = %bb9
  %19 = landingpad { ptr, i32 }
          cleanup
  %20 = extractvalue { ptr, i32 } %19, 0
  %21 = extractvalue { ptr, i32 } %19, 1
  %22 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 0
  store ptr %20, ptr %22, align 8
  %23 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  store i32 %21, ptr %23, align 8
  br label %bb17

bb10:                                             ; preds = %bb9
; invoke core::ptr::drop_in_place<alloc::string::String>
  invoke void @"_ZN4core3ptr42drop_in_place$LT$alloc..string..String$GT$17h6cd7d71abe930a69E"(ptr %_13)
          to label %bb11 unwind label %cleanup2

bb12:                                             ; preds = %cleanup2
  store i8 0, ptr %_15, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_13, ptr align 8 %_11, i64 24, i1 false)
  br label %bb17

cleanup2:                                         ; preds = %bb10
  %24 = landingpad { ptr, i32 }
          cleanup
  %25 = extractvalue { ptr, i32 } %24, 0
  %26 = extractvalue { ptr, i32 } %24, 1
  %27 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 0
  store ptr %25, ptr %27, align 8
  %28 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  store i32 %26, ptr %28, align 8
  br label %bb12

bb11:                                             ; preds = %bb10
  store i8 0, ptr %_15, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_13, ptr align 8 %_11, i64 24, i1 false)
  store i8 0, ptr %_15, align 1
  br label %bb4

bb16:                                             ; preds = %bb17
; invoke core::ptr::drop_in_place<alloc::string::String>
  invoke void @"_ZN4core3ptr42drop_in_place$LT$alloc..string..String$GT$17h6cd7d71abe930a69E"(ptr %_11) #18
          to label %bb14 unwind label %terminate

terminate:                                        ; preds = %bb14, %bb16
  %29 = landingpad { ptr, i32 }
          cleanup
  %30 = extractvalue { ptr, i32 } %29, 0
  %31 = extractvalue { ptr, i32 } %29, 1
; call core::panicking::panic_cannot_unwind
  call void @_ZN4core9panicking19panic_cannot_unwind17hc1edb5342d68b13dE() #19
  unreachable

bb15:                                             ; preds = %bb14
  %32 = load ptr, ptr %0, align 8, !noundef !3
  %33 = getelementptr inbounds { ptr, i32 }, ptr %0, i32 0, i32 1
  %34 = load i32, ptr %33, align 8, !noundef !3
  %35 = insertvalue { ptr, i32 } poison, ptr %32, 0
  %36 = insertvalue { ptr, i32 } %35, i32 %34, 1
  resume { ptr, i32 } %36
}

; std::rt::lang_start_internal
; Function Attrs: uwtable
declare i64 @_ZN3std2rt19lang_start_internal17h2b22f0f26affdef7E(ptr align 1, ptr align 8, i64, ptr, i8) unnamed_addr #1

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #4

; Function Attrs: uwtable
declare i32 @rust_eh_personality(i32, i32, i64, ptr, ptr) unnamed_addr #1

; core::panicking::panic_cannot_unwind
; Function Attrs: cold noinline noreturn nounwind uwtable
declare void @_ZN4core9panicking19panic_cannot_unwind17hc1edb5342d68b13dE() unnamed_addr #5

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.assume(i1 noundef) #6

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare i1 @llvm.expect.i1(i1, i1) #7

; core::panicking::panic
; Function Attrs: cold noinline noreturn uwtable
declare void @_ZN4core9panicking5panic17h593487776db43352E(ptr align 1, i64, ptr align 8) unnamed_addr #8

; Function Attrs: nounwind allockind("alloc,zeroed,aligned") allocsize(0) uwtable
declare noalias ptr @__rust_alloc_zeroed(i64, i64 allocalign) unnamed_addr #9

; Function Attrs: nounwind allockind("alloc,uninitialized,aligned") allocsize(0) uwtable
declare noalias ptr @__rust_alloc(i64, i64 allocalign) unnamed_addr #10

; Function Attrs: nounwind allockind("realloc,aligned") allocsize(3) uwtable
declare noalias ptr @__rust_realloc(ptr allocptr, i64, i64 allocalign, i64) unnamed_addr #11

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #12

; alloc::alloc::handle_alloc_error
; Function Attrs: cold noreturn uwtable
declare void @_ZN5alloc5alloc18handle_alloc_error17h1202a93345cedb79E(i64, i64) unnamed_addr #13

; alloc::raw_vec::capacity_overflow
; Function Attrs: noreturn uwtable
declare void @_ZN5alloc7raw_vec17capacity_overflow17hd5f837b05ce19c95E() unnamed_addr #14

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i64, i1 } @llvm.uadd.with.overflow.i64(i64, i64) #15

; Function Attrs: nounwind allockind("free") uwtable
declare void @__rust_dealloc(ptr allocptr, i64, i64) unnamed_addr #16

; core::panicking::panic_bounds_check
; Function Attrs: cold noinline noreturn uwtable
declare void @_ZN4core9panicking18panic_bounds_check17h2cb4edcf4f6d0db4E(i64, i64, ptr align 8) unnamed_addr #8

; <alloc::string::String as core::clone::Clone>::clone
; Function Attrs: uwtable
declare void @"_ZN60_$LT$alloc..string..String$u20$as$u20$core..clone..Clone$GT$5clone17h9cb5416e4602032dE"(ptr sret(%"alloc::string::String"), ptr align 8) unnamed_addr #1

define i32 @main(i32 %0, ptr %1) unnamed_addr #17 {
top:
  %2 = sext i32 %0 to i64
; call std::rt::lang_start
  %3 = call i64 @_ZN3std2rt10lang_start17h442e628b9232b4b1E(ptr @_ZN2_14main17h64474c559b14522dE, i64 %2, ptr %1, i8 0)
  %4 = trunc i64 %3 to i32
  ret i32 %4
}

attributes #0 = { noinline uwtable "frame-pointer"="all" "probe-stack"="inline-asm" "target-cpu"="core2" }
attributes #1 = { uwtable "frame-pointer"="all" "probe-stack"="inline-asm" "target-cpu"="core2" }
attributes #2 = { inlinehint uwtable "frame-pointer"="all" "probe-stack"="inline-asm" "target-cpu"="core2" }
attributes #3 = { cold uwtable "frame-pointer"="all" "probe-stack"="inline-asm" "target-cpu"="core2" }
attributes #4 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { cold noinline noreturn nounwind uwtable "frame-pointer"="all" "probe-stack"="inline-asm" "target-cpu"="core2" }
attributes #6 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite) }
attributes #7 = { nocallback nofree nosync nounwind willreturn memory(none) }
attributes #8 = { cold noinline noreturn uwtable "frame-pointer"="all" "probe-stack"="inline-asm" "target-cpu"="core2" }
attributes #9 = { nounwind allockind("alloc,zeroed,aligned") allocsize(0) uwtable "alloc-family"="__rust_alloc" "frame-pointer"="all" "probe-stack"="inline-asm" "target-cpu"="core2" }
attributes #10 = { nounwind allockind("alloc,uninitialized,aligned") allocsize(0) uwtable "alloc-family"="__rust_alloc" "frame-pointer"="all" "probe-stack"="inline-asm" "target-cpu"="core2" }
attributes #11 = { nounwind allockind("realloc,aligned") allocsize(3) uwtable "alloc-family"="__rust_alloc" "frame-pointer"="all" "probe-stack"="inline-asm" "target-cpu"="core2" }
attributes #12 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #13 = { cold noreturn uwtable "frame-pointer"="all" "probe-stack"="inline-asm" "target-cpu"="core2" }
attributes #14 = { noreturn uwtable "frame-pointer"="all" "probe-stack"="inline-asm" "target-cpu"="core2" }
attributes #15 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #16 = { nounwind allockind("free") uwtable "alloc-family"="__rust_alloc" "frame-pointer"="all" "probe-stack"="inline-asm" "target-cpu"="core2" }
attributes #17 = { "frame-pointer"="all" "target-cpu"="core2" }
attributes #18 = { noinline }
attributes #19 = { noinline noreturn nounwind }
attributes #20 = { noreturn }
attributes #21 = { nounwind }

!llvm.module.flags = !{!0, !1}

!0 = !{i32 8, !"PIC Level", i32 2}
!1 = !{i32 7, !"PIE Level", i32 2}
!2 = !{i32 2612967}
!3 = !{}
!4 = !{i8 -1, i8 2}
!5 = !{i64 8}
!6 = !{i8 0, i8 2}
!7 = !{i64 1, i64 -9223372036854775807}
!8 = !{i64 0, i64 -9223372036854775807}
!9 = !{i64 0, i64 -9223372036854775806}
!10 = !{i64 0, i64 2}
