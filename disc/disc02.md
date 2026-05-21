# CS 61C C Basics / C 基础

Summer 2020 Discussion 2: June 24, 2020  
2020 夏季讨论 2：2020 年 6 月 24 日

## 1. Pre-Check / 课前检查

This section is designed as a conceptual check for you to determine if you conceptually understand and have any misconceptions about this topic. Please answer true/false to the following questions, and include an explanation.  
本节用于概念检查，帮助你判断自己是否理解本主题，以及是否存在误解。请对以下问题回答真/假，并给出解释。

### 1.1 True or False: C is a pass-by-value language.

### 1.1 判断正误：C 是按值传递语言。

**Answer / 答案：True / 真。**

**Explanation / 解析：**

C 的函数参数总是按值传递。调用函数时，实参的值会被复制到形参中。即使传入的是指针，复制的也是“地址值”本身；函数可以通过这个地址修改被指向的对象，但不能改变调用者手里的指针变量本身，除非传入指针的指针。

```c
void f(int x) { x = 5; }          // 只改局部副本
void g(int *p) { *p = 5; }        // 通过地址改调用者的 int
void h(int **pp) { *pp = NULL; }  // 通过二级指针改调用者的指针
```

### 1.2 What is a pointer? What does it have in common to an array variable?

### 1.2 什么是指针？它和数组变量有什么共同点？

**Answer / 答案：**

A pointer is a variable that stores a memory address. An array variable often behaves like a pointer to its first element in expressions.  
指针是存储内存地址的变量。数组变量在表达式中通常会退化为指向其第一个元素的指针。

**Explanation / 解析：**

指针变量 `p` 的值是某个对象的地址，`*p` 表示访问该地址处的对象。数组名 `arr` 在大多数表达式中会转换为 `&arr[0]`，因此 `arr[i]` 和 `*(arr + i)` 等价。

但数组和指针并不完全相同：数组名本身不是可重新赋值的变量，`sizeof(arr)` 在同一作用域内得到整个数组大小，而 `sizeof(p)` 只得到指针大小。

### 1.3 If you try to dereference a variable that is not a pointer, what will happen? What about when you free one?

### 1.3 如果尝试解引用一个不是指针的变量，会发生什么？如果对它调用 `free` 呢？

**Answer / 答案：**

Usually it is a compile-time type error. If forced through casts, dereferencing or freeing an invalid non-pointer value causes undefined behavior.  
通常会产生编译期类型错误。如果通过强制类型转换绕过检查，解引用或释放非法的非指针值会导致未定义行为。

**Explanation / 解析：**

`*x` 要求 `x` 具有指针类型；`free(x)` 要求 `x` 是由 `malloc`、`calloc`、`realloc` 返回的堆指针，或者是 `NULL`。对普通整数、栈地址、全局变量地址、字符串字面量地址等调用 `free` 都是错误的。

### 1.4 When should you use the heap over the stack? Do they grow?

### 1.4 什么时候应该使用堆而不是栈？它们会增长吗？

**Answer / 答案：**

Use the heap when data must outlive the current function, when the size is large, or when the size is only known at runtime and should be manually managed. Both stack and heap can grow as a program runs, but in typical systems they grow in opposite directions.  
当数据需要在当前函数返回后继续存在、数据很大，或大小在运行时才知道且需要手动管理时，应使用堆。栈和堆都可能随程序运行而增长，但在典型系统中它们通常朝相反方向增长。

**Explanation / 解析：**

栈内存由函数调用自动分配和释放，函数返回后局部变量失效。堆内存由程序员用 `malloc` 等手动申请，并用 `free` 手动释放。堆适合跨函数生命周期的数据结构，例如链表、树、动态数组等。

## 2. C / C 语言

C is syntactically similar to Java, but there are a few key differences.  
C 在语法上和 Java 相似，但有几个关键区别。

1. C is function-oriented, not object-oriented; there are no objects.  
   C 是面向函数的，不是面向对象的；C 中没有对象。

2. C does not automatically handle memory for you.  
   C 不会自动替你管理内存。

Stack memory, or things that are not manually allocated: data is garbage immediately after the function in which it was defined returns.  
栈内存，或者说没有手动分配的对象：定义它的函数返回后，这些数据立即失效。

Heap memory, or things allocated with `malloc`, `calloc`, or `realloc`: data is freed only when the programmer explicitly frees it.  
堆内存，或者说通过 `malloc`、`calloc`、`realloc` 分配的对象：只有程序员显式释放时才会释放。

