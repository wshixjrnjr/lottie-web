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

import lottie from '@ohos/lottie';
import { AnimationItem } from '@ohos/lottie';
import { HeaderComponent } from './HeaderComponent';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct AllAnimation {
  // 渲染构建上下文
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);
  private animateItem: AnimationItem | null = null;
  // 动画名称
  private animateName: string = "ALL";
  @State basePath: string = 'common/lottie/';
  @State fileName: string = 'data.json';
  @State path: string = 'common/lottie/data.json';
  @State fileNameList: Array<string> = [
    'animation.json',
    'data.json',
    'data_base64.json',
    'data_rawfile.json',
    'data_url.json',
    'door_lock.json',
    'grunt.json',
    'navidad.json',
    'red_heart.jsonn',
    'robotYoga.json'
  ]

  aboutToDisappear() {
    lottie.destroy(this.animateName);
  }

  build() {
    Column() {
      HeaderComponent({ text: $r("app.string.all_animation") })

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
        Row({ space: 10 }) {
          // 关联画布
          Canvas(this.canvasRenderingContext)
            .width(200)
            .height(200)
            .backgroundColor(Color.Gray)
            .onReady(() => {
              // 可在此生命回调周期中加载动画，可以保证动画尺寸正确
              this.animateItem?.resize();
            })
            .onDisAppear(() => {
              lottie.destroy(this.animateName);
            })
            .margin(30)
        }

        Row() {
          TextInput({ text: this.path })
            .height(40)
            .width('100%')
            .borderRadius(50)
            .backgroundColor('#F1F3F5')
            .onChange((value) => {
              this.path = value;
            })
        }.margin({ top: 5 })

        Row() {
          Button($r("app.string.load_animation"))
            .onClick(() => {
              lottie.destroy(this.animateName)
              this.animateItem = lottie.loadAnimation({
                path: this.path,
                isNetwork: false,
                container: this.canvasRenderingContext,
                renderer: 'canvas', // canvas 渲染模式
                loop: true,
                autoplay: true,
                name: this.animateName,
              })
              this.animateItem.addEventListener('error', (args: Object): void => {
                console.info("error:" + JSON.stringify(args));
              });
            })
        }.margin({ top: 5 })

        Row() {
          Button($r("app.string.play"))
            .onClick(() => {
              lottie.play(this.animateName);
            })

          Button($r("app.string.pause"))
            .onClick(() => {
              lottie.pause(this.animateName);
            })

          Button($r("app.string.destroy"))
            .onClick(() => {
              if (this.animateItem != null) {
                this.animateItem = null;
              }
              lottie.destroy(this.animateName);
            })
        }.margin({ top: 5 })
      }
      .margin(5)
      .width('100%')
      .height(320)


      Scroll() {
        Column() {
          List() {

            ForEach(this.fileNameList, (Item: string, index) => {
              ListItem() {
                Column() {
                  Text(Item)
                }
                .width('100%')
                .borderRadius(10)
                .height(30)
                .backgroundColor('#ffffffff')
              }.onClick(() => {
                this.fileName = Item;
                this.path = this.basePath + this.fileName;
              })
              .margin(10)
            }, (Item: string) => Item)

          }.width('100%')
          .height(1000)
        }.backgroundColor('#F1F3F5')
      }
    }
    .width('100%')
    .height('100%')
  }

  onBackPress(): boolean | void {
    if (this.animateItem != null) {
      this.animateItem = null;
    }
    lottie.destroy(this.animateName);
    return false;
  }

  getResourceString(res: Resource) {
    return getContext().resourceManager.getStringSync(res.id)
  }
}