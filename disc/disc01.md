# CS 61C Number Representation / 数字表示

Summer 2020 Discussion 1: June 22th, 2020  
2020 夏季讨论 1：2020 年 6 月 22 日

## 1. Pre-Check / 课前检查

This section is designed as a conceptual check for you to determine if you conceptually understand and have any misconceptions about this topic. Please answer true/false to the following questions, and include an explanation.  
本节用于概念检查，帮助你判断自己是否理解本主题，以及是否存在误解。请对以下问题回答真/假，并给出解释。

### 1.1 Depending on the context, the same sets of bits may represent different things.

### 1.1 根据上下文，同一组比特可以表示不同的东西。

**Answer / 答案：True / 真。**

**Explanation / 解析：**

比特本身只是 0 和 1 的序列，含义由解释方式决定。例如 `11111111` 可以被解释为无符号整数 `255`，8 位补码整数 `-1`，ASCII/扩展编码中的字符，或者浮点数的一部分。

### 1.2 It is possible to get an overflow error in Two’s Complement when adding numbers of opposite signs.

### 1.2 在补码中，相反符号的数相加可能发生溢出。

**Answer / 答案：False / 假。**

**Explanation / 解析：**

补码加法中，只有同号数相加并得到异号结果时才会溢出。相反符号相加等价于做减法，结果的绝对值不会超过两个操作数中绝对值较大的那个，因此不会发生补码溢出。

### 1.3 If you interpret an N bit Two’s complement number as an unsigned number, negative numbers would be smaller than positive numbers.

### 1.3 如果把一个 N 位补码数解释为无符号数，负数会比正数小。

**Answer / 答案：False / 假。**

**Explanation / 解析：**

N 位补码负数的最高位为 `1`，如果把它当作无符号数解释，会落在 `2^(N-1)` 到 `2^N - 1` 的范围内。补码非负数最高位为 `0`，当作无符号数解释时在 `0` 到 `2^(N-1)-1` 范围内。因此负数的比特模式作为无符号数通常比正数更大。

### 1.4 If you interpret an N bit Bias notation number as an unsigned number (assume there are negative numbers for the given bias), negative numbers would be smaller than positive numbers.

### 1.4 如果把一个 N 位偏置表示数解释为无符号数（假设该偏置下存在负数），负数会比正数小。

**Answer / 答案：True / 真。**

**Explanation / 解析：**

偏置表示通常满足：实际值 = 无符号编码值 + bias。这个关系对编码值是单调递增的，所以实际值越小，编码值也越小。因此负数的编码会小于正数的编码。

## 2. Unsigned Integers / 无符号整数

### 2.1 Positional notation / 位权表示法

If we have an `n`-digit unsigned numeral `d_(n-1)d_(n-2)...d_0` in radix or base `r`, then the value of that numeral is `sum from i=0 to n-1 of r^i d_i`, which is just fancy notation to say that instead of a 10’s or 100’s place we have an `r`’s or `r^2`’s place. For the three radices binary, decimal, and hex, we just let `r` be `2`, `10`, and `16`, respectively.  
如果有一个 `n` 位无符号数 `d_(n-1)d_(n-2)...d_0`，其进制为 `r`，那么它的值为 `sum from i=0 to n-1 of r^i d_i`。这只是用更正式的方式说明：除了十进制中的十位、百位之外，在 `r` 进制中有 `r` 位、`r^2` 位等。对于二进制、十进制和十六进制，`r` 分别为 `2`、`10`、`16`。

Let’s try this by hand. Recall that our preferred tool for writing large numbers is the IEC prefixing system.  
我们手算一些例子。回忆一下，我们表示大数时常使用 IEC 前缀系统。

| Prefix / 前缀 | Value / 值 |
| --- | --- |
| Ki (Kibi) | `2^10` |
| Mi (Mebi) | `2^20` |
| Gi (Gibi) | `2^30` |
| Ti (Tebi) | `2^40` |
| Pi (Pebi) | `2^50` |
| Ei (Exbi) | `2^60` |
| Zi (Zebi) | `2^70` |
| Yi (Yobi) | `2^80` |

### 2.1(a) Convert the following numbers from their initial radix into the other two common radices.

### 2.1(a) 将以下数从初始进制转换为另外两种常见进制。

