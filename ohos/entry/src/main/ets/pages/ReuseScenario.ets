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

import { HeaderComponent } from './HeaderComponent';
import lottie, { AnimationItem } from '@ohos/lottie';

class DemoLisItemInfo {
  name: string;
  icon: Resource;

  constructor(name: string, icon: Resource) {
    this.name = name;
    this.icon = icon;
  }
}

@Entry
@Component
struct ReuseScenario {
  @State videoList: Array<DemoLisItemInfo> = [];
  @State refreshing: boolean = false
  @State enterFrameText: string = "";

  aboutToAppear(): void {
    for (let i = 0; i < 10; i++) {
      this.videoList.push(new DemoLisItemInfo("item" + i, $r("app.media.icon")))
    }
  }

  build() {
    Stack() {
      Column() {
        HeaderComponent({ text: $r("app.string.reuseScenario_title") })

        Refresh({ refreshing: $$this.refreshing }) {
          List({ space: 5 }) {
            ForEach(this.videoList, (item: string, index: number) => {
              if (index === 0) {
                UpListComponent({ enterFrameText: this.enterFrameText })
                  .width('100%')
                  .height(200)
                  .margin({ bottom: 20})
              } else {
                ContentComponent({enterFrameText: this.enterFrameText})
                  .width('100%')
                  .height(200)
                  .margin({ bottom: 20})
              }
            }, (item: string) => item)
          }
          .cachedCount(2)
          .width('100%')
          .height("90%")
          .listDirection(Axis.Vertical)
          .alignListItem(ListItemAlign.Center)
          .backgroundColor("#fafafa")
        }
        .onRefreshing(() => {
          setTimeout(() => {
            this.refreshing = false
          }, 2000)
          console.log('onRefreshing test')
        })
      }
    }
    .width("100%")

  }
}

@Component
struct UpListComponent {
  @Link enterFrameText: string;
  @State item: Array<number> = [1, 2, 3, 4];
  private animationName: string = "topAnimation1";
  private animateItem: AnimationItem | null = null;
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext1: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);

  aboutToAppear(): void {
    lottie.destroy(this.animationName);
    this.animateItem = null;
  }
  aboutToDisappear(): void {
    lottie.destroy(this.animationName);
    this.animateItem = null;
  }

  build() {
    List({ space: 5 }) {
      Repeat(this.item)
        .each((obj: RepeatItem<number>) => {
          if (obj.index === 0) {
            Canvas(this.canvasRenderingContext1)
              .width("25%")
              .height(100)
              .onReady(() => {
                if (this.animateItem) {
                  this.animateItem.resize();
                } else {
                  this.animateItem = lottie.loadAnimation({
                    container: this.canvasRenderingContext1,
                    renderer: 'canvas',
                    loop: true,
                    autoplay: true,
                    name: '2016',
                    contentMode: 'Contain',
                    path: "common/lottie/robotYoga.json",
                  })
                  this.animateItem?.addEventListener('enterFrame', (args: Object): void => {
                    this.enterFrameText = this.animateItem?.currentFrame?.toString() || "";
                  });
                }
              })
          } else {
            ListItem() {
              Image($r("app.media.icon"))
                .width("100%")
            }
            .width("23%")
          }
        })
        .virtualScroll()
    }
    .cachedCount(2)
    .height("90%")
    .listDirection(Axis.Horizontal)
    .alignListItem(ListItemAlign.Center)
  }

}

@Component
struct ContentComponent {
  @Prop enterFrameText: string;

  build() {
    Column() {
      Text($r("app.string.reuseScenario_text"))
        .fontColor(Color.Black)
        .margin({ bottom: 20 })
      Text("Drawing frames: " + this.enterFrameText)
        .fontColor(Color.Black)
        .margin({ bottom: 20 })
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .height("100%")
    .margin({ bottom: 10 })
    .padding(10)
    .backgroundColor(Color.White)
  }
}

