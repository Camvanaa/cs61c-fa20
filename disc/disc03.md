# CS 61C Floating Point / 浮点数

Summer 2020 Discussion 3: June 29, 2020  
2020 夏季讨论 3：2020 年 6 月 29 日

## 1. Pre-Check / 课前检查

This section is designed as a conceptual check for you to determine if you conceptually understand and have any misconceptions about this topic. Please answer true/false to the following questions, and include an explanation.  
本节用于概念检查，帮助你判断自己是否理解本主题，以及是否存在误解。请对以下问题回答真/假，并给出解释。

### 1.1 True or False. The goals of floating point are to have a large range of values, a low amount of precision, and real arithmetic results.

### 1.1 判断正误：浮点数的目标是拥有很大的取值范围、较低的精度，以及真实的算术结果。

**Answer / 答案：False / 假。**

**Explanation / 解析：**

浮点数的目标是在有限位数内近似表示很大范围的实数，并尽量提供有用的精度。它不是为了“低精度”，也不能保证真实数学意义上的精确实数运算。很多十进制小数和分数无法被二进制浮点精确表示，运算也会发生舍入。

### 1.2 True or False. The distance between floating point numbers increase as the absolute value of the numbers increase.

### 1.2 判断正误：随着浮点数绝对值增大，相邻浮点数之间的距离也会增大。

**Answer / 答案：True / 真。**

**Explanation / 解析：**

规格化浮点数的有效数字位数固定。当指数变大时，同样的尾数字段变化 1 所代表的实际值也会变大，因此相邻可表示数之间的间隔会增大。

### 1.3 True or False. Floating Point addition is associative.

### 1.3 判断正误：浮点加法满足结合律。

**Answer / 答案：False / 假。**

**Explanation / 解析：**

浮点加法会舍入，且大数和小数相加时小数可能被丢失，因此 `(a + b) + c` 不一定等于 `a + (b + c)`。

Example / 示例：

```text
(1e20 + -1e20) + 3.14 = 3.14
1e20 + (-1e20 + 3.14) = 0      // 3.14 is lost when added to -1e20
```

## 2. Floating Point / 浮点数

The IEEE 754 standard defines a binary representation for floating point values using three fields.  
IEEE 754 标准使用三个字段定义浮点值的二进制表示。

- The sign determines the sign of the number, `0` for positive and `1` for negative.  
  符号位决定数的正负，`0` 表示正，`1` 表示负。
- The exponent is in biased notation. For instance, the bias is `-127`, which comes from `-(2^(8-1) - 1)`, for single-precision floating point numbers.  
  指数字段采用偏置表示。对于单精度浮点数，偏置是 `-127`，来自 `-(2^(8-1) - 1)`。
- The significand or mantissa is akin to unsigned integers, but used to store a fraction instead of an integer.  
  有效数或尾数类似无符号整数，但它用于存储小数部分而不是整数。

The below table shows the bit breakdown for the single precision (32-bit) representation. The leftmost bit is the MSB and the rightmost bit is the LSB.  
下表展示单精度（32 位）表示的比特划分。最左边是最高有效位，最右边是最低有效位。

| Sign / 符号 | Exponent / 指数 | Mantissa, Significand, Fraction / 尾数、有效数、小数 |
| --- | --- | --- |
| 1 bit | 8 bits | 23 bits |

For normalized floats:  
对于规格化浮点数：

```text
Value = (-1)^Sign * 2^(Exp + Bias) * 1.significand_2
```

For denormalized floats:  
对于非规格化浮点数：

```text
Value = (-1)^Sign * 2^(Exp + Bias + 1) * 0.significand_2
```

For single precision, `Bias = -127`, so normalized floats use exponent `Exp - 127`, and denormalized floats use exponent `1 - 127 = -126`.  
对单精度而言，`Bias = -127`，因此规格化浮点数使用指数 `Exp - 127`，非规格化浮点数使用指数 `1 - 127 = -126`。

| Exponent / 指数字段 | Significand / 有效数字段 | Meaning / 含义 |
| --- | --- | --- |
| `0` | Anything / 任意 | Denorm / 非规格化数 |
| `1-254` | Anything / 任意 | Normal / 规格化数 |
| `255` | `0` | Infinity / 无穷 |
| `255` | Nonzero / 非零 | NaN |

