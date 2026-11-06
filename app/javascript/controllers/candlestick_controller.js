
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "chart",
    "price",
    "change",
    "high",
    "low",
    "previous",
    "message"
  ]

  static values = {
    url: String
  }

  connect() {
    this.createChart()
    this.loadData(this.urlValue)
  }

  disconnect() {
    this.resizeObserver?.disconnect()
    this.chart?.remove()
  }

 createChart() {
    const library = window.LightweightCharts

    if (!library) {
      this.messageTarget.textContent = "Chart library could not be loaded."
      console.error("LightweightCharts is not available")
      return
    }

    const width = this.chartTarget.clientWidth || 800

    this.chart = library.createChart(this.chartTarget, {
      width,
      height: 380,
      layout: {
        background: { color: "#0f172a" },
        textColor: "#64748B"
      },
      grid: {
        vertLines: { color: "#F1F5F9" },
        horzLines: { color: "#F1F5F9" }
      },
      rightPriceScale: {
        borderColor: "#E2E8F0"
      },
      timeScale: {
        borderColor: "#E2E8F0",
        timeVisible: false,
        rightOffset: 5
      },
      crosshair: {
        mode: library.CrosshairMode.Normal
      }
    })

    this.candles = this.chart.addCandlestickSeries({
      upColor: "#16A34A",
      downColor: "#EF4444",
      borderUpColor: "#16A34A",
      borderDownColor: "#EF4444",
      wickUpColor: "#16A34A",
      wickDownColor: "#EF4444"
    })

    this.resizeObserver = new ResizeObserver(() => {
      const width = this.chartTarget.clientWidth

      if (width > 0) {
        this.chart.applyOptions({ width })
      }
    })

    this.resizeObserver.observe(this.chartTarget)
  }

  async loadData(url) {
    this.messageTarget.textContent = "Loading market data..."

    try {
      const response = await fetch(url, {
        headers: {
          Accept: "application/json"
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }

      const result = await response.json()

      const candles = result.candles || []
      const summary = result.summary || {}

      if (candles.length === 0) {
        this.candles.setData([])
        this.messageTarget.textContent =
          "No historical data available for this period."
        return
      }

      this.candles.setData(candles)
      this.chart.timeScale().fitContent()

      this.updateSummary(summary)

      this.messageTarget.textContent =
        `${candles.length} historical trading sessions`

    } catch (error) {
      console.error("Error loading stock chart:", error)

      this.messageTarget.textContent =
        "Unable to load historical market data."
    }
  }

  updateSummary(summary) {
    this.priceTarget.textContent =
      this.formatCurrency(summary.current_price)

    this.previousTarget.textContent =
      this.formatCurrency(summary.previous_price)

    this.highTarget.textContent =
      this.formatCurrency(summary.highest)

    this.lowTarget.textContent =
      this.formatCurrency(summary.lowest)

    const change = Number(summary.change_percentage || 0)

    this.changeTarget.textContent =
      `${change > 0 ? "+" : ""}${change.toFixed(2)}%`

    this.changeTarget.className = change >= 0
      ? "text-sm font-semibold px-3 py-1 rounded-full bg-green-50 text-green-600"
      : "text-sm font-semibold px-3 py-1 rounded-full bg-red-50 text-red-600"
  }

  changeRange(event) {
    const range = event.currentTarget.dataset.range

    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("range", range)

    this.loadData(url.toString())

    this.element.querySelectorAll("[data-range]").forEach(button => {
      button.classList.remove(
        "bg-blue-600",
        "text-white",
        "border-blue-600"
      )

      button.classList.add("text-slate-500")
    })

    event.currentTarget.classList.add(
      "bg-blue-600",
      "text-white",
      "border-blue-600"
    )
  }

  formatCurrency(value) {
    if (value == null || !Number.isFinite(Number(value))) {
      return "--"
    }

    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD"
    }).format(value)
  }
}