There are two other sections of memory that we learn about in this course, static and code, but we’ll get to those later.  
本课程还会学习另外两个内存区域：静态区和代码区，但之后再讲。

In any case, allocated memory always holds garbage until it is initialized.  
无论哪种情况，分配出的内存在初始化前都保存着垃圾值。

3. C uses pointers explicitly. If `p` is a pointer, then `*p` tells us to use the value that `p` points to, rather than the value of `p`, and `&x` gives the address of `x` rather than the value of `x`.  
   C 显式使用指针。如果 `p` 是指针，那么 `*p` 表示使用 `p` 所指向位置的值，而不是 `p` 自身的值；`&x` 表示 `x` 的地址，而不是 `x` 的值。

On the left is the memory represented as a box-and-pointer diagram. On the right, we see how the memory is really represented in the computer.  
左边是用框和箭头表示的内存图。右边展示了内存在计算机中真实的表示方式。

Let’s assume that `int *p` is located at `0xF9320904` and `int x` is located at `0xF93209B0`. As we can observe:  
假设 `int *p` 位于 `0xF9320904`，`int x` 位于 `0xF93209B0`。可以观察到：

- `*p` evaluates to `0x2A` (`42` in decimal).  
  `*p` 的值是 `0x2A`（十进制 `42`）。
- `p` evaluates to `0xF93209AC`.  
  `p` 的值是 `0xF93209AC`。
- `x` evaluates to `0x61C`.  
  `x` 的值是 `0x61C`。
- `&x` evaluates to `0xF93209B0`.  
  `&x` 的值是 `0xF93209B0`。

Let’s say we have an `int **pp` that is located at `0xF9320900`.  
假设还有一个位于 `0xF9320900` 的 `int **pp`。

### 2.1 What does `pp` evaluate to? How about `*pp`? What about `**pp`?

### 2.1 `pp` 的值是什么？`*pp` 呢？`**pp` 呢？

**Answer / 答案：**

- `pp` evaluates to `0xF9320904`.
- `*pp` evaluates to `0xF93209AC`.
- `**pp` evaluates to `0x2A` (`42` in decimal).

**Explanation / 解析：**

`pp` 是二级指针，它保存 `p` 的地址，所以 `pp == &p == 0xF9320904`。`*pp` 表示取出 `p` 本身的值，即 `0xF93209AC`。`**pp` 等价于 `*p`，表示取出 `p` 指向的整数，即 `0x2A`。

### 2.2 The following functions are syntactically-correct C, but written in an incomprehensible style. Describe the behavior of each function in plain English.

### 2.2 以下函数在语法上是正确的 C，但写法晦涩。请用自然语言描述每个函数的行为。

#### 2.2(a)

Recall that the ternary operator evaluates the condition before the `?` and returns the value before the colon `:` if true, or the value after it if false.  
回忆：三元运算符会先计算 `?` 前面的条件；如果为真，返回冒号前的值；如果为假，返回冒号后的值。

```c
int foo(int *arr, size_t n) {
    return n ? arr[0] + foo(arr + 1, n - 1) : 0;
}
```

**Answer / 答案：**

It recursively returns the sum of the first `n` integers in `arr`.  
它递归返回数组 `arr` 前 `n` 个整数的和。

**Explanation / 解析：**

当 `n == 0` 时返回 `0`。否则返回当前第一个元素 `arr[0]` 加上剩余 `n - 1` 个元素的和。`arr + 1` 指向下一个整数。

#### 2.2(b)

Recall that the negation operator, `!`, returns `0` if the value is non-zero, and `1` if the value is `0`. The `~` operator performs a bitwise NOT operation.  
回忆：逻辑非运算符 `!` 在值非零时返回 `0`，在值为 `0` 时返回 `1`。`~` 运算符执行按位取反。

```c
int bar(int *arr, size_t n) {
    int sum = 0, i;
    for (i = n; i > 0; i--)
        sum += !arr[i - 1];
    return ~sum + 1;
}
```

**Answer / 答案：**

It returns the negative of the number of zero elements among the first `n` elements of `arr`.  
它返回 `arr` 前 `n` 个元素中零元素个数的相反数。

**Explanation / 解析：**

`!arr[i - 1]` 在元素为 `0` 时为 `1`，否则为 `0`，因此 `sum` 是零元素个数。二补码中 `~sum + 1` 等价于 `-sum`。

