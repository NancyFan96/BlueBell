//
//  AddImageViewController.h
//  MapTest
//
//  Created by Nancy Fan on 2017/5/30.
//  Copyright © 2017年 Nancy Fan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddImageViewController : UIViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate> {
    
    UIImagePickerController *pickerCamera;
    UIImagePickerController *pickerLib;
    
    
}

@property (weak, nonatomic)  UIImageView *imageView;
@property (weak, nonatomic)  UIImage *image;

-(void)takePhoto;
-(void)choseLib;
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

@end
