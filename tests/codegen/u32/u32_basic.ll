
; BEGIN-CHECK: testU32DeclareUninitialized:
define void @testU32DeclareUninitialized() {
entry:
  ; CHECK: mov r1 0
  ; CHECK: mstore [r9,-1] r1
  %a = alloca i64, align 8
  store i64 0, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %0, i64 3)
  ret void
}

; BEGIN-CHECK: testU32DeclareThenInitialized:
define void @testU32DeclareThenInitialized() {
entry:
  ; CHECK: mov r1 0
  ; CHECK: mstore [r9,-1] r1
  %a = alloca i64, align 8
  store i64 0, ptr %a, align 4
  ; CHECK: mov r1 5
  ; CHECK: mstore [r9,-1] r1
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %0, i64 3)
  ret void
  
}

; BEGIN-CHECK: testU32DeclareThenInitialized:
define void @testU32InitializedByVariable() {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  ; CHECK: mov r1 5
  ; CHECK: mstore [r9,-2] r1
  store i64 5, ptr %a, align 4
  ; CHECK: mload r1 [r9,-2]
  %0 = load i64, ptr %a, align 4
  ; CHECK: mstore [r9,-1] r1
  store i64 %0, ptr %b, align 4
  %1 = load i64, ptr %b, align 4
  call void @prophet_printf(i64 %1, i64 3)
  ret void
}

define void @testU32RightValueExpression() {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %a, align 4
; CHECK: add r1 r2 r3
  %2 = add i64 %0, %1
; CHECK: range r1
  call void @builtin_range_check(i64 %2)
; CHECK: mstore [r9,-1] r1
  store i64 %2, ptr %b, align 4
  ret void
}

define void @testU32AsParameter(i64 %0) {
entry:
  %x = alloca i64, align 8
; CHECK: mstore [r9,-1] r1
  store i64 %0, ptr %x, align 4
; CHECK: mload r1 [r9,-1]
  %1 = load i64, ptr %x, align 4
  call void @prophet_printf(i64 %1, i64 3)
  ret void
}

define void @testU32CallByValue() {
entry:
  %a = alloca i64, align 8
; CHECK: mov r1 5
  store i64 5, ptr %a, align 4
; CHECK: mstore [r9,-3] r1
  %0 = load i64, ptr %a, align 4
; CHECK: mload r1 [r9,-3]
  call void @testU32AsParameter(i64 %0)
  ret void
}

define i64 @testU32AsReturnValue() {
entry:
  %a = alloca i64, align 8
  store i64 10, ptr %a, align 4
; CHECK: mload r0 [r9,-1]
  %0 = load i64, ptr %a, align 4
; CHECK: ret
  ret i64 %0
}

define i64 @testU32AsReturnConstValue() {
entry:
; CHECK: mov r0 5
; CHECK: ret
  ret i64 5
}

define void @testU32AddOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
; CHECK: mload r2 [r9,-3] 
  %0 = load i64, ptr %a, align 4
; CHECK: mload r3 [r9,-2]
  %1 = load i64, ptr %b, align 4
; CHECK: add r1 r2 r3
  %2 = add i64 %0, %1
  call void @builtin_range_check(i64 %2)
  ret void
}

define void @testU32SubOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = sub i64 %0, %1
  call void @builtin_range_check(i64 %2)
  ret void
}

define void @testU32MulOperatoin() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = mul i64 %0, %1
  call void @builtin_range_check(i64 %2)
  ret void
}

define void @testU32DivOperation() {
entry:
  %c = alloca i64, align 8
  %0 = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 10, ptr %a, align 4
  store i64 5, ptr %b, align 4
  %1 = load i64, ptr %a, align 4
  %2 = load i64, ptr %b, align 4
  call void @u32_div_mod(i64 %1, i64 %2, ptr %0, ptr null)
  %3 = load i64, ptr %0, align 4
  store i64 %3, ptr %c, align 4
  %4 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %4, i64 3)
  ret void
}

define void @testU32ModOperation() {
entry:
  %c = alloca i64, align 8
  %0 = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 10, ptr %a, align 4
  store i64 5, ptr %b, align 4
  %1 = load i64, ptr %a, align 4
  %2 = load i64, ptr %b, align 4
  call void @u32_div_mod(i64 %1, i64 %2, ptr null, ptr %0)
  %3 = load i64, ptr %0, align 4
  store i64 %3, ptr %c, align 4
  %4 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %4, i64 3)
  ret void
}

define void @testU32AndOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = and i64 %0, %1
  store i64 %2, ptr %c, align 4
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32BitWiseXorOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = xor i64 %0, %1
  store i64 %2, ptr %c, align 4
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32BitWiseOrOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = or i64 %0, %1
  store i64 %2, ptr %c, align 4
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32PowerOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = call i64 @u32_power(i64 %0, i64 %1)
  store i64 %2, ptr %c, align 4
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32LeftShiftOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = call i64 @u32_power(i64 2, i64 %1)
  %3 = mul i64 %0, %2
  call void @builtin_range_check(i64 %3)
  store i64 %3, ptr %c, align 4
  %4 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %4, i64 3)
  ret void
}

define void @testU32RightShiftOperation() {
entry:
  %c = alloca i64, align 8
  %0 = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %1 = load i64, ptr %a, align 4
  %2 = load i64, ptr %b, align 4
  %3 = call i64 @u32_power(i64 2, i64 %2)
  call void @u32_div_mod(i64 %1, i64 %3, ptr %0, ptr null)
  %4 = load i64, ptr %0, align 4
  store i64 %4, ptr %c, align 4
  %5 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %5, i64 3)
  ret void
}

define void @testU32EqualOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = icmp eq i64 %0, %1
  store i1 %2, ptr %c, align 1
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32NotEqualOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = icmp ne i64 %0, %1
  store i1 %2, ptr %c, align 1
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32GreaterOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = icmp ugt i64 %0, %1
  store i1 %2, ptr %c, align 1
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32GreaterEqualOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = icmp uge i64 %0, %1
  store i1 %2, ptr %c, align 1
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32LessOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = icmp ult i64 %0, %1
  store i1 %2, ptr %c, align 1
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32LessEqualOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = icmp ule i64 %0, %1
  store i1 %2, ptr %c, align 1
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32IfStatement() {
entry:
  %a = alloca i64, align 8
  store i64 10, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  %1 = icmp ugt i64 %0, 5
  br i1 %1, label %then, label %else

then:                                             ; preds = %entry
  %2 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %2, i64 3)
  br label %endif

else:                                             ; preds = %entry
  call void @prophet_printf(i64 0, i64 3)
  br label %endif

endif:                                            ; preds = %else, %then
  ret void
}

define void @testU32InLoopStatement() {
entry:
  %a = alloca i64, align 8
  %i = alloca i64, align 8
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %0 = load i64, ptr %i, align 4
  %1 = icmp ult i64 %0, 10
  br i1 %1, label %body, label %endfor

body:                                             ; preds = %cond
  %2 = load i64, ptr %i, align 4
  store i64 %2, ptr %a, align 4
  %3 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %3, i64 3)
  br label %next

next:                                             ; preds = %body
  %4 = load i64, ptr %i, align 4
  %5 = add i64 %4, 1
  store i64 %5, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void
}