Note that in the above table, our exponent has values from `0` to `255`. When translating between binary and decimal floating point values, we must remember that there is a bias for the exponent.  
注意，上表中的指数字段取值范围是 `0` 到 `255`。在二进制浮点值和十进制值之间转换时，必须记住指数存在偏置。

### 2.1 How many zeroes can be represented using a float?

### 2.1 `float` 可以表示多少个零？

**Answer / 答案：Two / 两个。**

**Explanation / 解析：**

IEEE 754 有 `+0` 和 `-0`。二者的指数和尾数字段全为 0，符号位分别为 0 和 1。

```text
+0: 0x00000000
-0: 0x80000000
```

### 2.2 What is the largest finite positive value that can be stored using a single precision float?

### 2.2 单精度浮点数能存储的最大有限正数是什么？

**Answer / 答案：**

```text
(2 - 2^-23) * 2^127
```

**Explanation / 解析：**

最大有限正数要求符号位为 `0`，最大规格化指数为 `Exp = 254`，实际指数为 `254 - 127 = 127`，尾数全为 1。有效数为：

```text
1.111...111_2 = 2 - 2^-23
```

因此最大有限正数为 `(2 - 2^-23) * 2^127`。

### 2.3 What is the smallest positive value that can be stored using a single precision float?

### 2.3 单精度浮点数能存储的最小正数是什么？

**Answer / 答案：**

```text
2^-149
```

**Explanation / 解析：**

最小正数是最小的正非规格化数：符号位为 `0`，指数字段为 `0`，尾数字段只有最低位为 `1`。非规格化有效数为 `2^-23`，指数为 `-126`，所以值为：

```text
2^-126 * 2^-23 = 2^-149
```

### 2.4 What is the smallest positive normalized value that can be stored using a single precision float?

### 2.4 单精度浮点数能存储的最小正规格化数是什么？

**Answer / 答案：**

```text
2^-126
```

**Explanation / 解析：**

最小正规格化数的 `Exp = 1`，实际指数为 `1 - 127 = -126`，尾数全为 0，有效数为 `1.0`，因此值为 `1.0 * 2^-126`。

### 2.5 Convert the following single-precision floating point numbers from binary to decimal or from decimal to binary. You may leave your answer as an expression.

### 2.5 将以下单精度浮点数在二进制和十进制之间转换。答案可以保留为表达式。

#### 2.5(a) `0x00000000`

**Answer / 答案：**

```text
0.0 (+0)
```

**Explanation / 解析：**

符号位为 0，指数全 0，尾数全 0，表示正零。

#### 2.5(b) `8.25`

**Answer / 答案：**

```text
0x41040000
```

Binary fields / 二进制字段：

```text
sign = 0
exponent = 10000010
mantissa = 00001000000000000000000
```

**Explanation / 解析：**

`8.25 = 1000.01_2 = 1.00001_2 * 2^3`。实际指数为 `3`，指数字段为 `3 + 127 = 130 = 10000010_2`。小数部分为 `00001` 后补 0 到 23 位。

#### 2.5(c) `0x00000F00`

**Answer / 答案：**

```text
15 * 2^-141
```

Equivalent form / 等价形式：

```text
(0x000F00 / 2^23) * 2^-126 = 3840 * 2^-149 = 15 * 2^-141
```

**Explanation / 解析：**

`0x00000F00` 的符号位为 0，指数字段为 0，所以是非规格化数。尾数字段为 `0x000F00 = 3840 = 15 * 2^8`。非规格化数值为：

```text
(3840 / 2^23) * 2^-126
= 3840 * 2^-149
= 15 * 2^8 * 2^-149
= 15 * 2^-141
```

#### 2.5(d) `39.5625`

**Answer / 答案：**

```text
0x421E4000
```

Binary fields / 二进制字段：

```text
sign = 0
exponent = 10000100
mantissa = 00111100100000000000000
```

**Explanation / 解析：**

`39 = 100111_2`，`0.5625 = 0.1001_2`，所以：

```text
39.5625 = 100111.1001_2 = 1.001111001_2 * 2^5
```

实际指数为 `5`，指数字段为 `5 + 127 = 132 = 10000100_2`。尾数保存小数部分 `001111001` 后补 0 到 23 位。

#### 2.5(e) `0xFF94BEEF`

**Answer / 答案：**

```text
NaN
```

**Explanation / 解析：**

`0xFF94BEEF` 的符号位为 1，指数字段全为 1 (`255`)，尾数字段非零，因此根据 IEEE 754 表示 NaN。NaN 不表示普通数值；符号位对 NaN 的数值含义通常不重要。

