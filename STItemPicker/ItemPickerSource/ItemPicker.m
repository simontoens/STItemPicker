// @author Simon Toens 03/17/13

#import "ItemPickerViewController.h"
#import "ItemPickerDataSourceDefaults.h"

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
@synthesize maxSelectableItems = _maxSelectableItems;
@synthesize showCancelButton = _showCancelButton;

- (id)initWithDataSources:(NSArray *)someDataSources
{
    if (self = [super init]) 
    {
        dataSources = someDataSources;
        _maxSelectableItems = 1;
        _showCancelButton = NO;
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
    id<ItemPickerDataSource> wrappedDataSource = [[ItemPickerDataSourceDefaults alloc] initWithDataSource:dataSource];
    ItemPickerViewController *controller = [[ItemPickerViewController alloc] initWithDataSource:wrappedDataSource];
    controller.itemPickerDelegate = self.delegate;
    controller.maxSelectableItems = self.maxSelectableItems;
    controller.showCancelButton = self.showCancelButton;
    return [[UINavigationController alloc] initWithRootViewController:controller];    
}

@end