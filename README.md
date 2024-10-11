# C# CLI Debugging Tutorial

This repository provides a command-line interface (CLI) version of [Mosh Hamadani's C# debugging tutorial](https://youtu.be/u-HdLtqEOog?si=pezMgFbl9cQyPIkw), originally demonstrated using Visual Studio's GUI. Here, we use `mdbg.exe` and other CLI tools to debug C# code.

## Prerequisites

- Windows operating system
- .NET Framework (comes pre-installed on most Windows systems)
- Chocolatey or winget (for installing NuGet)
- NuGet (for installing Mdbg)

## Setup

1. Install NuGet using Chocolatey:

   ```
   choco install nuget.commandline
   ```

   Or using winget:

   ```
   winget install Microsoft.NuGet
   ```

2. `cd` into your directory of choice and install Mdbg using NuGet:

   ```
   nuget install Mdbg
   ```

3. Add Mdbg to your system PATH:
   ```
   set "PATH=%PATH%;C:\path\to\Mdbg\tools"
   ```
   Replace `C:\path\to\Mdbg\tools` with the actual path where Mdbg was installed.

## Compiling the C# Code

A cmd batch file (`compile.bat`) is provided that allows you to compile the C# code using different methods. The syntax is:

```
compile.bat <debug/release> <vs2019/windows/dotnet> <csc/msbuild/devenv/dotnet> [clean] [run]
```

Arguments:

- First argument: `debug` or `release` (build type)
- Second argument: `vs2019`, `windows`, or `dotnet` (compiler source)
- Third argument: `csc`, `msbuild`, `devenv`, or `dotnet` (compiler)
- Optional `clean`: Cleans the output directories before building
- Optional `run`: Runs the compiled program (uses `mdbg.exe` for debug builds)

Examples:

- To compile in debug mode using the Windows-provided `csc.exe`:
  ```
  compile.bat debug windows csc
  ```
- To clean, compile in release mode using VS2019's MSBuild, and run the program:
  ```
  compile.bat release vs2019 msbuild clean run
  ```
- To compile and run using .NET Core/5+:
  ```
  compile.bat debug dotnet run
  ```

Note: The order of the first three arguments doesn't matter, except for `dotnet`, which must be specified as the second argument.

## Project Structure

The repository includes the following key files:

- `Program.cs`: The main C# source code file
- `Program.csproj`: The C# project file for use with MSBuild and Visual Studio
- `Program.sln`: The solution file for use with Visual Studio
- `compile.bat`: The batch script for compiling and running the program

## Debugging with mdbg.exe

1. Compile the code in debug mode:

   ```
   compile.bat debug windows csc
   ```

2. Start mdbg:

   ```
   mdbg build\Program.exe
   ```

3. Set a breakpoint at the beginning of the Main method:

   ```
   b Program.cs:7
   ```

4. Run the program:

   ```
   run
   ```

5. Step through the code:

   - `n` to step over
   - `s` to step into
   - `o` to step out
   - `g` to continue execution

6. Inspect variables:

   ```
   p variableName
   ```

7. View the call stack:

   ```
   where
   ```

8. Exit mdbg:
   ```
   q
   ```

## Tutorial Steps

### 1. Initial Run and Identifying the Bug

First, let's compile and run the program to see the initial output:

```
compile.bat run
```

at once, or seperately:

```
compile.bat
```

and then

```
path\to\Program.exe
```

Expected output:

```
Compilation completed.
6
5
4
```

We expected to see the three smallest numbers (1, 2, 3), but we got the three largest instead. This indicates a bug in our program.

### 2. Stepping Through the Code

Let's step through the code and identify the issue. Compile the program in debug mode using our cmd batch:

```
compile.bat debug run
```

at once, or do it step by step:

```
compile.bat debug
```

and use `mdbg.exe` directly:

```
mdbg path\to\Program.exe
```

You should see output similar to this:

```lang-none
MDbg (Managed debugger) v0.0.0.0 started.
Copyright (C) Microsoft Corporation. All rights reserved.
For information about commands type "help";
to exit program type "quit".
run build\Program.exe
STOP: Breakpoint Hit
located at line 9 in Program.cs
```

Note: The "Breakpoint Hit" message is due to an auto-break at the entry point. When `mdbg Program.exe` is run, the debugger often halts execution at the program's entry point (usually the Main method) by default. This isn't a user-set breakpoint but an automatic one to give the user control over execution before any code runs.

In this case, we've stopped at line 9 in `Program.cs`, which is the opening curly brace `{` of the Main method. This means we're paused at the very beginning of the method, before any of its code has executed. The next step will take us into the first executable line of the Main method.

#### Understanding `step` and `next` in mdbg.exe

When debugging with `mdbg.exe`, two primary commands for moving through your code are `s` (step) and `n` (next). While they might seem similar, they behave quite differently:

- `s` (step):

  The `s` or `step` command:

  - Moves execution into the next function on the current line, or moves to the next line if there is no function to step into.
  - Allows you to follow the execution path into method calls, constructors, and other function-like code.

  For example, when using `s` repeatedly from the start of the `Main` method:

  ```
  [p#:0, t#:0] mdbg> s
  located at line 10 in Program.cs
  [p#:0, t#:0] mdbg> s
  IP: 0 @ System.Collections.Generic.List`1..ctor - MAPPING_EXACT
  [p#:0, t#:0] mdbg> s
  IP: 0 @ System.Collections.Generic.List`1..ctor - MAPPING_APPROXIMATE
  [p#:0, t#:0] mdbg> s
  IP: 0 @ System.Object..ctor - MAPPING_EXACT
  ...
  [p#:0, t#:0] mdbg> s
  IP: 17 @ System.Collections.Generic.List`1..ctor - MAPPING_EXACT
  [p#:0, t#:0] mdbg> s
  located at line 10 in Program.cs
  ```

  In this example:

  1.  We first step into line 10, which initializes a new `List<int>`.
  2.  The subsequent steps take us through the constructor of `List<int>` and its base classes.
  3.  The lines starting with `IP:` show the Instruction Pointer (IP) within the method being executed. These represent low-level steps in the construction of the `List<int>` object.
  4.  After many `s` commands, we finally return to line 10 in our `Program.cs`.

  The `MAPPING_EXACT` and `MAPPING_APPROXIMATE` indicate how precisely the debugger can map the current instruction to a line in the source code.

- `n` (next):

  The `n` or `next` command:

  - Runs code and moves to the next line, even if the current line includes multiple function calls.
  - Executes an entire line of code as a single unit, regardless of how many method calls or operations it contains.

  Using `n` from the same starting point:

  ```
  [p#:0, t#:0] mdbg> n
  located at line 10 in Program.cs
  ```

  With a single `n` command, we move to the next line, skipping over all the internal steps of creating the `List<int>`.

**Key Differences:**

1. **Granularity**: `s` provides a much finer granularity of control, allowing you to see every step of execution, including within library methods. `n` gives a higher-level view, focusing on your code.

2. **Speed of Debugging**: Using `n` allows you to move through your code more quickly, while `s` can be slower but provides more detailed information.

3. **Use Cases**:
   - Use `s` when you want to investigate the internals of a method call or when you suspect a problem within a called method.
   - Use `n` when you're confident in the workings of called methods and want to focus on the flow of your own code.

By understanding and effectively using both `s` and `n`, you can navigate your code efficiently during debugging, choosing the appropriate level of detail for your current debugging needs.

**Observing Variable Initialization**

After stepping to line 10 and then to line 11, we can observe how the `numbers` variable changes:

```
[p#:0, t#:0] mdbg> s
located at line 10 in Program.cs
[p#:0, t#:0] mdbg> p numbers
numbers=<null>
[p#:0, t#:0] mdbg> n
located at line 11 in Program.cs
[p#:0, t#:0] mdbg> p numbers
numbers=System.Collections.Generic.List`1<System.Int32>
        [0] = 1
        [1] = 2
        [2] = 3
        [3] = 4
        [4] = 5
        [5] = 6
```

Initially, when we're at line 10, `numbers` is `<null>` because the variable has been declared but not yet initialized. The `List<int>` object hasn't been created and assigned to `numbers` at this point.

After executing line 10 with the `n` command, we move to line 11. Now, `numbers` has been initialized with a new `List<int>` containing the values 1 through 6. This demonstrates how the debugger allows us to observe the step-by-step process of variable initialization and assignment.

### Identifying the Bug in GetSmallest Method

Now, let's navigate to the `GetSmallest` method and examine its behavior:

1. Continue stepping through the code using `n` until you reach the `GetSmallest` method call:

   ```
   [p#:0, t#:0] mdbg> s
   located at line 10 in Program.cs
   [p#:0, t#:0] mdbg> n
   located at line 11 in Program.cs
   [p#:0, t#:0] mdbg> s
   located at line 18 in Program.cs
   [p#:0, t#:0] mdbg> n
   located at line 19 in Program.cs
   [p#:0, t#:0] mdbg> n
   located at line 21 in Program.cs
   [p#:0, t#:0] mdbg> n
   located at line 22 in Program.cs
   [p#:0, t#:0] mdbg> n
   located at line 23 in Program.cs
   ```

2. Step into the `GetSmallest` method using `s`:

   ```
   [p#:0, t#:0] mdbg> s
   located at line 32 in Program.cs
   ```

3. Inside `GetSmallest`, step through each line, examining the variables:

   ```
   [p#:0, t#:0] mdbg> n
   located at line 34 in Program.cs
   [p#:0, t#:0] mdbg> n
   located at line 35 in Program.cs
   [p#:0, t#:0] mdbg> n
   located at line 35 in Program.cs
   [p#:0, t#:0] mdbg> n
   located at line 36 in Program.cs
   [p#:0, t#:0] mdbg> n
   located at line 37 in Program.cs
   [p#:0, t#:0] mdbg> n
   located at line 38 in Program.cs
   [p#:0, t#:0] mdbg> p min
   min=1
   ```

4. Pay close attention to the comparison logic:

   ```
   [p#:0, t#:0] mdbg> n
   located at line 39 in Program.cs
   [p#:0, t#:0] mdbg> p min
   min=2
   ```

Notice that instead of finding the smallest number, it's updating `min` to a larger number. This is where we identify the bug in our comparison logic. The condition `list[i] > min` is incorrect for finding the smallest number; it should be `list[i] < min`.

This step-by-step examination allows us to pinpoint exactly where and how the logic is failing, demonstrating the power of debugging in identifying subtle bugs in our code.

### 3. Fixing the Comparison in GetSmallest Method

The bug is in the comparison inside the GetSmallest method. Let's fix it:

1. Exit the debugger:

   ```
   q
   ```

2. Open Program.cs in a text editor and locate the GetSmallest method.

3. Change the comparison from:

   ```csharp
   if (list[i] > min)
   ```

   to:

   ```csharp
   if (list[i] < min)
   ```

4. Save the file and recompile:

   ```
   compile.bat debug
   ```

5. Run the debugger again and step through to verify the fix:
   ```
   mdbg !run path\to\Program.exe !go !quit
   ```

<!--### 4. Handling Edge Cases

Now let's test some edge cases:

1. Modify the Main method to test with an empty list or requesting more items than in the list.

2. Recompile and run the debugger:

   ```
   compile.bat debug run
   ```

3. Set a breakpoint at the GetSmallests method:

   ```
   b Program.cs:15
   ```

4. Run and examine the behavior with edge cases:
   ```
   go
   p numbers
   p count
   s
   ```

You'll notice the program doesn't handle these edge cases well.

### 5. Implementing Defensive Programming Techniques

Let's improve our code with defensive programming:

1. Exit the debugger and open Program.cs.

2. Modify the GetSmallests method to include input validation:

   ```csharp
   public static List<int> GetSmallests(List<int> list, int count)
   {
       if (list == null)
           throw new ArgumentNullException(nameof(list));
       if (count <= 0 || count > list.Count)
           throw new ArgumentOutOfRangeException(nameof(count), "Count should be between 1 and the number of elements in the list.");

       var smallests = new List<int>();
       var listCopy = new List<int>(list); // Create a copy to avoid modifying the original list

       while (smallests.Count < count)
       {
           var min = GetSmallest(listCopy);
           smallests.Add(min);
           listCopy.Remove(min);
       }

       return smallests;
   }
   ```

3. Recompile and run the debugger:

   ```
   compile.bat debug windows csc
   mdbg build\Program.exe
   ```

4. Set breakpoints and step through the code to verify the new defensive measures:

   ```
   b Program.cs:15
   run
   s
   ```

5. Test different scenarios (null list, count = 0, count > list.Count) and observe how the program now handles these cases.

By following these steps, you've debugged the initial problem, fixed the bug, and implemented defensive programming techniques to make the code more robust. The CLI debugging process using `mdbg.exe` allows for a detailed examination of the code execution, similar to what you'd achieve with Visual Studio's GUI debugger. -->

## Contributing

Feel free to contribute to this project by submitting pull requests or opening issues for any bugs or suggestions.

## License

This project is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike (CC BY-NC-SA) License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Mosh Hamadani](https://x.com/moshhamedani/) for the original Visual Studio debugging tutorial
- Microsoft for providing mdbg.exe and other .NET debugging tools
