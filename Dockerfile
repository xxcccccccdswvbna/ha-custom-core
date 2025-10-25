# ----------------------------------------------------------------------------------
# 第一阶段：构建环境 (Building Stage)
# ----------------------------------------------------------------------------------

# 使用多架构的 ':stable' 标签作为 Home Assistant 核心基础镜像
FROM ghcr.io/home-assistant/home-assistant:stable AS builder

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

# 重新使用干净的 HA 核心镜像
FROM ghcr.io/home-assistant/home-assistant:stable

USER root

# 5. 从构建阶段复制预编译好的 lupa
COPY --from=builder /usr/local/lib/python*/site-packages /usr/local/lib/python*/site-packages

# 6. 确保权限正确 (Home Assistant 默认用户是 homeassistant)
RUN chown -R homeassistant:homeassistant /usr/local/lib/python*/site-packages

USER homeassistant