| Initial / 初始 | Binary / 二进制 | Decimal / 十进制 | Hex / 十六进制 |
| --- | --- | --- | --- |
| `0b10010011` | `0b10010011` | `147` | `0x93` |
| `63` | `0b111111` | `63` | `0x3F` |
| `0b00100100` | `0b00100100` | `36` | `0x24` |
| `0` | `0b0` | `0` | `0x0` |
| `39` | `0b100111` | `39` | `0x27` |
| `437` | `0b110110101` | `437` | `0x1B5` |
| `0x0123` | `0b0000000100100011` | `291` | `0x0123` |

**Explanation / 解析：**

二进制转十进制时按位权相加，例如 `0b10010011 = 128 + 16 + 2 + 1 = 147`。十六进制和二进制互转时，每个十六进制数字正好对应 4 位二进制，例如 `0x93 = 1001 0011`。

### 2.1(b) Convert the following numbers from hex to binary.

### 2.1(b) 将以下数从十六进制转换为二进制。

| Hex / 十六进制 | Binary / 二进制 |
| --- | --- |
| `0xD3AD` | `0b1101001110101101` |
| `0xB33F` | `0b1011001100111111` |
| `0x7EC4` | `0b0111111011000100` |

**Explanation / 解析：**

逐个十六进制数字替换成 4 位二进制即可：`D = 1101`，`3 = 0011`，`A = 1010`，`D = 1101`，所以 `0xD3AD = 1101 0011 1010 1101`。

### 2.1(c) Write the following numbers using IEC prefixes.

### 2.1(c) 使用 IEC 前缀表示以下数。

| Number / 数 | IEC form / IEC 表示 |
| --- | --- |
| `2^16` | `64 Ki` |
| `2^34` | `16 Gi` |
| `2^27` | `128 Mi` |
| `2^61` | `2 Ei` |
| `2^43` | `8 Ti` |
| `2^47` | `128 Ti` |
| `2^36` | `64 Gi` |
| `2^59` | `512 Pi` |

**Explanation / 解析：**

选择最接近且不超过原指数的 IEC 前缀。例如 `2^34 = 2^4 * 2^30 = 16 Gi`，`2^59 = 2^9 * 2^50 = 512 Pi`。

### 2.1(d) Write the following numbers as powers of 2.

### 2.1(d) 将以下数写成 2 的幂。

| IEC form / IEC 表示 | Power of 2 / 2 的幂 |
| --- | --- |
| `2 Ki` | `2^11` |
| `256 Pi` | `2^58` |
| `512 Ki` | `2^19` |
| `64 Gi` | `2^36` |
| `16 Mi` | `2^24` |
| `128 Ei` | `2^67` |

**Explanation / 解析：**

把前面的系数也写成 2 的幂后相加指数。例如 `256 Pi = 2^8 * 2^50 = 2^58`。

## 3. Signed Integers / 有符号整数

Unsigned binary numbers work for natural numbers, but many calculations use negative numbers as well. To deal with this, a number of different schemes have been used to represent signed numbers, but we will focus on two’s complement, as it is the standard solution for representing signed integers.  
无符号二进制数适合表示自然数，但很多计算也需要负数。为此，人们使用过多种不同方案表示有符号数；这里重点关注补码，因为它是表示有符号整数的标准方案。

- Most significant bit has a negative value, all others are positive. So the value of an `n`-digit two’s complement number can be written as `sum from i=0 to n-2 of 2^i d_i - 2^(n-1)d_(n-1)`.  
  最高有效位具有负权重，其余位具有正权重。因此，一个 `n` 位补码数的值可写为 `sum from i=0 to n-2 of 2^i d_i - 2^(n-1)d_(n-1)`。
- Otherwise exactly the same as unsigned integers.  
  除此之外，它和无符号整数完全一样。
- A neat trick for flipping the sign of a two’s complement number: flip all the bits and add 1.  
  改变补码数符号的技巧：所有位取反，然后加 1。
- Addition is exactly the same as with an unsigned number.  
  加法和无符号数加法完全一样。
- Only one 0, and it’s located at `0b0`.  
  只有一个 0，表示为 `0b0`。

For questions (a) through (c), assume an 8-bit integer and answer each one for the case of an unsigned number, biased number with a bias of `-127`, and two’s complement number. Indicate if it cannot be answered with a specific representation.  
对于 (a) 到 (c)，假设为 8 位整数，并分别回答无符号数、偏置为 `-127` 的偏置表示数、补码数三种情况。如果某种表示无法回答，请说明。

### 3.1(a) What is the largest integer? What is the result of adding one to that number?

### 3.1(a) 最大整数是什么？给它加 1 的结果是什么？

