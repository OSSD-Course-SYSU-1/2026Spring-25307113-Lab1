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
import { CommonConstants, Logger } from "base";
import { PortraitConstants } from "../constants/PortraitConstants";

// 方块状态接口
interface BlockState {
  id: number;
  color: Resource;
  scale: number;
  opacity: number;
}

// 行列坐标接口
interface RowCol {
  row: number;
  col: number;
}

@Builder
export function PortraitModeGameBuilder() {
  PortraitModeGame()
}

@Component
export struct PortraitModeGame {
  @StorageLink(CommonConstants.WIDTH_BREAK_POINT) widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  windowObj: window.Window | undefined = undefined;
  @State blockArr: number[] = [];
  @State blockColorArr: Resource[] = PortraitConstants.BLOCK_COLOR_ARR;
  
  // 游戏状态
  @State score: number = 0; // 当前得分
  @State steps: number = 20; // 剩余步数
  @State blockStates: BlockState[] = []; // 方块状态数组
  private context: common.UIAbilityContext | undefined = undefined;

  aboutToAppear(): void {
    try {
      this.windowObj = (this.getUIContext().getHostContext() as common.UIAbilityContext).windowStage.getMainWindowSync();
      this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    } catch (err) {
      Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
    }

    this.windowObj?.setPreferredOrientation(window.Orientation.PORTRAIT)
      .catch((err: BusinessError) => {
        Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
      });
    this.initBlockArray();
    this.initBlockStates();
  }

  aboutToDisappear() {
    this.windowObj?.setPreferredOrientation(window.Orientation.UNSPECIFIED)
      .catch((err: BusinessError) => {
        Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
      });
  }

  // 设置FlowItem的宽/高数组
  initBlockArray() {
    for (let i = 0; i < 64; i++) {
      this.blockArr.push(i);
    }
  }

  // 初始化方块状态
  initBlockStates() {
    this.blockStates = [];
    for (let i = 0; i < 64; i++) {
      const blockState: BlockState = {
        id: i,
        color: this.randomColor(),
        scale: 1,
        opacity: 1
      };
      this.blockStates.push(blockState);
    }
  }

  randomColor() {
    return this.blockColorArr[Math.floor(Math.random() * 3)];
  }

  // 获取方块的行列坐标
  getRowCol(index: number): RowCol {
    const result: RowCol = {
      row: Math.floor(index / 8),
      col: index % 8
    };
    return result;
  }

  // 根据行列获取索引
  getIndex(row: number, col: number): number {
    return row * 8 + col;
  }

  // 查找相邻同色方块（BFS算法）
  findConnectedBlocks(startIndex: number): number[] {
    const connectedBlocks: number[] = [];
    const visited: boolean[] = new Array(64).fill(false);
    const queue: number[] = [startIndex];
    const targetColor = this.blockStates[startIndex].color;
    
    while (queue.length > 0) {
      const currentIndex = queue.shift();
      if (currentIndex === undefined || visited[currentIndex]) {
        continue;
      }
      
      visited[currentIndex] = true;
      
      if (this.blockStates[currentIndex].color !== targetColor) {
        continue;
      }
      
      connectedBlocks.push(currentIndex);
      
      const rowCol = this.getRowCol(currentIndex);
      const row = rowCol.row;
      const col = rowCol.col;
      
      // 检查上
      if (row > 0) {
        const upIndex = this.getIndex(row - 1, col);
        if (!visited[upIndex]) {
          queue.push(upIndex);
        }
      }
      
      // 检查下
      if (row < 7) {
        const downIndex = this.getIndex(row + 1, col);
        if (!visited[downIndex]) {
          queue.push(downIndex);
        }
      }
      
      // 检查左
      if (col > 0) {
        const leftIndex = this.getIndex(row, col - 1);
        if (!visited[leftIndex]) {
          queue.push(leftIndex);
        }
      }
      
      // 检查右
      if (col < 7) {
        const rightIndex = this.getIndex(row, col + 1);
        if (!visited[rightIndex]) {
          queue.push(rightIndex);
        }
      }
    }
    
    return connectedBlocks;
  }

  // 计算得分（消除越多，分数越高）
  calculateScore(blockCount: number): number {
    if (blockCount === 1) {
      return 10;
    }
    // 基础分10分，每多一个方块加5分，并有额外奖励
    return 10 + (blockCount - 1) * 5 + Math.floor(blockCount * blockCount / 2);
  }

