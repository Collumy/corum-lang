# Corum Programming Language

<p align="center">
  <b>Modern, expressive, high-performance systems programming language.</b><br>
  Combines the syntax elegance of <b>Kotlin</b> with the raw speed and deterministic control of <b>C</b> and <b>Rust</b>.
</p>

---

## ⚡ Key Highlights

- **Kotlin-like Syntax & Ergonomics**: Clean expressions, trailing lambdas, data classes, smart casts, null-safety (`?`, `?.`, `?:`, `!!`), pattern matching (`when`), and scope functions (`let`, `run`, `apply`, `also`, `with`).
- **Deterministic ARC Memory Model**: Fast, predictable Automatic Reference Counting with automatic `deinit { }` destructors — no stop-the-world garbage collection pauses.
- **Resource Safety**: Safe resource scoping with `with (res) { ... }` bound to `operator fun close()`.
- **First-Class Data Classes**: Automatic generation of `copy()`, `equals (==)`, `hashCode()`, `toString()`, and destructuring `componentN()` operators.
- **Rich Operator Overloading**: Overload `+`, `-`, `*`, `/`, `%`, `==`, `[]`, `slice`, `invoke()`, `in`, `!`, `~`, `iterator()`.
- **Iterators & Generators**: Native `yield` statement for elegant stream and collection generation in `for` loops.
- **Clean Infix Bitwise Math**: High-level `and`, `or`, `xor`, `shl`, `shr`, `inv` lowered directly to native LLVM CPU instructions.
- **Zero-Cost Systems Programming**: Explicit raw pointers (`&T`, `&mut T`), pointer dereferencing (`$ptr`), manual `alloc`/`free`, and high-speed `Arena` allocators in `unsafe { }` blocks.
- **Full Standard Library**: Fast $O(1)$ `HashMap` & `HashSet`, dynamic `ArrayList`, collection factories (`listOf`, `setOf`, `mapOf`), string slicing, text utilities, and directory walking.
- **Integrated Tooling**: Project initialization (`corum init`, `corum new`), instant checking (`corum check`), building (`corum build`), running (`corum run`), and testing (`corum test`).

---

## 🚀 Quick Start

### 1. Requirements
- **JDK 17+** (JDK 21 or 25 recommended)
- **Clang / LLVM** (14.0+) in `PATH` or `D:\apps\llvm\bin`

### 2. Global Installation
The project provides global CLI wrappers in `bin/`:
```powershell
# Add D:\projects\corum\bin to your Windows User PATH (done automatically or run):
[Environment]::SetEnvironmentVariable('Path', 'D:\projects\corum\bin;' + [Environment]::GetEnvironmentVariable('Path', 'User'), 'User')
```

### 3. Creating & Running a Project
```bash
# Create a new application
corum init my_project
cd my_project

# Instant syntax and type check (takes ~15ms)
corum check

# Compile and run
corum run
```

---

## 📖 Quick Language Tour

```corum
import corum.collections.*
import corum.text.*
import corum.math.*

// 1. Data classes with auto-generated operators
data class User(val id: Int64, val name: String, var age: Int32)

// 2. Resource management with operator fun close()
class Connection(val url: String) {
    operator fun close() {
        println("Connection closed.")
    }
}

// 3. Generators with yield
fun rangeEven(max: Int32): ArrayList<Int32> {
    var i = 0
    while (i <= max) {
        if (i % 2 == 0) yield i
        i++
    }
}

fun main() {
    // Collections & for-each
    val users = listOf(
        User(1, "Alice", 25),
        User(2, "Bob", 30)
    )

    for (u in users) {
        // Destructuring & string interpolation
        val (id, name, age) = u
        println("User #$id: $name is $age years old")
    }

    // Infix bitwise operations
    val flags = 0b1100 and 0b1010 // 0b1000 (8)
    val shifted = 1 shl 4         // 16

    // Scope functions
    val alice = User(1, "Alice", 25).apply {
        this.age = 26
    }

    // with statement
    with (conn = Connection("localhost:5432")) {
        println("Working with database...")
    }

    // Yield generator
    for (num in rangeEven(6)) {
        print("$num ") // 0 2 4 6
    }
    println()
}
```

---

## 📚 Complete Documentation

For the full specification and comprehensive language guide, read:
👉 **[Language Reference Guide (docs/LANGUAGE_GUIDE.md)](docs/LANGUAGE_GUIDE.md)**

It covers:
- Complete Type System & Null Safety (`?`, `?:`, `!!`, `?.`)
- Full Object Model (`class`, `data class`, `object`, `interface`, `struct`, `init`, `deinit`)
- Slices, Ranges (`..`, `until`), and Custom Iterators
- Memory Management & ARC internals
- Unsafe Programming, Pointers, and `Arena`
- Standard Library Reference (`corum.collections`, `corum.math`, `corum.text`, `corum.io`)
- Project Manifest (`corum.toml`) & Build System

---

## 🛠️ CLI Commands Reference

| Command | Description |
|---|---|
| `corum init [name]` | Initialize a new Corum project in the current or named directory |
| `corum new <name>` | Create a new project directory with `corum.toml` and `src/main.cr` |
| `corum check [file]` | Fast syntax & semantic validation without compiling (~15ms) |
| `corum build [file]` | Compile source file or project to native executable (`.exe`) |
| `corum run [file]` | Compile and immediately execute |
| `corum test [file]` | Run embedded unit test suite |
| `corum --emit-llvm` | Emit human-readable LLVM IR (`.ll`) |

---

## 📄 License
MIT License. Developed with ❤️ by the Corum team.
