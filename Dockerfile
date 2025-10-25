# ----------------------------------------------------------------------------------
# 第一阶段：构建环境 (Building Stage)
# ----------------------------------------------------------------------------------

# 使用官方 Home Assistant ARMv7 核心镜像
FROM ghcr.io/home-assistant/home-assistant:stable-armv7 AS builder

USER root

# 2. 安装构建工具 (gcc, python-dev 等)
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

FROM ghcr.io/home-assistant/home-assistant:stable-armv7

USER root

# 5. 从构建阶段复制预编译好的 lupa
COPY --from=builder /usr/local/lib/python*/site-packages /usr/local/lib/python*/site-packages

# 6. 确保权限正确
RUN chown -R homeassistant:homeassistant /usr/local/lib/python*/site-packages

USER homeassistant