  // 消除方块并填充新方块
  eliminateAndFill(connectedBlocks: number[]) {
    // 消除方块动画
    animateTo({
      duration: 200,
      curve: Curve.EaseOut
    }, () => {
      for (const index of connectedBlocks) {
        this.blockStates[index].scale = 0;
        this.blockStates[index].opacity = 0;
      }
    });
    
    // 延迟后填充新方块
    setTimeout(() => {
      for (const index of connectedBlocks) {
        this.blockStates[index].color = this.randomColor();
        this.blockStates[index].scale = 1;
        this.blockStates[index].opacity = 1;
      }
    }, 200);
  }

  // 点击方块
  onBlockClick(index: number) {
    if (this.steps <= 0) {
      return;
    }
    
    // 减少步数
    this.steps--;
    
    // 查找相邻同色方块
    const connectedBlocks = this.findConnectedBlocks(index);
    
    // 计算得分
    const earnedScore = this.calculateScore(connectedBlocks.length);
    this.score += earnedScore;
    
    // 方块动画
    animateTo({
      duration: 150,
      curve: Curve.EaseOut
    }, () => {
      const block = this.blockStates[index];
      block.scale = 1.2;
      block.opacity = 0.5;
    });
    
    // 恢复原状并消除
    setTimeout(() => {
      animateTo({
        duration: 150,
        curve: Curve.EaseIn
      }, () => {
        const block = this.blockStates[index];
        block.scale = 1;
        block.opacity = 1;
      });
      
      // 消除并填充
      setTimeout(() => {
        this.eliminateAndFill(connectedBlocks);
      }, 150);
    }, 150);
    
    // 检查游戏结束
    if (this.steps === 0) {
      setTimeout(() => {
        this.showGameOverDialog();
      }, 500);
    }
  }

  // 显示游戏结束对话框
  showGameOverDialog() {
    AlertDialog.show({
      title: '游戏结束',
      message: `最终得分：${this.score}`,
      confirm: {
        value: '确定',
        action: () => {}
      }
    });
  }

  // 重置关卡
  resetLevel() {
    this.score = 0;
    this.steps = 20;
    this.initBlockStates();
  }

  // 下一关
  nextLevel() {
    this.score = 0;
    this.steps = 20;
    this.initBlockStates();
  }

  // 切换游戏（返回首页）
  switchGame() {
    if (this.context) {
      this.context.terminateSelf();
    }
  }

  build() {
    NavDestination() {
      Column({ space: 8 }) {
        // 游戏状态显示
        Row({ space: 20 }) {
          Text(`得分: ${this.score}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Text(`步数: ${this.steps}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 10, bottom: 10 })
        
        Text($r("app.string.Level2"))
          .width(CommonConstants.FULL_PERCENT)
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .textIndent(12)
          .fontColor($r('app.color.title_font_color'))
        
        List() {
          ForEach(this.blockArr, (item: number) => {
            ListItem() {
              Column() {
                Text()
                  .width("70%")
                  .aspectRatio(1)
                  .backgroundColor(this.blockStates[item].color)
                  .opacity(this.blockStates[item].opacity)
                  .scale({ x: this.blockStates[item].scale, y: this.blockStates[item].scale })
              }
              .width(CommonConstants.FULL_PERCENT)
              .height(CommonConstants.FULL_PERCENT)
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.onBlockClick(item);
              })
            }
            .border({ width: { right: 1, bottom: 1 }, color: $r('app.color.border_color') })
            .aspectRatio(1)
          }, (item: number) => item.toString())
        }
        .width(CommonConstants.FULL_PERCENT)
        .height("auto")
        .lanes(8)
        .border({ width: { top: 1, left: 1 }, color: $r('app.color.border_color') })
        .scrollBar(BarState.Off)
        .backgroundColor($r('app.color.portrait_bg'))
        
        // 游戏控制按钮
        Row({ space: 10 }) {
          Button('重置关卡')
            .fontSize(14)
            .width(100)
            .height(40)
            .onClick(() => {
              this.resetLevel();
            })
          
          Button('下一关')
            .fontSize(14)
            .width(100)
            .height(40)
            .onClick(() => {
              this.nextLevel();
            })
          
          Button('切换游戏')
            .fontSize(14)
            .width(100)
            .height(40)
            .onClick(() => {
              this.switchGame();
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 10, bottom: 10 })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        left: 16,
        right: 16,
        top: 28
      })
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .title($r("app.string.portrait_game"), { backgroundColor: $r('app.color.common_background_color') })
    .backgroundColor($r('app.color.common_background_color'))
  }
}