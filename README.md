# ApplePayDemo
苹果支付ApplePay

一. 首先集成线上支付ApplePay需要两个步骤: 1.配置支付环境   2. 代码实现
    可查看苹果官方文档查看集成方式:https://developer.apple.com/apple-pay/get-started/cn/
    
    
    1. 配置支付环境
        (1).创建一个工程, 确定好对应的BundleID
            BundleID在下面将要用到
        
        (2).注册并配置一个商业表示符
             a.登录开发者中心, 进入证书配置栏目, 添加App ID;
                  添加App ID时, 选择明确的App ID(Explicit App ID), 并勾选App Service中的Apple Pay服务;
                  
             b.配置Merchant ID
                  配置完Merchant ID, 再次点击App ID进行编辑, 编辑ApplePay功能, 进行选择刚才创建的Merchant ID(可选择多个) 
                  
             c.给Merchant ID配置证书, 并下载证书安装到钥匙串
                  点击Merchant ID创建证书, 使用钥匙串生成csr文件后 choose File 选择生成证书, 点击DownLoad下载证书, 安装都本地钥匙串
                  
             d.检查安装到钥匙串中的证书是否有效
                  进入钥匙串查看刚才安装的证书是否有效, 如果显示 "此证书是由未知颁发机构签名的" 表示本地的根证书或中级证书过期
                  ￼钥匙串-->系统-->证书----如果显示此证书已过期, 需要重新下载证书
                    苹果根证书下载网址:
                    https://www.apple.com/certificateauthority/
                    下载 Apple Intermediate Certificates 中的 WWDR Certificate (Expiring 02/07/23)   点击即可下载
                    下载完双击安装
                  安装完, 再次查看证书, 如果还是显示 "此证书是由未知颁发机构签名的" 则还需下载CA-G2证书
                  下载 Apple Intermediate Certificates 中的 Worldwide Developer Relations - G2 Certificate  点击即可下载
                  
             e.绑定Merchart ID到App ID
             
        (3).配置Xcode项目, 开启Applepay功能
            首先要把项目配置成8.0
