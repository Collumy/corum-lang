# Corum Programming Language

**Corum** is a modern, high-performance, statically typed, compiled systems programming language designed to combine the expressive power and clean syntax of **Kotlin** with the zero-cost abstractions, raw performance, and low-level control of **Rust** and **C++**.

Corum compiles directly to machine code via **LLVM**, providing native execution speeds, predictable memory layout, and full hardware utilization.

---

## Key Highlights

- **Kotlin-like Syntax & Ergonomics**: Clean expressions, trailing lambdas, data classes, smart casts, null-safety, and pattern matching with `when`.
- **Zero-Cost Systems Programming**: Explicit pointers (`&T`, `&mut T`), inline assembly (`asm { ... }`), raw memory manipulation (`unsafe { ... }`), and static memory layouts.
- **LLVM Backend**: Generates optimized native binaries with standard platform ABI integration.
- **Modern Object Model**: Single inheritance, sealed classes, interfaces with default methods, and singletons (`object`).
- **Memory Safety & RAII**: Scope-based resource management with automatic destructors (`drop()`) and deterministic deferred execution (`defer`).
- **Rich Operator Overloading & Extension Functions**: Overload operators (`+`, `-`, `*`, `[]`, `set`, `in`, `invoke()`, `!`, `~`, `++`, `--`) directly or via extension methods on third-party types and literals.
- **Modular Package Ecosystem (`corum.toml`)**: Clean dependency management, scoped package naming (`author.lib`), and instant project bootstrapping (`corum init`).

---

## Table of Contents

