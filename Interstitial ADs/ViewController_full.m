//
//  ViewController.m
//  Components
//
//  Created by Kuan-Wei Lin on 7/11/16.
//  Copyright © 2016 Kuan-Wei Lin. All rights reserved.
//

#import "ViewController.h"

#define ORIENTATION_LANDSCAPE_RIGHT @"UIInterfaceOrientationLandscapeRight"
#define ORIENTATION_LANDSCAPE_LEFT @"UIInterfaceOrientationLandscapeLeft"
#define ORIENTATION_PORTRAIT @"UIInterfaceOrientationPortrait"

@interface ViewController () <UIWebViewDelegate>

/*! 顯示Interstitial的webView */
@property (strong, nonatomic) UIWebView *webView;

/*! 關閉webView的Button */
@property (strong, nonatomic) UIButton *closeButton;

/*! 旋轉螢幕的Button */
@property (strong, nonatomic) UIButton *rotateButton;

/*! 顯示webView讀取中的Custom activityIndicatorView*/
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

/*! Custom activityIndicatorView的背景，範圍包含整個iPhone螢幕*/
@property (strong, nonatomic) UIView *containerView;

/*! 包住Custom activityIndicatorView的深色底，讓activityIndicatorView可以清楚顯示出來 */
@property (strong, nonatomic) UIView *loadingView;

//MARK: - Orientation
@property (strong, nonatomic) NSArray *appSupportInterfaceOrientationsArray;
@property (nonatomic) BOOL isRotate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    //存入iPhone的各種轉向選擇
    self.appSupportInterfaceOrientationsArray = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
    NSLog(@"arrayAppSupportInterfaceOrientations = %@", self.appSupportInterfaceOrientationsArray);
    
    //監聽iPhone的轉向
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (IBAction)showInterstitialAd:(UIButton *)sender {
    
    UIViewController *vc = [[UIViewController alloc] init];
    
    self.webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    self.webView.delegate = self;
    self.webView.scrollView.scrollEnabled = NO;
    
    NSString *url=@"https://www.google.com";
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    
    [self.webView loadRequest:nsrequest];
    [vc.view addSubview:self.webView];
    [self presentViewController:vc animated:YES completion:nil];
    
    //Close button
    UIImage* imgClose = [UIImage imageNamed:@"close.png"];
    CGRect rc = [UIScreen mainScreen].bounds;
    int nX = rc.size.width - imgClose.size.width - 20;
    
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(nX, 20, imgClose.size.width, imgClose.size.height)];
    [self.closeButton addTarget:self action:@selector(closeWebView) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton setImage:imgClose forState:UIControlStateNormal];
    
    //Rotate button
    self.rotateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.rotateButton.frame = CGRectMake(20, 20, 100, 100);
    [self.rotateButton setTitle:@"Rotate" forState:UIControlStateNormal];
    [self.rotateButton addTarget:self action:@selector(rotateDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.webView addSubview:self.rotateButton];
    
    [self performSelector:@selector(addCloseBtn) withObject:nil afterDelay:3];
}

- (void)addCloseBtn{
    //TODO: - 不知為何animationWithDuration無法delay，這裡先用performSelector afterDelay，待解決
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         NSLog(@"Show close btn after delay");
                         [self.webView addSubview:self.closeButton];
                     }
                     completion:^(BOOL finished)
     {
         NSLog(@"The close btn is shown");
     }];
}

- (void)closeWebView{
    NSLog(@"closeBtn pressed");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"shouldStartLoadWithRequest URL = %@", request.URL.absoluteString);
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webViewDidStartLoad");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self startCustomActivityIndicator:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"webViewDidFinishLoad");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self stopCustomActivityIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"didFailLoadWithError = %@", error.description);
}

#pragma mark - Custom UIActivityIndicatorView
- (IBAction)startCustomActivityIndicator:(UIButton *)sender {
    
    self.containerView = [[UIView alloc] init];
    self.containerView.frame = self.view.frame;
    self.containerView.backgroundColor = [UIColor colorWithRed:200 green:200 blue:200 alpha:0.3];
    
    self.loadingView = [[UIView alloc] init];
    self.loadingView.frame = CGRectMake(0, 0, 80, 80);
    self.loadingView.center = self.view.center;
    self.loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    self.loadingView.clipsToBounds = YES;
    self.loadingView.layer.cornerRadius = 10;
    
    self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.activityIndicatorView.center = CGPointMake(self.loadingView.frame.size.width / 2, self.loadingView.frame.size.height /2);
    
    [self.loadingView addSubview:self.activityIndicatorView];
    [self.containerView addSubview:self.loadingView];

    [self.webView addSubview:self.containerView];
    
    [self.activityIndicatorView startAnimating];
}

