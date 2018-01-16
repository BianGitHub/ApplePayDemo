//
//  ViewController.m
//  ApplePayDemo
//
//  Created by 边雷 on 2017/6/14.
//  Copyright © 2017年 Mac-b. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>

@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    label.center = self.view.center;
    label.text = @"商品";
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor blueColor];
    [self.view addSubview:label];
    
    // 判断设备是否支持applePay
    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        
        NSLog(@"此设备不支持Apple Pay");
    } else if(![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa,PKPaymentNetworkChinaUnionPay]]){  // 判断设备是否已经绑定银联卡或者visa卡
        
        PKPaymentButton *btn = [PKPaymentButton buttonWithType:PKPaymentButtonTypeSetUp style:PKPaymentButtonStyleWhiteOutline];
        btn.frame = CGRectMake(self.view.bounds.size.width / 2 - 50, self.view.bounds.size.height - 60, 100, 40);
        [btn addTarget:self action:@selector(jump) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }else {
        PKPaymentButton *btn = [PKPaymentButton buttonWithType:PKPaymentButtonTypeBuy style:PKPaymentButtonStyleBlack];
        btn.frame = CGRectMake(self.view.bounds.size.width / 2 - 50, self.view.bounds.size.height - 60, 100, 40);
        [btn addTarget:self action:@selector(buy) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}


- (void)jump {
    
    PKPassLibrary *pl = [PKPassLibrary new];
    [pl openPaymentSetup];
}

- (void)buy {
    NSLog(@"可以支付");
    /**
     一般支付分两步:
     1.创建一个支付请求
     2.验证用户的支付授权
     */
    
    // 创建一个支付请求
    PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
    
    // 1. 配置 货币代码 以及 国家代码
    request.countryCode = @"CN";
    request.currencyCode = @"CNY";
    
    // 2. 配置请求支持的支持网络
    request.supportedNetworks = @[PKPaymentNetworkChinaUnionPay,PKPaymentNetworkVisa];
    
    // 3. 配置商户的处理方式
    request.merchantCapabilities = PKMerchantCapability3DS;
    
    // 4. 配置购买的商品列表 ---- 支付列表最后一个代表汇总
    NSDecimalNumber *dn1 = [[NSDecimalNumber alloc] initWithString:@"10.0"];
    PKPaymentSummaryItem *item1 = [PKPaymentSummaryItem summaryItemWithLabel:@"苹果6(商品名称)" amount:dn1];
    NSDecimalNumber *dn2 = [[NSDecimalNumber alloc] initWithString:@"10.0"];
    PKPaymentSummaryItem *item2 = [PKPaymentSummaryItem summaryItemWithLabel:@"苹果6(商品名称)" amount:dn2];
    NSDecimalNumber *dn3 = [[NSDecimalNumber alloc] initWithString:@"20.0"];
    PKPaymentSummaryItem *item3 = [PKPaymentSummaryItem summaryItemWithLabel:@"苹果公司" amount:dn3];
    request.paymentSummaryItems = @[item1, item2,item3];
    
    // 5. 配置商家ID
    request.merchantIdentifier = @"merchant.applePayDemoBL.com";
    
    //------------配置请求的附加项
    // 1. 是否显示发票收货地址   显示哪些选项
    request.requiredBillingAddressFields = PKAddressFieldAll;
    // 2. 是否显示快递收货地址   显示哪些选项
    request.requiredShippingAddressFields = PKAddressFieldAll;
    // 3. 配置快递方式
    NSDecimalNumber *dnSF = [[NSDecimalNumber alloc] initWithString:@"10.0"];
    PKShippingMethod *method1 = [PKShippingMethod summaryItemWithLabel:@"顺丰快递" amount:dnSF];
    method1.identifier = @"YD"; //--需要配置快递的标记--不设置会崩溃
    method1.detail = @"顺丰到家";   //--快递信息描述--
    
    NSDecimalNumber *dnYD = [[NSDecimalNumber alloc] initWithString:@"1.0"];
    PKShippingMethod *method2 = [PKShippingMethod summaryItemWithLabel:@"韵达快递" amount:dnYD];
    method2.identifier = @"SF";
    method2.detail = @"韵达到家";
    request.shippingMethods = @[method1,method2];
    
    // 配置快递的类型
    request.shippingType = PKShippingTypeServicePickup;
    // 添加一些附加数据
    request.applicationData = [@"buyID==1234" dataUsingEncoding:NSUTF8StringEncoding];
    
    
    
    // 验证用户的支付授权
    PKPaymentAuthorizationViewController *pvc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    pvc.delegate = self;
    [self presentViewController:pvc animated:YES completion:nil];
}

#pragma mark -PKPaymentAuthorizationViewControllerDelegate
// 必须实现的两个代理方法
/**
 如果当用户授权成功 就会调用这个方法
 参数1: 授权控制器
 参数2: 支付对象
 参数3: 系统给定的一个回调代码块, 我们需要执行这个代码块, 来告诉系统当前的支付状态是否成功
 */
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion {
    
    // 一般在此处, 拿到支付信息, 发送给服务器处理, 处理完毕之后服务器返回一个状态, 告诉客户端是否支付成功, 然后客户端进行处理
    BOOL isSuccess = YES;
    
    
    if (isSuccess) {
        completion(PKPaymentAuthorizationStatusSuccess);
    } else {
        completion(PKPaymentAuthorizationStatusFailure);
    }
}

// 当用户授权成功, 或者取消授权时调用此方法
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    
    NSLog(@"授权结束");
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
