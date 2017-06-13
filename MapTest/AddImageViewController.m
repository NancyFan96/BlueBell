//
//  AddImageViewController.m
//  MapTest
//
//  Created by Nancy Fan on 2017/5/30.
//  Copyright © 2017年 Nancy Fan. All rights reserved.
//

#import "AddImageViewController.h"

@interface AddImageViewController ()

@end

@implementation AddImageViewController

@synthesize image;
@synthesize imageView;


-(void)takePhoto {
    pickerCamera = [[UIImagePickerController alloc] init];
    pickerCamera.allowsEditing = NO;
    [pickerCamera setSourceType:UIImagePickerControllerSourceTypeCamera];
    pickerCamera.delegate = self;
    [self presentViewController:pickerCamera animated:YES completion:NULL];
    
}

-(void)choseLib {
    pickerLib = [[UIImagePickerController alloc] init];
    pickerLib.allowsEditing = NO;
    [pickerLib setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    pickerLib.delegate = self;
    [self presentViewController:pickerLib animated:YES completion:NULL];
    NSLog(@"finish Chose");
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"get image");
    [self.imageView setImage:image];
    [self dismissViewControllerAnimated:NO completion:NULL];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
