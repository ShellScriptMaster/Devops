Guanziq957@163.com
pod生命周期
    1. puase容器创建
        初始化网络/挂载存储卷/与其他容器共享网络/共享IPC/共享PID/回收僵尸进程(孤儿进程)
    2. Init Containers 初始化容器
        在主容器启动前按顺序执行,有可能是一系列或者一个容器
        每个init 退出的时候必须返回0 失败则按 restartPolicy 重启(默认Always) 所有init-C 重新开始restart
        典型用途：
            数据库迁移、配置下载、依赖检查、权限初始化、风险性操作
            案例: 创建php容器前需要确保mysql存活并正常提供服务，可以在创建php前创建init-c对mysql存活进行持续探测，确保mysql在php前已经创建
    3. 主容器 main-container 持续运行/多个main-C 可以并发执行
        kubelet调度CRI进行容器初始化 
        执行启动命令(dockerfile cmd/entrypoint) / postStart(与容器主进程异步执行) 服务注册/配置生成/缓存预热/启动回调/权限初始化 (postStart失败会导致整个pod失败)
        启动/存活/就绪探测 startup/liveness/readiness (kubelet执行)
        用户下达缩容命令 APIServer记录deletionTimeStamp pod进入terminating状态 pod从serviceEndpoint中移除不再接受新流量
        preStop执行 (kubelet必须等待其完成再发送SIGTERM信号到主容器)
        Kubelet向主容器发送SIGTERM信号 等待terminationGracePeriodSeconds(默认30s,preStop执行时间也计入其中) 若30s后进程未退出则直接kill 

        postStart 
            spec:
            containers:
                - name: app
                image: nginx:alpine
                lifecycle:
                    postStart:
                    exec:
                        command:
                        - /bin/sh
                        - -c
                        - |
                            echo "[$(date)] Container started" >> /var/log/lifecycle.log
                            # 模拟服务注册
                            curl -X POST http://service-registry/register \
                            -d '{"pod": "poststart-demo", "ip": "$(POD_IP)"}' || exit 1

        preStop 
            spec:
            terminationGracePeriodSeconds: 60  # 总宽限期 60 秒
            containers:
                - name: app
                lifecycle:
                    preStop:
                    exec:
                        command: ["/bin/sh", "-c", "sleep 45"]  # PreStop 执行 45 秒

