#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define THEOS

#ifdef THEOS
	#define HOOK(classname) %hook classname
	#define END %end
#else
	#define HOOK(classname) @implementation classname (theos)
	#define END @end
#endif

@interface SBAppSliderController : NSObject
- (void)sliderScroller:(id)arg1 itemWantsToBeRemoved:(unsigned int)arg2;
- (BOOL)sliderScroller:(id)arg1 isIndexRemovable:(unsigned int)arg2;
@end

@interface SBAppSliderScrollingViewController : NSObject
- (SBAppSliderController *)delegate;
@end

@interface SBAppSwitcherPageView : NSObject
@end

@interface SBAppSliderItemScrollView : NSObject
- (SBAppSwitcherPageView *)item;
@end

%hook SBAppSliderScrollingViewController

static NSMutableArray *itemsToRemove;

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(CGPoint *)targetContentOffset {
    %orig;

    NSUInteger itemIndex = [[self valueForKey:@"_items"] indexOfObject:scrollView];
    BOOL isRemovable = [self.delegate sliderScroller:scrollView isIndexRemovable:itemIndex];

    if (scrollView.contentOffset.y < -40.0 && isRemovable) {
        [itemsToRemove addObject:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
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

        NSLog(@"SpringBoard: WEEEEEEEEEEEEEEEEEEEEEEE!!!!!!");
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