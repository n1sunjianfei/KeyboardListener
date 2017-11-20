//
//  JYKeyBoardListener.m
//
//  Created by JianF.Sun on 17/9/26.
//  Copyright © 2017年 sjf. All rights reserved.
//

#import "JYKeyBoardListener.h"

#define KBL_Screen_Height [UIScreen mainScreen].bounds.size.height

NSString * const JYKeyboard_Unused_Key= @"JYKeyboard_Unused_Key";

@interface JYKeyBoardListener ()
@property (nonatomic,strong) UIView *inputView;
@property (nonatomic,strong) UIButton *resignBtn;
@property (nonatomic,strong) UIView *lastView;//记录之前一个需要处理的view，解决push,present操作时，键盘的隐藏问题
//@property (nonatomic,strong) UIViewController *unUsedVC;

@end
@implementation JYKeyBoardListener

#pragma mark - 接口方法，直接调用即可
+ (void)useJYKeyboardListener{
    
    [JYKeyBoardListener shareJYKeyBoardListener];
}
+ (void)unUsedIn:(UIViewController*)viewController{
    
    JYKeyBoardListener *manager = [JYKeyBoardListener shareJYKeyBoardListener];
    [[NSUserDefaults standardUserDefaults] setValue:[manager getMemory:viewController] forKey:JYKeyboard_Unused_Key];
}

#pragma mark - 单例

+ (instancetype)shareJYKeyBoardListener {
    
    static JYKeyBoardListener *jyKeyBoardListener = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jyKeyBoardListener = [[JYKeyBoardListener alloc] init];
        // 监听键盘

        [[NSNotificationCenter defaultCenter] addObserver:jyKeyBoardListener selector:@selector(keyboardWillShowAction:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:jyKeyBoardListener selector:@selector(keyboardWillHideAction:) name:UIKeyboardWillHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:jyKeyBoardListener selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:jyKeyBoardListener selector:@selector(enterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    });
    
    return jyKeyBoardListener;
}


#pragma mark - 键盘显示和隐藏的监听方法
/**
 *  键盘即将弹出
 */
- (void)keyboardWillShowAction:(NSNotification *)note{
    
    if ([self currentMemory]!=nil&&[[self currentMemory] isEqualToString:[self getMemory:[self topViewController]]]) {
        [self addResignBtn:[self topViewController].view];
        return;
    }else{
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:JYKeyboard_Unused_Key];
    }
    
    //结束时键盘的frame
    CGRect endF = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //键盘高度
    CGFloat keyboardH = endF.size.height;
    //键盘弹出需要的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //当前的view
    UIView *firstRspView = [self findFirstResponsderView];
    
    if (firstRspView==nil) {
        //        NSLog(@"为空");
        return ;
    }
    //找到输入框
    [self findSubView:firstRspView];

    //获取输入框相对于当前展示的最底层的那个view的frame
    CGRect inputFrame = [self getAbsoluteFrame:self.inputView];
    //
    CGFloat difH = CGRectGetMaxY(inputFrame)-(KBL_Screen_Height-keyboardH);
    // 2.动画
    [UIView animateWithDuration:duration animations:^{
        
        if (difH>0) {
            
            firstRspView.transform = CGAffineTransformMakeTranslation(0,-difH);
            
        }else{
            firstRspView.transform = CGAffineTransformIdentity;
            
        }
        _lastView = firstRspView;
    }completion:^(BOOL finished) {
        [self addResignBtn:firstRspView];

    } ];
}
/**
 *  键盘即将隐藏
 */
- (void)keyboardWillHideAction:(NSNotification *)note{
    
    //判断当前控制器是否被禁用
    if ([self currentMemory]!=nil&&[[self currentMemory] isEqualToString:[self getMemory:[self topViewController]]]) {
        
        return;
    }else{
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:JYKeyboard_Unused_Key];
    }
    // 1.键盘弹出需要的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIView *firstRspView = [self findFirstResponsderView];

    if(firstRspView==nil){
        return;
    }
    if (_lastView&&_lastView!=firstRspView) {//处理跳转时恢复之前的，push之前必须

        _lastView.transform = CGAffineTransformIdentity;
        _lastView = nil;
        return;
    }
    // 2.动画
    [UIView animateWithDuration:duration animations:^{
        firstRspView.transform = CGAffineTransformIdentity;
        
    }completion:^(BOOL finished) {

    }];

}


#pragma mark - 前台后台切换处理
- (void)enterBackground:(NSNotification*)note{
    [[self findFirstResponsderView] endEditing:YES];
}
- (void)enterForeground:(NSNotification*)note{
    
}
#pragma mark - 隐藏键盘按钮
- (void)addResignBtn:(UIView*)firstRspView{
    if (self.resignBtn) {
        [self.resignBtn removeFromSuperview];
    }
    self.resignBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.resignBtn.backgroundColor = [UIColor clearColor];
    [self.resignBtn addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    self.resignBtn.frame = firstRspView.bounds;
    [firstRspView addSubview:self.resignBtn];
    [firstRspView sendSubviewToBack:self.resignBtn];
}
- (void)hideKeyboard{
    [[self findFirstResponsderView] endEditing:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.resignBtn removeFromSuperview];

    });
}
#pragma mark - 其他辅助性方法
/**
 查找根控制器的view

 @return return FirstResponsderView
 */
- (UIView*)findFirstResponsderView{
    
    UIViewController *returnVC;
    
    //查找当前的根控制器
    returnVC = [self topViewController];
    if (returnVC) {
        return returnVC.view;
    }else{
        return nil;
    }
}
// 获取当前屏幕显示的ViewController
- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}


/*
 获取输入框的相对于根控制器view的frame
 */
- (CGRect)getAbsoluteFrame:(UIView*)view{
    
    UIView *mainView = [self findFirstResponsderView];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect rect=[view convertRect: view.bounds toView:mainView];
    //处理导航栏问题
    if (CGRectGetHeight(mainView.bounds)<CGRectGetHeight(window.bounds)) {
        rect.origin.y += CGRectGetHeight(window.bounds)-CGRectGetHeight(mainView.bounds);
    }
    //滚动视图返回的frame去掉scrollView.contentOffset.y
    if ([mainView isKindOfClass:[UIScrollView class]]||[mainView isKindOfClass:[UITableView class]]||[mainView isKindOfClass:[UIWebView class]]) {
        UIScrollView *scrollView = (UIScrollView*)mainView;
        rect.origin.y -=scrollView.contentOffset.y;
        if (CGRectGetMaxY(rect)>KBL_Screen_Height) {//输入框没有完全显示出来
            
            //去掉屏幕外的高度值
            rect.origin.y-=CGRectGetMaxY(rect)-KBL_Screen_Height;
        }
    }
    
    return rect;
}

/*
 递归法
 找到输入框
 */
- (void)findSubView:(UIView*)view{
    
    for (UIView *subView in view.subviews){

        if ([subView isFirstResponder]) {
//            NSLog(@"找到输入框");
            self.inputView = subView;
        }else{
            [self findSubView:subView];
        }
    }
}


- (NSString*)getMemory:(UIViewController*)vc{
    //控制器名称+内容的内存地址+view的内容地址
    return [NSString stringWithFormat:@"jykeyboard%@%p%p",NSStringFromClass([vc class]),vc,vc.view];
}
- (NSString*)currentMemory{
    return [[NSUserDefaults standardUserDefaults] valueForKey:JYKeyboard_Unused_Key];
}
@end
