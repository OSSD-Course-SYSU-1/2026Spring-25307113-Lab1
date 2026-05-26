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

import { ListDataSource } from '../viewmodel/ListDataSource';
import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { PhotosBarViewModel } from '../viewmodel/PhotoTabBarViewModel';
import { PhotosBarItemInterface } from '../model/PhotsTabBarModel';
import { CommonConstants, Logger } from 'base';

// 收藏图片数据接口
interface FavoritePhoto {
  index: number;
}

@Builder
export function PhotosBuilder() {
  Photos()
}

@Component
export struct Photos {
  @StorageLink(CommonConstants.WIDTH_BREAK_POINT) widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  windowObj: window.Window | undefined = undefined;
  private photoList: ListDataSource = new ListDataSource();
  scrollerForList: Scroller = new Scroller();
  scrollerForFavorite: Scroller = new Scroller(); // 收藏列表独立滚动控制器
  @State currentIndex: number = 0;
  photosTabBarsInfo: PhotosBarViewModel = new PhotosBarViewModel();
  
  // 收藏功能状态
  @State favoriteIndices: number[] = []; // 收藏图片索引数组（用于快速查找）
  @State favoritePhotos: FavoritePhoto[] = []; // 收藏图片数据数组（用于渲染收藏列表）

  aboutToAppear(): void {
    try {
      this.windowObj = (this.getUIContext().getHostContext() as common.UIAbilityContext).windowStage.getMainWindowSync()
    } catch (err) {
      Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
    }

    this.windowObj?.setPreferredOrientation(window.Orientation.AUTO_ROTATION_UNSPECIFIED)
      .catch((err: BusinessError) => {
        Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
      });
  }

  aboutToDisappear() {
    this.windowObj?.setPreferredOrientation(window.Orientation.UNSPECIFIED)
      .catch((err: BusinessError) => {
        Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
      });
  }

  @Builder
  TabBarBuilder(item: PhotosBarItemInterface, index: number) {
    Column({ space: 4 }) {
      Image(item.icon)
        .width(24)
        .aspectRatio(1)
      Text(item.name)
        .fontSize(12)
        .fontWeight(500)
        .fontColor(index === this.currentIndex ? $r('app.color.tab_select_color') : $r('app.color.tab_normal_color'))
    }
    .height(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
  }

  // 切换收藏状态（同时更新两个数组）
  toggleFavorite(index: number) {
    const pos = this.favoriteIndices.indexOf(index);
    if (pos === -1) {
      // 添加到收藏
      this.favoriteIndices.push(index);
      // 同步更新收藏列表数据
      const photo: FavoritePhoto = {
        index: index
      };
      this.favoritePhotos.push(photo);
    } else {
      // 从收藏中移除
      this.favoriteIndices.splice(pos, 1);
      // 同步更新收藏列表数据
      this.favoritePhotos.splice(pos, 1);
    }
  }

  // 检查是否已收藏
  isFavorite(index: number): boolean {
    return this.favoriteIndices.indexOf(index) !== -1;
  }

  // 全部图片列表项（带收藏按钮）
  @Builder
  AllPhotosListItem(params: number) {
    Stack() {
      Image($r(`app.media.ic_photos_${params % 7}`))
        .width(CommonConstants.FULL_PERCENT)
        .aspectRatio(1)
        .objectFit(ImageFit.Cover)
      
      // 收藏按钮（右上角心形图标）
      Column() {
        Row() {
          Blank()
          Button() {
            if (this.isFavorite(params)) {
              // 已收藏：实心心形
              Text('❤️')
                .fontSize(20)
            } else {
              // 未收藏：空心心形
              Text('🤍')
                .fontSize(20)
            }
          }
          .width(36)
          .height(36)
          .backgroundColor('rgba(255, 255, 255, 0.7)')
          .borderRadius(18)
          .onClick(() => {
            this.toggleFavorite(params);
          })
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding({ top: 8, right: 8 })
        
        Blank()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .aspectRatio(1)
  }

  // 收藏图片列表项（只展示，无操作）
  @Builder
  FavoritePhotoItem(photo: FavoritePhoto) {
    Image($r(`app.media.ic_photos_${photo.index % 7}`))
      .width(CommonConstants.FULL_PERCENT)
      .aspectRatio(1)
      .objectFit(ImageFit.Cover)
  }

  build() {
    NavDestination() {
      Column() {
        Tabs({
          barPosition: this.widthBp === WidthBreakpoint.WIDTH_LG ? BarPosition.Start : BarPosition.End,
          index: this.currentIndex
        }) {
          // 照片标签页：显示全部图片
          TabContent() {
            Column() {
              List({ space: 2, initialIndex: 0, scroller: this.scrollerForList }) {
                LazyForEach(this.photoList, (item: number) => {
                  ListItem() {
                    this.AllPhotosListItem(item)
                  }
                }, (item: number) => item.toString())
              }
              .lanes(4, 2)
              .width(CommonConstants.FULL_PERCENT)
              .height(CommonConstants.FULL_PERCENT)
              .scrollBar(BarState.Off)
              .cachedCount(2)
            }
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .backgroundColor($r("app.color.list_background_color"))
          }
          .tabBar(this.TabBarBuilder(this.photosTabBarsInfo.getTabList()[0], 0))

          // 时刻标签页：恢复为空白状态
          TabContent() {
          }
          .tabBar(this.TabBarBuilder(this.photosTabBarsInfo.getTabList()[1], 1))

          // 相册标签页：显示已收藏的图片
          TabContent() {
            Column() {
              if (this.favoritePhotos.length === 0) {
                // 无收藏时显示提示
                Column() {
                  Text('暂无收藏')
                    .fontSize(16)
                    .fontColor('#999999')
                  Text('在"照片"标签页点击心形图标收藏图片')
                    .fontSize(12)
                    .fontColor('#CCCCCC')
                    .margin({ top: 8 })
                }
                .width(CommonConstants.FULL_PERCENT)
                .height(CommonConstants.FULL_PERCENT)
                .justifyContent(FlexAlign.Center)
              } else {
                // 显示收藏列表
                List({ space: 2, initialIndex: 0, scroller: this.scrollerForFavorite }) {
                  ForEach(this.favoritePhotos, (photo: FavoritePhoto) => {
                    ListItem() {
                      this.FavoritePhotoItem(photo)
                    }
                  }, (photo: FavoritePhoto) => photo.index.toString())
                }
                .lanes(4, 2)
                .width(CommonConstants.FULL_PERCENT)
                .height(CommonConstants.FULL_PERCENT)
                .scrollBar(BarState.Off)
              }
            }
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .backgroundColor($r("app.color.list_background_color"))
          }
          .tabBar(this.TabBarBuilder(this.photosTabBarsInfo.getTabList()[2], 2))
        }
        .vertical(this.widthBp === WidthBreakpoint.WIDTH_LG)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
        .barHeight(this.widthBp === WidthBreakpoint.WIDTH_LG ? CommonConstants.HALF_PERCENT :
          54)
        .barWidth(this.widthBp === WidthBreakpoint.WIDTH_LG ?
          96 : CommonConstants.FULL_PERCENT)
        .barBackgroundColor($r('app.color.common_background_color'))
        .scrollable(false)
        .height(CommonConstants.FULL_PERCENT)
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('app.color.common_background_color'))
      .padding({
        top: 8
      })
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .align(Alignment.Center)
    .title($r("app.string.photos"), { backgroundColor: $r('app.color.common_background_color') })
    .backgroundColor($r('app.color.common_background_color'))
  }
}