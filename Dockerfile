FROM rust:1.53 as builder
WORKDIR /build
COPY . .
RUN rustup target add aarch64-unknown-linux-gnu
RUN apt update && apt install -y gcc-aarch64-linux-gnu
RUN cd wasm-tools && cargo build
RUN cd wasmtime && cargo build --target aarch64-unknown-linux-gnu

FROM debian:buster
WORKDIR /run
RUN mkdir wasm-tools && mkdir wasmtime
# Install ghidra
ENV VERSION 10.0
ENV GHIDRA_SHA "aaf84d14fb059beda10de9056e013186601962b6f87cd31161aaac57698a0f11"

RUN apt update && apt install -y openjdk-11-jdk

RUN apt install -y wget ca-certificates unzip \
    && wget --progress=bar:force -O /tmp/ghidra.zip https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.0_build/ghidra_10.0_PUBLIC_20210621.zip \
    && echo "${GHIDRA_SHA}  /tmp/ghidra.zip" | sha256sum -c - \
    && unzip /tmp/ghidra.zip \
    && mv ghidra_${VERSION}_PUBLIC /ghidra \
    && chmod +x /ghidra/ghidraRun \
    && echo "===> Clean up unnecessary files..." \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives /tmp/* /var/tmp/* \
    && rm -rf /ghidra/docs \
    && rm -rf /ghidra/licenses \
    && rm -rf /ghidra/Extensions/Ghidra \
    && rm -rf /ghidra/Extensions/Eclipse \
    && find /ghidra -type f -name "*src*.zip" -exec rm -f {} \;

RUN dpkg --add-architecture arm64
RUN apt update && apt install -y qemu qemu-user make libc6:arm64 bbe
RUN mkdir wasm-tools/target wasmtime/target JANT

COPY --from=builder /build/wasm-tools/target wasm-tools/target
COPY --from=builder /build/wasmtime/target wasmtime/target
WORKDIR /run/JANT
COPY JANT .
COPY run_check.sh .
RUN chmod +x run_check.sh