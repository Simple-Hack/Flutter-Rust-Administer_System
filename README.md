# 学生教务系统/flutter+rust实现

使用到的工具有

- flutter_rust_bridge 2.6.0
- sqlite3
- serde
- serde_json
- provider
- wasm-bindgen(似乎没用上，因为编译sqlite3需要用到C标准库所以这里需要使用Emscripten)
- ......
  
> Emscripten is "the" toolchain for building WASM applications. Though there are several others available, e.g. wasi-sdk or even vanilla clang, Emscripten has several features which are required in order to get a completely-working copy of many types of C libraries out of the box, most notably their POSIX I/O API proxy support. sqlite3 can be built with other toolchains, but it cannot currently do much because getting the resulting WASM file loaded requires that the client provide implementations for the I/O-layer functions (a considerable undertaking!)[^1]

总的来讲，当打开Chrome或Edge浏览器时始终存在编译sqlite3时显示缺少 **\<stdio.h\>** 的问题，目前还没有找到解决方案，所以，本文件只能在Windows平台上运行。

[^1]: [Sqlite3官方文档](https://sqlite.org/wasm/doc/trunk/emscripten.md)
