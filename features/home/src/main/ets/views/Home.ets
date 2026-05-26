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
import { CommonConstants, Logger } from "base";
import { BarItemInterface, TabBarsInfo } from "../model/TabBarModel";
import { TabBarViewModel } from "../viewmodel/TabBarViewModel";
import { WaterFlowDataSource } from "../viewmodel/WaterFlowDataSource";
import { common } from "@kit.AbilityKit";
import { window } from "@kit.ArkUI";

@Builder
export function HomeBuilder() {
  Home()
}
// [Start home]
@Component
export struct Home {
  windowObj: window.Window | undefined = undefined;
  // [StartExclude home]
  @StorageLink(CommonConstants.WIDTH_BREAK_POINT) widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  @State currentIndex: number = 0;
  @State isDarkMode: boolean = false; // 日夜模式状态
  @State themeOpacity: number = 1; // 主题切换动画透明度
  tabBarsInfo: TabBarViewModel = new TabBarViewModel();
  waterFlowList: WaterFlowDataSource = new WaterFlowDataSource();
  private itemHeightArray: number[] = [];
  minSize: number = 130;
  maxSize: number = 200;
  // [EndExclude home]

  aboutToAppear(): void {
    this.tabBarsInfo.setTabList(TabBarsInfo);
    try {
      this.windowObj = (this.getUIContext().getHostContext() as common.UIAbilityContext).windowStage.getMainWindowSync()
    } catch (err) {
      Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
    }

    this.windowObj?.setPreferredOrientation(window.Orientation.FOLLOW_DESKTOP)
      .catch((err: BusinessError) => {
        Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
      });
    // [StartExclude home]
    this.setItemSizeArray();
    // [EndExclude home]
  }

  // [StartExclude home]
  aboutToDisappear() {
    this.windowObj?.setPreferredOrientation(window.Orientation.UNSPECIFIED)
      .catch((err: BusinessError) => {
        Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
      });
  }

  // 设置FlowItem的宽/高数组
  setItemSizeArray() {
    for (let i = 0; i < 100; i++) {
      this.itemHeightArray.push(this.getSize());
    }
  }

  // 计算FlowItem宽/高
  getSize() {
    let ret = Math.floor(Math.random() * this.maxSize);
    return (ret > this.minSize ? ret : this.minSize);
  }

  // 切换日夜模式
  toggleTheme() {
    // 淡出动画
    animateTo({
      duration: 200,
      curve: Curve.EaseOut
    }, () => {
      this.themeOpacity = 0;
    });
    
    // 延迟切换主题并淡入
    setTimeout(() => {
      this.isDarkMode = !this.isDarkMode;
      animateTo({
        duration: 200,
        curve: Curve.EaseIn
      }, () => {
        this.themeOpacity = 1;
      });
    }, 200);
  }

  @Builder
  MainBuilder() {
    Column() {
      WaterFlow() {
        LazyForEach(this.waterFlowList, (item: number) => {
          FlowItem() {
            this.ReusableFlowItem()
          }
          .onAppear(() => {
            if (item + 20 == this.waterFlowList.totalCount()) {
              for (let i = 0; i < 100; i++) {
                this.waterFlowList.addLastItem()
              }
            }
          })
          .width(CommonConstants.FULL_PERCENT)
          .height(this.itemHeightArray[item % 100])
          .backgroundColor(this.isDarkMode ? $r('app.color.card_background_dark') : $r('app.color.card_background_light'))
          .borderRadius(16)
          .shadow({
            radius: this.isDarkMode ? 0 : 8,
            color: $r('app.color.list_item_card_shadow'),
            offsetX: 0,
            offsetY: 2
          })
        }, (item: string) => item)
      }
      .key('waterFlow')
      .cachedCount(2)
      .columnsTemplate({ fillType: PresetFillType.BREAKPOINT_SM2MD3LG5 })
      .columnsGap(12)
      .rowsGap(12)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
  }

  @Builder
  ReusableFlowItem() {
    Column() {
      Text('卡片内容')
        .fontSize(14)
        .fontColor(this.isDarkMode ? $r('app.color.card_text_color_dark') : $r('app.color.card_text_color_light'))
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

  @Builder
  TabBarBuilder(item: BarItemInterface, index: number) {
    Column({ space: 4 }) {
      Image(index !== this.currentIndex ? item.icon : item.iconSelected)
        .width(24)
        .aspectRatio(1)
      Text(item.name)
        .fontSize(10)
        .fontWeight(500)
        .fontColor(index === this.currentIndex ? $r('app.color.tab_select_color') : 
                   (this.isDarkMode ? $r('app.color.text_color_dark') : $r('app.color.tab_normal_color')))
    }
    .height(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
  }
  // [EndExclude home]

  build() {
    // [StartExclude home]
    NavDestination() {
      Column({ space: 10 }) {
        Tabs({
          barPosition: this.widthBp === WidthBreakpoint.WIDTH_LG ? BarPosition.Start : BarPosition.End,
          index: this.currentIndex
        }) {
          TabContent() {
            this.MainBuilder()
          }
          .tabBar(this.TabBarBuilder(this.tabBarsInfo.getTabList()[0], 0))

          TabContent() {
          }
          .tabBar(this.TabBarBuilder(this.tabBarsInfo.getTabList()[1], 1))

          TabContent() {
          }
          .tabBar(this.TabBarBuilder(this.tabBarsInfo.getTabList()[2], 2))

          TabContent() {
          }
          .tabBar(this.TabBarBuilder(this.tabBarsInfo.getTabList()[3], 3))
        }
        .vertical(this.widthBp === WidthBreakpoint.WIDTH_LG)
        .barHeight(this.widthBp === WidthBreakpoint.WIDTH_LG ? CommonConstants.HALF_PERCENT :
          54)
        .barWidth(this.widthBp === WidthBreakpoint.WIDTH_LG ?
          96 : CommonConstants.FULL_PERCENT)
        .barBackgroundBlurStyle(BlurStyle.NONE)
        .barBackgroundColor(this.isDarkMode ? $r('app.color.tabbar_background_dark') : $r('app.color.tabbar_background_light'))
        .scrollable(false)
        .height(CommonConstants.FULL_PERCENT)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        left: 16,
        right: 16,
        top: 8
      })
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .align(Alignment.Center)
    .title($r("app.string.homepage"), { 
      backgroundColor: this.isDarkMode ? $r('app.color.page_background_dark') : $r('app.color.page_background_light')
    })
    .backgroundColor(this.isDarkMode ? $r('app.color.page_background_dark') : $r('app.color.page_background_light'))
    .opacity(this.themeOpacity)
    .menus([
      {
        value: '',
        icon: this.isDarkMode ? $r('app.media.ic_moon') : $r('app.media.ic_sun'),
        action: () => {
          this.toggleTheme();
        }
      }
    ])
    // [EndExclude home]
  }
}
// [End home]