#### 2.2(c)

Recall that `^` is the bitwise exclusive-or (XOR) operator.  
回忆：`^` 是按位异或运算符。

```c
void baz(int x, int y) {
    x = x ^ y;
    y = x ^ y;
    x = x ^ y;
}
```

**Answer / 答案：**

Inside the function, it swaps the local variables `x` and `y` using XOR, but the caller sees no change.  
在函数内部，它用异或交换局部变量 `x` 和 `y`，但调用者看不到任何变化。

**Explanation / 解析：**

异或交换的数学性质可实现无临时变量交换。但 C 按值传参，`x` 和 `y` 是调用者实参的副本，所以函数返回后外部变量不变。

#### 2.2(d) Bonus: How do you write the bitwise exclusive-nor (XNOR) operator in C?

#### 2.2(d) 加分：如何在 C 中写按位同或（XNOR）运算？

**Answer / 答案：**

```c
~(x ^ y)
```

**Explanation / 解析：**

XNOR 是 XOR 的按位取反。`x ^ y` 在对应位不同的时候为 `1`，`~(x ^ y)` 则在对应位相同的时候为 `1`。

## 3. Programming with Pointers / 使用指针编程

### 3.1 Implement the following functions so that they work as described.

### 3.1 实现以下函数，使其符合描述。

#### 3.1(a) Swap the value of two ints. Remain swapped after returning from this function.

#### 3.1(a) 交换两个 `int` 的值，并在函数返回后保持交换结果。

```c
void swap(int *x, int *y) {
    int temp = *x;
    *x = *y;
    *y = temp;
}
```

**Explanation / 解析：**

要让交换结果影响调用者，必须传入两个整数的地址。函数通过 `*x` 和 `*y` 修改地址处的实际整数，而不是修改局部副本。

#### 3.1(b) Return the number of bytes in a string. Do not use `strlen`.

#### 3.1(b) 返回字符串中的字节数。不要使用 `strlen`。

```c
int mystrlen(char *str) {
    int len = 0;
    while (*str != '\0') {
        len++;
        str++;
    }
    return len;
}
```

**Explanation / 解析：**

C 字符串以空字符 `\0` 结尾。逐个字符前进，直到遇到 `\0`，计数就是不包含终止符的字节数。

### 3.2 The following functions may contain logic or syntax errors. Find and correct them.

### 3.2 以下函数可能包含逻辑或语法错误。请找出并修正。

#### 3.2(a) Returns the sum of all the elements in `summands`.

#### 3.2(a) 返回 `summands` 中所有元素的和。

Original / 原代码：

```c
int sum(int* summands) {
    int sum = 0;
    for (int i = 0; i < sizeof(summands); i++)
        sum += *(summands + i);
    return sum;
}
```

**Corrected / 修正：**

```c
int sum(int *summands, size_t n) {
    int total = 0;
    for (size_t i = 0; i < n; i++) {
        total += summands[i];
    }
    return total;
}
```

**Explanation / 解析：**

函数参数中的 `int *summands` 只是指针，`sizeof(summands)` 得到的是指针大小，不是数组长度。因此必须额外传入数组长度 `n`。

#### 3.2(b) Increments all of the letters in the string which is stored at the front of an array of arbitrary length, `n >= strlen(string)`. Does not modify any other parts of the array’s memory.

#### 3.2(b) 将存储在任意长度数组开头的字符串中所有字母加一，且 `n >= strlen(string)`。不要修改数组内存中的其他部分。

Original / 原代码：

```c
void increment(char* string, int n) {
    for (int i = 0; i < n; i++)
        *(string + i)++;
}
```

**Corrected / 修正：**

```c
void increment(char *string, int n) {
    for (int i = 0; i < n && string[i] != '\0'; i++) {
        string[i]++;
    }
}
```

**Explanation / 解析：**

原代码的 `*(string + i)++` 因运算符优先级会尝试递增指针表达式，而不是字符值，并且没有在字符串终止符处停止。正确做法是只处理 `\0` 之前的字符，避免修改字符串后面的数组内存。

#### 3.2(c) Copies the string `src` to `dst`.

#### 3.2(c) 将字符串 `src` 复制到 `dst`。

Original / 原代码：

```c
void copy(char* src, char* dst) {
    while (*dst++ = *src++);
}
```

**Corrected / 修正：**

```c
void copy(char *src, char *dst) {
    while ((*dst++ = *src++) != '\0') {
    }
}
```

