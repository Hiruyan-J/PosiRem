import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="infinite-scroll"
export default class extends Controller {
  static values =  { url: String }

  connect() {
    this.firstLoad = true // 最初の読み込みスキップフラグ

    this.scrollToBottom()  // 初回接続時にスクロールを最下部へ移動

    this.observer = new IntersectionObserver(entries => {
      if (entries[0].isIntersecting) {
        // 最初の読み込みはスキップ
        if (this.firstLoad) {
          this.firstLoad = false
          return
        }
        this.load()
      }
    })

    this.observer.observe(this.element)  // 監視開始
  }

  load() {
    // 多重読み込み防止
    if (this.loading) return
    this.loading = true

    // `conversation_数字` の形式のIDを取得
    const first = document.querySelector("[id^='conversation_']")
    if (!first) {
      this.loading = false  // メッセージが存在しない場合は終了
      return
    }

    // 要素のIDから数字部分を抽出
    const beforeId = first.id.replace("conversation_", "")
    console.log("Loading messages before ID:", beforeId)  // TODO:デバッグ用ログ削除

    // 【スクロール準備】チャットメッセージコンテナの高さを取得
    const scrollContainer = document.getElementById("chat-messages")
    const prevHeight = scrollContainer.scrollHeight

    // Turboストリームで古いメッセージを取得
    fetch(`${this.urlValue}?before_id=${beforeId}`, {
      headers: { Accept: "text/vnd.turbo-stream.html" }
    })
      .then(response => response.text())  // TurboストリームのHTMLを取得
      .then(html => {
        // 【画面の更新】Turboストリームを使用して画面を更新
        Turbo.renderStreamMessage(html)

        // ブラウザの描画が完了するのを待つ
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            // 【スクロール位置調整】スクロール位置を維持
            const newHeight = scrollContainer.scrollHeight
            scrollContainer.scrollTop += (newHeight - prevHeight)
            console.log("Adjusted scrollTop by:", newHeight - prevHeight)  // TODO:デバッグ用ログ削除

            // 読み込み完了(読み込みフラグを解除)
            this.loading = false
          })
        })
      })
  }

  // 最下部までスクロール
  scrollToBottom() {
    const scrollContainer = document.getElementById("chat-messages")
    if (scrollContainer) {
      scrollContainer.scrollTop = scrollContainer.scrollHeight
    }
  }
}
