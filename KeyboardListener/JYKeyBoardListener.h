//
//  JYKeyBoardListener.h
//
//  Created by JianF.Sun on 17/9/26.
//  Copyright © 2017年 sjf. All rights reserved.
//
/*
 功能：
 1、输入框被键盘遮挡时，整个view上移（此时输入框在键盘上方）
 2、键盘弹出时，添加一个按钮负责隐藏键盘
 3、禁止某控制器使用JYKeyBoardListener
 使用：
 1、引入JYKeyBoardListener.h
 2、程序启动时：[JYKeyBoardListener useJYKeyboardListener];
 3、某些控制器不想使用时：[JYKeyBoardListener unUsedIn:vc];
 处理：
 1、监听键盘 显示，隐藏，退到后台，进入前台；
 2、获取当前顶层控制器；
 3、获取当前编辑的输入框在self.view中的frame；
 4、键盘显示隐藏时动画；
 5、隐藏键盘的按钮添加
 6、处理push、present时键盘的显示隐藏问题（切记push之前，代码endEditing,因为push操作系统不会自动退出键盘）
 7、处理self.view比屏幕小的问题（即self.view没有伸缩到导航栏底部）
 8、处理输入框显示在屏幕中不完整的情况
 
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface JYKeyBoardListener : NSObject
//程序启动时调用
+ (void)useJYKeyboardListener;
//在viewcontroller中禁止使用JYKeyBoardListener
+ (void)unUsedIn:(UIViewController*)viewController;
@end
