1. 什麼是 Skills？
Skills 就是資料夾：它被定義為「組織好的檔案集合，打包了可組合的程序性知識」。因為本質上是資料夾，所以非常容易透過 Git 版控、Google Drive 或壓縮成 zip 來分享與管理。
漸進式載入 (Progressive Disclosure)：這是解決 Context Window (上下文視窗) 限制的關鍵。Agent 一開始只會看到 Skill 的 name 和 description，只有在真正需要時，才會進一步讀取詳細內容或特定檔案。這使得系統可以同時掛載成百上千個 Skills 而不會撐爆 Context Window。
2. Scripts 作為工具的優勢 (Scripts as Tools)
優於傳統 Function Calling：傳統的 Tool 說明往往寫得模糊，且模型若卡住也無法修改工具本身。
高彈性與低佔用：將腳本 (Scripts) 作為工具，程式碼本身就是文件，隨時可以被修改調整；平時不佔用 Context Window，只有在執行或需要時才載入。
3. 完整架構定位：Agent + MCP + Skills
Models (模型) = 處理器：擁有巨大潛力，但單獨存在時作用有限。
Agents (智能體) = 作業系統：負責管理 Context (迴圈管理)、編排資源，讓模型發揮價值。
MCP Servers = 外部連接埠：向左連接外部資料源與工具。
Skills = 應用程式 (Applications)：向右連接檔案系統的 Skills 庫，提供 AI 「領域專業知識 (Domain Expertise)」。
互補關係：MCP 提供「連接」能力，而 Skills 提供「專業知識」，兩者在 Agent 架構中相輔相成。
4. 發展思維的典範轉移 (Paradigm Shift)
核心呼籲：💡 「與其花時間在從零打造 Agent 架構上，不如把領域知識好好整理成 Skills。」
價值累積：精心整理的領域知識 (Skills) 才是真正能產生「複利效應」並且持續累積的資產。
未來軟體工程 (Treat Skills like Software)：隨著 Skills 越來越複雜，它將被視為真正的軟體來對待，包含評估 (Evaluation)、版本控制 (Versioning) 以及可組合性 (Composability)。最終願景是由人類與 Agent 共同策展的「集體知識庫」。