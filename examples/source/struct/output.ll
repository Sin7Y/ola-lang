; ModuleID = '1.1142b1c3e997ee03-cgu.0'
source_filename = "1.1142b1c3e997ee03-cgu.0"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.0"

%"core::fmt::Arguments<'_>" = type { { ptr, i64 }, { ptr, i64 }, { ptr, i64 } }

@vtable.0 = private unnamed_addr constant <{ ptr, [16 x i8], ptr, ptr, ptr }> <{ ptr @"_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17hc8602fbf372112e5E", [16 x i8] c"\08\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00", ptr @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17hcf350ab568a5f1e2E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h0394e9abce59b207E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h0394e9abce59b207E" }>, align 8
@alloc_91c7fa63c3cfeaa3c795652d5cf060e4 = private unnamed_addr constant <{ [12 x i8] }> <{ [12 x i8] c"invalid args" }>, align 1
@alloc_560206a49c61adca6f3f0639a12632eb = private unnamed_addr constant <{ ptr, [8 x i8] }> <{ ptr @alloc_91c7fa63c3cfeaa3c795652d5cf060e4, [8 x i8] c"\0C\00\00\00\00\00\00\00" }>, align 8
@alloc_513570631223a12912d85da2bec3b15a = private unnamed_addr constant <{}> zeroinitializer, align 8
@alloc_6adfd9c60beb07d7d287ecd7d5ca203c = private unnamed_addr constant <{ [75 x i8] }> <{ [75 x i8] c"/rustc/74c4821045c68d42bb8b8a7c998bdb5c2a72bd0d/library/core/src/fmt/mod.rs" }>, align 1
@alloc_0d1ff39106e0b78d16ea496c6b42bc6b = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_6adfd9c60beb07d7d287ecd7d5ca203c, [16 x i8] c"K\00\00\00\00\00\00\005\01\00\00\0D\00\00\00" }>, align 8
@alloc_7b93ca6e48f39d6c023562e11197c6a3 = private unnamed_addr constant <{ [21 x i8] }> <{ [21 x i8] c"The new point is at (" }>, align 1
@alloc_94b00be069aafad82a2c6df764237b82 = private unnamed_addr constant <{ [2 x i8] }> <{ [2 x i8] c", " }>, align 1
@alloc_cba169e49d2f6a8c1ea9f5f92c42ec6b = private unnamed_addr constant <{ [2 x i8] }> <{ [2 x i8] c")\0A" }>, align 1
@alloc_b5b97be63dfae4fbb72d1f18e1e44432 = private unnamed_addr constant <{ ptr, [8 x i8], ptr, [8 x i8], ptr, [8 x i8] }> <{ ptr @alloc_7b93ca6e48f39d6c023562e11197c6a3, [8 x i8] c"\15\00\00\00\00\00\00\00", ptr @alloc_94b00be069aafad82a2c6df764237b82, [8 x i8] c"\02\00\00\00\00\00\00\00", ptr @alloc_cba169e49d2f6a8c1ea9f5f92c42ec6b, [8 x i8] c"\02\00\00\00\00\00\00\00" }>, align 8

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

; core::fmt::Arguments::new_v1
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3fmt9Arguments6new_v117h7b1bf110b2eb495bE(ptr sret(%"core::fmt::Arguments<'_>") %0, ptr align 8 %pieces.0, i64 %pieces.1, ptr align 8 %args.0, i64 %args.1) unnamed_addr #2 {
start:
  %_16 = alloca { ptr, i64 }, align 8
  %_14 = alloca { ptr, i64 }, align 8
  %_12 = alloca %"core::fmt::Arguments<'_>", align 8
  %_3 = alloca i8, align 1
  %_4 = icmp ult i64 %pieces.1, %args.1
  br i1 %_4, label %bb1, label %bb2

bb2:                                              ; preds = %start
  %_9 = add i64 %args.1, 1
  %_7 = icmp ugt i64 %pieces.1, %_9
  %1 = zext i1 %_7 to i8
  store i8 %1, ptr %_3, align 1
  br label %bb3

