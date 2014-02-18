%config(generator=MobileSubstrate);

#import "springshot.h"

BOOL _springshotEnabled = NO;

%hook SBAppSliderController

- (void)switcherWillBeDismissed:(BOOL)arg1 {
    _springshotEnabled = NO;
    %orig;
}

- (void)switcherWasPresented:(BOOL)arg1 {
    _springshotEnabled = YES;
    %orig;
}

%end

%hook SBAppSliderScrollingViewController

static NSMutableArray *itemsToRemove;

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(CGPoint *)targetContentOffset {
    %orig;

    if (_springshotEnabled) {
        NSUInteger itemIndex = [[self valueForKey:@"_items"] indexOfObject:scrollView];
        BOOL isRemovable = [self.delegate sliderScroller:scrollView isIndexRemovable:itemIndex];

        if (scrollView.contentOffset.y < -40.0 && isRemovable) {
            [itemsToRemove addObject:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([itemsToRemove containsObject:scrollView] && _springshotEnabled) {
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

- (void)switcherWasDismissed:(id)switcher {
    [itemsToRemove removeAllObjects];
    %orig;
}

%end

%ctor {
    itemsToRemove = [[NSMutableArray alloc] init];
}
