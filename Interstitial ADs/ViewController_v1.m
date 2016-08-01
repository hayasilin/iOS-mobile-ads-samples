//
//  ViewController.m
//  Components
//
//  Created by Kuan-Wei Lin on 7/11/16.
//  Copyright © 2016 Kuan-Wei Lin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) UIActivityIndicatorView *webViewActivityIndicatorView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    UIImage* imgClose = [UIImage imageNamed:@"close.png"];
    CGRect rc = [UIScreen mainScreen].bounds;
    int nX = rc.size.width - imgClose.size.width - 20;
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(nX, 20, imgClose.size.width, imgClose.size.height)];
    [closeButton addTarget:self action:@selector(closeWebView) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImage:imgClose forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.3 delay:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        NSLog(@"Show close btn after delay");
        [self.webView addSubview:closeButton];
    } completion:^(BOOL finished) {
        
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
    
    self.webViewActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.webView.frame), CGRectGetMidY(self.webView.frame), 50, 50)];
    self.webViewActivityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.webViewActivityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"webViewDidFinishLoad");
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self.webViewActivityIndicatorView stopAnimating];
    self.webViewActivityIndicatorView.hidesWhenStopped = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"didFailLoadWithError = %@", error.description);
}


@end
