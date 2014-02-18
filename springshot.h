#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef DEBUG
    #define DebugLog(str, ...) NSLog(str, ##__VA_ARGS__)
#else
    #define DebugLog(str, ...)
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
