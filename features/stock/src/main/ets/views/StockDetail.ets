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

import { window } from "@kit.ArkUI";
import { common } from "@kit.AbilityKit";
import { CYCLE_TITLE, OTHER_TITLE, StockInForm, STOCK_INFORM_LIST } from "../model/DataModel";
import { CommSlide, StockInFormList, TitleIcon, UniversalIcon } from "./CommonViews";
import { LineChart } from '@ohos/mpchart';
import { LinesChartModel } from "../chartmodels/LineChartModel";
import { BarChartView } from "../chartmodels/BarChartView";
import { StockDealDetails } from "./StockDealDetails";
import { BreakpointType, CommonConstants, Logger } from "base";

// 关键时间点数据接口
interface TimePoint {
  time: string;
  label: string;
  price: number;
  volume: number;
  x: number;
}

// 弹窗数据接口
interface TimePointDialog {
  show: boolean;
  timePoint: TimePoint | null;
}

@Builder
export function StockDetailBuilder() {
  StockDetail()
}
// [Start stockDetail]
@Component
export struct StockDetail {
  windowObj: window.Window | undefined = undefined;
  // [StartExclude stockDetail]
  @StorageLink(CommonConstants.WIDTH_BREAK_POINT) widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  pathStack?: NavPathStack;
  private scroller: Scroller = new Scroller();
  @Provide('isExpand') isExpand: boolean = false;
  @State firstTabIndexSelected: number = 0;
  @State secondTabIndexSelected: number = 0;
  @State ChartViewModel: LinesChartModel = new LinesChartModel();
  
  // 关键时间点数据
  @State timePoints: TimePoint[] = [];
  @State dialogData: TimePointDialog = { show: false, timePoint: null };
  // [EndExclude stockDetail]

  aboutToAppear(): void {
    try {
      this.windowObj = (this.getUIContext().getHostContext() as common.UIAbilityContext).windowStage.getMainWindowSync()
    } catch (err) {
      Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
    }

    this.windowObj?.setPreferredOrientation(window.Orientation.FOLLOW_DESKTOP)
      .catch((err: BusinessError) => {
        Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
      });
    
    // 初始化关键时间点数据
    this.initTimePoints();
  }

  // 初始化关键时间点
  initTimePoints() {
    // 开盘时间 9:30
    const openPoint: TimePoint = {
      time: '09:30',
      label: '开盘',
      price: 9.00,
      volume: 1250000,
      x: 0.1
    };
    
    // 午休时间 11:30
    const lunchPoint: TimePoint = {
      time: '11:30',
      label: '午休',
      price: 9.02,
      volume: 890000,
      x: 0.4
    };
    
    // 收盘时间 15:00
    const closePoint: TimePoint = {
      time: '15:00',
      label: '收盘',
      price: 9.04,
      volume: 1580000,
      x: 0.9
    };
    
    this.timePoints = [openPoint, lunchPoint, closePoint];
  }

  // 显示时间点弹窗
  showTimePointDialog(point: TimePoint) {
    this.dialogData = {
      show: true,
      timePoint: point
    };
  }

  // 关闭弹窗
  closeDialog() {
    this.dialogData = {
      show: false,
      timePoint: null
    };
  }

  aboutToDisappear() {
    this.windowObj?.setPreferredOrientation(window.Orientation.UNSPECIFIED)
      .catch((err: BusinessError) => {
        Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
      });
  }

