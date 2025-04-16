/**
 * MIT License
 *
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import lottie, { AnimationItem } from '@ohos/lottie';
import { HeaderComponent } from './HeaderComponent';

@Entry
@Component
struct Page {
  pageInfos: NavPathStack = new NavPathStack();
  isUseInterception: boolean = false;
  @State currentIndex: number = 0;
  private controller: TabsController = new TabsController()

  build() {
    Row() {
      Column() {
        HeaderComponent({ text: $r("app.string.hidingParentNodes_title") })

        Navigation(this.pageInfos) {
          Column() {
            Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
              TabContent() {
                Column() {
                  MainSubMainPage()
                    .width("100%")
                    .height("100%")
                }
                .width("100%")
                .height("100%")
                .backgroundColor("#fafafa")
              }
            }
            .vertical(false)
            .barMode(BarMode.Fixed)
            .barWidth(360)
            .barHeight(0)
          }
        }
        .title($r("app.string.hidingParentNodes_title"))
        .backgroundColor("#fafafa")
      }
      .width("100%")
      .height("100%").justifyContent(FlexAlign.SpaceBetween)
    }
    .height('100%')
  }
}


@Component
struct MainSubMainPage {
  @State isRefreshing: boolean = false;
  @State isRefreshFinish: boolean = false;
  @State enterFrameText: string = "";
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);
  private animateItem: AnimationItem | null = null;
  private canvasId: number = 0;
  private componentId: number = 0;
  private animationName: string = "HidingParentNodes";

  aboutToAppear(): void {
    lottie.destroy(this.animationName);
  }

  aboutToDisappear(): void {
    lottie.destroy(this.animationName);
  }

  loadAnimation() {
    let animateItem = lottie.loadAnimation({
      container: this.canvasRenderingContext,
      renderer: 'canvas',
      loop: true,
      autoplay: true,
      name: this.animationName,
      contentMode: 'Contain',
      frameRate: 60,
      initialSegment: [10, 20],
      path: "common/lottie/robotYoga.json"
    })
    animateItem.addEventListener('enterFrame', (args: Object): void => {
      console.info("lottie enterFrame");
      this.enterFrameText = animateItem.currentFrame.toString();
    });
    return animateItem;
  }

  fakedRefreshList() {
    setTimeout(() => {
      this.animateItem?.pause();
      this.isRefreshFinish = true;
      setTimeout(() => {
        this.isRefreshing = false;
        this.isRefreshFinish = false;
      }, 1000)
    }, 1000)
  }

  @Builder
  customRefreshComponent() {
    Stack() {
      if (this.isRefreshFinish) {
        Text("Refreshed").fontColor(Color.Black)
      } else {
        Canvas(this.canvasRenderingContext)
          .id(this.canvasId.toString())
          .onReady(() => {
            console.info("lottie_ohos=========canvas" + this.canvasId);
            this.animateItem?.destroy();
            this.animateItem = null;
            setTimeout(() => {
              if (!this.animateItem) {
                this.animateItem = this.loadAnimation();
              }
            }, 100)
          })
          .width(100)
          .height(100)
        Row().onDisAppear(() => {
          this.canvasId++;
        })
      }
    }
    .visibility(this.isRefreshing ? Visibility.Visible : Visibility.None)
  }

  build() {
    Refresh({ refreshing: $$this.isRefreshing, builder: this.customRefreshComponent() }) {
      ListPage({ enterFrameText: this.enterFrameText })
    }
    .onRefreshing(() => {
      this.animateItem?.pause();
      this.fakedRefreshList();
    })
  }
}

@Component
struct ListPage {
  @Prop enterFrameText: string = "";
  list: Array<number> = [1, 2, 3, 4];

  build() {
    List() {
      ForEach(this.list, (item: number) => {
        ListItem() {
          Column() {
            Text($r("app.string.hidingParentNodes_title2"))
              .fontColor(Color.Black)
              .margin({ bottom: 20 })
            Text("Drawing frames: " + this.enterFrameText)
              .fontColor(Color.Black)
          }
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Center)
          .width("100%")
          .height("100%")
          .padding(10)
          .backgroundColor(Color.White)
        }
        .width("100%")
        .height(200)
        .margin({ bottom: 10 })
      })
    }
  }
}