bb1:                                              ; preds = %start
  store i8 1, ptr %_3, align 1
  br label %bb3

bb3:                                              ; preds = %bb2, %bb1
  %2 = load i8, ptr %_3, align 1, !range !4, !noundef !3
  %3 = trunc i8 %2 to i1
  br i1 %3, label %bb4, label %bb5

bb5:                                              ; preds = %bb3
  store ptr null, ptr %_14, align 8
  %4 = getelementptr inbounds { ptr, i64 }, ptr %0, i32 0, i32 0
  store ptr %pieces.0, ptr %4, align 8
  %5 = getelementptr inbounds { ptr, i64 }, ptr %0, i32 0, i32 1
  store i64 %pieces.1, ptr %5, align 8
  %6 = getelementptr inbounds { ptr, i64 }, ptr %_14, i32 0, i32 0
  %7 = load ptr, ptr %6, align 8, !align !5, !noundef !3
  %8 = getelementptr inbounds { ptr, i64 }, ptr %_14, i32 0, i32 1
  %9 = load i64, ptr %8, align 8
  %10 = getelementptr inbounds %"core::fmt::Arguments<'_>", ptr %0, i32 0, i32 2
  %11 = getelementptr inbounds { ptr, i64 }, ptr %10, i32 0, i32 0
  store ptr %7, ptr %11, align 8
  %12 = getelementptr inbounds { ptr, i64 }, ptr %10, i32 0, i32 1
  store i64 %9, ptr %12, align 8
  %13 = getelementptr inbounds %"core::fmt::Arguments<'_>", ptr %0, i32 0, i32 1
  %14 = getelementptr inbounds { ptr, i64 }, ptr %13, i32 0, i32 0
  store ptr %args.0, ptr %14, align 8
  %15 = getelementptr inbounds { ptr, i64 }, ptr %13, i32 0, i32 1
  store i64 %args.1, ptr %15, align 8
  ret void

bb4:                                              ; preds = %bb3
  store ptr null, ptr %_16, align 8
  %16 = getelementptr inbounds { ptr, i64 }, ptr %_12, i32 0, i32 0
  store ptr @alloc_560206a49c61adca6f3f0639a12632eb, ptr %16, align 8
  %17 = getelementptr inbounds { ptr, i64 }, ptr %_12, i32 0, i32 1
  store i64 1, ptr %17, align 8
  %18 = getelementptr inbounds { ptr, i64 }, ptr %_16, i32 0, i32 0
  %19 = load ptr, ptr %18, align 8, !align !5, !noundef !3
  %20 = getelementptr inbounds { ptr, i64 }, ptr %_16, i32 0, i32 1
  %21 = load i64, ptr %20, align 8
  %22 = getelementptr inbounds %"core::fmt::Arguments<'_>", ptr %_12, i32 0, i32 2
  %23 = getelementptr inbounds { ptr, i64 }, ptr %22, i32 0, i32 0
  store ptr %19, ptr %23, align 8
  %24 = getelementptr inbounds { ptr, i64 }, ptr %22, i32 0, i32 1
  store i64 %21, ptr %24, align 8
  %25 = getelementptr inbounds %"core::fmt::Arguments<'_>", ptr %_12, i32 0, i32 1
  %26 = getelementptr inbounds { ptr, i64 }, ptr %25, i32 0, i32 0
  store ptr @alloc_513570631223a12912d85da2bec3b15a, ptr %26, align 8
  %27 = getelementptr inbounds { ptr, i64 }, ptr %25, i32 0, i32 1
  store i64 0, ptr %27, align 8
; call core::panicking::panic_fmt
  call void @_ZN4core9panicking9panic_fmt17h5f1768fb380922f0E(ptr %_12, ptr align 8 @alloc_0d1ff39106e0b78d16ea496c6b42bc6b) #5
  unreachable
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

