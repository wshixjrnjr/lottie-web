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

import lottie from '@ohos/lottie'
import { AnimationItem, AnimationEventCallback } from '@ohos/lottie'
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { HeaderComponent } from './HeaderComponent';

@Entry
@Component
struct AnimationShow {
  @State animationDuration: string = this.getResourceString($r('app.string.get_duration'));
  @State pauseState: string = this.getResourceString($r('app.string.check_state'));
  @State isCanvasVisible: Visibility = Visibility.Visible;
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings)
  private mainRenderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private mainCanvasRenderingContext: CanvasRenderingContext2D =
    new CanvasRenderingContext2D(this.mainRenderingSettings)
  private animateItem: AnimationItem | null = null;
  private animateItem2: AnimationItem | null = null;
  private animateName: string = "grunts";
  @State subFramed?: boolean = undefined;
  @State currentFrame?: number = undefined;
  @State currentRawFrame?: number = undefined;
  @State totalFrames?: number = undefined;
  @State playCount?: number = undefined;
  @State totalPlayedCount: number = 0;
  @State playDirecton?: number = undefined;
  @State playSpeed?: number = undefined;
  @State subFramed2?: boolean = undefined;
  @State currentFrame2?: number = undefined;
  @State currentRawFrame2?: number = undefined;
  @State totalFrames2?: number = undefined;
  @State playCount2?: number = undefined;
  @State totalPlayedCount2: number = 0;
  @State playDirecton2?: number = undefined;
  @State playSpeed2?: number = undefined;

  updateAllStates() {
    this.subFramed = this.animateItem?.isSubframeEnabled;
    this.currentFrame = this.animateItem?.currentFrame;
    this.currentRawFrame = this.animateItem?.currentRawFrame;
    this.totalFrames = this.animateItem?.totalFrames;
    this.playCount = this.animateItem?.playCount;
    this.playDirecton = this.animateItem?.playDirection;
    this.playSpeed = this.animateItem?.playSpeed;
  }

  updateAllStates2() {
    this.subFramed2 = this.animateItem2?.isSubframeEnabled;
    this.currentFrame2 = this.animateItem2?.currentFrame;
    this.currentRawFrame2 = this.animateItem2?.currentRawFrame;
    this.totalFrames2 = this.animateItem2?.totalFrames;
    this.playCount2 = this.animateItem2?.playCount;
    this.playDirecton2 = this.animateItem2?.playDirection;
    this.playSpeed2 = this.animateItem2?.playSpeed;
  }

  aboutToAppear(): void {
    console.info('aboutToAppear');
  }

  /**
   * 页面销毁时释放动画资源
   */
  aboutToDisappear(): void {
    console.info('aboutToDisappear');
  }

  build() {
    Column() {
      HeaderComponent({ text: $r("app.string.animationShow_title")})

      Scroll() {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          Column() {
            Row({ space: 10 }) {
              Canvas(this.canvasRenderingContext)
                .width('60%')
                .height(200)
                .onReady(() => {
                  this.animateItem2?.resize();
                })
                .onDisAppear(() => {
                  // 组件移除时，可销毁动画资源
                  lottie.destroy("2024");
                })
                .visibility(this.isCanvasVisible)
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }.height('30%')
          .width('100%')

          Scroll() {
            Column() {
              Row() {
                Button($r("app.string.load_2016"))
                  .onClick(() => {
                    lottie.destroy('2024')
                    this.animateItem2 = lottie.loadAnimation({
                      container: this.canvasRenderingContext,
                      renderer: 'canvas', // canvas 渲染模式
                      loop: true,
                      autoplay: true,
                      name: '2024',
                      contentMode: 'Contain',
                      path: "common/lottie/data.json", // 路径加载动画只支持entry/src/main/ets 文件夹下的相对路径
                    })
                    this.animateItem2.addEventListener('enterFrame', (args: Object): void => {
                      this.updateAllStates2();
                    }); //只要播放，会一直触发
                  })

                Button($r("app.string.load_grunt"))
                  .onClick(() => {
                    lottie.destroy(this.animateName)
                    this.animateItem = lottie.loadAnimation({
                      container: this.mainCanvasRenderingContext,
                      renderer: 'canvas', // canvas 渲染模式
                      loop: true,
                      autoplay: true,
                      name: this.animateName,
                      contentMode: 'Contain',
                      path: "common/lottie/grunt.json", // 路径加载动画只支持entry/src/main/ets 文件夹下的相对路径
                    })
                    this.animateItem.addEventListener('enterFrame', (args: Object): void => {
                      this.updateAllStates();
                    }); //只要播放，会一直触发
                  })

                Button($r("app.string.hide"))
                  .onClick(() => {
                    this.isCanvasVisible = Visibility.Hidden;
                  })

                Button($r("app.string.show"))
                  .onClick(() => {
                    this.isCanvasVisible = Visibility.Visible;
                  })
                Button($r("app.string.destroy"))
                  .onClick(() => {
                    lottie.destroy('2024');
                    lottie.destroy(this.animateName);

                    this.currentFrame = 0;
                    this.currentRawFrame = 0;
                    this.totalFrames = 0;
                    this.playCount = 0;
                    this.playDirecton = 0;
                    this.playSpeed = 0;

                    this.currentFrame2 = 0;
                    this.currentRawFrame2 = 0;
                    this.totalFrames2 = 0;
                    this.playCount2 = 0;
                    this.playDirecton2 = 0;
                    this.playSpeed2 = 0;

                  })

              }.margin({ top: 5 })

              Row() {
                Canvas(this.mainCanvasRenderingContext)
                  .width('60%')
                  .height(200)
                  .onReady(() => {
                    this.animateItem2?.resize();
                  })
                  .onDisAppear(() => {
                    // 组件移除时，可销毁动画资源
                    lottie.destroy(this.animateName);
                  })
                  .visibility(this.isCanvasVisible)
              }.margin({ top: 5 })

              Row() {
              }.margin({ top: 50 })

              Row() {
                Text($r("app.string.animation_2016"));
              }.margin({ top: 20 })

              Row() {
                Text(this.currentFrame2 !== undefined ?
                  this.currentFrame2.toFixed(2) + " " + this.getResourceString($r("app.string.frame")) : " ")
                  .margin({ left: 5 })
                Text(this.totalFrames2 !== undefined ?
                  this.getResourceString($r("app.string.total")) + " " + " " + this.totalFrames2 +
                  this.getResourceString($r("app.string.frame")) + "" : " ").margin({ left: 5 })
                Text(this.playCount2 !== undefined ?
                  this.playCount2 + " " + this.getResourceString($r("app.string.time")) : " ").margin({ left: 5 })
                Text(this.getResourceString($r("app.string.total")) + " " + this.totalPlayedCount2 + " " +
                this.getResourceString($r("app.string.time"))).margin({ left: 5 })
                Text(this.playDirecton2 !== undefined ?
                  (this.playDirecton2 > 0 ? this.getResourceString($r("app.string.forward")) :
                  this.getResourceString($r("app.string.backward"))) : " ").margin({ left: 5 })
                Text(this.playSpeed2 !== undefined ?
                  this.getResourceString($r("app.string.speed")) + " " + this.playSpeed2 : " ").margin({ left: 5 })
              }.margin({ top: 5 })

              Row() {
                Text($r("app.string.animation_grunt"));
              }.margin({ top: 20 })

              Row() {
                Text(this.currentFrame !== undefined ?
                  this.currentFrame.toFixed(2) + " " + this.getResourceString($r("app.string.frame")) : " ")
                  .margin({ left: 5 })
                Text(this.totalFrames !== undefined ?
                  this.getResourceString($r("app.string.total")) + " " + " " + this.totalFrames +
                  this.getResourceString($r("app.string.frame")) + "" : " ").margin({ left: 5 })
                Text(this.playCount !== undefined ?
                  this.playCount + " " + this.getResourceString($r("app.string.time")) :
                  " ").margin({ left: 5 })
                Text(this.getResourceString($r("app.string.total")) + " " + this.totalPlayedCount + " " +
                this.getResourceString($r("app.string.time"))).margin({ left: 5 })
                Text(this.playDirecton !== undefined ?
                  (this.playDirecton > 0 ? this.getResourceString($r("app.string.forward")) :
                  this.getResourceString($r("app.string.backward"))) : " ").margin({ left: 5 })
                Text(this.playSpeed !== undefined ?
                  this.getResourceString($r("app.string.speed")) + " " + this.playSpeed : " ").margin({ left: 5 })
              }.margin({ top: 5 })

              Column(){
                Text($r("app.string.animationShow_text1"))
                Text($r("app.string.animationShow_text2"))
                Text($r("app.string.animationShow_text3"))
              }
              .padding({top: 15})
              .alignItems(HorizontalAlign.Start)
            }
          }
          .nestedScroll({ scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.PARENT_FIRST })
          .scrollBar(BarState.Off)
          .height('80%')

          Blank().width('100%').height('100%').backgroundColor('#F0F0F0')
        }
      }
      .scrollBar(BarState.Off)
      .width('100%')
    }
  }

  getResourceString(res: Resource) {
    return getContext().resourceManager.getStringSync(res.id)
  }
}