  build() {
    // [StartExclude stockDetail]
    NavDestination() {
      Column() {
        Stack() {
          Row() {
            Row(){
              UniversalIcon("#0C000000", $r('sys.symbol.chevron_backward'))
            }
            .onClick(()=> {
              this.pathStack?.pop()
            })
          }
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Start)
          .padding({
            left: 16
          })

          Column() {
            Text() {
              Span($r('app.string.somebody_technology'))
              Span('60**39')
            }
            .fontSize(16)
            .height(21)

            Row() {
              WordBackgroundComm($r('app.string.deep'), '#1E6CF3', '#E8F0FE')
              Text($r('app.string.closed_day'))
                .fontSize(11)
                .height(15)
                .fontColor('#999999')
            }
          }
        }
        .height(40)

        Scroll(this.scroller) {
          Column() {
            Column() {
              Row() {
                Text(`${9.04}`)
                  .fontSize(30)
                  .height(30)
                  .fontColor($r("app.color.stock_font_color"))
                  .fontWeight(FontWeight.Medium)
                  .margin({
                    right: 11.5
                  })
                Text(`${+0.04}  ${'+0.53%'}`)
                  .fontSize(14)
                  .height(19)
                  .fontColor($r("app.color.stock_font_color"))
                  .fontWeight(FontWeight.Medium)
              }
              .width(CommonConstants.FULL_PERCENT)
              .height(48)
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Bottom)
              .backgroundColor(Color.White)
              .padding({
                top: 9,
                right: new BreakpointType(16, 16, 24, 32, 32).getValue(this.widthBp),
                bottom: 9,
                left: new BreakpointType(16, 16, 24, 32, 32).getValue(this.widthBp)
              })

              Row() {
                Column() {
                  GridRow({
                    columns: 12,
                    direction: GridRowDirection.Row
                  }) {
                    ForEach(STOCK_INFORM_LIST, (item: StockInForm, index: number) => {
                      GridCol({
                        span: {
                          xs: 6,
                          sm: 6,
                          md: 4,
                          lg: 3
                        }
                      }) {
                        StockInFormList({ item: item, index: index })
                      }
                    }, (item: StockInForm, index: number) => item.title1.toString() + index)
                  }
                  .width(CommonConstants.FULL_PERCENT)

                  SymbolGlyph(this.isExpand ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'))
                    .fontColor([$r('sys.color.icon_primary')])
                    .fontSize(16)
                    .onClick(() => {
                      this.isExpand = !this.isExpand;
                    })
                    .padding({
                      bottom: 4
                    })
                }
                .width(CommonConstants.FULL_PERCENT)
                .backgroundColor(Color.White)
              }
            }

            Row() {
              Column() {
                CommSlide({
                  commSlideData: CYCLE_TITLE,
                  tabIndexSelected: this.firstTabIndexSelected
                })
              }
              .width(CommonConstants.FULL_PERCENT)
              .height(40)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor(Color.White)
              .margin({
                top: (this.widthBp === WidthBreakpoint.WIDTH_LG ||
                  this.widthBp === WidthBreakpoint.WIDTH_XL) ? 8 : 4,
                bottom: this.widthBp === WidthBreakpoint.WIDTH_SM ? 4 : 1
              })
            }

            Row() {
              Row() {
                Column() {
                  Stack({ alignContent: Alignment.BottomEnd }) {
                    // K线图表
                    LineChart({ model: this.ChartViewModel.getLineChartModel() })
                    
                    // 关键时间点标记层
                    Stack() {
                      ForEach(this.timePoints, (point: TimePoint) => {
                        Column() {
                          // 时间点标记线
                          Row()
                            .width(2)
                            .height('100%')
                            .backgroundColor('#FF6B6B')
                            .opacity(0.6)
                          
                          // 时间点标签
                          Column() {
                            Text(point.label)
                              .fontSize(10)
                              .fontColor('#FFFFFF')
                              .fontWeight(FontWeight.Bold)
                          }
                          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                          .backgroundColor('#FF6B6B')
                          .borderRadius(4)
                          .onClick(() => {
                            this.showTimePointDialog(point);
                          })
                        }
                        .position({ x: `${point.x * 100}%`, y: 0 })
                        .height('100%')
                        .alignItems(HorizontalAlign.Center)
                      }, (point: TimePoint) => point.time)
                    }
                    .width(CommonConstants.FULL_PERCENT)
                    .height(CommonConstants.FULL_PERCENT)
                    
                    SymbolGlyph($r('sys.symbol.arrow_up_left_and_arrow_down_right'))
                      .width(24)
                      .height(24)
                      .onClick(() => {
                        this.pathStack?.pushPathByName("ABAWindow", null);
                      })
                      .margin({
                        bottom: 36
                      })
                  }
                  .height('80%')
                  .padding({
                    top: 20
                  })

                  Row() {
                    BarChartView()
                  }
                  .width(CommonConstants.FULL_PERCENT)
                  .height('20%')
                }
                .height(CommonConstants.FULL_PERCENT)
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.SpaceBetween)
              
              // 时间点信息弹窗
              if (this.dialogData.show && this.dialogData.timePoint !== null) {
                Column() {
                  Column() {
                    Row() {
                      Text(this.dialogData.timePoint.label)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#333333')
                      
                      Blank()
                      
                      Text('×')
                        .fontSize(20)
                        .fontColor('#999999')
                        .onClick(() => {
                          this.closeDialog();
                        })
                    }
                    .width(CommonConstants.FULL_PERCENT)
                    .justifyContent(FlexAlign.SpaceBetween)
                    .margin({ bottom: 12 })
                    
                    Row() {
                      Text('时间：')
                        .fontSize(14)
                        .fontColor('#666666')
                      Text(this.dialogData.timePoint.time)
                        .fontSize(14)
                        .fontColor('#333333')
                        .fontWeight(FontWeight.Medium)
                    }
                    .width(CommonConstants.FULL_PERCENT)
                    .margin({ bottom: 8 })
                    
                    Row() {
                      Text('股价：')
                        .fontSize(14)
                        .fontColor('#666666')
                      Text(`${this.dialogData.timePoint.price.toFixed(2)}`)
                        .fontSize(14)
                        .fontColor('#E53137')
                        .fontWeight(FontWeight.Medium)
                    }
                    .width(CommonConstants.FULL_PERCENT)
                    .margin({ bottom: 8 })
                    
                    Row() {
                      Text('成交量：')
                        .fontSize(14)
                        .fontColor('#666666')
                      Text(`${(this.dialogData.timePoint.volume / 10000).toFixed(0)}万`)
                        .fontSize(14)
                        .fontColor('#333333')
                        .fontWeight(FontWeight.Medium)
                    }
                    .width(CommonConstants.FULL_PERCENT)
                  }
                  .width(200)
                  .padding(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .shadow({
                    radius: 8,
                    color: 'rgba(0, 0, 0, 0.1)',
                    offsetX: 0,
                    offsetY: 4
                  })
                }
                .width(CommonConstants.FULL_PERCENT)
                .height(CommonConstants.FULL_PERCENT)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .backgroundColor('rgba(0, 0, 0, 0.3)')
                .onClick(() => {
                  this.closeDialog();
                })
              }

              StockDealDetails()
            }
            .width(CommonConstants.FULL_PERCENT)
            .height(new BreakpointType(294, 294, 286, 376, 376).getValue(this.widthBp))
            .justifyContent(FlexAlign.SpaceBetween)
            .backgroundColor(Color.White)
            .padding({
              right: new BreakpointType(16, 16, 24, 32, 32).getValue(this.widthBp),
              left: new BreakpointType(16, 16, 24, 32, 32).getValue(this.widthBp)
            })

            Row() {
              Column() {
                CommSlide({
                  commSlideData: OTHER_TITLE,
                  tabIndexSelected: this.secondTabIndexSelected
                })
              }
              .width(CommonConstants.FULL_PERCENT)
              .height(40)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor(Color.White)
              .margin({
                top: 4,
                bottom: 12
              })
            }

            Column({ space: 12 }) {
              Image($r('app.media.ic_title'))
                .borderRadius(16)
              Image($r('app.media.ic_content0'))
                .borderRadius(16)
              Image($r('app.media.ic_content1'))
                .borderRadius(16)
              Image($r('app.media.ic_content2'))
                .borderRadius(16)
            }
            .margin({
              right: new BreakpointType(16, 16, 24, 32, 32).getValue(this.widthBp),
              left: new BreakpointType(16, 16, 24, 32, 32).getValue(this.widthBp)
            })
          }
        }
        .backgroundColor($r('sys.color.comp_background_gray'))
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        .padding({
          bottom: 8
        })
        .align(Alignment.Top)

        Row() {
          Row({ space: 24 }) {
            TitleIcon($r('sys.symbol.dot_grid_2x2'), $r('app.string.self_selected_settings'))
            TitleIcon($r('sys.symbol.Investment_stable_value_add'), $r('app.string.stock_pk'))
            TitleIcon($r('sys.symbol.more'), $r('app.string.more'))
          }
          .margin({
            right: new BreakpointType(32, 32, 101, 32, 32).getValue(this.widthBp)
          })

          Row() {
            Text($r('app.string.go_trade'))
              .fontSize(16)
              .lineHeight(21)
              .fontWeight(500)
              .fontColor($r('sys.color.font_on_primary'))
          }
          .layoutWeight(1)
          .height(40)
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#E53137')
          .padding({
            top: 2
          })
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(52)
        .backgroundColor($r('sys.color.font_on_primary'))
        .alignItems(VerticalAlign.Top)
        .justifyContent(this.widthBp === WidthBreakpoint.WIDTH_LG ? FlexAlign.End : FlexAlign.Start)
        .padding({
          top: 6,
          right: new BreakpointType(16, 16, 24, 32, 32).getValue(this.widthBp),
          left: new BreakpointType(16, 16, 24, 32, 32).getValue(this.widthBp)
        })
        .margin({ bottom: -6 })
        .border({
          width: { top: 0.5 },
          color: { top: '#33000000' },
          style: { top: BorderStyle.Solid }
        })
      }
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .hideTitleBar(true)
    .align(Alignment.Center)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    // [StartExclude stockDetail]
  }
}
// [End stockDetail]

@Builder
export function WordBackgroundComm(text: ResourceStr, textFontColor: ResourceColor,
  textBackgroundColor: ResourceColor) {
  Row() {
    Text(text)
      .fontSize(10)
      .fontColor(textFontColor)
  }
  .width(12)
  .height(12)
  .borderRadius(2)
  .alignItems(VerticalAlign.Center)
  .justifyContent(FlexAlign.Center)
  .backgroundColor(textBackgroundColor)
  .margin({
    right: 4
  })
}