**Explanation / 解析：**

原代码逻辑上可以工作，但编译器可能警告“在条件中使用赋值”。加上括号和显式比较能表达意图。循环会连同终止符 `\0` 一起复制。

#### 3.2(d) Overwrites an input string `src` with `"61C is awesome!"` if there’s room. Does nothing if there is not. Assume that `length` correctly represents the length of `src`.

#### 3.2(d) 如果有足够空间，用 `"61C is awesome!"` 覆盖输入字符串 `src`；如果没有空间则什么也不做。假设 `length` 正确表示 `src` 的长度。

Original / 原代码：

```c
void cs61c(char* src, size_t length) {
    char *srcptr, replaceptr;
    char replacement[16] = "61C is awesome!";
    srcptr = src;
    replaceptr = replacement;
    if (length >= 16) {
        for (int i = 0; i < 16; i++)
            *srcptr++ = *replaceptr++;
    }
}
```

**Corrected / 修正：**

```c
void cs61c(char *src, size_t length) {
    char *srcptr, *replaceptr;
    char replacement[16] = "61C is awesome!";
    srcptr = src;
    replaceptr = replacement;
    if (length >= 16) {
        for (int i = 0; i < 16; i++) {
            *srcptr++ = *replaceptr++;
        }
    }
}
```

**Explanation / 解析：**

`replaceptr` 原来声明成了 `char`，但它应该是 `char *`。字符串 `"61C is awesome!"` 有 15 个可见字符，加上终止符 `\0` 共 16 字节，所以需要 `length >= 16`。循环复制 16 个字节，包含终止符。

## 4. Memory Management / 内存管理

### 4.1 For each part, choose one or more of the following memory segments where the data could be located: `code`, `static`, `heap`, `stack`.

### 4.1 对每一项，从以下内存段中选择数据可能位于的位置：`code`、`static`、`heap`、`stack`。

#### 4.1(a) Static variables / 静态变量

**Answer / 答案：`static` / 静态区。**

**Explanation / 解析：**

`static` 局部变量和全局静态变量具有静态存储期，通常位于静态数据区。

#### 4.1(b) Local variables / 局部变量

**Answer / 答案：usually `stack` / 通常在栈上。**

**Explanation / 解析：**

普通局部变量随函数调用创建、函数返回销毁，通常位于栈上。若局部变量声明为 `static`，则位于静态区。

#### 4.1(c) Global variables / 全局变量

**Answer / 答案：`static` / 静态区。**

**Explanation / 解析：**

全局变量具有静态存储期，程序整个运行期间都存在。

#### 4.1(d) Constants / 常量

**Answer / 答案：`code` or `static`, sometimes immediate values in instructions / 代码区或静态区，有时作为指令中的立即数。**

**Explanation / 解析：**

编译器可能把常量放在只读数据区、代码区，或直接编码进机器指令。具体位置取决于常量类型和编译器实现。

#### 4.1(e) Machine Instructions / 机器指令

**Answer / 答案：`code` / 代码区。**

**Explanation / 解析：**

程序的机器指令存放在代码段，通常只读、可执行。

#### 4.1(f) Result of `malloc` / `malloc` 的结果

**Answer / 答案：`heap` / 堆。**

**Explanation / 解析：**

`malloc` 返回的地址指向堆上分配的内存，需要用 `free` 释放。

#### 4.1(g) String Literals / 字符串字面量

**Answer / 答案：`static`, often read-only static storage / 静态区，通常是只读静态存储。**

**Explanation / 解析：**

字符串字面量具有静态存储期，通常放在只读数据区。修改字符串字面量是未定义行为。

### 4.2 Write the code necessary to allocate memory on the heap in the following scenarios.

### 4.2 写出在以下场景中在堆上分配内存所需的代码。

#### 4.2(a) An array `arr` of `k` integers

#### 4.2(a) 一个包含 `k` 个整数的数组 `arr`

```c
int *arr = malloc(k * sizeof(int));
```

**Explanation / 解析：**

每个 `int` 占 `sizeof(int)` 字节，因此总共需要 `k * sizeof(int)` 字节。

#### 4.2(b) A string `str` containing `p` characters

#### 4.2(b) 一个包含 `p` 个字符的字符串 `str`

```c
char *str = malloc((p + 1) * sizeof(char));
```

**Explanation / 解析：**

C 字符串需要额外一个字节存放终止符 `\0`，所以是 `p + 1` 个 `char`。

