# 10 - Bun Build Plan

## 目标
在 Termux/Android arm64 上得到可运行的 Bun 产物，并可进一步打包为：
- `deb`
- `pkg.tar.xz`

---

## 关键事实

- Termux 为 Bionic 环境，Bun 的部分执行路径依赖 glibc 兼容层。
- `bun build --compile` 产物依赖 `/proc/self/exe` 读取自身 trailer。
- 若通过不当 loader 路径启动，`/proc/self/exe` 可能指向 `ld.so`，导致运行异常。

### 为什么普通 glibc 兼容层不够

| 方式 | `/proc/self/exe` 指向 | Bun 行为 |
|------|----------------------|---------|
| `grun ./my-app` | `ld-linux-aarch64.so.1` | ❌ 找不到嵌入数据 |
| `ld.so ./my-app` | `ld-linux-aarch64.so.1` | ❌ 找不到嵌入数据 |
| userspace exec | `./my-app`（自身） | ✅ 正常工作 |

**解决方案**：bun-termux-loader 使用 userspace exec，不调用 `execve()`，保持 `/proc/self/exe` 指向原二进制。

---

## 阶段路线

### 1. 输入准备
获取真实 `bun build --compile` 产物：

```bash
# 方式 A：从上游 release 获取预编译 bun
# 方式 B：本地构建（需要 glibc 环境）
bun build ./entry.ts --compile --outfile ./my-app
```

### 2. loader 包装
使用 `bun-termux-loader` 的 `build.py`：

```bash
git clone https://github.com/kaan-escober/bun-termux-loader
cd bun-termux-loader
python3 build.py /path/to/my-app
# 输出：./my-app-termux
```

### 3. 标记校验

```bash
# 输入必须包含
strings -n 8 ./my-app | grep '---- Bun! ----'

# 输出必须同时包含
strings -n 8 ./my-app-termux | grep -E 'BUNWRAP1|---- Bun! ----'
```

### 4. 运行校验

```bash
./my-app-termux --version
echo 'console.log("ok")' | ./my-app-termux -
```

---

## Fail-Fast 门禁

| 检查 | 失败条件 | 排查方向 |
|------|---------|---------|
| 输入标记 | 不含 `---- Bun! ----` | 输入不是有效的 `bun build --compile` 产物 |
| 输出标记 | 不含 `BUNWRAP1` | loader 构建失败 |
| 运行错误 | `loader cannot load itself` | 提取的 ELF 是 `ld.so` 而非 Bun runtime |
| 提取大小 | `~240KB` 而非 `~90MB` | 元数据解析错误，嵌入了错误的 payload |

---

## 排错检查点

```bash
# 检查文件类型
file ./my-app ./my-app-termux

# 检查标记
strings -n 8 ./my-app | grep '---- Bun! ----'
strings -n 8 ./my-app-termux | grep -E 'BUNWRAP1|---- Bun! ----'

# 检查提取的 Bun ELF（首次运行后）
ls -lh "$TMPDIR/bun-termux-cache/"
# 应看到 ~90MB 文件，而非 ~240KB 的 ld.so
```

---

## 二进制优化

### ✅ strip（推荐）

```bash
strip ./my-app-termux
```

效果：减少 10-30%，无副作用

### ❌ UPX（不可用）

```bash
upx --best ./my-app-termux
# error: no embedded Bun runtime (missing BUNWRAP1)
```

原因：UPX 压缩会破坏嵌入标记结构。

详见：[12-bun-executable-structure.md](./12-bun-executable-structure.md)

### ✅ 分发压缩

```bash
zstd -19 --ultra -o my-app-termux.zst my-app-termux
# 或
xz -9e -k my-app-termux
```

---

## 相关资源

- [bun-termux-loader](https://github.com/kaan-escober/bun-termux-loader) - 核心 loader
- [bun-termux-loader SOLUTION.md](https://github.com/kaan-escober/bun-termux-loader/blob/master/SOLUTION.md) - 技术原理
- [Bun Issue #26752](https://github.com/oven-sh/bun/issues/26752) - BUN_SELF_EXE 请求
- [Bun Issue #8685](https://github.com/oven-sh/bun/issues/8685) - Bun on Termux

---

## 待锁定

- [ ] bun 版本/tag
- [ ] bun-termux-loader commit
- [ ] 是否需要额外 bunfs shim 路径处理
