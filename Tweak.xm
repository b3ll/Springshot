//
//  Tweak.xm
//  Springshot
//
//  Created by Adam Bell on 2013-12-31.
//  Copyright (c) 2014 Adam Bell. All rights reserved.
//

%config(generator=MobileSubstrate);

#import "springshot.h"

#define PREFERENCES_PATH @"/User/Library/Preferences/ca.adambell.springshot.plist"
#define PREFERENCES_CHANGED_NOTIFICATION "ca.adambell.springshot.preferences-changed"
#define PREFERENCES_ENABLED_KEY @"springshotEnabled"

static BOOL _switcherVisible = NO;
static BOOL _springshotEnabled = NO;

%hook SBAppSliderController

- (void)switcherWillBeDismissed:(BOOL)arg1 {
    _switcherVisible = NO;
    %orig;
}

- (void)switcherWasPresented:(BOOL)arg1 {
    _switcherVisible = YES;
    %orig;
}

%end

%hook SBAppSliderScrollingViewController

static NSMutableArray *itemsToRemove;

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(CGPoint *)targetContentOffset {
    %orig;

    if (_switcherVisible && _springshotEnabled) {
        NSUInteger itemIndex = [[self valueForKey:@"_items"] indexOfObject:scrollView];
        BOOL isRemovable = [self.delegate sliderScroller:scrollView isIndexRemovable:itemIndex];

        if (scrollView.contentOffset.y < -40.0 && isRemovable) {
            [itemsToRemove addObject:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_springshotEnabled && _switcherVisible) {
        if ([itemsToRemove containsObject:scrollView]) {
            __weak SBAppSliderController *scrollerDelegate = self.delegate;
            __weak SBAppSliderScrollingViewController *weakSelf = self;
            __weak UIScrollView *weakScrollView = scrollView;

            NSUInteger itemIndex = [[self valueForKey:@"_items"] indexOfObject:scrollView];
            [UIView animateWithDuration:0.4
                delay:0.0
                options: UIViewAnimationOptionCurveEaseInOut
                animations:^(){
                    weakScrollView.contentOffset = CGPointMake(0.0, scrollView.contentSize.height / 2.0);
                }
                completion:^(BOOL finished){
                    [itemsToRemove removeObject:scrollView];

                    [scrollerDelegate sliderScroller:weakSelf itemWantsToBeRemoved:itemIndex];
                }];

            DebugLog(@"SpringBoard: WEEEEEEEEEEEEEEEEEEEEEEE!!!!!!");
        }
        else {
            %orig;
        }
    }
    else {
        %orig;
    }
}

- (void)switcherWasDismissed:(id)switcher {
    [itemsToRemove removeAllObjects];
    %orig;
}

%end

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSDictionary *preferences = [[NSDictionary alloc] initWithContentsOfFile:PREFERENCES_PATH];
    _springshotEnabled = [preferences[PREFERENCES_ENABLED_KEY] boolValue];
}

%ctor {
    itemsToRemove = [[NSMutableArray alloc] init];

    NSDictionary *preferences = [[NSDictionary alloc] initWithContentsOfFile:PREFERENCES_PATH];
    if (preferences == nil) {
        preferences = @{ PREFERENCES_ENABLED_KEY : @(YES) };
        [preferences writeToFile:PREFERENCES_PATH atomically:YES];
        _springshotEnabled = YES;
    }
    else {
        _springshotEnabled = [preferences[PREFERENCES_ENABLED_KEY] boolValue];
    }

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PREFERENCES_CHANGED_NOTIFICATION), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
