FROM node:20-slim AS builder

# --max-old-space-size
# ENV PNPM_HOME="/pnpm"
# ENV PATH="$PNPM_HOME:$PATH"
ENV NODE_OPTIONS=--max-old-space-size=8192
ENV TZ=Asia/Shanghai

RUN corepack enable

# 安装 Git
RUN apt-get update && apt-get install -y git

WORKDIR /app

# copy package.json and pnpm-lock.yaml to workspace
COPY . /app

# 配置 Git（可选，视情况而定）
RUN git config --global user.email "dushuren@gmail.com" && \
    git config --global user.name "lizhz" && \
    git init && \
    git add . && \
    git commit -m "Initial commit" && \
    git config --local core.quotepath false

# RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm install --frozen-lockfile
RUN pnpm run build

RUN echo "Builder Success 🎉"

FROM nginx:stable-alpine as production

RUN echo "types { application/javascript js mjs; }" > /etc/nginx/conf.d/mjs.conf
COPY --from=builder /app/playground/dist /usr/share/nginx/html

COPY ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080

# start nginx
CMD ["nginx", "-g", "daemon off;"]
