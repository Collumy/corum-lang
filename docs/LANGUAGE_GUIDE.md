# Corum Language Reference Guide

Corum is a modern, statically typed compiled systems programming language designed to unite the ergonomic beauty and expressiveness of **Kotlin** with the raw execution speed, deterministic memory model, and low-level control of **C** and **Rust**.

Corum compiles natively to machine code using **LLVM**, features **Automatic Reference Counting (ARC)** with deterministic destructors, and provides zero-cost abstractions for systems programming.

---

## Table of Contents

1. [Program Structure & Entry Point](#1-program-structure--entry-point)
2. [Variables & Types](#2-variables--types)
   - [Basic Types](#basic-types)
   - [Type Inference & Suffixes](#type-inference--suffixes)
   - [Null Safety (`T?`, `?.`, `?:`, `!!`)](#null-safety)
   - [Tuples & Destructuring](#tuples--destructuring)
3. [Control Flow](#3-control-flow)
   - [`if` as an Expression](#if-as-an-expression)
   - [`when` Pattern Matching](#when-pattern-matching)
   - [`while` Loop](#while-loop)
   - [`for (item in collection)`](#for-item-in-collection)
   - [`yield` & Generator Functions](#yield--generator-functions)
4. [Functions & Methods](#4-functions--methods)
   - [Function Declarations](#function-declarations)
   - [Default & Named Arguments](#default--named-arguments)
   - [Extension Functions](#extension-functions)
   - [Operator Overloading (`operator fun`)](#operator-overloading)
   - [Lambdas & Trailing Lambda Syntax](#lambdas--trailing-lambda-syntax)
5. [Scope Functions (`let`, `run`, `apply`, `also`, `with`)](#5-scope-functions)
6. [Classes & Object-Oriented Programming](#6-classes--object-oriented-programming)
   - [Classes & Constructors](#classes--constructors)
   - [`init { }` Blocks](#init--blocks)
   - [`deinit { }` Destructors](#deinit--destructors)
   - [`data class` & Generated Operators](#data-class)
   - [`object` (Singletons)](#object-singletons)
   - [`interface` & Default Methods](#interfaces)
   - [`struct` (Value Types)](#structs)
   - [`enum` (Enumerations)](#enums)
7. [Resource Management & Memory Model](#7-resource-management--memory-model)
   - [Automatic Reference Counting (ARC)](#automatic-reference-counting-arc)
   - [The `with` Statement & `operator fun close()`](#the-with-statement)
8. [Low-Level & Unsafe Programming](#8-low-level--unsafe-programming)
   - [`unsafe { }` Blocks](#unsafe-blocks)
   - [Raw Pointers (`&`, `&mut`, `$`)](#raw-pointers)
   - [Dynamic Allocation (`alloc`, `free`)](#dynamic-allocation)
   - [Arena Allocator](#arena-allocator)
9. [Bitwise Operations (`corum.math`)](#9-bitwise-operations)
10. [Collections & Standard Library](#10-collections--standard-library)
    - [`listOf`, `setOf`, `mapOf`](#collection-factories)
    - [`ArrayList<T>`](#arraylist)
    - [`HashMap<K, V>` ($O(1)$) & `HashSet<T>`](#hashmap--hashset)
    - [Slices (`a[start..end]`, `a[start until end]`)](#slices)
    - [Text & Characters (`corum.text`)](#text-utilities)
    - [File I/O (`corum.io`)](#file-io)
11. [CLI Tooling & Project Management](#11-cli-tooling--project-management)

---

## 1. Program Structure & Entry Point

Every executable Corum program begins with the top-level `fun main()` function.

```corum
// src/main.cr
import corum.collections.*
import corum.text.*
import corum.math.*

fun main() {
    println("Hello, Corum!")
}
```

Modules and imports:
- `module my.package.name` declares the package namespace.
- `import corum.collections.*` imports all symbols from a module.
- `import ./utils` or `import ../math/vector` imports local files relative to the current file.

---

## 2. Variables & Types

### Basic Types

Corum has strict static typing with type inference:

| Type | Description | Example |
|---|---|---|
| `Int8`, `Int16`, `Int32`, `Int64` | Signed integers | `val a: Int32 = 42` |
| `UInt8`, `UInt16`, `UInt32`, `UInt64` | Unsigned integers | `val b: UInt64 = 100UL` |
| `Float32`, `Float64` | IEEE 754 floating point numbers | `val pi: Float64 = 3.14159` |
| `Bool` | Boolean truth values | `val flag: Bool = true` |
| `Char` | 8-bit character | `val c: Char = 'Z'` |
| `String` | UTF-8 string with ARC | `val s: String = "Hello"` |
| `Void` | Unit / return type for side-effects | `fun log(): Void` |

### Type Inference & Suffixes

```corum
// Immutable variable (cannot be reassigned)
val x = 100               // Inferred as Int32
val big = 10000000000L    // Inferred as Int64
val rate = 2.5            // Inferred as Float64

// Mutable variable
var counter = 0
counter++
counter += 5

// Number formats
val hex = 0xDEAD_BEEF
val bin = 0b1011_0010
```

### Null Safety

Types in Corum are **non-nullable by default**. To allow `null`, append `?`:

```corum
var name: String = "Alice"     // Never null
var nickname: String? = null    // May be null

// Safe call: evaluates to null if receiver is null
val len = nickname?.len

// Elvis operator: fallback if null
val display = nickname ?: "Anonymous"

// Not-null assertion: throws runtime panic if null
val forced = nickname!!
```

### Tuples & Destructuring

```corum
val pair: (String, Int32) = ("Age", 30)
val (key, value) = pair
println("$key: $value")
```

---

## 3. Control Flow

### `if` as an Expression

In Corum, `if` can be used both as a statement and as an expression:

```corum
val max = if (a > b) a else b

val status = if (score >= 90) {
    "Excellent"
} else if (score >= 60) {
    "Passed"
} else {
    "Failed"
}
```

### `when` Pattern Matching

The `when` construct replaces `switch` with powerful pattern matching:

```corum
when (code) {
    200 -> println("OK")
    404 -> println("Not Found")
    500 -> println("Internal Server Error")
    else -> println("Unknown code: $code")
}

// Matching on type (is / !is):
when (obj) {
    is String -> println("Length: ${obj.len}")
    is Int32 -> println("Number: $obj")
    else -> println("Other")
}
```

### `while` Loop

```corum
var i = 0
while (i < 5) {
    println("Index: $i")
    i++
}
```

### `for (item in collection)`

Iterate over any collection implementing the iterator protocol:

```corum
val list = listOf(10, 20, 30)
for (item in list) {
    println("Item: $item")
}

val set = setOf("alpha", "beta")
for (name in set) {
    println("Found: $name")
}
```

### `yield` & Generator Functions

Corum supports lightweight generator functions using `yield`:

```corum
fun generateEvens(max: Int32): ArrayList<Int32> {
    var i = 0
    while (i <= max) {
        if (i % 2 == 0) {
            yield i
        }
        i++
    }
}

val evens = generateEvens(10)
for (e in evens) {
    println(e) // 0, 2, 4, 6, 8, 10
}
```

---

## 4. Functions & Methods

### Function Declarations

```corum
// Block body
fun add(a: Int32, b: Int32): Int32 {
    return a + b
}

// Expression body
fun multiply(a: Int32, b: Int32): Int32 = a * b
```

### Default & Named Arguments

```corum
fun greet(name: String, prefix: String = "Hello", count: Int32 = 1) {
    var i = 0
    while (i < count) {
        println("$prefix, $name!")
        i++
    }
}

// Calling with positional arguments:
greet("Bob")

// Calling with named arguments:
greet(name = "Alice", count = 3, prefix = "Welcome")
```

### Extension Functions

You can extend existing classes and primitive types without inheritance:

```corum
fun String.shout(): String {
    return this + "!!!"
}

fun Int32.squared(): Int32 {
    return this * this
}

println("hello".shout()) // hello!!!
println(5.squared())     // 25
```

### Operator Overloading

Methods marked with `operator fun` overload standard syntax:

```corum
class Vector2(val x: Int32, val y: Int32) {
    operator fun plus(other: Vector2): Vector2 {
        return Vector2(this.x + other.x, this.y + other.y)
    }

    operator fun get(index: Int32): Int32 {
        if (index == 0) return this.x
        return this.y
    }
}

val v1 = Vector2(1, 2)
val v2 = Vector2(10, 20)
val v3 = v1 + v2 // calls plus()
println(v3[0])   // calls get(0)
```

Supported operators:
- Binary: `plus (+)` , `minus (-)`, `times (*)`, `div (/)`, `rem (%)`, `equals (==)`
- Indexing: `get ([])`, `set ([] =)`
- Slicing: `slice(start, end)`
- Invocations: `invoke()`
- Comparison: `compareTo (<, <=, >, >=)`
- Bitwise / unary: `not (!)`, `unaryMinus (-)`, `inv (~)`
- Iteration: `iterator()`

### Lambdas & Trailing Lambda Syntax

```corum
val double = { x: Int32 -> x * 2 }
println(double(5)) // 10

// Trailing lambda outside parentheses:
val filtered = list.filter { it > 10 }
```

---

## 5. Scope Functions

Corum includes standard Kotlin-style scope functions for clean object transformations:

| Function | Context Object | Return Value | Purpose |
|---|---|---|---|
| `let` | `it` (argument) | Lambda result | Null-checks and mapping expressions |
| `run` | `this` | Lambda result | Object configuration and computation |
| `apply` | `this` | Context object | Initializing and mutating object properties |
| `also` | `it` (argument) | Context object | Side effects (logging, debugging) |
| `with` | `this` | Lambda result | Grouping multiple calls on an object |

```corum
// let
nickname?.let {
    println("Found nickname: $it")
}

// apply
val person = Person("Alice", 25).apply {
    this.age = 26
}

// also
val p2 = person.also {
    println("Logged: ${it.name}")
}

// with
with (person) {
    println("Name: ${this.name}, Age: ${this.age}")
}
```

---

## 6. Classes & Object-Oriented Programming

### Classes & Constructors

```corum
class User(val id: Int64, var name: String, var email: String = "") {
    val isVerified: Bool get() = this.email.isNotEmpty()
}
```

### `init { }` Blocks

`init { }` blocks run immediately after field initialization during construction:

```corum
class DatabaseConnection(val host: String, val port: Int32) {
    var isConnected: Bool = false

    init {
        println("Connecting to ${this.host}:${this.port}...")
        this.isConnected = true
    }
}
```

### `deinit { }` Destructors

`deinit { }` runs automatically when the object's ARC reference count drops to zero:

```corum
class FileHandle(val path: String) {
    init {
        println("Opened $path")
    }

    deinit {
        println("Closed $path")
    }
}
```

### `data class`

Declaring a `data class` automatically synthesizes:
1. `operator fun equals(other: T): Bool` (`==` / `!=`)
2. `operator fun hashCode(): Int64` (DJB2 property hash combination)
3. `operator fun toString(): String` (e.g. `Person(name=Alice, age=25)`)
4. `operator fun component1()`, `component2()`... (for destructuring)
5. `fun copy(...)` (with default parameter values)

```corum
data class Person(val name: String, val age: Int32)

val p1 = Person("Alice", 25)
val p2 = Person("Alice", 25)
val p3 = p1.copy(age = 26)

println(p1 == p2) // true
println(p1.toString()) // Person(name=Alice, age=25)

// Destructuring:
val (name, age) = p1
println("$name is $age")
```

### `object` (Singletons)

```corum
object AppConfig {
    val version: String = "1.0.0"
    fun info(): String = "Corum App v$version"
}

println(AppConfig.info())
```

### `interface` & Default Methods

```corum
interface Printable {
    fun printContent()
    fun defaultHeader(): String = "=== Document ==="
}

class Document(val text: String) : Printable {
    override fun printContent() {
        println(this.text)
    }
}
```

### `struct` (Value Types)

`struct` types are stored inline on the stack without heap allocation or reference counting:

```corum
struct Point2D {
    val x: Float32
    val y: Float32
}
```

---

## 7. Resource Management & Memory Model

### Automatic Reference Counting (ARC)

Corum manages class instances on the heap using compiler-emitted **Automatic Reference Counting (ARC)**:
- When a reference is copied, the refcount increments (`retain`).
- When a reference goes out of scope, the refcount decrements (`release`).
- When the refcount reaches zero, `deinit { }` executes and the object's memory is freed immediately without pause.

### The `with` Statement

For deterministic, scope-bounded resource cleanup (similar to Kotlin's `use` or Python's `with`), Corum provides `with`:

Any class defining `operator fun close()` can be managed via `with`:

```corum
class Resource {
    fun doWork() {
        println("Working...")
    }

    operator fun close() {
        println("Resource released!")
    }
}

fun main() {
    // Parentheses around resource are optional:
    with (res = Resource()) {
        res.doWork()
    }
    // res.close() is guaranteed to be called here upon exit!
}
```

---

## 8. Low-Level & Unsafe Programming

### `unsafe { }` Blocks

Low-level operations require explicit `unsafe` blocks:

```corum
unsafe {
    // Direct pointer arithmetic and dereferencing
}
```

### Raw Pointers

- `&x`: immutable pointer to `x`
- `&mut x`: mutable pointer to `x`
- `$ptr`: dereference pointer (read or write)

```corum
var value = 42
unsafe {
    val ptr: &mut Int32 = &mut value
    $ptr = 100
}
println(value) // 100
```

### Dynamic Allocation

```corum
unsafe {
    val buffer: &mut Int32 = alloc<Int32>(10) // Allocates 10 Int32 elements
    buffer[0] = 123
    free(buffer)
}
```

### Arena Allocator

Corum includes a high-performance region-based `Arena` in `corum.memory`:

```corum
import corum.memory.*

val arena = Arena(1024 * 64) // 64 KB memory block
unsafe {
    val ptr = arena.alloc<Point>(5)
    // Fast batch memory release:
    arena.free()
}
```

---

## 9. Bitwise Operations (`corum.math`)

In Corum, bitwise operators are clean, type-safe infix functions instead of confusing symbol operators:

```corum
import corum.math.*

val a = 0b1100
val b = 0b1010

val bitAnd = a and b      // 0b1000 (8)
val bitOr  = a or b       // 0b1110 (14)
val bitXor = a xor b      // 0b0110 (6)
val shlVal = 1 shl 4      // 16
val shrVal = 32 shr 2     // 8
val invVal = 0.inv()      // -1
```

> **Performance Note**: The compiler lowers these calls directly into native LLVM CPU instructions (`and`, `or`, `xor`, `shl`, `ashr`, `xor -1`), resulting in zero runtime function overhead.

---

## 10. Collections & Standard Library

### Collection Factories

```corum
import corum.collections.*

val list = listOf(1, 2, 3)
val set  = setOf("a", "b", "c")
val map  = mapOf(
    "key1" to 100,
    "key2" to 200
)
```

### `ArrayList<T>`

Dynamic resizable array:

```corum
val list = ArrayList<String>()
list.add("Apple")
list.add("Banana")
println(list.size)     // 2
println(list[0])        // Apple
list.removeAt(0)
```

### `HashMap<K, V>` & `HashSet<T>`

True $O(1)$ hash table with collision buckets using `key.hashCode()`:

```corum
val map = HashMap<String, Int32>()
map.put("apple", 10)
map.put("banana", 20)

println(map.containsKey("apple")) // true
println(map["banana"] ?: 0)        // 20

map.remove("apple")
```

### Slices

Slicing on strings, lists, and arrays using ranges (`..` or `until`):

```corum
val text = "Hello, World!"
val sub = text[0..4]      // "Hello"
val sub2 = text[0 until 5] // "Hello"

val list = listOf(10, 20, 30, 40)
val slice = list[1..2]    // [20, 30]
```

### Text Utilities

Character inspection:

```corum
import corum.text.*

val ch = '9'
ch.isDigit()         // true
ch.isLetter()        // false
ch.isLetterOrDigit() // true
ch.isWhitespace()    // false
ch.isHexDigit()      // true
ch.toUpper()         // '9'
```

### File I/O

```corum
import corum.io.*

// Reading and writing
File.writeAllText("output.txt", "Hello, Corum!")
val content = File.readAllText("output.txt")

// Walking directory tree:
val files = Directory.walkFiles("src")
for (f in files) {
    println("Source file: $f")
}
```

---

## 11. CLI Tooling & Project Management

Corum provides a complete command-line toolkit:

```bash
# Create a new application project
corum init my_app
corum new my_app

# Quick syntax & semantic check (instant, no build)
corum check

# Compile and link executable
corum build
corum build -o my_binary.exe

# Compile and immediately run
corum run

# Run unit tests
corum test
```

### `corum.toml` Project Manifest

```toml
[package]
name = "my_app"
version = "0.1.0"
authors = ["Your Name"]
type = "bin"
entry = "src/main.cr"

[dependencies]
# Local or Git dependencies:
# http = { git = "https://github.com/corum-lang/http", tag = "v1.0.0" }
# utils = { path = "../shared/utils" }
```
