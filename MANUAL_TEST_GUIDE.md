# 手动测试指南

由于缺少GitHub仓库URL，以下是手动测试步骤。

## 测试前提条件

### 1. 创建GitHub仓库
```bash
# 在浏览器中访问：
# https://github.com/new

# 创建仓库：
# - 仓库名: termux-packaging
# - 描述: Packaging system for Bun and OpenCode on Termux
# - 公开仓库
# - 不要初始化README
# - 添加MIT许可证
```

### 2. 获取仓库URL
创建后获得URL，格式为：
```
https://github.com/Hope2333/bun-termux.git
```

## 测试步骤

### 步骤1: 推送本地仓库到GitHub
```bash
cd /data/data/com.termux/files/home/develop

# 使用实际URL替换<your-repo-url>
./push_to_github.sh https://github.com/Hope2333/bun-termux.git
```

### 步骤2: 测试arm64机器 (10.31.66.45:8022)
```bash
cd /data/data/com.termux/files/home/develop

# 使用实际URL
./test_remote_machine.sh 10.31.66.45 8022 https://github.com/Hope2333/bun-termux.git
```

### 步骤3: 测试arm32机器 (10.31.66.76:8022)
```bash
cd /data/data/com.termux/files/home/develop

# 使用实际URL
./test_remote_machine.sh 10.31.66.76 8022 https://github.com/Hope2333/bun-termux.git
```

### 步骤4: 手动验证（如果自动测试失败）

#### 在arm64测试机上手动操作：
```bash
# SSH连接到测试机
ssh -p 8022 u0_a240@10.31.66.45

# 克隆仓库
git clone https://github.com/Hope2333/bun-termux.git
cd bun-termux

# 运行设置
./setup.sh

# 编辑配置
echo 'TERMUX_PREFIX="/data/data/com.termux/files/usr"
DEVELOP_ROOT="'$(pwd)'"
ARCHITECTURE="arm64"' > .config/termux-packaging.conf

# 测试构建
source .config/termux-packaging.conf
./scripts/build/build_bun.sh
./scripts/build/build_opencode.sh
```

#### 在arm32测试机上手动操作：
```bash
# SSH连接到测试机
ssh -p 8022 u0_a450@10.31.66.76

# 克隆仓库
git clone https://github.com/Hope2333/bun-termux.git
cd bun-termux

# 运行设置
./setup.sh

# 编辑配置
echo 'TERMUX_PREFIX="/data/data/com.termux/files/usr"
DEVELOP_ROOT="'$(pwd)'"
ARCHITECTURE="armv7l"' > .config/termux-packaging.conf

# 测试构建
source .config/termux-packaging.conf
./scripts/build/build_bun.sh
./scripts/build/build_opencode.sh
```

## 预期结果

### arm64测试机应显示：
```
✓ ARM64 (64-bit) architecture
✓ apt is available (Debian/Ubuntu style)
✓ All scripts are executable
✓ Build completes without errors
```

### arm32测试机应显示：
```
✓ ARM32 (32-bit) architecture
✓ apt is available (Debian/Ubuntu style)
✓ All scripts are executable
✓ Build completes without errors
```

## 故障排除

### 如果SSH连接失败：
1. 检查IP地址是否正确
2. 检查端口8022是否开放
3. 验证用户名是否为u0_a450
4. 检查网络连接

### 如果Git克隆失败：
1. 验证GitHub仓库URL
2. 检查网络连接
3. 确保仓库是公开的

### 如果构建失败：
1. 检查.config/termux-packaging.conf中的路径
2. 确保有足够的磁盘空间
3. 检查Termux包管理器是否正常工作

## 验证清单

### arm64验证：
- [ ] SSH连接成功
- [ ] Git克隆成功
- [ ] 所有脚本可执行
- [ ] 构建脚本运行无错误
- [ ] 架构检测为arm64

### arm32验证：
- [ ] SSH连接成功
- [ ] Git克隆成功
- [ ] 所有脚本可执行
- [ ] 构建脚本运行无错误
- [ ] 架构检测为armv7l

## 完成标准

两个测试机都完成以下操作：
1. 成功克隆GitHub仓库
2. 成功运行setup.sh
3. 成功执行构建脚本
4. 正确检测系统架构

## 报告问题

如果测试失败，请记录：
1. 错误信息
2. 测试环境详情
3. 已尝试的解决步骤
4. 相关日志文件