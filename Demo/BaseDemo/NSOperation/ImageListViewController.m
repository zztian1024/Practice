//
//  ImageListViewController.m
//  NSOperation
//
//  Created by Tian on 2021/4/19.
//

#import "ImageListViewController.h"
#import "ImageAssets.h"
#import "DownloadOperation.h"

@interface ImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation ImageCell

@end

@interface ImageListViewController ()<DownloadOperationDelegate>

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSMutableDictionary *imageCache;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) NSMutableDictionary *operations;

@end

@implementation ImageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
}

- (NSArray *)images {
    if (!_images) {
        _images = [ImageAssets getImages];
    }
    return _images;
}

- (NSOperationQueue *)downloadQueue {
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 3;
    }
    return _downloadQueue;
}

- (NSMutableDictionary *)imageCache {
    if (!_imageCache) {
        _imageCache = [NSMutableDictionary dictionary];
    }
    return _imageCache;
}

- (NSMutableDictionary *)operations {
    if (!_operations) {
        _operations = [NSMutableDictionary dictionary];
    }
    return _operations;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.images.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageItem *item = [_images objectAtIndex:indexPath.row];
    ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
    cell.nameLabel.text = item.name;
    
    /** 耗时操作
    // 下载图片数据
    NSLog(@"加载图片数据---%@", [NSThread currentThread]);
    NSURL *url = [NSURL URLWithString:item.avatar];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *imgae = [UIImage imageWithData:data];
    cell.avatarView.image = imgae;
    NSLog(@"完成显示");
    */
    UIImage *image = self.imageCache[item.avatar];
    if (image) {
        cell.avatarView.image = image;
    } else {
        if (![self.operations valueForKey:item.avatar]) {// 不重复添加
            DownloadOperation *opt = [[DownloadOperation alloc] init];
            opt.indexPath = indexPath;
            opt.url = item.avatar;
            opt.delegate = self;
            [self.downloadQueue addOperation:opt];
            self.operations[item.avatar] = opt;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  100.0;
}


#pragma mark - DownloadOperationDelegate

- (void)downloadOperation:(DownloadOperation *)operation didFishedDownLoad:(UIImage *)image {
    
    [self.operations removeObjectForKey:operation.url];
    self.imageCache[operation.url] = image;
    
    [self.tableView reloadRowsAtIndexPaths:@[operation.indexPath] withRowAnimation:UITableViewRowAnimationFade];
    NSLog(@"---- download finish~");
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
