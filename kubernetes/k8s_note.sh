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
    4. 探针 
        探针由kubelet 对容器进行定期诊断 通过调用由容器实现的 Handler 包含3种类型的处理程序
            ExecAction 在容器内执行指定命令 如果命令返回码为200 为诊断成功
            TCPSocketAction 对指定端口的容器IP进行TCP检查 如果端口打开则为成功
            HTTPGetAction 对指定端口和路径的容器IP地址进行http Get请求 如果响应码大于200小于400则为成功
        每次探测都会得到以下3种结果之一
            成功 容器通过诊断
            失败 容器未通过诊断
            未知 诊断失败 不会采取任何行动
        startupProbe 是否已经启动 保障存活探针执行时不会因为时间设定问题导致 无限死亡/延迟很长 的死循环情况
        livenessProbe 是否存活 如果pod为失败状态则重启容器 容器restart +1  如果不指定的话会发生容器在运行但是无法提供服务的情况
        readinessProbe 是否准备提供服务 (不添加就绪探测 默认就绪 )
            initialDelaySeconds 容器启动后多少秒后探针开始工作 默认0s
            periodSeconds 执行探测时间间隔 默认10s 最小1s
            timeoutSeconds 执行检测请求后等待响应的超时时间 默认1s 最小1s
            successThreshold 探针检测失败后认为成功的最小连接成功数 默认为1 最小为1 
            failureThreshold 探针检测失败重试次数 重试一定次数后将认定失败 默认为3 最小为1
    5. 钩子Hook postStart/preStop
        基于Linux命令 kubernetes/resourceFile/pod/1-4hook-1.yaml
        基于http get  kubernetes/resourceFile/pod/1-4hook-2.yaml
        k8s 中理想的状态是pod 优雅释放 Graceful destroy 但是有时候会出现以下因素导致pod 无法优雅释放 
            pod卡死
            退出逻辑有bug
            代码问题导致执行命令没有结果 
        针对以上问题可以通过pod.spec.terminationGracePeriodSeconds 定义最多容忍时间, 超过时间后将直接通过kill -9 进行强行退出

控制器
    