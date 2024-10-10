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

2. `cd` into you directory of choice and install Mdbg using NuGet:

   ```
   nuget install Mdbg
   ```

3. Add Mdbg to your system PATH:
   ```
   set "PATH=%PATH%;C:\path\to\Mdbg\tools"
   ```
   Replace `C:\path\to\Mdbg\tools` with the actual path where Mdbg was installed.

## Compiling the C# Code

A cmd batch file is provided that allows you to compile the C# code using different methods. The syntax is:

```
compile.bat <debug/release> <vs2019/windows/dotnet> <csc/msbuild/devenv>
```

For example, to compile in debug mode using the Windows-provided `csc.exe`:

```
compile.bat debug windows csc
```

## Debugging with mdbg.exe

1. Compile the code in debug mode:

   ```
   compile.bat debug windows csc
   ```

2. Start mdbg:

   ```
   mdbg Program.exe
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

(Here, we'll add detailed steps following Mosh Hamadani's tutorial, adapted for CLI usage)

1. Initial run and identifying the bug
2. Stepping through the code
3. Fixing the comparison in GetSmallest method
4. Handling edge cases
5. Implementing defensive programming techniques

(Each step will be expanded with specific mdbg.exe commands and expected outputs)

## Contributing

Feel free to contribute to this project by submitting pull requests or opening issues for any bugs or suggestions.

## License

This project is licensed under the Creative Commons License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Mosh Hamadani for the original Visual Studio debugging tutorial
- Microsoft for providing mdbg.exe and other .NET debugging tools
