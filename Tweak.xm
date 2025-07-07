#import <UIKit/UIKit.h>

@interface CNGNumberDotView : UIView
@end
@interface CNGPackageListYourLikeView : UIView
@end
@interface CNHomeBackgroundView : UIView
@end
@interface CNTabBarGroupView : UIView
@end
@interface CNLogisticsRecommendView : UIView
@end
@interface CNGHomeHeadSearchRollTextView : UIView
@end
@interface CNAdRecommendHeaderSearchView : UIView
@end
@interface CNGShopBubbleNewV2View : UIView
@end
@interface CNTabBarViewController : UIViewController
@property (nonatomic, assign) NSInteger cnSelectedIndex;
- (void)setCnSelectedIndex:(NSInteger)cnSelectedIndex;
- (void)updateHomeButtonState;
@end
@interface UITabBarButton : UIView
@end

// 隐藏首页右上方消息小红点
%hook CNGNumberDotView

- (void)layoutSubviews {
    %orig;
    UIView *pview = self.superview;
    UIView *gpview = pview.superview;
    UIView *ggpview = gpview.superview;
    if (
        [pview isKindOfClass:%c(UIButton)] && 
        [gpview isKindOfClass:%c(UIView)] && 
        [ggpview isKindOfClass:%c(CNGHomeHead860View)]
        ) {
        [self removeFromSuperview];
    }
}

%end

// 隐藏首页在途包裹下方 大家都在逛
%hook CNGPackageListYourLikeView

- (void)layoutSubviews {
	%orig;
	self.hidden = YES;
}

%end

// 隐藏首页蓝色背景图(因为去掉大家都在逛之后会有显示问题)
%hook CNHomeBackgroundView

- (void)layoutSubviews {
    %orig;
    for (UIView *subview in self.subviews) {
        if (![subview isKindOfClass:%c(CNHomeBackgroundImageView)]) {
            subview.hidden = YES;
        }
    }
}

%end

// 隐藏包裹详情页下方
%hook CNLogisticsRecommendView

- (void)layoutSubviews {
    %orig;
    self.hidden = YES;
}

%end

// 隐藏首页搜索栏填充词
%hook CNGHomeHeadSearchRollTextView

- (void)layoutSubviews {
    %orig;
    [self removeFromSuperview];
}

%end

// 隐藏下滑顶栏大家都在逛
%hook CNAdRecommendHeaderSearchView

- (void)layoutSubviews {
    %orig;
    UIView *pview = self.superview;
    for(UIView *subview in pview.subviews) {
        if ([subview isKindOfClass:%c(UIImageView)]) {
            [subview removeFromSuperview];
            break;
        }
    }
}

%end

// 隐藏每日首次查询积分动画
%hook CNGShopBubbleNewV2View

- (void)layoutSubviews {
    %orig;
    [self removeFromSuperview];
}

%end

// 禁用首页点击下滑
%hook CNTabBarViewController

// 通用方法：根据当前选中索引禁用或启用首页按钮
%new
- (void)updateHomeButtonState {
    NSInteger currentIndex = self.cnSelectedIndex;
    // containerView就是UILayoutContainerView，直接在其子视图中找UITabBar
    UIView *containerView = self.viewIfLoaded;
    UITabBar *tabBar = nil;
    // 直接在containerView的子视图中找UITabBar
    for (UIView *subview in containerView.subviews) {
        if ([subview isKindOfClass:%c(UITabBar)]) {
            tabBar = (UITabBar *)subview;
            break;
        }
    }
    // 根据当前索引禁用或启用首页tab按钮
    if (tabBar && tabBar.subviews.count > 0) {
        NSArray *buttons = [tabBar.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject isKindOfClass:%c(UITabBarButton)];
        }]];
        if (buttons.count > 0) {
            UITabBarButton *firstButton = buttons[0];
            firstButton.userInteractionEnabled = (currentIndex != 0);
        }
    }
}

// 在视图布局完成后重新检查按钮状态（处理初始化、深浅色切换等重新布局情况）
- (void)viewDidLayoutSubviews {
    %orig;
    // 延迟执行，确保所有子视图都已经布局完成
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateHomeButtonState];
    });
}

