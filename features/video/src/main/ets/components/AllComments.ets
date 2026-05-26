/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CommonConstants } from 'base';
import { UserInfo, UserViewModel } from '../viewmodel/UserViewModel';

// 新评论数据接口
interface NewComment {
  content: string;
  timestamp: string;
  id: number;  // 唯一标识
}

// 删除确认对话框数据接口
interface DeleteDialogData {
  show: boolean;
  commentId: number;
  commentIndex: number;
}

@Component
export struct AllComments {
  @StorageLink(CommonConstants.WIDTH_BREAK_POINT) widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  @Link commentImgHeight: string;
  @Link commentImgWidth: string;
  private commentsList: UserInfo[] = new UserViewModel().getRelatedVideoList();
  
  // 评论输入相关状态
  @State commentInput: string = '';
  @State newComments: NewComment[] = [];
  @State commentIdCounter: number = 0;  // 评论ID计数器
  @State deleteDialog: DeleteDialogData = { show: false, commentId: -1, commentIndex: -1 };  // 删除对话框数据
  @State showDeleteSuccess: boolean = false;  // 删除成功提示

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          this.TitleText($r('app.string.comments'))
        }
        .padding({
          left: 24,
          right: 24
        })
        .height(48)
        .width(CommonConstants.FULL_PERCENT)
      
      // 评论输入框区域
      Row({ space: 12 }) {
        TextInput({ placeholder: '写下你的评论…', text: this.commentInput })
          .layoutWeight(1)
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .placeholderColor('#999999')
          .placeholderFont({ size: 14 })
          .fontSize(14)
          .fontColor('#333333')
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.commentInput = value;
          })
          .type(InputType.Normal)
        
        Button('发送')
          .width(60)
          .height(48)
          .backgroundColor('#007DFF')
          .borderRadius(8)
          .fontSize(14)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .enabled(this.commentInput.length > 0)
          .onClick(() => {
            if (this.commentInput.length > 0) {
              this.commentIdCounter = this.commentIdCounter + 1;
              const newComment: NewComment = {
                content: this.commentInput,
                timestamp: '刚刚',
                id: this.commentIdCounter
              };
              this.newComments.unshift(newComment);
              this.commentInput = '';
            }
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        left: 24,
        right: 24,
        top: 12,
        bottom: 12
      })
      .alignItems(VerticalAlign.Center)

      Column() {
        // 新添加的评论列表
        ForEach(this.newComments, (item: NewComment, index: number) => {
          Column() {
            Row() {
              Image($r('app.media.ic_user_profile_1'))
                .height(36)
                .width(36)
                .margin({ right: 16 })

              this.TitleText('我')
              
              Blank()
              
              // 删除按钮（仅自己的评论显示）
              Text('删除')
                .fontSize(12)
                .fontColor('#999999')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(4)
                .onClick(() => {
                  // 显示删除确认对话框
                  this.deleteDialog = {
                    show: true,
                    commentId: item.id,
                    commentIndex: index
                  };
                })
            }
            .height(48)
            .width(CommonConstants.FULL_PERCENT)
            .margin({ top: 10 })
            .alignItems(VerticalAlign.Center)

            Row() {
              Text(item.content)
                .margin({ left: 52 })
                .opacity(0.6)
                .fontSize(14)
                .lineHeight(28)
                .fontWeight(500)
            }
            .margin({ top: 4 })
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Start)

            Row() {
              Text(item.timestamp)
                .opacity(0.6)
                .fontSize(12)
                .lineHeight(18)
                .fontWeight(FontWeight.Normal)
                .margin({ left: 52 })

              Blank()
              Row({ space: 24 }) {
                this.IconImage($r('app.media.ic_public_comments'))
                this.IconImage($r('app.media.ic_public_thumb_sup'))
                this.IconImage($r('app.media.ic_public_share'))
              }
            }
            .margin({ top: 14 })
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Start)

            Divider()
              .color(Color.Black)
              .opacity(0.05)
              .margin({
                top: 12
              })
              .height(1)
              .width(CommonConstants.FULL_PERCENT)
          }
          .width(CommonConstants.FULL_PERCENT)
        }, (item: NewComment, index: number) => item.id.toString())
        
        // 原有评论列表
        ForEach(this.commentsList, (item: UserInfo, index: number) => {
          Row() {
            Image(item.getImageSrc())
              .height(36)
              .width(36)
              .margin({ right: 16 })

            this.TitleText(item.getName())
          }
          .height(48)
          .width(CommonConstants.FULL_PERCENT)
          .margin({ top: 10 })
          .alignItems(VerticalAlign.Center)

          Row() {
            Text(item.getComment())
              .margin({ left: 52 })
              .opacity(0.6)
              .fontSize(14)
              .lineHeight(28)
              .fontWeight(500)
          }
          .margin({ top: 4 })
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Start)

          // Row() {
          // }
          // .padding({ left: $r('app.float.all_comments_img_row_padding') })
          // .margin({ top: $r('app.float.all_comments_img_row_margin') })
          // .width(CommonConstants.FULL_PERCENT)
          // .justifyContent(FlexAlign.Start)
          // .visibility(!item.getCommentImageSrc() ? Visibility.None : Visibility.Visible)

          Row() {
            Text(item.getTime())
              .opacity(0.6)
              .fontSize(12)
              .lineHeight(18)
              .fontWeight(FontWeight.Normal)
              .margin({ left: 52 })

            Blank()
            Row({ space: 24 }) {
              this.IconImage($r('app.media.ic_public_comments'))
              this.IconImage($r('app.media.ic_public_thumb_sup'))
              this.IconImage($r('app.media.ic_public_share'))
            }
          }
          .margin({ top: 14 })
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Start)

          Divider()
            .color(Color.Black)
            .opacity(0.05)
            .margin({
              top: 12
            })
            .height(1)
            .width(CommonConstants.FULL_PERCENT)
            .visibility(index === this.commentsList.length - 1 ? Visibility.None : Visibility.Visible)
        }, (item: UserInfo, index: number) => index + JSON.stringify(item))
      }
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: 24,
        right: 24
      })
      .width(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Start)
    
    // 删除成功提示
    if (this.showDeleteSuccess) {
      Row() {
        Text('删除成功')
          .fontSize(14)
          .fontColor(Color.White)
      }
      .width(120)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(0, 0, 0, 0.7)')
      .borderRadius(20)
      .margin({ top: 60 })
    }
  }
  .bindSheet(this.deleteDialog.show, this.DeleteConfirmSheet(), {
    height: 180,
    backgroundColor: Color.White,
    dragBar: false
  })
  }
  
  // 删除确认对话框
  @Builder
  DeleteConfirmSheet() {
    Column() {
      Text('确认删除')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 20, bottom: 16 })
      
      Text('确定要删除这条评论吗？')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 24 })
      
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F5F5F5')
          .fontColor('#333333')
          .fontSize(16)
          .onClick(() => {
            this.deleteDialog = { show: false, commentId: -1, commentIndex: -1 };
          })
        
        Button('删除')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#FF4D4F')
          .fontColor(Color.White)
          .fontSize(16)
          .onClick(() => {
            // 执行删除
            if (this.deleteDialog.commentIndex >= 0 && this.deleteDialog.commentIndex < this.newComments.length) {
              this.newComments.splice(this.deleteDialog.commentIndex, 1);
              this.showDeleteSuccess = true;
              // 2秒后隐藏成功提示
              setTimeout(() => {
                this.showDeleteSuccess = false;
              }, 2000);
            }
            this.deleteDialog = { show: false, commentId: -1, commentIndex: -1 };
          })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })
    }
    .width('100%')
    .padding({ bottom: 20 })
  }

  @Builder
  TitleText(content: ResourceStr) {
    Text(content)
      .fontSize(16)
      .lineHeight(22)
      .fontWeight(500)
  }

  @Builder
  IconImage(image: Resource | null = null) {
    Image(image)
      .height(16)
      .width(16)
  }
}