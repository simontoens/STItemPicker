// @author Simon Toens 03/17/13

#import "ItemPickerViewController.h"

@interface ItemPicker() 
{
    @private 
    id<ItemPickerDataSource> dataSource;
    UINavigationController *navigationController;
}
@end

@implementation ItemPicker

@synthesize delegate;

- (id)initWithDataSource:(id<ItemPickerDataSource>)aDataSource 
{
    if (self = [super init]) 
    {
        dataSource = aDataSource;
    }
    return self;
}

- (UIViewController *)viewController 
{
    if (!navigationController) 
    {
        ItemPickerViewController *controller = [[ItemPickerViewController alloc] initWithDataSource:dataSource];
        controller.itemPickerDelegate = self.delegate;
        navigationController = [[UINavigationController alloc] initWithRootViewController:controller];      
    }
    return navigationController;
}

@end