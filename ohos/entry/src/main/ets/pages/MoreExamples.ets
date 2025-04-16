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
import router from '@ohos.router';

@Entry
@Component
struct MoreExamples {
  @State message: string = 'Hello World';

  build() {
    Column() {
      HeaderComponent({ text: $r("app.string.index_more") })

      Column() {
        Button($r("app.string.load_json"))
          .margin({ top: 10 })
          .onClick(() => {
            router.pushUrl({ url: "pages/DownloadJson" });
          })

        Button($r("app.string.load_zip"))
          .margin({ top: 10 })
          .onClick(() => {
            router.pushUrl({ url: "pages/DownloadZip" });
          })

        Button($r("app.string.load_img"))
          .margin({ top: 10 })
          .onClick(() => {
            router.pushUrl({ url: "pages/DownloadImg" });
          })

        Button($r("app.string.animation_image"))
          .margin({ top: 10 })
          .onClick(() => {
            router.pushUrl({ url: "pages/UpdateImageShow" });
          })

        Button($r("app.string.animationShow_title"))
          .margin({ top: 10 })
          .onClick(() => {
            router.pushUrl({ url: "pages/AnimationShow" });
          })
        Button($r("app.string.reuseScenario_title"))
          .margin({ top: 10 })
          .onClick(() => {
            router.pushUrl({ url: "pages/ReuseScenario" })
          })

        Button($r("app.string.hidingParentNodes_title"))
          .margin({ top: 10 })
          .onClick(() => {
            router.pushUrl({ url: "pages/HidingParentNodes" })
          })

        Button($r("app.string.coordinatorExample_title"))
          .margin({ top: 10 })
          .onClick(() => {
            router.pushUrl({ url: "pages/CoordinatorExample" })
          })

        Button($r("app.string.frameCallback_title"))
          .margin({ top: 10 })
          .onClick(() => {
            router.pushUrl({ url: "pages/FrameCallbackCase" })
          })

        Button($r("app.string.all_animation"))
          .margin({ top: 10 })
          .onClick(() => {
            router.pushUrl({ url: "pages/AllAnimation" })
          })
      }
      .padding(10)
    }
    .height('100%')
    .width('100%')
  }
}