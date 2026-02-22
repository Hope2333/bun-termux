当前环境termux，通过转换脚本/data/data/com.termux/files/init-pacmanV00fix14.sh将包管理器移交给了pacman，配置文件和启用储存库位于$PREFIX/etc/pacman.conf，pkg和apt是通过转译脚本把操作翻译给pacman安装软件包；可以通过grun使用glib的软件(命令行软件优先)，可以通过termux-{api,x11}等调用外部。已部署pip、npm等，基本上各大语言的编译库差不多就绪(主要针对本环境)。

本文件大体遵循markdown，但一大堆确实不太遵循

---

anomalyco/opencode  
[本文]https://github.com/anomalyco/opencode/issues/12515
# Android/Termux install fails: postinstall requires missing package opencode-android-arm64
`Open` `[#12515]`
@baiyun1123 opened 上周  
## Description
Title: Android/Termux install fails: postinstall requires missing package `opencode-android-arm64`

Hi maintainers,

I’m trying to install `opencode-ai` in Termux (Android arm64), and installation fails during `postinstall`.

# Environment
- Device: Android (arm64)
- Shell: Termux
- Node: (run `node -v`)
- npm: (run `npm -v`)
- Install command: `npm i -g opencode-ai`

# Error log
Failed to setup opencode binary: Could not find package opencode-android-arm64: Cannot find module 'opencode-android-arm64/package.json'  
Require stack:

- /data/data/com.termux/files/usr/lib/node_modules/opencode-ai/postinstall.mjs
```
npm error code 1
npm error path /data/data/com.termux/files/usr/lib/node_modules/opencode-ai
npm error command failed
npm error command sh -c bun ./postinstall.mjs || node ./postinstall.mjs
```
# Investigation
`optionalDependencies` for `opencode-ai` currently are:
```
{
  "opencode-linux-x64": "1.1.53",
  "opencode-darwin-x64": "1.1.53",
  "opencode-linux-arm64": "1.1.53",
  "opencode-windows-x64": "1.1.53",
  "opencode-darwin-arm64": "1.1.53",
  "opencode-linux-x64-musl": "1.1.53",
  "opencode-linux-arm64-musl": "1.1.53",
  "opencode-linux-x64-baseline": "1.1.53",
  "opencode-darwin-x64-baseline": "1.1.53",
  "opencode-windows-x64-baseline": "1.1.53",
  "opencode-linux-x64-baseline-musl": "1.1.53"
}

### Plugins

_No response_

### OpenCode version

_No response_

### Steps to reproduce

_No response_

### Screenshot and/or share link

_No response_

### Operating System

_No response_

### Terminal

_No response_
```

.
@baiyun1123 added [bug] Something isn't working 上周 
@github-actions assigned thdxr 上周

github-actions (bot) 上周 – with GitHub Actions		Contributor  
This issue might be a duplicate of existing issues. Please check:

[FEATURE]: Make a binary build for Android Aarch64 (Termux) #11689:   
- This feature request addresses the exact same problem of missing Android/Termux support

OpenCode binary fails to run natively on Termux / Android aarch64 (wrong interpreter + non‑PIE executable) #10504:  
- Related to binary compatibility issues on Android/Termux
Feel free to ignore if none of these address your specific case.

.
baiyun1123 closed this as completed 上周

baiyun1123 上周		Author  
I believe this is a duplicate of #11689 (and related to #10504).

My Termux/Android arm64 repro:

- `npm i -g opencode-ai` fails `in postinstall.mjs`
- error: `Cannot find module 'opencode-android-arm64/package.json'`
- `npm view opencode-ai optionalDependencies --json` does not include `opencode-android-arm64`

So Android arm64 seems referenced by installer logic but not published as a platform package.

Also, running binaries from shared storage paths (e.g. /sdcard-like mount) can cause `Permission denied` due to noexec, which is a separate runtime constraint.

baiyun1123 上周		Author  
awa

.
baiyun1123 reopened this 上周

kaan-escober 3天前  
@thdxr here is the complete termux fix  
so i fixed the whole bun termux compatibilty thing once and for all.

Termux uses Bionic (Android's libc), but Bun is compiled against glibc. The standard workaround is using grun (glibc-runner), but this breaks Bun bundled executables because /proc/self/exe points to ld.so instead of the actual binary.

Bun bundled executables detect their embedded JavaScript by reading /proc/self/exe and looking for the ---- Bun! ---- magic trailer. When /proc/self/exe points to ld.so, Bun can't find its embedded code and falls back to CLI mode.

# The Solution
This tool uses userland exec - it loads glibc's ld.so via mmap() and jumps to it directly, without calling execve(). Since the kernel only updates /proc/self/exe on execve(), it stays pointing to our binary which contains the embedded JavaScript.

I wrote a custom userspace exec wrapper in C. Now Opencode, Droid, claude code & Amp run natively on termux. Opencode was a little trickier because it loaded opentui from $bunfs which wasnt available on termux, so i added a dlopen interception for $bunfs calls and now Opencode works

Here is the repo with source code: https://github.com/kaan-escober/bun-termux-loader

baiyun1123 3天前		Author  
@kaan-escober  
Thanks for the report. That error usually means the wrapper is extracting the wrong ELF and jumping into ld-linux-aarch64.so.1 instead of the Bun runtime. In your case the cached file size (241144 bytes) matches glibc’s ld-linux-aarch64.so.1, not the Bun ELF (~90MB), so the metadata parsing or input binary is likely wrong.  
Please confirm:  
1)  
file ./my-app (input to build.py)  
2)  
strings -n 8 ./my-app | rg 'BUNWRAP1|---- Bun! ----'  
3)  
ls -l $TMPDIR/bun-termux-cache/ (size of extracted bun-* file)  
If the input isn’t the compiled bun binary from bun build --compile, build.py will embed the wrong payload and you’ll hit this exact error. Once the input is correct, the extracted bun-* file should be ~90MB and the error should disappear.