1. [Installation & Requirements](#installation--requirements)
2. [CLI & Project Tooling](#cli--project-tooling)
3. [Language Tour & Syntax](#language-tour--syntax)
   - [Variables & Basic Types](#variables--basic-types)
   - [Functions & Extension Functions](#functions--extension-functions)
   - [Control Flow (`if`, `when`, `for`, `while`)](#control-flow)
   - [Null Safety](#null-safety)
   - [Classes, Data Classes & Sealed Classes](#classes-data-classes--sealed-classes)
   - [Interfaces with Default Methods](#interfaces-with-default-methods)
   - [Enum Classes](#enum-classes)
   - [Tuples & Destructuring](#tuples--destructuring)
   - [Operator Overloading](#operator-overloading)
   - [Resource Management (RAII & `defer`)](#resource-management-raii--defer)
   - [Low-Level & Unsafe Programming](#low-level--unsafe-programming)
4. [Package Management (`corum.toml`)](#package-management-corumtoml)

---

## Installation & Requirements

### Prerequisites
- **JDK 17+** (JDK 21 or 25 recommended)
- **Clang / LLVM** (14.0+) in `PATH` or in `D:\apps\llvm\bin`

### Building the Compiler
```bash
git clone https://github.com/collumy/corum.git
cd corum/corumc
./gradlew installDist
```

The compiler launcher `corum.bat` (or `corum` on Unix) will be available in the project root.

---

## CLI & Project Tooling

Corum supports two operational modes:
1. **Single File Script Mode** (fast prototyping with local imports):
   ```bash
   corum main.cr
   ```
2. **Modular Project Mode** (managed dependencies via `corum.toml`):
   ```bash
   corum init my.awesome.app        # Create a new application
   corum init collumy.net.http --lib # Create a new reusable library
   corum build                      # Build binary from manifest
   corum run                        # Build and immediately execute
   ```

---

## Language Tour & Syntax

### Variables & Basic Types

Corum has strict static typing with type inference:

```corum
// Immutable variable
val x = 42

// Mutable variable
var counter = 0
counter++
counter += 10

// Primitive types:
// Integers: Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64
// Floating point: Float32, Float64
// Text: Str (string slice/literal), String (managed)
// Booleans: Bool (true / false)
val pi: Float64 = 3.1415926535
val message: Str = "Hello, Corum!"
```

### Functions & Extension Functions

Functions are defined with `fun`. Both block bodies and expression bodies are supported:

```corum
fun add(a: Int32, b: Int32): Int32 {
    a + b
}

// Single-expression function
fun square(x: Int32) = x * x

// Extension functions: extend any existing type or literal
fun Float64.doubleMe(): Float64 = this * 2.0

val f = 2.5.doubleMe() // 5.0
```

### Control Flow

#### `if` Expression
```corum
val max = if (a > b) a else b
```

#### `when` Expression (Pattern Matching & Smart Casts)
`when` replaces traditional `switch` and supports arbitrary conditions, type checks, and sealed class matching:

```corum
when (val) {
    0 -> println("Zero")
    1, 2 -> println("One or two")
    is Int32 -> println("Type is Int32")
    else -> println("Other")
}
```

#### Loops
```corum
// Range loops: exclusive (until) and inclusive (..)
for (i in 0 until 5) {
    println("i = ", i)
}

// For-each loop over arrays, spans, and collections
val numbers = [10, 20, 30]
for (n in numbers) {
    println("n = ", n)
}

while (condition) {
    doWork()
}
```

### Null Safety

Like Kotlin, types are non-nullable by default. Append `?` to permit `null`:

```corum
val nonNull: Str = "Safe"
// nonNull = null // Compile Error!

val nullable: Str? = null

// Safe call (?.)
val len = nullable?.length

// Elvis operator (?:)
val result = nullable ?: "Default Value"

// Not-null assertion (!!)
val forced = nullable!!
```

### Classes, Data Classes & Sealed Classes

#### Standard Class
```corum
class Person(val name: Str, var age: Int32) {
    fun greet() {
        println("Hello, I am ", this.name)
    }
}
```

#### Data Classes
Data classes automatically synthesize `copy()` and `component1()`, `component2()`... for destructuring:

```corum
data class User(val id: Int32, val username: Str)

val u = User(1, "alice")
val (id, name) = u // Destructuring declaration
```

#### Sealed Classes (Algebraic Data Types)
```corum
sealed class Result
class Success(val value: Int32) : Result()
class Error(val message: Str) : Result()

fun handle(r: Result) {
    when (r) {
        is Success -> println("Success: ", r.value)
        is Error -> println("Error: ", r.message)
    }
}
```

### Interfaces with Default Methods

Interfaces support optional default implementations:

```corum
interface Printable {
    fun printSelf() {
        println("Default printable output")
    }
}

class Document : Printable {
    // printSelf() is automatically inherited
}
```

### Enum Classes

Corum enums compile down to a zero-overhead `i32` ordinal representation with static lookup tables for properties:

```corum
enum class Color(val hex: Int32) {
    RED(0xFF0000),
    GREEN(0x00FF00),
    BLUE(0x0000FF)
}

val c = Color.RED
println(c.name)    // "RED"
println(c.ordinal) // 0
println(c.hex)     // 16711680
```

### Tuples & Destructuring

Return multiple values without declaring dedicated classes:

```corum
fun getStats(): (Int32, Str, Bool) {
    (200, "OK", true)
}

val (code, status, ok) = getStats()
```

### Operator Overloading

Operators can be overloaded inside classes or via **extension functions**:

| Operator | Function Name | Usage Example |
|---|---|---|
| `+`, `-`, `*`, `/`, `%` | `plus`, `minus`, `times`, `div`, `rem` | `a + b` |
| `a[i]` | `get(index: I)` | `val x = arr[i]` |
| `a[i] = v` | `set(index: I, value: V)` | `arr[i] = 100` |
| `x in coll` | `contains(x: T)` | `if (10 in list)` |
| `obj(args...)` | `invoke(args...)` | `"CompileTarget"(999)` |
| `!a`, `~a`, `-a` | `not`, `inv`, `unaryMinus` | `!flag`, `~mask` |
| `++a`, `--a` | `prefix / postfix increment` | `count++` |

```corum
operator fun Str.invoke(code: Int32) {
    println("Invoked on '", this, "' with code: ", code)
}

"Command"(42) // Works directly on literals!
```

### Resource Management (RAII & `defer`)

#### Automatic Scope-Based Destructors (RAII)
Declare a `drop()` method in any class. Corum automatically injects destructor calls at the end of the enclosing scope:

```corum
class FileHandle(val path: Str) {
    fun drop() {
        println("Closing file handle for: ", this.path)
    }
}

fun process() {
    val file = FileHandle("test.txt")
    // Destructor FileHandle_drop(file) is guaranteed to run when exiting process()
}
```

#### `defer` Statement
Guarantees execution of a cleanup statement at scope exit (LIFO order):

```corum
val ptr = alloc<Int32>(100)
defer free(ptr)
```

### Low-Level & Unsafe Programming

```corum
val x: Int32 = 10
val p: &Int32 = &x         // Reference
val mutP: &mut Int32 = &mut x // Mutable reference
val value = $p             // Dereference

unsafe {
    // Direct pointer arithmetic and raw memory access
}

asm {
    "nop"
}
```

---

## Package Management (`corum.toml`)

Corum uses a project manifest for dependencies and build configuration.

### Sample `corum.toml`
```toml
[package]
name = "my.company.server"
version = "1.0.0"
authors = ["Alice <alice@example.com>"]
type = "bin"
entry = "src/main.cr"

[dependencies]
# Dependencies from Git (cached globally in ~/.corum/pkg)
http = { git = "https://github.com/corum-lang/http", tag = "v1.2.0", package = "corum.net.http" }

# Local path dependencies
math = { path = "../shared/math", package = "my.company.math" }
```

### Using Dependencies in Code
```corum
module my.company.server

import http.Client
import my.company.math.Matrix

fun main(args: Array<String>) {
    println("Server ready!")
}
```

---

## License

Corum is licensed under the [MIT License](LICENSE).