#### 2.5(f) `-infinity`

#### 2.5(f) `-∞`

**Answer / 答案：**

```text
0xFF800000
```

Binary fields / 二进制字段：

```text
sign = 1
exponent = 11111111
mantissa = 00000000000000000000000
```

**Explanation / 解析：**

无穷要求指数字段全为 1，尾数字段全为 0。负无穷的符号位为 1。

## 3. More Floating Point Representation / 更多浮点数表示

Not every number can be represented perfectly using floating point. For example, `1/3` can only be approximated and thus must be rounded in any attempt to represent it. For this question, we will only look at positive numbers.  
并非每个数都能用浮点数精确表示。例如，`1/3` 只能近似表示，因此任何表示它的尝试都必须舍入。本题只考虑正数。

### 3.1 What is the next smallest number larger than `2` that can be represented completely?

### 3.1 大于 `2` 且能被精确表示的最小下一个数是什么？

**Answer / 答案：**

```text
2 + 2^-22
```

**Explanation / 解析：**

`2 = 1.0 * 2^1`。单精度有 23 个显式尾数位，在指数为 `1` 的区间内，尾数字段最小增量对应：

```text
2^1 * 2^-23 = 2^-22
```

所以 2 后的下一个可表示数是 `2 + 2^-22`。

### 3.2 What is the next smallest number larger than `4` that can be represented completely?

### 3.2 大于 `4` 且能被精确表示的最小下一个数是什么？

**Answer / 答案：**

```text
4 + 2^-21
```

**Explanation / 解析：**

`4 = 1.0 * 2^2`。指数为 `2` 时，尾数字段增加 1 对应实际值增量：

```text
2^2 * 2^-23 = 2^-21
```

### 3.3 Define stepsize to be the distance between some value `x` and the smallest value larger than `x` that can be completely represented. What is the step size for `2`? `4`?

### 3.3 定义步长为某个值 `x` 与大于 `x` 的最小可精确表示值之间的距离。`2` 和 `4` 的步长是多少？

**Answer / 答案：**

```text
stepsize(2) = 2^-22
stepsize(4) = 2^-21
```

**Explanation / 解析：**

步长就是上一两题中“下一个可表示数”和原数之间的差。

### 3.4 Now let’s see if we can generalize the stepsize for normalized numbers. If we are given a normalized number that is not the largest representable normalized number with exponent value `x` and with significand value `y`, what is the stepsize at that value? Hint: There are 23 significand bits.

### 3.4 现在尝试推广规格化数的步长。若给定一个规格化数，它不是指数值为 `x` 时可表示的最大规格化数，并且有效数字段值为 `y`，那么该值处的步长是多少？提示：有效数字段有 23 位。

**Answer / 答案：**

If `x` is the unbiased exponent, the stepsize is:  
如果 `x` 是无偏实际指数，则步长为：

```text
2^(x - 23)
```

If `x` is the stored exponent field, the stepsize is:  
如果 `x` 是存储的指数字段，则步长为：

```text
2^(x - 127 - 23) = 2^(x - 150)
```

**Explanation / 解析：**

规格化数值可写为：

```text
(1 + y / 2^23) * 2^x
```

当尾数字段 `y` 增加 1 时，数值增加：

```text
(1 / 2^23) * 2^x = 2^(x - 23)
```

题目排除了“该指数下最大尾数”的情况，因此下一个数仍在同一指数区间内，不需要处理指数进位。

### 3.5 Now let’s apply this technique. What is the largest odd number that we can represent? Part 4 should be very useful in finding this answer.

### 3.5 应用上述技巧。我们能表示的最大奇数是多少？第 4 小题对求解很有帮助。

**Answer / 答案：**

```text
2^24 - 1 = 16,777,215
```

**Explanation / 解析：**

单精度浮点数有 24 位有效精度：1 个隐藏的 leading 1 加 23 个显式尾数位。因此所有绝对值不超过 `2^24` 的整数都可以精确表示，包括最大的连续奇数 `2^24 - 1`。

当数值达到 `2^24` 附近时，步长变为：

```text
2^(24 - 23) = 2
```

之后可表示整数之间至少相差 2，只能表示偶数、4 的倍数、8 的倍数等更稀疏的整数，不再能表示更大的奇数。因此最大可表示奇数是 `2^24 - 1`。
