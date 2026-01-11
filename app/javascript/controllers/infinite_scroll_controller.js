import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="infinite-scroll"
export default class extends Controller {
  static targets = [ "scrollContainer", "sentinel" ]
  static values =  { url: String }

  connect() {
    console.log("InfiniteScrollController connected")
    this.loading = false // 読み込み中フラグ

    this.scrollToBottom()  // 初回接続時にスクロールを最下部へ移動

    this.setupObserver()

  }

  // IntersectionObserverのセットアップ
  setupObserver() {
    console.log("Setting up IntersectionObserver")  // TODO:デバッグ用ログ削除
    this.observer = new IntersectionObserver(entries => {
      if (entries[0].isIntersecting) {
        console.log("読み込み前のスクロールTop:", this.scrollContainerTarget.scrollTop)  // TODO:デバッグ用ログ削除
        console.log("読み込み前のContainerの高さ:", this.scrollContainerTarget.scrollHeight)  // TODO:デバッグ用ログ削除
        this.load()
      }
    }, {
      root: this.hasScrollContainerTarget ? this.scrollContainerTarget : null,
      rootMargin: '50px 0px 0px 0px'
    })

    // Targetとして定義した要素を監視
    if (this.hasSentinelTarget) {
      this.observer.observe(this.sentinelTarget)
    }
  }

  // 古いメッセージの読み込み
  async load() {
    console.log("Loading more messages")  // TODO:デバッグ用ログ削除
    // 多重読み込み防止
    if (this.loading) return

    // `conversation_数字` の形式のIDを取得
    const firstMessage = this.scrollContainerTarget.querySelector("[id^='conversation_']")
    if (!firstMessage) return // メッセージが存在しない場合は終了

    // 要素のIDから数字部分を抽出
    const beforeId = firstMessage.id.replace("conversation_", "")
    console.log("Loading messages before ID:", beforeId)  // TODO:デバッグ用ログ削除

    this.loading = true  // 読み込み開始

    try {
      // 【スクロール準備】チャットメッセージコンテナの高さを取得
      const prevHeight = this.scrollContainerTarget.scrollHeight

      // Turboストリームで古いメッセージを取得
      const response = await fetch(`${this.urlValue}?before_id=${beforeId}`, {
        headers: { Accept: "text/vnd.turbo-stream.html" }
      })

      const html = await response.text()  // TurboストリームのHTMLを取得

      await Turbo.renderStreamMessage(html)  // 【画面の更新】Turboストリームを使用して画面を更新

      // 無限スクロールの終端に到達した場合の処理
      console.log("Checking if all messages are loaded:", this.sentinelTarget.querySelector('[data-all-loaded="true"]'))  //TODO:デバッグ用ログ削除
      if (this.sentinelTarget.querySelector('[data-all-loaded="true"]')) {
        console.log("All messages loaded. Disconnecting observer.")  //TODO:デバッグ用ログ削除
        this.observer.disconnect()
        this.loading = false  //TODO:終了処理消してもOK?
        return
      }

      await this.maintainScrollPosition(prevHeight)  // 【スクロール位置調整】スクロール位置を維持
    } catch (error) {
      console.error("通信エラー:", error)
    } finally {
      this.loading = false  // 読み込み完了
    }
  }

  maintainScrollPosition(prevHeight) {
    // ブラウザの描画が完了するのを待つ
    return new Promise(resolve => {
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          // 【スクロール位置調整】スクロール位置を維持
          const newHeight = this.scrollContainerTarget.scrollHeight
          const diff = newHeight - prevHeight
          if (diff > 0) {
            this.scrollContainerTarget.scrollTop += diff
          }
          resolve()
        })
      })
    })
  }

  // 最下部までスクロール
  scrollToBottom() {
    if (this.scrollContainerTarget) {
      this.scrollContainerTarget.scrollTop = this.scrollContainerTarget.scrollHeight
    }
  }

  // コントローラが切断されたときの処理
  disconnect() {
    // IntersectionObserverの監視を停止
    if (this.observer) {
      this.observer.disconnect()
    }
  }
}
