# AspNetCoreCloud 

目前还是很简陋很粗糙的，希望有做Net的朋友可以进群指导：568016706，慢慢的把这个项目维护好。

### 视频介绍地址：https://www.ixigua.com/i6758305674041508360/

### docker容器化介绍：https://www.ixigua.com/i6768731822999208462/

## 目录结构

apollo-quick-start-1.5.0/sql文件夹是存放我自己建立的Apollo项目，如果所有的src内的代码都没有改变就希望能跑起来的话就需要将Sql文件导入到Apollo

src目录内是ApiGateServer网关、AuthService权限微服、OrderService订单微服、ProductService产品微服

配置中心及服务发现 https://pan.baidu.com/s/1FSLrnJBqc8rRN6RHn_CmHw

## 1、Apollo首先需要启动配置中心

### 因为配置中心启动包有点大上传到github上会单个文件超出100mb出错，所以我放在了上面的百度云链接中。可以直接下载或者去:https://github.com/ctripcorp/apollo 下载。

启动Apollo需要Java 1.8或更高版本，MySQL5.6.6或更高版本。

下载官方的Apollo或者使用我提供的百度云链接下载完成后，先在MySQL中导入apollo-quick-start-1.5.0/sql内的两个sql文件执行成功后会得到两个数据库（ApolloConfigDB、ApolloPortalDB）

之后打开demo.sh文件修改里面的数据库链接字符串类似：

#### apollo config db info

apollo_config_db_url=jdbc:mysql://localhost:33061/ApolloConfigDB?characterEncoding=utf8（修改成自己的）

apollo_config_db_username=root（修改成自己的）

apollo_config_db_password=root（修改成自己的）

#### apollo portal db info

apollo_portal_db_url=jdbc:mysql://localhost:33061/ApolloPortalDB?characterEncoding=utf8（修改成自己的）

apollo_portal_db_username=root（修改成自己的）

apollo_portal_db_password=root（修改成自己的）

接下来就是启动，在命令行输入： ./demo.sh start 启动成功后访问链接http://localhost:8070/， 登录后台的账号：apollo，密码；admin

Apollo不用的时候在命令行输入：./demo.sh stop

## 2、接下来就是启动Consul服务发现,一样需要下载可以用上面的百度云链接中下载或者去：https://github.com/hashicorp/consul 下载。

### 不过我建议直接用我那个百度云，因为那里面我写了一个开发环境的简单启动命令行。文件夹内有一个start.sh文件，直接在命令行中执行：./start.sh

浏览器访问：http://localhost:8500/ui/ ，如果能出来consul界面就是启动成功了。

## 3、链路追踪Zipkin

运行一个Zipkin : docker run -d -p 9411:9411 openzipkin/zipkin 

除docker外其他的启动方式：https://zipkin.io/ ，运行起来后先浏览器访问：http://localhost:9411/ ，最后等我们整个项目都跑一遍后回来看效果。

## 4、接下来启动src内的所有AspNetCore项目都直接命令行执行：dotnet run 就好了。

### 可以先把所有的AspNetCore项目都启动起来，然后去http://localhost:8500/ui/ 看看services列表是不是应该增加了三个服务。目前我没有把网关加入服务。

### ApiGateServer

Ocelot的网关是直接可以与consul服务发现配合的，而且这里我用的动态路由具体的内容请看找到ApiGateServer/ocelot.json

所有的访问链接

一般在网关这里会直接用鉴权，所以我在项目内引用了JWT,项目地址：https://github.com/jwt-dotnet/jwt

如果浏览器访问：http://localhost:10000/home/index或者http://localhost:10000/order/add就会被拦截请求，返回一个jwt的token。

实际情况应该是拦截请求返回未登录，jwt token应该通过AuthService进行登录验证后返回。这个可以自行改造。

### AuthService

AuthService内有TestController/Index使用了Polly，可以去查看。

因为我们启动了网关，所有的service都可以通过网关来请求。浏览器访问：http://localhost:10000/authservice/test/index 就可以查看效果了。也可以vs来调试启动AuthService，在TestController/Index中加入一些断点来看效果更佳。

### OrderService

这个服务内我加入来Get和Post两种方式的服务消费，就是OrderService中去访问AuthService和ProductService。

浏览器访问：http://localhost:10000/orderservice/home/test   这个是get请求的服务消费

浏览器访问：http://localhost:10000/orderservice/home/testpost 这个是post请求的服务消费

### 最后我们浏览器访问：http://localhost:9411/ 来查看链路