; core::ptr::drop_in_place<std::rt::lang_start<()>::{{closure}}>
; Function Attrs: inlinehint uwtable
define internal void @"_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17hc8602fbf372112e5E"(ptr %_1) unnamed_addr #2 {
start:
  ret void
}

; <() as std::process::Termination>::report
; Function Attrs: inlinehint uwtable
define internal i8 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h615134f8c08cc0f9E"() unnamed_addr #2 {
start:
  ret i8 0
}

; _1::translate
; Function Attrs: uwtable
define internal { double, double } @_ZN2_19translate17h49eedd695803811bE(double %point.0, double %point.1, double %dx, double %dy) unnamed_addr #1 {
start:
  %0 = alloca { double, double }, align 8
  %_4 = fadd double %point.0, %dx
  %_6 = fadd double %point.1, %dy
  store double %_4, ptr %0, align 8
  %1 = getelementptr inbounds { double, double }, ptr %0, i32 0, i32 1
  store double %_6, ptr %1, align 8
  %2 = getelementptr inbounds { double, double }, ptr %0, i32 0, i32 0
  %3 = load double, ptr %2, align 8, !noundef !3
  %4 = getelementptr inbounds { double, double }, ptr %0, i32 0, i32 1
  %5 = load double, ptr %4, align 8, !noundef !3
  %6 = insertvalue { double, double } poison, double %3, 0
  %7 = insertvalue { double, double } %6, double %5, 1
  ret { double, double } %7
}

; _1::main
; Function Attrs: uwtable
define internal void @_ZN2_14main17h64474c559b14522dE() unnamed_addr #1 {
start:
  %0 = alloca { ptr, ptr }, align 8
  %1 = alloca { ptr, ptr }, align 8
  %_8 = alloca [2 x { ptr, ptr }], align 8
  %_4 = alloca %"core::fmt::Arguments<'_>", align 8
  %new_point = alloca { double, double }, align 8
  %point = alloca { double, double }, align 8
  store double 1.000000e+00, ptr %point, align 8
  %2 = getelementptr inbounds { double, double }, ptr %point, i32 0, i32 1
  store double 2.000000e+00, ptr %2, align 8
  %3 = getelementptr inbounds { double, double }, ptr %point, i32 0, i32 0
  %4 = load double, ptr %3, align 8, !noundef !3
  %5 = getelementptr inbounds { double, double }, ptr %point, i32 0, i32 1
  %6 = load double, ptr %5, align 8, !noundef !3
