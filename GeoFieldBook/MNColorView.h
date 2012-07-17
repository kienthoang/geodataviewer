//
//  MNColorView.h
//  MNColorPicker
//

#import <UIKit/UIKit.h>


typedef enum  {
    MNColorViewBorderStyleSingle = 0,
    MNColorViewBorderStyleTop, 
    MNColorViewBorderStyleMiddle, 
    MNColorViewBorderStyleBottom,
} MNColorViewBorderStyle;


@interface MNColorView : UIControl 

+ (id)colorViewWithColor:(UIColor *)color borderStyle:(MNColorViewBorderStyle)borderStyle;

@property (nonatomic, retain) UIColor *color;
@property (nonatomic) MNColorViewBorderStyle borderStyle;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@end