| Representation / 表示 | Largest integer / 最大整数 | Add one / 加 1 结果 |
| --- | --- | --- |
| Unsigned / 无符号 | `255`, bits `11111111` | wraps to `0`, bits `00000000` |
| Biased, bias `-127` / 偏置 `-127` | `128`, bits `11111111` | cannot represent true result `129`; bit wrap gives `00000000`, interpreted as `-127` |
| Two’s Complement / 补码 | `127`, bits `01111111` | overflow; wraps to `-128`, bits `10000000` |

**Explanation / 解析：**

8 位无符号范围是 `0..255`。偏置 `-127` 的实际值为无符号编码值减 `127`，范围是 `-127..128`。8 位补码范围是 `-128..127`。加 1 超出可表示范围时，硬件仍按固定 8 位丢弃进位，产生环绕。

### 3.1(b) How would you represent the numbers `0`, `1`, and `-1`?

### 3.1(b) 如何表示 `0`、`1` 和 `-1`？

| Representation / 表示 | `0` | `1` | `-1` |
| --- | --- | --- | --- |
| Unsigned / 无符号 | `00000000` | `00000001` | cannot represent / 无法表示 |
| Biased, bias `-127` / 偏置 `-127` | `01111111` | `10000000` | `01111110` |
| Two’s Complement / 补码 | `00000000` | `00000001` | `11111111` |

**Explanation / 解析：**

偏置表示中实际值 = 编码值 `- 127`，所以编码值 = 实际值 `+ 127`。例如 `-1` 的编码值是 `126`，即 `01111110`。补码中 `-1` 是全 1。

### 3.1(c) How would you represent `17` and `-17`?

### 3.1(c) 如何表示 `17` 和 `-17`？

| Representation / 表示 | `17` | `-17` |
| --- | --- | --- |
| Unsigned / 无符号 | `00010001` | cannot represent / 无法表示 |
| Biased, bias `-127` / 偏置 `-127` | `10010000` | `01101110` |
| Two’s Complement / 补码 | `00010001` | `11101111` |

**Explanation / 解析：**

`17` 的二进制是 `00010001`。偏置表示中 `17 + 127 = 144 = 10010000`，`-17 + 127 = 110 = 01101110`。补码 `-17` 可由 `17` 取反加 1 得到：`00010001 -> 11101110 -> 11101111`。

### 3.1(d) What is the largest integer that can be represented by any encoding scheme that only uses 8 bits?

### 3.1(d) 任何只使用 8 位的编码方案能表示的最大整数是什么？

**Answer / 答案：**

If the encoding scheme is completely arbitrary, there is no finite maximum. If we restrict ourselves to the usual unsigned positional encoding, the largest is `255`.  
如果编码方案完全任意，则不存在有限最大值。如果限制为通常的无符号位权编码，最大值是 `255`。

**Explanation / 解析：**

8 位只能区分 `2^8 = 256` 种不同模式，但我们可以任意规定某个模式代表任意大的整数。因此“任意编码方案”的最大可表示整数没有上界。常规课程语境中若问 8 位无符号整数最大值，则为 `2^8 - 1 = 255`。

### 3.1(e) Prove that the two’s complement inversion trick is valid, i.e. that `x` and `~x + 1` sum to `0`.

### 3.1(e) 证明补码取反加一技巧有效，即 `x` 和 `~x + 1` 的和为 `0`。

**Answer / 答案：**

For an `n`-bit value, `x + ~x = 2^n - 1`, because every bit position sums to `1`. Therefore:  
对于一个 `n` 位值，`x + ~x = 2^n - 1`，因为每一位上二者相加都得到 `1`。因此：

```text
x + (~x + 1) = (x + ~x) + 1
             = (2^n - 1) + 1
             = 2^n
             = 0 modulo 2^n
```

**Explanation / 解析：**

固定 `n` 位机器整数只保留低 `n` 位，`2^n` 的低 `n` 位全为 0。因此 `~x + 1` 正是 `x` 的加法逆元，也就是 `-x` 的补码表示。

### 3.1(f) Explain where each of the three radices shines and why it is preferred over other bases in a given context.

### 3.1(f) 解释二进制、十进制、十六进制各自适合的场景，以及为什么在这些场景中优于其他进制。

**Answer / 答案：**

- Binary / 二进制：best for hardware, bit-level reasoning, masks, shifts, and flags.  
  最适合硬件、位级推理、掩码、移位和标志位。
- Decimal / 十进制：best for human-facing quantities, counting, money-like values, and everyday communication.  
  最适合面向人的数量、计数、类似货币的值和日常交流。