- (void)setCnSelectedIndex:(NSInteger)cnSelectedIndex {
    %orig(cnSelectedIndex);
    // 使用通用方法更新首页按钮状态
    [self updateHomeButtonState];
}

%end

// 首页tab栏精简重新布局逻辑
%hook UITabBar

- (void)layoutSubviews {
    %orig;
    NSMutableArray *buttons = [NSMutableArray array];
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:%c(UITabBarButton)]) {
            [buttons addObject:subview];
        }
    }
    if (buttons.count >= 2) {
        // 移除中间的按钮
        for (NSInteger i = 1; i < buttons.count - 1; i++) {
            UIView *button = buttons[i];
            [button removeFromSuperview];
        }
        // 重新排布剩余的按钮
        CGFloat tabBarWidth = self.bounds.size.width;
        UIView *firstButton = buttons[0];
        UIView *lastButton = buttons[buttons.count - 1];
        // 按照1:1的比例分配屏幕空间，第一个按钮在1/4处，最后一个按钮在3/4处
        CGFloat firstButtonCenterX = tabBarWidth * 0.25;
        CGFloat lastButtonCenterX = tabBarWidth * 0.75;
        // 调整第一个按钮位置
        CGRect firstFrame = firstButton.frame;
        firstFrame.origin.x = firstButtonCenterX - firstFrame.size.width / 2;
        firstButton.frame = firstFrame;
        // 调整最后一个按钮位置
        CGRect lastFrame = lastButton.frame;
        lastFrame.origin.x = lastButtonCenterX - lastFrame.size.width / 2;
        lastButton.frame = lastFrame;
    }
}

%end

// 隐藏图标&重新布局
%hook CNTabBarGroupView

- (void)layoutSubviews {
    %orig;
    NSMutableArray *labelImagePairs = [NSMutableArray array];
    UIView *switchIconView = nil;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:%c(UILabel)] || [subview isKindOfClass:%c(UIImageView)]) {
            [labelImagePairs addObject:subview];
        } else if ([subview isKindOfClass:%c(CNTabBarSwitchIconView)]) {
            switchIconView = subview;
        }
    }
    if (labelImagePairs.count >= 4) {
        // 移除中间的元素
        for (NSInteger i = 2; i < labelImagePairs.count - 2; i++) {
            UIView *view = labelImagePairs[i];
            [view removeFromSuperview];
        }
        // 重新排布剩余的两对元素
        CGFloat screenWidth = self.bounds.size.width;
        // 按照1:2:1的比例分配屏幕空间
        CGFloat firstCenterX = screenWidth * 0.25;  // 第一对元素位于1/4处
        CGFloat secondCenterX = screenWidth * 0.75; // 第二对元素位于3/4处
        // 第一对元素（索引0和1）
        UIView *firstLabel = labelImagePairs[0];
        UIView *firstImage = labelImagePairs[1];
        // 第二对元素（索引count-2和count-1）
        UIView *secondLabel = labelImagePairs[labelImagePairs.count - 2];
        UIView *secondImage = labelImagePairs[labelImagePairs.count - 1];
        // 调整第一对元素位置
        CGRect firstLabelFrame = firstLabel.frame;
        CGRect firstImageFrame = firstImage.frame;
        firstLabelFrame.origin.x = firstCenterX - firstLabelFrame.size.width / 2;
        firstImageFrame.origin.x = firstCenterX - firstImageFrame.size.width / 2;
        firstLabel.frame = firstLabelFrame;
        firstImage.frame = firstImageFrame;
        // 调整switchIconView位置，与第一对元素对齐
        if (switchIconView) {
            CGRect switchFrame = switchIconView.frame;
            switchFrame.origin.x = firstCenterX - switchFrame.size.width / 2;
            switchIconView.frame = switchFrame;
        }
        // 调整第二对元素位置
        CGRect secondLabelFrame = secondLabel.frame;
        CGRect secondImageFrame = secondImage.frame;
        secondLabelFrame.origin.x = secondCenterX - secondLabelFrame.size.width / 2;
        secondImageFrame.origin.x = secondCenterX - secondImageFrame.size.width / 2;
        secondLabel.frame = secondLabelFrame;
        secondImage.frame = secondImageFrame;
    }
}

%end