.
baiyun1123 closed this as completed 3天前

baiyun1123 3天前		Author  
no

.
baiyun1123 reopened this 3天前  
baiyun1123 closed this as completed 3天前  

baiyun1123 3天前		Author  
It doesn't seem to be good yet

.
baiyun1123 reopened this 3天前

kaan-escober 3天前  
whats wrong

baiyun1123 3天前		Author  
@kaan-escober ---  
Title: ld-linux-aarch64.so.1: loader cannot load itself error on Termux

Description:  
When running the built Termux binary, the following error occurs:  
$ ./my-app-termux  
ld-linux-aarch64.so.1: loader cannot load itself  
Exit code: 127

Environment:

- Platform: Android/Termux (aarch64)
- glibc version: 2.42 (glibc package)
- glibc-runner version: 2.0-3
- clang version: 21.1.8

Steps to Reproduce:

1. Clone the repository
2. Run make to build wrapper
3. Run python3 build.py ./demo-app/my-app
4. Execute the generated binary: ./my-app-termux

Investigation:

1. The wrapper binary is built successfully (Bionic-linked, Android-compatible)
2. The build process successfully embeds the Bun ELF and generates my-app-termux (247.5 KB)
3. On first run, the wrapper extracts the embedded Bun ELF to $TMPDIR/bun-termux-cache/
4. The extracted file /data/data/com.termux/files/usr/tmp/bun-termux-cache/bun-* is identical to the glibc's ld-linux-aarch64.so.1 (241144 bytes)

Analysis:

- The wrapper extracts the wrong data - it appears to be extracting ld-linux-aarch64.so.1 instead of the actual Bun binary
- This suggests the BUNWRAP1 metadata parsing or Bun ELF size extraction may be incorrect
- Or the original my-app binary may have an incorrect structure

Expected Behavior:  
The bundled Bun executable should run on Termux without the "loader cannot load itself" error.


kaan-escober 前天  
if you could tell me mofe about the binary, i will try to fix it

---

# 附文/库且可能有用：  
## bun：
https://github.com/thdxr/bun/tree/patch-1
https://github.com/thdxr/bun/
https://github.com/oven-sh/bun
https://github.com/kaan-escober/bun-termux-loader
https://github.com/oven-sh/bun/issues/26752 Bun Issue #26752 - Request for BUN_SELF_EXE env var
https://github.com/oven-sh/bun/issues/8685 Bun Issue #8685 - Bun on Termux documentation
https://github.com/kaan-escober/bun-termux-loader/blob/master/README.md
https://github.com/kaan-escober/bun-termux-loader/blob/master/SOLUTION.md

## opencode：
https://github.com/anomalyco/opencode

## Hao to build & Differences from Debian&ArchLinux：
https://github.com/termux-user-repository/tur
https://wiki.termux.com/wiki/Package_Management
https://wiki.termux.com/wiki/AUR
https://wiki.archlinux.org/title/Arch_User_Repository
https://wiki.archlinux.org/title/PKGBUILD
https://www.debian.org/doc/manuals/maint-guide/build.html
https://wiki.termux.com/wiki/Switching_package_manager
https://wiki.termux.com/wiki/Termux-exec
https://wiki.termux.com/wiki/Building_packages
https://wiki.termux.com/wiki/Differences_from_Linux
https://github.com/termux/termux-packages/wiki/Common-porting-problems
https://wiki.termux.com/wiki/Development_Environments
https://github.com/termux/termux-packages/wiki/Creating-new-package
https://github.com/termux/termux-packages
https://github.com/termux/termux-packages/wiki
https://github.com/termux/termux-packages/wiki/Building-packages
https://github.com/termux/termux-packages/wiki/Build-environment
https://github.com/termux-pacman/termux-packages


# 其他技术栈
https://github.com/turbomaster95/bun-termux/blob/main/install.sh
https://github.com/tribixbite/bun-on-termux
https://github.com/Amirulmuuminin/Termux-glibc-wrapper

# 非官方文档
https://blog.csdn.net/gitblog_00289/article/details/150710049
https://readmex.com/termux/termux-packages/
https://aur.archlinux.org/packages/yay

另外，没有网络限制，请不要吝啬去查询最新版和拉取东西，做成品又不是做玩具

---

大致，你会制作多个由于构建的工具链（如build.sh或PKGBUILD等。
大概目标是构建出两个软件包bun和opencode，它们都有deb和pkg.tar.xz的两个版本
bun-termux-loader应该是作为oven-sh/bun的patch
应该会下载bun-termux-loader的仓库然后构建它或者使用构建的patch，或者patch或者前者都有；还会下载bun和opencode的release。