- (void)stopCustomActivityIndicator{
    
    [self.activityIndicatorView stopAnimating];
    [self.loadingView removeFromSuperview];
    [self.containerView removeFromSuperview];
}

#pragma mark - Device rotate
- (void) viewDidRotate:(NSNotification *)notification {
    NSLog(@"viewDidRotate");
    
    UIImage* imgClose = [UIImage imageNamed:@"close.png"];
    CGRect rc = [UIScreen mainScreen].bounds;
    int nX = rc.size.width - imgClose.size.width - 20;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    //重新計算UIWebView位置跟著iPhone裝置一起轉
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         if (self.webView != nil) {
                             self.webView.frame = [UIScreen mainScreen].bounds;
                         }
                         
                         if (self.closeButton) {
                             //判斷目前狀況是Landscape還是Portrait
                             if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
                                 _closeButton.frame = CGRectMake(nX, 10, imgClose.size.width, imgClose.size.height);
                             } else {
                                 _closeButton.frame = CGRectMake(nX, 20, imgClose.size.width, imgClose.size.height);
                             }
                         }
                         
                         if (self.rotateButton) {
                             if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
                                 self.rotateButton.frame = CGRectMake(10, 10, 100, 100);
                             }else{
                                 self.rotateButton.frame = CGRectMake(20, 20, 100, 100);
                             }
                         }
                     }
                     completion:^(BOOL finished){
                         //reset the layer's frame, and re-add it to the view
                         NSLog(@"%@ setIfNotEqual end", self);
                     }];

    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationLandscapeLeft){
        NSLog(@"Landscape Left!");
    }
    if (orientation == UIDeviceOrientationLandscapeRight){
        NSLog(@"Landscape Right!");
    }
    if (orientation == UIDeviceOrientationPortrait){
        NSLog(@"Portrait Up!");
    }
}

//手動旋轉iPhone
- (void)rotateDevice {
    // strDirection 1: portrait, 0: landscape
    NSString *strDirection;
    
    //Simulate that value is given by server side
    if (self.isRotate) {
        strDirection = @"1";
        self.isRotate = NO;
    }else{
        strDirection = @"0";
        self.isRotate = YES;
    }
    NSLog(@"strDirection = %@", strDirection);
    
    int nDeviceOrientation = -1;
    
    if ( [strDirection intValue] == 0 ) {
        if ( [self.appSupportInterfaceOrientationsArray containsObject:ORIENTATION_LANDSCAPE_RIGHT] ) {
            nDeviceOrientation = UIDeviceOrientationLandscapeRight;
        }
        else if ( [self.appSupportInterfaceOrientationsArray containsObject:ORIENTATION_LANDSCAPE_LEFT] ) {
            nDeviceOrientation = UIDeviceOrientationLandscapeLeft;
        }
    } else if ( [strDirection intValue] == 1 ) {
        if ( [self.appSupportInterfaceOrientationsArray containsObject:ORIENTATION_PORTRAIT] ) {
            nDeviceOrientation = UIDeviceOrientationPortrait;
        }
    }
    
    NSLog(@"nDeviceOrientation = %i", nDeviceOrientation);
    if ( nDeviceOrientation >= 0 ) {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            
            //MARK: - One way to rotate the iPhone device
            //            NSLog(@"Using NSInvocation to transform to UIDevice Orientation %d", nDeviceOrientation);
            //            SEL selector = NSSelectorFromString(@"setOrientation:");
            //            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            //            [invocation setSelector:selector];
            //            [invocation setTarget:[UIDevice currentDevice]];
            //            [invocation setArgument:&nDeviceOrientation atIndex:2];
            //            [invocation invoke];
            
            //MARK: - Another way to rotate the iPhone device
            NSNumber *value = [NSNumber numberWithInt:nDeviceOrientation];
            [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
            
        } else {
            NSLog(@"UIDevice setOrientation does not exist!!");
        }
    }
}

@end
