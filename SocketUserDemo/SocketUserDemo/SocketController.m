//
//  SocketController.m
//  SocketUserDemo
//
//  Created by wbx_iMac on 2017/8/23.
//  Copyright © 2017年 wbx_iMac. All rights reserved.
//

#import "SocketController.h"
#import "GCDAsyncSocket.h"


@interface SocketController ()<GCDAsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *portField;

@property (weak, nonatomic) IBOutlet UITextField *ipField;

@property (weak, nonatomic) IBOutlet UITextField *msgField;

@property (weak, nonatomic) IBOutlet UILabel *receiveLabel;

@property(nonatomic, strong) GCDAsyncSocket *clientSocket;

@end

@implementation SocketController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

}

- (IBAction)beginBtnClickEvent:(id)sender {
 
//    [self.clientSocket connectToHost:self.ipField.text onPort:self.portField.text.intValue withTimeout:-1 error:&error];
    
    [self.clientSocket connectToHost:self.ipField.text onPort:self.portField.text.integerValue viaInterface:nil withTimeout:-1 error:nil];

    NSLog(@"ip：%@,端口：%@",self.ipField.text,self.portField.text);
//
//    NSString *loginStr = @"iam:I am login!";
//    
//    NSData *loginData = [loginStr dataUsingEncoding: NSUTF8StringEncoding];
//    
//    [_clientSocket writeData:loginData withTimeout:-1 tag:0];
}

- (IBAction)senderBtnClickEvent:(id)sender {
    NSData *data = [self.msgField.text dataUsingEncoding:NSUTF8StringEncoding];

    //tag：消息标记,withTimeout -1 :无穷大
    [self.clientSocket writeData:data withTimeout:-1 tag:0];
}
- (IBAction)receiveBtnClickEvent:(id)sender {
    [self.clientSocket readDataWithTimeout:11 tag:0];
}
#pragma mark - GCDAsynSocket Delegate
//连接成功
- (void)socket:(GCDAsyncSocket*)sock didConnectToHost:(NSString*)host port:(uint16_t)port{
    
    [self showMessageWithStr:@"system:连接成功"];
    
    NSLog(@"system:连接成功");

    [self.clientSocket readDataWithTimeout:-1 tag:0];
}
//断开连接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    if (err) {
        [self showMessageWithStr:@"system:连接失败"];
        NSLog(@"system:连接失败");
    }else{
        [self showMessageWithStr:@"system:正常断开"];
        NSLog(@"system:正常断开");
    }
}
//数据发送成功
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"%s",__func__);
    [self showMessageWithStr:@"system:发送成功"];
    //发送完数据手动读取
    [sock readDataWithTimeout:-1 tag:tag];
}
//收到消息
- (void)socket:(GCDAsyncSocket*)sock didReadData:(NSData*)data withTag:(long)tag{
    
    NSString*text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    [self showMessageWithStr:text];
    
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}


- (void)showMessageWithStr:(NSString *)str
{
    NSLog(@"%@",str);
    self.receiveLabel.text = [self.receiveLabel.text stringByAppendingFormat:@"%@\n", str];
}

@end
