// @author Simon Toens 03/17/13

#import "ItemPickerViewController.h"

@interface ItemPicker() 
{
    @private 
    NSArray *dataSources;
    UIViewController *viewController;
}
- (UIViewController *)getControllerForDataSource:(id<ItemPickerDataSource>)dataSource;
@end

@implementation ItemPicker

@synthesize delegate;

- (id)initWithDataSources:(NSArray *)someDataSources
{
    if (self = [super init]) 
    {
        dataSources = someDataSources;
    }
    return self;
}

- (UIViewController *)viewController 
{
    if (!viewController) 
    {
        if ([dataSources count] > 1) 
        {
            NSMutableArray *viewControllers = [[NSMutableArray alloc]initWithCapacity:[dataSources count]];
            for (id<ItemPickerDataSource> dataSource in dataSources) 
            {
                [viewControllers addObject:[self getControllerForDataSource:dataSource]];
            }
            viewController = [[UITabBarController alloc] init];
            [(id)viewController setViewControllers:viewControllers];
        } 
        else 
        {
            viewController = [self getControllerForDataSource:[dataSources lastObject]];
        }
    }
    return viewController;
}

- (UIViewController *)getControllerForDataSource:(id<ItemPickerDataSource>)dataSource
{
    ItemPickerViewController *controller = [[ItemPickerViewController alloc] initWithDataSource:dataSource];
    controller.itemPickerDelegate = self.delegate;
    return [[UINavigationController alloc] initWithRootViewController:controller];    
}

@end