- Hexadecimal / 十六进制：best for compactly writing binary data, memory addresses, machine code, and bit patterns.  
  最适合紧凑表示二进制数据、内存地址、机器码和位模式。

**Explanation / 解析：**

二进制直接对应硬件中的比特，但长数字难读。十进制符合人类习惯，但和二进制转换不如十六进制方便。十六进制每位对应 4 个二进制位，既紧凑又容易和比特模式互转。

## 4. Arithmetic and Counting / 算术与计数

### 4.1 Binary and hex arithmetic / 二进制与十六进制算术

Addition and subtraction of binary/hex numbers can be done in a similar fashion as with decimal digits by working right to left and carrying over extra digits to the next place. However, sometimes this may result in an overflow if the number of bits can no longer represent the true sum. Overflow occurs if and only if two numbers with the same sign are added and the result has the opposite sign.  
二进制和十六进制的加减法可以像十进制一样从右往左逐位计算，并把多出的位进位到下一位。不过，如果位数已经无法表示真实结果，就可能溢出。溢出当且仅当两个同号数相加却得到异号结果时发生。

### 4.1(a) Compute the decimal result of the following arithmetic expressions involving 6-bit Two’s Complement numbers as they would be calculated on a computer. Do any of these result in an overflow? Are all these operations possible?

### 4.1(a) 对以下涉及 6 位补码数的算术表达式，按计算机中的方式计算十进制结果。是否发生溢出？这些操作都可能吗？

6-bit two’s complement range is `-32..31`.  
6 位补码范围是 `-32..31`。

| Expression / 表达式 | Operand values / 操作数值 | Result / 结果 | Overflow? / 溢出？ | Notes / 说明 |
| --- | --- | --- | --- | --- |
| `0b011001 - 0b000111` | `25 - 7` | `18` (`0b010010`) | No / 否 | exact / 可精确表示 |
| `0b100011 + 0b111010` | `-29 + -6` | true result `-35`, wraps to `29` (`0b011101`) | Yes / 是 | negative + negative gave positive / 负数加负数得到正数 |
| `0x3B + 0x06` | `0b111011 + 0b000110 = -5 + 6` | `1` (`0b000001`) | No / 否 | using low 6 bits / 按低 6 位解释 |
| `0xFF - 0xAA` | low 6 bits: `0b111111 - 0b101010 = -1 - (-22)` | `21` (`0b010101`) | No / 否 | as written these hex literals are more than 6 bits; strict 6-bit operands would not fit / 原十六进制字面量超过 6 位，严格作为 6 位操作数并不适合 |

**Explanation / 解析：**

6 位补码最高位权重为 `-32`。例如 `0b100011 = -32 + 2 + 1 = -29`，`0b111010 = -32 + 16 + 8 + 2 = -6`。二者真实和为 `-35`，小于 6 位补码最小值 `-32`，因此溢出；硬件保留低 6 位，得到 `011101`，即 `29`。

对于十六进制写法，`0x3B` 可视为比特模式 `111011`，正好 6 位；`0xFF` 和 `0xAA` 是 8 位模式，如果题目严格要求所有操作数必须是 6 位，则它们不能直接作为 6 位补码数。若按机器截断低 6 位来算，则得到表中结果。

### 4.1(b) What is the least number of bits needed to represent the following ranges using any number representation scheme?

### 4.1(b) 使用任意数字表示方案表示以下范围所需的最少位数是多少？

| Range / 范围 | Number of values / 值的个数 | Minimum bits / 最少位数 |
| --- | --- | --- |
| `0` to `256` | `257` | `9` |
| `-7` to `56` | `64` | `6` |
| `64` to `127` and `-64` to `-127` | `128` | `7` |
| Address every byte of a `12 TiB` chunk of memory / 给 `12 TiB` 内存块的每个字节编址 | `12 * 2^40 = 3 * 2^42` | `44` |

**Explanation / 解析：**

如果只要求用某种编码区分 `N` 个不同值，最少需要 `ceil(log2 N)` 位。

`0..256` 是包含两端的 `257` 个值，`2^8 = 256` 不够，`2^9 = 512` 足够，所以需要 9 位。`-7..56` 有 `56 - (-7) + 1 = 64` 个值，需要 6 位。`64..127` 有 64 个值，`-127..-64` 也有 64 个值，共 128 个，需要 7 位。`12 TiB = 12 * 2^40 = 3 * 2^42` 字节，`2^43 = 8 TiB` 不够，`2^44 = 16 TiB` 足够，所以需要 44 位地址。
