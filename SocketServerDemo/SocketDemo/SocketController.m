//
//  SocketController.m
//  SocketDemo
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

@property (weak, nonatomic) IBOutlet UIButton *beginBtn;

@property (weak, nonatomic) IBOutlet UIButton *senderBtn;

@property (weak, nonatomic) IBOutlet UIButton *receiveBtn;

@property (weak, nonatomic) IBOutlet UITextView *receiveLabel;

//服务器socket（开放端口，监听客户端socket的链接）
@property(nonatomic, strong) GCDAsyncSocket *serverSocket;

//保护客户端socket
@property (strong, nonatomic) GCDAsyncSocket *clientSocket;


@end
@implementation SocketController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化服务器socket,在主线程回调
    self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //初始化客户端socket
//    _clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [_beginBtn addTarget:self action:@selector(beginBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [_senderBtn addTarget:self action:@selector(senderBtnClick) forControlEvents:UIControlEventTouchUpInside];

    [_receiveBtn addTarget:self action:@selector(receiveBtnClick) forControlEvents:UIControlEventTouchUpInside];

}
#pragma mark -- touchEvent
- (void)beginBtnClick
{
    //2、开放端口
    
    NSError*error =nil;
    
    BOOL result = [self.serverSocket acceptOnPort:self.portField.text.integerValue error:&error];
    
    if(result && error ==nil) {
    
        [self showMessageWithStr:@"system:服务器开启成功"];
    }
    else
    {
        [self showMessageWithStr:@"system:服务器开启失败"];
    }
}
- (void)senderBtnClick
{
    NSData *data = [self.msgField.text dataUsingEncoding:NSUTF8StringEncoding];
    
    //tag:消息标记，withTimeout -1:无穷大，一直等
    [_clientSocket writeData:data withTimeout:-1 tag:0];
}
- (void)receiveBtnClick
{
    [self.clientSocket readDataWithTimeout:11 tag:0];
}

#pragma mark - 服务器socket Delegate
- (void)socket:(GCDAsyncSocket*)sock didAcceptNewSocket:(GCDAsyncSocket*)newSocket{
    
    //sock为服务端的socket，服务端的socket只负责客户端的连接，不负责数据的读取。   newSocket为客户端的socket
    
    //保存客户端的socket
    _clientSocket = newSocket;
    
    NSLog(@"服务端的socket %p 客户端的socket %p",sock,newSocket);

    [self showMessageWithStr:@"链接成功"];
    
    [self showMessageWithStr:[NSString stringWithFormat:@"服务器地址：%@ -端口：%d", newSocket.connectedHost, newSocket.connectedPort]];
    
    [newSocket readDataWithTimeout:-1 tag:0];
    
}
//服务器写数据给客户端
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"%s",__func__);
    [sock readDataWithTimeout:-1 tag:100];
}
//收到消息
- (void)socket:(GCDAsyncSocket*)sock didReadData:(NSData*)data withTag:(long)tag{
    //sock为客户端的socket
    //接收到数据
    NSString *receiverStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self showMessageWithStr:receiverStr];
    
//    // 把回车和换行字符去掉，接收到的字符串有时候包括这2个，导致判断quit指令的时候判断不相等
//    receiverStr = [receiverStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//    receiverStr = [receiverStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    /*
    //判断是登录指令还是发送聊天数据的指令。这些指令都是自定义的
    //登录指令
    if([receiverStr hasPrefix:@"iam:"]){
        // 获取用户名
        NSString *user = [receiverStr componentsSeparatedByString:@":"][1];
        // 响应给客户端的数据
        NSString *respStr = [user stringByAppendingString:@"has joined"];
        [sock writeData:[respStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    }
    //聊天指令
    if ([receiverStr hasPrefix:@"msg:"]) {
        //截取聊天消息
        NSString *msg = [receiverStr componentsSeparatedByString:@":"][1];
        [sock writeData:[msg dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    }
    //quit指令
    if ([receiverStr isEqualToString:@"quit"]) {
        //断开连接
        [sock disconnect];
        //移除socket
        _clientSocket = nil;
    }
    */
    NSLog(@"%s",__func__);
}




- (void)showMessageWithStr:(NSString *)str
{
    NSString * tmpStr = _receiveLabel.text;
    
    tmpStr = [tmpStr stringByAppendingString:[NSString stringWithFormat:@"\n%@",str]];
    
    [_receiveLabel setText:tmpStr];
}



@end
