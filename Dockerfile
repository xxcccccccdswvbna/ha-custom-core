# ----------------------------------------------------------------------------------
# 第一阶段：构建环境 (Building Stage)
# ----------------------------------------------------------------------------------

# 修正: 使用多架构的 'stable' 标签作为基础。Buildx 会自动选择 armv7。
FROM ghcr.io/home-assistant/home-assistant:stable AS builder

USER root

# 2. 安装构建工具 (gcc, python-dev 等)
# 这些工具只存在于此阶段，不会污染最终镜像
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        python3-dev \
        libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# 3. 预编译和安装 lupa
RUN /usr/local/bin/python3 -m pip install lupa

# ----------------------------------------------------------------------------------
# 第二阶段：最终镜像 (Final Stage)
# ----------------------------------------------------------------------------------

# 重新使用官方 HA 核心镜像，确保最终镜像最小化且干净
FROM ghcr.io/home-assistant/home-assistant:stable

USER root

# 5. 从构建阶段复制预编译好的 lupa
# 使用通配符 * 匹配 python 版本
COPY --from=builder /usr/local/lib/python*/site-packages /usr/local/lib/python*/site-packages

# 6. 确保权限正确 (HA 默认用户是 homeassistant)
RUN chown -R homeassistant:homeassistant /usr/local/lib/python*/site-packages

USER homeassistant