#### 4.2(c) An `n x m` matrix `mat` of integers initialized to zero.

#### 4.2(c) 一个初始化为零的 `n x m` 整数矩阵 `mat`。

**Option 1: contiguous allocation / 方式 1：连续分配**

```c
int *mat = calloc(n * m, sizeof(int));
```

访问元素时使用：

```c
mat[i * m + j]
```

**Option 2: array of row pointers / 方式 2：行指针数组**

```c
int **mat = malloc(n * sizeof(int *));
for (int i = 0; i < n; i++) {
    mat[i] = calloc(m, sizeof(int));
}
```

**Explanation / 解析：**

`calloc` 会把分配出的内存初始化为 0。连续分配更简单、更利于缓存；行指针形式可以用 `mat[i][j]` 访问，但需要逐行释放。

### 4.3 What’s the main issue with the code snippet seen here? Hint: `gets()` is a function that reads in user input and stores it in the array given in the argument.

### 4.3 下面代码片段的主要问题是什么？提示：`gets()` 会读取用户输入并存储到作为参数给出的数组中。

```c
char* foo() {
    char* buffer[64];
    gets(buffer);

    char* important_stuff = (char*) malloc(11 * sizeof(char));

    int i;
    for (i = 0; i < 10; i++) important_stuff[i] = buffer[i];
    important_stuff[i] = '\0';
    return important_stuff;
}
```

**Answer / 答案：**

The main issue is unsafe input and type misuse: `buffer` is declared as an array of 64 `char *`, not 64 `char`, and `gets` can overflow the buffer because it performs no bounds checking.  
主要问题是不安全输入和类型错误：`buffer` 被声明成 64 个 `char *` 的数组，而不是 64 个 `char`；并且 `gets` 不做边界检查，可能导致缓冲区溢出。

**Explanation / 解析：**

应使用 `char buffer[64];` 表示 64 字节字符缓冲区，并用 `fgets(buffer, sizeof(buffer), stdin)` 代替 `gets`。`gets` 已从 C 标准中移除，因为它无法防止用户输入超过缓冲区大小。

Possible safer version / 一种更安全写法：

```c
char *foo(void) {
    char buffer[64];
    if (fgets(buffer, sizeof(buffer), stdin) == NULL) {
        return NULL;
    }

    char *important_stuff = malloc(11 * sizeof(char));
    if (important_stuff == NULL) {
        return NULL;
    }

    int i;
    for (i = 0; i < 10 && buffer[i] != '\0'; i++) {
        important_stuff[i] = buffer[i];
    }
    important_stuff[i] = '\0';
    return important_stuff;
}
```

Suppose we’ve defined a linked list struct as follows. Assume `*lst` points to the first element of the list, or is `NULL` if the list is empty.  
假设我们定义了如下链表结构体。假设 `*lst` 指向链表第一个元素；若链表为空，则为 `NULL`。

```c
struct ll_node {
    int first;
    struct ll_node *rest;
};
```

### 4.4 Implement `prepend`, which adds one new value to the front of the linked list. Hint: why use `ll_node **lst` instead of `ll_node *lst`?

### 4.4 实现 `prepend`，向链表头部添加一个新值。提示：为什么使用 `ll_node **lst` 而不是 `ll_node *lst`？

```c
void prepend(struct ll_node **lst, int value) {
    struct ll_node *new_node = malloc(sizeof(struct ll_node));
    if (new_node == NULL) {
        return;
    }

    new_node->first = value;
    new_node->rest = *lst;
    *lst = new_node;
}
```

**Explanation / 解析：**

头插会改变链表头指针本身。如果只传 `struct ll_node *lst`，函数得到的是头指针的副本，无法修改调用者的头指针。传 `struct ll_node **lst` 后，`*lst = new_node` 可以更新调用者持有的链表头。

### 4.5 Implement `free_ll`, which frees all the memory consumed by the linked list.

### 4.5 实现 `free_ll`，释放链表占用的所有内存。

```c
void free_ll(struct ll_node **lst) {
    struct ll_node *curr = *lst;
    while (curr != NULL) {
        struct ll_node *next = curr->rest;
        free(curr);
        curr = next;
    }
    *lst = NULL;
}
```

**Explanation / 解析：**

释放当前节点前必须先保存下一个节点地址，否则 `free(curr)` 后再访问 `curr->rest` 会使用已释放内存。最后把调用者的头指针置为 `NULL`，避免悬空指针。
