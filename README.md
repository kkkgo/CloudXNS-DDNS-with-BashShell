# CloudXNS-DDNS-with-BashShell
利用CloudXNS的API和shell脚本搭建自己的动态域名服务。如果你使用这个脚本，建议点watch以获取更新通知。  
>用于CloudXns的Powershell脚本另见：  
https://github.com/lixuy/CloudXNS-DDNS-with-PowerShell  
用于DNSPOD的Shell脚本另见：  
https://github.com/lixuy/CloudXNS-DDNS-with-BashShell  
## 使用方法
本脚本分为两个版本，一个是获取自己外网ip的版本cloudxns_ddns.sh，一个是直接获取自己网卡设备上的ip的版本cloudxns_ddns_line.sh（对于多拨或者路由器网关用户适用）。
### 获取API的API_KEY和SECRET_KEY
APi的API_KEY和SECRET_KEY可以在用户中心开启获取：  
![获取API](https://www.cloudxns.net/Public/Uploads/Article/201506/5577aca518efa.jpg)
### **cloudxns_ddns.sh**
#### 参数说明  
参数|填写说明
:-:|:-
|API_KEY | 在个人中心后台的安全设置里面获取ID|
SECRET_KEY|在个人中心后台的安全设置里面获取Token
DOMAIN| 用作动态DNS的域名，例如```ddns.mydomain.com```，```home.example.com```，注意所填写的域名必须在你的账号下并且有存在解析记录。
CHECKURL|用于检查自己的外网IP是什么的网址，注释掉该参数会跳过所有检查（仅验证域名记录是否存在）直接执行更新记录（会导致高频率调用更新）；建议的备选CHECKURL：```http://ip.3322.org``` ```http://myip.ipip.net``` ```http://ip.xdty.org```
OUT|指定使用某个网卡设备进行联网通信（默认被注释掉）。注意，一些系统的负载均衡功能可能会导致该参数无效。推荐使用```ip a```命令或者```ifconfig```命令查看网卡设备名称。

#### **推荐的部署方法**
把如上所述的参数填好即可。  
本脚本没有自带循环，因为linux平台几乎都有Crontab（计划任务），利用计划任务可以实现开机启动、循环执行脚本、并设定循环频率而无需常驻后台。  
>**命令参考**  
假设脚本已经填写好参数并加了可执行权限（```chmod +x ./cloudxns_ddns.sh```），并位于```/root/cloudxns_ddns.sh```:  
新建计划任务输入```crontab -e```  
按a进入编辑模式，输入   
 ```*/1 * * * * /root/cloudxns_ddns.sh &> /dev/null```  
意思是每隔一分钟执行/root/cloudxns_ddns.sh并屏蔽输出日志。当然，如果你需要记录日志可以直接重定向至保存路径。 
然后按Esc，输入:wq回车保存退出即可。  
更多关于Crontab的使用方法此处不再详述。  
另外对于一些带有Web管理界面嵌入式系统（比如openwrt），有图形化的计划任务菜单管理，可以直接把脚本粘贴进去。

#### 工作过程
1、用CHECKURL检查自己的外网ip和本地解析记录是否相同，相同则退出；  
2、使用API获取域名在Dnspod平台的ip记录，如果ip记录和本地解析记录或者外网解析记录相同则退出；  
3、执行DNS更新，并返回执行结果。
#### 注意事项
本脚本**不会**自动创建子域名，请务必先到后台添加一个随意的子域名A记录，否则会提示Host record does not exist 

### **cloudxns_ddns_line.sh**
仅说明与上面脚本参数不同的地方。  
因该脚本是用于获取网卡设备ip，所以没有CHECKURL参数。  
#### 参数说明
参数|填写说明
:-:|:-
|DEV | 从网卡设备（例如eht0）上获取ip，并与DNS记录比对更新。推荐使用```ip a```命令```ifconfig```命令查看网卡设备名称。  

### 日志参考
现象|说明
:-|:-
[DNS IP]为Get Domain Failed|本地DNS解析出现问题（断网、DNS服务器不工作、域名记录错误）
[URL IP]为空|访问CHECKURL失败，检查网络访问CHECKURL是否正常
Host record does not exist|不存在该域名或者该主机记录（本脚本**不会**自动创建子域名，请务必先到后台添加一个随意的子域名A记录）
[URL IP]或者[DEV IP]上次已经更新成功但是DNSIP还是不一样|DNS有缓存，DNS记录是已经更新，属正常现象
### **关于**
https://03k.org/cloudxns-ddns-with-bashshell.html
