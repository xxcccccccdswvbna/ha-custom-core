# ----------------------------------------------------------------------------------
# 第一阶段：构建环境 (Building Stage)
# ----------------------------------------------------------------------------------

# 使用官方 Home Assistant ARMv7 核心镜像作为基础
# 我们使用 'stable-armv7' 标签来确保架构正确
FROM ghcr.io/home-assistant/home-assistant:stable-armv7 AS builder

# 1. 切换到 root 用户来安装依赖
USER root

# 2. 安装必要的构建工具 (gcc, python-dev 等)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        python3-dev \
        libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# 3. 预编译和安装 lupa
# 使用 HA 环境中的 Python
RUN /usr/local/bin/python3 -m pip install lupa

# ----------------------------------------------------------------------------------
# 第二阶段：最终镜像 (Final Stage)
# ----------------------------------------------------------------------------------

# 重新使用官方 ARMv7 核心镜像
FROM ghcr.io/home-assistant/home-assistant:stable-armv7

# 4. 切换到 root 用户来复制文件
USER root

# 5. 从构建阶段复制预编译好的 lupa
# 使用通配符 * 匹配 python 版本 (例如 python3.11, python3.12)
COPY --from=builder /usr/local/lib/python*/site-packages /usr/local/lib/python*/site-packages

# 6. 确保权限正确 (HA 默认以 'homeassistant' 用户运行)
RUN chown -R homeassistant:homeassistant /usr/local/lib/python*/site-packages

# 7. 切换回默认用户
USER homeassistant