; call _1::translate
  %7 = call { double, double } @_ZN2_19translate17h49eedd695803811bE(double %4, double %6, double 1.000000e+00, double -1.000000e+00)
  store { double, double } %7, ptr %new_point, align 8
  store ptr %new_point, ptr %0, align 8
  %8 = getelementptr inbounds { ptr, ptr }, ptr %0, i32 0, i32 1
  store ptr @"_ZN4core3fmt5float52_$LT$impl$u20$core..fmt..Display$u20$for$u20$f64$GT$3fmt17h83bab9065305c00fE", ptr %8, align 8
  %9 = load ptr, ptr %0, align 8, !nonnull !3, !align !6, !noundef !3
  %10 = getelementptr inbounds { ptr, ptr }, ptr %0, i32 0, i32 1
  %11 = load ptr, ptr %10, align 8, !nonnull !3, !noundef !3
  %12 = insertvalue { ptr, ptr } poison, ptr %9, 0
  %13 = insertvalue { ptr, ptr } %12, ptr %11, 1
  %_9.0 = extractvalue { ptr, ptr } %13, 0
  %_9.1 = extractvalue { ptr, ptr } %13, 1
  %_12 = getelementptr inbounds { double, double }, ptr %new_point, i32 0, i32 1
  store ptr %_12, ptr %1, align 8
  %14 = getelementptr inbounds { ptr, ptr }, ptr %1, i32 0, i32 1
  store ptr @"_ZN4core3fmt5float52_$LT$impl$u20$core..fmt..Display$u20$for$u20$f64$GT$3fmt17h83bab9065305c00fE", ptr %14, align 8
  %15 = load ptr, ptr %1, align 8, !nonnull !3, !align !6, !noundef !3
  %16 = getelementptr inbounds { ptr, ptr }, ptr %1, i32 0, i32 1
  %17 = load ptr, ptr %16, align 8, !nonnull !3, !noundef !3
  %18 = insertvalue { ptr, ptr } poison, ptr %15, 0
  %19 = insertvalue { ptr, ptr } %18, ptr %17, 1
  %_11.0 = extractvalue { ptr, ptr } %19, 0
  %_11.1 = extractvalue { ptr, ptr } %19, 1
  %20 = getelementptr inbounds [2 x { ptr, ptr }], ptr %_8, i64 0, i64 0
  %21 = getelementptr inbounds { ptr, ptr }, ptr %20, i32 0, i32 0
  store ptr %_9.0, ptr %21, align 8
  %22 = getelementptr inbounds { ptr, ptr }, ptr %20, i32 0, i32 1
  store ptr %_9.1, ptr %22, align 8
  %23 = getelementptr inbounds [2 x { ptr, ptr }], ptr %_8, i64 0, i64 1
  %24 = getelementptr inbounds { ptr, ptr }, ptr %23, i32 0, i32 0
  store ptr %_11.0, ptr %24, align 8
  %25 = getelementptr inbounds { ptr, ptr }, ptr %23, i32 0, i32 1
  store ptr %_11.1, ptr %25, align 8
; call core::fmt::Arguments::new_v1
  call void @_ZN4core3fmt9Arguments6new_v117h7b1bf110b2eb495bE(ptr sret(%"core::fmt::Arguments<'_>") %_4, ptr align 8 @alloc_b5b97be63dfae4fbb72d1f18e1e44432, i64 3, ptr align 8 %_8, i64 2)
; call std::io::stdio::_print
  call void @_ZN3std2io5stdio6_print17h4e4c7894e4deba28E(ptr %_4)
  ret void
}

; std::rt::lang_start_internal
; Function Attrs: uwtable
declare i64 @_ZN3std2rt19lang_start_internal17h2b22f0f26affdef7E(ptr align 1, ptr align 8, i64, ptr, i8) unnamed_addr #1

; core::fmt::float::<impl core::fmt::Display for f64>::fmt
; Function Attrs: uwtable
declare zeroext i1 @"_ZN4core3fmt5float52_$LT$impl$u20$core..fmt..Display$u20$for$u20$f64$GT$3fmt17h83bab9065305c00fE"(ptr align 8, ptr align 8) unnamed_addr #1

; core::panicking::panic_fmt
; Function Attrs: cold noinline noreturn uwtable
declare void @_ZN4core9panicking9panic_fmt17h5f1768fb380922f0E(ptr, ptr align 8) unnamed_addr #3

; Function Attrs: uwtable
declare i32 @rust_eh_personality(i32, i32, i64, ptr, ptr) unnamed_addr #1

; std::io::stdio::_print
; Function Attrs: uwtable
declare void @_ZN3std2io5stdio6_print17h4e4c7894e4deba28E(ptr) unnamed_addr #1

define i32 @main(i32 %0, ptr %1) unnamed_addr #4 {
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
attributes #3 = { cold noinline noreturn uwtable "frame-pointer"="all" "probe-stack"="inline-asm" "target-cpu"="core2" }
attributes #4 = { "frame-pointer"="all" "target-cpu"="core2" }
attributes #5 = { noreturn }

!llvm.module.flags = !{!0, !1}

!0 = !{i32 8, !"PIC Level", i32 2}
!1 = !{i32 7, !"PIE Level", i32 2}
!2 = !{i32 1404248}
!3 = !{}
!4 = !{i8 0, i8 2}
!5 = !{i64 8}
!6 = !{i64 1}
