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

import router from '@ohos.router';

@Component
export struct HeaderComponent {
  @State text: string | ResourceStr = "";

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      Image($r("app.media.arrow_right"))
        .margin({ right: 10 })
        .width(20)
        .height(20)
        .onClick(() => {
          router.back();
        })
      Text(this.text)
        .fontSize(20)
      Blank()
        .width(20)
        .height(20)
    }
    .padding(10)
    .backgroundColor(Color.White)
    .shadow({ radius: 5, color: "rgba(0,0,0,0.06)", offsetX: 0, offsetY: 10, type: ShadowType.COLOR})
  }
}